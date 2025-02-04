local FRIENDS_ID   = 1
local VILLAINS_ID  = 2
local ADDON_PREFIX = "XELCONTACTS_"
local T            = type

local function L(str)
    if (T(str) == "string") then
        local s = ADDON_PREFIX .. str
        return _G[s] and GetString(_G[s]) or str
    elseif (T(str) == "number") then
        return GetString(str)
    else
        return "<[MISSING_STRING]>"
    end
end

-- =========================
-- === Addon declaration ===
-- =========================

XelosesContacts = XelosesContacts or {
    __namespace    = "XelosesContacts",
    __prefix       = ADDON_PREFIX,
    getString      = L,

    name           = "Xeloses' Contacts",
    displayName    = "|cee55eeXeloses|r' Contacts",
    authorID       = "@Savaoth",
    author         = "|cee55eeXeloses|r (|c7799ee@Savaoth|r [PC/EU])",
    tag            = "Contacts",
    url            = "https://www.esoui.com/downloads/info4025-XelosesContacts.html",
    url_dev        = "https://github.com/Xeloses/XelosesContacts/",
    svVersion      = 1, -- Saved Variables version

    initialised    = false,
    loaded         = false,
    processing     = false,
    inCombat       = false,
    accountID      = 0,
    characterID    = 0,
    zoneID         = 0,

    slashCmd       = "/contacts",
    slashCmdParams = {
        ["NEW_CONTACT"] = {
            cmd     = "new",
            tooltip = L("SLASHCMD_NEW_CONTACT_TOOLTIP"),
        },
        ["ADD_CONTACT"] = {
            cmd     = "add",
            tooltip = L("SLASHCMD_ADD_CONTACT_TOOLTIP"),
        },
        ["OPEN_SETTINGS"] = {
            cmd     = "config",
            tooltip = L("SLASHCMD_OPEN_SETTINGS_TOOLTIP"),
        },
    },
    colors         = {
        tag       = "ee55ee", -- color of addon tag in chat
        info      = "66ffff", -- color of info messages in chat
        warning   = "ffaa33", -- color of warning messages in chat
        error     = "ff3333", -- color of error messages in chat
        chat_link = "eeeeee", -- color of chat links
        default   = "dddddd",
    },
    icons          = {
        ui = {
            main = "/esoui/art/contacts/tabicon_friends_",
        },
        notification = {
            default = "/esoui/art/contacts/tabicon_friends_up.dds",
        },
    },
    sound          = {
        notification = {
            default = SOUNDS.DUEL_START,
        },
    },
    UI             = {},
    Chat           = {},
    Game           = {},
    Integrations   = {},
    config         = {},
    contacts       = table:new(),

    -- ---------------------------
    --  @SECTION Default settings
    -- ---------------------------
    defaults       = {
        groups = {
            [FRIENDS_ID] = {
                [1] = L("GROUP_11"),
                [2] = L("GROUP_12"),
                [3] = L("GROUP_13"),
                [4] = L("GROUP_14"),
                [5] = L("GROUP_15"),
            },
            [VILLAINS_ID] = {
                [1] = L("GROUP_21"),
                [2] = L("GROUP_22"),
                [3] = L("GROUP_23"),
                [4] = L("GROUP_24"),
                [5] = L("GROUP_25"),
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
            block_groups = {
                [1] = false,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
            },
            block_channels = {
                SAY     = true,
                ZONE    = true,
                GROUP   = true,
                GUILD   = true,
                WHISPER = true,
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
                combat = false,
                trial  = true,
                pvp    = true,
            },
            position = 2, -- @REF XelosesContacts.CONST.UI.RETICLE_MARKER.POSITION
            offset   = 5,
            icon     = {
                enabled = true,
                size    = 48,
            },
            font     = {
                size = 22,
                style = "soft-shadow-thin",
            },
            markers  = {
                friend    = { enabled = true, color = "FFFF33" },
                ignored   = { enabled = true, color = "DD1188" },
                guildmate = { enabled = true, color = "1188FF" },
            }
        },
    },

    -- --------------------
    --  @SECTION Constants
    -- --------------------
    CONST          = {
        CONTACTS_FRIENDS_ID     = FRIENDS_ID,
        CONTACTS_VILLAINS_ID    = VILLAINS_ID,
        CONTACTS_CATEGORIES     = {
            [FRIENDS_ID]  = L("FRIENDS"),
            [VILLAINS_ID] = L("VILLAINS"),
        },
        ACCOUNT_NAME_MIN_LENGTH = 3,
        ACCOUNT_NAME_MAX_LENGTH = 20,
        GROUP_NAME_MAX_LENGTH   = 20,
        CONTACT_NOTE_MAX_LENGTH = 500,
        NOTIFICATION_CHANNELS   = {
            BOTH = 1,
            CHAT = 2,
            SCREEN = 3,
        },
        FONT_STYLE              = {
            "normal",
            "outline",
            "thick-outline",
            "shadow",
            "soft-shadow-thick",
            "soft-shadow-thin"
        },
        UI                      = {
            TAB_NAME = "Contacts",
            RETICLE_MARKER = {
                MIN_OFFSET = 0,
                MAX_OFFSET = 50,
                POSITION = {
                    ABOVE = 1,
                    BELOW = 2,
                },
                ICON_SIZE = {
                    SMALL  = 32,
                    MEDIUM = 48,
                    BIG    = 64,
                },
            },
        },
        CHAT                    = {
            CHANNELS = {
                SAY     = {
                    CHAT_CHANNEL_SAY,
                    CHAT_CHANNEL_YELL,
                    CHAT_CHANNEL_EMOTE,
                },
                ZONE    = {
                    CHAT_CHANNEL_ZONE,
                    CHAT_CHANNEL_ZONE_LANGUAGE_1, -- EN
                    CHAT_CHANNEL_ZONE_LANGUAGE_2, -- FR
                    CHAT_CHANNEL_ZONE_LANGUAGE_3, -- DE
                    CHAT_CHANNEL_ZONE_LANGUAGE_4, -- JP
                    CHAT_CHANNEL_ZONE_LANGUAGE_5, -- RU
                    CHAT_CHANNEL_ZONE_LANGUAGE_6, -- ES
                    CHAT_CHANNEL_ZONE_LANGUAGE_7, -- ZH (Chinese)
                },
                GROUP   = {
                    CHAT_CHANNEL_PARTY
                },
                GUILD   = {
                    CHAT_CHANNEL_GUILD_1,
                    CHAT_CHANNEL_GUILD_2,
                    CHAT_CHANNEL_GUILD_3,
                    CHAT_CHANNEL_GUILD_4,
                    CHAT_CHANNEL_GUILD_5,
                    CHAT_CHANNEL_OFFICER_1,
                    CHAT_CHANNEL_OFFICER_2,
                    CHAT_CHANNEL_OFFICER_3,
                    CHAT_CHANNEL_OFFICER_4,
                    CHAT_CHANNEL_OFFICER_5,
                },
                WHISPER = {
                    CHAT_CHANNEL_WHISPER,
                    --CHAT_CHANNEL_WHISPER_SENT,
                },
            },
        },
    },

    -- ---------------------------
    --  @SECTION Icons & Textures
    -- ---------------------------
    ICONS          = {
        GROUPS = {
            [FRIENDS_ID] = {
                [1] = "/esoui/art/armory/buildicons/buildicon_49.dds",
                [2] = "/esoui/art/armory/buildicons/buildicon_33.dds",
                [3] = "/esoui/art/treeicons/gamepad/gp_collectionicon_housing.dds",
                [4] = "/esoui/art/armory/buildicons/buildicon_4.dds",
                [5] = "/esoui/art/tutorial/achievements_indexicon_summary_up.dds",
            },
            [VILLAINS_ID] = {
                [1] = "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds",
                [2] = "/esoui/art/armory/buildicons/buildicon_13.dds",
                [3] = "/esoui/art/contacts/tabicon_ignored_up.dds",
                [4] = "/esoui/art/armory/buildicons/buildicon_59.dds",
                [5] = "/esoui/art/armory/buildicons/buildicon_51.dds",
            },
        },

        SOCIAL = {
            FRIEND    = "/esoui/art/mainmenu/menubar_social_up.dds",
            IGNORED   = "/esoui/art/contacts/tabicon_ignored_up.dds",
            GUILDMATE = "/esoui/art/mainmenu/menubar_guilds_up.dds", --"/esoui/art/contacts/tabicon_friends_up.dds",
        }
    },

    debug          = true, --false,
}

ZO_CreateStringId(ADDON_PREFIX .. "ADDON_NAME", XelosesContacts.displayName)
