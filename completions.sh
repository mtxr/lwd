#/bin/bash

_complete_lwd() {
  local cur
  local prev
  local IFS=$'\n'
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  COMPREPLY=( )
  if [ "$prev" = "lwd" ];then
      local opts=$(_lwd_search "$cur")
      COMPREPLY=( "clear" ${opts[@]} )
  fi
  return 0
}
complete -F _complete_lwd lwd
