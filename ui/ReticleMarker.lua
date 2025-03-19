local T                       = type

-- --------------------
--  @SECTION Constants
-- --------------------

XELOSES_CONTACTS_RETICLE_SIZE = 40

XelosesReticleMarker          = {
    DISPLAY_MODE = {
        TEXT = 1,
        ICON = 2,
        FULL = 255,
    },

    POSITION     = {
        ABOVE = 1,
        BELOW = 2,
    },

    ICON_SIZE    = {
        SMALL  = 32,
        MEDIUM = 48,
        BIG    = 64,
    },

    MIN_OFFSET   = 0,
    MAX_OFFSET   = 50,
}

local DEFAULTS                = {
    DISPLAY_MODE = XelosesReticleMarker.DISPLAY_MODE.FULL,
    POSITION     = XelosesReticleMarker.POSITION.BELOW,
    ICON_SIZE    = XelosesReticleMarker.ICON_SIZE.MEDIUM,
    OFFSET       = 10,
    FONT_SIZE    = 20,
    FONT_STYLE   = "outline",
    COLOR        = ZO_ColorDef:New(ZO_ReticleContainerReticle:GetColor()) or ZO_ColorDef:New(1, 1, 1, 0.75)
}

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesReticleMarker:Initialize(parent, params)
    local config = (T(params) == "table") and params or {}

    self.parent  = parent
    self.frame   = XelosesReticleMarkerFrame

    self.UI      = {
        caption = GetControl(self.frame, "Caption"),
        icon    = GetControl(self.frame, "Icon")
    }

    self.shown   = false

    self:SetDisplayMode(config.mode)

    self:SetPosition(config.position)
    self:SetOffset(config.offset)

    self.UI.caption:SetColor(DEFAULTS.COLOR:UnpackRGBA())
    self:SetCaptionFont(config.font)

    self:SetIconSize(config.icon and config.icon.size)
    self:ToggleReticleColorizer(config.colorize_reticle)

    return self
end

-- ------------------
--  @SECTION Display
-- ------------------

function XelosesReticleMarker:Setup(text, icon, color)
    if (not text or text:isEmpty()) then return self:Reset() end

    color = ZO_ColorDef:New(color) or DEFAULTS.COLOR

    if (self.colorize_reticle) then
        ZO_ReticleContainerReticle:SetColor(color:UnpackRGBA())
    end

    self:SetIcon(icon, color)
    self:SetCaption(text)

    self.shown = true
end

function XelosesReticleMarker:Reset()
    if (not self.shown) then return end

    if (self.colorize_reticle) then
        ZO_ReticleContainerReticle:SetColor(DEFAULTS.COLOR:UnpackRGBA())
    end

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

    if (pos == self.POSITION.ABOVE) then
        self.UI.caption:SetAnchor(BOTTOM, self.frame, TOP, 0, 0)
        self.UI.icon:SetAnchor(BOTTOM, self.UI.caption, TOP, 0, 0)
    elseif (pos == self.POSITION.BELOW) then
        self.UI.caption:SetAnchor(TOP, self.frame, BOTTOM, 0, 0)
        self.UI.icon:SetAnchor(TOP, self.UI.caption, BOTTOM, 0, 0)
    end

    self.position = pos
end

function XelosesReticleMarker:SetOffset(offset)
    local y = offset * ((self.position == self.POSITION.ABOVE) and -1 or 1)
    if (self.offset == y) then return end

    self.frame:ClearAnchors()
    self.frame:SetAnchor(CENTER, ZO_ReticleContainerReticle, CENTER, 0, y)
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
    local str     = (T(text) == "string") and text:trim()
    local visible = self.show_caption and str and str:len() > 0

    if (visible) then
        self.UI.caption:SetText(str)
        self.UI.caption:SetDimensions(self.UI.caption:GetTextDimensions())
    end

    self.UI.caption:SetHidden(not visible)
end

function XelosesReticleMarker:SetCaptionFont(font_params)
    if (self.font_size == font_params.size and self.font_style == font_params.style) then return end

    self.font_size  = font_params.size
    self.font_style = font_params.style

    local font      = ("$(BOLD_FONT)|%s|%s"):format(font_params.size, font_params.style)
    self.UI.caption:SetFont(font)
end

function XelosesReticleMarker:SetIcon(icon, color)
    local visible = self.show_icon and icon

    if (visible) then
        if (not color) then
            color = DEFAULTS.COLOR
        elseif (T(color) == "string") then
            color = ZO_ColorDef:New(color)
        end

        self.UI.icon:SetColor(color:UnpackRGBA())
        self.UI.icon:SetTexture(icon)
    end

    self.UI.icon:SetHidden(not visible)
end

function XelosesReticleMarker:SetIconSize(size)
    if (self.icon_size == size) then return end

    self.icon_size = size
    self.UI.icon:SetDimensions(size, size)
end

-- -------------------------------
--  @SECTION Utility & Properties
-- -------------------------------

function XelosesReticleMarker:SetDisplayMode(display_mode)
    self.mode         = display_mode
    self.show_icon    = BitAnd(display_mode, self.DISPLAY_MODE.ICON) > 0
    self.show_caption = BitAnd(display_mode, self.DISPLAY_MODE.TEXT) > 0
end

function XelosesReticleMarker:ToggleReticleColorizer(enabled)
    self.colorize_reticle = enabled or false
end
