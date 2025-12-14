--[[--
Auto-rotate module for Maximum plugin.
Based on https://github.com/Extraltodeus/koreader-autorotate
@module maximum.autorotate
]]--

local Device = require("device")
local Event = require("ui/event")
local UIManager = require("ui/uimanager")
local Screen = Device.screen

local AutoRotate = {
    enabled = true,
    clockwise = true,
    last_portrait_rotation_mode = nil,
}

function AutoRotate:init(Settings)
    self.enabled = Settings:get("autorotate_enabled")
    self.clockwise = Settings:get("rotate_clockwise")
    self.last_portrait_rotation_mode = Screen:getRotationMode()
end

function AutoRotate:reset()
    self.last_portrait_rotation_mode = nil
end

function AutoRotate:onPageUpdate(document, pageno)
    if not self.enabled or not document then return end

    local page_size = document:getNativePageDimensions(pageno)
    if not page_size then return end

    local cur_rotation = Screen:getRotationMode()

    if page_size.w > page_size.h then
        if cur_rotation == Screen.DEVICE_ROTATED_UPRIGHT or
           cur_rotation == Screen.DEVICE_ROTATED_UPSIDE_DOWN then
            self.last_portrait_rotation_mode = cur_rotation
            local new_rotation
            if self.clockwise then
                new_rotation = Screen.DEVICE_ROTATED_CLOCKWISE
            else
                new_rotation = Screen.DEVICE_ROTATED_COUNTER_CLOCKWISE
            end
            UIManager:broadcastEvent(Event:new("SetRotationMode", new_rotation))
        end
    else
        if cur_rotation == Screen.DEVICE_ROTATED_CLOCKWISE or
           cur_rotation == Screen.DEVICE_ROTATED_COUNTER_CLOCKWISE then
            local new_rotation = self.last_portrait_rotation_mode or Screen.DEVICE_ROTATED_UPRIGHT
            UIManager:broadcastEvent(Event:new("SetRotationMode", new_rotation))
        end
    end
end

function AutoRotate:restorePortrait()
    local cur_rotation = Screen:getRotationMode()
    if cur_rotation == Screen.DEVICE_ROTATED_CLOCKWISE or
       cur_rotation == Screen.DEVICE_ROTATED_COUNTER_CLOCKWISE then
        local new_rotation = self.last_portrait_rotation_mode or Screen.DEVICE_ROTATED_UPRIGHT
        Screen:setRotationMode(new_rotation)
        UIManager:broadcastEvent(Event:new("SetRotationMode", new_rotation))
    end
end

function AutoRotate:toggle()
    self.enabled = not self.enabled
    if not self.enabled then
        self:restorePortrait()
    end
    return self.enabled
end

function AutoRotate:setDirection(clockwise)
    self.clockwise = clockwise
end

return AutoRotate
