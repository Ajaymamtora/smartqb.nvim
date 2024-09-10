vim.api.nvim_create_user_command("MyFirstFunction", require("plugin.smart_quotes").hello, {})
