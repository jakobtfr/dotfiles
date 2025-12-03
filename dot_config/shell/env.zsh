export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"
export DISABLE_AUTO_TITLE='true'

export PATH="/Library/TeX/texbin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
