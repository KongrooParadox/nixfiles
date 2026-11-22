#!/usr/bin/env bash
set -euo pipefail

llm_specialisation="/run/current-system/specialisation/mjolnir-llm"
rocm_specialisation="/run/current-system/specialisation/mjolnir-llm-rocm"

current_role() {
  if [ -e "$rocm_specialisation" ]; then
    echo llm-rocm
  elif [ -e "$llm_specialisation" ]; then
    echo llm
  else
    echo gaming
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
      "$llm_specialisation/bin/switch-to-configuration" boot
      ;;
    llm-rocm)
      "$rocm_specialisation/bin/switch-to-configuration" boot
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
  llm | llm-rocm | gaming)
    boot_role "$1"
    ;;
  *)
    echo "usage: mjolnir-role [status|llm|llm-rocm|gaming]" >&2
    exit 2
    ;;
esac
