#!/usr/bin/env bash
set -euo pipefail

specialisation="/run/current-system/specialisation/mjolnir-llm"

current_role() {
  if [ -e "$specialisation" ]; then
    echo gaming
  else
    echo llm
  fi
}

boot_role() {
  local role="$1"
  local current
  current="$(current_role)"

  if [ "$role" = "$current" ]; then
    echo "already in the $role role" >&2
    exit 0
  fi

  case "$role" in
    llm)
      "$specialisation/bin/switch-to-configuration" boot
      ;;
    gaming)
      /nix/var/nix/profiles/system/bin/switch-to-configuration boot
      ;;
  esac

  echo "next boot: $role role; rebooting" >&2
  systemctl reboot
}

case "${1:-status}" in
  status)
    current_role
    ;;
  llm | gaming)
    boot_role "$1"
    ;;
  *)
    echo "usage: mjolnir-role [status|llm|gaming]" >&2
    exit 2
    ;;
esac
