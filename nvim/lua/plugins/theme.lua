local function active_theme()
  local f = io.open(vim.fn.expand("~/.config/themes/current"), "r")
  if f then
    local t = f:read("*l")
    f:close()
    return t or "nord"
  end
  return "nord"
end

local theme = active_theme()

return {
  {
    "shaunsingh/nord.nvim",
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_disable_background = true
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "dawn",
      disable_background = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme == "rosepine" and "rose-pine" or "nord",
    },
  },
}
