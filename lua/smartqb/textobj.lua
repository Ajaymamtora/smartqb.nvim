local api = vim.api
local utils = require("smartqb.utils")

local M = {}

local function find_next_quote(line, start, chars)
  for i = start, #line do
    if vim.tbl_contains(chars, line:sub(i, i)) then
      return i
    end
  end
  return nil
end

local function find_matching_quote(line, start, chars)
  local nested = 0
  for i = start + 1, #line do
    if vim.tbl_contains(chars, line:sub(i, i)) then
      if nested == 0 then
        return i
      end
      nested = nested - 1
    end
  end
  return nil
end

local function get_inner_quote_selection(char)
  local chars = { char }
  local curpos = utils.get_curpos()
  local line = api.nvim_get_current_line()
  local col = curpos[2]

  local function find_valid_pair(start)
    local left_quote = find_next_quote(line, start, chars)
    if not left_quote then
      return nil
    end

    local right_quote = find_matching_quote(line, left_quote, chars)
    if not right_quote then
      return nil
    end

    if right_quote - left_quote > 1 then
      return left_quote, right_quote
    else
      return find_valid_pair(right_quote + 1)
    end
  end

  local left_quote, right_quote = find_valid_pair(1)

  if not left_quote or not right_quote then
    return nil
  end

  return {
    left = { first_pos = { curpos[1], left_quote + 1 } },
    right = { first_pos = { curpos[1], right_quote - 1 } },
  }
end

local function get_around_quote_selection(char)
  local chars = { char }
  local curpos = utils.get_curpos()
  local line = api.nvim_get_current_line()
  local col = curpos[2]

  local left_quote = find_next_quote(line, 1, chars)
  if not left_quote then
    return nil
  end

  local right_quote = find_matching_quote(line, left_quote, chars)
  if not right_quote then
    return nil
  end

  return {
    left = { first_pos = { curpos[1], left_quote } },
    right = { first_pos = { curpos[1], right_quote } },
  }
end

function M.quote_textobj(mode)
  local selections
  if mode == "i" then
    selections = get_inner_quote_selection("q")
  else
    selections = get_around_quote_selection("q")
  end

  if selections then
    local left_pos = selections.left.first_pos
    local right_pos = selections.right.first_pos

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
end

return M
