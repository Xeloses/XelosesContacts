-- ---------------------------
--  @SECTION Default settings
-- ---------------------------

function XelosesContacts:getDefaultSettings()
    local L = self.getString

    local defaults = {
        groups = {
            [self.CONST.CONTACTS_FRIENDS_ID] = {
                [1] = L("GROUP_11"),
                [2] = L("GROUP_12"),
                [3] = L("GROUP_13"),
                [4] = L("GROUP_14"),
                [5] = L("GROUP_15"),
            },
            [self.CONST.CONTACTS_VILLAINS_ID] = {
                [1] = L("GROUP_21"),
                [2] = L("GROUP_22"),
                [3] = L("GROUP_23"),
                [4] = L("GROUP_24"),
                [5] = L("GROUP_25"),
            },
        },
        colors = {
            [self.CONST.CONTACTS_FRIENDS_ID] = "33e033",
            [self.CONST.CONTACTS_VILLAINS_ID] = "e03333",
        },
        ui = {
            search_note = true,
        },
        chat = {
            block_groups = {
                [1] = false,
                [2] = true,
                [3] = true,
                [4] = false,
                [5] = false,
            },
            block_channels = {
                SAY     = true,
                ZONE    = true,
                GROUP   = false,
                GUILD   = false,
                WHISPER = true,
            },
            cache = {
                enabled = true,
                maxsize = 100,
            },
            log = true,
        },
        notifications = {
            -- notifications channel: 1 - Chat and Screen; 2 - Chat; 3 - Screen
            channel = 1,
            -- notify when join group with villain
            groupJoin = {
                enabled  = true,
                announce = false,
            },
            -- notify when villain joined group
            groupMember = {
                enabled  = true,
                announce = false,
            },
            -- notify when got a group invite from villain
            groupInvite = {
                enabled  = true,
                announce = false,
                decline  = false,
            },
            -- notify when got a friend request from villain
            friendInvite = {
                enabled  = true,
                announce = false,
                decline  = false,
            },
        },
        confirmation = {
            -- add villain to ESO ingame friends
            friend = true,
        },
        reticle = {
            enabled  = true,
            disable  = {
                combat        = false,
                group_dungeon = false,
                trial         = true,
                pvp           = true,
            },
            position = self.CONST.UI.RETICLE_MARKER.POSITION.BELOW,
            offset   = 5,
            icon     = {
                enabled = true,
                size    = 48,
            },
            font     = {
                size = 22,
                style = "outline",
            },
            markers  = {
                friend    = { enabled = true, color = "FFFF33" },
                ignored   = { enabled = true, color = "DD1188" },
                guildmate = { enabled = true, color = "1188FF" },
            }
        },
    }

    return defaults
end
