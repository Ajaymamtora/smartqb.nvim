local M = {}

--- Counts unescaped characters to the left of the cursor
---@param line string The line to search
---@param col number The column to start searching from
---@param char string The character to count
---@return number The number of unescaped characters
function M.count_chars_to_left(line, col, char)
  local count = 0
  for i = 1, col do
    if line:sub(i, i) == char and (i == 1 or line:sub(i - 1, i - 1) ~= "\\") then
      count = count + 1
    end
  end
  return count
end

--- Finds the next unescaped character position
---@param line string The line to search
---@param col number The column to start searching from
---@param chars table Array of characters to search for
---@return number|nil, string|nil The position of the next unescaped character and the character, or nil if not found
function M.find_next_unescaped_char(line, col, chars)
  for i = col + 1, #line do
    local char = line:sub(i, i)
    if vim.tbl_contains(chars, char) then
      if i == 1 or line:sub(i - 1, i - 1) ~= "\\" then
        return i, char
      end
    end
  end
  return nil, nil
end

--- Finds matching character
---@param line string The line to search
---@param start_pos number The starting position
---@param char string The character to match
---@param direction number 1 for forward, -1 for backward
---@return number|nil The position of the matching character, or nil if not found
function M.find_matching_char(line, start_pos, char, direction)
  local pos = direction == 1 and start_pos + 1 or start_pos - 1
  local end_pos = direction == 1 and #line or 1
  while pos >= 1 and pos <= #line do
    if line:sub(pos, pos) == char and (pos == 1 or line:sub(pos - 1, pos - 1) ~= "\\") then
      return pos
    end
    pos = pos + direction
  end
  return nil
end

-- Find delimiter pair in the current line
---@param start_col number The column to start searching from
---@param chars table Array of delimiter characters to search for
---@param line string The line to search
---@param curpos table The current cursor position
---@return table|nil A table containing the start and end positions of the delimiter pair, or nil if not found
function M.find_delimiter_pair(start_col, chars, line, curpos)
  local current_char = line:sub(start_col + 1, start_col + 1)
  local is_on_delimiter = vim.tbl_contains(chars, current_char)

  local next_pos, delimiter_char
  if is_on_delimiter then
    next_pos, delimiter_char = start_col + 1, current_char
  else
    next_pos, delimiter_char = M.find_next_unescaped_char(line, start_col, chars)
  end

  if not next_pos then
    return nil
  end

  local count_left = M.count_chars_to_left(line, is_on_delimiter and start_col or next_pos - 1, delimiter_char)
  local is_opening = count_left % 2 == 0
  local start_pos, end_pos

  if is_on_delimiter then
    if is_opening then
      start_pos = { curpos[1], next_pos }
      end_pos = { curpos[1], M.find_matching_char(line, next_pos, delimiter_char, 1) or next_pos }
    else
      end_pos = { curpos[1], next_pos }
      start_pos = { curpos[1], M.find_matching_char(line, next_pos, delimiter_char, -1) or next_pos }
    end
  else
    if is_opening then
      start_pos = { curpos[1], next_pos }
      end_pos = { curpos[1], M.find_matching_char(line, next_pos, delimiter_char, 1) or next_pos }
    else
      end_pos = { curpos[1], next_pos }
      start_pos = { curpos[1], M.find_matching_char(line, next_pos, delimiter_char, -1) or next_pos }
    end
  end

  if not start_pos[2] or not end_pos[2] then
    return nil
  end

  return { start_pos = start_pos, end_pos = end_pos }
end

--- Determines if a character is an opening bracket
---@param char string The character to check
---@return boolean True if the character is an opening bracket, false otherwise
function M.is_opening_bracket(char)
  return vim.tbl_contains({ "{", "(", "[" }, char)
end

--- Determines if a character is a closing bracket
---@param char string The character to check
---@return boolean True if the character is a closing bracket, false otherwise
function M.is_closing_bracket(char)
  return vim.tbl_contains({ "}", ")", "]" }, char)
end

--- Gets the matching closing bracket for an opening bracket
---@param opening_char string The opening bracket character
---@return string The matching closing bracket character
function M.get_matching_closing_bracket(opening_char)
  local pairs = { ["{"] = "}", ["("] = ")", ["["] = "]" }
  return pairs[opening_char]
end

--- Gets the matching opening bracket for a closing bracket
---@param closing_char string The closing bracket character
---@return string The matching opening bracket character
function M.get_matching_opening_bracket(closing_char)
  local pairs = { ["}"] = "{", [")"] = "(", ["]"] = "[" }
  return pairs[closing_char]
end

return M
