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

		dapui.setup {
			icons = {
				expanded = '▾',
				collapsed = '▸',
				current_frame = '*',
			},
			mappings = {
				expand = { '<CR>', '<2-LeftMouse>' },
				open = 'o',
				remove = 'd',
				edit = 'e',
				repl = 'r',
				toggle = 't',
			},
			element_mappings = {},
			expand_lines = true,
			layouts = {
				{
					elements = {
						{ id = 'scopes', size = 0.25 },
						{ id = 'breakpoints', size = 0.25 },
						{ id = 'stacks', size = 0.25 },
						{ id = 'watches', size = 0.25 },
					},
					size = 40,
					position = 'left',
				},
				{
					elements = {
						{ id = 'repl', size = 0.5 },
						{ id = 'console', size = 0.5 },
					},
					size = 10,
					position = 'bottom',
				},
			},
			controls = {
				enabled = true,
				element = 'repl',
				icons = {
					pause = '⏸',
					play = '▶',
					step_into = '⏎',
					step_over = '⏭',
					step_out = '⏮',
					step_back = 'b',
					run_last = '▶▶',
					terminate = '⏹',
					disconnect = '⏏',
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				border = 'single',
				mappings = {
					close = { 'q', '<Esc>' },
				},
			},
			force_buffers = true,
			render = {
				max_type_length = nil,
				max_value_lines = 100,
				indent = 1,
			},
		}

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
		vim.keymap.set('n', '<Leader>do', dapui.toggle, {})
		vim.keymap.set('n', '<Leader>ds', dap.step_over, {})
		vim.keymap.set('n', '<Leader>di', dap.step_into, {})
		vim.keymap.set('n', '<Leader>du', dap.step_out, {})

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
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = true,
				args = {},
				runInTerminal = false,
				env = function()
					local variables = {}
					for k, v in pairs(vim.fn.environ()) do
						table.insert(variables, string.format('%s=%s', k, v))
					end
					return variables
				end,
			},
		}
		dap.configurations.c = dap.configurations.cpp
	end,
}
