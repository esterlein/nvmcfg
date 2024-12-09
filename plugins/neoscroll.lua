return {
	'karb94/neoscroll.nvim',
	opts = {},

	config = function()
		local neoscroll = require 'neoscroll'

		neoscroll.setup {
			mappings = {},
		}

		local keymap = {
			['<C-d>'] = function()
				neoscroll.scroll(10, {
					move_cursor = true,
					duration = 100,
				})
			end,
			['<C-k>'] = function()
				neoscroll.scroll(-10, {
					move_cursor = true,
					duration = 100,
				})
			end,
			['<C-e>'] = function()
				neoscroll.ctrl_d { duration = 500 }
			end,
			['<C-i>'] = function()
				neoscroll.ctrl_u { duration = 500 }
			end,
		}

		local modes = { 'n', 'v', 'x' }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func)
		end
	end,
}
