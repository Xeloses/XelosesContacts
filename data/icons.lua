-- ----------------
--  @SECTION ICONS
-- ----------------

function XelosesContacts:LoadIconsList()
    self.CONST.ICONS = {

        MAIN_ICON = "/esoui/art/contacts/tabicon_friends_up.dds",

        -- -----------------------
        --  @SECTION Social icons
        -- -----------------------

        SOCIAL = table:new({
            FRIEND    = "/esoui/art/mainmenu/menubar_social_up.dds",
            IGNORED   = "/esoui/art/contacts/tabicon_ignored_up.dds",
            GUILDMATE = "/esoui/art/mainmenu/menubar_guilds_up.dds",
        }),

        -- ----------------------
        --  @SECTION Class icons
        -- ----------------------

        CLASS = "/esoui/art/contacts/social_classicon_%s.dds", -- dragonknight / necromancer / nightblade / templar / sorcerer / warden

        -- --------------------
        --  @SECTION PvP icons
        -- --------------------

        AVA = {
            AD = "/esoui/art/contacts/social_allianceicon_aldmeri.dds",    -- /esoui/art/leaderboards/gamepad/gp_leaderboards_menuicon_aldmeri.dds
            DC = "/esoui/art/contacts/social_allianceicon_daggerfall.dds", -- /esoui/art/leaderboards/gamepad/gp_leaderboards_menuicon_daggerfall.dds
            EB = "/esoui/art/contacts/social_allianceicon_ebonheart.dds",  -- /esoui/art/leaderboards/gamepad/gp_leaderboards_menuicon_ebonheart.dds
        },

        -- -------------------
        --  @SECTION UI icons
        -- -------------------

        UI = {
            NOTE         = "/esoui/art/buttons/edit_up.dds",
            QUEST        = "/esoui/art/journal/journal_tabicon_quest_up.dds",
            INFO         = "/esoui/art/login/login_icon_info.dds",
            WARNING      = "/esoui/art/miscellaneous/eso_icon_warning.dds",
            EXCLAMATION  = "/esoui/art/interaction/questnewavailable.dds",
            QUESTION     = "/esoui/art/interaction/questcompleteavailable.dds",
            CHECK        = "/esoui/art/champion/gamepad/gp_quickmenu_equipped_selected.dds",
            LOCK         = "/esoui/art/tooltips/icon_lock.dds",

            NOTIFICATION = {
                DEFAULT = "/esoui/art/contacts/tabicon_friends_up.dds",
            },

            CONFIG_PANEL = {
                GENERAL        = "/esoui/art/mainmenu/menubar_collections_up.dds",
                COLORS         = "/esoui/art/dye/dyes_categoryicon_up.dds",
                GROUPS         = "/esoui/art/mainmenu/menubar_group_up.dds",
                CHAT           = "/esoui/art/mainmenu/menubar_voip_up.dds",
                CHAT_BLOCK     = "/esoui/art/contacts/tabicon_ignored_up.dds",
                CONTEXT_MENU   = "/esoui/art/buttons/gamepad/scarlett/nav_scarlett_menu.dds", -- /esoui/art/menubar/gamepad/gp_playermenu_icon_communications.dds
                NOTIFICATION   = "/esoui/art/mainmenu/menubar_notifications_up.dds",
                RETICLE_MARKER = "/esoui/art/armory/buildicons/buildicon_23.dds",
                MARKERS        = "/esoui/art/journal/u26_progress_digsite_marked_complete.dds",
                IMPORT         = "/esoui/art/lfg/lfg_indexicon_groupfinder_up.dds",
            },
        },
    }

    -- --------------------------------------
    --  @SECTION Icons list (for IconPicker)
    -- --------------------------------------

    -- icons list (used for LAM IconPicker widget)
    local icons_list = table:new({
        "/esoui/art/tutorial/achievements_indexicon_summary_up.dds",
        "/esoui/art/treeicons/gamepad/gp_collectionicon_housing.dds",
        "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds",
        "/esoui/art/contacts/tabicon_ignored_up.dds",
    })

    -- fill icons list (add Armory icons)
    local armory_icons = "/esoui/art/armory/buildicons/buildicon_%d.dds"
    for i = 1, 78 do
        icons_list:insert(armory_icons:format(i))
    end

    self.CONST.ICONS.LIST = icons_list
end
