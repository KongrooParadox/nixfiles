-- LSP settings.

return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            {
                'neovim/nvim-lspconfig',
            },
            {
                -- Additional lua configuration, makes nvim stuff amazing
                'folke/neodev.nvim',
                config = true,
                lazy = true,
            },
            {
                -- Automatically install LSPs to stdpath for neovim
                'williamboman/mason.nvim',
                config = true,
            },
            {
                'williamboman/mason-lspconfig.nvim',
            },
            {
                'hrsh7th/nvim-cmp',
                dependencies = {
                    'hrsh7th/cmp-nvim-lsp',
                    'hrsh7th/cmp-nvim-lua',
                    'L3MON4D3/LuaSnip',
                    'saadparwaiz1/cmp_luasnip',
                },
            },
        },
        config = function()
            local lsp = require("lsp-zero").preset({})
            lsp.ensure_installed({
                "ansiblels",
                "bashls",
                "gopls",
                "docker_compose_language_service",
                "dockerls",
                "terraformls",
                "yamlls",
                "rust_analyzer",
                "tsserver",
                "eslint",
                "lua_ls"
            })

            require("lspconfig").ansiblels.setup {
                filetypes = {
                    "yaml.ansible"
                },
                settings = {
                    ansible = {
                        ansible = {
                            path = "ansible",
                            useFullyQualifiedCollectionNames = true
                        },
                        ansibleLint = {
                            enabled = true,
                            path = "ansible-lint"
                        },
                        executionEnvironment = {
                            enabled = false
                        },
                        python = {
                            interpreterPath = "python3"
                        },
                        completion = {
                            provideRedirectModules = true,
                            provideModuleOptionAliases = true
                        }
                    },
                },
            }
            require("neodev").setup()
            lsp.nvim_workspace()

            local cmp = require('cmp')
            local cmp_select = {behavior = cmp.SelectBehavior.Select}
            local cmp_mappings = lsp.defaults.cmp_mappings({
                ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            })

            lsp.setup_nvim_cmp({
                mapping = cmp_mappings
            })

            -- This function gets run when an LSP connects to a particular buffer.
            lsp.on_attach(function(client, bufnr)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, remap = false, desc = 'LSP: [R]e[n]ame' })
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, remap = false, desc = 'LSP: [C]ode [A]ction' })
                vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { buffer = bufnr, remap = false, desc = 'LSP: Diagnostics [O]pen [F]loat' })
                vim.keymap.set('n', '[d', vim.diagnostic.goto_next, { buffer = bufnr, remap = false, desc = 'LSP: Diagnostics Next' })
                vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, { buffer = bufnr, remap = false, desc = 'LSP: Diagnostics Previous' })

                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, remap = false, desc ='LSP: [G]oto [D]efinition' })
                vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { buffer = bufnr, remap = false, desc ='LSP: [G]oto [R]eferences' })
                vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { buffer = bufnr, remap = false, desc = 'LSP: [G]oto [I]mplementation' })
                vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { buffer = bufnr, remap = false, desc = 'LSP: Type [D]efinition' })
                vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, { buffer = bufnr, remap = false, desc = 'LSP: [D]ocument [S]ymbols' })
                vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, { buffer = bufnr, remap = false, desc = 'LSP: [W]orkspace [S]ymbols' })
                vim.keymap.set("n", "<leader>f", function()
                    vim.lsp.buf.format()
                end, { buffer = bufnr, remap = false, desc = 'LSP: [F]ormat Current Buffer' })

                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, remap = false, desc = 'LSP: Hover Documentation' })
                vim.keymap.set('n', '<leader>K', vim.lsp.buf.signature_help, { buffer = bufnr, remap = false, desc = 'LSP: Signature Documentation' })

                -- Lesser used LSP functionality
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, remap = false, desc = 'LSP: [G]oto [D]eclaration' })
                vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr, remap = false, desc = 'LSP: [W]orkspace [A]dd Folder' })
                vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr, remap = false, desc = 'LSP: [W]orkspace [R]emove Folder' })
                vim.keymap.set('n', '<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, { buffer = bufnr, remap = false, desc = 'LSP: [W]orkspace [L]ist Folders' })
            end)

            require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

            lsp.setup()
        end
    },
    {
        'jay-babu/mason-nvim-dap.nvim',
        cmd = { 'DapInstall', 'DapUninstall' },
        opts = {
            automatic_installation = true,
            handlers = {},
            ensure_installed = {
                'codelldb',
            },
        }
    },
    {
        'mfussenegger/nvim-ansible'
    }
}
