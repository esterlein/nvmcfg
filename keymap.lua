vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- newline remap

vim.keymap.set('n', 'O', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
vim.keymap.set('n', 'o', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")

-- split navigation :help wincmd

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- semicolon at eol

vim.keymap.set('n', '<leader>;', function()
	local cursor = vim.api.nvim_win_get_cursor(0)
	vim.cmd 'norm A;'
	vim.api.nvim_win_set_cursor(0, cursor)
end, { noremap = true, silent = true })
