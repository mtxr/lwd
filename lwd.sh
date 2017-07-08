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

# override current cd fn to allow adding to lwd history
cd() {
  builtin cd $@ && echo -n "$PWD" > $LWDHISTORY && return 0
}
