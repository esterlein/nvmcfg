return {

	-- detect tabstop and shiftwidth
	'tpope/vim-sleuth',

	{
		'lewis6991/gitsigns.nvim',
		opts = {
			signs = {
				add = { text = '+' },
				change = { text = '~' },
				delete = { text = '_' },
				topdelete = { text = '‾' },
				changedelete = { text = '~' },
			},
		},
	},

	-- pending keybind

	{
		'folke/which-key.nvim',
		event = 'VimEnter',
		opts = {
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = '<Up> ',
					Down = '<Down> ',
					Left = '<Left> ',
					Right = '<Right> ',
					C = '<C-…> ',
					M = '<M-…> ',
					D = '<D-…> ',
					S = '<S-…> ',
					CR = '<CR> ',
					Esc = '<Esc> ',
					ScrollWheelDown = '<ScrollWheelDown> ',
					ScrollWheelUp = '<ScrollWheelUp> ',
					NL = '<NL> ',
					BS = '<BS> ',
					Space = '<Space> ',
					Tab = '<Tab> ',
					F1 = '<F1>',
					F2 = '<F2>',
					F3 = '<F3>',
					F4 = '<F4>',
					F5 = '<F5>',
					F6 = '<F6>',
					F7 = '<F7>',
					F8 = '<F8>',
					F9 = '<F9>',
					F10 = '<F10>',
					F11 = '<F11>',
					F12 = '<F12>',
				},
			},
			spec = {
				{ '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
				{ '<leader>d', group = '[D]ocument' },
				{ '<leader>r', group = '[R]ename' },
				{ '<leader>s', group = '[S]earch' },
				{ '<leader>w', group = '[W]orkspace' },
				{ '<leader>t', group = '[T]oggle' },
				{ '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
			},
		},
	},

	-- [[ lsp plugins ]]

	{
		'folke/lazydev.nvim',
		ft = 'lua',
		opts = {
			library = {
				{ path = 'luvit-meta/library', words = { 'vim%.uv' } },
			},
		},
	},
	{ 'Bilal2453/luvit-meta', lazy = true },
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'williamboman/mason.nvim', config = true },
			'williamboman/mason-lspconfig.nvim',
			'WhoIsSethDaniel/mason-tool-installer.nvim',
			{ 'j-hui/fidget.nvim', opts = {} },
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or 'n'
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
					end

					map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
					map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
					map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
					map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
					map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
					map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
					map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
					map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
					map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

					-- autocommands to highlight word under cursor hold :help CursorHold

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
						vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd('LspDetach', {
							group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
							end,
						})
					end

					-- keymap to toggle inlay hints in code

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map('<leader>th', function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
						end, '[T]oggle Inlay [H]ints')
					end
				end,
			})

			-- create new LSP capabilities with nvim cmp

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

			-- :help lspconfig-all

			local servers = {
				clangd = {},
				pyright = {},
				rust_analyzer = {},
				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = 'Replace',
							},
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			require('mason').setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				'stylua',
			})

			require('mason-tool-installer').setup { ensure_installed = ensure_installed }

			require('mason-lspconfig').setup {
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
						require('lspconfig')[server_name].setup(server)
					end,
				},
			}
		end,
	},

	-- autoformat

	{
		'stevearc/conform.nvim',
		event = { 'BufWritePre' },
		cmd = { 'ConformInfo' },
		keys = {
			{
				'<leader>f',
				function()
					require('conform').format { async = true, lsp_format = 'fallback' }
				end,
				mode = '',
				desc = '[F]ormat buffer',
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = 'never'
				else
					lsp_format_opt = 'fallback'
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { 'stylua' },
				python = { 'isort', 'black' },
			},
		},
	},

	-- autocompletion

	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {

			-- snippet engine

			{
				'L3MON4D3/LuaSnip',
				build = (function()
					if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
						return
					end
					return 'make install_jsregexp'
				end)(),
				dependencies = {
					{
						'rafamadriz/friendly-snippets',
						config = function()
							require('luasnip.loaders.from_vscode').lazy_load()
						end,
					},
				},
			},
			'saadparwaiz1/cmp_luasnip',

			-- :help cmp

			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
		},
		config = function()
			local cmp = require 'cmp'
			local luasnip = require 'luasnip'
			luasnip.config.setup {}

			cmp.setup {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = 'menu,menuone,noinsert' },

				-- :help ins-completion

				mapping = cmp.mapping.preset.insert {
					['<C-n>'] = cmp.mapping.select_next_item(),
					['<C-p>'] = cmp.mapping.select_prev_item(),
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),

					['<C-y>'] = cmp.mapping.confirm { select = true },

					--['<CR>'] = cmp.mapping.confirm { select = true },
					--['<Tab>'] = cmp.mapping.select_next_item(),
					--['<S-Tab>'] = cmp.mapping.select_prev_item(),

					['<C-Space>'] = cmp.mapping.complete {},

					['<C-l>'] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { 'i', 's' }),
					['<C-h>'] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { 'i', 's' }),
				},

				sources = {
					{
						name = 'lazydev',
						group_index = 0,
					},
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'path' },
				},
			}
		end,
	},

	{
		'echasnovski/mini.nvim',
		config = function()
			-- around/inside textobjects
			-- va)  - [V]isually select [A]round [)]paren
			-- yinq - [Y]ank [I]nside [N]ext [Q]uote
			-- ci'  - [C]hange [I]nside [']quote
			require('mini.ai').setup { n_lines = 500 }
			-- add/delete/replace surroundings
			-- saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- sd'	 - [S]urround [D]elete [']quotes
			-- sr)'  - [S]urround [R]eplace [)] [']
			require('mini.surround').setup()
			local statusline = require 'mini.statusline'
			statusline.setup { use_icons = vim.g.have_nerd_font }

			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return '%2l:%-2v'
			end
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		main = 'nvim-treesitter.configs',
		opts = {
			ensure_installed = {
				'bash',
				'c',
				'diff',
				'html',
				'lua',
				'luadoc',
				'markdown',
				'markdown_inline',
				'query',
				'vim',
				'vimdoc',
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { 'ruby' },
			},
			indent = { enable = true, disable = { 'ruby' } },
		},
	},

	-- help: lazy.nvim-lazy.nvim-structuring-your-plugins
	-- { import = 'custom.plugins' },
}
