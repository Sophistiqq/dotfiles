-- Native Neovim 0.12/0.13 theme-adaptive slanted buffer tabline
-- Active tab uses an elevated dark surface so filename & devicons keep full theme colors!
local M = {}

local SEP_ACTIVE_LEFT = ""  -- `/` slant on left edge of active tab (parallel `/  /`)
local SEP_ACTIVE_RIGHT = "" -- `/` slant on right edge of active tab
local SEP_BADGE_LEFT = ""   -- `\` slant on far-right badge (mirrors bottom-right Git pill)
local SEP_THIN = ""         -- subtle `/` divider between inactive buffers

local fill_bg = nil
local sel_bg = nil
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

local function pick_distinct_bg(candidates, avoid_bg, fallback)
  for _, name in ipairs(candidates) do
    local bg = get_hl(name).bg
    if bg and bg ~= avoid_bg then
      return bg
    end
  end
  return fallback
end

local function setup_highlights()
  icon_hl_cache = {}

  local normal = get_hl("Normal")
  local stl = get_hl("StatusLine")
  local stl_nc = get_hl("StatusLineNC")
  local tfill = get_hl("TabLineFill")
  local tsel = get_hl("TabLineSel")

  local is_light = vim.o.background == "light"
  fill_bg = tfill.bg or stl_nc.bg or stl.bg
  -- Pick an elevated surface distinct from fill_bg so active tab lifts cleanly while preserving icon colors
  sel_bg = pick_distinct_bg(
    { "TabLine", "CursorLine", "Visual", "Pmenu", "StatusLine" },
    fill_bg,
    is_light and "#e0e0e0" or "#475258"
  )

  local active_fg = normal.fg or "#d3c6aa"
  local muted_fg = stl.fg or tfill.fg or "#859289"
  local pill_fg = normal.bg or tsel.fg or (is_light and "#ffffff" or "#1e2326")

  local badge_bg = pick_fg({ "DiagnosticHint", "Constant", "Statement" }, "#d699b6")
  local warn_fg = pick_fg({ "DiagnosticWarn" }, "#dbbc7f")

  local hl = vim.api.nvim_set_hl
  hl(0, "TblFill", { fg = muted_fg, bg = fill_bg })
  hl(0, "TblNorm", { fg = muted_fg, bg = fill_bg })
  hl(0, "TblThinSep", { fg = muted_fg, bg = fill_bg })
  hl(0, "TblModNorm", { fg = warn_fg, bg = fill_bg })

  -- Active tab: elevated theme surface + crisp Normal.fg bold + full-color devicon
  hl(0, "TblSel", { fg = active_fg, bg = sel_bg, bold = true })
  hl(0, "TblModSel", { fg = warn_fg, bg = sel_bg, bold = true })
  hl(0, "TblSelSep", { fg = sel_bg, bg = fill_bg })

  -- Far-right slanted badge (matches bottom-right Git pill)
  hl(0, "TblBadge", { fg = pill_fg, bg = badge_bg, bold = true })
  hl(0, "TblBadgeSep", { fg = badge_bg, bg = fill_bg })
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

  local bg = is_active and sel_bg or fill_bg
  if hl_name then
    local cache_key = (is_active and "S_" or "N_") .. hl_name
    local cached = icon_hl_cache[cache_key]
    if not cached then
      local fg = get_hl(hl_name).fg
      cached = "TblIcon_" .. cache_key
      vim.api.nvim_set_hl(0, cached, { fg = fg, bg = bg })
      icon_hl_cache[cache_key] = cached
    end
    return "%#" .. cached .. "#" .. icon .. "  "
  end
  return (is_active and "%#TblSel#" or "%#TblNorm#") .. icon .. "  "
end

function M.render()
  local cur = vim.api.nvim_get_current_buf()
  local bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      table.insert(bufs, buf)
    end
  end

  local parts = {}
  for i, buf in ipairs(bufs) do
    local is_active = buf == cur
    local full = vim.api.nvim_buf_get_name(buf)
    local is_term = vim.bo[buf].buftype == "terminal"
    local name = is_term and (full:match("([^:/\\]+)$") or "Terminal")
      or (full ~= "" and vim.fn.fnamemodify(full, ":t") or "[No Name]")
    local icon = is_term and "  " or get_icon_part(name, vim.bo[buf].filetype, is_active)

    if is_active then
      local mod = vim.bo[buf].modified and "%#TblModSel#  ●" or ""
      local left_edge = i > 1 and ("%#TblSelSep#" .. SEP_ACTIVE_LEFT) or ""
      table.insert(
        parts,
        string.format(
          "%s%%%d@v:lua.UserTablineClick@%%#TblSel#  %s%%#TblSel#%s%s  %%X%%#TblSelSep#%s",
          left_edge,
          buf,
          icon,
          name,
          mod,
          SEP_ACTIVE_RIGHT
        )
      )
    else
      local mod = vim.bo[buf].modified and "%#TblModNorm#  ●" or ""
      local next_is_active = bufs[i + 1] == cur
      local sep = (i < #bufs and not next_is_active) and ("%#TblThinSep#" .. SEP_THIN) or ""
      table.insert(
        parts,
        string.format(
          "%%%d@v:lua.UserTablineClick@%%#TblNorm#  %s%%#TblNorm#%s%s  %%X%s",
          buf,
          icon,
          name,
          mod,
          sep
        )
      )
    end
  end

  table.insert(parts, "%#TblFill#%=")

  local tabs = vim.fn.tabpagenr("$")
  local right_label = tabs > 1
    and string.format("󰓩 %d/%d", vim.fn.tabpagenr(), tabs)
    or string.format("󰈔 %d", #bufs)

  table.insert(parts, string.format("%%#TblBadgeSep#%s%%#TblBadge#  %s  ", SEP_BADGE_LEFT, right_label))

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
