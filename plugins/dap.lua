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
				if lines[i]:find 'metapool' then
					table.insert(procs, lines[i])
				end
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
			},
			{
				name = 'Attach to process',
				type = 'lldb',
				request = 'attach',
				pid = select_pid,
				stopOnEntry = true,
				env = get_env_vars,
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
			},
		}
		dap.configurations.c = dap.configurations.cpp

		dapui.setup()
		require('nvim-dap-virtual-text').setup {}

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
			end, 200)
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
			dapui.close()
			restore_layout()
		end

		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
			restore_layout()
		end

		dap.listeners.after.event_initialized['focus-window'] = function()
			vim.defer_fn(function()
				if vim.fn.win_gettype() == 'popup' then
					vim.cmd 'wincmd p'
				end
			end, 100)
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
	end,
}
