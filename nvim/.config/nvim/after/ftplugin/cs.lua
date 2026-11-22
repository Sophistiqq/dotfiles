-- C# standard 4-space indentation
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4

-- Quickfix-friendly dotnet compiler integration
vim.bo.makeprg = "dotnet build --nologo -v quiet"

-- Buffer-local C# / .NET helper commands
vim.api.nvim_buf_create_user_command(0, "DotnetBuild", function()
  vim.cmd("botright split | terminal dotnet build")
end, { desc = "Run dotnet build" })

vim.api.nvim_buf_create_user_command(0, "DotnetTest", function()
  vim.cmd("botright split | terminal dotnet test")
end, { desc = "Run dotnet test" })

vim.api.nvim_buf_create_user_command(0, "DotnetRestore", function()
  vim.cmd("botright split | terminal dotnet restore")
end, { desc = "Run dotnet restore" })
