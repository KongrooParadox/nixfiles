vim.opt.list = true
vim.opt.showbreak = "↪"
vim.opt.listchars = { tab=" ▸", eol="↲", nbsp="␣", trail="~", extends="⟩", precedes="⟨", space="•"}

-- Search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Make relative line numbers default
vim.opt.relativenumber = true
vim.opt.number = true

-- Enable mouse mode
vim.opt.mouse = 'a'

vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.wrap = false

-- Save undo history
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.updatetime = 50
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = "120"

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

