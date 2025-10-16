# THE logmsg function.
function logmsg () {
  scriptname="$(echo $0 | sed 's/^\(.*\/\)\([a-zA-Z0-9_-]\+\.sh\)$/\2/')"
  if [[ $# -eq 2 && "$1" = "-e" ]]; then
    echo -e "\e[31m[ $scriptname ] $2\e[0m"
  elif [ $# -eq 0 ]; then
    echo -e "\e[36m[ $scriptname ]\e[0m"
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

# ask_yes_no <prefix> <prompt> [default]
function ask_yes_no() {
  local prefix="$1"
  local prompt="$2"
  local default="${3:-y}"
  local answer

  while true; do
    echo -en "$prefix\e[1;35m $prompt [y/n] ($default):\e[0m " && read -r answer
    answer="${answer:-$default}"

    case "$answer" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}
