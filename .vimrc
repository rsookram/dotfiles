syntax on
set showcmd
set title
set ignorecase
set noerrorbells
set novisualbell
set number
set ruler
set ai
set ci
filetype plugin indent on

autocmd BufRead *.py nmap <F5> :!python %<CR>
autocmd BufRead *.c nmap <F5> :!gcc % && ./a.out<CR>
set tabstop=4
