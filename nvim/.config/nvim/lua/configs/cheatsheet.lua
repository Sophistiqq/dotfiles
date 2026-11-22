-- Native styled 2-column floating Cheatsheet popup (:Cheatsheet or <leader>?)
local M = {}

local ns = vim.api.nvim_create_namespace("user_cheatsheet")

local sections = {
  {
    title = " 󰍉  Find (Telescope) ",
    hl = "CsHeaderBlue",
    items = {
      { "<leader>ff", "Find files" },
      { "<leader>fw", "Live grep (find words)" },
      { "<leader>fb / <Spc><Spc>", "Find open buffers" },
      { "<leader>fd", "Find diagnostics" },
      { "<leader>fq", "Find quickfix items" },
      { "<leader>fs / fS", "Document / workspace symbols" },
      { "<leader>fk", "Fuzzy search ALL keymaps" },
      { "<leader>fh", "Find Neovim help tags" },
      { "<leader>th", "Pick & save colorscheme" },
    },
  },
  {
    title = " 󰌛  LSP & C# / .NET (Roslyn) ",
    hl = "CsHeaderPurple",
    items = {
      { "K / gd / gD", "Hover / definition / decl" },
      { "grr / gri / grt", "Refs / impl / type def" },
      { "gO", "Document symbols outline" },
      { "grn / <leader>ra", "Rename symbol" },
      { "gra / <leader>ca", "Code actions" },
      { "grx / <leader>cl", "Run CodeLens (Tests/Refs)" },
      { "<leader>ih", "Toggle inlay hints" },
      { "<leader>uf", "Toggle LSP format-on-save" },
      { "<leader>ce / :EFCore", "EF Core Migrations Manager" },
      { ":DotnetBuild / Test", "Build / test in split (.cs)" },
      { ":MasonEnsure", "Install Roslyn & dev tools" },
    },
  },
  {
    title = " 󰚩  AI (Sidekick & Copilot) ",
    hl = "CsHeaderGreen",
    items = {
      { "<leader>aa", "Toggle AI CLI window" },
      { "<leader>as", "Select installed AI CLI" },
      { "<leader>ay", "Toggle Antigravity (agy)" },
      { "<leader>ao / ag / ax", "OpenCode / Gemini / Codex" },
      { "<leader>at / af", "Send selection / file to AI" },
      { "<leader>ap", "AI prompts (fix, tests...)" },
      { "<leader>ad", "Detach / close AI CLI" },
      { "<leader>an / ac", "Apply / clear Copilot NES" },
      { "<C-f> / <C-g> (Ins)", "Accept / cycle ghost text" },
      { "<leader>ai", "Toggle inline completion" },
      { ":LspCopilotSignIn", "Authenticate Copilot LSP" },
    },
  },
  {
    title = " 󰙅  Navigation & Explorer ",
    hl = "CsHeaderCyan",
    items = {
      { "<C-h/j/k/l>", "Switch windows (N & Term)" },
      { "]b / [b", "Next / prev buffer (native)" },
      { "<leader>x", "Close current buffer" },
      { "<C-n> / <leader>ee", "Toggle NvimTree explorer" },
      { "<leader>e> / e<", "Widen / shrink NvimTree" },
      { "<leader>;", "Dropbar winbar picker" },
      { "[; / ];", "Context start / next" },
    },
  },
  {
    title = " 󰆍  Terminal & Git (Native) ",
    hl = "CsHeaderYellow",
    items = {
      { "<C-/> / <leader>tt", "Toggle floating terminal" },
      { "<leader>tv", "Toggle vertical terminal" },
      { "<leader>ts", "Toggle split terminal" },
      { "<leader>gg / gt", "Toggle floating LazyGit" },
      { "<Esc><Esc> (Term)", "Exit terminal mode safely" },
    },
  },
  {
    title = " 󰃤  Debugging (DAP: C# & Rust) ",
    hl = "CsHeaderRed",
    items = {
      { "<leader>dc", "Start / continue debug" },
      { "<leader>db / dB", "Breakpoint / conditional" },
      { "<leader>do / di / dO", "Step over / into / out" },
      { "<leader>dt", "Terminate debug session" },
      { "<leader>du", "Toggle DAP UI" },
    },
  },
  {
    title = " 󰏫  Editing & Sessions ",
    hl = "CsHeaderOrange",
    items = {
      { "<leader>w", "Save file" },
      { ";", "Enter command mode (:)" },
      { "<leader>/", "Toggle comment (N & V)" },
      { "<leader>tf", "Flip true <-> false" },
      { "<leader>uw / rn", "Toggle wrap / relnumber" },
      { "<leader>uu", "Toggle built-in :Undotree" },
      { "<leader>uk", "Buffer-local which-key" },
      { "<leader>ss / sr / sd", "Save / restore / del session" },
    },
  },
  {
    title = " 󰒓  Neovim 0.12 / 0.13 Built-ins ",
    hl = "CsHeaderTeal",
    items = {
      { "Q / <C-LeftMouse>", "Add/toggle multicursor" },
      { "zq / q= / gQ / <C-l>", "Motion / follow / restore / clr" },
      { "an / in / ]n / [n", "TS incremental selection" },
      { "]N / [N", "Expand to sibling TS node" },
      { "ZR / :restart", "Restart preserving session" },
      { "g<", "Open ui2 message pager" },
      { ":DiffTool a b", "Built-in file/dir diff" },
      { ":packupdate / :packdel", "Manage vim.pack plugins" },
    },
  },
}

local function setup_highlights()
  local hl = vim.api.nvim_set_hl
  hl(0, "CsHeaderBlue", { fg = "#1e222a", bg = "#61afef", bold = true })
  hl(0, "CsHeaderPurple", { fg = "#1e222a", bg = "#c678dd", bold = true })
  hl(0, "CsHeaderGreen", { fg = "#1e222a", bg = "#98c379", bold = true })
  hl(0, "CsHeaderCyan", { fg = "#1e222a", bg = "#56b6c2", bold = true })
  hl(0, "CsHeaderYellow", { fg = "#1e222a", bg = "#e5c07b", bold = true })
  hl(0, "CsHeaderRed", { fg = "#1e222a", bg = "#e06c75", bold = true })
  hl(0, "CsHeaderOrange", { fg = "#1e222a", bg = "#d19a66", bold = true })
  hl(0, "CsHeaderTeal", { fg = "#1e222a", bg = "#7fdbca", bold = true })
  hl(0, "CsKey", { link = "Function" })
  hl(0, "CsDesc", { link = "NormalFloat" })
  hl(0, "CsRule", { link = "Comment" })
  hl(0, "CsTitle", { link = "Title" })
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserCheatsheetHL", { clear = true }),
  callback = setup_highlights,
})

local function pad_right(str, target_width)
  local w = vim.fn.strdisplaywidth(str)
  if w >= target_width then
    return str
  end
  return str .. string.rep(" ", target_width - w)
end

-- Build a single card's lines + highlight spans (byte-indexed relative to card line)
local function build_card(sec, col_width)
  local key_col = math.min(27, math.floor(col_width * 0.45))
  local out = {}

  -- Header badge line
  local header_text = pad_right(sec.title, col_width)
  table.insert(out, {
    text = header_text,
    hls = { { 0, #header_text, sec.hl } },
  })

  -- Subtle underline rule
  local rule = string.rep("─", col_width)
  table.insert(out, {
    text = rule,
    hls = { { 0, #rule, "CsRule" } },
  })

  -- Keybind rows
  for _, item in ipairs(sec.items) do
    local key_str = " " .. item[1]
    local key_padded = pad_right(key_str, key_col)
    local desc_budget = col_width - vim.fn.strdisplaywidth(key_padded)
    local desc = item[2]
    if vim.fn.strdisplaywidth(desc) > desc_budget then
      desc = vim.fn.strcharpart(desc, 0, math.max(1, desc_budget - 1)) .. "…"
    end
    local full = pad_right(key_padded .. desc, col_width)
    table.insert(out, {
      text = full,
      hls = {
        { 0, #key_padded, "CsKey" },
        { #key_padded, #full, "CsDesc" },
      },
    })
  end

  -- Blank spacer after card
  table.insert(out, { text = string.rep(" ", col_width), hls = {} })
  return out
end

local function build_layout(total_width)
  local margin = 2
  local inner = total_width - margin * 2
  local two_col = inner >= 104
  local lines = {}
  local marks = {} -- { row, col_start, col_end, hl }

  local pad = string.rep(" ", margin)

  -- Top banner
  table.insert(lines, "")

  if two_col then
    local gap = 4
    local col_w = math.floor((inner - gap) / 2)
    local gap_str = string.rep(" ", gap)

    -- Balance sections across left & right columns by height
    local left_rows, right_rows = {}, {}
    local left_h, right_h = 0, 0
    for _, sec in ipairs(sections) do
      local card = build_card(sec, col_w)
      if left_h <= right_h then
        vim.list_extend(left_rows, card)
        left_h = left_h + #card
      else
        vim.list_extend(right_rows, card)
        right_h = right_h + #card
      end
    end

    local max_rows = math.max(#left_rows, #right_rows)
    local empty_col = string.rep(" ", col_w)

    for i = 1, max_rows do
      local l = left_rows[i] or { text = empty_col, hls = {} }
      local r = right_rows[i] or { text = empty_col, hls = {} }
      local line = pad .. l.text .. gap_str .. r.text
      local row_idx = #lines
      table.insert(lines, line)

      local l_off = #pad
      for _, h in ipairs(l.hls) do
        table.insert(marks, { row_idx, l_off + h[1], l_off + h[2], h[3] })
      end

      local r_off = #pad + #l.text + #gap_str
      for _, h in ipairs(r.hls) do
        table.insert(marks, { row_idx, r_off + h[1], r_off + h[2], h[3] })
      end
    end
  else
    local col_w = math.max(40, inner)
    for _, sec in ipairs(sections) do
      local card = build_card(sec, col_w)
      for _, row in ipairs(card) do
        local row_idx = #lines
        table.insert(lines, pad .. row.text)
        local off = #pad
        for _, h in ipairs(row.hls) do
          table.insert(marks, { row_idx, off + h[1], off + h[2], h[3] })
        end
      end
    end
  end

  return lines, marks
end

local win = -1
local buf = -1

function M.toggle()
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = -1
    return
  end

  local width = math.min(136, math.max(60, math.floor(vim.o.columns * 0.92)))
  local lines, marks = build_layout(width)
  local height = math.min(#lines, math.max(16, math.floor(vim.o.lines * 0.88)))

  if not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].filetype = "cheatsheet"
    vim.bo[buf].buftype = "nofile"

    local close = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
        win = -1
      end
    end
    vim.keymap.set("n", "q", close, { buf = buf, desc = "Close cheatsheet", nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buf = buf, desc = "Close cheatsheet", nowait = true })
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], {
      end_col = m[3],
      hl_group = m[4],
    })
  end
  vim.bo[buf].modifiable = false

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " 󰌌  Neovim 0.13 Cheatsheet ",
    title_pos = "center",
    footer = " q / <Esc>: close  •  /: search  •  <leader>fk: fuzzy keymaps ",
    footer_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
end

vim.api.nvim_create_user_command("Cheatsheet", M.toggle, { desc = "Toggle Neovim keybind cheatsheet" })
vim.keymap.set("n", "<leader>?", M.toggle, { desc = "Open Keybind Cheatsheet" })

return M
