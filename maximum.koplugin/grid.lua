--[[--
Grid zoom module for Maximum plugin.
@module maximum.grid
]]--

local Device = require("device")
local Event = require("ui/event")
local Geom = require("ui/geometry")
local UIManager = require("ui/uimanager")
local Screen = Device.screen

local Grid = {
    enabled = true,
    expanded_cell = nil,
    original_zoom_mode = nil,
    ui = nil,
}

local QUADRANTS = {
    { id = "maximum_2tap_q1", x = 0,   y = 0,   w = 0.5, h = 0.5 },
    { id = "maximum_2tap_q2", x = 0.5, y = 0,   w = 0.5, h = 0.5 },
    { id = "maximum_2tap_q3", x = 0,   y = 0.5, w = 0.5, h = 0.5 },
    { id = "maximum_2tap_q4", x = 0.5, y = 0.5, w = 0.5, h = 0.5 },
}

function Grid:init(ui, Settings)
    self.ui = ui
    self.enabled = Settings:get("grid_enabled")
    self.expanded_cell = nil
    self.original_zoom_mode = nil
end

function Grid:reset()
    self.expanded_cell = nil
    self.original_zoom_mode = nil
end

function Grid:setupTouchZones(handler)
    if not Device:isTouchDevice() then return end

    local zones = {}
    for i, q in ipairs(QUADRANTS) do
        zones[#zones + 1] = {
            id = q.id,
            ges = "two_finger_tap",
            screen_zone = { ratio_x = q.x, ratio_y = q.y, ratio_w = q.w, ratio_h = q.h },
            handler = function(ges) return handler(i, ges) end,
        }
    end

    zones[#zones + 1] = {
        id = "maximum_single_tap",
        ges = "tap",
        screen_zone = { ratio_x = 0, ratio_y = 0, ratio_w = 1, ratio_h = 1 },
        handler = function(ges) return self:onSingleTap(ges) end,
    }

    self.ui:registerTouchZones(zones)
end

function Grid:expand(cell)
    local view = self.ui.view
    local zooming = self.ui.zooming

    if not view or not zooming then return end

    self.original_zoom_mode = zooming.zoom_mode
    self.expanded_cell = cell

    local col = (cell - 1) % 2
    local row = math.floor((cell - 1) / 2)

    local screen_w = Screen:getWidth()
    local screen_h = Screen:getHeight()

    local center_x = (col * screen_w / 2) + (screen_w / 4)
    local center_y = (row * screen_h / 2) + (screen_h / 4)

    local pos = Geom:new{
        x = center_x,
        y = center_y,
        w = 0,
        h = 0,
    }

    self.ui:handleEvent(Event:new("SetZoomMode", "manual"))

    local current_zoom = view.state.zoom or 1
    local new_zoom = current_zoom * 1

    zooming.zoom = new_zoom
    view:onZoomUpdate(new_zoom)

    if view.SetZoomCenter then
        view:SetZoomCenter(center_x * 2, center_y * 2)
    end

    self.ui:handleEvent(Event:new("RedrawCurrentView"))
    UIManager:setDirty(view, "full")
end

function Grid:collapse()
    local zooming = self.ui.zooming
    if not zooming then return end

    self.expanded_cell = nil

    if self.original_zoom_mode then
        self.ui:handleEvent(Event:new("SetZoomMode", self.original_zoom_mode))
        self.original_zoom_mode = nil
    else
        self.ui:handleEvent(Event:new("SetZoomMode", "page"))
    end

    self.ui:handleEvent(Event:new("RedrawCurrentView"))
    UIManager:setDirty(self.ui.view, "full")
end

function Grid:onGesture(quadrant)
    if not self.enabled then return false end

    if self.expanded_cell then
        self:collapse()
    else
        self:expand(quadrant)
    end

    return true
end

function Grid:onSingleTap(ges)
    if self.expanded_cell then
        self:collapse()
        return true
    end
    return false
end

function Grid:toggle()
    self.enabled = not self.enabled
    if not self.enabled and self.expanded_cell then
        self:collapse()
    end
    return self.enabled
end

return Grid
