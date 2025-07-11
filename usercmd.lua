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

vim.api.nvim_create_user_command('DapLog', function()
	local log_path = vim.fn.stdpath 'cache' .. '/dap.log'
	if vim.fn.filereadable(log_path) == 0 then
		vim.notify('DAP log not found at: ' .. log_path, vim.log.levels.WARN)
		return
	end
	vim.cmd('vsplit ' .. vim.fn.fnameescape(log_path))
	vim.cmd 'setlocal readonly'
	vim.cmd 'setlocal buftype=nowrite'
end, { desc = 'Open nvim-dap log file' })
