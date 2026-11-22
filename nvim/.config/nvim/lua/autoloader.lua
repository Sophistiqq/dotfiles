-- lua/autoloader.lua
-- Pure-Lua directory scan using vim.fs (faster than vim.fn.readdir & Windows-safe)
local plugins_path = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins")
local files = {}

for name, entry_type in vim.fs.dir(plugins_path) do
  if (entry_type == "file" or entry_type == "link") and name:match("%.lua$") then
    table.insert(files, name)
  end
end

table.sort(files)

for _, file in ipairs(files) do
  local plugin_name = file:gsub("%.lua$", "")
  local ok, err = pcall(require, "plugins." .. plugin_name)
  if not ok then
    vim.notify("Error loading plugin " .. plugin_name .. ": " .. tostring(err), vim.log.levels.ERROR)
  end
end
