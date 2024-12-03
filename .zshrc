export ZSH="$HOME/.oh-my-zsh"

# theme

ZSH_THEME=""

source $ZSH/oh-my-zsh.sh

# user config

bindkey '	' autosuggest-accept

export EDITOR='nvim'
export PATH="$HOME/.pyenv/shims:$PATH"

export CC=/usr/local/Cellar/llvm/19.1.4/bin/clang
export CXX=/usr/local/Cellar/llvm/19.1.4/bin/clang

# aliases

alias python=python3
alias pip=pip3

alias clang=/usr/local/Cellar/llvm/19.1.4/bin/clang
alias lldb=/usr/local/Cellar/llvm/19.1.4/bin/lldb
alias lldb-dap=/usr/local/Cellar/llvm/19.1.4/bin/lldb-dap
alias lld=/usr/local/Cellar/lld/19.1.4/bin/lld
alias ld64.lld=/usr/local/Cellar/lld/19.1.4/bin/ld64.lld

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

