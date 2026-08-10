#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${EUID}" -ne 0 ]; then
    echo "Run as root: curl -fsSL https://raw.githubusercontent.com/josephrandall577/xboard-node/dev/upgrade-amd64.sh | sudo bash" >&2
    exit 1
fi

if [ "$(uname -s)" != "Linux" ] || [ "$(uname -m)" != "x86_64" ]; then
    echo "This script only supports Linux amd64" >&2
    exit 1
fi

for command in curl sha256sum systemctl; do
    command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
base=https://github.com/josephrandall577/xboard-node/releases/latest/download
curl -fsSL "$base/xbctl-linux-amd64" -o "$tmp/xbctl-linux-amd64"
curl -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS"
(cd "$tmp" && grep '  xbctl-linux-amd64$' SHA256SUMS | sha256sum -c -)
chmod +x "$tmp/xbctl-linux-amd64"
"$tmp/xbctl-linux-amd64" upgrade --version latest
systemctl status xboard-node.service --no-pager
