alias g="git";
alias gst="git status -sb";
alias gstl="git status -sb";
alias ga="git add";
alias gai="git add -i";
alias gb="git branch -vv";
alias gbl="git blame";
alias gco="git commit";
alias gl="git log --abbrev-commit --decorate=short";
alias gd="git diff --patience --patch-with-stat";
alias gdh="git diff --patience --patch-with-stat HEAD";
alias gdst="git diff --patience --staged --patch-with-stat";
# https://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings/1250279#1250279
alias gsf='git status -s | fzf --reverse --height=15 | awk '"'"'{ print $2 }'"'"'';

alias l='ls -1 -G'
alias ll='ls -alFG'

alias adb='adbp'
alias adbreset='adb kill-server && adb devices'
alias lc='adbp shell logcat -v color'

alias vif='vi "$(fzf --reverse --preview "cat {}")"'

alias cdr='cd $(ls -1d $HOME/src/*/ | fzf --height 50 --reverse --delimiter "/" --with-nth 5 --preview "ls {}")'

alias utc='date -u'

alias bc='bc --quiet --mathlib'

# Use output from fd as default list for fzf. Allows fzf to respect .gitignore
export FZF_DEFAULT_COMMAND='fd --type f'

# colour man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[32m'

# better colours for ls
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

export PATH=${PATH}:$HOME/bin
export PATH=${PATH}:$HOME/go/bin
export PATH=${PATH}:$HOME/Library/Android/sdk/tools
export PATH=${PATH}:$HOME/Library/Android/sdk/platform-tools
export PATH=${PATH}:$HOME/tools
export PATH=${PATH}:$HOME/src/other/adb-peco/bin

# added by Anaconda3 5.2.0 installer
export PATH="/anaconda3/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

# prompt
export PS1="\w $ "

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

export NVM_DIR="$HOME/.nvm"
alias setupnvm=". $NVM_DIR/nvm.sh"

# https://github.com/direnv/direnv
eval "$(direnv hook bash)"

alias dc="docker-compose"
