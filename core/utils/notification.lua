local L = XelosesContacts.getString
local F = XelosesContacts.formatString

-- -----------------------------------
--  @SECTION Notifications and Alerts
-- -----------------------------------

function XelosesContacts:isChatNotificationsEnabled()
    return (self.config.notifications.channel ~= self.CONST.NOTIFICATION_CHANNELS.SCREEN)
end

function XelosesContacts:isScreenNotificationsEnabled()
    return (self.config.notifications.channel ~= self.CONST.NOTIFICATION_CHANNELS.CHAT)
end

-- ------------------------

function XelosesContacts:Notify(msg, ...)
    if (self:isChatNotificationsEnabled() and self.config.chat.log) then self:PrintInfo(msg, ...) end
    if (self:isScreenNotificationsEnabled()) then self:Alert(msg, ...) end
end

function XelosesContacts:Warn(msg, ...)
    if (self:isChatNotificationsEnabled()) then self:PrintWarning(msg, ...) end
    if (self:isScreenNotificationsEnabled()) then
        local s = L("WARNING"):colorize(self.CONST.COLOR.WARN) .. " " .. msg
        self:Alert(s, ...)
    end
end

function XelosesContacts:ShowError(msg, ...)
    if (self:isChatNotificationsEnabled()) then self:PrintError(msg, ...) end
    if (self:isScreenNotificationsEnabled()) then
        local s = L("ERROR"):colorize(self.CONST.COLOR.ERROR) .. ": " .. msg
        self:Alert(s, ...)
    end
end

-- ------------------------

function XelosesContacts:Alert(msg, ...)
    if (not msg or msg == "") then return end
    local s = (select("#", ...) > 0) and F(msg, ...) or msg
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, self:addPrefix(s))
end

-- ------------------------

--[[
Create center screen announcement.

XelosesContacts:Announce(string Message, table Options)

@param Message - Announcement text.
@param Options - [optional] Table with additional options:
                 {
                    string title     - Announcement title (header);
                    string sound     - Path to sound file to play with announcement;
                    string icon      - Icon for announcement;
                    number timeout   - Timeout (in milliseconds) for announcement;
                    table textParams - table with params used to format announcement text;
                 }
]]
function XelosesContacts:Announce(msg, options)
    if (not msg or msg:isEmpty()) then return end

    options = options or {}

    local s = msg
    local header = options.title or self.tag

    if (options.textParams) then
        s = F(msg, options.textParams)
    end

    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)

    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
    params:SetText(header, s)
    params:SetIconData(options.icon or self.CONST.ICONS.UI.NOTIFICATION.DEFAULT)
    params:SetSound(options.sound or self.CONST.SOUND.NOTIFICATION.DEFAULT)
    params:SetLifespanMS(options.timeout or 5000)
    params:MarkShowImmediately()

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end
