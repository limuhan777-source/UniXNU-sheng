#!/usr/bin/env bash
# CI pre-flight fixes for a clean fork of UniXNU-sheng.
# 1. Upstream UniXNU at the pinned ref ships *.patch files whose "new file"
#    hunks lack the "new file mode" line, so `git apply` aborts packaging.
# 2. board.toml enables the Wi-Fi userspace build; its WCN7850 supplicant
#    sources are not in this repository, so it always fails. The key is a bare
#    TOML key, so comment it out before unixnu reads the board.
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

if [ -f board.toml ]; then
  perl -pi -e 's|^wifi_tool|# wifi_tool|' board.toml || true
  echo '--- board.toml wifi keys after repair ---'
  grep -n 'wifi_tool' board.toml || true
fi
