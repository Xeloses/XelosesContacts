local L = XelosesContacts.getString
local F = XelosesContacts.formatString

-- -------------------------
--  @SECTION Chat utulities
-- -------------------------

function XelosesContacts:Print(msg, ...)
    if (not self.loaded or not msg or msg == "") then return end

    local s = F(msg, ...)

    if (self.Chat.lib) then
        self.Chat.lib:SetTagColor(self.CONST.COLOR.TAG):Print(s)
    else
        CHAT_SYSTEM:AddMessage(self:addPrefix(s))
    end
end

function XelosesContacts:PrintInfo(msg, ...)
    self:Print(msg, ...)
end

function XelosesContacts:PrintWarning(msg, ...)
    local s = L("WARNING"):colorize(self.CONST.COLOR.WARNING) .. " " .. msg
    XelosesContacts:Print(s, ...)
end

function XelosesContacts:PrintError(msg, ...)
    local s = L("ERROR"):colorize(self.CONST.COLOR.ERROR) .. ": " .. msg
    XelosesContacts:Print(s, ...)
end

-- -------------------------

function XelosesContacts.Chat:Whisper(target_name)
    if (target_name) then
        StartChatInput("", CHAT_CHANNEL_WHISPER, target_name)
    end
end
