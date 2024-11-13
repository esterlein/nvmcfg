return {
	{
		'nvim-neo-tree/neo-tree.nvim',
		opts = {
			window = {
				position = 'left',
				width = 20,
			},
			filesystem = {
				filtered_items = {
					visible = true,
					show_hidden_count = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
			close_if_last_window = true,
		},
		branch = 'v3.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
			'MunifTanjim/nui.nvim',
			--'3rd/image.nvim',
		},
	},
}
