#!/bin/bash

SCRIPT=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0)
SCRIPTPATH=`dirname $SCRIPT`
LWDHISTORY=${LWDHISTORY:-"$HOME/.lwdhistory"}

lwd() {
  if [ ! -f "$LWDHISTORY" ]; then
    return 0
  fi

  local last=$(cat $LWDHISTORY)
  if [ ! -d "$last" ];then
    echo "Directory $last does not exist anymore." && return 1
  fi

  builtin cd "$last" && return 0
}

__lwd_chpwd_fn_hook () {
  (echo -n "$PWD" > $LWDHISTORY &)
}

if [ -n "$ZSH_VERSION" ]; then
  if [[ ! " ${precmd_functions[@]} " =~ " __lwd_chpwd_fn_hook " ]]; then
    precmd_functions=(${precmd_functionsf[@]} "__lwd_chpwd_fn_hook")
  fi
else
  # override current cd fn to allow adding to lwd history
  cd() {
    builtin cd $@ && __lwd_chpwd_fn_hook && return 0
  }
fi
