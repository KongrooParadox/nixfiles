vim.g.have_nerd_font = true

vim.o.list = true
vim.o.showbreak = "↪"
vim.opt.listchars =
  { tab = " ▸", eol = "↲", nbsp = "␣", trail = "~", extends = "⟩", precedes = "⟨", space = "•" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Search settings
vim.o.hlsearch = false
vim.o.incsearch = true

-- Make relative line numbers default
vim.o.relativenumber = true
vim.o.number = true

-- Enable mouse mode
vim.o.mouse = "a"
vim.o.showmode = false

vim.o.smartindent = true
vim.o.breakindent = true
vim.o.wrap = false

-- Save undo history
vim.o.undofile = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "120"

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})
