local EM    = GetEventManager()
local XC    = XelosesContacts
local CONST = XC.CONST
local L     = XC.getString
local T     = type

-- ---------------
--  @SECTION Init
-- ---------------

---@private
function XC:InitHooks()
    self.__hooks = {
        -- Handle zone change (teleport/move to new zone)
        ZoneChange = {
            event    = EVENT_PLAYER_ACTIVATED,
            callback = self.onZoneChange,
        },

        -- Handle attemp to add someone to ESO ingame friends to check if target is a Villain
        AddFriend = {
            fn_name  = "ZO_Dialogs_ShowDialog",
            callback = self.handleZODialogs,
            enabled  = function() return self.config.confirmation.friend end,
        },

        -- Handle incoming invite to friends to check if inviter is a Villain
        IncomingFriendInvite = {
            event    = EVENT_INCOMING_FRIEND_INVITE_ADDED,
            callback = self.handleIncomingFriendInvite,
            enabled  = function() return self.config.notifications.friendInvite.enabled end,
        },

        -- Handle incoming group invite to check if inviter is a Villain
        IncomingGroupInvite = {
            event    = EVENT_GROUP_INVITE_RECEIVED,
            callback = self.handleIncomingGroupInvite,
            enabled  = function() return self.config.notifications.groupInvite.enabled end,
        },

        -- Handle group changing (player join/leave group, group members joined/left) to check for Villains in a group
        GroupChange = {
            event    = EVENT_GROUP_MEMBER_JOINED,
            callback = self.onGroupChange,
            enabled  = function() return (self.config.notifications.groupJoin.enabled or self.config.notifications.groupMember.enabled) end,
        }
    }

    self.Game.__friends = table:new()
    self.Game.__ignored = table:new()
    self.Game.__guildmates = table:new()

    ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(...) return self:handleChatMessages(...) end)
    ZO_PreHook("StartChatInput", function(...) return self:handleStartChatInput(...) end)
    EM:RegisterForEvent(self.__namespace, EVENT_PLAYER_COMBAT_STATE, function(...) return self:onCombatStateChange(...) end)
    EM:RegisterForEvent(self.__namespace, EVENT_SOCIAL_DATA_LOADED, function() return self.Game:loadSocialData() end)
    EM:RegisterForEvent(self.__namespace, EVENT_GUILD_DATA_LOADED, function() return self.Game:loadGuildData() end)
    self:SetupHook("AddFriend")
    self:SetupHook("IncomingGroupInvite")
    self:SetupHook("GroupChange")
    self:SetupHook("IncomingFriendInvite")
end

-- -----------------------
--  @SECTION Manage hooks
-- -----------------------

---@private
function XC:SetupHook(hook)
    if (T(hook) == "string") then
        hook = self.__hooks[hook]
        if (not hook) then return end
        local hook_enabled = hook.enabled == nil or (T(hook.enabled) == "function" and hook.enabled()) or hook.enabled
        if (not hook_enabled) then return end
    end
    if (hook.injected) then return end -- prevent duplicate hooks
    local fn_callback = function(...) return hook.callback(self, ...) end
    if (hook.fn_name) then
        ZO_PreHook(hook.fn_name, fn_callback)
    elseif (hook.event) then
        EM:RegisterForEvent(self.__namespace, hook.event, fn_callback)
    end
    hook.injected = true -- flag to prevent duplicate hooks
end

---@private
function XC:UpdateHook(hook_name)
    local hook = self.__hooks[hook_name]
    if (not hook) then return end
    local hook_enabled = hook.enabled == nil or (T(hook.enabled) == "function" and hook.enabled()) or hook.enabled
    if (hook_enabled) then
        self:SetupHook(hook)
    else
        self:RemoveHook(hook)
    end
end

---@private
function XC:RemoveHook(hook)
    if (T(hook) == "string") then
        hook = self.__hooks[hook]
    end
    if (not hook) then return end
    if (not hook.injected) then return end
    if (hook.event) then
        EM:UnregisterForEvent(self.__namespace, hook.event)
        hook.injected = false
    end
end

-- ----------------
--  @SECTION ESOUI
-- ----------------

function XC:handleZODialogs(dialog, data)
    if (not dialog) then return end
    if (dialog == "REQUEST_FRIEND" and self.config.confirmation.friend) then
        if (data and data.name) then
            local contact = self:getContactData(data.name)
            if (self:isVillain(contact)) then
                local text_params = { self:getContactName(contact, true), self:getContactGroupName(contact, true, true) }
                self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_BEFRIEND_VILLAIN, text_params, data)
                return true -- disable default dialog
            end
        end
    end
end

-- ---------------
--  @SECTION Chat
-- ---------------

function XC:handleChatMessages(_, event_code, channel, from_name, raw_message_text, is_customer_service, from_display_name)
    if (not from_display_name or from_display_name == "") then return end
    if (event_code ~= EVENT_CHAT_MESSAGE_CHANNEL) then return end
    if (is_customer_service) then return end        -- do not process customer service
    local sender = IsDecoratedDisplayName(from_display_name) and ("@%s"):format(UndecorateDisplayName(from_display_name)) or from_display_name
    if (sender == self.accountName) then return end -- do not process local player
    local contact = self:getContactData(sender)
    if (contact) then
        if (self:isChatBlocked(contact)) then
            -- get chat channel type
            local channel_category
            for category_name, channels in pairs(CONST.CHAT.CHANNELS) do
                local channels_list = table:new(channels)
                if (channels_list:has(channel)) then
                    channel_category = category_name
                    break
                end
            end
            -- check chat channel blocking rules
            if (channel_category and self.config.chat.block_channels[channel_category]) then
                -- @LOG blocked message
                self:Log("[Chat::%s] Block message from %s [%s]: %s", channel_category, self:getContactGroupName(contact), contact.account, GetString(SI_CHAT_MESSAGE_FORMATTER):zo_format(raw_message_text))
                return true -- flag indicates message should be blocked
            end
        end
    end
end

function XC:handleStartChatInput(text, channel, target)
    if (target and target ~= "") then
        local contact = self:getContactData(target)
        if (contact and self:isChatBlocked(contact)) then
            self:Warn(L("CHAT_WHISPER_BLOCKED"), contact)
            return true -- block chat input
        end
    end
end

-- ---------------
--  @SECTION Zone
-- ---------------

function XC:onZoneChange()
    self.zoneID = GetZoneId(GetUnitZoneIndex("player"))
    self.zoneName = GetUnitZone("player")
end

-- -----------------
--  @SECTION Combat
-- -----------------

function XC:onCombatStateChange(_, in_combat)
    self.inCombat = in_combat
end

-- ----------------
--  @SECTION Group
-- ----------------

function XC:handleIncomingGroupInvite(_, inviter_char_name, inviter_display_name)
    if (not self.config.notifications.groupInvite.enabled) then return end
    if (inviter_display_name and self:isVillain(inviter_display_name)) then
        local contact = self:getContactData(inviter_display_name)
        local x = self.config.notifications.groupInvite.decline
        local s = L("GROUP_INVITE_FROM_VILLAIN") .. (x and (" (%s)"):format(L("DECLINED")) or "")
        if (x) then DeclineGroupInvite() end
        self:Warn(s, contact)
        if (not x and self.config.notifications.groupInvite.announce) then
            self:Announce(s, { title = L("WARNING"), textParams = contact, icon = self:getContactGroupIcon(contact) })
        end
    end
end

function XC:onGroupChange(_, character_name, display_name, is_local_player)
    local villain_name
    if (is_local_player) then
        -- Player joined of left group
        if (not self.config.notifications.groupJoin.enabled) then return end
        if (IsUnitGrouped("player")) then
            -- Player joined new group
            for i = 1, GetGroupSize() do
                local unitTag = GetGroupUnitTagByIndex(i)
                if (unitTag and not AreUnitsEqual(unitTag, "player")) then
                    local account_name = GetUnitDisplayName(unitTag)
                    if (account_name and self:isVillain(account_name)) then
                        villain_name = account_name
                        break
                    end
                end
            end
        end
    else
        -- someone joined player's group
        if (not self.config.notifications.groupMember.enabled) then return end
        if (self:isVillain(display_name)) then
            villain_name = display_name
        end
    end
    if (villain_name) then
        local contact = self:getContactData(villain_name)
        local s = L(is_local_player and "GROUP_WITH_VILLAIN" or "GROUP_JOINED_VILLAIN")
        self:Warn(s, contact)

        if (is_local_player and self.config.notifications.groupJoin.announce or self.config.notifications.groupMember.announce) then
            self:Announce(s, { title = L("WARNING"), textParams = contact, icon = self:getContactGroupIcon(contact) })
        end
    end
end

-- -----------------
--  @SECTION Social
-- -----------------

function XC:handleIncomingFriendInvite(_, inviter_name)
    if (not self.config.notifications.friendInvite.enabled) then return end
    if (self:isVillain(inviter_name)) then
        local contact = self:getContactData(inviter_name)
        local x = self.config.notifications.friendInvite.decline
        local s = L("FRIEND_INVITE_FROM_VILLAIN") .. (x and (" (%s)"):format(L("DECLINED")) or "")
        if (x) then RejectFriendRequest(inviter_name) end
        self:Warn(s, contact)
        if (not x and self.config.notifications.friendInvite.announce) then
            self:Announce(s, { title = L("WARNING"), textParams = contact, icon = self:getContactGroupIcon(contact) })
        end
    end
end
