set -euo pipefail

mode_dir="${XDG_RUNTIME_DIR:?}/gamescope-client-mode"
mode_file="$mode_dir/modes.cfg"
state_file="$mode_dir/active-mode"
applied_file="$mode_dir/applied-mode"
mode_tmp=""
state_tmp=""

cleanup() {
  if [[ -n "$mode_tmp" ]]; then
    rm -f -- "$mode_tmp"
  fi
  if [[ -n "$state_tmp" ]]; then
    rm -f -- "$state_tmp"
  fi
}
trap cleanup EXIT

mkdir -p -- "$mode_dir"
chmod 0700 "$mode_dir"
exec 9>"$mode_dir/lock"
if ! flock -n 9; then
  echo "A Gamescope client mode change is already running." >&2
  exit 75
fi

case "${1:-}" in
  set-client)
    if [[ "$#" -ne 1 ]]; then
      echo "Usage: sunshine-gamescope-mode set-client" >&2
      exit 64
    fi
    if [[ -z "${SUNSHINE_CLIENT_WIDTH:-}" || -z "${SUNSHINE_CLIENT_HEIGHT:-}" ]]; then
      echo "Sunshine did not provide client width and height." >&2
      exit 64
    fi

    width="$SUNSHINE_CLIENT_WIDTH"
    height="$SUNSHINE_CLIENT_HEIGHT"
    case "$width:$height" in
      1920:1080 | 2560:1600)
        ;;
      *)
        echo "Unsupported client resolution: ${width}x${height}" >&2
        exit 64
        ;;
    esac

    if [[ -e "$state_file" ]]; then
      read -r active_width active_height < "$state_file"
      if [[ "$width" != "$active_width" || "$height" != "$active_height" ]]; then
        echo "A different Gamescope client mode is already active; restore it before starting another stream." >&2
        exit 75
      fi
      if [[ -r "$applied_file" ]] &&
        read -r applied_width applied_height < "$applied_file" &&
        [[ "$width" == "$applied_width" && "$height" == "$applied_height" ]] &&
        [[ -r "$mode_file" ]] &&
        systemctl --user is-active --quiet gamescope-session.target; then
        exit 0
      fi
    fi

    mode_tmp="$(mktemp "$mode_dir/modes.XXXXXX")"
    state_tmp="$(mktemp "$mode_dir/state.XXXXXX")"

    printf 'BCV BC250 VKMS:%sx%s@60 0\n' "$width" "$height" > "$mode_tmp"
    printf '%s %s\n' "$width" "$height" > "$state_tmp"
    chmod 0600 "$mode_tmp" "$state_tmp"
    mv -f -- "$mode_tmp" "$mode_file"
    mode_tmp=""
    mv -f -- "$state_tmp" "$state_file"
    state_tmp=""
    rm -f -- "$applied_file"

    if ! systemctl --user restart gamescope-session.target; then
      rm -f -- "$mode_file" "$state_file" "$applied_file"
      systemctl --user restart gamescope-session.target || true
      exit 1
    fi
    ;;

  restore)
    if [[ "$#" -ne 1 ]]; then
      echo "Usage: sunshine-gamescope-mode restore" >&2
      exit 64
    fi
    if [[ ! -e "$state_file" && ! -e "$applied_file" && ! -e "$mode_file" ]]; then
      exit 0
    fi

    systemctl --user unset-environment \
      GAMESCOPE_SESSION_WIDTH \
      GAMESCOPE_SESSION_HEIGHT \
      GAMESCOPE_MODE_SAVE_FILE || true
    rm -f -- "$mode_file" "$state_file" "$applied_file"
    if systemctl --user is-active --quiet gamescope-session.target; then
      systemctl --user restart gamescope-session.target
    fi
    ;;

  *)
    echo "Usage: sunshine-gamescope-mode {set-client|restore}" >&2
    exit 64
    ;;
esac
