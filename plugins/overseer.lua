return {
	'stevearc/overseer.nvim',
	lazy = false,
	opts = {
		strategy = {
			'toggleterm',
			direction = 'float',
		},
	},
	dependencies = {
		'nvim-lua/plenary.nvim',
		'akinsho/toggleterm.nvim',
	},
	config = function(_, opts)
		local overseer = require 'overseer'
		local Path = require 'plenary.path'
		local scan = require 'plenary.scandir'

		require('toggleterm').setup()
		overseer.setup(opts)

		vim.keymap.set('n', '<leader>br', function()
			overseer.run_last()
		end, { desc = 'run last build task' })

		vim.keymap.set('n', '<leader>bt', function()
			overseer.toggle()
		end, { desc = 'toggle build task list' })

		vim.keymap.set('n', '<leader>bb', function()
			local cwd = vim.loop.cwd()
			local build_scripts = scan.scan_dir(cwd, {
				depth = 6,
				search_pattern = 'build.sh',
				add_dirs = false,
				hidden = false,
			})

			if #build_scripts == 0 then
				vim.notify('no build.sh found', vim.log.levels.WARN)
				return
			end

			vim.ui.select(build_scripts, { prompt = 'select build.sh' }, function(selected)
				if type(selected) ~= 'string' or selected == '' then
					return
				end

				vim.ui.input({ prompt = 'arguments:' }, function(args)
					if args == nil then
						args = ''
					end

					local script_path = Path:new(selected):absolute()
					local run_dir = Path:new(script_path):parent().filename
					local cmd = { './build.sh' }

					for arg in string.gmatch(args, '%S+') do
						table.insert(cmd, arg)
					end

					vim.notify('Running: ' .. table.concat(cmd, ' ') .. '\nIn: ' .. run_dir)

					overseer.run_template {
						name = 'run build.sh',
						builder = function()
							return {
								cmd = cmd,
								cwd = run_dir,
								components = { 'default' },
								strategy = {
									'toggleterm',
									direction = 'float',
								},
							}
						end,
					}
				end)
			end)
		end, { desc = 'run selected build.sh' })
	end,
}
