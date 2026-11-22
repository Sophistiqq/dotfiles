-- Native Neovim 0.13 theme-adaptive buffer tabline (matches statusline styling)
local M = {}

local sel_bg = nil
local norm_bg = nil
local icon_hl_cache = {}

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false }) or {}
end

local function setup_highlights()
  icon_hl_cache = {}

  local normal = get_hl("Normal")
  local stl = get_hl("StatusLine")
  local stl_nc = get_hl("StatusLineNC")
  local tfill = get_hl("TabLineFill")
  local tsel = get_hl("TabLineSel")
  local accent = get_hl("Function").fg or get_hl("DiagnosticInfo").fg or "#a7c080"
  local warn = get_hl("DiagnosticWarn").fg or "#dbbc7f"

  sel_bg = stl.bg or tsel.bg or "#3d484d"
  norm_bg = tfill.bg or stl_nc.bg or normal.bg
  local active_fg = normal.fg or "#d3c6aa"
  local muted_fg = stl.fg or tfill.fg or "#859289"
  local pill_fg = normal.bg or tsel.fg or "#1e2326"

  local hl = vim.api.nvim_set_hl
  hl(0, "TblFill", { fg = muted_fg, bg = norm_bg })
  hl(0, "TblNorm", { fg = muted_fg, bg = norm_bg })
  hl(0, "TblSel", { fg = active_fg, bg = sel_bg, bold = true })
  hl(0, "TblSelAccent", { fg = accent, bg = sel_bg, bold = true })
  hl(0, "TblModSel", { fg = warn, bg = sel_bg, bold = true })
  hl(0, "TblModNorm", { fg = warn, bg = norm_bg })
  hl(0, "TblSep", { fg = muted_fg, bg = norm_bg })
  hl(0, "TblTabBadge", { fg = pill_fg, bg = accent, bold = true })
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserTablineHL", { clear = true }),
  callback = setup_highlights,
})

local function get_icon_part(name, ft, is_active)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return ""
  end
  local icon, hl_name = devicons.get_icon(name, vim.fn.fnamemodify(name, ":e"), { default = true })
  if not icon and ft ~= "" then
    icon, hl_name = devicons.get_icon_by_filetype(ft, { default = true })
  end
  if not icon then
    return ""
  end

  local bg = is_active and sel_bg or norm_bg
  if hl_name then
    local cache_key = (is_active and "S_" or "N_") .. hl_name
    local cached = icon_hl_cache[cache_key]
    if not cached then
      local fg = get_hl(hl_name).fg
      cached = "TblIcon_" .. cache_key
      vim.api.nvim_set_hl(0, cached, { fg = fg, bg = bg })
      icon_hl_cache[cache_key] = cached
    end
    return "%#" .. cached .. "#" .. icon .. " "
  end
  return (is_active and "%#TblSel#" or "%#TblNorm#") .. icon .. " "
end

function M.render()
  local cur = vim.api.nvim_get_current_buf()
  local parts = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      local is_active = buf == cur
      local full = vim.api.nvim_buf_get_name(buf)
      local name = full ~= "" and vim.fn.fnamemodify(full, ":t") or "[No Name]"
      local icon = get_icon_part(name, vim.bo[buf].filetype, is_active)
      local mod = vim.bo[buf].modified and ((is_active and "%#TblModSel#" or "%#TblModNorm#") .. " ●") or ""

      if is_active then
        table.insert(
          parts,
          string.format("%%%d@v:lua.UserTablineClick@%%#TblSelAccent#▎ %%#TblSel#%s%%#TblSel#%s%s  %%X", buf, icon, name, mod)
        )
      else
        table.insert(
          parts,
          string.format("%%%d@v:lua.UserTablineClick@%%#TblNorm#  %s%%#TblNorm#%s%s  %%X", buf, icon, name, mod)
        )
      end
    end
  end

  table.insert(parts, "%#TblFill#%=")

  local tabs = vim.fn.tabpagenr("$")
  if tabs > 1 then
    table.insert(parts, string.format("%%#TblTabBadge#  Tab %d/%d  ", vim.fn.tabpagenr(), tabs))
  end

  return table.concat(parts)
end

function _G.UserTablineClick(bufnr, _, btn)
  if btn == "m" then
    pcall(vim.api.nvim_buf_delete, bufnr, {})
  elseif vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_set_current_buf(bufnr)
  end
end

vim.o.tabline = "%!v:lua.require('configs.tabline').render()"

return M
