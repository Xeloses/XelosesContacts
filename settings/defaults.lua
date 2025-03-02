-- ---------------------------
--  @SECTION Default settings
-- ---------------------------

function XelosesContacts:getDefaultSettings()
    local L           = self.getString

    local FRIENDS_ID  = self.CONST.CONTACTS_FRIENDS_ID
    local VILLAINS_ID = self.CONST.CONTACTS_VILLAINS_ID

    local defaults    = {
        default_category = FRIENDS_ID,
        groups = {
            [FRIENDS_ID] = {
                [1] = { id = 1, name = L("GROUP_11"), icon = "/esoui/art/armory/buildicons/buildicon_49.dds" },
                [2] = { id = 2, name = L("GROUP_12"), icon = "/esoui/art/armory/buildicons/buildicon_33.dds" },
                [3] = { id = 3, name = L("GROUP_13"), icon = "/esoui/art/treeicons/gamepad/gp_collectionicon_housing.dds" },
                [4] = { id = 4, name = L("GROUP_14"), icon = "/esoui/art/armory/buildicons/buildicon_4.dds" },
                [5] = { id = 5, name = L("GROUP_15"), icon = "/esoui/art/tutorial/achievements_indexicon_summary_up.dds" },
            },
            [VILLAINS_ID] = {
                [1] = { id = 1, name = L("GROUP_21"), icon = "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds", mute = false },
                [2] = { id = 2, name = L("GROUP_22"), icon = "/esoui/art/armory/buildicons/buildicon_13.dds", mute = true },
                [3] = { id = 3, name = L("GROUP_23"), icon = "/esoui/art/contacts/tabicon_ignored_up.dds", mute = true },
                [4] = { id = 4, name = L("GROUP_24"), icon = "/esoui/art/armory/buildicons/buildicon_59.dds", mute = false },
                [5] = { id = 5, name = L("GROUP_25"), icon = "/esoui/art/armory/buildicons/buildicon_51.dds", mute = false },
            },
        },
        colors = {
            [FRIENDS_ID]  = "33e033",
            [VILLAINS_ID] = "e03333",
        },
        ui = {
            search_note = true,
        },
        chat = {
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
        contextmenu = {
            enabled = true,
            submenu = true,
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
