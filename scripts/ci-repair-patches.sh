#!/usr/bin/env bash
# Upstream UniXNU at the pinned ref (82b847c) ships patch files whose "new file"
# hunks lack the "new file mode" line, which makes `git apply` abort packaging
# (e.g. patches/mesa/turnip-frame-diagnostics.patch). Insert the missing header.
# Idempotent: patches that already carry it are left untouched.
set -euo pipefail

python3 - <<'PY'
import pathlib

fixed = []
for root in ('../UniXNU/patches', 'patches'):
    base = pathlib.Path(root)
    if not base.is_dir():
        continue
    for patch in sorted(base.rglob('*.patch')):
        body = patch.read_text(encoding='utf-8', errors='replace')
        if '--- /dev/null' not in body or 'new file mode' in body:
            continue
        out = []
        for line in body.splitlines(keepends=True):
            if line.strip() == '--- /dev/null' and not (out and out[-1].startswith('new file mode ')):
                out.append('new file mode 100644\n')
            out.append(line)
        patch.write_text(''.join(out), encoding='utf-8')
        fixed.append(str(patch))

print('ci-repair-patches: repaired', len(fixed), 'patch files')
for name in fixed:
    print('  ', name)
PY
