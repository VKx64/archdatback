#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./install-config.sh <name>
  ./install-config.sh link <name>
  ./install-config.sh unlink <name>
  ./install-config.sh status <name>

Links from:   <repo>/config/<name>
To:           ~/.config/<name>

Notes:
  - link/unlink both delete ~/.config/<name> first (symlink/dir/file).
EOF
}

die() { echo "error: $*" >&2; exit 1; }

action="${1:-}"
name="${2:-}"

if [[ -z "${action}" || "${action}" == "-h" || "${action}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${action}" != "link" && "${action}" != "unlink" && "${action}" != "status" ]]; then
  name="${action}"
  action="link"
fi

[[ -n "${name}" ]] || die "missing <name>"
[[ "${name}" != *"/"* ]] || die "name must not contain '/' (got: ${name})"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
src="${SCRIPT_DIR}/config/${name}"
dst="${HOME}/.config/${name}"

mkdir -p "${HOME}/.config"

case "${action}" in
  status)
    if [[ -L "${dst}" ]]; then
      echo "linked: ${dst} -> $(readlink "${dst}")"
      exit 0
    fi
    if [[ -e "${dst}" ]]; then
      echo "exists (not a symlink): ${dst}"
      exit 0
    fi
    echo "missing: ${dst}"
    ;;

  unlink)
    rm -rf -- "${dst}"
    echo "removed: ${dst}"
    ;;

  link)
    [[ -e "${src}" ]] || die "source does not exist: ${src}"
    rm -rf -- "${dst}"
    ln -s -- "${src}" "${dst}"
    echo "linked: ${dst} -> ${src}"
    ;;
esac
