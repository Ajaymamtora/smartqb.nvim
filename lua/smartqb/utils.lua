local M = {}

--- Counts unescaped quotes to the left of the cursor
---@param line string The line to search
---@param col number The column to start searching from
---@param quote_char string The quote character to count
---@return number The number of unescaped quotes
function M.count_quotes_to_left(line, col, quote_char)
  local count = 0
  for i = 1, col do
    if line:sub(i, i) == quote_char and (i == 1 or line:sub(i - 1, i - 1) ~= "\\") then
      count = count + 1
    end
  end
  return count
end

--- Finds the next unescaped quote position
---@param line string The line to search
---@param col number The column to start searching from
---@param quote_chars table Array of quote characters to search for
---@return number|nil, string|nil The position of the next unescaped quote and the quote character, or nil if not found
function M.find_next_unescaped_quote(line, col, quote_chars)
  for i = col + 1, #line do
    local char = line:sub(i, i)
    if vim.tbl_contains(quote_chars, char) then
      if i == 1 or line:sub(i - 1, i - 1) ~= "\\" then
        return i, char
      end
    end
  end
  return nil, nil
end

--- Finds matching quote
---@param line string The line to search
---@param start_pos number The starting position
---@param quote_char string The quote character to match
---@param direction number 1 for forward, -1 for backward
---@return number|nil The position of the matching quote, or nil if not found
function M.find_matching_quote(line, start_pos, quote_char, direction)
  local pos = direction == 1 and start_pos + 1 or start_pos - 1
  local end_pos = direction == 1 and #line or 1
  while pos >= 1 and pos <= #line do
    if line:sub(pos, pos) == quote_char and (pos == 1 or line:sub(pos - 1, pos - 1) ~= "\\") then
      return pos
    end
    pos = pos + direction
  end
  return nil
end

return M
