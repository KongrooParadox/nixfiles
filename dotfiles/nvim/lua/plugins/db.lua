return {
  { "kristijanhusak/vim-dadbod-completion", event = "VeryLazy" },
  {
    "tpope/vim-dadbod",
    lazy = true,
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    event = "VeryLazy",
    config = function()
      -- Database connections
      local dbConfFile = vim.fn.stdpath("config") .. "/lua/dbui-servers.lua"
      if vim.fn["filereadable"](dbConfFile) == 1 then
        vim.g.dbs = require("dbui-servers")
      end

      vim.g.db_ui_execute_on_save = 1
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_win_position = "right"
    end,
  },
}
