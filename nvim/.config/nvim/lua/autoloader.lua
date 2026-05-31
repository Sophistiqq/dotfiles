-- lua/autoloader.lua
local plugins_path = vim.fn.stdpath('config') .. '/lua/plugins'
local files = vim.fn.readdir(plugins_path)

for _, file in ipairs(files) do
  if file:match('%.lua$') then
    local plugin_name = file:gsub('%.lua$', '')
    local status, err = pcall(require, 'plugins.' .. plugin_name)
    if not status then
      vim.notify("Error loading plugin " .. plugin_name .. ": " .. err, vim.log.levels.ERROR)
    end
  end
end
