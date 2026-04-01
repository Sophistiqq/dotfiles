vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" },
})
require("everforest").setup({
  transparent_background_level = 1,
})


local function set_colorscheme(name)
  vim.cmd("colorscheme " .. name)

  -- save to file
  local path = vim.fn.stdpath("config") .. "/configs.lua"
  local file = io.open(path, "w")
  if file then
    file:write('vim.cmd("colorscheme ' .. name .. '")')
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
