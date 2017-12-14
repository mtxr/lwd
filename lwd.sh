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

__LWDREGISTER=0

__lwd_precmd_fn_hook () {
  if [ $__LWDREGISTER -eq 0 ]; then
    return
  fi
  __LWDREGISTER=0
  (echo -n "$PWD" > $LWDHISTORY &)
}

__lwd_preexec_fn_hook () {
  __LWDREGISTER=1
}

if [ -n "$ZSH_VERSION" ]; then
  if [[ ! " ${precmd_functions[@]} " =~ " __lwd_precmd_fn_hook " ]]; then
    precmd_functions=(${precmd_functions[@]} "__lwd_precmd_fn_hook")
  fi
  if [[ ! " ${preexec_functions[@]} " =~ " __lwd_preexec_fn_hook " ]]; then
    preexec_functions=(${preexec_functions[@]} "__lwd_preexec_fn_hook")
  fi
else
  # override current cd fn to allow adding to lwd history
  cd() {
    builtin cd $@ && __lwd_precmd_fn_hook && return 0
  }
fi
