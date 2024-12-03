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

		dap.adapters.lldb = {
			type = 'executable',
			command = '/usr/local/Cellar/llvm/19.1.4/bin/lldb-dap',
			name = 'lldb',
		}

		dap.configurations.cpp = {
			{
				name = 'Launch (LLDB)',
				type = 'lldb',
				request = 'launch',
				program = function()
					local path = vim.fn.input {
						prompt = 'Path to executable: ',
						default = vim.fn.getcwd() .. '/',
						completion = 'file',
					}
					return (path and path ~= '') and path or dap.ABORT
				end,
				cwd = '${workspaceFolder}',
				stopAtEntry = true,
				args = {},
			},
			--			{
			--				name = 'Launch with arguments (GDB)',
			--				type = 'gdb',
			--				request = 'launch',
			--				program = function()
			--					local path = vim.fn.input {
			--						prompt = 'Path to executable: ',
			--						default = vim.fn.getcwd() .. '/',
			--						completion = 'file',
			--					}
			--					return (path and path ~= '') and path or dap.ABORT
			--				end,
			--				args = function()
			--					local args_str = vim.fn.input {
			--						prompt = 'Arguments: ',
			--					}
			--					return vim.split(args_str, ' +')
			--				end,
			--				stopAtEntry = true,
			--			},
			--			{
			--				name = 'Attach (GDB)',
			--				type = 'gdb',
			--				request = 'attach',
			--				processId = require('dap.utils').pick_process,
			--				stopAtEntry = true,
			--			},
		}

		dap.configurations.c = dap.configurations.cpp
	end,
}
