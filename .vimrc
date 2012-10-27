syntax on
set showcmd
set title
set ignorecase
set noerrorbells
set novisualbell
set number
set ruler
set expandtab
set textwidth=79
set ai
set ci
set tabstop=8
set softtabstop=4
set shiftwidth=4
filetype plugin indent on

set completeopt=menu

autocmd BufRead *.py nmap <F5> :!python %<CR>
autocmd BufRead *.c nmap <F5> :!gcc % && ./a.out<CR>

inoremap ,, <C-x><C-o>
