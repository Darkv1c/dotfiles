-- [[ Leader Key ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Lazy.nvim Bootstrap ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- [[ Plugins ]]
require("lazy").setup({
  -- Telescope (Finder)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = true }
    },
    config = function()
      require('telescope').setup({
        defaults = {
          path_display = { "filename_first" },
        }
      })
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
    end
  },
  -- LSP & Mason (Intelligence, Linters & Errors)
    {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      -- Setup Mason (The installer) - Solo una vez
      require('mason').setup()
      -- Setup Mason-LSPConfig (Automation)
      require('mason-lspconfig').setup({
        ensure_installed = { "lua_ls" },
        handlers = {
          function(server_name)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig')[server_name].setup({
              capabilities = capabilities,
            })
          end,
          ["lua_ls"] = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig').lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = { 'vim' } },
                },
              },
            })
          end,
        },
      })
    end
  },
  -- Autocompletion (Cmp)
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip'
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  },
{
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    vim.g.copilot_no_tab_map = true -- Disable default Tab mapping
    vim.g.copilot_assume_mapped = true -- Assume Tab is already mapped
    vim.g.copilot_tab_expands = true -- Allow expanding suggestions with Tab
  end
}
})

-- [[ UI Settings ]]
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })

-- [[ General Options ]]
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.list = true
vim.o.confirm = true

-- Sync clipboard after UIEnter to reduce startup time
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- [[ Keymaps ]]
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
-- Window navigation
vim.keymap.set({ 't', 'i' }, '<leader>h', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<leader>j', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<leader>k', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<leader>l', '<C-\\><C-n><C-w>l')
vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true })
-- Custom mappings
vim.keymap.set('n', 'ñ', ';', { noremap = true })
-- Diagnostics (errors and warnings)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic message (float)' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list (loclist)' })
-- Copilot
-- Accept Copilot suggestion with <leader><leader>
vim.keymap.set('i', '<leader><leader>', 'copilot#Accept()', {
  expr = true,
  silent = true,
  replace_keycodes = false,
})

-- Next suggestion with <leader><Tab>
vim.keymap.set('i', '<leader><Tab>', 'copilot#Next()', {
  expr = true,
  silent = true,
  replace_keycodes = false,
})

-- Previous suggestion with <leader><S-Tab>
vim.keymap.set('i', '<leader><S-Tab>', 'copilot#Previous()', {
  expr = true,
  silent = true,
  replace_keycodes = false,
})

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ User Commands ]]
vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.')
  local filename = vim.api.nvim_buf_get_name(0)
  print(vim.fn.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }))
end, { desc = 'Print the git blame for the current line' })

-- [[ Optional Packages ]]
vim.cmd('packadd! nohlsearch')
