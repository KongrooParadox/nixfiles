-- Set colorscheme
vim.o.termguicolors = true

local function enableTransparency()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.cmd('hi Directory guibg=NONE')
  vim.cmd('hi SignColumn guibg=NONE')
end

return {
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
    config = function()
      vim.cmd('hi Directory guibg=NONE')
      vim.cmd('hi SignColumn guibg=NONE')
      vim.cmd([[colorscheme nord ]])
      enableTransparency()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = true,
        theme = "nord",
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
    },
  },
  { -- Show CSS Colors
    'brenoprata10/nvim-highlight-colors',
    opts = {},
  },
}
