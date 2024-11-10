-- [[ autocommands :help lua-guide-autocommands ]]

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking',
	group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_augroup('NeotreeAutoopen', { clear = true })
vim.api.nvim_create_autocmd('BufRead', {
	desc = 'Open neo-tree on enter',
	group = 'NeotreeAutoopen',
	once = true,
	callback = function()
		if not vim.g.neotree_opened then
			vim.cmd 'Neotree show'
			vim.g.neotree_opened = true
		end
	end,
})

-- [[ user commands ]]

-- window resize

vim.api.nvim_create_user_command('Vr', function(opts)
	local usage = 'Usage: [VirticalResize] :Vr {number (%)}'
	if not opts.args or not string.len(opts.args) == 2 then
		print(usage)
		return
	end
	vim.cmd(':vertical resize ' .. vim.opt.columns:get() * (opts.args / 100.0))
end, { nargs = '*' })

vim.api.nvim_create_user_command('Hr', function(opts)
	local usage = 'Usage: [HorizontalResize] :Hr {number (%)}'
	if not opts.args or not string.len(opts.args) == 2 then
		print(usage)
		return
	end
	vim.cmd(':resize ' .. ((vim.opt.lines:get() - vim.opt.cmdheight:get()) * (opts.args / 100.0)))
end, { nargs = '*' })

-- [[ plugin manager ]]

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		error('Error cloning lazy.nvim:\n' .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require 'vimopt'
require 'keymap'
require('lazy').setup('plugins', {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = '⌘',
			config = '🛠',
			event = '📅',
			ft = '📂',
			init = '⚙',
			keys = '🗝',
			plugin = '🔌',
			runtime = '💻',
			require = '🌙',
			source = '📄',
			start = '🚀',
			task = '📌',
			lazy = '💤 ',
		},
	},
})
