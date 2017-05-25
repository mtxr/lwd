#!/bin/zsh

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
LWDHISTORY=${LWDHISTORY:-"$HOME/.lwdhistory"}
LWDHISTORYSIZE=${LWDHISTORYSIZE:-10}

_lwd_search() {
  if [ ! -f "$LWDHISTORY" ]; then 
    echo ""
    return 0
  fi

  local search="$1"

  cat $LWDHISTORY | grep "$search" --color=none
}

_lwd_last() {
  if [ ! -f "$LWDHISTORY" ]; then 
    echo "$PWD"
    return 0
  fi

  local last=$(head -n 1 $LWDHISTORY)
  if [ ! -d "$last" ];then
    return 1
  fi
  
  echo "$last"
  return 0
}

_lwd_clear() {
  echo -n "" > $LWDHISTORY && return 0
}

_lwd_add() {
  (
    (
      local pathtoadd="$1"
      if [ "$pathtoadd" = "" ]; then
        return 0
      fi
      local PARSEDPATHS=$(grep -vwF "${pathtoadd}" "$LWDHISTORY" | sed '/^\s*$/d')
      echo "$pathtoadd\n$PARSEDPATHS" > $LWDHISTORY && return 0
    ) & 
  )
  return 0
}

cd() {
    builtin cd $@
    _lwd_add "$PWD"
    return 0    
}

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

lwd() {
  if [ "$#" = "0" ]; then
    local last=$(_lwd_last)
    if [ ! -d "$last" ];then
      echo "Dir '${last}' does not exist."
      return 1
    fi

    cd "$last"
    return 0
  elif [ "$1" = "clear" ]; then
    _lwd_clear && echo "LWD history cleared"
    return 0
  fi
  cd $@
}

if [[ -n ${ZSH_VERSION-} ]]; then
  autoload -U +X bashcompinit && bashcompinit
fi

complete -F _complete_lwd lwd
