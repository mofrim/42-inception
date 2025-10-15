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
