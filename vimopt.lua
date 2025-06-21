vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.g.clipboard = {
	name = 'wl-clipboard',
	copy = {
		['+'] = 'wl-copy',
		['*'] = 'wl-copy',
	},
	paste = {
		['+'] = 'wl-paste',
		['*'] = 'wl-paste',
	},
	cache_enabled = 0,
}

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'

vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.schedule(function()
	vim.opt.clipboard = 'unnamedplus'
end)
