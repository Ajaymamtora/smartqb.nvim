local M = {}

function M.get_curpos()
  return vim.api.nvim_win_get_cursor(0)
end

return M
