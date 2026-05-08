#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

script_hint() {
  local category="$1"
  local script="$2"
  case "$category/$script" in
    "connect/connect-portainer-tunnel.sh")
      echo "args: <server_ip> [ssh_user] [ssh_port] [local_port]"
      ;;
    "caddy/generate-password-hash.sh")
      echo "args: <plain_password> [username]"
      ;;
    *)
      echo ""
      ;;
  esac
}
list_categories() {
  find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d \
    ! -name "lib" \
    -printf "%f\n" | sort
}

list_scripts_in_category() {
  local category="$1"
  find "$SCRIPT_DIR/$category" -mindepth 1 -maxdepth 1 -type f -name "*.sh" \
    -printf "%f\n" | sort
}

run_category_menu() {
  local category="$1"
  local scripts=()

  mapfile -t scripts < <(list_scripts_in_category "$category")
  if [ "${#scripts[@]}" -eq 0 ]; then
    echo "No scripts in category: $category"
    return
  fi

  while true; do
    echo
    echo "=== $category ==="
    for i in "${!scripts[@]}"; do
      hint="$(script_hint "$category" "${scripts[$i]}")"
      if [ -n "$hint" ]; then
        printf "%d) %s (%s)\n" "$((i + 1))" "${scripts[$i]}" "$hint"
      else
        printf "%d) %s\n" "$((i + 1))" "${scripts[$i]}"
      fi
    done
    echo "0) back"

    read -r -p "Select script: " script_choice
    if [ "$script_choice" = "0" ]; then
      break
    fi

    if ! [[ "$script_choice" =~ ^[0-9]+$ ]]; then
      echo "Invalid input."
      continue
    fi

    if [ "$script_choice" -lt 1 ] || [ "$script_choice" -gt "${#scripts[@]}" ]; then
      echo "Unknown option: $script_choice"
      continue
    fi

    selected_script="${scripts[$((script_choice - 1))]}"
    selected_path="$SCRIPT_DIR/$category/$selected_script"
    selected_hint="$(script_hint "$category" "$selected_script")"

    if [ -n "$selected_hint" ]; then
      echo "Hint: $selected_hint"
    fi
    read -r -p "Args (optional, press Enter for none): " args_line

    if [ -n "$args_line" ]; then
      read -r -a args <<< "$args_line"
      "$selected_path" "${args[@]}"
    else
      "$selected_path"
    fi
  done
}

while true; do
  categories=()
  mapfile -t categories < <(list_categories)

  echo
  echo "=== Scripts Categories ==="
  for i in "${!categories[@]}"; do
    printf "%d) %s\n" "$((i + 1))" "${categories[$i]}"
  done
  echo "0) exit"

  read -r -p "Select category: " choice
  if [ "$choice" = "0" ]; then
    exit 0
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid input."
    continue
  fi

  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#categories[@]}" ]; then
    echo "Unknown option: $choice"
    continue
  fi

  run_category_menu "${categories[$((choice - 1))]}"
done
