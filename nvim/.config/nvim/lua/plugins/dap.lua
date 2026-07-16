vim.pack.add({
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
})

local dap_ok, dap = pcall(require, 'dap')
if not dap_ok then
  return
end

local dapui_ok, dapui = pcall(require, 'dapui')
if dapui_ok then
  dapui.setup()

  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open({ reset = true })
  end
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close
end

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb',
    args = { '--port', '${port}' },
  },
}

dap.configurations.rust = {
  {
    name = 'Launch (cargo build)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      vim.notify('Building...', vim.log.levels.INFO)
      local result = vim.fn.system('cargo build 2>&1')
      if vim.v.shell_error ~= 0 then
        vim.notify('Build failed:\n' .. result, vim.log.levels.ERROR)
        return nil
      end
      vim.notify('Build OK', vim.log.levels.INFO)
      local lines = vim.fn.readfile(vim.fn.getcwd() .. '/Cargo.toml')
      for _, l in ipairs(lines) do
        local name = l:match('^name%s*=%s*"(.+)"')
        if name then
          return vim.fn.getcwd() .. '/target/debug/' .. name
        end
      end
      return vim.fn.getcwd() .. '/target/debug/'
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}


vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step over' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step into' })
vim.keymap.set('n', '<leader>du', function()
  pcall(require('dapui').toggle)
end, { desc = 'Toggle DAP UI' })
