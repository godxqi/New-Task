#!/usr/bin/env bash
# validate.sh <task-root>
#
# 机械校验 new-task 的产物（粗粒度，不替代人工审查）：
#   1. .planning/ 与 .active_plan 存在；每个 plan 有 task_plan.md
#   2. 标记 complete 的阶段，必需产物齐全
#   3. ID 编号连续（REQ / NFR / IF / DM / DS / WI / TC / RV / ADR）
#   4. 粗粒度引用：WI 所在文件有 DS；TC 所在文件有 DS；RV 所在文件有 WI；
#      IF 所在文件有 REQ；编号 ADR 在某个 task_plan.md 有索引
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

# 1. active plan
ACTIVE="$(cat "$PLAN/.active_plan" 2>/dev/null || true)"
if [ -n "$ACTIVE" ]; then ok "active plan: $ACTIVE"; else bad "缺少 .planning/.active_plan"; fi

# 2. plan dirs
for d in "$PLAN"/plan*_*; do
  [ -d "$d" ] || continue
  if [ -f "$d/task_plan.md" ]; then ok "$(basename "$d")/task_plan.md"; else bad "$(basename "$d") 缺 task_plan.md"; fi
  [ -d "$d/output" ] || note "$(basename "$d") 还没有 output/"
done

# 3. required outputs for complete stages
check_outputs() {
  local dir="$1"; shift
  [ -f "$dir/task_plan.md" ] || return 0
  grep -q '\*\*状态：\*\* *complete' "$dir/task_plan.md" 2>/dev/null || return 0
  local f
  for f in "$@"; do
    if [ -f "$dir/output/$f" ]; then ok "$(basename "$dir")/output/$f"; else bad "$(basename "$dir") 缺 output/$f"; fi
  done
}
check_outputs "$PLAN/plan0_RequirementsConfirm" requirements.md
check_outputs "$PLAN/plan1_ArchitectureDesign" 01-estimation.md 02-quality.md 03-interfaces.md 04-data-model.md 05-architecture.md 06-bottlenecks.md
check_outputs "$PLAN/plan2_DetailedDesign" work-items.md test-points.md
check_outputs "$PLAN/plan5_Review" reconciliation.md
check_outputs "$PLAN/plan6_Delivery" deliverables.md

# 4. ID continuity
check_contiguous() {
  local p="$1"
  local nums max n gap=0
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
for p in REQ NFR IF DM DS WI TC RV; do check_contiguous "$p"; done

# ADR: 4 位编号，连续性单独查
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

# 5. coarse reference checks
coarse_ref() {
  local src="$1" needle="$2" evidence="$3" label="$4"
  local f
  for f in $src; do
    [ -f "$f" ] || continue
    if grep -qE "\\b${needle}-[0-9]+" "$f" 2>/dev/null && ! grep -qE "\\b${evidence}-[0-9]+" "$f" 2>/dev/null; then
      bad "$label：$f 有 $needle 但没有 $evidence"
    fi
  done
}
coarse_ref "$PLAN/plan2_DetailedDesign/output/work-items.md" WI DS "实施链"
coarse_ref "$PLAN/plan4_Test/output/*.md" TC DS "验证链"
coarse_ref "$PLAN/plan3_Coding/task_plan.md" RV WI "审查链"
coarse_ref "$PLAN/plan1_ArchitectureDesign/output/*.md" IF REQ "设计链"

# 6. ADR index
for f in "$PLAN"/plan*/task_plan.md; do
  [ -f "$f" ] || continue
  for id in $(grep -rhoE 'ADR-[0-9]{4}' "$f" 2>/dev/null | sort -u); do
    ok "$(basename "$(dirname "$f")") 索引 $id"
  done
done

if [ "$fail" -eq 0 ]; then
  echo "== 通过 =="
  exit 0
else
  echo "== 有问题，见上面 ✗ =="
  exit 1
fi
