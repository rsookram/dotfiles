" Treat long lines as break lines
map j gj
map k gk

set title

set wildmenu

set showcmd
set incsearch

set noerrorbells
set novisualbell

set number

set ruler

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

set splitbelow
set splitright

execute pathogen#infect()

filetype plugin indent on
filetype plugin on

set omnifunc=syntaxcomplete#Complete
set completeopt=menu

inoremap ,, <C-x><C-o>

syntax on

