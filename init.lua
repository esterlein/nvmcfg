vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- [[ options ]]

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

-- schedule  after UiEnter to not increase startup-time

vim.schedule(function()
	vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.breakindent = true
vim.opt.undofile = true

-- search text case
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- substitution preview
vim.opt.inccommand = 'split'

vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- [[ keymaps ]]

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- newline remap

vim.keymap.set('n', 'O', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
vim.keymap.set('n', 'o', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")

-- split navigation :help wincmd

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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

-- [[ plugins ]]

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
