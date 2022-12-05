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

" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" GUI enhancements
Plug 'noahfrederick/vim-noctu'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'smartpde/telescope-recent-files'

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

" telescope
lua << EOF
local actions = require("telescope.actions")
require("telescope").setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-u>"] = false
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--trim" -- this differs from the default
    }
  }
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('recent_files')
EOF

nnoremap <leader>r <cmd>Telescope find_files<cr>
nnoremap <leader>e <cmd>Telescope recent_files pick<cr>
nnoremap <leader>f <cmd>Telescope live_grep<cr>
nnoremap <leader>g <cmd>Telescope grep_string<cr>
nnoremap <leader>a <cmd>Telescope command_history<cr>

" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Configure LSP
lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    window = {
    },
    mapping = cmp.mapping.preset.insert({
      ['<TAB>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
    }),
    experimental = {
      ghost_text = true,
    },
  })

-- nvim_lsp object
local nvim_lsp = require'lspconfig'

-- function to attach completion when setting up lsp
local on_attach = function(client, bufnr)
    local opts = { noremap=true, silent=true }

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>6', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>G', '<Cmd>Telescope lsp_references<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>o', '<Cmd>Telescope lsp_document_symbols<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>t', '<Cmd>Telescope lsp_workspace_symbols<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>.', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Go
nvim_lsp.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({
  on_attach = on_attach,
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
  },
  capabilities = capabilities,
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
