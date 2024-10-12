local api = vim.api
local buffer = require("nvim-surround.buffer")
local utils = require("smartqb.utils")
local config = require("smartqb.config")

local M = {}

-- Apply selection based on the current mode
---@param left_pos table The left position of the selection
---@param right_pos table The right position of the selection
local function apply_selection(left_pos, right_pos)
  local current_mode = vim.fn.mode()

  if current_mode == "o" or current_mode:sub(1, 1) == "v" then
    vim.fn.cursor(left_pos[1], left_pos[2])
    if current_mode:sub(1, 1) == "v" then
      vim.cmd("normal! o")
    end
    vim.fn.cursor(right_pos[1], right_pos[2])
  else
    vim.cmd("normal! v")
    vim.fn.cursor(left_pos[1], left_pos[2])
    vim.cmd("normal! o")
    vim.fn.cursor(right_pos[1], right_pos[2])
  end
end

-- Generic function to get the nearest selections for a pair of delimiters
---@param char string? A character representing what kind of surrounding pair is to be selected.
---@param mode "i"|"a" Inside or around
---@return table|nil A table containing the start and end positions of the delimiters, or nil if not found.
local function get_nearest_selections(char, mode)
  char = config.get_alias(char)
  local chars = config.get_opts().aliases[char] or { char }
  local curpos = buffer.get_curpos()
  local line = api.nvim_get_current_line()
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

-- Generic textobject function
---@param get_selections function Function to get the nearest selections
---@param mode 'i'|'a' Inside or around
function M.create_textobject(get_selections, mode)
  return function()
    local nearest_selections = get_selections(mode)
    if nearest_selections then
      local left_pos = nearest_selections.left.first_pos
      local right_pos = nearest_selections.right.first_pos
      apply_selection(left_pos, right_pos)
    end
  end
end

return M
