return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',
		'theHamsta/nvim-dap-virtual-text',
	},
	config = function()
		local dap = require 'dap'

		dap.util = dap.util or {}

		dap.util.resolve_debug_path = function(path)
			if vim.fn.filereadable(path) == 1 then
				return path
			end

			local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
			if not git_root or git_root == '' then
				return path
			end

			local rel = path:sub(#git_root + 2)
			local path_parts = vim.split(rel, '/', { plain = true })

			local build_root = nil
			for i, part in ipairs(path_parts) do
				if part == 'build' then
					build_root = i
					break
				end
			end

			local cleaned_rel_path
			if build_root then
				cleaned_rel_path = table.concat(vim.list_slice(path_parts, build_root + 1), '/')
			else
				cleaned_rel_path = rel
			end

			local cleaned = git_root .. '/' .. cleaned_rel_path
			if vim.fn.filereadable(cleaned) == 1 then
				return cleaned
			end

			local filename = vim.fn.fnamemodify(path, ':t')
			local results = vim.fn.systemlist { 'fd', '--type', 'f', '--name', filename, git_root }
			for _, candidate in ipairs(results) do
				local lines = vim.fn.readfile(candidate)
				if #lines >= 1 then
					return candidate
				end
			end

			return path
		end

		local dapui = require 'dapui'

		dap.adapters.lldb = {
			type = 'executable',
			command = 'lldb-dap',
			name = 'lldb',
			options = {
				sourceMap = {
					[vim.fn.getcwd() .. '/build'] = vim.fn.getcwd(),
				},
			},
		}

		local function get_env_vars()
			local vars = {}
			for k, v in pairs(vim.fn.environ()) do
				table.insert(vars, string.format('%s=%s', k, v))
			end
			return vars
		end

		local function select_pid()
			local output = vim.fn.system { 'ps', 'aux' }
			local lines = vim.split(output, '\n')
			local procs = {}
			for i = 2, #lines do
				table.insert(procs, lines[i])
			end
			local options = {}
			for _, proc in ipairs(procs) do
				local cols = vim.fn.split(proc, ' \t\n')
				local filtered = vim.tbl_filter(function(s)
					return s ~= ''
				end, cols)
				table.insert(options, string.format('%s: %s', filtered[2], proc))
			end
			local choice = vim.fn.inputlist { 'Select process to attach:', unpack(options) }
			if choice < 1 or choice > #options then
				return nil
			end
			return tonumber(options[choice]:match '^(%d+):')
		end

		local function get_setup_commands()
			return {
				{ text = 'breakpoint set --name __cxa_throw', description = 'Catch all exceptions at throw site', ignoreFailures = false },
				{ text = 'breakpoint set --name std::terminate', description = 'Break on std::terminate', ignoreFailures = true },
				{ text = 'breakpoint set --name abort', description = 'Break on abort()', ignoreFailures = true },
				{ text = 'breakpoint set --name __assert_fail', description = 'Break on assertion failures', ignoreFailures = true },
				{ text = 'process handle SIGSEGV --stop true --pass false --notify true', description = 'Stop on SIGSEGV', ignoreFailures = true },
				{ text = 'process handle SIGABRT --stop true --pass false --notify true', description = 'Stop on SIGABRT', ignoreFailures = true },
				{ text = 'process handle SIGFPE --stop true --pass false --notify true', description = 'Stop on SIGFPE', ignoreFailures = true },
				{
					text = 'settings set target.process.thread.step-avoid-regexp "^std::"',
					description = 'Avoid stepping into std namespace',
					ignoreFailures = true,
				},
			}
		end

		dap.configurations.cpp = {
			{
				name = 'Launch',
				type = 'lldb',
				request = 'launch',
				program = function()
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = {},
				env = get_env_vars,
				setupCommands = get_setup_commands(),
				initCommands = {
					'settings set target.process.thread.step-avoid-regexp "^std::"',
				},
			},
			{
				name = 'Attach to process',
				type = 'lldb',
				request = 'attach',
				pid = select_pid,
				stopOnEntry = false,
				env = get_env_vars,
				setupCommands = get_setup_commands(),
				initCommands = {
					'settings set target.process.thread.step-avoid-regexp "^std::"',
				},
			},
			{
				name = 'Launch with arguments',
				type = 'lldb',
				request = 'launch',
				program = function()
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = function()
					local arg_str = vim.fn.input 'Arguments: '
					return vim.fn.split(arg_str, ' ')
				end,
				env = get_env_vars,
				setupCommands = get_setup_commands(),
				initCommands = {
					'settings set target.process.thread.step-avoid-regexp "^std::"',
				},
			},
		}
		dap.configurations.c = dap.configurations.cpp

		local crashed = false

		dap.listeners.before.launch['set-exceptions'] = function()
			dap.set_exception_breakpoints { 'cpp_throw', 'cpp_catch' }
		end
		dap.listeners.before.attach['set-exceptions'] = function()
			dap.set_exception_breakpoints { 'cpp_throw', 'cpp_catch' }
		end

		dap.listeners.after.event_stopped['detect-crash'] = function(_, body)
			if body.reason == 'exception' or body.reason == 'signal' then
				crashed = true
			end
		end

		dapui.setup {
			controls = {
				enabled = true,
			},
			layouts = {
				{
					elements = {
						{ id = 'scopes', size = 0.25 },
						{ id = 'breakpoints', size = 0.25 },
						{ id = 'stacks', size = 0.25 },
						{ id = 'watches', size = 0.25 },
					},
					position = 'left',
					size = 40,
				},
				{
					elements = {
						{ id = 'repl', size = 0.5 },
						{ id = 'console', size = 0.5 },
					},
					position = 'bottom',
					size = 10,
				},
			},
		}

		require('nvim-dap-virtual-text').setup {
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			only_first_definition = true,
			all_references = false,
			clear_on_continue = false,
			virt_text_pos = 'eol',
		}

		local layout_snapshot = nil

		local function save_layout()
			layout_snapshot = {
				cmd = vim.fn.winrestcmd(),
				views = {},
			}
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				layout_snapshot.views[buf] = vim.fn.winsaveview()
			end
		end

		local function restore_layout()
			vim.defer_fn(function()
				if not layout_snapshot then
					return
				end
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if layout_snapshot.views[buf] then
						vim.fn.winrestview(layout_snapshot.views[buf])
					end
				end
				vim.cmd(layout_snapshot.cmd)
			end, 500)
		end

		dap.listeners.before.attach.dapui_config = function()
			save_layout()
			dapui.open()
		end

		dap.listeners.before.launch.dapui_config = function()
			save_layout()
			dapui.open()
		end

		dap.listeners.before.event_terminated.dapui_config = function()
			if not crashed then
				vim.defer_fn(function()
					dapui.close()
					restore_layout()
				end, 1000)
			end
			crashed = false
		end

		dap.listeners.before.event_exited.dapui_config = function()
			if not crashed then
				vim.defer_fn(function()
					dapui.close()
					restore_layout()
				end, 1000)
			end
			crashed = false
		end

		dap.listeners.after.event_initialized['focus-window'] = function()
			vim.defer_fn(function()
				if vim.fn.win_gettype() == 'popup' then
					vim.cmd 'wincmd p'
				end
			end, 100)
		end

		dap.listeners.after.event_stopped['show-exception'] = function(session, body)
			if body.reason == 'exception' then
				print('Exception caught: ' .. (body.description or 'Unknown exception'))
				vim.defer_fn(function()
					local wins = vim.api.nvim_list_wins()
					for _, win in ipairs(wins) do
						local buf = vim.api.nvim_win_get_buf(win)
						local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
						if filetype == 'cpp' or filetype == 'c' then
							vim.api.nvim_set_current_win(win)
							break
						end
					end
				end, 100)
			end
		end

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

		vim.keymap.set('n', '<Leader>de', function()
			dap.set_exception_breakpoints { 'cpp_catch', 'cpp_throw' }
		end, { desc = '[d]ap set [e]xception breakpoints' })

		vim.keymap.set('n', '<Leader>ds', function()
			dap.disconnect()
			dap.close()
		end, { desc = '[d]ap [s]top/disconnect' })

		vim.keymap.set('n', '<Leader>dl', ':DapLog<CR>', { desc = '[d]ap [l]og', silent = true })
	end,
}
