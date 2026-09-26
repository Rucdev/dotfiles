-- tree-sitter のパーサ / クエリは Nix (home/neovim.nix) で stdpath("data")/site に配置する。
-- Neovim 本体はバンドル済みの言語 (lua, markdown など) しか自動でハイライトしないので、
-- それ以外はパーサがあれば FileType で vim.treesitter.start() する。
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

return {}
