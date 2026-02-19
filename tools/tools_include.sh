# THE logmsg function.
function logmsg () {
  scriptname="$(echo $0 | sed 's/^\(.*\/\)\([a-zA-Z0-9_-]\+\.sh\)$/\2/')"
  if [[ $# -eq 2 && "$1" = "-e" ]]; then
    echo -e "\e[31m[ $scriptname ] $2\e[0m"
  elif [[ $# -eq 2 && "$1" = "-n" ]]; then
    echo -ne "\e[36m[ $scriptname ] $2\e[0m"
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

# shamelessly stolen and adopted from ysap:
# https://github.com/bahamas10/ysap/blob/main/code/2026-01-07-spinner/spinner
#
function spinner() {
	# hide the cursor
	tput civis

	# local chars0=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
	local chars1=(
		"▐⠂       ▌"
		"▐⠈       ▌"
		"▐ ⠂      ▌"
		"▐ ⠠      ▌"
		"▐  ⡀     ▌"
		"▐  ⠠     ▌"
		"▐   ⠂    ▌"
		"▐   ⠈    ▌"
		"▐    ⠂   ▌"
		"▐    ⠠   ▌"
		"▐     ⡀  ▌"
		"▐     ⠠  ▌"
		"▐      ⠂ ▌"
		"▐      ⠈ ▌"
		"▐       ⠂▌"
		"▐       ⠠▌"
		"▐       ⡀▌"
		"▐      ⠠ ▌"
		"▐      ⠂ ▌"
		"▐     ⠈  ▌"
		"▐     ⠂  ▌"
		"▐    ⠠   ▌"
		"▐    ⡀   ▌"
		"▐   ⠠    ▌"
		"▐   ⠂    ▌"
		"▐  ⠈     ▌"
		"▐  ⠂     ▌"
		"▐ ⠠      ▌"
		"▐ ⡀      ▌"
		"▐⠠       ▌"
	)
	local skip_back1="\033[1D\033[1D\033[1D\033[1D\033[1D\033[1D\033[1D\033[1D\033[1D\033[1D\033[1D"
	local c
	while true; do
		for c in "${chars1[@]}"; do
			printf "\033[1;33m%s\033[0m $skip_back1" "$c"
			sleep .1
		done
	done
}

# same as above spinner function
function spinner_cleanup() {
	if [[ -n $SPINNER_PID ]]; then
		kill "$SPINNER_PID"
		unset -v SPINNER_PID
		tput cnorm
	fi
}

# set optional ssh keyfile option depending on location (school / not
# school)
if [ -n "$(hostname | grep wolfsburg)" ]; then
	export SSH_KEYOPT=""
else
	export SSH_KEYOPT="-i ~/.ssh/id_ed25519-mofrim"
fi
