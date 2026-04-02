#!/bin/bash
# test_init.sh - Tests for init.sh
# Run: bash skills/init/test_init.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/init.sh"
TEST_DIR="$(mktemp -d)"
PASS=0
FAIL=0

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

setup_test_env() {
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"/{skills/init,skills/translate,available/ja/smart-commit,available/en/smart-commit,available/es/smart-commit}

  # Dummy skills in available/
  echo "---" > "$TEST_DIR/available/ja/smart-commit/SKILL.md"
  echo "name: smart-commit" >> "$TEST_DIR/available/ja/smart-commit/SKILL.md"
  echo "---" >> "$TEST_DIR/available/ja/smart-commit/SKILL.md"

  echo "---" > "$TEST_DIR/available/en/smart-commit/SKILL.md"
  echo "name: smart-commit" >> "$TEST_DIR/available/en/smart-commit/SKILL.md"
  echo "---" >> "$TEST_DIR/available/en/smart-commit/SKILL.md"

  echo "---" > "$TEST_DIR/available/es/smart-commit/SKILL.md"
  echo "name: smart-commit" >> "$TEST_DIR/available/es/smart-commit/SKILL.md"
  echo "---" >> "$TEST_DIR/available/es/smart-commit/SKILL.md"

  # Existing protected skills
  echo "init placeholder" > "$TEST_DIR/skills/init/SKILL.md"
  echo "translate placeholder" > "$TEST_DIR/skills/translate/SKILL.md"
}

assert_eq() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $description"
    ((PASS++))
  else
    echo "  FAIL: $description"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    ((FAIL++))
  fi
}

assert_file_exists() {
  local description="$1"
  local path="$2"
  if [ -f "$path" ]; then
    echo "  PASS: $description"
    ((PASS++))
  else
    echo "  FAIL: $description (file not found: $path)"
    ((FAIL++))
  fi
}

assert_file_not_exists() {
  local description="$1"
  local path="$2"
  if [ ! -f "$path" ]; then
    echo "  PASS: $description"
    ((PASS++))
  else
    echo "  FAIL: $description (file should not exist: $path)"
    ((FAIL++))
  fi
}

assert_contains() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if echo "$actual" | grep -q "$expected"; then
    echo "  PASS: $description"
    ((PASS++))
  else
    echo "  FAIL: $description"
    echo "    expected to contain: $expected"
    echo "    actual: $actual"
    ((FAIL++))
  fi
}

assert_exit_code() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $description"
    ((PASS++))
  else
    echo "  FAIL: $description"
    echo "    expected exit code: $expected"
    echo "    actual exit code:   $actual"
    ((FAIL++))
  fi
}

# ============================================================
echo "=== Test 1: Select ja → available/ja/ skills copied to skills/ ==="
setup_test_env
output=$(echo "1" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1) || true
assert_file_exists "smart-commit/SKILL.md exists in skills/" "$TEST_DIR/skills/smart-commit/SKILL.md"

# ============================================================
echo "=== Test 2: Select en → available/en/ skills copied to skills/ ==="
setup_test_env
output=$(echo "2" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1) || true
assert_file_exists "smart-commit/SKILL.md exists in skills/" "$TEST_DIR/skills/smart-commit/SKILL.md"

# ============================================================
echo "=== Test 3: Select other → shows translate skill guidance ==="
setup_test_env
output=$(echo "4" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1) || true
assert_contains "output mentions translate" "translate" "$output"
assert_file_not_exists "no skills copied to skills/" "$TEST_DIR/skills/smart-commit/SKILL.md"

# ============================================================
echo "=== Test 4: init/ and translate/ are overwritten with language versions ==="
setup_test_env
mkdir -p "$TEST_DIR/available/ja/init" "$TEST_DIR/available/ja/translate"
echo "init ja version" > "$TEST_DIR/available/ja/init/SKILL.md"
echo "translate ja version" > "$TEST_DIR/available/ja/translate/SKILL.md"
output=$(echo "1" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1) || true
init_after=$(cat "$TEST_DIR/skills/init/SKILL.md")
translate_after=$(cat "$TEST_DIR/skills/translate/SKILL.md")
assert_eq "init/SKILL.md overwritten with ja version" "init ja version" "$init_after"
assert_eq "translate/SKILL.md overwritten with ja version" "translate ja version" "$translate_after"

# ============================================================
echo "=== Test 5: Invalid input → error ==="
setup_test_env
output=$(echo "5" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1)
exit_code=$?
assert_exit_code "exit code is non-zero" "1" "$exit_code"

setup_test_env
output=$(echo "abc" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1)
exit_code=$?
assert_exit_code "exit code is non-zero for abc" "1" "$exit_code"

# ============================================================
echo "=== Test 6: Empty available/{lang}/ → warning message ==="
setup_test_env
rm -rf "$TEST_DIR/available/ja/smart-commit"
output=$(echo "1" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1) || true
assert_contains "output contains warning" "no skills" "$output"

# ============================================================
echo "=== Test 7: optional/ skills are not copied ==="
setup_test_env
mkdir -p "$TEST_DIR/available/ja/optional/x-draft"
echo "---" > "$TEST_DIR/available/ja/optional/x-draft/SKILL.md"
echo "name: x-draft" >> "$TEST_DIR/available/ja/optional/x-draft/SKILL.md"
echo "---" >> "$TEST_DIR/available/ja/optional/x-draft/SKILL.md"
output=$(echo "1" | bash "$INIT_SCRIPT" "$TEST_DIR" 2>&1) || true
assert_file_not_exists "optional/x-draft not copied to skills/" "$TEST_DIR/skills/x-draft/SKILL.md"
assert_file_not_exists "optional dir not copied to skills/" "$TEST_DIR/skills/optional/SKILL.md"
assert_file_exists "non-optional skill still copied" "$TEST_DIR/skills/smart-commit/SKILL.md"

# ============================================================
echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
