export ZSH="$HOME/.oh-my-zsh"

# theme
ZSH_THEME=""

source $ZSH/oh-my-zsh.sh

# user config
bindkey '	' autosuggest-accept

export EDITOR='nvim'
export PATH="$HOME/.pyenv/shims:$PATH"

# symlinks for llvm and lld
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/usr/local/opt/lld/bin:$PATH"

# compiler
export CC="/usr/local/opt/llvm/bin/clang"
export CXX="/usr/local/opt/llvm/bin/clang++"

# linker
export LD="/usr/bin/ld"

# bundled libc++ and libunwind
export LDFLAGS="-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib/c++ -L/usr/local/opt/llvm/lib/unwind -lunwind"
export CPPFLAGS="-I/usr/local/opt/llvm/include"

# c++ include and lib
CPLUS_INCLUDE_PATH="~/code/learogl/deps:${CPLUS_INCLUDE_PATH}"
CPLUS_INCLUDE_PATH="/usr/local/include:${CPLUS_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH

LIBRARY_PATH="/usr/local/lib:${LIBRARY_PATH}"
export LIBRARY_PATH

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
