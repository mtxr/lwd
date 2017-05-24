#!/bin/zsh

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
LWDJS=$SCRIPTPATH/lwd.js

if [ ! -d "$SCRIPTPATH/../node_modules/" ]; then
    echo "Installing lwd dependencies"
    npm install --prefix $SCRIPTPATH/../
fi

function cd() {
    builtin cd $@
    (node $LWDJS add "$PWD" &> /dev/null &)
    return 0    
}

function _complete_lwd() {
    local cur
    local prev
    local IFS=$'\n'
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=( )
    if [ "$prev" = "lwd" ];then
        local opts=$(node $LWDJS search "$cur")
        COMPREPLY=( "clear" ${opts[@]} )
    fi
    return 0
}

function lwd() {
    if [ "$#" = "0" ]; then
        cd $(node $LWDJS)
        return 0
    elif [ "$1" = "clear" ]; then
        rm $HOME/.lwdhistory &> /dev/null && echo "LWD history cleared"
        return 0
    fi
    cd $@
}

if [[ -n ${ZSH_VERSION-} ]]; then
  autoload -U +X bashcompinit && bashcompinit
fi

complete -F _complete_lwd lwd
