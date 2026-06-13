#!/usr/bin/env bash
# Downloads the StevenBlack hosts list and converts it into the plain
# one-domain-per-line format that a PAN-OS Domain EDL can read.
# Output file: edl/panos-edl.txt
set -euo pipefail
 
OUT_DIR="edl"
OUT_FILE="${OUT_DIR}/panos-edl.txt"
SOURCE="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
 
mkdir -p "$OUT_DIR"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
 
# Keep only "0.0.0.0 domain" lines, take the domain, lowercase, drop junk,
# keep only valid domains, remove duplicates.
curl -fsSL --retry 3 "$SOURCE" \
  | grep '^0\.0\.0\.0 ' \
  | awk '{print $2}' \
  | tr 'A-Z' 'a-z' \
  | grep -vE '^(localhost|local|broadcasthost|ip6-)' \
  | grep -vE '^[0-9.]+$' \
  | grep -E '^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$' \
  | sort -u > "$TMP"
 
COUNT="$(wc -l < "$TMP")"
{ echo "# StevenBlack converted for PAN-OS - $(date -u +%FT%TZ) - ${COUNT} domains"; cat "$TMP"; } > "$OUT_FILE"
echo "Wrote ${COUNT} domains to ${OUT_FILE}"
