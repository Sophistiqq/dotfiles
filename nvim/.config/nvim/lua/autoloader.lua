-- lua/autoloader.lua
local plugins_path = vim.fn.stdpath('config') .. '/lua/plugins'
local files = vim.fn.readdir(plugins_path)

for _, file in ipairs(files) do
  if file:match('%.lua$') then
    local plugin_name = file:gsub('%.lua$', '')
    require('plugins.' .. plugin_name)
  end
end
