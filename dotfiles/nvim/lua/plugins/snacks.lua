return {
  "folke/snacks.nvim",
  tag = "v2.31.0",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>gIo",      function() Snacks.picker.gh_issue() end,                  desc = "GitHub Issues (open)" },
    { "<leader>gIa",      function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
    { "<leader>gp",       function() Snacks.picker.gh_pr() end,                     desc = "GitHub Pull Requests (open)" },
    { "<leader>gP",       function() Snacks.picker.gh_pr({ state = "all" }) end,    desc = "GitHub Pull Requests (all)" },
    { "<leader>.",        function() Snacks.scratch() end,                          desc = "Toggle Scratch Buffer" },
    { "<leader>S",        function() Snacks.scratch.select() end,                   desc = "Select Scratch Buffer" },
    { "<C-p>",            function() Snacks.picker.git_files() end,                 desc = "[G]it [F]iles" },
    { "<leader>sh",       function() Snacks.picker.help() end,                      desc = "[S]earch [H]elp" },
    { "<leader>sk",       function() Snacks.picker.keymaps() end,                   desc = "[S]earch [K]eymaps" },
    { "<leader>sf",       function() Snacks.picker.files() end,                     desc = "[S]earch [F]iles" },
    { "<leader>ss",       function() Snacks.picker.builtin() end,                   desc = "[S]earch [S]elect Telescope" },
    { "<leader>sg",       function() Snacks.picker.grep() end,                      desc = "[S]earch by [G]rep" },
    { "<leader>sb",       function() Snacks.picker.grep_buffers() end,              desc = "[S]earch by Grep open [B]uffers" },
    { "<leader>sw",       function() Snacks.picker.grep_word() end,                 desc = "[S]earch current [W]ord",        mode = { "n", "x" } },
    { "<leader>sd",       function() Snacks.picker.diagnostics() end,               desc = "[S]earch [D]iagnostics" },
    { "<leader>sD",       function() Snacks.picker.diagnostics_buffer() end,        desc = "[S]earch [D]iagnostics Buffer" },
    { "<leader>sq",       function() Snacks.picker.qflist() end,                    desc = "[S]earch [Q]uickfix List" },
    { "<leader>sr",       function() Snacks.picker.resume() end,                    desc = "[S]earch [R]esume" },
    { "<leader><leader>", function() Snacks.picker.buffers() end,                   desc = "[ ] Find existing buffers" },
    {
      "<leader>sn",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") --, follow = true
        })
      end,
      desc = "[S]earch [N]eovim files"
    },
  },
  ---@type snacks.Config
  opts = {
    gh = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    scratch = { enabled = true },
  },
}
