return {

	-- colorscheme
	{
		'catppuccin/nvim',
		name = 'catppuccin',
		priority = 1000,
		config = function()
			-- catppuccin-latte catppuccin-frappe catppuccin-macchiato catppuccin-mocha
			vim.cmd.colorscheme 'catppuccin-mocha'
		end,
	},

	-- highligh special comments
	{
		'folke/todo-comments.nvim',
		event = 'VimEnter',
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = { signs = false },
	},
}
