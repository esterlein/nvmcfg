export ZSH="$HOME/.oh-my-zsh"

# theme

ZSH_THEME=""

source $ZSH/oh-my-zsh.sh

# user config

export EDITOR='nvim'
export PATH="$HOME/.pyenv/shims:$PATH"

# aliases

alias python=python3
alias pip=pip3

# plugins

plugins=(git)

export ZPLUG_HOME=/usr/local/opt/zplug

source $ZPLUG_HOME/init.zsh
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug load

# install plugins

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

