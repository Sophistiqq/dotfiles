-- Native Rider-style Entity Framework Core Manager (:EFCore or <leader>ce)
-- Uses Telescope pickers (with live file previews!) & styled wide dashboard UI
local M = {}

local ns = vim.api.nvim_create_namespace("user_efcore")

local SKIP_DIRS = {
  bin = true,
  obj = true,
  [".git"] = true,
  [".vs"] = true,
  [".idea"] = true,
  node_modules = true,
  packages = true,
}

local state_cache = {}
local ui_win = -1
local ui_buf = -1

local function setup_highlights()
  local hl = vim.api.nvim_set_hl
  hl(0, "EfHeaderConfig", { fg = "#1e222a", bg = "#61afef", bold = true })
  hl(0, "EfHeaderAction", { fg = "#1e222a", bg = "#98c379", bold = true })
  hl(0, "EfHeaderCmd", { fg = "#1e222a", bg = "#c678dd", bold = true })
  hl(0, "EfKey", { link = "Function" })
  hl(0, "EfDangerKey", { link = "DiagnosticError" })
  hl(0, "EfLabel", { link = "Comment" })
  hl(0, "EfValue", { link = "String" })
  hl(0, "EfBadge", { link = "DiagnosticInfo" })
  hl(0, "EfRule", { link = "Comment" })
  hl(0, "EfCmd", { link = "Special" })
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserEfCoreHL", { clear = true }),
  callback = setup_highlights,
})

local function norm(path)
  return (path:gsub("\\", "/"))
end

local function pad_right(str, target_width)
  local w = vim.fn.strdisplaywidth(str)
  if w >= target_width then
    return str
  end
  return str .. string.rep(" ", target_width - w)
end

local function relpath(root, full)
  local r = norm(root):gsub("/$", "")
  local f = norm(full)
  if f:sub(1, #r + 1) == r .. "/" then
    return f:sub(#r + 2)
  end
  return f
end

local function find_solution_root(start_dir)
  local base = start_dir
  if not base or base == "" then
    local bufname = vim.api.nvim_buf_get_name(0)
    base = (bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:h")) or vim.fn.getcwd()
  end

  local found = vim.fs.root(base, function(name)
    return name:match("%.slnx?$") ~= nil
  end)
  if found then
    return norm(found)
  end

  local git_root = vim.fs.root(base, ".git")
  if git_root then
    return norm(git_root)
  end

  return norm(vim.fn.getcwd())
end

local function read_text(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local data = f:read("*a")
  f:close()
  return data
end

local function walk_files(dir, predicate, results)
  results = results or {}
  for name, entry_type in vim.fs.dir(dir) do
    local full = vim.fs.joinpath(dir, name)
    if entry_type == "directory" then
      if not SKIP_DIRS[name] then
        walk_files(full, predicate, results)
      end
    elseif entry_type == "file" or entry_type == "link" then
      if predicate(name, full) then
        table.insert(results, norm(full))
      end
    end
  end
  return results
end

local function detect_output_dir(proj_dir, ctx_name)
  local snapshot_name = ctx_name .. "ModelSnapshot.cs"
  local snapshots = walk_files(proj_dir, function(name)
    return name == snapshot_name
  end)
  if snapshots[1] then
    local snap_dir = norm(vim.fs.dirname(snapshots[1]))
    local rel = relpath(proj_dir, snap_dir)
    if rel ~= "" and rel ~= norm(proj_dir) then
      return rel
    end
  end
  return "Migrations"
end

local function list_migration_files(proj_dir, output_dir)
  local mig_dir = vim.fs.joinpath(proj_dir, output_dir)
  if not vim.uv.fs_stat(mig_dir) then
    return {}
  end

  local items = {}
  for name, entry_type in vim.fs.dir(mig_dir) do
    if (entry_type == "file" or entry_type == "link")
      and name:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d_.+%.cs$")
      and not name:match("%.Designer%.cs$")
    then
      local id = name:gsub("%.cs$", "")
      table.insert(items, {
        id = id,
        path = norm(vim.fs.joinpath(mig_dir, name)),
      })
    end
  end

  table.sort(items, function(a, b)
    return a.id > b.id
  end)
  return items
end

-- Telescope picker wrapper with optional file preview (falls back cleanly to vim.ui.select)
local function ef_pick(items, opts, on_choice)
  local ok_p, pickers = pcall(require, "telescope.pickers")
  local ok_f, finders = pcall(require, "telescope.finders")
  local ok_c, conf = pcall(require, "telescope.config")
  local ok_a, actions = pcall(require, "telescope.actions")
  local ok_s, action_state = pcall(require, "telescope.actions.state")
  local ok_t, themes = pcall(require, "telescope.themes")

  if not (ok_p and ok_f and ok_c and ok_a and ok_s and ok_t) then
    vim.ui.select(items, {
      prompt = opts.prompt,
      format_item = opts.format_item,
    }, on_choice)
    return
  end

  local has_preview = opts.preview_path ~= nil
  local picker_opts
  if has_preview then
    picker_opts = {
      layout_strategy = "horizontal",
      layout_config = {
        width = 0.88,
        height = 0.78,
        preview_width = 0.55,
      },
    }
  else
    picker_opts = themes.get_dropdown({
      previewer = false,
      layout_config = {
        width = math.min(90, math.floor(vim.o.columns * 0.7)),
        height = math.min(20, #items + 6),
      },
    })
  end

  pickers.new(picker_opts, {
    prompt_title = opts.prompt or "EF Core",
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        local display = opts.format_item and opts.format_item(item) or tostring(item)
        local path = opts.preview_path and opts.preview_path(item) or nil
        return {
          value = item,
          display = display,
          ordinal = display,
          path = path,
        }
      end,
    }),
    sorter = conf.values.generic_sorter(picker_opts),
    previewer = has_preview and conf.values.file_previewer(picker_opts) or nil,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if sel and sel.value ~= nil then
          on_choice(sel.value)
        end
      end)
      return true
    end,
  }):find()
end

function M.discover(root)
  root = root or find_solution_root()
  local csproj_files = walk_files(root, function(name)
    return name:match("%.csproj$") ~= nil
  end)
  table.sort(csproj_files)

  local projects = {}
  local contexts = {}
  local seen_ctx = {}

  for _, csproj in ipairs(csproj_files) do
    local content = read_text(csproj) or ""
    local proj_dir = norm(vim.fs.dirname(csproj))
    local rel = relpath(root, csproj)

    local proj = {
      path = csproj,
      rel = rel,
      dir = proj_dir,
      name = vim.fn.fnamemodify(csproj, ":t:r"),
      is_web = content:match('Sdk="Microsoft%.NET%.Sdk%.Web"') ~= nil
        or content:match('Sdk="Microsoft%.NET%.Sdk%.Worker"') ~= nil,
      is_exe = content:match("<OutputType>%s*Exe%s*</OutputType>") ~= nil,
      has_ef_design = content:match("Microsoft%.EntityFrameworkCore%.Design") ~= nil,
      has_ef = content:match("Microsoft%.EntityFrameworkCore") ~= nil,
    }
    table.insert(projects, proj)

    -- Scan project for DbContext subclasses (partial classes, IdentityDbContext<T>, C# 12 primary ctors)
    local cs_files = walk_files(proj_dir, function(name, full)
      if not name:match("%.cs$") then
        return false
      end
      if name:match("ModelSnapshot%.cs$") or name:match("%.Designer%.cs$") then
        return false
      end
      return not full:match("[/\\]Migrations[/\\]")
    end)

    for _, cs in ipairs(cs_files) do
      local src = read_text(cs)
      if src and src:find("DbContext", 1, true) then
        local flat = src:gsub("\r\n", "\n")
        for line in flat:gmatch("[^\n]+") do
          if not line:match("^%s*//") then
            local cls = line:match("class%s+([%w_]+)%s*%b()%s*:%s*[%w_.<>%s,]*DbContext")
              or line:match("class%s+([%w_]+)%s*:%s*[%w_.<>%s,]*DbContext")
            if cls and not cls:match("DesignTime") then
              local key = rel .. "::" .. cls
              if not seen_ctx[key] then
                seen_ctx[key] = true
                table.insert(contexts, {
                  name = cls,
                  project = rel,
                  project_dir = proj_dir,
                  file = cs,
                  output_dir = detect_output_dir(proj_dir, cls),
                })
              end
            end
          end
        end
      end
    end
  end

  table.sort(contexts, function(a, b)
    if a.project ~= b.project then
      return a.project < b.project
    end
    return a.name < b.name
  end)

  local function startup_score(p)
    local s = 0
    if p.is_web then s = s + 100 end
    if p.has_ef_design then s = s + 50 end
    if p.is_exe then s = s + 25 end
    if p.has_ef then s = s + 10 end
    return s
  end

  local best_startup = projects[1]
  for _, p in ipairs(projects) do
    if not best_startup or startup_score(p) > startup_score(best_startup) then
      best_startup = p
    end
  end

  local default_ctx = contexts[1]
  local default_mig_proj = (default_ctx and default_ctx.project)
    or (best_startup and best_startup.rel)
    or ""

  return {
    root = root,
    projects = projects,
    contexts = contexts,
    defaults = {
      migrations_project = default_mig_proj,
      startup_project = best_startup and best_startup.rel or "",
      context = default_ctx and default_ctx.name or "",
      output_dir = default_ctx and default_ctx.output_dir or "Migrations",
      configuration = "Debug",
      no_build = false,
    },
  }
end

local function state_path(root)
  local dir = vim.fs.joinpath(vim.fn.stdpath("state"), "efcore")
  local slug = vim.fs.slug and vim.fs.slug(root) or root:gsub("[^%w%-_]", "_")
  return dir, vim.fs.joinpath(dir, slug .. ".json")
end

local function save_state(root, cfg)
  local dir, file = state_path(root)
  vim.fs.mkdir(dir, { parents = true })
  local f = io.open(file, "w")
  if f then
    f:write(vim.json.encode(cfg))
    f:close()
  end
end

local function load_state(root)
  local _, file = state_path(root)
  local data = read_text(file)
  if not data then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, data)
  return ok and type(decoded) == "table" and decoded or nil
end

local function get_workspace(force_rescan)
  local root = find_solution_root()
  if not force_rescan and state_cache[root] then
    return state_cache[root]
  end

  local info = M.discover(root)
  local saved = load_state(root)
  local cfg = vim.deepcopy(info.defaults)

  if saved then
    local proj_set = {}
    for _, p in ipairs(info.projects) do
      proj_set[p.rel] = true
    end
    local ctx_set = {}
    for _, c in ipairs(info.contexts) do
      ctx_set[c.name] = true
    end

    if saved.migrations_project and proj_set[saved.migrations_project] then
      cfg.migrations_project = saved.migrations_project
    end
    if saved.startup_project and proj_set[saved.startup_project] then
      cfg.startup_project = saved.startup_project
    end
    if saved.context and ctx_set[saved.context] then
      cfg.context = saved.context
    end
    if saved.output_dir and saved.output_dir ~= "" then
      cfg.output_dir = saved.output_dir
    end
    if saved.configuration == "Debug" or saved.configuration == "Release" then
      cfg.configuration = saved.configuration
    end
    if type(saved.no_build) == "boolean" then
      cfg.no_build = saved.no_build
    end
  end

  state_cache[root] = { info = info, cfg = cfg }
  return state_cache[root]
end

local function build_args(cfg, subcmd, opts)
  opts = opts or {}
  local args = { "dotnet", "ef" }
  vim.list_extend(args, subcmd)

  if cfg.migrations_project ~= "" then
    vim.list_extend(args, { "--project", cfg.migrations_project })
  end
  if cfg.startup_project ~= "" then
    vim.list_extend(args, { "--startup-project", cfg.startup_project })
  end
  if cfg.context ~= "" then
    vim.list_extend(args, { "--context", cfg.context })
  end
  if opts.include_output_dir and cfg.output_dir ~= "" then
    vim.list_extend(args, { "--output-dir", cfg.output_dir })
  end
  if cfg.configuration and cfg.configuration ~= "Debug" then
    vim.list_extend(args, { "--configuration", cfg.configuration })
  end
  if cfg.no_build then
    table.insert(args, "--no-build")
  end

  return args
end

local function format_cmd(args)
  local parts = {}
  for _, a in ipairs(args) do
    if a:find("%s") then
      table.insert(parts, '"' .. a .. '"')
    else
      table.insert(parts, a)
    end
  end
  return table.concat(parts, " ")
end

local function close_dashboard()
  if vim.api.nvim_win_is_valid(ui_win) then
    vim.api.nvim_win_close(ui_win, true)
    ui_win = -1
  end
end

local function run_ef_command(ws, subcmd, title, opts)
  opts = opts or {}
  if vim.fn.executable("dotnet") ~= 1 then
    vim.notify("`dotnet` CLI not found in PATH. Install .NET SDK + `dotnet tool install -g dotnet-ef`.", vim.log.levels.ERROR)
    return
  end

  local args = build_args(ws.cfg, subcmd, opts)
  close_dashboard()

  local out_buf = vim.api.nvim_create_buf(false, true)
  local w = math.floor(vim.o.columns * 0.88)
  local h = math.floor(vim.o.lines * 0.82)
  local out_win = vim.api.nvim_open_win(out_buf, true, {
    relative = "editor",
    width = w,
    height = h,
    col = math.floor((vim.o.columns - w) / 2),
    row = math.floor((vim.o.lines - h) / 2),
    border = "rounded",
    title = " 󰆼  EF Core: " .. title .. " ",
    title_pos = "center",
    footer = " q / <Esc>: close  •  r: return to EF Core Manager ",
    footer_pos = "center",
  })

  vim.bo[out_buf].buflisted = false
  vim.wo[out_win].winhl = "Normal:Normal,NormalFloat:Normal"

  local close_out = function()
    if vim.api.nvim_win_is_valid(out_win) then
      vim.api.nvim_win_close(out_win, true)
    end
  end

  vim.fn.jobstart(args, {
    term = true,
    cwd = ws.info.root,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("EF Core (" .. title .. ") succeeded", vim.log.levels.INFO)
          if opts.on_success then
            opts.on_success()
          end
        else
          vim.notify("EF Core (" .. title .. ") failed (exit " .. code .. ")", vim.log.levels.ERROR)
        end
        if vim.api.nvim_buf_is_valid(out_buf) then
          vim.keymap.set("n", "q", close_out, { buf = out_buf, desc = "Close EF Core output" })
          vim.keymap.set("n", "<Esc>", close_out, { buf = out_buf, desc = "Close EF Core output" })
          vim.keymap.set("n", "r", function()
            close_out()
            M.open()
          end, { buf = out_buf, desc = "Return to EF Core Manager" })
        end
      end)
    end,
  })

  vim.notify("Running: " .. format_cmd(args), vim.log.levels.INFO)
end

local function find_project_dir(ws, rel)
  for _, p in ipairs(ws.info.projects) do
    if p.rel == rel then
      return p.dir
    end
  end
  return ws.info.root
end

local function format_project_entry(p)
  local tags = {}
  if p.is_web then table.insert(tags, "Web") end
  if p.is_exe and not p.is_web then table.insert(tags, "Exe") end
  if p.has_ef_design then table.insert(tags, "EF.Design")
  elseif p.has_ef then table.insert(tags, "EF") end
  local suffix = #tags > 0 and ("  [" .. table.concat(tags, ", ") .. "]") or ""
  return p.rel .. suffix
end

local function wrap_text(str, max_w)
  local out = {}
  local cur = ""
  for word in str:gmatch("%S+") do
    if cur == "" then
      cur = word
    elseif vim.fn.strdisplaywidth(cur .. " " .. word) <= max_w then
      cur = cur .. " " .. word
    else
      table.insert(out, cur)
      cur = "  " .. word
    end
  end
  if cur ~= "" then
    table.insert(out, cur)
  end
  return out
end

local function compute_width()
  return math.min(126, math.max(76, math.floor(vim.o.columns * 0.90)))
end

local function render_dashboard(ws, width)
  if not vim.api.nvim_buf_is_valid(ui_buf) then
    return 24
  end

  width = width or compute_width()
  local margin = 3
  local inner = width - margin * 2
  local pad = string.rep(" ", margin)

  local cfg = ws.cfg
  local root_name = vim.fn.fnamemodify(ws.info.root, ":t")
  local mig_dir = find_project_dir(ws, cfg.migrations_project)
  local migrations = list_migration_files(mig_dir, cfg.output_dir)
  local latest = migrations[1] and migrations[1].id or "(none found)"

  local lines = { "" }
  local marks = {}

  local function add_line(text, hls)
    local row = #lines
    table.insert(lines, text)
    if hls then
      for _, h in ipairs(hls) do
        table.insert(marks, { row, h[1], h[2], h[3] })
      end
    end
  end

  local function add_header(title, hl_group)
    local bar = pad_right(title, inner)
    add_line(pad .. bar, { { #pad, #pad + #bar, hl_group } })
    local rule = string.rep("─", inner)
    add_line(pad .. rule, { { #pad, #pad + #rule, "EfRule" } })
  end

  -- Section 1: Configuration
  add_header(" 󰒓  Configuration — " .. root_name .. " (" .. #ws.info.projects .. " projects, " .. #ws.info.contexts .. " DbContexts) ", "EfHeaderConfig")

  local function add_cfg_row(key, label, value, extra)
    local k = " " .. key .. " "
    local l = pad_right(label, 21)
    local v = value ~= "" and value or "(none)"
    local e = extra or ""
    local line = pad .. k .. l .. v .. e
    local off = #pad
    add_line(line, {
      { off, off + #k, "EfKey" },
      { off + #k, off + #k + #l, "EfLabel" },
      { off + #k + #l, off + #k + #l + #v, "EfValue" },
      e ~= "" and { off + #k + #l + #v, #line, "EfBadge" } or nil,
    })
  end

  add_cfg_row("[p]", "Migrations Project", cfg.migrations_project)
  add_cfg_row("[s]", "Startup Project", cfg.startup_project)
  add_cfg_row("[c]", "DbContext", cfg.context)
  add_cfg_row("[o]", "Output Dir", cfg.output_dir, "   (" .. #migrations .. " migrations  •  latest: " .. latest .. ")")
  add_cfg_row("[b]", "Build Config", cfg.configuration, "     [n] --no-build: " .. (cfg.no_build and "ON" or "OFF"))
  add_line("")

  -- Section 2: Actions (2-column grid when wide!)
  add_header(" 󰆼  Migration & Database Actions ", "EfHeaderAction")

  local action_items = {
    { "[a]", "Add Migration", "create new migration", false },
    { "[u]", "Update DB (Latest)", "apply pending migrations", false },
    { "[r]", "Remove Migration", "undo last migration", false },
    { "[t]", "Update DB (Target)", "Telescope + file preview", false },
    { "[l]", "List Migrations", "applied vs pending list", false },
    { "[m]", "Browse Migrations", "Telescope preview & open", false },
    { "[g]", "Generate SQL Script", "idempotent .sql script", false },
    { "[i]", "DbContext Info", "provider & connection", false },
    { "[R]", "Rescan Solution", "refresh .csproj & ctxs", false },
    { "[d]", "Drop Database", "destructive (type DROP)", true },
  }

  local two_col = inner >= 100
  if two_col then
    local gap = 4
    local col_w = math.floor((inner - gap) / 2)
    local gap_str = string.rep(" ", gap)
    local half = math.ceil(#action_items / 2)

    local function fmt_action(item)
      if not item then
        return string.rep(" ", col_w), {}
      end
      local k = " " .. item[1] .. " "
      local title = pad_right(item[2], 22)
      local desc_w = math.max(8, col_w - vim.fn.strdisplaywidth(k) - vim.fn.strdisplaywidth(title))
      local desc = item[3]
      if vim.fn.strdisplaywidth(desc) > desc_w then
        desc = vim.fn.strcharpart(desc, 0, desc_w - 1) .. "…"
      end
      local txt = pad_right(k .. title .. desc, col_w)
      return txt, {
        { 0, #k, item[4] and "EfDangerKey" or "EfKey" },
        { #k, #k + #title, item[4] and "EfDangerKey" or "NormalFloat" },
        { #k + #title, #txt, "EfLabel" },
      }
    end

    for i = 1, half do
      local l_txt, l_hls = fmt_action(action_items[i])
      local r_txt, r_hls = fmt_action(action_items[i + half])
      local full = pad .. l_txt .. gap_str .. r_txt
      local row_hls = {}
      local l_off = #pad
      for _, h in ipairs(l_hls) do
        table.insert(row_hls, { l_off + h[1], l_off + h[2], h[3] })
      end
      local r_off = #pad + #l_txt + #gap_str
      for _, h in ipairs(r_hls) do
        table.insert(row_hls, { r_off + h[1], r_off + h[2], h[3] })
      end
      add_line(full, row_hls)
    end
  else
    for _, item in ipairs(action_items) do
      local k = " " .. item[1] .. " "
      local title = pad_right(item[2], 26)
      local line = pad .. k .. title .. item[3]
      local off = #pad
      add_line(line, {
        { off, off + #k, item[4] and "EfDangerKey" or "EfKey" },
        { off + #k, off + #k + #title, item[4] and "EfDangerKey" or "NormalFloat" },
        { off + #k + #title, #line, "EfLabel" },
      })
    end
  end

  add_line("")

  -- Section 3: Command Preview
  add_header(" 󰆍  Command Preview ", "EfHeaderCmd")
  local preview = format_cmd(build_args(cfg, { "migrations", "add", "<Name>" }, { include_output_dir = true }))
  for _, wrapped in ipairs(wrap_text(preview, inner - 2)) do
    local line = pad .. " " .. wrapped
    add_line(line, { { #pad + 1, #line, "EfCmd" } })
  end
  add_line("")

  vim.bo[ui_buf].modifiable = true
  vim.api.nvim_buf_set_lines(ui_buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(ui_buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    if m then
      vim.api.nvim_buf_set_extmark(ui_buf, ns, m[1], m[2], {
        end_col = m[3],
        hl_group = m[4],
      })
    end
  end
  vim.bo[ui_buf].modifiable = false

  return #lines
end

local function bind_dashboard_keys(ws)
  local bmap = function(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buf = ui_buf, desc = desc, nowait = true })
  end

  local refresh = function()
    save_state(ws.info.root, ws.cfg)
    local w = vim.api.nvim_win_is_valid(ui_win) and vim.api.nvim_win_get_width(ui_win) or compute_width()
    render_dashboard(ws, w)
  end

  bmap("q", close_dashboard, "Close EF Core Manager")
  bmap("<Esc>", close_dashboard, "Close EF Core Manager")

  -- [p] Pick Migrations Project (Telescope + .csproj preview)
  bmap("p", function()
    if #ws.info.projects == 0 then
      vim.notify("No .csproj files found in solution", vim.log.levels.WARN)
      return
    end
    ef_pick(ws.info.projects, {
      prompt = "Select Migrations Project",
      format_item = format_project_entry,
      preview_path = function(p) return p.path end,
    }, function(choice)
      if choice then
        ws.cfg.migrations_project = choice.rel
        refresh()
      end
    end)
  end, "Select Migrations Project")

  -- [s] Pick Startup Project (Telescope + .csproj preview)
  bmap("s", function()
    if #ws.info.projects == 0 then
      vim.notify("No .csproj files found in solution", vim.log.levels.WARN)
      return
    end
    ef_pick(ws.info.projects, {
      prompt = "Select Startup Project",
      format_item = format_project_entry,
      preview_path = function(p) return p.path end,
    }, function(choice)
      if choice then
        ws.cfg.startup_project = choice.rel
        refresh()
      end
    end)
  end, "Select Startup Project")

  -- [c] Pick DbContext (Telescope + DbContext .cs preview; auto-updates Project & Output Dir!)
  bmap("c", function()
    if #ws.info.contexts == 0 then
      vim.ui.input({ prompt = "DbContext name: ", default = ws.cfg.context }, function(val)
        if val and val ~= "" then
          ws.cfg.context = val
          refresh()
        end
      end)
      return
    end
    ef_pick(ws.info.contexts, {
      prompt = "Select DbContext",
      format_item = function(item)
        return string.format("%-24s  (%s -> %s)", item.name, item.project, item.output_dir)
      end,
      preview_path = function(item) return item.file end,
    }, function(choice)
      if choice then
        ws.cfg.context = choice.name
        ws.cfg.migrations_project = choice.project
        ws.cfg.output_dir = choice.output_dir
        refresh()
      end
    end)
  end, "Select DbContext")

  -- [o] Edit Output Dir
  bmap("o", function()
    vim.ui.input({ prompt = "Migrations Output Dir (relative to project): ", default = ws.cfg.output_dir }, function(val)
      if val and val ~= "" then
        ws.cfg.output_dir = norm(val)
        refresh()
      end
    end)
  end, "Set Migrations Output Dir")

  -- [b] Toggle Debug / Release
  bmap("b", function()
    ws.cfg.configuration = ws.cfg.configuration == "Debug" and "Release" or "Debug"
    refresh()
  end, "Toggle Build Configuration")

  -- [n] Toggle --no-build
  bmap("n", function()
    ws.cfg.no_build = not ws.cfg.no_build
    refresh()
  end, "Toggle --no-build")

  -- [a] Add Migration
  bmap("a", function()
    vim.ui.input({ prompt = "New Migration Name: " }, function(name)
      if not name or vim.trim(name) == "" then
        return
      end
      run_ef_command(ws, { "migrations", "add", vim.trim(name) }, "Add " .. vim.trim(name), {
        include_output_dir = true,
      })
    end)
  end, "Add Migration")

  -- [r] Remove Last Migration (Telescope dropdown)
  bmap("r", function()
    local ctx_label = ws.cfg.context ~= "" and ws.cfg.context or "default context"
    ef_pick({ "Cancel", "Remove last migration", "Remove last migration (--force)" }, {
      prompt = "Remove Migration (" .. ctx_label .. ")",
    }, function(choice)
      if choice == "Remove last migration" then
        run_ef_command(ws, { "migrations", "remove" }, "Remove Migration")
      elseif choice == "Remove last migration (--force)" then
        run_ef_command(ws, { "migrations", "remove", "--force" }, "Remove Migration (--force)")
      end
    end)
  end, "Remove Last Migration")

  -- [u] Update Database (Latest)
  bmap("u", function()
    run_ef_command(ws, { "database", "update" }, "Update Database (Latest)")
  end, "Update Database to Latest")

  -- [t] Update Database (Target migration via Telescope + live .cs preview!)
  bmap("t", function()
    local mig_dir = find_project_dir(ws, ws.cfg.migrations_project)
    local migrations = list_migration_files(mig_dir, ws.cfg.output_dir)
    local choices = {
      { label = "Latest (apply all pending)", action = "latest" },
      { label = "0 (revert ALL migrations)", action = "zero" },
    }
    for _, m in ipairs(migrations) do
      table.insert(choices, { label = m.id, action = "target", id = m.id, path = m.path })
    end
    table.insert(choices, { label = "Custom migration name...", action = "custom" })

    ef_pick(choices, {
      prompt = "Update Database to Target (" .. ws.cfg.context .. ")",
      format_item = function(item) return item.label end,
      preview_path = function(item) return item.path end,
    }, function(choice)
      if not choice then
        return
      end
      if choice.action == "latest" then
        run_ef_command(ws, { "database", "update" }, "Update Database (Latest)")
      elseif choice.action == "zero" then
        run_ef_command(ws, { "database", "update", "0" }, "Revert All Migrations (0)")
      elseif choice.action == "custom" then
        vim.ui.input({ prompt = "Target migration name: " }, function(val)
          if val and vim.trim(val) ~= "" then
            run_ef_command(ws, { "database", "update", vim.trim(val) }, "Update Database -> " .. vim.trim(val))
          end
        end)
      elseif choice.id then
        run_ef_command(ws, { "database", "update", choice.id }, "Update Database -> " .. choice.id)
      end
    end)
  end, "Update Database to Target Migration")

  -- [l] List Migrations
  bmap("l", function()
    run_ef_command(ws, { "migrations", "list" }, "List Migrations")
  end, "List Migrations")

  -- [m] Browse & Open Migration File via Telescope (with live preview!)
  bmap("m", function()
    local mig_dir = find_project_dir(ws, ws.cfg.migrations_project)
    local migrations = list_migration_files(mig_dir, ws.cfg.output_dir)
    if #migrations == 0 then
      vim.notify("No migration files found in " .. ws.cfg.output_dir, vim.log.levels.WARN)
      return
    end
    ef_pick(migrations, {
      prompt = "Browse Migrations (" .. ws.cfg.context .. ")",
      format_item = function(m) return m.id end,
      preview_path = function(m) return m.path end,
    }, function(choice)
      if choice and choice.path then
        close_dashboard()
        vim.cmd.edit(vim.fn.fnameescape(choice.path))
      end
    end)
  end, "Browse & Open Migration File")

  -- [g] Generate Idempotent SQL Script
  bmap("g", function()
    local default_file = vim.fs.joinpath(
      ws.info.root,
      (ws.cfg.context ~= "" and ws.cfg.context or "ef") .. "_migration.sql"
    )
    vim.ui.input({ prompt = "SQL Script Output Path (blank = stdout): ", default = default_file }, function(out)
      if out == nil then
        return
      end
      local sub = { "migrations", "script", "--idempotent" }
      if vim.trim(out) ~= "" then
        vim.list_extend(sub, { "--output", vim.trim(out) })
      end
      run_ef_command(ws, sub, "Generate SQL Script", {
        on_success = function()
          if vim.trim(out) ~= "" and vim.uv.fs_stat(vim.trim(out)) then
            vim.notify("SQL script written to " .. vim.trim(out), vim.log.levels.INFO)
          end
        end,
      })
    end)
  end, "Generate Idempotent SQL Script")

  -- [i] DbContext Info
  bmap("i", function()
    run_ef_command(ws, { "dbcontext", "info" }, "DbContext Info")
  end, "DbContext Info")

  -- [d] Drop Database (with confirmation)
  bmap("d", function()
    vim.ui.input({ prompt = "DANGER! Type DROP to drop database for " .. ws.cfg.context .. ": " }, function(confirm)
      if confirm == "DROP" then
        run_ef_command(ws, { "database", "drop", "--force" }, "Drop Database")
      else
        vim.notify("Drop Database cancelled", vim.log.levels.INFO)
      end
    end)
  end, "Drop Database")

  -- [R] Rescan Solution
  bmap("R", function()
    local rescanned = get_workspace(true)
    ws.info = rescanned.info
    ws.cfg = rescanned.cfg
    refresh()
    vim.notify("Rescanned solution (" .. #ws.info.projects .. " projects, " .. #ws.info.contexts .. " DbContexts)", vim.log.levels.INFO)
  end, "Rescan Solution")
end

function M.open()
  if vim.api.nvim_win_is_valid(ui_win) then
    close_dashboard()
    return
  end

  local ws = get_workspace(false)

  if not vim.api.nvim_buf_is_valid(ui_buf) then
    ui_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[ui_buf].bufhidden = "hide"
    vim.bo[ui_buf].filetype = "efcore"
    vim.bo[ui_buf].buftype = "nofile"
  end

  local width = compute_width()
  local content_height = render_dashboard(ws, width)
  local height = math.min(content_height, math.max(18, math.floor(vim.o.lines * 0.86)))

  bind_dashboard_keys(ws)

  ui_win = vim.api.nvim_open_win(ui_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " 󰆼  EF Core Migrations Manager ",
    title_pos = "center",
    footer = " q / <Esc>: close  •  p/s/c: Telescope pickers  •  R: rescan ",
    footer_pos = "center",
  })

  vim.wo[ui_win].wrap = false
  vim.wo[ui_win].cursorline = true
end

vim.api.nvim_create_user_command("EFCore", M.open, { desc = "Open EF Core Migrations Manager popup" })
vim.keymap.set("n", "<leader>ce", M.open, { desc = "EF Core Migrations Manager" })

return M
