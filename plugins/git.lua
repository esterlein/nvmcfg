return {
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
	{
		'kdheepak/lazygit.nvim',
		lazy = true,
		cmd = {
			'LazyGit',
			'LazyGitConfig',
			'LazyGitCurrentFile',
			'LazyGitFilter',
			'LazyGitFilterCurrentFile',
		},
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		keys = {
			{ '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
		},
	},
}
