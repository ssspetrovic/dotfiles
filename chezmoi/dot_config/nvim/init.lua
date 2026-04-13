-- ~/.config/nvim/init.lua

-- ── basic settings ────────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.mapleader = " "

-- ── bootstrap lazy.nvim ───────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- ── plugins ───────────────────────────────────────────────────────────────────
require("lazy").setup({

  -- file explorer
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>n", ":NvimTreeToggle<CR>")
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end,
  },

  -- fuzzy finder (replaces fzf)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>f", builtin.find_files)
      vim.keymap.set("n", "<leader>g", builtin.live_grep)
      vim.keymap.set("n", "<leader>b", builtin.buffers)
    end,
  },

  -- treesitter (better syntax)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "bash",
          "yaml",
          "json",
          "java",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- git
  { "tpope/vim-fugitive" },

  -- autopairs
  {
    "windwp/nvim-autopairs",
    config = true,
  },

  -- LSP (basic, extend later)
  {
    "neovim/nvim-lspconfig",
  },

  -- autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },

  -- IMAGE SUPPORT
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- or "ueberzug"
    },
  },

})

-- ── keymaps (extra) ───────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
