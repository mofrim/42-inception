#!/usr/bin/env bash

# count_char <char> <text>
function count_char() {
  echo -n $2 | sed "s/[^$1]//g" | wc -c
}

function shorten_path() {
  local path_level=$(echo pwd | sed 's/[^\/]//g' | wc -c)
  if [ $path_level -gt 2 ]; then
    pwd | sed 's/.*\/\([a-zA-Z0-9_-]\+\)\/\([a-zA-Z0-9_-]\+\)$/\1\/\2/'
  else
    pwd
  fi
}


shorten_path

count_char "/" "abb/aabcs/ak/djla"
