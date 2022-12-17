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
Plug 'rsookram/monokaikai.vim'
Plug 'folke/which-key.nvim'

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
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_cursor {
      }
    },
    ["recent_files"] = {
      only_cwd = true
    }
  }
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('recent_files')
EOF


" Key bindings
lua << EOF
require("which-key").setup{
}
EOF

" Reduce timeout so that which-key panel appears sooner
set timeoutlen=500

nnoremap <leader>e <CMD>Telescope recent_files theme=dropdown previewer=false pick<CR>
nnoremap <leader>f <CMD>Telescope live_grep layout_strategy=vertical<CR>
nnoremap <leader>g <CMD>Telescope grep_string layout_strategy=vertical<CR>
nnoremap <leader>r <CMD>Telescope find_files<CR>

nnoremap <leader>ch <CMD>Telescope command_history<CR>

nnoremap <leader>d <CMD>lua vim.diagnostic.open_float()<CR>

" LSP key bindings
nnoremap <leader>la <CMD>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>ld <CMD>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>ln <CMD>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>lr <CMD>Telescope lsp_references<CR>
nnoremap <leader>ls <CMD>Telescope lsp_document_symbols<CR>
nnoremap <leader>lw <CMD>Telescope lsp_workspace_symbols<CR>


" Completion
"
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

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Go
nvim_lsp.gopls.setup({
  capabilities = capabilities,
})

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({
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
set termguicolors
colorscheme monokaikai

" Hide tildes at the end of the file
let &fcs='eob: '


autocmd BufRead,BufNewFile *.md setlocal spell

" Prevent x from copying to clipboard
nnoremap x "_x

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
