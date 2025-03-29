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

local function fix_debug_path(path)
	local project_dir = vim.fn.getcwd()
	local fixed_path = path

	if vim.fn.filereadable(path) == 0 then
		if path:match '^build/[^/]+/' then
			local subpath = path:gsub('^build/', '')
			local correct_path = project_dir .. '/' .. subpath
			if vim.fn.filereadable(correct_path) == 1 then
				fixed_path = correct_path
				print('Corrected path: ' .. path .. ' -> ' .. fixed_path)
			end
		elseif path:match(project_dir .. '/build/') then
			local subpath = path:gsub(project_dir .. '/build/', '')
			local correct_path = project_dir .. '/' .. subpath
			if vim.fn.filereadable(correct_path) == 1 then
				fixed_path = correct_path
				print('Corrected path: ' .. path .. ' -> ' .. fixed_path)
			end
		elseif path:match '^/build/' then
			local subpath = path:gsub('^/build/', '')
			local correct_path = project_dir .. '/' .. subpath
			if vim.fn.filereadable(correct_path) == 1 then
				fixed_path = correct_path
				print('Corrected path: ' .. path .. ' -> ' .. fixed_path)
			end
		end
	end

	return fixed_path
end

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapBreakpointChanged',
	callback = function()
		local session = require('dap').session()
		if session and session.capabilities and session.capabilities.supportsSetBreakpoints then
			print('Debug adapter is now focused on file: ' .. vim.fn.expand '%:p')
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapContinued',
	callback = function()
		vim.g.dap_last_session_state = {
			current_file = vim.fn.expand '%:p',
			has_pending_breakpoints = #require('dap.breakpoints').get() > 0,
		}
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapBreakpointAdded',
	callback = function(args)
		if args.data and args.data.file then
			print('Breakpoint added in file: ' .. args.data.file)

			if args.data.breakpoint and not args.data.breakpoint.verified then
				local fixed_path = fix_debug_path(args.data.file)
				if fixed_path ~= args.data.file then
					require('dap').set_breakpoint(nil, nil, nil, fixed_path, args.data.line)
					print('Relocated breakpoint to correct path: ' .. fixed_path)
				end
			end
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapStopped',
	callback = function()
		local session = require('dap').session()
		if not session or not session.current_frame or not session.current_frame.source then
			print 'Missing frame information'
			return
		end

		local frame = session.current_frame
		local path = frame.source.path or ''

		local real_path = require('dap').utils.resolve_debug_path(path)

		if vim.fn.filereadable(real_path) == 1 then
			pcall(function()
				vim.cmd('edit ' .. vim.fn.fnameescape(real_path))
				local buffer_line_count = vim.api.nvim_buf_line_count(0)
				local line = math.min(frame.line, buffer_line_count)
				local col = math.max(0, (frame.column or 1) - 1)
				vim.api.nvim_win_set_cursor(0, { line, col })
				vim.cmd 'normal! zz'
			end)
		end
	end,
})

vim.api.nvim_create_autocmd('User', {
	pattern = 'DapEvent',
	callback = function(args)
		vim.g.resolved_debug_paths = vim.g.resolved_debug_paths or {}

		if args.data and args.data.event == 'loadedSource' then
			local path = args.data.source and args.data.source.path
			if path and not vim.g.resolved_debug_paths[path] then
				local resolved = require('dap.utils').resolve_debug_path(path)
				if resolved ~= path then
					vim.g.resolved_debug_paths[path] = resolved
					print('Resolved source path: ' .. path .. ' -> ' .. resolved)
				end
			end
		end
	end,
})
