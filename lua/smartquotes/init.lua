local config = require("smartquotes.config")
local textobj = require("smartquotes.textobj")

---@class SmartQuotes
local M = {}

-- Internal setup function
local function setup_plugin(opts)
  config.setup(opts)

  -- Set up keymaps for the quote textobject
  vim.keymap.set({ "x", "o" }, "a" .. config.options.key, function()
    textobj.quote_textobj("a")
  end, { desc = "Select around the quote" })

  vim.keymap.set({ "x", "o" }, "i" .. config.options.key, function()
    textobj.quote_textobj("i")
  end, { desc = "Select inside the quote" })
end

---@param args Config?
-- Setup function to initialize the plugin with user configurations
function M.setup(args)
  -- If setup is called directly, use the provided args
  setup_plugin(args)
end

-- Return the module table
return setmetatable(M, {
  -- Handle the case where the module is called like a function
  __call = function(_, args)
    setup_plugin(args)
  end,
})
