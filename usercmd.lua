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
