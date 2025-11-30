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
      vim.g.dbs = {
        local_postgres = "postgres://postgres@localhost:5432/postgres",
        -- TODO : source optional config file to separate db config from neovim config
      }

      vim.g.db_ui_execute_on_save = 1
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_win_position = "right"
    end,
  },
}
