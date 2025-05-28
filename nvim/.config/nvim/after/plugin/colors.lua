function ColorMyPencils(color)
	-- switch to a higher-contrast theme
	color = color or "tokyonight"

	vim.cmd.colorscheme(color)

	-- disable transparent background overrides for better contrast
	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()
