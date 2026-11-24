#!/usr/bin/env bash
# S5 机械校验的自测：正样例必须过，反样例必须拦。
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL="$(cd "$HERE/.." && pwd)"
PY="$(command -v python || command -v python3 || true)"
fail=0

ok()  { printf '  ✓ %s\n' "$*"; }
bad() { printf '  ✗ %s\n' "$*"; fail=1; }

[ -n "$PY" ] || { echo "需要 python"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

sh "$SKILL/scripts/validate.sh" "$HERE/fixtures/pass" >"$TMP/v_pass" 2>&1 \
  && ok "validate: 合规样例通过" || { bad "validate: 合规样例被拦"; tail -20 "$TMP/v_pass"; }

if sh "$SKILL/scripts/validate.sh" "$HERE/fixtures/fail" >"$TMP/v_fail" 2>&1; then
  bad "validate: 违规样例未被拦"
else
  ok "validate: 违规样例被拦"
fi

"$PY" "$SKILL/scripts/case_lint.py" "$HERE/fixtures/pass/.planning/plan5_Test/output/test-cases.md" >/dev/null 2>&1 \
  && ok "lint: 合规样例通过" || bad "lint: 合规样例被拦"

if "$PY" "$SKILL/scripts/case_lint.py" "$HERE/fixtures/fail/.planning/plan5_Test/output/test-cases.md" >/dev/null 2>&1; then
  bad "lint: 违规样例未被拦"
else
  ok "lint: 违规样例被拦"
fi

OUT="$TMP/test-cases.schema.yaml"
"$PY" "$SKILL/scripts/extract_case_schema.py" \
  "$HERE/fixtures/pass/.planning/plan5_Test/output/test-cases.md" "$OUT" >/dev/null 2>&1 \
  && [ "$(grep -c '^  - id: "TestCase-' "$OUT")" = "2" ] \
  && ok "schema: 抽取 2 条" || bad "schema: 抽取失败"

if [ "$fail" -eq 0 ]; then echo "== 全部通过 =="; else echo "== 有失败 =="; fi
exit "$fail"
