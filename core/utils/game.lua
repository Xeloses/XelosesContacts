local EM     = GetEventManager()
local XC     = XelosesContacts
local XCGame = XC.Game

-- ------------------
--  @SECTION Players
-- ------------------

---@private
function XCGame.getUnitInfo(unit_tag)
    if (not unit_tag or unit_tag == "" or unit_tag:lower() == "player") then return end

    return {
        displayName      = GetUnitDisplayName(unit_tag),
        characterName    = GetUnitName(unit_tag),
        rawCharacterName = GetRawUnitName(unit_tag),
        classId          = GetUnitClassId(unit_tag),
        alliance         = GetUnitAlliance(unit_tag),
        level            = GetUnitLevel(unit_tag),
        cp               = GetUnitEffectiveChampionPoints(unit_tag),
        rank             = GetUnitAvARank(unit_tag),
        online           = IsUnitOnline(unit_tag),
        zone             = ZO_CachedStrFormat(SI_ZONE_NAME, GetUnitZone(unit_tag)),
        secondaryName    = ZO_GetSecondaryPlayerNameWithTitleFromUnitTag(unit_tag),
    }
end

-- ----------------
--  @SECTION Group
-- ----------------

---@private
-- returns TRUE if player is in the same group with target
function XCGame:isGroupMember(target_name)
    if (not IsUnitGrouped("player")) then return false end
    for i = 1, GROUP_SIZE_MAX do
        local unit         = "group" .. i
        local display_name = GetUnitDisplayName(unit)
        if (display_name and target_name == display_name) then
            return true
        end
    end
    return false
end

-- ---------

function XCGame:GroupInvite(target_name)
    local SENT_FROM_CHAT = false
    local DISPLAY_INVITED_MESSAGE = true
    TryGroupInviteByName(target_name, SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE)
end

function XCGame:GroupKick(target_name)
    if (DoesGroupModificationRequireVote()) then
        BeginGroupElection(GROUP_ELECTION_TYPE_KICK_MEMBER, ZO_GROUP_ELECTION_DESCRIPTORS.NONE, target_name)
    elseif (IsUnitGroupLeader("player")) then
        GroupKickByName(target_name)
    end
end

function XCGame:LeaveGroup()
    if (IsUnitGrouped("player")) then
        ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
    end
end

function XCGame:DisbandGroup()
    if (IsGroupModificationAvailable() and IsUnitGroupLeader("player")) then
        ZO_Dialogs_ShowDialog("GROUP_DISBAND_DIALOG")
    end
end

-- ----------------
--  @SECTION Guild
-- ----------------

---@private
function XCGame:isGuildmate(target_name)
    if (not self.__guildmates:len()) then self:loadGuildData() end
    return self.__guildmates:has(target_name)
end

-- ------------------
--  @SECTION Friends
-- ------------------

---@private
function XCGame:isFriend(target_name)
    if (not self.__friends:len()) then self:loadSocialData() end
    return self.__friends:has(target_name)
end

function XCGame:addFriend(target_name, skip_dialog)
    if (not self:isFriend(target_name)) then
        if (skip_dialog) then
            RequestFriend(target_name, "")
        else
            ZO_Dialogs_ShowDialog("REQUEST_FRIEND", { name = target_name })
        end
    end
end

function XCGame:removeFriend(target_name)
    if (not self:isFriend(target_name)) then return end
    ZO_Dialogs_ShowDialog("CONFIRM_REMOVE_FRIEND", { displayName = target_name }, { mainTextParams = { target_name } })
end

-- ------------------
--  @SECTION Ignored
-- ------------------

---@private
function XCGame:isIgnored(target_name)
    if (not self.__ignored:len()) then self:loadSocialData() end
    return self.__ignored:has(target_name)
end

function XCGame:addIgnore(target_name)
    if (self:isIgnored(target_name)) then return end
    ZO_PlatformIgnorePlayer(target_name)
end

function XCGame:removeIgnore(target_name)
    if (not self:isIgnored(target_name)) then return end
    RemoveIgnore(target_name)
end

-- ------------------
--  @SECTION Service
-- ------------------

function XCGame:TeleportTo(target_name)
    if (IsUnitDead("player")) then return end -- unable to teleport while dead

    local name = XC:validateAccountName(target_name)

    if IsMounted() then
        -- retry teleport after 1.5 sec delay (first teleport attempt will just dismount player, so we need to do teleport again)
        zo_callLater(function() self:TeleportTo(name) end, 2000)
    end
    CancelCast()

    -- select teleportation method
    if (self:isFriend(name)) then
        JumpToFriend(name)
    elseif (self:isGuildmate(name)) then
        JumpToGuildMember(name)
    elseif (IsUnitGrouped("player")) then
        if (name == GetUnitDisplayName(GetGroupLeaderUnitTag())) then
            JumpToGroupLeader()
        elseif (self:isGroupMember(name)) then
            JumpToGroupMember(name)
        end
    end
end

function XCGame:VisitHouse(target_name)
    if (IsUnitDead("player")) then return end -- can't teleport while dead
    JumpToHouse(target_name)
end

function XCGame:SendMail(target_name)
    if (IsUnitDead("player")) then return end -- game does not allow to send mail while dead
    MAIL_SEND:ComposeMailTo(target_name)
end

function XCGame:ReportPlayer(target_name)
    ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(target_name)
end

-- --------------------
--  @SECTION Load data
-- --------------------

function XCGame:loadSocialData()
    EM:UnregisterForEvent(self.__namespace, EVENT_SOCIAL_DATA_LOADED)

    -- Friends list
    zo_callLater(
        function()
            for i = 1, GetNumFriends() do
                local name, _, _, _ = GetFriendInfo(i)
                self.__friends:insert(name)
            end
        end,
        100
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_FRIEND_ADDED,
        function(_, display_name)
            self.__friends:insert(display_name)
        end
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_FRIEND_REMOVED,
        function(_, display_name)
            self.__friends:removeElem(display_name)
        end
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_FRIEND_DISPLAY_NAME_CHANGED,
        function(_, old_display_name, new_display_name)
            local x = #self.__friends
            for i = 1, x do
                if (self.__friends[i] == old_display_name) then
                    self.__friends[i] = new_display_name
                    break
                end
            end
        end
    )

    -- Ignore list
    zo_callLater(
        function()
            for i = 1, GetNumIgnored() do
                local name, _, _, _ = GetIgnoredInfo(i)
                self.__ignored:insert(name)
            end
        end,
        200
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_IGNORE_ADDED,
        function(_, display_name)
            self.__ignored:insert(display_name)
        end
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_IGNORE_REMOVED,
        function(_, display_name)
            self.__ignored:removeElem(display_name)
        end
    )
end

function XCGame:loadGuildData()
    EM:UnregisterForEvent(self.__namespace, EVENT_GUILD_DATA_LOADED)

    -- Guilds
    zo_callLater(
        function()
            for i = 1, GetNumGuilds() do
                local gID = GetGuildId(i)
                for j = 1, GetNumGuildMembers(gID) do
                    local name, _, _, _ = GetGuildMemberInfo(gID, j)
                    if (not self.__guildmates:has(name)) then
                        self.__guildmates:insert(name)
                    end
                end
            end
        end,
        100
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_GUILD_MEMBER_ADDED,
        function(_, guild_id, display_name)
            if (not self.__guildmates:hasKey(display_name)) then
                self.__guildmates:insert(display_name)
            end
        end
    )

    EM:RegisterForEvent(
        self.__namespace,
        EVENT_GUILD_MEMBER_REMOVED,
        function(_, guild_id, display_name, character_name)
            self.__guildmates:removeElem(display_name)
        end
    )
end
