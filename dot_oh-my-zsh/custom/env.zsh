export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"
export DISABLE_AUTO_TITLE='true'

# atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# pyenv
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
