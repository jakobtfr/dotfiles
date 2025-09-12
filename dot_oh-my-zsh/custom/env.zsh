export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"
export DISABLE_AUTO_TITLE='true'

# atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# pyenv
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

# RBENV
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# ANDROID SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

# JAVA
export JAVA_HOME=$(/usr/libexec/java_home)
