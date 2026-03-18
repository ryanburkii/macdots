vim.opt.relativenumber = false
-- Auto-open neo-tree on startup
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("Neotree show")
		end
	end,
})
