return {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
        { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
    branch = 'v2.x',
    init = function()
        vim.g.neo_tree_remove_legacy_commands = 1
    end,
    config = {
        event_handlers = {
            {
                event = "file_opened",
                handler = function()
                    --auto close
                    require("neo-tree").close_all()
                end
            },
        }
    }
}
