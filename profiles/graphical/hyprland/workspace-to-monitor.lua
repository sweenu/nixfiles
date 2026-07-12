-- Workspace-to-monitor placement: "asdf" (1-4) live on the external monitor
-- when one is connected, else on the laptop; "uiop" (5-8) always live on the
-- laptop (bound statically via workspace_rule in default.nix).
--
-- Placement is done through workspace rules (a monitor binding) rather than
-- persistent workspaces. Rules apply when a workspace is created, so focusing
-- an as-yet-uncreated workspace drops it straight onto the intended monitor.
-- Because the workspaces are not persistent, empty ones are destroyed on leave
-- and never linger in the bar as a stray active workspace after a hotplug.
local laptop = "eDP-1"
local asdf_names = { "a", "s", "d", "f" }

local function external_monitor()
  for _, m in ipairs(hl.get_monitors()) do
    if m.name ~= laptop and not m.is_mirror then
      return m.name
    end
  end
  return nil
end

local function place_workspaces()
  local target = external_monitor() or laptop

  -- (Re)bind where the asdf workspaces are (re)created from now on. Names are
  -- set here too so this file is the single source of truth for 1-4.
  for ws = 1, 4 do
    hl.workspace_rule({
      workspace = tostring(ws),
      default_name = asdf_names[ws],
      default = ws == 1,
      monitor = target,
    })
  end

  -- Rules only affect creation; migrate any already-open asdf workspaces onto
  -- the target monitor. Empty ones simply don't exist here, so nothing strays.
  for _, w in ipairs(hl.get_workspaces()) do
    if w.id >= 1 and w.id <= 4 then
      hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(w.id), monitor = target }))
    end
  end

  if external_monitor() then
    -- External just appeared: give the laptop a real active workspace so no
    -- empty one is auto-spawned, then land focus on the external.
    hl.dispatch(hl.dsp.focus({ workspace = 5 }))
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
  end
end

-- Debounce: coalesce the burst of events during a hotplug into a single
-- placement pass ~600ms after the last one, once the layout has settled.
local pending
local function schedule_workspaces_placement()
  if pending then pending:set_enabled(false) end
  pending = hl.timer(place_workspaces, { timeout = 600, type = "oneshot" })
end

hl.on("hyprland.start", schedule_workspaces_placement)
hl.on("monitor.added", schedule_workspaces_placement)
hl.on("monitor.removed", schedule_workspaces_placement)
