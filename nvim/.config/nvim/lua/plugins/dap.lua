vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
})

local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
  return
end

local is_win = vim.fn.has("win32") == 1
local exe_ext = is_win and ".exe" or ""

local dapui_ok, dapui = pcall(require, "dapui")
if dapui_ok then
  dapui.setup()

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({ reset = true })
  end
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close
end

-- Helper to locate a Mason-installed or PATH executable cross-platform
local function find_tool(bin_name, mason_subpath)
  local in_path = vim.fn.exepath(bin_name)
  if in_path ~= "" then
    return in_path
  end
  local mason_bin = vim.fs.joinpath(
    vim.fn.stdpath("data"),
    "mason",
    "bin",
    bin_name .. (is_win and ".cmd" or "")
  )
  if vim.uv.fs_stat(mason_bin) then
    return mason_bin
  end
  if mason_subpath then
    return vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", unpack(mason_subpath))
  end
  return bin_name
end

----- [ C# / .NET (netcoredbg) ] -----
dap.adapters.coreclr = {
  type = "executable",
  command = find_tool("netcoredbg", { "netcoredbg", "netcoredbg", "netcoredbg" .. exe_ext }),
  args = { "--interpreter=vscode" },
}

local function find_dotnet_dll()
  local cwd = vim.fn.getcwd()
  vim.notify("Running dotnet build...", vim.log.levels.INFO)
  local res = vim.system({ "dotnet", "build" }, { cwd = cwd, text = true }):wait()
  if res.code ~= 0 then
    vim.notify("dotnet build failed:\n" .. (res.stdout or "") .. (res.stderr or ""), vim.log.levels.ERROR)
    return dap.ABORT
  end
  vim.notify("dotnet build succeeded", vim.log.levels.INFO)

  -- Try to auto-locate a matching <ProjectName>.dll under bin/Debug/
  local csproj = vim.fs.find(function(name)
    return name:match("%.csproj$") ~= nil
  end, { path = cwd, type = "file", limit = 1 })[1]

  local default_dir = vim.fs.joinpath(cwd, "bin", "Debug")
  if csproj then
    local proj_dir = vim.fs.dirname(csproj)
    local proj_name = vim.fn.fnamemodify(csproj, ":t:r")
    local debug_dir = vim.fs.joinpath(proj_dir, "bin", "Debug")
    if vim.uv.fs_stat(debug_dir) then
      local dlls = vim.fs.find(proj_name .. ".dll", { path = debug_dir, type = "file", limit = 1 })
      if dlls[1] then
        return vim.fn.input("Path to dll: ", dlls[1], "file")
      end
      default_dir = debug_dir
    end
  end

  return vim.fn.input("Path to dll: ", default_dir .. "/", "file")
end

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch (.NET Core)",
    request = "launch",
    program = find_dotnet_dll,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    console = "integratedTerminal",
    env = {
      ASPNETCORE_ENVIRONMENT = "Development",
    },
  },
  {
    type = "coreclr",
    name = "Attach (.NET Process)",
    request = "attach",
    processId = function()
      return require("dap.utils").pick_process()
    end,
  },
}

----- [ Rust (codelldb) ] -----
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = find_tool("codelldb", { "codelldb", "extension", "adapter", "codelldb" .. exe_ext }),
    args = { "--port", "${port}" },
  },
}

dap.configurations.rust = {
  {
    name = "Launch (cargo build)",
    type = "codelldb",
    request = "launch",
    program = function()
      local cwd = vim.fn.getcwd()
      vim.notify("Running cargo build...", vim.log.levels.INFO)
      local res = vim.system({ "cargo", "build" }, { cwd = cwd, text = true }):wait()
      if res.code ~= 0 then
        vim.notify("cargo build failed:\n" .. (res.stderr or res.stdout or ""), vim.log.levels.ERROR)
        return dap.ABORT
      end
      vim.notify("Build OK", vim.log.levels.INFO)
      local cargo_toml = vim.fs.joinpath(cwd, "Cargo.toml")
      if vim.uv.fs_stat(cargo_toml) then
        for _, line in ipairs(vim.fn.readfile(cargo_toml)) do
          local name = line:match('^name%s*=%s*"(.+)"')
          if name then
            return vim.fs.joinpath(cwd, "target", "debug", name .. exe_ext)
          end
        end
      end
      return vim.fn.input("Path to executable: ", vim.fs.joinpath(cwd, "target", "debug") .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

----- [ DAP Keymaps ] -----
local map = vim.keymap.set
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Continue / Start debug" })
map("n", "<leader>do", dap.step_over, { desc = "Step over" })
map("n", "<leader>di", dap.step_into, { desc = "Step into" })
map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
map("n", "<leader>dt", dap.terminate, { desc = "Terminate debug session" })
map("n", "<leader>du", function()
  local ok, ui = pcall(require, "dapui")
  if ok then
    ui.toggle()
  end
end, { desc = "Toggle DAP UI" })
