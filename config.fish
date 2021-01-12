# Remove greeting
set fish_greeting

function fish_prompt
  printf '%s%s%s> ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

alias g "git"
alias gst "git status -sb"
alias ga "git add"
alias gai "git add -i"
alias gap "git add -p * .*"
alias gb "git branch -vv"
alias gbl "git blame"
alias gco "git commit -v"
alias gl "git log --abbrev-commit --decorate=short"
alias gd "git diff --patience --patch-with-stat"
alias gdh "git diff --patience --patch-with-stat HEAD"
alias gdst "git diff --patience --staged --patch-with-stat"
alias gcb 'git checkout (git branch | sed "s/^ *//" | fzf)'

function gcbo
  git fetch

  git checkout origin/(gh pr list | fzf --reverse | awk '{ print $(NF-1) }')
end

function gbrowse
  git log --oneline --no-merges --color=always -- . |
    fzf --ansi --no-sort --reverse --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always | diff-so-fancy' --preview-window=wrap
end

alias l 'ls -1 -G --color'
alias ll 'ls -alFG --color'

alias adb-pull "adb shell 'find /sdcard/ -type file' | fzf | xargs -I{} adb pull {} ."
alias adbreset 'adb kill-server && adb devices'
alias lc 'adb shell logcat -v color'

alias vi 'nvim'
function vif
  set file (fzf --reverse --preview "bat --color=always {}" --preview-window=wrap)
  if test $status -eq 0
    nvim $file
  end
end

function cdr
  set dir (ls -1d ~/src/*/ ~/third-party/*/ | fzf --height 50 --reverse --delimiter '/' --with-nth 5)

  if test $status -eq 0
    cd $dir
  end
end

alias bc 'bc --quiet --mathlib'

alias wifi-settings 'nm-connection-editor'

# Use output from fd as default list for fzf. Allows fzf to respect .gitignore
set -gx FZF_DEFAULT_COMMAND 'fd --type f'

# colour man pages
set -gx LESS_TERMCAP_mb \e'[01;31m'
set -gx LESS_TERMCAP_md \e'[31m'
set -gx LESS_TERMCAP_me \e'[0m'
set -gx LESS_TERMCAP_se \e'[0m'
set -gx LESS_TERMCAP_so \e'[38;5;246m'
set -gx LESS_TERMCAP_ue \e'[0m'
set -gx LESS_TERMCAP_us \e'[32m'


set -gx JAVA_HOME ~/tools/android-studio/jre

set ANDROID_SDK ~/Android/Sdk/

set -gx PATH $PATH ~/bin
set -gx PATH $PATH /usr/local/go/bin
set -gx PATH $PATH ~/go/bin
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH $PATH $ANDROID_SDK/platform-tools
set -gx PATH $PATH $ANDROID_SDK/build-tools/28.0.3

# Python user base binary directory
set -gx PATH $PATH ~/.local/bin


# Use neovim for git commit messages
set -gx VISUAL nvim
set -gx EDITOR $VISUAL

# bat
set -gx BAT_THEME 'Solarized (light)'
set -gx BAT_STYLE 'plain'

# Disable auto-update with homebrew
set -gx HOMEBREW_NO_AUTO_UPDATE 1
