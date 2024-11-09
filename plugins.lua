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
}
