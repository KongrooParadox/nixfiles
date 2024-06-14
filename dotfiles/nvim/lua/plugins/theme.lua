-- Set colorscheme
vim.o.termguicolors = true

-- local colors = {
--     bg = "#272b30",
--     text = "#afb4c3",
--     strong_text = "#80838f",
--     faded_text = "#686d75",
--     strong_faded_text = "#464b50",
--
--     thin_line = "#2f3337",
--     thick_line = "#73787d",
--
--     popover_bg = "#1f262b",
--     popover_text = "#aaafb4",
--
--     white = "#ffffff",
--     darker_gray = "#2c323c",
--     lighter_gray = "#3e4452",
--
--     -- palette
--     silver = "#acbcc3",
--     cyan = "#7fb2c8",
--     blue = "#81a2be",
--     charcoal = "#708499",
--     teal = "#749689",
--     green = "#bdb968",
--     beige = "#ebd2a7",
--     yellow = "#f0c674",
--     orange = "#de935f",
--     purple = "#b08cba",
--     magenta = "#ff80ff",
--     red = "#cc6666",
-- }
--
return {
--     {
--         "rktjmp/lush.nvim",
--         branch = "main",
--         lazy = false,
--     },
--     {
--         'nvim-lualine/lualine.nvim', -- Fancier statusline
--         config = function()
--             local lualine_theme = {
--                 normal = {
--                     a = { fg = colors.bg, bg = colors.cyan, gui = "bold" },
--                     b = { fg = colors.text, bg = colors.darker_gray },
--                     c = { fg = colors.text, bg = colors.bg },
--                 },
--                 command = { a = { fg = colors.bg, bg = colors.yellow, gui = "bold" } },
--                 insert = { a = { fg = colors.bg, bg = colors.green, gui = "bold" } },
--                 visual = { a = { fg = colors.bg, bg = colors.purple, gui = "bold" } },
--                 terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = "bold" } },
--                 replace = { a = { fg = colors.bg, bg = colors.red, gui = "bold" } },
--                 inactive = {
--                     a = { fg = colors.strong_faded_text, bg = colors.bg, gui = "bold" },
--                     b = { fg = colors.strong_faded_text, bg = colors.bg },
--                     c = { fg = colors.strong_faded_text, bg = colors.bg },
--                 },
--             }
--             local mode = require "lualine.utils.mode"
--             require('lualine').setup {
--                 options = {
--                     icons_enabled = true,
--                     theme = lualine_theme,
--                     component_separators = "",
--                     section_separators = {
--                         left = "",
--                         right = "",
--                     },
--                     disabled_filetypes = {
--                         "NvimTree",
--                         "TelescopePrompt",
--                     },
--                     always_divide_middle = true,
--                     globalstatus = true,
--                 },
--                 sections = {
--                     lualine_a = {
--                         {
--                             function()
--                                 local m = mode.get_mode()
--                                 if m == "NORMAL" then return "N"
--                                 elseif m == "VISUAL" then return "V"
--                                 elseif m == "SELECT" then return "S"
--                                 elseif m == "INSERT" then return "I"
--                                 elseif m == "REPLACE" then return "R"
--                                 elseif m == "COMMAND" then return "C"
--                                 elseif m == "EX" then return "X"
--                                 elseif m == "TERMINAL" then return "T"
--                                 else return m
--                                 end
--                             end,
--                         },
--                     },
--                     lualine_b = {
--                         "diff",
--                         {
--                             "diagnostics",
--                         },
--                         {
--                             "filename",
--                             path = 0,
--                             color = { fg = colors.text, bg = colors.lighter_gray },
--                         },
--                         {
--                             "branch",
--                             color = { fg = colors.text, bg = colors.darker_gray },
--                         },
--                     },
--                     lualine_c = {},
--                     lualine_x = {},
--                     lualine_y = {
--                         "searchcount",
--                         "encoding",
--                         {
--                             "fileformat",
--                             color = { fg = colors.text, bg = colors.lighter_gray },
--                         },
--                         {
--                             "filetype",
--                             colored = true,
--                         },
--                         {
--                             "progress",
--                             color = { fg = colors.text, bg = colors.lighter_gray },
--                         },
--                     },
--                     lualine_z = {
--                         {
--                             "location",
--                             padding = { left = 0, right = 1 },
--                             color = { fg = colors.text, bg = colors.lighter_gray },
--                         },
--                     },
--                 },
--                 inactive_sections = {
--                     lualine_a = {},
--                     lualine_b = { "filename" },
--                     lualine_c = {},
--                     lualine_x = {},
--                     lualine_y = { "location" },
--                     lualine_z = {},
--                 },
--                 tabline = {},
--             }
--         end,
--     },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function ()
            require('rose-pine').setup({
                variant = 'moon',
                disable_float_background = true,
                disable_background = true
            })
            vim.cmd('colorscheme rose-pine')
        end
    },
    'nvim-tree/nvim-web-devicons',
}

