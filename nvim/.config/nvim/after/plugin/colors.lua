-- This file is loaded after all other configurations
-- You can use this to override plugin settings or add final configurations

-- Set colorscheme
vim.cmd([[colorscheme tokyonight]])

-- Additional color settings
vim.cmd([[
  hi Normal guibg=NONE ctermbg=NONE
  hi LineNr guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
  hi EndOfBuffer guibg=NONE ctermbg=NONE
]]) 