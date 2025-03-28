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

		-- dap ui setup
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

		-- dap ui auto-open/close
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

		-- keymaps
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

		-- setup virtual text
		require('nvim-dap-virtual-text').setup {
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			virt_text_pos = 'eol',
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		}

		-- lldb adapter setup
		dap.adapters.lldb = {
			type = 'executable',
			command = '/usr/local/Cellar/llvm/19.1.7_1/bin/lldb-dap',
			name = 'lldb',
			initCommands = {
				'settings set symbols.load-on-demand true',
				'settings set symbols.auto-download-missing-debug-symbols true',
				'settings set target.load-script-from-symbol-file true',
				'settings set target.auto-install-main-executable true',
			},
		}

		-- c++ configuration
		dap.configurations.cpp = {
			{
				name = 'Launch (LLDB)',
				type = 'lldb',
				request = 'launch',
				program = function()
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = {},
				runInTerminal = false,
				env = function()
					local variables = {}
					for k, v in pairs(vim.fn.environ()) do
						table.insert(variables, string.format('%s=%s', k, v))
					end
					return variables
				end,
				skipFiles = {
					'/usr/lib/**/*.so',
					'/usr/lib/**/*.dylib',
					'/usr/local/lib/**/*.dylib',
					'/System/Library/**/*.dylib',
				},

				-- source mapping for build directory
				sourceMap = {
					[vim.fn.getcwd() .. '/build'] = vim.fn.getcwd(),
				},
			},
			{
				name = 'Attach to process',
				type = 'lldb',
				request = 'attach',
				pid = function()
					local output = vim.fn.system { 'ps', 'aux' }
					local lines = vim.split(output, '\n')
					local procs = {}
					for i, line in ipairs(lines) do
						if i > 1 then
							if line:find 'metapool' then
								table.insert(procs, line)
							end
						end
					end
					local options = {}
					for i, proc in ipairs(procs) do
						local columns = vim.fn.split(proc, ' \t\n')
						local filtered = vim.tbl_filter(function(str)
							return str ~= ''
						end, columns)
						table.insert(options, string.format('%s: %s', filtered[2], proc))
					end
					local choice = vim.fn.inputlist { 'Select process to attach:', unpack(options) }
					if choice < 1 or choice > #options then
						return nil
					end
					return tonumber(options[choice]:match '^(%d+):')
				end,
				stopOnEntry = true,
				skipFiles = {
					'/usr/lib/**/*.so',
					'/usr/lib/**/*.dylib',
					'/usr/local/lib/**/*.dylib',
					'/System/Library/**/*.dylib',
				},
			},
			{
				name = 'Launch with arguments',
				type = 'lldb',
				request = 'launch',
				program = function()
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = true,
				args = function()
					local args_str = vim.fn.input 'Arguments: '
					return vim.fn.split(args_str, ' ')
				end,
				runInTerminal = false,
				env = function()
					local variables = {}
					for k, v in pairs(vim.fn.environ()) do
						table.insert(variables, string.format('%s=%s', k, v))
					end
					return variables
				end,
				skipFiles = {
					'/usr/lib/**/*.so',
					'/usr/lib/**/*.dylib',
					'/usr/local/lib/**/*.dylib',
					'/System/Library/**/*.dylib',
				},
				sourceMap = {
					[vim.fn.getcwd() .. '/build'] = vim.fn.getcwd(),
				},
			},
		}

		dap.configurations.c = dap.configurations.cpp

		-- additional configurations for specific build directories
		local function update_source_maps()
			local build_dirs = {
				'build',
				'build/debug',
				'build/release',
				'build/RelWithDebInfo',
				'cmake-build-debug',
				'cmake-build-release',
			}

			for _, config in pairs(dap.configurations.cpp) do
				if config.sourceMap then
					for _, build_dir in ipairs(build_dirs) do
						local full_build_path = vim.fn.getcwd() .. '/' .. build_dir
						if vim.fn.isdirectory(full_build_path) == 1 then
							config.sourceMap[full_build_path] = vim.fn.getcwd()
						end
					end
				end
			end
		end

		update_source_maps()
	end,
}
