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
			'external',
			'tools',
		}

		dap.utils = dap.utils or {}

		vim.g.dap_path_mappings = {}

		function dap.utils.resolve_debug_path(path)
			if not path then
				return nil
			end

			if vim.fn.filereadable(path) == 1 then
				return path
			end

			if vim.g.dap_path_mappings and vim.g.dap_path_mappings[path] then
				return vim.g.dap_path_mappings[path]
			end

			local project_dir = vim.fn.getcwd()
			local candidates = {}

			local filename = vim.fn.fnamemodify(path, ':t')

			vim.g.dap_path_mappings = vim.g.dap_path_mappings or {}

			if path:match '^build/' then
				table.insert(candidates, project_dir .. '/' .. path:gsub('^build/', ''))
			end
			if path:match '^/build/' then
				table.insert(candidates, project_dir .. '/' .. path:gsub('^/build/', ''))
			end
			if path:match(project_dir .. '/build/') then
				table.insert(candidates, path:gsub(project_dir .. '/build/', project_dir .. '/'))
			end
			if path:match '/build/' then
				table.insert(candidates, path:gsub('/build/', '/'))
			end

			if not path:match '^/' then
				table.insert(candidates, project_dir .. '/' .. path)
			end

			for _, subdir in ipairs(common_subdirs) do
				local pattern_rel = '^' .. subdir .. '/'
				local pattern_abs = '^/' .. subdir .. '/'
				local pattern_proj = '^' .. project_dir .. '/' .. subdir .. '/'
				local pattern_any = '/' .. subdir .. '/'

				local matched = false
				local subpath = nil

				if path:match(pattern_rel) then
					subpath = path:gsub(pattern_rel, '')
					matched = true
				elseif path:match(pattern_abs) then
					subpath = path:gsub(pattern_abs, '')
					matched = true
				elseif path:match(pattern_proj) then
					subpath = path:gsub(pattern_proj, '')
					matched = true
				elseif path:match(pattern_any) then
					local parts = vim.split(path, pattern_any, { plain = true })
					if #parts > 1 then
						subpath = parts[2]
						matched = true
					end
				end

				if matched and subpath then
					for _, target_subdir in ipairs(common_subdirs) do
						table.insert(candidates, project_dir .. '/' .. target_subdir .. '/' .. subpath)

						table.insert(candidates, project_dir .. '/build/' .. target_subdir .. '/' .. subpath)
						table.insert(candidates, '/build/' .. target_subdir .. '/' .. subpath)
						table.insert(candidates, 'build/' .. target_subdir .. '/' .. subpath)

						if subpath:match '/' then
							local flat_name = vim.fn.fnamemodify(subpath, ':t')
							table.insert(candidates, project_dir .. '/' .. target_subdir .. '/' .. flat_name)
							table.insert(candidates, project_dir .. '/build/' .. target_subdir .. '/' .. flat_name)
						end
					end
				end
			end

			for _, subdir in ipairs(common_subdirs) do
				local pattern_build_rel = '^build/' .. subdir .. '/'
				local pattern_build_abs = '^/build/' .. subdir .. '/'
				local pattern_build_proj = '^' .. project_dir .. '/build/' .. subdir .. '/'

				local matched = false
				local subpath = nil

				if path:match(pattern_build_rel) then
					subpath = path:gsub(pattern_build_rel, '')
					matched = true
				elseif path:match(pattern_build_abs) then
					subpath = path:gsub(pattern_build_abs, '')
					matched = true
				elseif path:match(pattern_build_proj) then
					subpath = path:gsub(pattern_build_proj, '')
					matched = true
				end

				if matched and subpath then
					table.insert(candidates, project_dir .. '/' .. subdir .. '/' .. subpath)

					for _, target_subdir in ipairs(common_subdirs) do
						if target_subdir ~= subdir then
							table.insert(candidates, project_dir .. '/' .. target_subdir .. '/' .. subpath)
							table.insert(candidates, project_dir .. '/build/' .. target_subdir .. '/' .. subpath)
						end
					end
				end
			end

			if filename and #filename > 0 then
				for _, subdir in ipairs(common_subdirs) do
					table.insert(candidates, project_dir .. '/' .. subdir .. '/' .. filename)
					table.insert(candidates, project_dir .. '/build/' .. subdir .. '/' .. filename)
				end

				table.insert(candidates, project_dir .. '/' .. filename)
				table.insert(candidates, project_dir .. '/build/' .. filename)

				local matches = vim.fn.glob(project_dir .. '/**/' .. filename, true, true)
				for _, match in ipairs(matches) do
					table.insert(candidates, match)
				end
			end

			local unique = {}
			local filtered = {}

			for _, candidate in ipairs(candidates) do
				if not unique[candidate] then
					unique[candidate] = true
					table.insert(filtered, candidate)
				end
			end

			for _, candidate in ipairs(filtered) do
				if vim.fn.filereadable(candidate) == 1 then
					vim.g.dap_path_mappings[path] = candidate

					print('DAP Path Resolution: ' .. path .. ' -> ' .. candidate)

					return candidate
				end
			end

			return path
		end

		local original_bp_set = require('dap.breakpoints').set
		require('dap.breakpoints').set = function(buf_id, line, opts)
			local bp = original_bp_set(buf_id, line, opts)

			local file_path = vim.api.nvim_buf_get_name(buf_id)
			if not file_path or file_path == '' then
				return bp
			end

			local session = dap.session()
			if not session or not session.initialized then
				return bp
			end

			vim.g.dap_path_mappings = vim.g.dap_path_mappings or {}

			local project_dir = vim.fn.getcwd()
			local filename = vim.fn.fnamemodify(file_path, ':t')
			local rel_path = file_path:gsub('^' .. project_dir .. '/', '')

			local in_subdir = nil
			local subdir_path = nil

			for _, subdir in ipairs(common_subdirs) do
				if rel_path:match('^' .. subdir .. '/') then
					in_subdir = subdir
					subdir_path = rel_path:gsub('^' .. subdir .. '/', '')
					break
				end
			end

			local alt_paths = {}

			table.insert(alt_paths, project_dir .. '/build/' .. rel_path)
			table.insert(alt_paths, '/build/' .. rel_path)
			table.insert(alt_paths, 'build/' .. rel_path)

			if rel_path:match '^build/' then
				local src_path = rel_path:gsub('^build/', '')
				table.insert(alt_paths, project_dir .. '/' .. src_path)
				table.insert(alt_paths, '/' .. src_path)
				table.insert(alt_paths, src_path)
			end

			if in_subdir and subdir_path then
				for _, other_subdir in ipairs(common_subdirs) do
					table.insert(alt_paths, project_dir .. '/' .. other_subdir .. '/' .. subdir_path)

					table.insert(alt_paths, project_dir .. '/build/' .. other_subdir .. '/' .. subdir_path)
					table.insert(alt_paths, '/build/' .. other_subdir .. '/' .. subdir_path)
					table.insert(alt_paths, 'build/' .. other_subdir .. '/' .. subdir_path)
				end
			end

			for _, subdir in ipairs(common_subdirs) do
				table.insert(alt_paths, project_dir .. '/' .. subdir .. '/' .. filename)
				table.insert(alt_paths, project_dir .. '/build/' .. subdir .. '/' .. filename)
				table.insert(alt_paths, '/build/' .. subdir .. '/' .. filename)
				table.insert(alt_paths, 'build/' .. subdir .. '/' .. filename)
			end

			local unique_paths = {}
			local filtered_paths = {}

			for _, path in ipairs(alt_paths) do
				if path ~= file_path and not unique_paths[path] then
					unique_paths[path] = true
					table.insert(filtered_paths, path)
				end
			end

			if #filtered_paths > 0 then
				print('DAP: Setting ' .. #filtered_paths .. ' shadow breakpoints for ' .. file_path)
			end

			for _, alt_path in ipairs(filtered_paths) do
				vim.g.dap_path_mappings[alt_path] = file_path
				vim.g.dap_path_mappings[file_path] = file_path -- Map to self for completeness

				session:request('setBreakpoints', {
					source = {
						name = filename,
						path = alt_path,
					},
					breakpoints = { { line = line } },
					sourceModified = false,
				})
			end

			return bp
		end

		local original_set_breakpoint = dap.set_breakpoint
		dap.set_breakpoint = function(condition, hit_condition, log_message, file, line)
			-- If file is provided, try to resolve a better path
			if file then
				local resolved_file = dap.utils.resolve_debug_path(file)

				if resolved_file ~= file then
					print('Using resolved file for breakpoint: ' .. resolved_file)
					return original_set_breakpoint(condition, hit_condition, log_message, resolved_file, line)
				end
			end

			return original_set_breakpoint(condition, hit_condition, log_message, file, line)
		end

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
			element_mappings = {
				scopes = {
					edit = 'e',
					expand = { '<CR>', '<2-LeftMouse>' },
					open = 'o',
					jump = { '<CR>' },
				},
			},
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

			local main_files = {}
			local file_list = vim.fn.glob(project_dir .. '/*.cpp', false, true)
			for _, file in ipairs(file_list) do
				table.insert(main_files, vim.fn.fnamemodify(file, ':t'))
			end

			local mappings = {}
			table.insert(mappings, { project_dir .. '/build', project_dir })
			table.insert(mappings, { '/build', project_dir })

			for _, main_file in ipairs(main_files) do
				table.insert(mappings, { '/build/' .. main_file, project_dir .. '/' .. main_file })
				table.insert(mappings, { 'build/' .. main_file, project_dir .. '/' .. main_file })
			end

			for _, subdir in ipairs(common_subdirs) do
				local full_subdir = project_dir .. '/' .. subdir
				if vim.fn.isdirectory(full_subdir) == 1 then
					table.insert(mappings, { '/build/' .. subdir, full_subdir })
					table.insert(mappings, { project_dir .. '/build/' .. subdir, full_subdir })
					table.insert(mappings, { 'build/' .. subdir, full_subdir })

					local all_files = vim.fn.glob(full_subdir .. '/*', false, true)
					for _, file in ipairs(all_files) do
						if vim.fn.isdirectory(file) ~= 1 then -- Skip directories
							local filename = vim.fn.fnamemodify(file, ':t')
							local rel_path = subdir .. '/' .. filename

							table.insert(mappings, { '/build/' .. rel_path, file })
							table.insert(mappings, { 'build/' .. rel_path, file })
							table.insert(mappings, { project_dir .. '/build/' .. rel_path, file })
						end
					end
				end
			end

			-- add mappings for each subfolder inside "src".
			local src_dir = project_dir .. '/src'
			if vim.fn.isdirectory(src_dir) == 1 then
				local nested_dirs = vim.fn.glob(src_dir .. '/*/', false, true)
				for _, dir in ipairs(nested_dirs) do
					local rel_dir = vim.fn.fnamemodify(dir, ':t')
					table.insert(mappings, { '/build/src/' .. rel_dir, dir })
					table.insert(mappings, { project_dir .. '/build/src/' .. rel_dir, dir })
					table.insert(mappings, { 'build/src/' .. rel_dir, dir })
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
