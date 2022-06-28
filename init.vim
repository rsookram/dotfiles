" Map leader key to space
let mapleader = "\<Space>"

" =============================================================================
" # PLUGINS
" =============================================================================
set nocompatible
filetype off
call plug#begin()

" Load plugins

" Collection of common configs for built-in LSP client
Plug 'neovim/nvim-lspconfig'
" Autocompletion framework for built-in LSP
Plug 'nvim-lua/completion-nvim'

" GUI enhancements
Plug 'noahfrederick/vim-noctu'

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Matching brackets/parens/quotes
Plug 'jiangmiao/auto-pairs'

" Git
Plug 'tpope/vim-fugitive'

" Language-specific
Plug 'khaveesh/vim-fish-syntax'
Plug 'fatih/vim-go'
Plug 'udalov/kotlin-vim'
Plug 'rust-lang/rust.vim'
Plug 'keith/swift.vim'

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
let g:fzf_layout = {'window': {'width': 0.9, 'height': 0.9}}

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


" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use <Tab> as trigger key
imap <Tab> <Plug>(completion_smart_tab)

" Configure LSP
lua <<EOF

-- nvim_lsp object
local nvim_lsp = require'lspconfig'

-- function to attach completion when setting up lsp
local on_attach = function(client, bufnr)
    local opts = { noremap=true, silent=true }

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

    require'completion'.on_attach(client)
end

-- Go
nvim_lsp.gopls.setup({ on_attach=on_attach })

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({
  on_attach=on_attach,
  settings = {
    ["rust-analyzer"] = {
      assist = {
        importGranularity = "module",
        importPrefix = "by_self",
      },
      cargo = {
        loadOutDirsFromCheck = true
      },
      procMacro = {
        enable = true
      },
    }
  }
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
EOF

" vim-go
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1

" rust.vim
let g:rustfmt_autosave = 1

" Theme
colorscheme noctu

" Hide tildes at the end of the file
let &fcs='eob: '


autocmd BufRead,BufNewFile *.md setlocal spell

" Start commits in insert mode at the beginning of the file
autocmd FileType gitcommit call feedkeys('ggi')

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

" Synchronize with system clipboard
set clipboard=unnamedplus
