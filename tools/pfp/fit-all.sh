#!/bin/bash
# Re-fit every team portrait into the house frame.
#
#   tools/pfp/fit-all.sh              # rewrite images/PFP/*.png in place
#   tools/pfp/fit-all.sh --dry-run    # just print what each photo measures
#
# Run this from an ORIGINAL photo whenever possible — re-fitting an already
# fitted file resamples it a second time. Originals live in the vault at
# PARA/1. Inbox/01_Images/ and in this repo's git history.
set -euo pipefail
cd "$(dirname "$0")/../.."
MEMBERS=(Danny Dave Eric Kelly Rachel Sireal Annie SMU Chloe)
if [ "${1:-}" = "--dry-run" ]; then
  for m in "${MEMBERS[@]}"; do
    swift tools/pfp/fit-portrait.swift "images/PFP/$m.png" --measure-only 2>/dev/null
  done
  exit 0
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
for m in "${MEMBERS[@]}"; do
  swift tools/pfp/fit-portrait.swift "images/PFP/$m.png" "$tmp/$m.png" 2>/dev/null
done
for m in "${MEMBERS[@]}"; do mv "$tmp/$m.png" "images/PFP/$m.png"; done
echo "done — $(( ${#MEMBERS[@]} )) portraits refitted"
