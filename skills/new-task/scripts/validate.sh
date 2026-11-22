#!/usr/bin/env bash
# validate.sh <task-root>
#
# 机械校验 new-task 的产物（粗粒度，不替代人工审查）：
#   1. .planning/ 与 .active_plan 存在；七个 plan 目录都有 task_plan.md 与 output/
#   2. 已完成的阶段，必需产物齐全
#   3. ID 编号连续（REQ / NFR / IF / DM / DS / TC / WI / RV / ADR；R 每阶段各自编号）
#   4. 定义的产物文件里，下游 ID 能指回上游：interfaces 有 REQ、work-items 有 DS、
#      test-cases 有 DS、S4 计划有 WI
#   5. 每个 ADR 文件都在某个 task_plan.md 里有索引行
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
  nums="$(grep -rhoE "\\b${p}-[0-9]+" "$PLAN" 2>/dev/null | sed 's/.*-//' | sort -n | uniq)"
  if [ -z "$nums" ]; then note "$p: 未使用"; return; fi
  max="$(printf '%s\n' "$nums" | tail -1)"
  n=1
  while [ "$n" -le "$max" ]; do
    if ! printf '%s\n' "$nums" | grep -qx "$n"; then bad "$p 编号不连续：缺 $p-$n"; gap=1; fi
    n=$((n + 1))
  done
  [ "$gap" -eq 0 ] && ok "$p-1..$p-$max 连续"
}
for p in REQ NFR IF DM DS TC WI RV; do check_contiguous "$p"; done

adr_nums="$(grep -rhoE 'ADR-[0-9]{4}' "$PLAN" 2>/dev/null | sed 's/.*-//' | sort -n | uniq)"
if [ -n "$adr_nums" ]; then
  max="$(printf '%s\n' "$adr_nums" | tail -1)"
  n=1
  gap=0
  while [ "$n" -le "$max" ]; do
    if ! printf '%s\n' "$adr_nums" | grep -qx "$(printf '%04d' "$n")"; then bad "ADR 编号不连续：缺 ADR-$(printf '%04d' "$n")"; gap=1; fi
    n=$((n + 1))
  done
  [ "$gap" -eq 0 ] && ok "ADR 编号连续（到 ADR-$(printf '%04d' "$max")）"
else
  note "ADR: 未使用"
fi

check_file_ref() {
  local file="$1" needle="$2" evidence="$3" label="$4"
  [ -f "$file" ] || return 0
  if grep -qE "\\b${needle}-[0-9]+" "$file" && ! grep -qE "\\b${evidence}-[0-9]+" "$file"; then
    bad "$label：$file 有 $needle 但没有 $evidence"
  fi
}
check_file_ref "$PLAN/plan1_ArchitectureDesign/output/interfaces.md" IF REQ "设计链"
check_file_ref "$PLAN/plan2_DetailedDesign/output/work-items.md" WI DS "实施链"
check_file_ref "$PLAN/plan4_Test/output/test-cases.md" TC DS "验证链"
check_file_ref "$PLAN/plan3_Coding/task_plan.md" RV WI "审查链"

for adr in "$PLAN"/plan*/output/adr/ADR-*.md; do
  [ -f "$adr" ] || continue
  id="$(basename "$adr" | grep -oE 'ADR-[0-9]{4}')"
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
