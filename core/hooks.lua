local EM = GetEventManager()
local L  = XelosesContacts.getString
local T  = type

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContacts:InitHooks()
    self.__hooks = {
        -- Handle zone change (teleport/move to new zone)
        ZoneChange = {
            event    = EVENT_PLAYER_ACTIVATED,
            callback = self.onZoneChange,
        },

        -- Handle combat state change
        CombatState = {
            event    = EVENT_PLAYER_COMBAT_STATE,
            callback = self.onCombatStateChange,
        },

        -- Handle attempt to start chat input
        ChatInput = {
            fn_name  = "StartChatInput",
            callback = self.handleStartChatInput,
        },

        -- Handle click on link
        LinkClicked = {
            fn_name  = "ZO_LinkHandler_OnLinkClicked",
            callback = self.handleLinkClicked,
        },
        LinkMouseUp = {
            fn_name  = "ZO_LinkHandler_OnLinkMouseUp",
            callback = self.handleLinkClicked,
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

        -- Handle group change (player join/leave group, group members joined/left) to check for Villains in a group
        GroupChange = {
            event    = EVENT_GROUP_MEMBER_JOINED,
            callback = self.onGroupChange,
            enabled  = function() return (self.config.notifications.groupJoin.enabled or self.config.notifications.groupMember.enabled) end,
        },

        -- Handle reticle target change
        ReticleTarget = {
            event    = EVENT_RETICLE_TARGET_CHANGED,
            callback = self.handleReticleTarget,
            enabled  = function() return self.config.reticle.enabled end,
        },

        -- Handle reticle target visibility change
        ReticleTargetVisibility = {
            event    = EVENT_RETICLE_HIDDEN_UPDATE,
            callback = self.handleReticleHiddenState,
        },

        -- Handle social/guilds data load
        SocialDataLoad = {
            event    = EVENT_SOCIAL_DATA_LOADED,
            callback = function(...) return self.Game:loadSocialData() end,
        },
        GuildDataLoad = {
            event    = EVENT_GUILD_DATA_LOADED,
            callback = function(...) return self.Game:loadGuildData() end,
        },

        -- Player join/left guild
        GuildJoin = {
            event    = EVENT_GUILD_SELF_JOINED_GUILD,
            callback = function(...) return self.Game:loadGuildData(true) end,
        },
        GuildLeave = {
            event    = EVENT_GUILD_SELF_LEFT_GUILD,
            callback = function(...) return self.Game:loadGuildData(true) end,
        },

        -- Friend' account ID changed
        FriendRenamed = {
            event    = EVENT_FRIEND_DISPLAY_NAME_CHANGED,
            callback = self.handleFriendRenamed,
        },
    }

    for hook_name, hook in pairs(self.__hooks) do
        if (not hook.injected) then
            self:SetupHook(hook_name)
        end
    end

    ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(...) return self:handleChatMessage(...) end)
end

-- -----------------------
--  @SECTION Manage hooks
-- -----------------------

function XelosesContacts:isHookEnabled(hook_name)
    local hook = self.__hooks[hook_name]
    if (not hook) then return false end

    return
        (hook.enabled == nil) or
        (T(hook.enabled) == "function" and hook.enabled()) or
        hook.enabled
end

function XelosesContacts:SetupHook(hook_name)
    local hook = self.__hooks[hook_name]
    if (not hook or hook.injected) then return end
    if (not self:isHookEnabled(hook_name)) then return end

    if (not hook.namespace) then
        hook.namespace = self.__namespace .. "_" .. hook_name -- generate unique namespace for hook
    end

    local fn_callback = function(...) return hook.callback(self, ...) end

    if (hook.fn_name) then
        -- function hook
        ZO_PreHook(hook.fn_name, fn_callback)
    elseif (hook.event) then
        -- event handler
        EM:RegisterForEvent(hook.namespace, hook.event, fn_callback)

        if (hook.filter and T(hook.filter) == "table") then
            for filter_key, filter_value in pairs(hook.filter) do
                EM:AddFilterForEvent(hook.namespace, hook.event, filter_key, filter_value)
            end
        end
    elseif (hook.interval) then
        -- timer
        EM:RegisterForUpdate(hook.namespace, hook.interval, hook.callback)
    end

    hook.injected = true -- flag to prevent duplicate hooks
end

function XelosesContacts:RemoveHook(hook_name)
    local hook = self.__hooks[hook_name]
    if (not hook or not hook.injected) then return end

    if (hook.event) then
        EM:UnregisterForEvent(hook.namespace, hook.event)
    elseif (hook.interval) then
        EM:UnregisterForUpdate(hook.namespace)
    end

    hook.injected = false
end

function XelosesContacts:ToggleHook(hook_name)
    if (self:isHookEnabled(hook_name)) then
        self:SetupHook(hook_name)
    else
        self:RemoveHook(hook_name)
    end
end

-- ----------------
--  @SECTION ESOUI
-- ----------------

function XelosesContacts:handleZODialogs(dialog, data)
    if (not dialog) then return end
    if (dialog == "REQUEST_FRIEND" and self.config.confirmation.friend) then
        if (data and data.name) then
            local contact = self:getContactData(data.name)
            if (self:isVillain(contact)) then
                local text_params = { self:getContactName(contact, true), self:getContactGroupName(contact, true, true) }
                self:ShowDialog(self.CONST.UI.DIALOGS.CONFIRM_BEFRIEND_VILLAIN, text_params, data)
                return true -- disable default dialog
            end
        end
    end
end

-- ---------------
--  @SECTION Chat
-- ---------------

function XelosesContacts:handleChatMessage(_, event_code, channel, from_name, raw_message_text, is_customer_service, from_display_name)
    local skip =
        is_customer_service or -- do not process customer service
        event_code ~= EVENT_CHAT_MESSAGE_CHANNEL or
        not from_display_name or not IsDecoratedDisplayName(from_display_name) or
        from_display_name == self.accountName -- do not process self
    if (skip) then return end

    local contact = self:getContactData(from_display_name)
    if (contact and self:isChatBlocked(contact) and self.Game:isChatChannelBlocked(channel)) then
        -- @LOG blocked message
        self:Log("[Chat::%s] Block message from %s [%s]: %s", self.Game:getChatChannelCategory(channel), self:getContactGroupName(contact), contact.account, zo_strformat(GetString(SI_CHAT_MESSAGE_FORMATTER), raw_message_text))

        return true -- flag indicates message should be blocked
    end
end

function XelosesContacts:handleStartChatInput(text, channel, target)
    if (not target or target == "") then
        channel, target = CHAT_ROUTER:GetCurrentChannelData()
        if (not channel.target --[[ or channel.id ~= CHAT_CHANNEL_WHISPER ]]) then return end
    end

    local contact = self:getContactData(target)
    if (contact and self:isChatBlocked(contact)) then
        self:Warn(L("CHAT_WHISPER_BLOCKED"), contact)
        return true -- flag indicates chat input should be blocked
    end
end

function XelosesContacts:handleLinkClicked(link, button)
    if (button ~= MOUSE_BUTTON_INDEX_LEFT) then return end

    local _, _, link_type, link_data = ZO_LinkHandler_ParseLink(link)
    if (link_type ~= DISPLAY_NAME_LINK_TYPE) then return end

    local contact = self:getContactData("@" .. link_data)
    if (contact and self:isChatBlocked(contact)) then
        self:Warn(L("CHAT_WHISPER_BLOCKED"), contact)
        return true -- flag indicates ... should be blocked
    end
end

-- ---------------
--  @SECTION Zone
-- ---------------

function XelosesContacts:onZoneChange()
    local zoneID  = GetZoneId(GetUnitZoneIndex("player"))

    self.zoneID   = zoneID
    self.zoneName = GetUnitZone("player")
    self.zoneInfo = self.Game:GetZoneInfo(zoneID)
end

-- -----------------
--  @SECTION Combat
-- -----------------

function XelosesContacts:onCombatStateChange(_, in_combat)
    self.inCombat = in_combat
end

-- -------------------------
--  @SECTION Reticle Target
-- -------------------------

function XelosesContacts:handleReticleTarget()
    if (not self.config.reticle.enabled) then return end

    self.UI.ReticleMarker:Reset()

    if (self.inCombat and self.config.reticle.disable.combat) then return end

    if (self.zoneInfo.solo_dungeon or self.zoneInfo.ia) then return end -- do not track targets in solo arenas and Infinite archive

    local isSolo = not self.inGroup                                     -- do not track targets in group dungeons and trials when not in group
    if (self.zoneInfo.group_dungeon and (isSolo or self.config.reticle.disable.group_dungeon)) then return end
    if (self.zoneInfo.trial and (isSolo or self.config.reticle.disable.trial)) then return end

    if (self.zoneInfo.pvp and self.config.reticle.disable.pvp) then return end

    if (not DoesUnitExist("reticleover")) then return end
    if (not IsUnitPlayer('reticleover')) then return end

    local target_name = GetUnitDisplayName("reticleover")
    if (not IsDecoratedDisplayName(target_name)) then return end

    local contact     = XelosesContacts:getContactData(target_name)
    local isGuildmate = self.config.reticle.markers.guildmate.enabled and self.Game:isGuildmate(target_name)
    local isFriend    = self.config.reticle.markers.friend.enabled and self.Game:isFriend(target_name)
    local isIgnored   = self.config.reticle.markers.ignored.enabled and self.Game:isIgnored(target_name)

    if (not contact and not isGuildmate and not isFriend and not isIgnored) then return end

    local markers_config = self.config.reticle.markers

    local icon, color
    local info = table:new()

    if (contact) then
        icon  = XelosesContacts:getGroupIcon(contact.category, contact.group)
        color = XelosesContacts:getCategoryColor(contact.category)
        info:insert(XelosesContacts:getContactGroupName(contact, true, true))
    end

    if (isIgnored) then
        icon = icon or self.CONST.ICONS.SOCIAL.IGNORED
        color = color or markers_config.ignored.color
        info:insert(L("ESO_IGNORED"):colorize(markers_config.ignored.color))
    elseif (isFriend) then
        icon = icon or self.CONST.ICONS.SOCIAL.FRIEND
        color = color or markers_config.friend.color
        info:insert(L("ESO_FRIEND"):colorize(markers_config.friend.color))
    end

    if (isGuildmate) then
        icon = icon or self.CONST.ICONS.SOCIAL.GUILDMATE
        color = color or markers_config.guildmate.color
        local g_name = self.Game:getGuildName(target_name)
        info:insert(L("ESO_GUILDMATE"):zo_format(g_name):colorize(markers_config.guildmate.color))
    end

    self.UI.ReticleMarker:Show(info:concat(", "), icon, color and color)
end

function XelosesContacts:handleReticleHiddenState()
    self.UI.ReticleMarker:Hide()
end

-- ----------------
--  @SECTION Group
-- ----------------

function XelosesContacts:handleIncomingGroupInvite(_, inviter_char_name, inviter_display_name)
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

function XelosesContacts:onGroupChange(_, character_name, display_name, is_local_player)
    local villain_name

    if (is_local_player) then
        -- Player joined of left group
        self.inGroup = IsUnitGrouped("player")

        if (not self.config.notifications.groupJoin.enabled) then return end

        if (self.inGroup) then
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

function XelosesContacts:handleIncomingFriendInvite(_, inviter_name)
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

function XelosesContacts:handleFriendRenamed(_, old_display_name, new_display_name)
    if XelosesContacts:isInContacts(old_display_name) then
        XelosesContacts:RenameContact(old_display_name, new_display_name)
    end

    if (self.Game.__friends) then
        local x = self.Game.__friends:len()
        for i = 1, x do
            if (self.Game.__friends[i] == old_display_name) then
                self.Game.__friends[i] = new_display_name
                break
            end
        end
    end
end
