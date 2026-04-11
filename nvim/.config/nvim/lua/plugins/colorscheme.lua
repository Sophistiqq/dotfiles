vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" },
})
require("everforest").setup({
  transparent_background_level = 1,
})

function set_colorscheme(name)
  vim.cmd("colorscheme " .. name)

  -- save to file
  local path = vim.fn.stdpath("config") .. "/lua/.colorscheme"
  local file = io.open(path, "w")
  if file then
    file:write(name)
    file:close()
  end
end

-- Colorscheme
vim.keymap.set("n", "<leader>th", function()
  require("telescope.builtin").colorscheme({
    enable_preview = true,
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        set_colorscheme(selection.value)
      end)
      return true
    end,
  })
end, { desc = "[F]ind Colorscheme" })

-- Load saved colorscheme preference
local colorscheme_file = vim.fn.stdpath("config") .. "/lua/.colorscheme"
local f = io.open(colorscheme_file, "r")
if f then
  local saved = f:read("*l")
  f:close()
  if saved and saved ~= "" then
    vim.cmd("colorscheme " .. saved)
  else
    vim.cmd("colorscheme everforest")
  end
else
  vim.cmd("colorscheme everforest")
end
