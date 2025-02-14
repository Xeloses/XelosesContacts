local XC                      = XelosesContacts
local CONST                   = XC.CONST
local L                       = XC.getString
local T                       = type

XELOSES_CONTACTS_RETICLE_SIZE = 40

local POSITION                = CONST.UI.RETICLE_MARKER.POSITION
local DEFAULTS                = XC.defaults.reticle

-- ---------------
--  @SECTION Init
-- ---------------

XelosesReticleMarker          = ZO_Object:Subclass()

function XelosesReticleMarker:New(parent_control, params)
    local marker = ZO_Object.New(self)
    marker.parent = parent_control
    marker:Initialize(params)
    return marker
end

function XelosesReticleMarker:Initialize(params)
    self.container = XelosesReticleMarkerFrame

    self.UI = {
        caption = GetControl(self.container, "Caption"),
        icon    = GetControl(self.container, "Icon")
    }

    self.shown = false
    self.default_color = ZO_ColorDef:New(ZO_ReticleContainerReticle:GetColor() or { r = 1, g = 1, b = 1, a = 0.75 })

    local p = (T(params) == "table") and params or {}

    self:SetPosition(p.position or DEFAULTS.position)
    self:SetOffset(p.offset or DEFAULTS.offset)

    self.UI.caption:SetColor(self.default_color:UnpackRGBA())
    self:SetCaptionFont({
        size = p.font.size or DEFAULTS.font.size,
        style = p.font.style or DEFAULTS.font.style,
    })
    self:SetIconSize(p.icon and p.icon.size or DEFAULTS.icon.size)
    self:SetIconVisibility(p.icon and p.icon.enabled or DEFAULTS.icon.enabled)

    return self
end

-- ------------------
--  @SECTION Display
-- ------------------

function XelosesReticleMarker:Setup(text, icon, color)
    if (not text or text:isEmpty()) then return self:Reset() end

    color = ZO_ColorDef:New(color) or self.default_color

    ZO_ReticleContainerReticle:SetColor(color:UnpackRGBA())

    self:SetIcon(icon, color)
    self:SetCaption(text)

    self.shown = true
end

function XelosesReticleMarker:Reset()
    if (not self.shown) then return end

    ZO_ReticleContainerReticle:SetColor(self.default_color:UnpackRGBA())

    self:SetIcon(nil)
    self:SetCaption("")

    self.shown = false
end

function XelosesReticleMarker:Show(text, icon, color)
    self:Setup(text, icon, color)
end

function XelosesReticleMarker:Hide()
    self:Reset()
end

-- ----------------
--  @SECTION Frame
-- ----------------

function XelosesReticleMarker:SetPosition(pos)
    if (self.position == pos) then return end

    if (self.position and self.offset) then
        self:InvertOffset()
    end

    self.UI.icon:ClearAnchors()
    self.UI.caption:ClearAnchors()

    if (pos == POSITION.ABOVE) then
        self.UI.caption:SetAnchor(BOTTOM, self.container, TOP, 0, 0)
        self.UI.icon:SetAnchor(BOTTOM, self.UI.caption, TOP, 0, 0)
    elseif (pos == POSITION.BELOW) then
        self.UI.caption:SetAnchor(TOP, self.container, BOTTOM, 0, 0)
        self.UI.icon:SetAnchor(TOP, self.UI.caption, BOTTOM, 0, 0)
    end

    self.position = pos
end

function XelosesReticleMarker:SetOffset(offset)
    local y = offset * ((self.position == POSITION.ABOVE) and -1 or 1)
    if (self.offset == y) then return end

    self.container:ClearAnchors()
    self.container:SetAnchor(CENTER, ZO_ReticleContainerReticle, CENTER, 0, y)
    self.offset = y
end

function XelosesReticleMarker:InvertOffset()
    if (self.offset) then
        self:SetOffset(self.offset * -1)
    end
end

-- -------------------
--  @SECTION Controls
-- -------------------

function XelosesReticleMarker:SetCaption(text)
    local s = (T(text) == "string") and text:trim() or ""

    self.UI.caption:SetText(s)
    self.UI.caption:SetDimensions(self.UI.caption:GetTextDimensions())
    self.UI.caption:SetHidden(s:isEmpty())
end

function XelosesReticleMarker:SetIcon(icon, color)
    if (self.icon_show and icon) then
        if (not color) then
            color = self.default_color
        elseif (T(color) == "string") then
            color = ZO_ColorDef:New(color)
        end

        self.UI.icon:SetColor(color:UnpackRGBA())
        self.UI.icon:SetTexture(icon)
        self.UI.icon:SetHidden(false)
    else
        self.UI.icon:SetHidden(true)
    end
end

function XelosesReticleMarker:SetCaptionFont(font_params)
    if (T(font_params) ~= "table") then return end

    local font_size  = font_params.size or self.font_size
    local font_style = font_params.style or self.font_style

    if (self.font_size == font_size and self.font_style == font_style) then return end

    self.font_size  = font_size
    self.font_style = font_style

    local font      = ("$(BOLD_FONT)|%s|%s"):format(font_size, font_style)
    self.UI.caption:SetFont(font)
end

function XelosesReticleMarker:SetIconSize(size)
    if (not size or self.icon_size == size) then return end

    self.icon_size = size
    self.UI.icon:SetDimensions(size, size)
end

function XelosesReticleMarker:SetIconVisibility(visible)
    self.icon_show = visible
end
