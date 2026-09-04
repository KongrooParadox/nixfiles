return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },
  {
    "numToStr/Comment.nvim",
    config = true,
  },
  {
    "kylechui/nvim-surround",
    config = true,
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "[A]dd file to harpoon list" })
      vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu, { desc = "Edit [H]arpoon list" })
      vim.keymap.set("n", "<C-H>", function()
        ui.nav_file(1)
      end, { desc = "Go to 1st file in harpoon list" })
      vim.keymap.set("n", "<C-J>", function()
        ui.nav_file(2)
      end, { desc = "Go to 2nd file in harpoon list" })
      vim.keymap.set("n", "<C-K>", function()
        ui.nav_file(3)
      end, { desc = "Go to 3rd file in harpoon list" })
      vim.keymap.set("n", "<C-L>", function()
        ui.nav_file(4)
      end, { desc = "Go to 4th file in harpoon list" })
      vim.keymap.set("n", "<C-;>", function()
        ui.nav_file(5)
      end, { desc = "Go to 5th file in harpoon list" })
    end,
  },
  "ThePrimeagen/vim-be-good",
  {
    "folke/zen-mode.nvim",
    config = function()
      vim.keymap.set("n", "<leader>zz", function()
        require("zen-mode").setup({
          window = {
            width = 120,
            options = {},
          },
        })
        require("zen-mode").toggle()
        vim.wo.wrap = false
        vim.wo.number = true
        vim.wo.rnu = true
      end, { desc = "Toggle [Z]en Mode" })
    end,
  },
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle [U]ndotree" })
    end,
  },
  "xiyaowong/virtcolumn.nvim",
  {
    "lucidph3nx/nvim-sops",
    event = { "BufEnter" },
    opts = {
      defaults = {
        ageSshPrivateKeyFile = "~/.ssh/id_ed25519",
      },
      keys = {
        { "<leader>ef", vim.cmd.SopsEncrypt, desc = "[E]ncrypt [F]ile" },
        { "<leader>df", vim.cmd.SopsDecrypt, desc = "[D]ecrypt [F]ile" },
      },
    },
  },
  {                     -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 500,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },

      -- Document existing key chains
      spec = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      },
    },
  },
  {
    "lervag/vimtex",
    dependencies = {
      "let-def/texpresso.vim",
    },
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-lualatex", -- sets lualatex to default engine
      }
      vim.g.vimtex_quickfix_open_on_warning = 0
    end
  },
}
