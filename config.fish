# Remove greeting
set fish_greeting

function fish_prompt
  if not set -q __fish_git_prompt_show_informative_status
    set -g __fish_git_prompt_show_informative_status 1
  end

  if not set -q __fish_git_prompt_color_branch
    set -g __fish_git_prompt_color_branch brmagenta
  end

  if not set -q __fish_git_prompt_color_stagedstate
    set -g __fish_git_prompt_color_stagedstate yellow
  end

  printf '%s%s%s%s> ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) (fish_git_prompt)
end


set --universal fish_color_normal FFFFFF
set --universal fish_color_selection --background=EEEEEC
set --universal fish_color_match --background=E4E4E4
set --universal fish_color_search_match --background=000000
set --universal fish_color_comment CFBFAD
set --universal fish_color_autosuggestion 929292
set --universal fish_color_param FF8700
set --universal fish_color_quote FCF330
set --universal fish_color_command A0EB01


alias g "git"
alias gst "git status -sb"
alias gsh "git show"
alias ga "git add"
alias gai "git add -i"
alias gap "git add -p * .*"
alias gr "git rebase"
alias gb "git branch -vv"
alias gbl "git blame"
alias gco "git commit -v"
alias gl "git log --abbrev-commit --decorate=short"
alias gd "git diff --patience --find-renames --patch-with-stat"
alias gdh "git diff --patience --find-renames --patch-with-stat HEAD"
alias gdst "git diff --patience --staged --patch-with-stat"
alias gch 'git checkout'
alias gcb 'git checkout (git branch | sed "s/^ *//" | fzf)'
alias ghpr 'gh pr create --web'

function gcbo
  git fetch

  git checkout origin/(gh pr list | fzf --reverse | awk '{ print $(NF-5) }')
end

function gbrowse
  git log --oneline --no-merges --color=always -- . |
    fzf --ansi --no-sort --reverse --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always | delta' --preview-window=wrap
end

alias l 'exa --oneline --group-directories-first'
alias ll 'exa --long --all --classify --group-directories-first'
alias tree 'exa --tree'

alias c 'cargo'

alias adbreset 'adb kill-server && adb devices'
alias lc 'adb shell logcat -v color'

function v
  if count $argv > /dev/null
    nvim $argv
  else
    set file (DISABLE_FNM=true fzf --reverse --preview "bat --color=always {}" --preview-window=wrap)
    if test $status -eq 0
      nvim $file
    end
  end
end

function cdr
  set dir (ls -1d ~/src/*/ | fzf --height 50 --reverse --delimiter '/' --with-nth 5)

  if test $status -eq 0
    cd $dir
  end
end

alias bc 'bc --quiet --mathlib'

set -gx FZF_CTRL_R_OPTS '--reverse'
# Use output from fd as default list for fzf. Allows fzf to respect .gitignore
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git --strip-cwd-prefix'

# colour man pages
set -gx LESS_TERMCAP_mb \e'[01;31m'
set -gx LESS_TERMCAP_md \e'[31m'
set -gx LESS_TERMCAP_me \e'[0m'
set -gx LESS_TERMCAP_se \e'[0m'
set -gx LESS_TERMCAP_so \e'[38;5;246m'
set -gx LESS_TERMCAP_ue \e'[0m'
set -gx LESS_TERMCAP_us \e'[32m'



if test (uname) = "Darwin"
  set -gx JAVA_HOME '/Applications/Android Studio.app/Contents/jre/Contents/Home/'
  set ANDROID_SDK ~/Library/Android/sdk
else
  set -gx JAVA_HOME ~/tools/android-studio/jre
  set ANDROID_SDK ~/Android/Sdk
end

set -gx ANDROID_NDK_HOME $ANDROID_SDK/ndk/21.0.6113669/

set -gx PATH $PATH ~/bin
set -gx PATH $PATH ~/go/bin
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH $PATH $ANDROID_SDK/platform-tools
set -gx PATH $PATH $ANDROID_SDK/build-tools/30.0.3
set -gx PATH $JAVA_HOME/bin $PATH
set -gx PATH $PATH ~/tools/depot_tools

if test (uname) = "Darwin"
  set -gx PATH $PATH /opt/homebrew/bin
else
  set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew";
  set -gx HOMEBREW_CELLAR "/home/linuxbrew/.linuxbrew/Cellar";
  set -gx HOMEBREW_REPOSITORY "/home/linuxbrew/.linuxbrew/Homebrew";
  set -gx PATH "/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $PATH;
  set -q MANPATH; or set MANPATH ''; set -gx MANPATH "/home/linuxbrew/.linuxbrew/share/man" $MANPATH;
  set -q INFOPATH; or set INFOPATH ''; set -gx INFOPATH "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH;
end

# Go installation is managed by homebrew on macos
if test (uname) = "Linux"
  set -gx PATH $PATH /usr/local/go/bin
end

# Python user base binary directory
set -gx PATH $PATH ~/.local/bin


# Use neovim for git commit messages
set -gx VISUAL nvim
set -gx EDITOR $VISUAL

# bat
set -gx BAT_THEME 'Monokai Extended'
set -gx BAT_STYLE 'plain'

# Disable auto-update with homebrew
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# fnm
if which fnm > /dev/null
  if not set -q DISABLE_FNM
    fnm env --use-on-cd | source 1>&2
  end
end
