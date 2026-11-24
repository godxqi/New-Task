#!/usr/bin/env python3
"""把 new-task 的 test-cases.md（markmap）抽成 test-cases.schema.yaml。

零第三方依赖：YAML 用 JSON 兼容的双引号字符串手工生成。
单轨真相仍是 markmap；schema 每次由本脚本再生，不手工维护。

用例格式（见 references/S5-test-design.md）：

    - **TestCase-1 登录失败抛 AuthError** [P0]
      - 验证: TestPoint-3（DetailedDesign-2）
      - 层: contract
      - 前置条件: ...
      - 操作步骤: 1. ... 2. ...
      - 预期结果: ...

用法：
    python extract_case_schema.py test-cases.md test-cases.schema.yaml
退出码：0 = 写出；1 = 未识别到用例或参数错误。
"""
import json
import re
import sys
from datetime import date
from pathlib import Path

CASE_RE = re.compile(r"^\s*[-*]\s+(?:\*\*)?\s*(TestCase-\d+)\s+(.+?)(?:\*\*)?\s*(?:\[(P[0-2])\])?\s*$")
FIELD_RE = re.compile(r"^\s+[-*]\s+([^:：]{1,12})[:：]\s*(.*)$")
STEP_SPLIT_RE = re.compile(r"(?:^|\s)\d+[.、]\s*")
ID_TOKEN_RE = re.compile(r"TestPoint-\d+|DetailedDesign-\d+|Requirement-\d+|Interface-\d+")

FIELD_MAP = {
    "验证": "verification",
    "层": "layer",
    "前置条件": "preconditions",
    "操作步骤": "steps",
    "预期结果": "expected",
    "验证方式": "verify_by",
}


def as_list(text):
    parts = [p.strip() for p in STEP_SPLIT_RE.split(text) if p.strip()]
    return parts or ([text.strip()] if text.strip() else [])


def parse(path):
    cases = []
    cur = None
    for line in Path(path).read_text(encoding="utf-8-sig").splitlines():
        m = CASE_RE.match(line)
        if m:
            cur = {
                "id": m.group(1),
                "title": m.group(2).strip(),
                "priority": m.group(3) or "P1",
                "raw": {},
            }
            cases.append(cur)
            continue
        if cur is None:
            continue
        f = FIELD_RE.match(line)
        if not f:
            continue
        name = FIELD_MAP.get(f.group(1).strip())
        if name:
            cur["raw"][name] = f.group(2).strip()
    return cases


def emit(cases, source, out_path):
    lines = ["meta:", '  source_markmap: "%s"' % source,
             '  extracted_at: "%s"' % date.today().isoformat(), "cases:"]
    for c in cases:
        raw = c["raw"]
        verification = raw.get("verification", "")
        ids = ID_TOKEN_RE.findall(verification)
        test_point = next((i for i in ids if i.startswith("TestPoint-")), "")
        design_refs = [i for i in ids if not i.startswith("TestPoint-")]
        lines.append('  - id: "%s"' % c["id"])
        lines.append('    title: %s' % json.dumps(c["title"], ensure_ascii=False))
        lines.append('    priority: "%s"' % c["priority"])
        lines.append('    layer: "%s"' % (raw.get("layer") or ""))
        lines.append('    test_point: "%s"' % test_point)
        lines.append("    design_refs: [%s]" % ", ".join('"%s"' % i for i in design_refs))
        for key, field in (("preconditions", "前置条件"), ("steps", "操作步骤"),
                           ("expected", "预期结果")):
            vals = as_list(raw.get(key, ""))
            lines.append("    %s:" % key)
            for v in vals:
                lines.append("      - %s" % json.dumps(v, ensure_ascii=False))
            if not vals:
                lines[-1] = "    %s: []" % key
        if raw.get("verify_by"):
            lines.append('    verify_by: %s' % json.dumps(raw["verify_by"], ensure_ascii=False))
    Path(out_path).write_text("\n".join(lines) + "\n", encoding="utf-8")
    return len(cases)


def main(argv):
    if len(argv) != 3:
        print("用法: python extract_case_schema.py <test-cases.md> <test-cases.schema.yaml>", file=sys.stderr)
        return 1
    src, dst = argv[1], argv[2]
    cases = parse(src)
    if not cases:
        print("未识别到任何用例（编号须为 TestCase-{序号}）", file=sys.stderr)
        return 1
    n = emit(cases, Path(src).name, dst)
    print("schema: %d 条用例 -> %s" % (n, dst))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
