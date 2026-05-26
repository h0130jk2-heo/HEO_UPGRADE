#!/usr/bin/env bash
# Turbo Pipeline — Automated feature builder using claude -p
# Reads feature_list.json, builds dependency waves, and executes each feature
# in a fresh claude -p session. Independent features run in parallel.
#
# Usage:
#   ./turbo-pipeline.sh --project /path/to/project
#   ./turbo-pipeline.sh --project /path/to/project --count 3 --model opus
#   ./turbo-pipeline.sh --project /path/to/project --dry-run
#   ./turbo-pipeline.sh --project /path/to/project --parallel 3

set -euo pipefail

# --- Defaults ---
PROJECT=""
COUNT=999
MODEL="sonnet"
PARALLEL=1
TIMEOUT_MINUTES=10
DRY_RUN=false

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)   PROJECT="$2"; shift 2 ;;
        --count)     COUNT="$2"; shift 2 ;;
        --model)     MODEL="$2"; shift 2 ;;
        --parallel)  PARALLEL="$2"; shift 2 ;;
        --timeout)   TIMEOUT_MINUTES="$2"; shift 2 ;;
        --dry-run)   DRY_RUN=true; shift ;;
        -h|--help)
            echo "Usage: $0 --project <path> [--count N] [--model sonnet|opus] [--parallel N] [--timeout N] [--dry-run]"
            exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$PROJECT" ]]; then
    echo "ERROR: --project is required" >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required. Install with: sudo apt install jq (or brew install jq)" >&2
    exit 1
fi

if ! command -v claude &>/dev/null; then
    echo "ERROR: claude CLI not found. Install Claude Code first." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/turbo-prompt-template.md"
FEATURE_LIST="$PROJECT/feature_list.json"
START_TIME=$(date +%s)

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

log() { echo -e "${CYAN}[$(date +%H:%M:%S)]${NC} $1"; }
log_color() { echo -e "${2}[$(date +%H:%M:%S)] $1${NC}"; }

# --- Helpers ---

read_file_or_empty() {
    if [[ -f "$1" ]]; then
        cat "$1"
    else
        echo "(not found)"
    fi
}

# --- Step 1: Load project context ---

log "Loading project context from: $PROJECT"

if [[ ! -f "$FEATURE_LIST" ]]; then
    echo "ERROR: feature_list.json not found in $PROJECT" >&2
    exit 1
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "ERROR: turbo-prompt-template.md not found at $TEMPLATE_FILE" >&2
    exit 1
fi

CLAUDE_MD=$(read_file_or_empty "$PROJECT/CLAUDE.md")
ARCH_MD=$(read_file_or_empty "$PROJECT/docs/Architecture.md")
if [[ "$ARCH_MD" == "(not found)" ]]; then
    ARCH_MD=$(read_file_or_empty "$PROJECT/Architecture.md")
fi
LESSONS=$(read_file_or_empty "$HOME/.claude/rules/lessons-learned.md")
INSTINCTS=$(read_file_or_empty "$HOME/.claude/rules/instincts.md")
TEMPLATE=$(cat "$TEMPLATE_FILE")

# --- Step 2: Build dependency waves ---

REMAINING_IDS=($(jq -r '.features[] | select(.passes != true) | .id' "$FEATURE_LIST"))
REMAINING_COUNT=${#REMAINING_IDS[@]}

if [[ $REMAINING_COUNT -eq 0 ]]; then
    log_color "All features already pass. Nothing to build." "$GREEN"
    exit 0
fi

log "Remaining features: $REMAINING_COUNT"

# Build waves using topological sort on depends_on
build_waves() {
    local completed_ids
    completed_ids=$(jq -r '.features[] | select(.passes == true) | .id' "$FEATURE_LIST" | tr '\n' ' ')

    local wave_num=0
    local all_remaining=("${REMAINING_IDS[@]}")
    local failed_ids=()

    # Store waves as wave_N variables (bash doesn't support 2D arrays)
    while [[ ${#all_remaining[@]} -gt 0 ]]; do
        local wave=()
        local still_remaining=()
        local progress=false

        for fid in "${all_remaining[@]}"; do
            local deps
            deps=$(jq -r --arg id "$fid" '.features[] | select(.id == $id) | .depends_on // [] | .[]' "$FEATURE_LIST" 2>/dev/null || true)

            local deps_met=true
            local deps_blocked=false

            if [[ -n "$deps" ]]; then
                while IFS= read -r dep; do
                    # Check if dep failed
                    for failed in "${failed_ids[@]+"${failed_ids[@]}"}"; do
                        if [[ "$failed" == "$dep" ]]; then
                            deps_blocked=true
                            break
                        fi
                    done
                    [[ "$deps_blocked" == "true" ]] && break

                    # Check if dep completed
                    if ! echo "$completed_ids" | grep -qw "$dep"; then
                        deps_met=false
                        break
                    fi
                done <<< "$deps"
            fi

            if [[ "$deps_blocked" == "true" ]]; then
                failed_ids+=("$fid")
                progress=true
            elif [[ "$deps_met" == "true" ]]; then
                wave+=("$fid")
                progress=true
            else
                still_remaining+=("$fid")
            fi
        done

        if [[ ${#wave[@]} -eq 0 && "$progress" == "false" ]]; then
            for fid in "${still_remaining[@]}"; do
                failed_ids+=("$fid")
            done
            break
        fi

        if [[ ${#wave[@]} -gt 0 ]]; then
            # Store wave in a global variable
            eval "WAVE_${wave_num}=(${wave[*]})"
            WAVE_COUNT=$((wave_num + 1))
            wave_num=$((wave_num + 1))
            completed_ids="$completed_ids ${wave[*]}"
        fi

        all_remaining=("${still_remaining[@]+"${still_remaining[@]}"}")
        [[ ${#all_remaining[@]} -eq 0 ]] && break
    done

    FAILED_BY_DEP=("${failed_ids[@]+"${failed_ids[@]}"}")
}

WAVE_COUNT=0
FAILED_BY_DEP=()
build_waves

log "Execution plan: $WAVE_COUNT wave(s)"
for ((w=0; w<WAVE_COUNT; w++)); do
    eval "wave_ids=(\"\${WAVE_${w}[@]}\")"
    log_color "  Wave $((w+1)): ${wave_ids[*]}" "$CYAN"
done

if [[ ${#FAILED_BY_DEP[@]} -gt 0 ]]; then
    log_color "Skipped (dependency issues): ${FAILED_BY_DEP[*]}" "$YELLOW"
fi

# --- Step 3: Build prompt for a feature ---

build_prompt() {
    local fid="$1"
    local feature_json
    feature_json=$(jq --arg id "$fid" '.features[] | select(.id == $id)' "$FEATURE_LIST")

    local name description priority steps decisions depends
    name=$(echo "$feature_json" | jq -r '.name')
    description=$(echo "$feature_json" | jq -r '.description')
    priority=$(echo "$feature_json" | jq -r '.priority // "Must"')

    # Build steps
    local step_count
    step_count=$(echo "$feature_json" | jq '.steps // [] | length')
    if [[ "$step_count" -gt 0 ]]; then
        steps=$(echo "$feature_json" | jq -r '.steps[] | . ' | awk '{print NR". "$0}')
    else
        steps="(no explicit steps -- implement based on description)"
    fi

    # Build decisions
    local has_decisions
    has_decisions=$(echo "$feature_json" | jq 'has("decisions") and (.decisions | length > 0)')
    if [[ "$has_decisions" == "true" ]]; then
        decisions=$(echo "$feature_json" | jq -r '.decisions | to_entries[] | "- **\(.key)**: \(.value)"')
    else
        decisions="(none -- use autonomous judgment)"
    fi

    # Build depends
    local dep_list
    dep_list=$(echo "$feature_json" | jq -r '.depends_on // [] | .[]' 2>/dev/null || true)
    if [[ -n "$dep_list" ]]; then
        depends=""
        while IFS= read -r dep; do
            local dep_name
            dep_name=$(jq -r --arg id "$dep" '.features[] | select(.id == $id) | .name // "unknown"' "$FEATURE_LIST")
            depends="${depends}${dep} (${dep_name}) -- completed\n"
        done <<< "$dep_list"
    else
        depends="(none)"
    fi

    local today
    today=$(date +%Y-%m-%d)

    # Replace placeholders
    local prompt="$TEMPLATE"
    prompt="${prompt//\{\{CLAUDE_MD\}\}/$CLAUDE_MD}"
    prompt="${prompt//\{\{ARCHITECTURE_MD\}\}/$ARCH_MD}"
    prompt="${prompt//\{\{LESSONS_LEARNED\}\}/$LESSONS}"
    prompt="${prompt//\{\{INSTINCTS\}\}/$INSTINCTS}"
    prompt="${prompt//\{\{FEATURE_ID\}\}/$fid}"
    prompt="${prompt//\{\{FEATURE_NAME\}\}/$name}"
    prompt="${prompt//\{\{FEATURE_DESCRIPTION\}\}/$description}"
    prompt="${prompt//\{\{FEATURE_PRIORITY\}\}/$priority}"
    prompt="${prompt//\{\{FEATURE_STEPS\}\}/$steps}"
    prompt="${prompt//\{\{FEATURE_DECISIONS\}\}/$decisions}"
    prompt="${prompt//\{\{FEATURE_DEPENDS\}\}/$depends}"
    prompt="${prompt//\{\{TODAY\}\}/$today}"

    echo "$prompt"
}

# --- Step 4: Execute features wave by wave ---

PASSED=()
FAILED=()
SKIPPED=("${FAILED_BY_DEP[@]+"${FAILED_BY_DEP[@]}"}")
BUILT_COUNT=0

run_feature() {
    local fid="$1"
    local name
    name=$(jq -r --arg id "$fid" '.features[] | select(.id == $id) | .name' "$FEATURE_LIST")
    BUILT_COUNT=$((BUILT_COUNT + 1))

    log_color "Building $fid - $name [$BUILT_COUNT]..." "$YELLOW"

    local prompt
    prompt=$(build_prompt "$fid")

    if [[ "$DRY_RUN" == "true" ]]; then
        local dry_dir="$PROJECT/.claude"
        mkdir -p "$dry_dir"
        echo "$prompt" > "$dry_dir/turbo-dry-run-${fid}.md"
        log_color "  [DRY-RUN] Prompt saved to: $dry_dir/turbo-dry-run-${fid}.md" "$YELLOW"
        PASSED+=("$fid")
        return 0
    fi

    local tmp_file
    tmp_file=$(mktemp)
    echo "$prompt" > "$tmp_file"
    local out_file="${tmp_file}.out"

    local timeout_seconds=$((TIMEOUT_MINUTES * 60))

    if timeout "$timeout_seconds" claude -p "$(cat "$tmp_file")" \
        --model "$MODEL" \
        --dangerously-skip-permissions \
        --allowedTools "Bash,Edit,Read,Write,Glob,Grep" \
        > "$out_file" 2>/dev/null; then

        # Check if feature passes
        local passes
        passes=$(jq -r --arg id "$fid" '.features[] | select(.id == $id) | .passes' "$FEATURE_LIST")
        if [[ "$passes" == "true" ]]; then
            log_color "  PASSED" "$GREEN"
            PASSED+=("$fid")
        else
            local fail_reason
            fail_reason=$(grep -oP 'TURBO_RESULT:FAILED\s*[-—]\s*\K.+' "$out_file" 2>/dev/null || echo "passes not set to true")
            log_color "  FAILED: $fail_reason" "$RED"
            FAILED+=("$fid ($fail_reason)")
        fi
    else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log_color "  TIMEOUT after ${TIMEOUT_MINUTES} min" "$RED"
            FAILED+=("$fid (timeout)")
        else
            log_color "  ERROR: claude exited with code $exit_code" "$RED"
            FAILED+=("$fid (exit code $exit_code)")
        fi
    fi

    rm -f "$tmp_file" "$out_file" "${tmp_file}.err" 2>/dev/null || true
}

for ((w=0; w<WAVE_COUNT; w++)); do
    [[ $BUILT_COUNT -ge $COUNT ]] && break

    eval "wave_ids=(\"\${WAVE_${w}[@]}\")"
    local_wave_ids=("${wave_ids[@]}")

    echo ""
    log_color "=== Wave $((w+1)): ${local_wave_ids[*]} ===" "$WHITE"

    if [[ $PARALLEL -le 1 || ${#local_wave_ids[@]} -le 1 ]]; then
        # Sequential
        for fid in "${local_wave_ids[@]}"; do
            [[ $BUILT_COUNT -ge $COUNT ]] && break
            run_feature "$fid"
        done
    else
        # Parallel
        local pids=()
        local pid_map=()
        local running=0

        for fid in "${local_wave_ids[@]}"; do
            [[ $BUILT_COUNT -ge $COUNT ]] && break

            # Throttle
            while [[ $running -ge $PARALLEL ]]; do
                wait -n 2>/dev/null || true
                running=$((running - 1))
            done

            run_feature "$fid" &
            pids+=($!)
            pid_map+=("$fid")
            running=$((running + 1))
        done

        # Wait for all in wave
        for pid in "${pids[@]}"; do
            wait "$pid" 2>/dev/null || true
        done
    fi

    # Refresh Architecture.md between waves
    ARCH_MD=$(read_file_or_empty "$PROJECT/docs/Architecture.md")
    if [[ "$ARCH_MD" == "(not found)" ]]; then
        ARCH_MD=$(read_file_or_empty "$PROJECT/Architecture.md")
    fi
done

# --- Step 5: Final Report ---

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
ELAPSED_FMT=$(printf '%02d:%02d:%02d' $((ELAPSED/3600)) $((ELAPSED%3600/60)) $((ELAPSED%60)))

echo ""
echo -e "${WHITE}===========================================${NC}"
echo -e "${WHITE} TURBO PIPELINE - FINAL REPORT${NC}"
echo -e "${WHITE}===========================================${NC}"
echo ""
echo -e "  Passed:  ${GREEN}${#PASSED[@]}${NC}"
echo -e "  Failed:  $(if [[ ${#FAILED[@]} -gt 0 ]]; then echo "${RED}${#FAILED[@]}${NC}"; else echo "${GREEN}0${NC}"; fi)"
echo -e "  Skipped: $(if [[ ${#SKIPPED[@]} -gt 0 ]]; then echo "${YELLOW}${#SKIPPED[@]}${NC}"; else echo "${GREEN}0${NC}"; fi)"
echo -e "  Elapsed: ${CYAN}${ELAPSED_FMT}${NC}"
echo ""

if [[ ${#PASSED[@]} -gt 0 ]]; then
    echo -e "  ${GREEN}[PASS] ${PASSED[*]}${NC}"
fi
if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo -e "  ${RED}[FAIL] ${FAILED[*]}${NC}"
fi
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo -e "  ${YELLOW}[SKIP] ${SKIPPED[*]}${NC}"
fi

# --- Step 6: Decision Review ---

DECISIONS_LOG="$PROJECT/.claude/decisions.log"
if [[ -f "$DECISIONS_LOG" ]]; then
    warnings=$(grep "WARNING" "$DECISIONS_LOG" 2>/dev/null || true)
    if [[ -n "$warnings" ]]; then
        warn_count=$(echo "$warnings" | wc -l)
        echo ""
        echo -e "  ${YELLOW}[!] Decisions requiring review ($warn_count):${NC}"
        echo "$warnings" | while IFS= read -r line; do
            echo -e "    ${YELLOW}${line}${NC}"
        done
    fi
fi

echo ""
echo -e "${WHITE}===========================================${NC}"
