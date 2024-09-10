local api = vim.api
local utils = require("nvim-surround.utils")
local buffer = require("nvim-surround.buffer")
local config = require("nvim-surround.config")

local M = {}

-- Default configuration
M.config = {
  key = "q",
}

-- Setup function
function M.setup(opts)
  print(vim.inspect(opts))
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  M.setup_keymaps()
end

-- Count unescaped quotes to the left of the cursor
local function count_quotes_to_left(line, col, quote_char)
  local count = 0
  for i = 1, col do
    if line:sub(i, i) == quote_char and (i == 1 or line:sub(i - 1, i - 1) ~= "\\") then
      count = count + 1
    end
  end
  return count
end

-- Find the next unescaped quote position
local function find_next_unescaped_quote(line, col, quote_chars)
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

-- Find matching quote
local function find_matching_quote(line, start_pos, quote_char, direction)
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

-- Gets the nearest two selections for the left and right surrounding pair.
---@param char string? A character representing what kind of surrounding pair is to be selected.
---@param mode "i"|"a" Inside or around
---@return table A table containing the start and end positions of the delimiters.
local function get_nearest_selections(char, mode)
  char = config.get_alias(char)
  local chars = config.get_opts().aliases[char] or { char }
  local curpos = buffer.get_curpos()
  local line = api.nvim_get_current_line()
  local col = curpos[2] - 1 -- 0-indexed for string operations

  local function find_quote_pair(start_col)
    local current_char = line:sub(start_col + 1, start_col + 1)
    local is_on_quote = vim.tbl_contains(chars, current_char)

    local next_pos, quote_char
    if is_on_quote then
      next_pos, quote_char = start_col + 1, current_char
    else
      next_pos, quote_char = find_next_unescaped_quote(line, start_col, chars)
    end

    if not next_pos then
      return nil
    end

    local count_left = count_quotes_to_left(line, is_on_quote and start_col or next_pos - 1, quote_char)
    local is_opening = count_left % 2 == 0
    local start_pos, end_pos

    if is_on_quote then
      if is_opening then
        start_pos = { curpos[1], next_pos }
        end_pos = { curpos[1], find_matching_quote(line, next_pos, quote_char, 1) or next_pos }
      else
        end_pos = { curpos[1], next_pos }
        start_pos = { curpos[1], find_matching_quote(line, next_pos, quote_char, -1) or next_pos }
      end
    else
      if is_opening then
        start_pos = { curpos[1], next_pos }
        end_pos = { curpos[1], find_matching_quote(line, next_pos, quote_char, 1) or next_pos }
      else
        end_pos = { curpos[1], next_pos }
        start_pos = { curpos[1], find_matching_quote(line, next_pos, quote_char, -1) or next_pos }
      end
    end

    if not start_pos[2] or not end_pos[2] then
      return nil
    end

    if mode == "i" then
      start_pos[2] = start_pos[2] + 1
      end_pos[2] = end_pos[2] - 1
    end

    return {
      left = { first_pos = start_pos },
      right = { first_pos = end_pos },
    }
  end

  return find_quote_pair(col)
end

--- quote textobject
---@param mode 'i'|'a' Inside or around
function M.quote_textobj(mode)
  local nearest_selections = get_nearest_selections("q", mode)
  if nearest_selections then
    local left_pos = nearest_selections.left.first_pos
    local right_pos = nearest_selections.right.first_pos

    -- Save the current mode
    local current_mode = vim.fn.mode()

    -- If we're in operator-pending mode or visual mode, we need to set the selection
    if current_mode == "o" or current_mode:sub(1, 1) == "v" then
      -- Move to the start of the selection
      vim.fn.cursor(left_pos[1], left_pos[2])

      -- If we're in visual mode, we need to extend the selection
      if current_mode:sub(1, 1) == "v" then
        vim.cmd("normal! o")
      end

      -- Move to the end of the selection
      vim.fn.cursor(right_pos[1], right_pos[2])
    else
      -- If we're in normal mode, enter visual mode and set the selection
      vim.cmd("normal! v")
      vim.fn.cursor(left_pos[1], left_pos[2])
      vim.cmd("normal! o")
      vim.fn.cursor(right_pos[1], right_pos[2])
    end
  end
end

-- Function to set up keymaps
function M.setup_keymaps()
  vim.keymap.set({ "x", "o" }, "a" .. M.config.key, function()
    M.quote_textobj("a")
  end, { desc = "around the quote" })

  vim.keymap.set({ "x", "o" }, "i" .. M.config.key, function()
    M.quote_textobj("i")
  end, { desc = "inside the quote" })
end

return M
