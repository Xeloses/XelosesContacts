local EM     = GetEventManager()
local XC     = XelosesContacts
local XCGame = XC.Game
local CONST  = XC.CONST
local T      = type

-- ------------------
--  @SECTION Players
-- ------------------

---@private
function XCGame:getUnitInfo(unit_tag)
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
--  @SECTION Zones
-- ----------------

function XCGame:isGroupDungeon(zone_id)
    return zone_id and (CONST.ZONES.DUNGEON:has(zone_id) or CONST.ZONES.ARENA.GROUP:has(zone_id))
end

function XCGame:isInGroupDungeon()
    return self:isGroupDungeon(XC.zoneID)
end

function XCGame:isTrial(zone_id)
    return zone_id and CONST.ZONES.TRIAL:has(zone_id)
end

function XCGame:isInTrial()
    return self:isTrial(XC.zoneID)
end

function XCGame:isPvPZone(zone_id)
    return zone_id and CONST.ZONES.PVP:has(zone_id)
end

function XCGame:isInPvPZone()
    return self:isPvPZone(XC.zoneID)
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
    if (not self.__guildmates) then self:loadGuildData() end
    return self.__guildmates:hasKey(target_name)
end

---@private
function XCGame:getGuildName(target_name)
    if (not self.__guilds) then self:loadGuildData() end

    local guild_index = self.__guildmates:get(target_name)
    if (not guild_index) then return end

    local guild = self.__guilds:get(guild_index)
    if (not guild) then return end

    return guild.name
end

-- ------------------
--  @SECTION Friends
-- ------------------

---@private
function XCGame:isFriend(target_name)
    if (not self.__friends) then self:loadSocialData() end
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
    if (not self.__ignored) then self:loadSocialData() end
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

local __social_events = { friends = false, ignored = false, guild = false }

function XCGame:loadSocialData(reset_data)
    XC:RemoveHook("SocialDataLoad")

    if ((self.__friends ~= nil and self.__ignored ~= nil) and not reset_data) then return end

    local num_friends = GetNumFriends()
    if (not reset_data and self.__friends and self.__friends:len() == num_friends) then return end

    local num_ignored = GetNumIgnored()
    if (not reset_data and self.__ignored and self.__ignored:len() == num_ignored) then return end

    self:resetSocialData()

    -- Friends list
    for i = 1, num_friends do
        local name, _, _, _ = GetFriendInfo(i)
        self.__friends:insert(name)
    end

    if (not __social_events.friends) then
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

        __social_events.friends = true
    end

    -- Ignored players list
    for i = 1, num_ignored do
        local name, _, _, _ = GetIgnoredInfo(i)
        self.__ignored:insert(name)
    end

    if (not __social_events.ignored) then
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

        __social_events.ignored = true
    end
end

function XCGame:loadGuildData(reset_data)
    XC:RemoveHook("GuildDataLoad")

    if ((self.__guildmates ~= nil and self.__guilds ~= nil) and not reset_data) then return end

    self:resetGuildData()

    for i = 1, GetNumGuilds() do
        local gID = GetGuildId(i)

        self.__guilds:insertElem(i, { id = gID, name = GetGuildName(gID) })

        for j = 1, GetNumGuildMembers(gID) do
            local name, _, _, _ = GetGuildMemberInfo(gID, j)
            if (not self.__guildmates:hasKey(name)) then
                self.__guildmates:insertElem(name, i)
            end
        end
    end

    if (not __social_events.guild) then
        EM:RegisterForEvent(
            self.__namespace,
            EVENT_GUILD_MEMBER_ADDED,
            function(_, guild_id, display_name)
                if (not self.__guildmates:hasKey(display_name)) then
                    if (not self.__guilds or not self.__guildmates) then self:loadGuildData() end

                    if (self.__guildmates:hasKey(display_name)) then return end

                    local n
                    for i = 1, self.__guilds:len() do
                        if (self.__guilds[i].id == guild_id) then
                            n = i
                            break
                        end
                    end

                    if (n) then
                        self.__guildmates:insertElem(display_name, n)
                    end
                end
            end
        )

        EM:RegisterForEvent(
            self.__namespace,
            EVENT_GUILD_MEMBER_REMOVED,
            function() self:loadGuildData(true) end
        )

        __social_events.guild = true
    end
end

function XCGame:resetSocialData()
    self.__friends = table:new()
    self.__ignored = table:new()
end

function XCGame:resetGuildData()
    self.__guilds = table:new()
    self.__guildmates = table:new()
end
