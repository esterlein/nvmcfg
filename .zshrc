export ZSH="$HOME/.oh-my-zsh"

# theme
ZSH_THEME=""

source "$ZSH/oh-my-zsh.sh"

# detect platform
OS="$(uname -s)"

if [[ "$OS" == "Darwin" ]]; then
	export IS_MACOS=1

	# symlinks for llvm and lld
	export PATH="/usr/local/opt/llvm/bin:$PATH"
	export PATH="/usr/local/opt/lld/bin:$PATH"

	# compiler and linker
	export CC="/usr/local/opt/llvm/bin/clang"
	export CXX="/usr/local/opt/llvm/bin/clang++"
	export LD="/usr/bin/ld"

	# libc++
	export CXXFLAGS="-nostdinc++ -isystem /usr/local/opt/llvm/include/c++/v1 -I/usr/local/opt/llvm/include -stdlib=libc++ $CXXFLAGS"
	export LDFLAGS="-nostdlib++ -L/usr/local/opt/llvm/lib/c++ -lc++ -stdlib=libc++ -L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib/unwind -lunwind $LDFLAGS"
	export CPPFLAGS="-I/usr/local/opt/llvm/include"

	# c++ include and lib
	CPLUS_INCLUDE_PATH="/usr/local/include:${CPLUS_INCLUDE_PATH}"
	export CPLUS_INCLUDE_PATH

	LIBRARY_PATH="/usr/local/lib:${LIBRARY_PATH}"
	export LIBRARY_PATH

	# zplug
	export ZPLUG_HOME="/usr/local/opt/zplug"
else
	export IS_LINUX=1

	# zplug
	export ZPLUG_HOME="$HOME/.zplug"
fi

# user config
bindkey '	' autosuggest-accept

export EDITOR='nvim'
export PATH="$HOME/.pyenv/shims:$PATH"

# aliases
alias python=python3
alias pip=pip3

# plugins
plugins=(git)

[ -f "$ZPLUG_HOME/init.zsh" ] && source "$ZPLUG_HOME/init.zsh"
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

# ssh
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
	eval "$(ssh-agent -s)"
fi

if [ -f "$HOME/.ssh/id_ed25519" ]; then
	if ! ssh-add -l | grep -q "id_ed25519"; then
		ssh-add "$HOME/.ssh/id_ed25519" > /dev/null 2>&1
	fi
fi
