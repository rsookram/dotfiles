" Map leader key to space
let mapleader = "\<Space>"

" Plugins
set nocompatible
filetype off
call plug#begin()

Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'rsookram/monokaikai.vim'
Plug 'folke/zen-mode.nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'rsookram/telescope-recent-files'

Plug 'tpope/vim-commentary'

Plug 'tpope/vim-fugitive'

Plug 'rust-lang/rust.vim'

call plug#end()

" Plugin settings

lua << EOF
require("telescope").setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require("telescope.actions").close,
        ["<C-u>"] = false -- so that I can delete to the beginning
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
    },
  },
  pickers = {
    find_files = {
      -- Hidden files aren't shown by default
      find_command = { "fd", "--hidden", "--type", "f", "--exclude", ".git", "--strip-cwd-prefix", "--glob", "" },
    },
    live_grep = {
      path_display = { "shorten" },
    },
    grep_string = {
      path_display = { "shorten" },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_cursor {
      }
    },
    ["recent_files"] = {
      tiebreak = function(_current_entry, _existing_entry, _prompt)
        -- Prevent the order from changing when filtering
        return false
      end,
    }
  }
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('recent_files')

require("zen-mode").setup {
  window = {
    width = 100,
  },
}
EOF

" Completion
"
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Limit height (default is available screen height)
set pumheight=12

lua <<EOF
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
    { name = 'buffer' },
    { name = 'vsnip' },
  }),
  experimental = {
    ghost_text = true,
  },
})

-- Configure LSP
local nvim_lsp = require'lspconfig'

local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<CMD>lua vim.lsp.buf.hover()<CR>', opts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

nvim_lsp.rust_analyzer.setup({
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        features = 'all',
      },
      checkOnSave = {
        command = 'clippy',
      },
      completion = {
        postfix = {
          enable = false,
        },
      },
      workspace = {
        symbol = {
          search = {
            kind = 'all_symbols',
          },
        },
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

" rust.vim
let g:rustfmt_autosave = 1

" Theme
set termguicolors
colorscheme monokaikai

" Make the dimmed area around the buffer in zen mode be the same as the
" terminal background
hi ZenBg guibg=#333333

" Hide tildes at the end of the file
let &fcs='eob: '


autocmd BufRead,BufNewFile *.md setlocal spell

" Briefly highlight yanked region
augroup highlight_yank
  autocmd!
  au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=400 }
augroup end


" Key bindings

" Go to the first non-whitespace character of the line more easily
nnoremap 0 ^
vnoremap 0 ^

nnoremap [d <CMD>lua vim.diagnostic.goto_prev()<CR>
nnoremap ]d <CMD>lua vim.diagnostic.goto_next()<CR>

nnoremap <leader>e <CMD>Telescope recent_files theme=dropdown previewer=false pick<CR>
nnoremap <leader>f <CMD>Telescope live_grep layout_strategy=vertical<CR>
nnoremap <leader>g <CMD>Telescope grep_string layout_strategy=vertical<CR>
nnoremap <leader>r <CMD>Telescope find_files theme=dropdown previewer=false<CR>

" Treat long lines as break lines
map <expr> j v:count ? 'j' : 'gj'
map <expr> k v:count ? 'k' : 'gk'


" LSP key bindings
nnoremap <leader>. <CMD>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>6 <CMD>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>G <CMD>Telescope lsp_references<CR>
nnoremap <leader>o <CMD>Telescope lsp_document_symbols<CR>
nnoremap <leader>O <CMD>Telescope lsp_workspace_symbols<CR>

" Key bindings for splits
nnoremap <leader>s <C-w>s
nnoremap <leader>v <C-w>v
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Prevent x from copying to clipboard
nnoremap x "_x

" Yank relative file path of current buffer
nnoremap <leader>y <CMD>let @+ = expand("%")<CR>

nnoremap <leader>z <CMD>ZenMode<CR>

" Run last external command
nnoremap <leader><tab> :!<Up><CR>

" Move line(s) up and down (and retain position within line)
nnoremap <Up> :move-2<CR>==
vnoremap <Up> :move '<-2<cr>gv=gv
nnoremap <Down> :move+<CR>==
vnoremap <Down> :move '>+1<cr>gv=gv

set relativenumber

set ignorecase

set nohlsearch

set noruler
set laststatus=0

set expandtab

set softtabstop=2
set tabstop=2
set shiftwidth=2

set textwidth=79

set copyindent

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
