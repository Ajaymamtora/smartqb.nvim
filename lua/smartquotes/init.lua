local config = require("smart-quotes.config")
local textobj = require("smart_quotes.textobj")

---@class QuoteTextObj
local M = {}

---@param args Config?
-- Setup function to initialize the plugin with user configurations
function M.setup(args)
  print(vim.inspect(args))
  config.setup(args)

  -- Set up keymaps for the quote textobject
  vim.keymap.set({ "x", "o" }, "a" .. config.options.key, function()
    textobj.quote_textobj("a")
  end, { desc = "Select around the quote" })

  vim.keymap.set({ "x", "o" }, "i" .. config.options.key, function()
    textobj.quote_textobj("i")
  end, { desc = "Select inside the quote" })
end

return M
