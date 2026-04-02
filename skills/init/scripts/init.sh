#!/bin/bash
# init.sh - Initialize Core Nexus plugin
# Usage: bash init.sh [plugin_root_dir]
#   plugin_root_dir: Root directory of the plugin (default: auto-detect from script location)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="${1:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"

SKILLS_DIR="$PLUGIN_ROOT/skills"
AVAILABLE_DIR="$PLUGIN_ROOT/available"

if [ ! -d "$AVAILABLE_DIR" ]; then
  echo "Error: available/ directory not found: $AVAILABLE_DIR" >&2
  exit 1
fi

# Directories to skip during copy
SKIP_DIRS=("optional")

echo "Select language:"
echo "1) ja - 日本語"
echo "2) en - English"
echo "3) es - Español"
echo "4) other"
printf "> "
read -r choice

case "$choice" in
  1) lang="ja" ;;
  2) lang="en" ;;
  3) lang="es" ;;
  4)
    echo "Use /core-nexus:translate to generate skills in your language."
    exit 0
    ;;
  *)
    echo "Error: Invalid selection '$choice'" >&2
    exit 1
    ;;
esac

lang_dir="$AVAILABLE_DIR/$lang"

if [ ! -d "$lang_dir" ]; then
  echo "Error: Language directory not found: $lang_dir" >&2
  exit 1
fi

# Find skill directories (direct children only, exclude optional/)
skills_found=0
for skill_dir in "$lang_dir"/*/; do
  [ -d "$skill_dir" ] || continue

  skill_name="$(basename "$skill_dir")"

  # Skip directories in SKIP_DIRS
  skip=false
  for skip_dir in "${SKIP_DIRS[@]}"; do
    if [ "$skill_name" = "$skip_dir" ]; then
      skip=true
      break
    fi
  done
  if [ "$skip" = true ]; then
    continue
  fi

  # Copy skill to skills/
  cp -r "$skill_dir" "$SKILLS_DIR/$skill_name"
  skills_found=$((skills_found + 1))
done

if [ "$skills_found" -eq 0 ]; then
  echo "Warning: no skills found in $lang_dir"
  exit 0
fi

echo "Installed $skills_found skill(s) from $lang."
echo "Run /reload-plugins to activate."
