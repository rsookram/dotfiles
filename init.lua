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
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
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
      'nvim-telescope/telescope-ui-select.nvim',
      'rsookram/telescope-recent-files',
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  'tpope/vim-fugitive',
  'lewis6991/gitsigns.nvim',

  'fatih/vim-go',
  'rust-lang/rust.vim',
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
      find_command = { "fd", "--hidden", "--type", "f", "--strip-cwd-prefix", "--glob", "", "--exclude", ".git/" },
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

-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'go', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'bash', 'java', 'lua' },

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        node_incremental = 'v',
        node_decremental = '<c-v>',
      },
    },
  }
end, 0)

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set('n', l, r, opts)
    end

    map('[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function()
        gs.prev_hunk()
        vim.api.nvim_feedkeys("zz", "n", false)
      end)
      return '<Ignore>'
    end, {expr=true})

    map(']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function()
        gs.next_hunk()
        vim.api.nvim_feedkeys("zz", "n", false)
      end)
      return '<Ignore>'
    end, {expr=true})

    map('<leader>u', gs.reset_hunk)
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
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>p', '<CMD>lua vim.lsp.buf.signature_help()<CR>', opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gh', '<CMD>lua vim.diagnostic.open_float()<CR>', opts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

nvim_lsp.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

nvim_lsp.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

nvim_lsp.ruff_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

nvim_lsp.rust_analyzer.setup({
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        features = 'all',
      },
      check = {
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

-- vim-go
-- This is done through LSP instead
vim.g.go_doc_keywordprg_enabled = 0

-- rust.vim
vim.g.rustfmt_autosave = 1

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
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 400 }
  end,
})

-- jump to last edit position on opening file
vim.api.nvim_create_autocmd(
	'BufReadPost',
	{
		pattern = '*',
		callback = function(ev)
			if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
				-- except for in git commit messages
				-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
				if not vim.fn.expand('%:p'):find('.git', 1, true) then
					vim.cmd('exe "normal! g\'\\""')
				end
			end
		end
	}
)

-- Key bindings

-- Go to the first non-whitespace character of the line more easily
vim.keymap.set({ 'n', 'v' }, '0', '^')

-- Treat long lines as break lines
vim.keymap.set({'n', 'v'}, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({'n', 'v'}, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

vim.keymap.set('n', '<leader>e', function()
  require('telescope').extensions.recent_files.pick(require('telescope.themes').get_dropdown {
    previewer = false,
  })
end)

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
vim.keymap.set('n', '<leader>O', require('telescope.builtin').lsp_workspace_symbols)

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

-- Yank relative file path of current buffer
vim.keymap.set('n', '<leader>y', function()
  vim.fn.setreg('+', vim.fn.expand('%'))
end)

-- Open netrw in the directory containing the current file
vim.keymap.set('n', '<leader><Up>', function()
  vim.cmd.edit(vim.fn.expand('%:h'))
end)

-- Run last external command
vim.keymap.set('n', '<leader><tab>', ':!<Up><CR>')

-- git commands
vim.keymap.set('n', '<leader>b', ':Git blame<CR>')
vim.keymap.set('n', '<leader><leader>g', ':topleft Git<CR>')
vim.keymap.set('n', '<leader><leader>i', ':topleft Git add -i<CR>')
vim.keymap.set('n', '<leader><leader>p', ':topleft Git add -p * .*<CR>')
vim.keymap.set('n', '<leader><leader>l', ':topleft Git log --abbrev-commit --decorate=short<CR>')
vim.keymap.set('n', '<leader><leader>c', ':tab Git commit -v<CR>')
vim.keymap.set('n', '<leader><leader>d', ':tab Git diff --patience --find-renames --patch-with-stat<CR>')

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
