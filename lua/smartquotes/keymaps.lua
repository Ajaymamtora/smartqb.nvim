local config = require("smartquotes.config")
local textobj = require("smartquotes.textobj")

local M = {}

function M.setup()
  local quotekey = config.get_config().quotekey
  local bracketkey = config.get_config().bracketkey

  vim.keymap.set({ "x", "o" }, "a" .. quotekey, function()
    textobj.quote_textobj("a")
  end, { desc = "around the quote" })

  vim.keymap.set({ "x", "o" }, "i" .. quotekey, function()
    textobj.quote_textobj("i")
  end, { desc = "inside the quote" })

  vim.keymap.set({ "x", "o" }, "a" .. bracketkey, function()
    textobj.bracket_textobj("a")
  end, { desc = "around the bracket" })

  vim.keymap.set({ "x", "o" }, "i" .. bracketkey, function()
    textobj.bracket_textobj("i")
  end, { desc = "inside the bracket" })
end

return M
