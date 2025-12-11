--[[--
MangaGrid plugin for KOReader
Divides the screen into 4 cells (2x2) for manga reading.
TWO-FINGER TAP on any quadrant to zoom it to fullscreen.
TWO-FINGER TAP again to return to grid view.
Only for CBZ and CBR files.

@module koplugin.maximun
@credits @shac0x
]]--

local Device = require("device")
local Event = require("ui/event")
local Geom = require("ui/geometry")
local InputContainer = require("ui/widget/container/inputcontainer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local logger = require("logger")
local _ = require("gettext")
local Screen = Device.screen

local Maximun = InputContainer:extend{
    name = "maximun",
    is_doc_only = false,
}

local grid_enabled = true
local expanded_cell = nil
local original_zoom_mode = nil

function Maximun:init()
    self.ui.menu:registerToMainMenu(self)
    logger.info("Maximun: Plugin initialized")
end

function Maximun:onReaderReady()
    self:setupTouchZones()
    grid_enabled = true
end

function Maximun:setupTouchZones()
    if not Device:isTouchDevice() then return end

    self.ui:registerTouchZones({
        {
            id = "maximun_2tap_q1",
            ges = "two_finger_tap",
            screen_zone = { ratio_x = 0, ratio_y = 0, ratio_w = 0.5, ratio_h = 0.5 },
            handler = function(ges) return self:onGridGesture(1, ges) end,
        },
        {
            id = "maximun_2tap_q2",
            ges = "two_finger_tap",
            screen_zone = { ratio_x = 0.5, ratio_y = 0, ratio_w = 0.5, ratio_h = 0.5 },
            handler = function(ges) return self:onGridGesture(2, ges) end,
        },
        {
            id = "maximun_2tap_q3",
            ges = "two_finger_tap",
            screen_zone = { ratio_x = 0, ratio_y = 0.5, ratio_w = 0.5, ratio_h = 0.5 },
            handler = function(ges) return self:onGridGesture(3, ges) end,
        },
        {
            id = "maximun_2tap_q4",
            ges = "two_finger_tap",
            screen_zone = { ratio_x = 0.5, ratio_y = 0.5, ratio_w = 0.5, ratio_h = 0.5 },
            handler = function(ges) return self:onGridGesture(4, ges) end,
        },
        {
            id = "maximun_single_tap",
            ges = "tap",
            screen_zone = { ratio_x = 0, ratio_y = 0, ratio_w = 1, ratio_h = 1 },
            handler = function(ges) return self:onSingleTap(ges) end,
        },
    })
    logger.info("Maximun: Touch zones registered")
end

function Maximun:isComic()
    if not self.ui or not self.ui.document then
        return false
    end
    local file = self.ui.document.file
    if not file then return false end
    local ext = file:match("%.([^%.]+)$")
    if ext then
        ext = ext:lower()
        return ext == "cbz" or ext == "cbr" or ext == "pdf"
    end
    return false
end

function Maximun:onGridGesture(quadrant, ges)
    if not grid_enabled then
        return false
    end

    if not self:isComic() then
        return false
    end

    logger.info("Maximun: Gesture on quadrant", quadrant)

    if expanded_cell then
        self:collapseCell()
    else
        self:expandCell(quadrant)
    end

    return true
end

function Maximun:addToMainMenu(menu_items)
    menu_items.manga_grid = {
        text = _("Manga Grid"),
        sorting_hint = "more_tools",
        sub_item_table = {
            {
                text = _("Enable Grid Mode"),
                checked_func = function()
                    return grid_enabled
                end,
                callback = function()
                    self:toggleGrid()
                end,
                favorite = true,
            },
            {
                text = _("About"),
                callback = function()
                    UIManager:show(InfoMessage:new{
                        text = "Manga Grid\n\n2-FINGER TAP to zoom quadrant.\n2-FINGER TAP to return.\n\nCBZ/CBR only.",
                    })
                end,
            },
        },
    }
end

function Maximun:toggleGrid()
    if not self:isComic() then
        UIManager:show(InfoMessage:new{
            text = "Open a CBZ, CBR or PDF file first.",
            timeout = 2,
        })
        return
    end

    grid_enabled = not grid_enabled

    if not grid_enabled and expanded_cell then
        self:collapseCell()
    end

    UIManager:show(InfoMessage:new{
        text = grid_enabled 
            and "Grid Mode ON\n2-FINGER TAP any quadrant" 
            or "Grid Mode OFF",
        timeout = 2,
    })
end

function Maximun:expandCell(cell)
    local view = self.ui.view
    local paging = self.ui.paging
    local zooming = self.ui.zooming

    if not view or not zooming then
        logger.warn("Maximun: Components not available")
        return
    end

    original_zoom_mode = zooming.zoom_mode

    expanded_cell = cell

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

    logger.info("Maximun: Expanded cell", cell, "zoom:", new_zoom)
end

function Maximun:collapseCell()
    local zooming = self.ui.zooming

    if not zooming then return end

    expanded_cell = nil

    if original_zoom_mode then
        self.ui:handleEvent(Event:new("SetZoomMode", original_zoom_mode))
        original_zoom_mode = nil
    else
        self.ui:handleEvent(Event:new("SetZoomMode", "page"))
    end

    self.ui:handleEvent(Event:new("RedrawCurrentView"))
    UIManager:setDirty(self.ui.view, "full")

    logger.info("Maximun: Collapsed")
end

function Maximun:onSingleTap(ges)
    if expanded_cell then
        self:collapseCell()
        return true
    end
    return false
end

function Maximun:onCloseDocument()
    grid_enabled = false
    expanded_cell = nil
    original_zoom_mode = nil
end

return Maximun
