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

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'dap-repl',
	callback = function()
		require('dap.ext.autocompl').attach()
	end,
})

-- auto open files when debugger stops
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
	callback = function()
		local fpath = vim.fn.expand '%:p'
		if fpath:match '/usr/' or fpath:match '/tmp/' then
			vim.opt_local.readonly = true
		end
	end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
	callback = function()
		local fpath = vim.fn.expand '%:p'
		if fpath == '/build/main.cpp' then
			-- Redirect to the actual file
			vim.cmd 'edit /Users/iftoin/code/metapool/main.cpp'
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = { 'DapBufLoad' },
	callback = function(args)
		local path = args.data.path
		if path:match '^/build/' then
			local real_path = '/Users/iftoin/code/metapool' .. path
			vim.cmd('edit ' .. real_path)
			return true -- Indicates we handled the file load
		end
	end,
})
