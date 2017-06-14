#!/bin/zsh

_complete_lwd () {
  local -a options; options=$(_lwd_search | sed -e "s/^\(.*\)/\1:/g")
  options=( $(echo ${options[@]}) 'clear:clear history' )
  _describe 'values' options
  return 0
}

compdef _complete_lwd lwd
