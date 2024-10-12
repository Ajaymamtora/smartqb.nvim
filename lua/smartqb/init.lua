local config = require("smartqb.config")
local textobj = require("smartqb.textobj")
local quotes = require("smartqb.quotes")
local brackets = require("smartqb.brackets")

local M = {}

-- Setup function
function M.setup(opts)
  config.setup(opts)
  M.setup_keymaps()
end

-- Function to set up keymaps
function M.setup_keymaps()
  local quotekey = config.get_config().quotekey
  vim.keymap.set(
    { "x", "o" },
    "a" .. quotekey,
    textobj.create_textobject(quotes.get_nearest_selections, "a"),
    { desc = "around the quote" }
  )
  vim.keymap.set(
    { "x", "o" },
    "i" .. quotekey,
    textobj.create_textobject(quotes.get_nearest_selections, "i"),
    { desc = "inside the quote" }
  )

  local bracketkey = config.get_config().bracketkey
  -- Add keymaps for brackets
  vim.keymap.set(
    { "x", "o" },
    "a" .. bracketkey,
    textobj.create_textobject(brackets.get_nearest_selections, "a"),
    { desc = "around the bracket" }
  )
  vim.keymap.set(
    { "x", "o" },
    "i" .. bracketkey,
    textobj.create_textobject(brackets.get_nearest_selections, "i"),
    { desc = "inside the bracket" }
  )
end

return M
