#!/bin/bash

SCRIPT=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0)
SCRIPTPATH=`dirname $SCRIPT`
LWDHISTORY=${LWDHISTORY:-"$HOME/.lwdhistory"}
LWDHISTORYSIZE=${LWDHISTORYSIZE:-10}

_lwd_search() {
  if [ ! -f "$LWDHISTORY" ]; then
    echo ""
    return 0
  fi

  local search="$1"
  local ESC_PWD=$(echo $PWD | sed 's_/_\\/_g')
  local ESC_HOME=$(echo $HOME | sed 's_/_\\/_g')

  cat $LWDHISTORY | \
    grep "$search" --color=none | \
    sed "s|^$ESC_PWD/||" | \
    sed "s|^$ESC_PWD|.|" | \
    sed "s|^$ESC_HOME|~|"
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

if [ -n "$ZSH_VERSION" ]; then
  . $SCRIPTPATH/completions.zsh
else
  . $SCRIPTPATH/completions.sh
fi

# override current cd fn to allow adding to lwd history
cd() {
    builtin cd $@
    _lwd_add "$PWD"
    return 0
}
