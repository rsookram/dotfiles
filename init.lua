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
  'rsookram/monokaikai.vim',
  'ibhagwan/fzf-lua',
  'lewis6991/gitsigns.nvim',
})

-- Plugin settings

local fzf_actions = require("fzf-lua.actions")
require('fzf-lua').setup{
  winopts = { backdrop = 100 }, -- disable scrim
  keymap = {
    fzf = { ['ctrl-q'] = 'select-all+accept' },
  },
  files = { previewer = 'false' },
}

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
-- noselect: Do not select, force user to select one from the menu
-- fuzzy: more flexible matching
vim.opt.completeopt = { 'menuone', 'noselect', 'fuzzy' }

-- Limit height (default is available screen height)
vim.opt.pumheight = 12

-- Configure LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'grr', require('fzf-lua').lsp_references, opts)
    vim.keymap.set('n', 'gO', require('fzf-lua').lsp_document_symbols, opts)

    vim.keymap.set('n', '<leader>p', function() vim.api.nvim_echo({{'use `<C-s>` in insert mode instead'}}, false, {}) end, opts)
    vim.keymap.set('n', 'gh', function() vim.api.nvim_echo({{'use `<C-w>d` instead'}}, false, {}) end, opts)
    vim.keymap.set({'n', 'v'}, '<leader>.', function() vim.api.nvim_echo({{'use `gra` instead'}}, false, {}) end, opts)
    vim.keymap.set('n', '<leader>6', function() vim.api.nvim_echo({{'use `grn` instead'}}, false, {}) end, opts)
    vim.keymap.set('n', '<leader>G', function() vim.api.nvim_echo({{'use `grr` instead'}}, false, {}) end, opts)
    vim.keymap.set('n', '<leader>o', function() vim.api.nvim_echo({{'use `gO` instead'}}, false, {}) end, opts)

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end,
    })

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.lsp.config.rust_analyzer = {
  cmd = { 'rust-analyzer' },
  root_markers = { 'Cargo.toml', 'Cargo.lock' },
  filetypes = { 'rust' },
  settings = {
    cargo = { features = 'all' },
    check = { command = 'clippy' },
    completion = {
      postfix = { enable = false },
    },
  },
}

vim.lsp.enable({'rust_analyzer'})

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

-- Treat a wrapped line as multiple lines
vim.keymap.set({'n', 'v'}, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({'n', 'v'}, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

vim.keymap.set('n', '<leader>f', require('fzf-lua').live_grep)
vim.keymap.set('n', '<leader>g', require('fzf-lua').grep_cword)
vim.keymap.set('n', '<leader>r', require('fzf-lua').files)

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
