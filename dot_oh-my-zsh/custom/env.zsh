export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"

# atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# pyenv
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
