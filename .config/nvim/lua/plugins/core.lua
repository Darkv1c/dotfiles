return {
	-- cmd line
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				"rcarriga/nvim-notify",
				opts = {
					background_colour = "#000000",
				},
			},
		},
		opts = {
			presets = {
				command_palette = true,
				bottom_search = false,
				long_message_to_split = true,
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
		},
	},
	
	-- Yazi: File Manager and Note-Taking
	{
		"mikavilpas/yazi.nvim",
		lazy = false,
		keys = {
			{
				"<leader>-",
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>y",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
		},
		opts = {
			open_for_directories = false,
		},
	},

	-- Cursor animation
	{
		"sphamba/smear-cursor.nvim",
		opts = {},
	},
	
	-- Treesitter (Syntax Highlighting, Indentation)
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})
			-- Install base parsers
			local parsers = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "bash" }
			-- Merge extra parsers from profiles (e.g. work.lua sets vim.g.treesitter_extra_parsers)
			local extra = vim.g.treesitter_extra_parsers
			if extra then
				for _, p in ipairs(extra) do
					table.insert(parsers, p)
				end
			end
			require("nvim-treesitter").install(parsers)
			-- Enable treesitter highlighting for all supported filetypes
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Telescope (Finder)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-tree/nvim-web-devicons", enabled = true },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					path_display = { "filename_first" },
					file_ignore_patterns = { "node_modules" },
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				},
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
		end,
	},

	-- Toggleable terminal
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{ "<leader>tt", function()
				local zoomed = Snacks.zen.win and Snacks.zen.win:valid()
				if zoomed then
					Snacks.zen.zoom()
				end
				vim.cmd("ToggleTerm")
				if not zoomed then
					vim.defer_fn(function()
						if vim.bo.buftype == "terminal" then
							Snacks.zen.zoom()
							vim.cmd("redraw!")
						end
					end, 100)
				end
			end, mode = { "n", "t" }, desc = "Toggle terminal" },
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating terminal" },
			{ "<leader>r", function()
				local file = vim.fn.expand("%:p")
				if file == "" then return end
				local shebang = vim.fn.readfile(file, "", 1)[1]
				local cmd
				if shebang and shebang:match("^#!") then
					cmd = file
				else
					local ft = vim.bo.filetype
					local runners = { sh = "bash", python = "python3", lua = "lua", javascript = "node", typescript = "node" }
					cmd = (runners[ft] or "bash") .. " " .. file
				end
				vim.cmd("TermExec direction=float cmd='" .. cmd:gsub("'", "'\\''") .. "'")
			end, desc = "Run current file (float)" },
		},
		opts = {
			size = 12,
			on_create = function()
			end,
		},
	},

	-- LSP & Mason (Intelligence, Linters & Errors)
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Setup Mason (The installer)
			require("mason").setup()
			-- Build ensure_installed list from base + profile extras
			local ensure_installed = { "lua_ls", "bashls" }
			local extra_servers = vim.g.mason_extra_servers
			if extra_servers then
				for _, s in ipairs(extra_servers) do
					table.insert(ensure_installed, s)
				end
			end
			-- Setup Mason-LSPConfig (Automation)
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			-- Servers managed externally (e.g. nvim-jdtls manages jdtls)
			local external_servers = vim.g.mason_external_servers or {}
			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				handlers = {
					function(server_name)
						-- Skip servers managed by dedicated plugins
						for _, ext in ipairs(external_servers) do
							if server_name == ext then return end
						end
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,
					["lua_ls"] = function()
						require("lspconfig").lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = { globals = { "vim" } },
								},
							},
						})
					end,
					["eslint"] = function()
						require("lspconfig").eslint.setup({
							capabilities = capabilities,
							on_attach = function(_, bufnr)
								vim.api.nvim_create_autocmd("BufWritePre", {
									buffer = bufnr,
									command = "EslintFixAll",
								})
							end,
						})
					end,
					["jsonls"] = function()
						require("lspconfig").jsonls.setup({
							capabilities = capabilities,
							settings = {
								json = {
									schemas = require("lspconfig").util.default_config
											and require("lspconfig").util.default_config.settings
											and require("lspconfig").util.default_config.settings.json
											and require("lspconfig").util.default_config.settings.json.schemas
										or {},
									validate = { enable = true },
								},
							},
						})
					end,
				},
			})
			-- Install formatters via Mason
			local ensure_tools = { "stylua", "black", "isort", "shfmt" }
			local extra_tools = vim.g.mason_extra_tools
			if extra_tools then
				for _, t in ipairs(extra_tools) do
					table.insert(ensure_tools, t)
				end
			end
			local mr = require("mason-registry")
			for _, tool in ipairs(ensure_tools) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
		end,
	},

	-- Autocompletion (Cmp)
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-l>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Disable Copilot ghost text when cmp menu is visible
			cmp.event:on("menu_opened", function()
				vim.b.copilot_suggestion_hidden = true
			end)
			cmp.event:on("menu_closed", function()
				vim.b.copilot_suggestion_hidden = false
			end)
		end,
	},

	-- Copilot
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = function()
			vim.g.copilot_no_tab_map = true -- Disable default Tab mapping
			vim.g.copilot_assume_mapped = true -- Assume Tab is already mapped
		end,
	},

	-- Opencode
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			{
				"folke/snacks.nvim",
				opts = {
					input = {},
					picker = {},
					terminal = {},
				},
			},
		},
		config = function()
			local opencode_cmd = "opencode --port"
			local snacks_terminal_opts = {
				win = {
					position = "right",
					enter = false,
					keys = {
						term_normal = false,
					},
				},
			}

			local function zoom_term(term)
				if term then
					vim.defer_fn(function()
						term:focus()
						Snacks.zen.zoom()
						vim.cmd("redraw!")
					end, 100)
				end
			end

			vim.g.opencode_opts = {
				server = {
			start = function()
							require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
						end,
				},
			}

			local orig_prompt = require("opencode.api.prompt").prompt
			require("opencode.api.prompt").prompt = function(prompt_text, context)
				return orig_prompt(prompt_text, context):next(function()
					vim.schedule(function()
						local term = require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts)
						if term and term:valid() then
							term:show()
							term:focus()
							Snacks.zen.zoom()
							vim.cmd("redraw!")
						end
					end)
				end)
			end

			vim.opt.autoread = true

			vim.keymap.set("n", "<leader>ot", function()
				local term = require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts)
				local zoomed = Snacks.zen.win and Snacks.zen.win:valid()
				if term:valid() then
					if zoomed then
						Snacks.zen.zoom()
						vim.defer_fn(function()
							term:hide()
							vim.cmd("redraw!")
						end, 50)
					else
						term:hide()
					end
				else
					term:show()
					vim.defer_fn(function()
						term:focus()
						Snacks.zen.zoom()
						vim.cmd("redraw!")
					end, 100)
				end
			end, { desc = "Toggle OpenCode terminal" })

			vim.keymap.set({ "n", "x" }, "<leader>oa",
				function() require("opencode").ask("@this: ") end,
				{ desc = "Ask OpenCode" })

			vim.keymap.set({ "n", "x" }, "<leader>os",
				function() require("opencode").select() end,
				{ desc = "Select OpenCode action" })

			vim.keymap.set({ "n", "x" }, "<leader>o+",
				function() require("opencode").prompt("@this") end,
				{ desc = "Add this to context" })

			vim.keymap.set("n", "<leader>on",
				function() require("opencode").command("session.new") end,
				{ desc = "New session" })

			vim.keymap.set("n", "<leader>oi",
				function() require("opencode").command("session.interrupt") end,
				{ desc = "Interrupt session" })

			vim.keymap.set("n", "<leader>oA",
				function() require("opencode").command("agent.cycle") end,
				{ desc = "Cycle agent" })

			vim.keymap.set("n", "<S-C-u>",
				function() require("opencode").command("session.half.page.up") end,
				{ desc = "Scroll up" })

			vim.keymap.set("n", "<S-C-d>",
				function() require("opencode").command("session.half.page.down") end,
				{ desc = "Scroll down" })

			vim.keymap.set("n", "<leader>zz", Snacks.zen.zoom,
				{ desc = "Toggle full screen" })
		end,
	},

	-- Firenvim (Neovim in browser)
	{
		"glacambre/firenvim",
		lazy = not vim.g.started_by_firenvim,
		build = ":call firenvim#install(0)",
		config = function()
			vim.g.firenvim_config = {
				globalSettings = {
					alt = "all",
				},
				localSettings = {
					[".*"] = {
						cmdline = "neovim",
						content = "text",
						priority = 0,
						selector = "textarea",
						takeover = "never",
					},
				},
			}
		end,
	},

	-- Conform (Code Formatter)
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"<leader>f",
				function() require("conform").format({ async = true, lsp_fallback = true }) end,
				mode = { "n", "v" },
				desc = "Format buffer with conform",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black", "isort", stop_after_first = true },
				sh = { "shfmt" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				vue = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
			},
		formatters = {
			shfmt = {
				args = { "-i", "2" },
			},
		},
		default_format_opts = {
			lsp_fallback = true,
		},
			format_after_save = function(bufnr)
				local ignore_filetypes = { "sql", "java" }
				if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
					return
				end
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { lsp_format = "fallback" }
			end,
		},
	},

	-- Diffview (Git diffs and history)
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open git diff view" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repository history" },
			{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close git diff view" },
		},
		opts = {},
	},

	-- render markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		ft = { "markdown" },
		opts = {},
	},
}
