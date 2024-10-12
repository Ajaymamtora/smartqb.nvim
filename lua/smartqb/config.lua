local M = {}

M.default_config = {
  quotekey = "q",
  aliases = {
    ["q"] = { "'", '"', "`" },
  },
}

M.config = M.default_config

--- Setup function for configuration
---@param opts table? Optional configuration table
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.default_config, opts or {})
end

--- Get the current configuration
---@return table The current configuration
function M.get_config()
  return M.config
end

--- Get the alias for a given character
---@param char string The character to get the alias for
---@return string The alias for the given character
function M.get_alias(char)
  return char or M.config.quotekey
end

--- Get the options for the plugin
---@return table The options for the plugin
function M.get_opts()
  return M.config
end

return M
