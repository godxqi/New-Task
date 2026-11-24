#!/usr/bin/env bash
# validate.sh <task-root>
#
# 机械校验 new-task 的产物。目标是能对「三条链无断点」负责：
#   1. .planning/ 与 .active_plan 存在；七个 plan 目录都有 task_plan.md 与 output/
#   2. 已完成的阶段，必需产物齐全（含 nfr.md / GLOSSARY.md）
#   3. ID 编号连续（Requirement / NonFunctionalRequirement / Interface / DataModel / DetailedDesign / TestPoint / TestCase / CodeUnit / Review / ArchDecisionRecord）
#   4. 行级链路：
#      - interfaces.md 每个 Interface 行有 Requirement 或 N/A
#      - detailed-design.md 每个 DetailedDesign 行有 Interface 或 DataModel
#      - work-items.md 每个 CodeUnit 行有 DetailedDesign
#      - test-points.md 每个 TestPoint 行有 DetailedDesign 或 Requirement
#      - test-cases.md 每个 TestCase 行有 TestPoint
#      - S4 计划里每个 CodeUnit 有 Review
#      - 每个 DetailedDesign 有 TP；每个 TestPoint 有 TestCase 或有缺口出口；TestCase 引用的 TestPoint 必须存在
#   5. 每个 ArchDecisionRecord 文件都在某个 task_plan.md 里有索引行
#   6. S5 结果闭环：
#      - 每个 TestCase 在 test-results.md 有对应行
#      - fail 行有出口（Risk-n / 修复记录）；not-run 行写明原因
#      - test-cases.md 过 case_lint.py（退出码 1 = 失败）
#      - test-cases.md 与 test-cases.schema.yaml 的用例数一致
#
# 退出码：0 = 通过；1 = 有问题。
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
PLAN="$ROOT/.planning"
fail=0
ok()  { printf '  ✓ %s\n' "$*"; }
bad() { printf '  ✗ %s\n' "$*"; fail=1; }
note(){ printf '  · %s\n' "$*"; }

[ -d "$PLAN" ] || { echo "找不到 $PLAN"; exit 1; }
echo "== new-task validate: $ROOT =="

ACTIVE="$(cat "$PLAN/.active_plan" 2>/dev/null || true)"
if [ -n "$ACTIVE" ]; then ok "active plan: $ACTIVE"; else bad "缺少 .planning/.active_plan"; fi

PLANS="plan1_RequirementsConfirm plan2_ArchitectureDesign plan3_DetailedDesign plan4_Coding plan5_Test plan6_Review plan7_Delivery"
for p in $PLANS; do
  d="$PLAN/$p"
  if [ ! -d "$d" ]; then bad "缺计划目录 $p"; continue; fi
  [ -f "$d/task_plan.md" ] && ok "$p/task_plan.md" || bad "$p 缺 task_plan.md"
  [ -d "$d/output" ] && ok "$p/output/" || bad "$p 缺 output/"
done

stage_complete() {
  local f="$1/task_plan.md"
  [ -f "$f" ] || return 1
  grep -q '\*\*状态：\*\* *complete' "$f" || return 1
  ! grep -qE '\*\*状态：\*\* *(pending|in_progress)' "$f"
}

check_outputs() {
  local p="$1"; shift
  local d="$PLAN/$p" f
  stage_complete "$d" || return 0
  for f in "$@"; do
    [ -f "$d/output/$f" ] && ok "$p/output/$f" || bad "$p 缺 output/$f"
  done
}
check_outputs plan1_RequirementsConfirm requirements.md nfr.md estimation.md GLOSSARY.md
check_outputs plan2_ArchitectureDesign quality-attributes.md interfaces.md data-model.md architecture.md bottlenecks.md
check_outputs plan3_DetailedDesign detailed-design.md work-items.md test-points.md
check_outputs plan5_Test test-strategy.md test-cases.md test-cases.schema.yaml test-results.md coverage-gaps.md
check_outputs plan6_Review reconciliation.md
check_outputs plan7_Delivery deliverables.md

check_contiguous() {
  local p="$1" nums max n gap=0
  nums="$(find "$PLAN" -type f -name '*.md' -exec cat {} + 2>/dev/null \
    | sed -E 's/[A-Za-z]+-[0-9]+\.\.[A-Za-z]+-?[0-9]*//g; s/[A-Za-z]+-[0-9]+\.\.n//g' \
    | grep -oE "\\b${p}-[0-9]+" | sed 's/.*-//' | sort -n | uniq)"
  if [ -z "$nums" ]; then note "$p: 未使用"; return; fi
  max="$(printf '%s\n' "$nums" | tail -1)"
  n=1
  while [ "$n" -le "$max" ]; do
    if ! printf '%s\n' "$nums" | grep -qx "$n"; then bad "$p 编号不连续：缺 $p-$n"; gap=1; fi
    n=$((n + 1))
  done
  [ "$gap" -eq 0 ] && ok "$p-1..$p-$max 连续"
}
for p in Requirement NonFunctionalRequirement Interface DataModel DetailedDesign TestPoint TestCase CodeUnit Review; do check_contiguous "$p"; done

adr_nums="$(grep -rhoE 'ArchDecisionRecord-[0-9]{4}' "$PLAN" 2>/dev/null | sed 's/.*-//' | sort -n | uniq)"
if [ -n "$adr_nums" ]; then
  max="$(printf '%s\n' "$adr_nums" | tail -1)"
  n=1
  gap=0
  while [ "$n" -le "$max" ]; do
    if ! printf '%s\n' "$adr_nums" | grep -qx "$(printf '%04d' "$n")"; then bad "ArchDecisionRecord 编号不连续：缺 ArchDecisionRecord-$(printf '%04d' "$n")"; gap=1; fi
    n=$((n + 1))
  done
  [ "$gap" -eq 0 ] && ok "ArchDecisionRecord 编号连续（到 ArchDecisionRecord-$(printf '%04d' "$max")）"
else
  note "ArchDecisionRecord: 未使用"
fi

# ---- 行级链路 ----
row_check() {
  local file="$1" idpat="$2" evpat="$3" label="$4"
  [ -f "$file" ] || return 0
  local out
  out="$(awk -v idpat="$idpat" -v evpat="$evpat" '
    ($0 ~ /^\|/ || $0 ~ /^[[:space:]]*[-*] /) && $0 ~ idpat && $0 !~ evpat { print }
  ' "$file")"
  if [ -n "$out" ]; then bad "$label：$file"; printf '%s\n' "$out" | sed 's/^/    /'; fi
}
row_check "$PLAN/plan2_ArchitectureDesign/output/interfaces.md" "Interface-[0-9]+" "(Requirement-[0-9]+|N/A)" "设计链：Interface 行缺 Requirement/N/A"
row_check "$PLAN/plan3_DetailedDesign/output/detailed-design.md" "DetailedDesign-[0-9]+" "(Interface-[0-9]+|DataModel-[0-9]+|Requirement-[0-9]+)" "设计链：DetailedDesign 行缺 Interface/DataModel/Requirement"
row_check "$PLAN/plan3_DetailedDesign/output/work-items.md" "CodeUnit-[0-9]+" "DetailedDesign-[0-9]+" "实施链：CodeUnit 行缺 DetailedDesign"
row_check "$PLAN/plan3_DetailedDesign/output/test-points.md" "TestPoint-[0-9]+" "(DetailedDesign-[0-9]+|Requirement-[0-9]+)" "验证链：TestPoint 行缺 DetailedDesign/Requirement"

# TestCase 的 TestPoint 在下一行「验证:」字段里，按用例块检查
case_link_check() {
  local file="$1"
  [ -f "$file" ] || return 0
  local out
  out="$(awk '
    function flush(){ if (id!="" && !ok) print id }
    /^[[:space:]]*[-*][[:space:]]+(\*\*)?[[:space:]]*TestCase-[0-9]+/ { flush(); id=$0; ok=0; next }
    /验证[[:space:]]*[:：]/ && /TestPoint-[0-9]+/ { ok=1 }
    END { flush() }
  ' "$file")"
  if [ -n "$out" ]; then bad "验证链：这些 TestCase 没有指向 TestPoint："; printf '%s\n' "$out" | sed 's/^/    /'; else ok "每个 TestCase 指向 TestPoint"; fi
}
case_link_check "$PLAN/plan5_Test/output/test-cases.md"

# 每个 CodeUnit 有 Review（S4 计划）
S4="$PLAN/plan4_Coding/task_plan.md"
if [ -f "$S4" ]; then
  all_wi="$(grep -oE 'CodeUnit-[0-9]+' "$S4" | sort -u)"
  if [ -n "$all_wi" ]; then
    rv_wi="$(grep -E 'Review-[0-9]+' "$S4" | grep -oE 'CodeUnit-[0-9]+' | sort -u)"
    missing="$(comm -23 <(printf '%s\n' "$all_wi") <(printf '%s\n' "$rv_wi"))"
    if [ -n "$missing" ]; then bad "实施链：这些 CodeUnit 没有 Review：$missing"; else ok "每个 CodeUnit 有 Review"; fi
  fi
fi

# 每个 DetailedDesign 有 TestPoint
DSF="$PLAN/plan3_DetailedDesign/output/detailed-design.md"
TPF="$PLAN/plan3_DetailedDesign/output/test-points.md"
TCF="$PLAN/plan5_Test/output/test-cases.md"
GAP="$PLAN/plan5_Test/output/coverage-gaps.md"
if [ -f "$DSF" ] && [ -f "$TPF" ]; then
  all_ds="$(grep -oE 'DetailedDesign-[0-9]+' "$DSF" | sort -u)"
  tp_ds="$(grep -oE 'DetailedDesign-[0-9]+' "$TPF" | sort -u)"
  missing="$(comm -23 <(printf '%s\n' "$all_ds") <(printf '%s\n' "$tp_ds"))"
  if [ -n "$missing" ]; then bad "验证链：这些 DetailedDesign 没有 TestPoint：$missing"; else ok "每个 DetailedDesign 有 TestPoint"; fi
fi

# 每个 TestPoint 有 TestCase 或有缺口出口；TestCase 引用的 TestPoint 必须存在
if [ -f "$TPF" ]; then
  all_tp="$(grep -oE 'TestPoint-[0-9]+' "$TPF" | sort -u)"
  tc_tp=""
  [ -f "$TCF" ] && tc_tp="$(grep -oE 'TestPoint-[0-9]+' "$TCF" | sort -u)"
  gap_tp=""
  [ -f "$GAP" ] && gap_tp="$(grep -oE 'TestPoint-[0-9]+' "$GAP" | sort -u)"
  covered="$(printf '%s\n%s\n' "$tc_tp" "$gap_tp" | grep -E '^TestPoint-[0-9]+$' | sort -u)"
  missing="$(comm -23 <(printf '%s\n' "$all_tp") <(printf '%s\n' "$covered"))"
  if [ -n "$missing" ]; then bad "验证链：这些 TestPoint 既没有 TestCase 也没有缺口出口：$missing"; else ok "每个 TestPoint 有 TestCase 或缺口出口"; fi
  if [ -n "$tc_tp" ]; then
    undefined="$(comm -13 <(printf '%s\n' "$all_tp") <(printf '%s\n' "$tc_tp"))"
    if [ -n "$undefined" ]; then bad "验证链：TestCase 引用了不存在的 TestPoint：$undefined"; else ok "TestCase 引用的 TestPoint 都存在"; fi
  fi
fi

# ---- S5 结果闭环 ----
TRF="$PLAN/plan5_Test/output/test-results.md"
SCHEMA="$PLAN/plan5_Test/output/test-cases.schema.yaml"
if [ -f "$TCF" ]; then
  all_tc="$(grep -oE 'TestCase-[0-9]+' "$TCF" | sort -u)"
fi

# 每个 TestCase 有结果行
if [ -n "${all_tc:-}" ] && [ -f "$TRF" ]; then
  res_tc="$(grep -oE 'TestCase-[0-9]+' "$TRF" | sort -u)"
  missing="$(comm -23 <(printf '%s\n' "$all_tc") <(printf '%s\n' "$res_tc"))"
  if [ -n "$missing" ]; then bad "结果闭环：这些 TestCase 在 test-results.md 没有结果行：$missing"; else ok "每个 TestCase 有结果行"; fi
fi

# fail 必须有出口；not-run 必须写原因
if [ -f "$TRF" ]; then
  no_exit="$(grep -E 'TestCase-[0-9]+' "$TRF" | grep -E 'fail' | grep -vE 'Risk-[0-9]+|修复|已修|fixed|出口')"
  if [ -n "$no_exit" ]; then bad "结果闭环：这些 fail 行没有出口（Risk-n / 修复记录）："; printf '%s\n' "$no_exit" | sed 's/^/    /'; fi
  no_reason="$(grep -E 'TestCase-[0-9]+' "$TRF" | grep -E 'not-run' | grep -vE '原因')"
  if [ -n "$no_reason" ]; then bad "结果闭环：这些 not-run 行没写原因："; printf '%s\n' "$no_reason" | sed 's/^/    /'; fi
  [ -z "$no_exit$no_reason" ] && ok "fail/not-run 有出口或原因"
fi

# lint（markmap 用例红线）
LINT="$SCRIPT_DIR/case_lint.py"
if [ -f "$TCF" ] && [ -f "$LINT" ]; then
  PY="$(command -v python || command -v python3 || true)"
  if [ -n "$PY" ]; then
    if out="$("$PY" "$LINT" "$TCF" 2>&1)"; then
      ok "case_lint 通过"
    else
      bad "case_lint 未通过："
      printf '%s\n' "$out" | grep -E '^(E|W)[0-9]' | sed 's/^/    /'
    fi
  else
    note "未找到 python，跳过 case_lint"
  fi
fi

# 两轨用例数一致
if [ -f "$TCF" ] && [ -f "$SCHEMA" ]; then
  n_md="$(grep -cE '^[[:space:]]*[-*][[:space:]]+(\*\*)?[[:space:]]*TestCase-[0-9]+' "$TCF")"
  n_yaml="$(grep -cE '^[[:space:]]*-[[:space:]]+id:[[:space:]]*"?TestCase-[0-9]+' "$SCHEMA")"
  if [ "$n_md" = "$n_yaml" ]; then ok "两轨用例数一致（$n_md）"; else bad "两轨用例数不一致：test-cases.md $n_md vs schema.yaml $n_yaml"; fi
fi

# ArchDecisionRecord 索引
for adr in "$PLAN"/plan*/output/adr/ArchDecisionRecord-*.md; do
  [ -f "$adr" ] || continue
  id="$(basename "$adr" | grep -oE 'ArchDecisionRecord-[0-9]{4}')"
  if grep -q "$id" "$PLAN"/plan*/task_plan.md 2>/dev/null; then
    ok "$id 有计划索引"
  else
    bad "$id 没有计划索引行"
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "== 通过 =="
  exit 0
else
  echo "== 有问题，见上面 ✗ =="
  exit 1
fi
