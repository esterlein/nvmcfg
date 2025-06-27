return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',
		'theHamsta/nvim-dap-virtual-text',
	},
	config = function()
		local dap = require 'dap'
		local dapui = require 'dapui'

		dap.adapters.lldb = {
			type = 'executable',
			command = 'lldb-dap',
			name = 'lldb',
		}

		dap.configurations.cpp = {
			{
				name = 'Launch',
				type = 'lldb',
				request = 'launch',
				program = function()
					return vim.fn.input('path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = {},
			},
		}
		dap.configurations.c = dap.configurations.cpp

		-- UI setup
		dapui.setup()
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

		require('nvim-dap-virtual-text').setup {}

		vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = '[d]ap toggle [b]reakpoint' })
		vim.keymap.set('n', '<Leader>dB', function()
			dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
		end, { desc = '[d]ap set conditional [B]reakpoint' })
		vim.keymap.set('n', '<Leader>dc', dap.continue, { desc = '[d]ap [c]ontinue' })
		vim.keymap.set('n', '<Leader>dt', dapui.toggle, { desc = '[d]ap [t]oggle ui' })
		vim.keymap.set('n', '<Leader>dn', dap.step_over, { desc = '[d]ap step over [n]ext' })
		vim.keymap.set('n', '<Leader>di', dap.step_into, { desc = '[d]ap step [i]nto' })
		vim.keymap.set('n', '<Leader>do', dap.step_out, { desc = '[d]ap step [o]ut' })
		vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = '[d]ap open [r]epl' })
		vim.keymap.set('n', '<Leader>dx', dap.terminate, { desc = '[d]ap terminate/e[x]it' })

		vim.keymap.set('n', '<Leader>df', function()
			local func_name = vim.fn.expand '<cword>'
			dap.set_breakpoint(nil, nil, func_name)
		end, { desc = '[d]ap set [f]unction breakpoint' })
	end,
}
