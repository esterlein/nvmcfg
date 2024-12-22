export ZSH="$HOME/.oh-my-zsh"

# theme

ZSH_THEME=""

source $ZSH/oh-my-zsh.sh

# user config

bindkey '	' autosuggest-accept

export EDITOR='nvim'
export PATH="$HOME/.pyenv/shims:$PATH"

export PATH="/usr/local/Cellar/llvm/19.1.4/bin:${PATH}"
export PATH="/usr/local/Cellar/lld/19.1.4/bin:${PATH}"


CPLUS_INCLUDE_PATH="/usr/local/Cellar/fmt/11.0.2/include:${CPLUS_INCLUDE_PATH}"
CPLUS_INCLUDE_PATH="/usr/local/Cellar/gcc/14.2.0_1/include:${CPLUS_INCLUDE_PATH}"
#CPLUS_INCLUDE_PATH="/usr/local/include:${CPLUS_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH

LIBRARY_PATH="/usr/local/lib:${LIBRARY_PATH}"
LIBRARY_PATH="/usr/local/Cellar/fmt/11.0.2/lib:${LIBRARY_PATH}"
export LIBRARY_PATH

export CC=/usr/local/Cellar/llvm/19.1.4/bin/clang
export CXX=/usr/local/Cellar/llvm/19.1.4/bin/clang++

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

