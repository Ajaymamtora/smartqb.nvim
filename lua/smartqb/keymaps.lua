local config = require("smartqb.config")
local textobj = require("smartqb.textobj")

local M = {}

function M.setup()
  local key = config.get_config().quotekey

  vim.keymap.set({ "x", "o" }, "a" .. key, function()
    textobj.quote_textobj("a")
  end, { desc = "around the quote" })

  vim.keymap.set({ "x", "o" }, "i" .. key, function()
    textobj.quote_textobj("i")
  end, { desc = "inside the quote" })
end

return M
