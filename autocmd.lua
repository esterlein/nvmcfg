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

vim.api.nvim_create_augroup('LazyGroup', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'lazy',
	desc = 'Quit lazy with <esc>',
	group = 'LazyGroup',
	callback = function()
		vim.keymap.set('n', '<esc>', function()
			vim.api.nvim_win_close(0, false)
		end, { buffer = true, nowait = true })
	end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
	pattern = { 'glsl' },
	callback = function()
		vim.b.autoformat = false
	end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = '*.tpp',
	command = 'set filetype=cpp',
})
