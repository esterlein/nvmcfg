return {
	'stevearc/overseer.nvim',
	lazy = false,
	opts = {
		strategy = {
			'toggleterm',
			direction = 'float',
		},
	},
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function(_, opts)
		local overseer = require 'overseer'
		local Path = require 'plenary.path'
		local scan = require 'plenary.scandir'

		overseer.setup(opts)

		vim.keymap.set('n', '<leader>br', function()
			overseer.rerun_last()
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
				if not selected then
					return
				end

				vim.ui.input({ prompt = 'arguments:' }, function(args)
					local dir = Path:new(selected):parent().filename
					local cmd = { './build.sh' }

					for arg in string.gmatch(args or '', '%S+') do
						table.insert(cmd, arg)
					end

					overseer.run_template {
						name = 'run build.sh',
						builder = function()
							return {
								cmd = cmd,
								cwd = dir,
								components = { 'default' },
							}
						end,
					}
				end)
			end)
		end, { desc = 'run selected build.sh' })
	end,
}
