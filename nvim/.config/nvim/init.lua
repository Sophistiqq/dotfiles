-- Enable Neovim Lua module bytecode loader for faster startup
if vim.loader then
  vim.loader.enable()
end

-- Register vim.pack lifecycle hooks BEFORE any vim.pack.add() calls
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("UserPackHooks", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "blink.cmp" then
      if not ev.data.active then
        pcall(vim.cmd.packadd, "blink.lib")
        pcall(vim.cmd.packadd, "blink.cmp")
      end
      local ok, cmp = pcall(require, "blink.cmp")
      if ok and cmp.build then
        cmp.build():pwait()
      end
    elseif name == "telescope-fzf-native.nvim" then
      local is_win = vim.fn.has("win32") == 1
      if is_win and vim.fn.executable("cmake") == 1 then
        local cfg = vim.system(
          { "cmake", "-S.", "-Bbuild", "-DCMAKE_BUILD_TYPE=Release" },
          { cwd = ev.data.path }
        ):wait()
        if cfg.code == 0 then
          vim.system({ "cmake", "--build", "build", "--config", "Release" }, { cwd = ev.data.path }):wait()
        end
      elseif not is_win and vim.fn.executable("make") == 1 then
        vim.system({ "make" }, { cwd = ev.data.path }):wait()
      end
    end
  end,
})

require("options")
require("autoloader")
require("configs.lspconfig")
require("configs.terminal")
require("configs.session")
require("configs.statusline")
require("configs.tabline")
require("configs.cheatsheet")
require("configs.efcore")
require("keymaps")
