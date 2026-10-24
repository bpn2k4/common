#!/usr/bin/env bash
set -euo pipefail

file="$(dirname "${BASH_SOURCE[0]}")/docker-compose.yaml"
image="docker.io/t8y2/dbx"

auth=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

latest="$(curl -fsSL "${auth[@]}" https://api.github.com/repos/t8y2/dbx/releases/latest \
  | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p')"
current="$(sed -n "s|.*$image:\([^[:space:]]*\).*|\1|p" "$file")"

if [[ -z "$latest" ]]; then
  echo "Could not fetch latest version" >&2
  exit 1
fi

if [[ "$current" == "$latest" ]]; then
  echo "Already up to date ($current)"
  exit 0
fi

sed -i "s|$image:$current|$image:$latest|" "$file"
echo "Updated version from $current to $latest"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "version=$latest" >> "$GITHUB_OUTPUT"
fi
