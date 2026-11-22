#!/usr/bin/env bash
# validate.sh <task-root>
#
# 机械校验 new-task 的产物。目标是能对「三条链无断点」负责：
#   1. .planning/ 与 .active_plan 存在；七个 plan 目录都有 task_plan.md 与 output/
#   2. 已完成的阶段，必需产物齐全（含 nfr.md / GLOSSARY.md）
#   3. ID 编号连续（Requirement / NonFunctionalRequirement / Interface / DataModel / DetailedDesign / TestPoint / TestCase / CodeUnit / Review / ADR）
#   4. 行级链路：
#      - interfaces.md 每个 Interface 行有 Requirement 或 N/A
#      - detailed-design.md 每个 DetailedDesign 行有 Interface 或 DataModel
#      - work-items.md 每个 CodeUnit 行有 DetailedDesign
#      - test-points.md 每个 TestPoint 行有 DetailedDesign
#      - test-cases.md 每个 TestCase 行有 TestPoint
#      - S4 计划里每个 CodeUnit 有 Review
#      - 每个 DetailedDesign 有 TP；每个 TestPoint 有 TestCase 或有缺口出口；TestCase 引用的 TestPoint 必须存在
#   5. 每个 ArchDecisionRecord 文件都在某个 task_plan.md 里有索引行
#
# 退出码：0 = 通过；1 = 有问题。
set -u

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

PLANS="plan0_RequirementsConfirm plan1_ArchitectureDesign plan2_DetailedDesign plan3_Coding plan4_Test plan5_Review plan6_Delivery"
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
check_outputs plan0_RequirementsConfirm requirements.md nfr.md estimation.md GLOSSARY.md
check_outputs plan1_ArchitectureDesign quality-attributes.md interfaces.md data-model.md architecture.md bottlenecks.md
check_outputs plan2_DetailedDesign detailed-design.md work-items.md test-points.md
check_outputs plan4_Test test-cases.md test-results.md coverage-gaps.md
check_outputs plan5_Review reconciliation.md
check_outputs plan6_Delivery deliverables.md

check_contiguous() {
  local p="$1" nums max n gap=0
  nums="$(grep -rhoE "\\b${p}-[0-9]+(\\.\\.)?" "$PLAN" 2>/dev/null | grep -v '\\.\\.$' | sed 's/.*-//' | sort -n | uniq)"
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
row_check "$PLAN/plan1_ArchitectureDesign/output/interfaces.md" "Interface-[0-9]+" "(Requirement-[0-9]+|N/A)" "设计链：Interface 行缺 Requirement/N/A"
row_check "$PLAN/plan2_DetailedDesign/output/detailed-design.md" "DetailedDesign-[0-9]+" "(Interface-[0-9]+|DataModel-[0-9]+|Requirement-[0-9]+)" "设计链：DetailedDesign 行缺 Interface/DataModel/Requirement"
row_check "$PLAN/plan2_DetailedDesign/output/work-items.md" "CodeUnit-[0-9]+" "DetailedDesign-[0-9]+" "实施链：CodeUnit 行缺 DetailedDesign"
row_check "$PLAN/plan2_DetailedDesign/output/test-points.md" "TestPoint-[0-9]+" "DetailedDesign-[0-9]+" "验证链：TestPoint 行缺 DetailedDesign"
row_check "$PLAN/plan4_Test/output/test-cases.md" "TestCase-[0-9]+" "TestPoint-[0-9]+" "验证链：TestCase 行缺 TestPoint"

# 每个 CodeUnit 有 Review（S4 计划）
S4="$PLAN/plan3_Coding/task_plan.md"
if [ -f "$S4" ]; then
  all_wi="$(grep -oE 'CodeUnit-[0-9]+' "$S4" | sort -u)"
  if [ -n "$all_wi" ]; then
    rv_wi="$(grep -E 'Review-[0-9]+' "$S4" | grep -oE 'CodeUnit-[0-9]+' | sort -u)"
    missing="$(comm -23 <(printf '%s\n' "$all_wi") <(printf '%s\n' "$rv_wi"))"
    if [ -n "$missing" ]; then bad "实施链：这些 CodeUnit 没有 Review：$missing"; else ok "每个 CodeUnit 有 Review"; fi
  fi
fi

# 每个 DetailedDesign 有 TestPoint
DSF="$PLAN/plan2_DetailedDesign/output/detailed-design.md"
TPF="$PLAN/plan2_DetailedDesign/output/test-points.md"
TCF="$PLAN/plan4_Test/output/test-cases.md"
GAP="$PLAN/plan4_Test/output/coverage-gaps.md"
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
