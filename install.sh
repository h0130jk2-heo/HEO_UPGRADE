#!/usr/bin/env bash
# HEO_UPGRADE Framework Installer for macOS / Linux
# Copies skills and rules from this repo into ~/.claude/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_DIR="$REPO_ROOT/framework"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DST="$CLAUDE_DIR/skills"
RULES_DST="$CLAUDE_DIR/rules"
TOOLS_DST="$CLAUDE_DIR/tools"
FORCE="${1:-}"

if [ ! -d "$FRAMEWORK_DIR" ]; then
    echo "ERROR: framework/ directory not found." >&2
    exit 1
fi

echo ""
echo "=== HEO_UPGRADE Framework Installer ==="
echo "Source : $FRAMEWORK_DIR"
echo "Target : $CLAUDE_DIR"
echo ""

mkdir -p "$SKILLS_DST" "$RULES_DST" "$TOOLS_DST"

installed=0
total=0
for skill_dir in "$FRAMEWORK_DIR"/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    total=$((total + 1))
    dst="$SKILLS_DST/$skill_name"
    if [ -d "$dst" ] && [ "$FORCE" != "--force" ]; then
        echo "  SKIP  $skill_name (already exists, use --force to overwrite)"
    else
        cp -r "$skill_dir" "$dst"
        echo "  OK    $skill_name"
        installed=$((installed + 1))
    fi
done

rules_installed=0
rules_total=0
for rule_file in "$FRAMEWORK_DIR"/rules/*.md; do
    rule_name="$(basename "$rule_file")"
    rules_total=$((rules_total + 1))
    dst="$RULES_DST/$rule_name"
    if [ -f "$dst" ] && [ "$FORCE" != "--force" ]; then
        echo "  SKIP  $rule_name (already exists, use --force to overwrite)"
    else
        cp "$rule_file" "$dst"
        echo "  OK    $rule_name"
        rules_installed=$((rules_installed + 1))
    fi
done

tools_installed=0
tools_total=0
if [ -d "$FRAMEWORK_DIR/tools" ]; then
    for tool_file in "$FRAMEWORK_DIR"/tools/*; do
        [ -f "$tool_file" ] || continue
        tool_name="$(basename "$tool_file")"
        tools_total=$((tools_total + 1))
        dst="$TOOLS_DST/$tool_name"
        if [ -f "$dst" ] && [ "$FORCE" != "--force" ]; then
            echo "  SKIP  $tool_name (already exists, use --force to overwrite)"
        else
            cp "$tool_file" "$dst"
            chmod +x "$dst" 2>/dev/null || true
            echo "  OK    $tool_name"
            tools_installed=$((tools_installed + 1))
        fi
    done
fi

echo ""
echo "--- Result ---"
echo "Skills : $installed / $total installed"
echo "Rules  : $rules_installed / $rules_total installed"
echo "Tools  : $tools_installed / $tools_total installed"
echo ""
echo "Done. Restart Claude Code to pick up the new skills."
