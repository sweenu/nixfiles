-- Workspace-to-monitor placement: "asdf" (1-4) live on the external monitor
-- when one is connected, else on the laptop; "uiop" (5-8) always on the
-- laptop.
local laptop = "eDP-1"

local function external_monitor()
  for _, m in ipairs(hl.get_monitors()) do
    if m.name ~= laptop and not m.is_mirror then
      return m.name
    end
  end
  return nil
end

local function place_workspaces()
  local ext = external_monitor()
  local asdf = ext or laptop
  for ws = 1, 4 do
    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(ws), monitor = asdf }))
  end
  for ws = 5, 8 do
    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(ws), monitor = laptop }))
  end
  if ext then
    -- External just appeared: give the laptop a real active workspace so
    -- no empty one is auto-spawned, then land focus on the external.
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
