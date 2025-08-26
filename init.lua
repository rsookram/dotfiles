-- Disable ShaDa for faster startup
vim.opt.shadafile = 'NONE'

-- Map leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'neovim/nvim-lspconfig',

  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      keymap = { preset = 'super-tab' },
      completion = {
        ghost_text = { enabled = true },
        menu = {
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind" },
            }
          },
        },
      }
    },
  },

  'rsookram/monokaikai.vim',

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
  },

  'lewis6991/gitsigns.nvim',
})

-- Plugin settings

require("telescope").setup{
  defaults = {
    layout_strategy = 'vertical',
    mappings = {
      i = {
        ["<esc>"] = require("telescope.actions").close,
        ["<C-u>"] = false -- so that I can delete to the beginning
      },
    },
    vimgrep_arguments = {
      "rg",
      "--vimgrep",
      "--smart-case",
      -- the following options differ from the default
      "--hidden",
      "--glob=!.git/*",
      "--trim"
    },
  },
  pickers = {
    find_files = {
      -- Hidden files aren't shown by default
      find_command = { "fd", "--hidden", "--type", "f", "--strip-cwd-prefix", "--glob", "", "--exclude", ".git/", "--max-results", "32767" },
    },
    live_grep = {
      path_display = { "shorten" },
    },
    grep_string = {
      path_display = { "shorten" },
    },
  },
}
require('telescope').load_extension('fzf')

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function()
        gs.prev_hunk()
        vim.api.nvim_feedkeys("zz", "n", false)
      end)
      return '<Ignore>'
    end, { expr = true, buffer = bufnr })

    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function()
        gs.next_hunk()
        vim.api.nvim_feedkeys("zz", "n", false)
      end)
      return '<Ignore>'
    end, { expr = true, buffer = bufnr })

    vim.keymap.set('n', '<leader>u', gs.reset_hunk, { buffer = bufnr })
  end
}

-- Completion
--
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force user to select one from the menu
vim.o.completeopt = "menuone,noinsert,noselect"

-- Limit height (default is available screen height)
vim.opt.pumheight = 12

-- Configure LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { noremap = true, silent = true }

    vim.api.nvim_buf_set_keymap(ev.buf, 'n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(ev.buf, 'n', '<leader>p', '<CMD>lua vim.lsp.buf.signature_help()<CR>', opts)

    vim.api.nvim_buf_set_keymap(ev.buf, 'n', 'gh', '<CMD>lua vim.diagnostic.open_float()<CR>', opts)
  end,
})

vim.lsp.config('rust_analyzer', {
  settings = {
    ["rust-analyzer"] = {
      cargo = { features = 'all' },
      check = { command = 'clippy' },
      completion = {
        postfix = { enable = false },
      },
    },
  },
})

vim.lsp.enable('rust_analyzer')

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Enable diagnostics
vim.diagnostic.config({
  virtual_text = { current_line = true }
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

-- Theme
vim.opt.termguicolors = true
vim.cmd.colorscheme 'monokaikai'

-- Hide tildes at the end of the file
vim.opt.fillchars = 'eob: '

-- Disable netrw banner (message at the top of the screen)
vim.g.netrw_banner = 0


vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Disable recommended style to keep 2 space indents
vim.g.markdown_recommended_style = 0

-- Briefly highlight yanked region
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 250 }
  end,
})

-- Key bindings

-- Go to the first non-whitespace character of the line more easily
vim.keymap.set({ 'n', 'v' }, '0', '^')

-- Treat long lines as break lines
vim.keymap.set({'n', 'v'}, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({'n', 'v'}, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

vim.keymap.set('n', '<leader>f', function()
  require('telescope.builtin').live_grep {
    disable_coordinates = true,
  }
end)

vim.keymap.set('n', '<leader>g', function()
  require('telescope.builtin').grep_string {
    disable_coordinates = true,
    word_match = '-w',
  }
end)

vim.keymap.set('n', '<leader>r', function()
  require('telescope.builtin').find_files(require('telescope.themes').get_dropdown {
    previewer = false,
  })
end)

-- LSP key bindings
vim.keymap.set({'n', 'v'}, '<leader>.', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>6', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>G', require('telescope.builtin').lsp_references)
vim.keymap.set('n', '<leader>o', require('telescope.builtin').lsp_document_symbols)

-- Key bindings for splits
vim.keymap.set('n', '<leader>s', '<C-w>s')
vim.keymap.set('n', '<leader>v', '<C-w>v')
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>k', '<C-w>k')
vim.keymap.set('n', '<leader>l', '<C-w>l')

-- Key bindings for quickfix commands
vim.keymap.set('n', '<C-n>', vim.cmd.cnext)
vim.keymap.set('n', '<C-p>', vim.cmd.cprev)
vim.keymap.set('n', '<leader>q', vim.cmd.cclose)

-- Prevent x from copying to clipboard
vim.keymap.set('n', 'x', '"_x')

-- Open netrw in the directory containing the current file
vim.keymap.set('n', '<leader><Up>', function()
  vim.cmd.edit(vim.fn.expand('%:h'))
end)

-- Move line(s) up and down (and retain position within line)
vim.keymap.set('n', '<Up>', '<CMD>move-2<CR>==')
vim.keymap.set('v', '<Up>', ":move '<-2<CR>gv=gv")
vim.keymap.set('n', '<Down>', '<CMD>move+<CR>==')
vim.keymap.set('v', '<Down>', ":move '>+1<CR>gv=gv")


vim.opt.number = true
vim.opt.relativenumber = true

vim.o.ignorecase = true

vim.o.hlsearch = false

vim.o.ruler = false
vim.o.laststatus = 0

vim.opt.expandtab = true

vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.opt.textwidth = 79

vim.opt.copyindent = true

vim.opt.swapfile = false

vim.opt.autoread = true

-- Sane splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Permanent undo
vim.opt.undodir = vim.fn.expand('~/.vimdid')
vim.opt.undofile = true

-- Synchronize with system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Don't allow selecting past the end of the line in visual mode
vim.opt.selection = 'old'
