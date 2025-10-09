# Remove greeting
set fish_greeting

function fish_prompt
  printf '%s%s%s> ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
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

abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"

alias g "git"
alias gst "git status -sb"
alias gsh "git show"
alias ga "git add"
alias gai "git add -i"
alias gap "git add -p * .*"
alias gb "git branch -vv"
alias gco "git commit -v"
alias gl "git log --abbrev-commit --decorate=short"
alias gd "git diff --patience --find-renames --patch-with-stat"
alias gdh "git diff --patience --find-renames --patch-with-stat HEAD"
alias gds "git diff --patience --staged --patch-with-stat"
alias gch 'git checkout'
alias gcb 'git checkout (git branch | sed "s/^ *//" | fzf)'

function gbrowse
  git log --oneline --no-merges --color=always -- . |
    fzf --ansi --no-sort --reverse --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always | delta' --preview-window=wrap
end

alias l 'ls -1 -G --color'
alias ll 'ls -alFG --color'

alias c 'cargo'
alias cr 'cargo run'
alias crr 'cargo run --release'
alias cb 'cargo build'
alias cbr 'cargo build --release'
alias ci 'cargo install'
alias cu 'cargo update --verbose'
alias ct 'cargo test'

alias lc 'adb shell logcat --format=time,color'

function v
  if count $argv > /dev/null
    nvim $argv
  else
    nvim -c ':FzfLua files'
  end
end

function j
  set dir (ls -1d ~/src/*/ | fzf --height 50 --reverse --delimiter '/' --with-nth 5)

  if test $status -eq 0
    cd $dir
  end
end

alias dl 'cd ~/Downloads'

alias bc 'bc --quiet --mathlib'

set -gx FZF_CTRL_R_OPTS '--reverse'
# Use output from fd as default list for fzf. Allows fzf to respect .gitignore
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --strip-cwd-prefix'

# Use neovim for viewing man pages
set -gx MANPAGER 'nvim +Man!'

set -gx JAVA_HOME ~/tools/android-studio/jbr
set ANDROID_SDK ~/Android/Sdk

set -gx ANDROID_HOME $ANDROID_SDK

fish_add_path ~/bin
fish_add_path ~/.cargo/bin
fish_add_path $ANDROID_SDK/platform-tools
fish_add_path $JAVA_HOME/bin

set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew";
set -gx HOMEBREW_CELLAR "/home/linuxbrew/.linuxbrew/Cellar";
set -gx HOMEBREW_REPOSITORY "/home/linuxbrew/.linuxbrew/Homebrew";
fish_add_path "/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin";
set -q MANPATH; or set MANPATH ''; set -gx MANPATH "/home/linuxbrew/.linuxbrew/share/man" $MANPATH;
set -q INFOPATH; or set INFOPATH ''; set -gx INFOPATH "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH;

fish_add_path ~/.local/bin

# Use neovim for git commit messages
set -gx VISUAL nvim
set -gx EDITOR $VISUAL

# bat
set -gx BAT_THEME 'Monokai Extended'
set -gx BAT_STYLE 'plain'

# Disable auto-update with homebrew
set -gx HOMEBREW_NO_AUTO_UPDATE 1

fzf --fish | source
