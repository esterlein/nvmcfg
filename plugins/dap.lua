return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',
		'theHamsta/nvim-dap-virtual-text',
	},
	config = function()
		vim.fn.setenv('DAP_DEBUG', '1')

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
		local neotree_width

		dap.listeners.before.attach.dapui_config = function()
			local neotree_wins = vim.tbl_filter(function(win)
				local buf = vim.api.nvim_win_get_buf(win)
				local buf_name = vim.api.nvim_buf_get_name(buf)
				return buf_name:match 'neo%-tree'
			end, vim.api.nvim_list_wins())

			if #neotree_wins > 0 then
				neotree_width = vim.api.nvim_win_get_width(neotree_wins[1])
			end

			dapui.open()
		end

		dap.listeners.before.launch.dapui_config = function()
			local neotree_wins = vim.tbl_filter(function(win)
				local buf = vim.api.nvim_win_get_buf(win)
				local buf_name = vim.api.nvim_buf_get_name(buf)
				return buf_name:match 'neo%-tree'
			end, vim.api.nvim_list_wins())

			if #neotree_wins > 0 then
				neotree_width = vim.api.nvim_win_get_width(neotree_wins[1])
			end

			dapui.open()
		end

		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()

			vim.defer_fn(function()
				if neotree_width then
					local neotree_wins = vim.tbl_filter(function(win)
						local buf = vim.api.nvim_win_get_buf(win)
						local buf_name = vim.api.nvim_buf_get_name(buf)
						return buf_name:match 'neo%-tree'
					end, vim.api.nvim_list_wins())

					if #neotree_wins > 0 then
						vim.api.nvim_win_set_width(neotree_wins[1], neotree_width)
					end
				end
			end, 100)
		end

		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()

			vim.defer_fn(function()
				if neotree_width then
					local neotree_wins = vim.tbl_filter(function(win)
						local buf = vim.api.nvim_win_get_buf(win)
						local buf_name = vim.api.nvim_buf_get_name(buf)
						return buf_name:match 'neo%-tree'
					end, vim.api.nvim_list_wins())

					if #neotree_wins > 0 then
						vim.api.nvim_win_set_width(neotree_wins[1], neotree_width)
					end
				end
			end, 100)
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
			env = {
				LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = 'YES',
			},
			initCommands = {
				'settings set symbols.load-on-demand true',
				'settings set symbols.auto-download-missing-debug-symbols true',
				'settings set target.load-script-from-symbol-file true',
				'settings set target.auto-install-main-executable true',
				'settings set target.inline-breakpoint-strategy always',
				'settings set target.skip-prologue false',
			},
		}

		-- generate source maps for c++ project template
		local function generate_cpp_source_maps()
			local project_dir = vim.fn.getcwd()
			local project_name = vim.fn.fnamemodify(project_dir, ':t')

			local main_files = {}
			local handle = vim.fn.glob(project_dir .. '/*.cpp', false, true)
			for _, file in ipairs(handle) do
				table.insert(main_files, vim.fn.fnamemodify(file, ':t'))
			end

			local mappings = {}

			table.insert(mappings, { project_dir .. '/build', project_dir })
			table.insert(mappings, { '/build', project_dir })

			for _, main_file in ipairs(main_files) do
				table.insert(mappings, { '/build/' .. main_file, project_dir .. '/' .. main_file })
				table.insert(mappings, { 'build/' .. main_file, project_dir .. '/' .. main_file })
			end

			local common_subdirs = {
				'src',
				'include',
				'lib',
				'benchmark',
				'test',
				'tests',
				'examples',
				'doc',
				'docs',
				'3rdparty',
				'third_party',
				'thirdparty',
				'external',
				'tools',
			}

			for _, subdir in ipairs(common_subdirs) do
				if vim.fn.isdirectory(project_dir .. '/' .. subdir) == 1 then
					table.insert(mappings, { '/build/' .. subdir, project_dir .. '/' .. subdir })
					table.insert(mappings, { project_dir .. '/build/' .. subdir, project_dir .. '/' .. subdir })

					local subdir_files = vim.fn.glob(project_dir .. '/' .. subdir .. '/*.{h,hpp,hxx}', false, true)
					for _, file in ipairs(subdir_files) do
						local filename = vim.fn.fnamemodify(file, ':t')
						table.insert(mappings, { '/build/' .. subdir .. '/' .. filename, file })
					end
				end
			end

			if vim.fn.isdirectory(project_dir .. '/src') == 1 then
				local nested_dirs = vim.fn.glob(project_dir .. '/src/*/', false, true)
				for _, dir in ipairs(nested_dirs) do
					local rel_dir = vim.fn.fnamemodify(dir, ':t')
					table.insert(mappings, { '/build/src/' .. rel_dir, dir })
					table.insert(mappings, { project_dir .. '/build/src/' .. rel_dir, dir })
				end
			end

			return mappings
		end

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
				args = { 'simple' },
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

				sourceMap = generate_cpp_source_maps(),

				setupCommands = {
					{
						text = 'settings show target.source-map',
						description = 'Show source map settings',
						ignoreFailures = true,
					},
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

			---@param config {sourceMap: table}
			local function update_config(config)
				if not config.sourceMap then
					config.sourceMap = {}
				end

				for _, build_dir in ipairs(build_dirs) do
					local full_build_path = vim.fn.getcwd() .. '/' .. build_dir
					if vim.fn.isdirectory(full_build_path) == 1 then
						table.insert(config.sourceMap, { full_build_path, vim.fn.getcwd() })
					end
				end
			end

			for _, config in pairs(dap.configurations.cpp) do
				update_config(config)
			end
		end

		update_source_maps()
	end,
}
