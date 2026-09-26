return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
    styles = {
      comments = { italic = true },
      keywords = { italic = true, bold = true },
      functions = { bold = true },
    },
    on_colors = function(colors)
      -- Push the syntax palette a bit brighter
      colors.blue = "#6cb6ff"
      colors.magenta = "#d58cff"
      colors.green = "#a6f06a"
      colors.orange = "#ffa24c"
      colors.cyan = "#4fe0ff"
    end,
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight")
  end,
}
