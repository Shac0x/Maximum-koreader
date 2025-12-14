--[[--
Maximum plugin for KOReader
@module koplugin.maximum
@credits @shac0x
]]--

local InputContainer = require("ui/widget/container/inputcontainer")

local Settings = require("settings")
local AutoRotate = require("autorotate")
local Grid = require("grid")
local Menu = require("menu")

local SUPPORTED_EXTENSIONS = {
    cbz = true,
    cbr = true,
    pdf = true,
}

local Maximum = InputContainer:extend{
    name = "maximum",
    is_doc_only = true,
}

function Maximum:init()
    self.ui.menu:registerToMainMenu(self)
end

function Maximum:onReaderReady()
    Grid:init(self.ui, Settings)
    Grid:setupTouchZones(function(quadrant, ges)
        return self:onGridGesture(quadrant, ges)
    end)
    AutoRotate:init(Settings)
end

function Maximum:isComic()
    local doc = self.ui and self.ui.document
    if not doc or not doc.file then return false end
    local ext = doc.file:match("%.([^%.]+)$")
    return ext and SUPPORTED_EXTENSIONS[ext:lower()] or false
end

function Maximum:onPageUpdate(pageno)
    if self:isComic() then
        AutoRotate:onPageUpdate(self.ui.document, pageno)
    end
end

function Maximum:onGridGesture(quadrant, ges)
    if not self:isComic() then return false end
    return Grid:onGesture(quadrant)
end

function Maximum:addToMainMenu(menu_items)
    menu_items.maximum = Menu:build(self, Grid, AutoRotate, Settings)
end

function Maximum:onCloseDocument()
    Grid:reset()
    if AutoRotate.enabled then
        AutoRotate:restorePortrait()
    end
    AutoRotate:reset()
end

return Maximum
