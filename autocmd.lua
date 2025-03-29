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

		if fpath:match '^/build/' then
			local subpath = fpath:gsub('^/build/', '')
			local project_dir = vim.fn.getcwd()
			local real_path = project_dir .. '/' .. subpath

			if vim.fn.filereadable(real_path) == 1 then
				vim.cmd('edit ' .. real_path)
				return true
			end
		end

		local function_name = vim.fn.fnamemodify(fpath, ':t')
		local dir_path = vim.fn.fnamemodify(fpath, ':h')

		if dir_path:match '/build/' or dir_path:match '^build/' then
			local project_dir = vim.fn.getcwd()
			local rel_path = fpath:gsub('.*/build/', '')
			local real_path = project_dir .. '/' .. rel_path

			if vim.fn.filereadable(real_path) == 1 then
				vim.cmd('edit ' .. real_path)
				return true
			end
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = { 'DapBufLoad' },
	callback = function(args)
		local path = args.data.path
		if path:match '^/build/' then
			local subpath = path:gsub('^/build/', '')
			local project_dir = vim.fn.getcwd()
			local project_path = project_dir .. '/' .. subpath

			if vim.fn.filereadable(project_path) == 1 then
				vim.cmd('edit ' .. project_path)
				return true
			end
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapStopped',
	callback = function(args)
		local frame = require('dap').session().current_frame
		if frame and frame.source and frame.source.path then
			local path = frame.source.path
			local real_path = path
			local project_dir = vim.fn.getcwd()

			print('Original debug frame path: ' .. path)

			if path:match '^build/[^/]+/' then
				local subdir = path:match '^build/([^/]+)/'
				local filename = vim.fn.fnamemodify(path, ':t')
				local direct_path = project_dir .. '/' .. subdir .. '/' .. filename

				print('Trying direct path: ' .. direct_path)
				if vim.fn.filereadable(direct_path) == 1 then
					real_path = direct_path
					print('Found direct path: ' .. real_path)
				end
			elseif path:match '^/build/' then
				real_path = path:gsub('^/build/', project_dir .. '/')
			elseif path:match '^build/' then
				real_path = path:gsub('^build/', project_dir .. '/')
			end

			print('Final path attempt: ' .. real_path)
			if vim.fn.filereadable(real_path) == 1 then
				print('Opening file: ' .. real_path)
				local ok, err = pcall(function()
					vim.cmd('edit ' .. vim.fn.fnameescape(real_path))
					vim.api.nvim_win_set_cursor(0, { frame.line, math.max(0, (frame.column or 1) - 1) })
					vim.cmd 'normal! zz'
				end)

				if not ok then
					print('Error opening file: ' .. tostring(err))
				end
				return true
			else
				print('Could not find a readable file for: ' .. path)
			end
		else
			print 'Missing frame information'
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapEvent',
	callback = function(args)
		if args.data and args.data.event == 'stopped' then
			vim.defer_fn(function()
				local session = require('dap').session()
				if session and session.current_frame and session.current_frame.source then
					local frame = session.current_frame
					print 'Stopped at frame:'
					print('  Source name: ' .. tostring(frame.source.name))
					print('  Source path: ' .. tostring(frame.source.path))
					print('  Line: ' .. tostring(frame.line))
					print('  Column: ' .. tostring(frame.column))
				end
			end, 100)
		end
	end,
})
