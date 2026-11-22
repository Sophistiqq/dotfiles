vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" },
  { src = "https://github.com/folke/tokyonight.nvim" },
})

require("everforest").setup({
  transparent_background_level = 1,
})

local state_dir = vim.fn.stdpath("state")
local colorscheme_file = vim.fs.joinpath(state_dir, "colorscheme")

local function set_colorscheme(name)
  local ok = pcall(vim.cmd.colorscheme, name)
  if not ok then
    return
  end
  if vim.fs.mkdir then
    vim.fs.mkdir(state_dir, { parents = true })
  else
    vim.fn.mkdir(state_dir, "p")
  end
  local file = io.open(colorscheme_file, "w")
  if file then
    file:write(name)
    file:close()
  end
end

vim.keymap.set("n", "<leader>th", function()
  require("telescope.builtin").colorscheme({
    enable_preview = true,
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        if selection and selection.value then
          set_colorscheme(selection.value)
        end
      end)
      return true
    end,
  })
end, { desc = "Find Colorscheme" })

-- Load saved colorscheme preference from stdpath("state")
local saved = nil
local f = io.open(colorscheme_file, "r")
if f then
  saved = f:read("*l")
  f:close()
end

if saved and saved ~= "" then
  if not pcall(vim.cmd.colorscheme, saved) then
    vim.cmd.colorscheme("everforest")
  end
else
  vim.cmd.colorscheme("everforest")
end
