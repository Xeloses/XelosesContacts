local XC = XelosesContacts
local L  = XC.getString
local F  = XC.formatString

-- -------------------------
--  @SECTION Chat utulities
-- -------------------------

function XC:Print(msg, ...)
    if (not self.loaded or not msg or msg == "") then return end

    local s = F(msg, ...)

    if (self.Chat.lib) then
        self.Chat.lib:SetTagColor(self.colors.tag):Print(s)
    else
        CHAT_SYSTEM:AddMessage(self:addPrefix(s))
    end
end

function XC:PrintInfo(msg, ...)
    self:Print(msg, ...)
end

function XC:PrintWarning(msg, ...)
    local s = L("WARNING"):colorize(XC.colors.warning) .. " " .. msg
    XC:Print(s, ...)
end

function XC:PrintError(msg, ...)
    local s = L("ERROR"):colorize(XC.colors.error) .. ": " .. msg
    XC:Print(s, ...)
end

-- -------------------------

function XC.Chat:Whisper(target_name)
    if (target_name) then
        StartChatInput("", CHAT_CHANNEL_WHISPER, target_name)
    end
end
