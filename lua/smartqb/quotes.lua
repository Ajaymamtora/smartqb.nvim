local utils = require("smartqb.utils")
local config = require("smartqb.config")

local M = {}

-- Gets the nearest quote selections
---@param mode "i"|"a" Inside or around
---@return table|nil A table containing the start and end positions of the delimiters, or nil if not found.
function M.get_nearest_selections(mode)
  local char = config.get_alias("q")
  local chars = config.get_opts().aliases[char] or { char }
  local curpos = require("nvim-surround.buffer").get_curpos()
  local line = vim.api.nvim_get_current_line()
  local col = curpos[2] - 1 -- 0-indexed for string operations

  local pair = utils.find_delimiter_pair(col, chars, line, curpos)
  if not pair then
    return nil
  end

  if mode == "i" then
    pair.start_pos[2] = pair.start_pos[2] + 1
    pair.end_pos[2] = pair.end_pos[2] - 1
  end

  return {
    left = { first_pos = pair.start_pos },
    right = { first_pos = pair.end_pos },
  }
end

return M
