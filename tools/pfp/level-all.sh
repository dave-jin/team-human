#!/bin/bash
# Bring every team portrait's backdrop to the house colour (#C9C3B3).
#
#   tools/pfp/level-all.sh              # rewrite images/PFP/*.png in place
#   tools/pfp/level-all.sh --dry-run    # just print each photo's backdrop + the shift
#
# Run AFTER fit-all.sh, not before — fitting stretches edge pixels to fill
# margins, so level the colour once the geometry is final.
set -euo pipefail
cd "$(dirname "$0")/../.."
MEMBERS=(Danny Dave Eric Kelly Rachel Sireal Annie SMU Chloe)
if [ "${1:-}" = "--dry-run" ]; then
  for m in "${MEMBERS[@]}"; do
    swift tools/pfp/level-backdrop.swift "images/PFP/$m.png" --measure-only 2>/dev/null
  done
  exit 0
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
for m in "${MEMBERS[@]}"; do
  swift tools/pfp/level-backdrop.swift "images/PFP/$m.png" "$tmp/$m.png" 2>/dev/null
done
for m in "${MEMBERS[@]}"; do mv "$tmp/$m.png" "images/PFP/$m.png"; done
echo "done — ${#MEMBERS[@]} backdrops levelled"
