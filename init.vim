" Map leader key to space
let mapleader = "\<Space>"

" =============================================================================
" # PLUGINS
" =============================================================================
set nocompatible
filetype off
call plug#begin()

" Load plugins

" GUI enhancements
Plug 'w0rp/ale'
Plug 'altercation/vim-colors-solarized'

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Matching brackets/parens/quotes
Plug 'jiangmiao/auto-pairs'

" Git
Plug 'tpope/vim-fugitive'

" Language-specific
Plug 'udalov/kotlin-vim'
Plug 'alderz/smali-vim'
Plug 'keith/swift.vim'
Plug 'fatih/vim-go'

call plug#end()

" Plugin settings

" fzf
" Override these commands to reverse the layout
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse']}, <bang>0)

command! -bang -nargs=? -complete=dir Buffers
    \ call fzf#vim#buffers(<q-args>, {'options': ['--layout=reverse']}, <bang>0)

" Open hotkeys
nmap <leader>o :Files<CR>
nmap <leader>e :Buffers<CR>

" Incremental Rg search
noremap <leader>f :RG<CR>
" Something like 'find usages' (of word under cursor)
noremap <leader>g :Rg<space><C-R><C-W><CR>

" Disable preview window for built-in commands
let g:fzf_preview_window = ''
" Display results for built-in commands in floating windows
let g:fzf_layout = {'window': {'width': 0.6, 'height': 0.7}}

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%'),
\ <bang>0)

command! -bang RG call fzf#vim#grep(
      \ 'fzf-vim-rg ""',
      \ 1,
      \ fzf#vim#with_preview({
      \   'options': ['--phony', '--bind', 'change:reload:fzf-vim-rg {q}'],
      \   'window': {'width': 0.8, 'height': 0.6}
      \ }, 'down:40%'),
      \ 0)

" ALE
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'go': ['goimports'],
\   'rust': ['rustfmt'],
\}
let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')

let g:ale_fix_on_save = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" vim-go
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1

" Theme
set background=light
colorscheme solarized

" Hide tildes at the end of the file
highlight EndOfBuffer ctermfg=bg


" Treat long lines as break lines
map j gj
map k gk

set wildmenu

set showcmd
set incsearch
set ignorecase

set noerrorbells
set novisualbell

set nohlsearch

set noruler
set laststatus=0

set expandtab

set softtabstop=2
set tabstop=2
set shiftwidth=2

set textwidth=79

set autoindent
set copyindent

set nocp
set noswapfile

set autoread

" Sane splits
set splitbelow
set splitright

" Permanent undo
set undodir=~/.vimdid
set undofile
