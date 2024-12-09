return {
	'karb94/neoscroll.nvim',
	opts = {},

	config = function()
		local neoscroll = require 'neoscroll'

		neoscroll.setup {
			mappings = {},
		}

		local keymap = {
			['<C-k>'] = function()
				neoscroll.ctrl_u { duration = 600 }
			end,
			['<C-d>'] = function()
				neoscroll.ctrl_d { duration = 600 }
			end,
			['<C-i>'] = function()
				neoscroll.ctrl_b { duration = 450 }
			end,
			['<C-e>'] = function()
				neoscroll.ctrl_f { duration = 450 }
			end,
		}

		local modes = { 'n', 'v', 'x' }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func)
		end
	end,
}
