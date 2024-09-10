---@class Config
---@field key string The textobject key
local default_config = {
  key = "q",
}

local M = {}

M.options = default_config

---@param opts Config?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", default_config, opts or {})
end

return M
