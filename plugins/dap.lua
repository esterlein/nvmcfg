return {
	'mfussenegger/nvim-dap',

	dependencies = {
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',
	},
	config = function()
		local dap = require 'dap'
		local dapui = require 'dapui'

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, {})
		vim.keymap.set('n', '<Leader>dc', dap.continue, {})

		dap.adapters.gdb = {
			id = 'gdb',
			type = 'executable',
			command = 'gdb',
			args = { '--quiet', '--interpreter=dap' },
		}

		dap.configurations.cpp = {
			{
				name = 'Launch (GDB)',
				type = 'gdb',
				request = 'launch',
				program = function()
					local path = vim.fn.input {
						prompt = 'Path to executable: ',
						default = vim.fn.getcwd() .. '/',
						completion = 'file',
					}
					return (path and path ~= '') and path or dap.ABORT
				end,
			},
			{
				name = 'Launch with arguments (GDB)',
				type = 'gdb',
				request = 'launch',
				program = function()
					local path = vim.fn.input {
						prompt = 'Path to executable: ',
						default = vim.fn.getcwd() .. '/',
						completion = 'file',
					}
					return (path and path ~= '') and path or dap.ABORT
				end,
				args = function()
					local args_str = vim.fn.input {
						prompt = 'Arguments: ',
					}
					return vim.split(args_str, ' +')
				end,
			},
		}
	end,
}
