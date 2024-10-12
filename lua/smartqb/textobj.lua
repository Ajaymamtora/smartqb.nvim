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
