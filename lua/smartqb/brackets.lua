local utils = require("smartqb.utils")
local config = require("smartqb.config")

local M = {}

--- Finds the matching bracket in the specified direction
---@param line string The line to search
---@param start_pos number The starting position
---@param bracket_char string The bracket character to match
---@param direction number 1 for forward, -1 for backward
---@return number|nil The position of the matching bracket, or nil if not found
local function find_matching_bracket(line, start_pos, bracket_char, direction)
  local depth = 0
  local pos = start_pos + direction
  local end_pos = direction == 1 and #line or 1

  local is_opening = utils.is_opening_bracket(bracket_char)
  local matching_char = is_opening and utils.get_matching_closing_bracket(bracket_char)
    or utils.get_matching_opening_bracket(bracket_char)

  while pos >= 1 and pos <= #line do
    local char = line:sub(pos, pos)
    if char == bracket_char then
      depth = depth + 1
    elseif char == matching_char then
      if depth == 0 then
        return pos
      end
      depth = depth - 1
    end
    pos = pos + direction
  end
  return nil
end

--- Gets the nearest bracket selections
---@param mode "i"|"a" Inside or around
---@return table|nil A table containing the start and end positions of the delimiters, or nil if not found.
function M.get_nearest_selections(mode)
  local char = config.get_alias("b")
  local chars = config.get_opts().aliases[char] or { char }
  local curpos = require("nvim-surround.buffer").get_curpos()
  local line = vim.api.nvim_get_current_line()
  local col = curpos[2] - 1 -- 0-indexed for string operations

  local function find_bracket_pair(start_col)
    -- Look forward for the next bracket
    for i = start_col + 1, #line do
      local current_char = line:sub(i, i)
      if utils.is_opening_bracket(current_char) then
        local end_pos = find_matching_bracket(line, i, current_char, 1)
        if end_pos then
          return { start_pos = { curpos[1], i }, end_pos = { curpos[1], end_pos } }
        end
      elseif utils.is_closing_bracket(current_char) then
        local start_pos = find_matching_bracket(line, i, current_char, -1)
        if start_pos then
          return { start_pos = { curpos[1], start_pos }, end_pos = { curpos[1], i } }
        end
      end
    end

    -- If no bracket found forward, look backward
    for i = start_col, 1, -1 do
      local current_char = line:sub(i, i)
      if utils.is_opening_bracket(current_char) then
        local end_pos = find_matching_bracket(line, i, current_char, 1)
        if end_pos then
          return { start_pos = { curpos[1], i }, end_pos = { curpos[1], end_pos } }
        end
      elseif utils.is_closing_bracket(current_char) then
        local start_pos = find_matching_bracket(line, i, current_char, -1)
        if start_pos then
          return { start_pos = { curpos[1], start_pos }, end_pos = { curpos[1], i } }
        end
      end
    end
    return nil
  end

  local pair = find_bracket_pair(col)
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
