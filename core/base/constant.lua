local FRIENDS_ID  = 1
local VILLAINS_ID = 2

-- --------------------
--  @SECTION CONSTANTs
-- --------------------

function XelosesContacts:LoadConstants()
    local L    = self.getString

    self.CONST = {
        COLOR                   = {
            DEFAULT   = "dddddd",
            TAG       = "ee55ee", -- color of addon tag
            INFO      = "66ffff", -- color of informational messages
            NOTE      = "999999", -- color of informational notes
            WARNING   = "ff3010", -- color of warnings
            DANGER    = "dd3333", -- color of dangerous warnings
            ERROR     = "ee3333", -- color of errors
            CHAT_LINK = "eeeeee", -- color of chat links
        },

        ACCOUNT_NAME_MIN_LENGTH = 3,
        ACCOUNT_NAME_MAX_LENGTH = 20,
        GROUP_NAME_MAX_LENGTH   = 20,
        CONTACT_NOTE_MAX_LENGTH = 500,

        CONTACTS_FRIENDS_ID     = FRIENDS_ID,
        CONTACTS_VILLAINS_ID    = VILLAINS_ID,
        CONTACTS_CATEGORIES     = {
            [FRIENDS_ID]  = L("FRIENDS"),
            [VILLAINS_ID] = L("VILLAINS"),
        },

        NOTIFICATION_CHANNELS   = {
            BOTH = 1,
            CHAT = 2,
            SCREEN = 3,
        },

        UI                      = {
            TAB_NAME       = "Contacts",
            FONT_STYLE     = {
                "normal",
                "outline",
                "thick-outline",
                "shadow",
                "soft-shadow-thick",
                "soft-shadow-thin"
            },
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

        SOUND                   = {
            NOTIFICATION = {
                DEFAULT = SOUNDS.DUEL_START,
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

            CACHE = {
                MIN_SIZE = 10,
                MAX_SIZE = 500,

                CHANNELS = {
                    [CHAT_CHANNEL_SAY]             = true,
                    [CHAT_CHANNEL_YELL]            = true,
                    [CHAT_CHANNEL_EMOTE]           = true,
                    [CHAT_CHANNEL_ZONE]            = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_1] = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_2] = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_3] = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_4] = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_5] = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_6] = true,
                    [CHAT_CHANNEL_ZONE_LANGUAGE_7] = true,
                    [CHAT_CHANNEL_WHISPER]         = true,
                    [CHAT_CHANNEL_WHISPER_SENT]    = true,
                },
            },
        },
    }

    self:LoadIconsList()
    self:LoadZonesData()
end
