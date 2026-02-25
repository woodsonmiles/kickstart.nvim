-- Restore <CR> behavior in quickfix window
vim.keymap.set('n', '<CR>', '<CR>', { buffer = true, silent = true })
-- Optional: also restore Shift-CR if needed
vim.keymap.set('n', '<S-CR>', '<S-CR>', { buffer = true, silent = true })
