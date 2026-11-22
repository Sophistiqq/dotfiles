-- Native Neovim 0.12/0.13 theme-adaptive statusline with slanted separators
-- Layout:
--   Left   : [MODE]  <icon> <file>
--   Center :   <LSPs> [progress]
--   Right  : <AI> <diagnostics> <macro>  [ <branch> +~-]
local M = {}

local SEP_LEFT = ""  -- slanted `/` separator after left mode pill
local SEP_RIGHT = "" -- slanted `\` separator before right git pill

local mode_map = {
  n = { label = "NORMAL", key = "Normal" },
  no = { label = "O-PEND", key = "Normal" },
  nov = { label = "O-PEND", key = "Normal" },
  noV = { label = "O-PEND", key = "Normal" },
  ["no\22"] = { label = "O-PEND", key = "Normal" },
  niI = { label = "NORMAL", key = "Normal" },
  niR = { label = "NORMAL", key = "Normal" },
  niV = { label = "NORMAL", key = "Normal" },
  nt = { label = "NORMAL", key = "Normal" },
  i = { label = "INSERT", key = "Insert" },
  ic = { label = "INSERT", key = "Insert" },
  ix = { label = "INSERT", key = "Insert" },
  v = { label = "VISUAL", key = "Visual" },
  V = { label = "V-LINE", key = "Visual" },
  ["\22"] = { label = "V-BLOCK", key = "Visual" },
  s = { label = "SELECT", key = "Visual" },
  S = { label = "S-LINE", key = "Visual" },
  ["\19"] = { label = "S-BLOCK", key = "Visual" },
  R = { label = "REPLACE", key = "Replace" },
  Rc = { label = "REPLACE", key = "Replace" },
  Rx = { label = "REPLACE", key = "Replace" },
  Rv = { label = "V-REPL", key = "Replace" },
  c = { label = "COMMAND", key = "Command" },
  cv = { label = "EX", key = "Command" },
  ce = { label = "EX", key = "Command" },
  r = { label = "PROMPT", key = "Command" },
  rm = { label = "MORE", key = "Command" },
  ["r?"] = { label = "CONFIRM", key = "Command" },
  ["!"] = { label = "SHELL", key = "Terminal" },
  t = { label = "TERMINAL", key = "Terminal" },
}

local base_bg = nil
local icon_hl_cache = {}

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false }) or {}
end

local function pick_fg(names, fallback)
  for _, name in ipairs(names) do
    local fg = get_hl(name).fg
    if fg then
      return fg
    end
  end
  return fallback
end

local function setup_highlights()
  icon_hl_cache = {}

  local stl = get_hl("StatusLine")
  local stl_nc = get_hl("StatusLineNC")
  local tab_sel = get_hl("TabLineSel")
  local normal = get_hl("Normal")

  base_bg = stl.bg or stl_nc.bg
  local base_fg = normal.fg or stl.fg or "#d3c6aa"
  local muted_fg = stl.fg or base_fg

  local is_light = vim.o.background == "light"
  -- Avoid washed-out StatusLineNC.bg on transparent themes; use true dark/light ink
  local pill_fg = normal.bg or tab_sel.fg or (is_light and "#ffffff" or "#1e2326")

  local c_normal = pick_fg({ "Function", "DiagnosticOk", "String" }, "#a7c080")
  local c_insert = pick_fg({ "DiagnosticInfo", "Type", "Constant" }, "#7fbbb3")
  local c_visual = pick_fg({ "Statement", "Keyword", "Special" }, "#c099ff")
  local c_command = pick_fg({ "DiagnosticWarn", "Special", "Type" }, "#dbbc7f")
  local c_replace = pick_fg({ "DiagnosticError", "ErrorMsg" }, "#e67e80")
  local c_term = pick_fg({ "Constant", "String", "DiagnosticHint" }, "#83c092")
  local c_git = pick_fg({ "DiagnosticHint", "Constant", "Statement" }, "#d699b6")

  local c_err = pick_fg({ "DiagnosticError" }, "#e67e80")
  local c_warn = pick_fg({ "DiagnosticWarn" }, "#dbbc7f")
  local c_info = pick_fg({ "DiagnosticInfo" }, "#7fbbb3")
  local c_hint = pick_fg({ "DiagnosticHint" }, "#d699b6")
  local c_ok = pick_fg({ "DiagnosticOk", "String" }, "#a7c080")

  local hl = vim.api.nvim_set_hl
  hl(0, "StlBase", { fg = base_fg, bg = base_bg })
  hl(0, "StlMuted", { fg = muted_fg, bg = base_bg })
  hl(0, "StlFile", { fg = base_fg, bg = base_bg, bold = true })
  hl(0, "StlMod", { fg = c_warn, bg = base_bg, bold = true })
  hl(0, "StlLsp", { fg = base_fg, bg = base_bg })

  -- Mode pills + slanted `/` separators
  local modes = {
    Normal = c_normal,
    Insert = c_insert,
    Visual = c_visual,
    Command = c_command,
    Replace = c_replace,
    Terminal = c_term,
  }
  for key, bg_col in pairs(modes) do
    hl(0, "StlMode" .. key, { fg = pill_fg, bg = bg_col, bold = true })
    hl(0, "StlModeSep" .. key, { fg = bg_col, bg = base_bg })
  end

  -- Diagnostics
  hl(0, "StlDiagError", { fg = c_err, bg = base_bg })
  hl(0, "StlDiagWarn", { fg = c_warn, bg = base_bg })
  hl(0, "StlDiagInfo", { fg = c_info, bg = base_bg })
  hl(0, "StlDiagHint", { fg = c_hint, bg = base_bg })

  -- AI indicator
  hl(0, "StlAiOk", { fg = c_ok, bg = base_bg })
  hl(0, "StlAiBusy", { fg = c_warn, bg = base_bg })
  hl(0, "StlAiErr", { fg = c_err, bg = base_bg })
  hl(0, "StlAiCli", { fg = c_info, bg = base_bg, bold = true })

  -- Macro recording indicator
  hl(0, "StlMacro", { fg = c_err, bg = base_bg, bold = true })

  -- Right Git pill + slanted `\` separator
  hl(0, "StlGit", { fg = pill_fg, bg = c_git, bold = true })
  hl(0, "StlGitSep", { fg = c_git, bg = base_bg })
end

setup_highlights()

local group = vim.api.nvim_create_augroup("UserStatusline", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = setup_highlights,
})

-- Instant statusline refresh when macro recording starts/stops
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
  group = group,
  callback = function()
    vim.schedule(function()
      vim.cmd("redrawstatus")
    end)
  end,
})

local function file_section()
  if vim.bo.buftype == "terminal" then
    local raw = vim.api.nvim_buf_get_name(0)
    local prog = raw:match("([^:/\\]+)$") or "Terminal"
    return "  %#StlAiCli#  %#StlFile#" .. prog
  end

  local fname = vim.fn.expand("%:t")
  if fname == "" then
    return "%#StlMuted#  [No Name]"
  end

  local icon_part = ""
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local icon, hl_name = devicons.get_icon(fname, vim.fn.expand("%:e"), { default = true })
    if icon then
      if hl_name then
        local cached = icon_hl_cache[hl_name]
        if not cached then
          local fg = get_hl(hl_name).fg
          cached = "StlIcon_" .. hl_name
          vim.api.nvim_set_hl(0, cached, { fg = fg, bg = base_bg })
          icon_hl_cache[hl_name] = cached
        end
        icon_part = "%#" .. cached .. "#" .. icon .. "  "
      else
        icon_part = "%#StlBase#" .. icon .. "  "
      end
    end
  end

  local mod = ""
  if vim.bo.modified then
    mod = "%#StlMod#  ●"
  elseif vim.bo.readonly or not vim.bo.modifiable then
    mod = "%#StlMuted#  "
  end

  return "  " .. icon_part .. "%#StlFile#" .. fname .. mod
end

local function lsp_section()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local names = {}
  for _, c in ipairs(clients) do
    if c.name ~= "copilot" then
      table.insert(names, c.name)
    end
  end

  local prog = vim.ui.progress_status and vim.ui.progress_status() or ""
  local prog_part = prog ~= "" and (" %#StlMuted#" .. prog) or ""

  if #names == 0 then
    return "%#StlMuted#  No LSP" .. prog_part
  end
  return "%#StlLsp#  " .. table.concat(names, ", ") .. prog_part
end

local function ai_section()
  local parts = {}

  -- Copilot / NES status via sidekick.status or native LSP
  local ok_sk, sk_status = pcall(require, "sidekick.status")
  if ok_sk then
    local st = sk_status.get()
    if st then
      local hl = "StlAiOk"
      if st.kind == "Error" then
        hl = "StlAiErr"
      elseif st.busy or st.kind == "Warning" then
        hl = "StlAiBusy"
      elseif st.kind == "Inactive" then
        hl = "StlMuted"
      end
      table.insert(parts, "%#" .. hl .. "# ")
    end

    local cli = sk_status.cli()
    if cli and #cli > 0 then
      local tools = {}
      for _, s in ipairs(cli) do
        table.insert(tools, s.tool)
      end
      table.insert(parts, "%#StlAiCli# " .. table.concat(tools, ","))
    end
  else
    local copilot = vim.lsp.get_clients({ bufnr = 0, name = "copilot" })
    if #copilot > 0 then
      local enabled = vim.lsp.inline_completion and vim.lsp.inline_completion.is_enabled({ bufnr = 0 })
      table.insert(parts, (enabled and "%#StlAiOk#" or "%#StlMuted#") .. " ")
    end
  end

  if #parts == 0 then
    return ""
  end
  return table.concat(parts, "  ")
end

local function diagnostics_section()
  local counts = vim.diagnostic.count(0)
  local sev = vim.diagnostic.severity
  local parts = {}

  local err = counts[sev.ERROR] or 0
  local warn = counts[sev.WARN] or 0
  local info = counts[sev.INFO] or 0
  local hint = counts[sev.HINT] or 0

  if err > 0 then table.insert(parts, "%#StlDiagError#󰅚 " .. err) end
  if warn > 0 then table.insert(parts, "%#StlDiagWarn#󰀪 " .. warn) end
  if info > 0 then table.insert(parts, "%#StlDiagInfo#󰋽 " .. info) end
  if hint > 0 then table.insert(parts, "%#StlDiagHint#󰌶 " .. hint) end

  if #parts == 0 then
    return ""
  end
  return table.concat(parts, "  ")
end

local function macro_section()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return "%#StlMacro#󰑋 @" .. reg
end

local function git_section()
  local g = vim.b.gitsigns_status_dict
  if not g or not g.head or g.head == "" then
    return ""
  end

  local diff = {}
  if vim.o.columns > 80 then
    if (g.added or 0) > 0 then table.insert(diff, "+" .. g.added) end
    if (g.changed or 0) > 0 then table.insert(diff, "~" .. g.changed) end
    if (g.removed or 0) > 0 then table.insert(diff, "-" .. g.removed) end
  end
  local diff_str = #diff > 0 and ("  " .. table.concat(diff, " ")) or ""

  return "%#StlGitSep#" .. SEP_RIGHT .. "%#StlGit#   " .. g.head .. diff_str .. "  "
end

function M.render()
  local raw_mode = vim.fn.mode(true)
  local m = mode_map[raw_mode] or mode_map[raw_mode:sub(1, 1)] or { label = raw_mode:upper(), key = "Normal" }

  local left = table.concat({
    "%#StlMode" .. m.key .. "#  " .. m.label .. "  ",
    "%#StlModeSep" .. m.key .. "#" .. SEP_LEFT,
    file_section(),
  })

  local center = table.concat({
    "%#StlBase#%=",
    lsp_section(),
    "%#StlBase#%=",
  })

  local right_items = {}
  for _, sec in ipairs({ ai_section(), diagnostics_section(), macro_section() }) do
    if sec ~= "" then
      table.insert(right_items, sec)
    end
  end

  local git = git_section()
  local right_prefix = #right_items > 0 and (table.concat(right_items, "   ") .. "  ") or ""
  local right = right_prefix .. git

  return left .. center .. right
end

vim.o.statusline = "%!v:lua.require('configs.statusline').render()"

return M
