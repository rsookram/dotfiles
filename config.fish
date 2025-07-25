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

abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"

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
alias gds "git diff --patience --staged --patch-with-stat"
alias gch 'git checkout'
alias gcb 'git checkout (git branch | sed "s/^ *//" | fzf)'
alias ghpr 'gh pr create --web'

function gcbo
  git fetch

  git checkout origin/(gh pr list | fzf --reverse | awk '{ print $(NF-2) }')
end

function gbrowse
  git log --oneline --no-merges --color=always -- . |
    fzf --ansi --no-sort --reverse --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always | delta' --preview-window=wrap
end

if test (uname) = "Darwin"
  alias l 'ls -1 -G'
  alias ll 'ls -alFG'
else
  alias l 'ls -1 -G --color'
  alias ll 'ls -alFG --color'
end

alias c 'cargo'

alias adbreset 'adb kill-server && adb devices'
alias lc 'adb shell logcat --format=time,color'

function v
  if count $argv > /dev/null
    nvim $argv
  else
    # As of Neovim 0.11.2, running the command synchronously doesn't move focus
    # to the UI that Telescope displays.
    # https://github.com/nvim-telescope/telescope.nvim/issues/3480
    nvim -c 'lua vim.defer_fn(function()
      require("telescope.builtin").find_files(require("telescope.themes").get_dropdown {
        previewer = false,
      })
    end, 0)'
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

if test (uname) = "Darwin"
  set -gx JAVA_HOME '/Applications/Android Studio.app/Contents/jbr/Contents/Home/'
  set ANDROID_SDK ~/Library/Android/sdk
else
  set -gx JAVA_HOME ~/tools/android-studio/jbr
  set ANDROID_SDK ~/Android/Sdk
end

set -gx ANDROID_NDK_HOME $ANDROID_SDK/ndk/25.1.8937393/

fish_add_path ~/bin
fish_add_path ~/go/bin
fish_add_path ~/.cargo/bin
fish_add_path $ANDROID_SDK/platform-tools
fish_add_path $ANDROID_SDK/build-tools/35.0.0
fish_add_path $JAVA_HOME/bin

if test (uname) = "Darwin"
  fish_add_path /opt/homebrew/bin
else
  set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew";
  set -gx HOMEBREW_CELLAR "/home/linuxbrew/.linuxbrew/Cellar";
  set -gx HOMEBREW_REPOSITORY "/home/linuxbrew/.linuxbrew/Homebrew";
  fish_add_path "/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin";
  set -q MANPATH; or set MANPATH ''; set -gx MANPATH "/home/linuxbrew/.linuxbrew/share/man" $MANPATH;
  set -q INFOPATH; or set INFOPATH ''; set -gx INFOPATH "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH;
end

# Python user base binary directory
fish_add_path ~/.local/bin

# Use neovim for git commit messages
set -gx VISUAL nvim
set -gx EDITOR $VISUAL

# bat
set -gx BAT_THEME 'Monokai Extended'
set -gx BAT_STYLE 'plain'

# Disable auto-update with homebrew
set -gx HOMEBREW_NO_AUTO_UPDATE 1

if type -q fnm
  fnm env --use-on-cd | source 1>&2
end

if which fzf > /dev/null
  fzf --fish | source
end
