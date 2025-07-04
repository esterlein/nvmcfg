vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- visual block remap
vim.keymap.set('n', 'zv', '<C-v>')

-- newline remap

vim.keymap.set('n', 'O', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
vim.keymap.set('n', 'o', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")

-- split navigation :help wincmd

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

-- semicolon at eol

vim.keymap.set('n', '<leader>;', function()
	local cursor = vim.api.nvim_win_get_cursor(0)
	vim.cmd 'norm A;'
	vim.api.nvim_win_set_cursor(0, cursor)
end, { noremap = true, silent = true })

-- dap ui

vim.keymap.set('n', '<leader>dfs', function()
	local widgets = require 'dap.ui.widgets'
	widgets.centered_float(widgets.scopes)
end, { desc = 'Focus on scopes' })

vim.keymap.set('n', '<leader>dj', function()
	require('dapui').eval(nil, { enter = true })
end, { desc = 'Jump to variable definition' })
