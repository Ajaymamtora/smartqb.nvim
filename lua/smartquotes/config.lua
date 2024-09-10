local M = {}

M.default_config = {
  key = "q",
}

M.config = M.default_config

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.default_config, opts or {})
end

function M.get_config()
  return M.config
end

return M
