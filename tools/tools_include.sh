# THE logmsg function.
function logmsg () {
  scriptname="$(echo $0 | sed 's/^\(.*\/\)\([a-zA-Z0-9_-]\+\.sh\)$/\2/')"
  if [[ $# -eq 2 && "$1" = "-e" ]]; then
    echo -e "\e[31m[ $scriptname ] $2\e[0m"
  else
    echo -e "\e[36m[ $scriptname ] $1\e[0m"
  fi
}

function escape_sed() {
  echo "$1" | sed 's/[][}{}^/()$&.*+?|]/\\&/g'
}

# print every line starting with a '#' in green
function print_cmds_green() {
  local file="$1"
  while IFS= read -r line; do
    if [[ "$line" =~ ^\# ]]; then
      # Print in grey
    echo "$line"
  else
    # Print in green
    echo -e "\e[32m$line\e[0m"
    fi
  done < "$file"
}

ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local answer

  while true; do
    read -r -p "$prompt [y/n] ($default): " answer
    answer="${answer:-$default}"

    case "$answer" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}
