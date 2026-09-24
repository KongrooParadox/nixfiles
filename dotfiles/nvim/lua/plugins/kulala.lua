return
{
  "mistweaverco/kulala.nvim",
  -- Load before session save/restore so VimLeavePre and SessionLoadPost hooks are registered.
  event = { "SessionLoadPost", "VimLeavePre" },
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
  },
  -- See opts.lsp.enforce_external_script_naming_convention
  -- to restrict LSP capabilities to *.http, *.http.js, *.http.ts and *.http.lua files.
  ft = { "http", "rest", "javascript", "lua" },
  opts = {
    kulala_core = {
      path = "/etc/profiles/per-user/robot/bin/kulala-core",
      -- Subprocess timeout (ms) for kulala-core.
      -- Default is 60000 (1 minute).
      -- 0 disables the vim.system timeout.
      timeout = 60000,
    },
    lsp = {
      ---enable/disable built-in LSP server
      ---@type boolean
      enable = true,

      ---filetypes to attach Kulala LSP to
      ---@type string[]
      filetypes = {
        "http",
        "rest",
        "javascript",
        "typescript",
        "lua",
      },

      ---Only scripts ending in *.http.js, *.http.ts and *.http.lua will be treated as HTTP scripts and
      ---have LSP capabilities, unless `enforce_external_script_naming_convention` is set to false.
      ---This allows users to have non-HTTP scripts with the same filetypes without LSP interference.
      ---@type boolean
      enforce_external_script_naming_convention = true,

      --enable/disable/customize  LSP keymaps
      ---@type boolean|table
      keymaps = false, -- disabled by default, as Kulala relies on default Neovim LSP keymaps

      on_attach = nil, -- function called when Kulala LSP attaches to the buffer
    },
    ---@type boolean|table
    global_keymaps = true,
    --[[
    {
      ["Send request"] = { -- sets global mapping
        "<leader>Rs",
        function() require("kulala").run() end,
        mode = { "n", "v" }, -- optional mode, default is n
        desc = "Send request" -- optional description, otherwise inferred from the key
      },
      ["Send all requests"] = {
        "<leader>Ra",
        function() require("kulala").run_all() end,
        mode = { "n", "v" },
        ft = "http", -- sets mapping for *.http files only
      },
      ["Replay the last request"] = {
        "<leader>Rr",
        function() require("kulala").replay() end,
        ft = { "http", "rest" }, -- sets mapping for specified file types
      },
    ["Find request"] = false -- set to false to disable
    },
  ]]

    -- Prefix for global keymaps
    global_keymaps_prefix = "<leader>R",
  },
}
