local XC    = XelosesContacts
local CONST = XC.CONST

-- ----------------
--  @SECTION Icons
-- ----------------

CONST.ICONS = {
    SOCIAL = table:new({
        FRIEND    = "/esoui/art/mainmenu/menubar_social_up.dds",
        IGNORED   = "/esoui/art/contacts/tabicon_ignored_up.dds",
        GUILDMATE = "/esoui/art/mainmenu/menubar_guilds_up.dds",
    }),

    CLASS = "/esoui/art/contacts/social_classicon_%s.dds", -- dragonknight / necromancer / nightblade / templar / sorcerer / warden

    AVA = {
        AD = "/esoui/art/contacts/social_allianceicon_aldmeri.dds",
        DC = "/esoui/art/contacts/social_allianceicon_daggerfall.dds",
        EB = "/esoui/art/contacts/social_allianceicon_ebonheart.dds",
    },

    LIST = table:new({
        "/esoui/art/tutorial/achievements_indexicon_summary_up.dds",
        "/esoui/art/treeicons/gamepad/gp_collectionicon_housing.dds",
        "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds",
        "/esoui/art/contacts/tabicon_ignored_up.dds",
    }),

    UI = {
        NOTE         = "/esoui/art/buttons/edit_up.dds",
        QUEST        = "/esoui/art/journal/journal_tabicon_quest_up.dds",
        INFO         = "/esoui/art/login/login_icon_info.dds",
        WARNING      = "/esoui/art/miscellaneous/eso_icon_warning.dds",
        EXCLAMATION  = "/esoui/art/interaction/questnewavailable.dds",
        QUESTION     = "/esoui/art/interaction/questcompleteavailable.dds",
        LOCK         = "/esoui/art/tooltips/icon_lock.dds",

        CONFIG_PANEL = {
            GENERAL        = "/esoui/art/mainmenu/menubar_collections_up.dds",
            COLORS         = "/esoui/art/dye/dyes_categoryicon_up.dds",
            GROUPS         = "/esoui/art/mainmenu/menubar_group_up.dds",
            -- @TODO get RETICLE MARKER new icon
            RETICLE_MARKER = "/esoui/art/reticle/reticle-groundtarget.dds",
            NOTIFICATION   = "/esoui/art/mainmenu/menubar_notifications_up.dds",
            CHAT           = "/esoui/art/mainmenu/menubar_voip_up.dds",
            CHAT_BLOCK     = "/esoui/art/contacts/tabicon_ignored_up.dds",
            IMPORT         = "/esoui/art/lfg/lfg_indexicon_groupfinder_up.dds",
        }
    }
}

do
    -- fill icons list (used for LAM IconPicker widget)
    local armory_icons = "/esoui/art/armory/buildicons/buildicon_%d.dds"

    for i = 1, 78 do
        CONST.ICONS.LIST:insert(armory_icons:format(i))
    end
end
