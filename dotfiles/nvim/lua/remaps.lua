require("remaps.telescope")

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
-- Disable arrow keys in normal mode

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[P]aste while keeping previous content" })
-- vim.keymap.set("n", "<leader>p", ':set paste<CR>"*p:set nopaste<CR>' , {desc = '[P]aste optimized for windows'})
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "[D]elete and keep previous content" })
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "[Y]ank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "[Y]ank till end of line to system clipboard" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "Center screen on PageUp" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "Center screen on PageDown" })
vim.keymap.set("n", "n", "nzzzv", { silent = true, desc = "Center screen on search cycling" })
vim.keymap.set("n", "N", "Nzzzv", { silent = true, desc = "Center screen on reverse search cycling" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down & auto-indent" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up & auto-indent" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "No CC for me !" })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "[P]roject [V]iew" })

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Q>", "<Nop>", { silent = true })
vim.keymap.set(
  "n",
  "<leader>x",
  "<cmd>!chmod u+x %<CR>",
  { silent = true, desc = "Add E[X]ecution rights to current file for current user" }
)

vim.keymap.set(
  "n",
  "<C-f>",
  "<cmd>!tmux neww tmux-switcher<CR>",
  { silent = true, desc = "Change current tmux session" }
)
