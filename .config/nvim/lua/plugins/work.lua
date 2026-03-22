-- Work profile plugins (JavaScript, TypeScript, Node.js)
-- Activate with: NVIM_PROFILE=work nvim

return {
	-- Treesitter parsers for React/Web development
	{
		"nvim-treesitter/nvim-treesitter",
		init = function()
			-- Register additional parsers for work profile
			-- core.lua's config will pick these up via vim.g.treesitter_extra_parsers
			vim.g.treesitter_extra_parsers = {
				"javascript", "typescript", "tsx",
				"html", "css", "scss",
				"json", "graphql",
			}
		end,
	},

	-- Auto close and rename HTML/JSX tags
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "xml" },
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		},
	},

	-- TypeScript/JavaScript LSP additional support
	{
		"pmizio/typescript-tools.nvim",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("typescript-tools").setup({
				capabilities = capabilities,
				settings = {
					separate_diagnostic_server = true,
					publish_diagnostic_on = "insert_leave",
					tsserver_file_preferences = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			})
		end,
	},

	-- Package.json support
	{
		"vuki656/package-info.nvim",
		ft = "json",
		dependencies = { "MunifTanjim/nui.nvim" },
		config = function()
			require("package-info").setup()
		end,
	},

	-- Prettier formatter
	{
		"stevearc/conform.nvim",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "css", "scss", "html" },
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.javascript = { "prettier" }
			opts.formatters_by_ft.javascriptreact = { "prettier" }
			opts.formatters_by_ft.typescript = { "prettier" }
			opts.formatters_by_ft.typescriptreact = { "prettier" }
			opts.formatters_by_ft.json = { "prettier" }
			opts.formatters_by_ft.jsonc = { "prettier" }
			opts.formatters_by_ft.css = { "prettier" }
			opts.formatters_by_ft.scss = { "prettier" }
			opts.formatters_by_ft.html = { "prettier" }
			return opts
		end,
	},

	-- Mason + LSP: ensure React/Web servers and formatters are installed
	{
		"neovim/nvim-lspconfig",
		init = function()
			-- Register extra LSP servers for work profile
			vim.g.mason_extra_servers = { "eslint", "tailwindcss", "jsonls" }
			-- Register extra formatters/tools for work profile
			vim.g.mason_extra_tools = { "prettier" }
		end,
	},
}
