#!/bin/zsh

if [[ -n ${ZSH_VERSION-} ]]; then
  autoload -U +X bashcompinit && bashcompinit
fi

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
LWDJS=$SCRIPTPATH/lwd.js

function cd() {
    builtin cd $@
    node $LWDJS add $@
}

function _complete_lwd() {
    local cur
    local IFS=$'\n'
    cur="${COMP_WORDS[COMP_CWORD]}"
    local opts=$(node $LWDJS search "$cur")
    COMPREPLY=( ${opts[@]} )
    return 0
}

function lwd() {
    if [ "$#" = "0" ]; then
        cd $(node $LWDJS)
        return 0
    fi
    cd $@
}

if [[ -n ${ZSH_VERSION-} ]]; then
  autoload -U +X bashcompinit && bashcompinit
fi

complete -F _complete_lwd lwd
