local api = vim.api
local utils = require("nvim-surround.utils")
local buffer = require("nvim-surround.buffer")
local config = require("nvim-surround.config")

local M = {}

-- Default configuration
M.config = {
  quotekey = "q",
  bracketkey = "b",
}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  require("smartqb.keymaps").setup()
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
      next_pos, quote_char = utils.find_next_unescaped_qb(line, start_col, chars)
    end

    if not next_pos then
      return nil
    end

    local count_left = utils.count_qb_to_left(line, is_on_quote and start_col or next_pos - 1, quote_char)
    local is_opening = count_left % 2 == 0
    local start_pos, end_pos

    if is_on_quote then
      if is_opening then
        start_pos = { curpos[1], next_pos }
        end_pos = { curpos[1], utils.find_matching_qb(line, next_pos, quote_char, 1) or next_pos }
      else
        end_pos = { curpos[1], next_pos }
        start_pos = { curpos[1], utils.find_matching_qb(line, next_pos, quote_char, -1) or next_pos }
      end
    else
      if is_opening then
        start_pos = { curpos[1], next_pos }
        end_pos = { curpos[1], utils.find_matching_qb(line, next_pos, quote_char, 1) or next_pos }
      else
        end_pos = { curpos[1], next_pos }
        start_pos = { curpos[1], utils.find_matching_qb(line, next_pos, quote_char, -1) or next_pos }
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

  ---@diagnostic disable-next-line: return-type-mismatch
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

return M
