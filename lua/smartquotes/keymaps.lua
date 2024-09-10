local config = require("smartquotes.config")
local textobj = require("smartquotes.textobj")

local M = {}

function M.setup()
  local key = config.get_config().key

  vim.keymap.set({ "x", "o" }, "a" .. key, function()
    textobj.quote_textobj("a")
  end, { desc = "around the quote" })

  vim.keymap.set({ "x", "o" }, "i" .. key, function()
    textobj.quote_textobj("i")
  end, { desc = "inside the quote" })
end

return M
