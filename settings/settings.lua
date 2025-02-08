local LAM   = LibAddonMenu2
local XC    = XelosesContacts
local CONST = XC.CONST
local F     = XC.formatString
local T     = type

function XC:OpenSettings()
    LAM:OpenToPanel(self.UI.SettingsPanel)
end

function XC:CreateConfigMenu()
    local panel_data = {
        type                = "panel",
        name                = self.name,
        displayName         = self.displayName,
        author              = self.author,
        version             = self:getVersion(),
        website             = self.url,
        feedback            = self.url_dev .. "issues",
        slashCommand        = self.slashCmd .. " " .. self.slashCmdParams["OPEN_SETTINGS"].cmd,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    -- --------------------
    --  @SECTION <Utility>
    -- --------------------

    local function getColor(index)
        local color = ZO_ColorDef:New(self:getCategoryColor(index) or self.defaults.colors[index])
        return color.r, color.g, color.b, color.a
    end

    local function setColor(index, color_r, color_g, color_b, color_a)
        self.config.colors[index] = ZO_ColorDef:New(color_r or 0.8, color_g or 0.8, color_b or 0.8, color_a or 0.9):ToHex()
    end

    local function ColorFromHex(hex_color)
        if (not T(hex_color) == "string" or not hex_color:match("^[%x]+$")) then
            hex_color = "FFFFFF"
        end
        local color = ZO_ColorDef:New(hex_color)
        return color.r, color.g, color.b, color.a
    end

    local function ColorToHex(color_r, color_g, color_b, color_a)
        return ZO_ColorDef:New(color_r or 0.8, color_g or 0.8, color_b or 0.8, color_a or 0.9):ToHex()
    end

    local function L(str, ...)
        local s = self.getString("SETTINGS_" .. str)
        if (not s or s:isEmpty() or s:match("^[_A-Z0-9]+$") or s:find("SETTINGS_", 1, true) == 1) then return end
        return F(s, ...)
    end

    -- -------------------

    local config_data = table:new()

    local function createItem(item_type, text, params)
        if (not item_type or T(item_type) ~= "string") then return end

        local item = { type = item_type }

        if (item_type == "divider") then
            if (text and not params and T(text) == "table") then
                params = text
            end
            item.alpha  = params and params.alpha or 0.25
            item.height = params and params.height or 10
            item.width  = params and params.width or "full"
            return item
        end

        if (not text or T(text) ~= "string" or text == "") then return end

        local item_text = text:match("[^A-Z0-9_]+") and text or L(text)
        if (item_type == "description") then
            item.text = item_text
        else
            item.name = item_text
        end

        if (T(params) == "table") then
            if (T(params.tooltip) == "string") then
                params.tooltip = L(params.tooltip)
            elseif (T(params.tooltip) == "table") then
                params.tooltip = table:new(params.tooltip):join(" ")
            elseif (params.tooltip == nil or params.tooltip) then
                params.tooltip = L(text .. "_TOOLTIP")
            end

            for key, val in pairs(params) do
                item[key] = val
            end
        end

        return item
    end

    local function addItem(item_type, text_id, params)
        config_data:insert(createItem(item_type, text_id, params))
    end

    local function addSubmenu(title, submenu, params)
        if (T(title) ~= "string" or title:isEmpty() or T(submenu) ~= "table" or #submenu == 0) then return end

        local submenu_data = {
            type = "submenu",
            name = (title:match("[A-Z_]+") == title) and L(title) or title,
            controls = submenu,
        }

        if (T(params) == "table") then
            for key, val in pairs(params) do
                submenu_data[key] = val
            end
        end

        config_data:insert(submenu_data)
    end

    -- ------------------
    --  @SECTION GENERAL
    -- ------------------
    addItem("header", "GENERAL")

    addItem("checkbox", "UI_SEARCH_NOTE", {
        getFunc = function() return self.config.ui.search_note end,
        setFunc = function(val) self.config.ui.search_note = val end,
        default = self.defaults.ui.search_note,
    })

    -- -----------------
    --  @SECTION COLORS
    -- -----------------
    addItem("header", "COLORS")
    addItem("description", "COLORS_DESCRIPTION")

    for category_id, category_name in ipairs(CONST.CONTACTS_CATEGORIES) do
        addItem("colorpicker", L("COLOR", category_name), {
            getFunc = function() return getColor(category_id) end,
            setFunc = function(r, g, b, a) setColor(category_id, r, g, b, a) end,
            default = function() return ZO_ColorDef:New(self.defaults.colors[category_id]) end,
        })
    end

    -- -----------------
    --  @SECTION GROUPS
    -- -----------------
    addItem("header", "GROUPS")
    addItem("description", "GROUPS_DESCRIPTION")

    -- GROUPS submenu
    for category_id, category_name in ipairs(CONST.CONTACTS_CATEGORIES) do
        local GROUPS = self.config.groups[category_id]
        local group_submenu = table:new()
        for group_id, group_name in ipairs(GROUPS) do
            local group_icon = tostring(group_id):addIcon(self:getGroupIcon(category_id, group_id), self:getCategoryColor(category_id))
            local text = L("GROUP_NAME", group_icon)
            group_submenu:insert(createItem("editbox", text, {
                maxChars    = CONST.GROUP_NAME_MAX_LENGTH,
                isMultiline = false,
                getFunc     = function() return GROUPS[group_id] end,
                setFunc     = function(val) GROUPS[group_id] = val:sanitize(CONST.GROUP_NAME_MAX_LENGTH) end,
                default     = self.defaults.groups[category_id][group_id],
            }))
        end
        addSubmenu(category_name, group_submenu)
    end

    -- -------------------------
    --  @SECTION RETICLE MARKER
    -- -------------------------
    addItem("header", "RETICLE_MARKER")
    addItem("description", "RETICLE_MARKER_DESCRIPTION")

    addItem("checkbox", "RETICLE_MARKER_ENABLE", {
        getFunc = function() return self.config.reticle.enabled end,
        setFunc = function(val)
            self.config.reticle.enabled = val
            self:ToggleHook("ReticleTarget")
        end,
        default = self.defaults.reticle.enabled,
    })

    addItem("checkbox", "RETICLE_MARKER_DISABLE_COMBAT", {
        getFunc = function() return self.config.reticle.disable.combat end,
        setFunc = function(val) self.config.reticle.disable.combat = val end,
        disabled = function() return not self.config.reticle.enabled end,
        default = self.defaults.reticle.disable.combat,
    })
    addItem("checkbox", "RETICLE_MARKER_DISABLE_GROUP_DUNGEON", {
        getFunc = function() return self.config.reticle.disable.group_dungeon end,
        setFunc = function(val) self.config.reticle.disable.group_dungeon = val end,
        disabled = function() return not self.config.reticle.enabled end,
        default = self.defaults.reticle.disable.group_dungeon,
    })
    addItem("checkbox", "RETICLE_MARKER_DISABLE_TRIAL", {
        getFunc = function() return self.config.reticle.disable.trial end,
        setFunc = function(val) self.config.reticle.disable.trial = val end,
        disabled = function() return not self.config.reticle.enabled end,
        default = self.defaults.reticle.disable.trial,
    })
    addItem("checkbox", "RETICLE_MARKER_DISABLE_PVP", {
        getFunc  = function() return self.config.reticle.disable.pvp end,
        setFunc  = function(val) self.config.reticle.disable.pvp = val end,
        disabled = function() return not self.config.reticle.enabled end,
        default  = self.defaults.reticle.disable.pvp,
    })

    do
        local positions = table:new()
        local position_indexes = table:new()
        for position, position_index in pairs(CONST.UI.RETICLE_MARKER.POSITION) do
            positions:insert(L("RETICLE_MARKER_POSITION_" .. position))
            position_indexes:insert(position_index)
        end
        addItem("dropdown", "RETICLE_MARKER_POSITION", {
            choices       = positions,
            choicesValues = position_indexes,
            sort          = "numericvalue-up",
            getFunc       = function() return self.config.reticle.position end,
            setFunc       = function(val)
                self.config.reticle.position = val
                self.UI.ReticleMarker:SetPosition(val)
            end,
            disabled      = function() return not self.config.reticle.enabled end,
            default       = self.defaults.reticle.position,
        })
    end

    addItem("slider", "RETICLE_MARKER_OFFSET", {
        min        = CONST.UI.RETICLE_MARKER.MIN_OFFSET,
        max        = CONST.UI.RETICLE_MARKER.MAX_OFFSET,
        step       = 5,
        clampInput = false,
        getFunc    = function() return self.config.reticle.offset end,
        setFunc    = function(val)
            self.config.reticle.offset = val
            self.UI.ReticleMarker:SetOffset(val)
        end,
        disabled   = function() return not self.config.reticle.enabled end,
        default    = self.defaults.reticle.offset,
    })

    addItem("slider", "RETICLE_MARKER_FONT_SIZE", {
        min        = 16,
        max        = 36,
        step       = 2,
        clampInput = false,
        getFunc    = function() return self.config.reticle.font.size end,
        setFunc    = function(val)
            self.config.reticle.font.size = val
            self.UI.ReticleMarker:SetCaptionFont({ size = val })
        end,
        disabled   = function() return not self.config.reticle.enabled end,
        default    = self.defaults.reticle.font.size,
    })
    addItem("dropdown", "RETICLE_MARKER_FONT_STYLE", {
        choices  = CONST.FONT_STYLE,
        getFunc  = function() return self.config.reticle.font.style end,
        setFunc  = function(val)
            self.config.reticle.font.style = val
            self.UI.ReticleMarker:SetCaptionFont({ style = val })
        end,
        disabled = function() return not self.config.reticle.enabled end,
        default  = self.defaults.reticle.font.style,
    })

    addItem("checkbox", "RETICLE_MARKER_ICON_ENABLE", {
        getFunc = function() return self.config.reticle.icon.enabled end,
        setFunc = function(val)
            self.config.reticle.icon.enabled = val
            self.UI.ReticleMarker:SetIconVisibility(val)
        end,
        default = self.defaults.reticle.icon.enabled,
    })

    do
        local sizes = table:new()
        local size_titles = table:new()
        for title, size in pairs(CONST.UI.RETICLE_MARKER.ICON_SIZE) do
            size_titles:insert(L("RETICLE_MARKER_ICON_SIZE_" .. title))
            sizes:insert(size)
        end
        addItem("dropdown", "RETICLE_MARKER_ICON_SIZE", {
            choices       = size_titles,
            choicesValues = sizes,
            sort          = "numericvalue-up",
            getFunc       = function() return self.config.reticle.icon.size end,
            setFunc       = function(val)
                self.config.reticle.icon.size = val
                self.UI.ReticleMarker:SetIconSize(val)
            end,
            disabled      = function() return not self.config.reticle.enabled or not self.config.reticle.icon.enabled end,
            default       = self.defaults.reticle.icon.size,
        })
    end

    -- Additional markers submenu
    do
        local markers_submenu = table:new()

        local markers_info = self.getString("WARNING"):colorize(self.colors.warning) .. " " .. L("RETICLE_MARKER_ADDITIONAL_MARKERS_DESCRIPTION")
        markers_submenu:insert(createItem("description", markers_info))

        local markers = self.config.reticle.markers
        local marker_names = table:new(markers):keys()
        marker_names:sort()
        for _, marker_name in ipairs(marker_names) do
            local uname = marker_name:upper()
            local icon = (""):addIcon(self.ICONS.SOCIAL[uname])
            local text = F(L("RETICLE_MARKER_ADDITIONAL_" .. uname), icon)
            markers_submenu:insert(createItem("divider"))
            markers_submenu:insert(createItem("checkbox", text, {
                tooltip = "RETICLE_MARKER_ADDITIONAL_" .. uname .. "_TOOLTIP",
                getFunc = function() return self.config.reticle.markers[marker_name].enabled end,
                setFunc = function(val) self.config.reticle.markers[marker_name].enabled = val end,
                disabled = function() return not self.config.reticle.enabled end,
                default = self.defaults.reticle.markers[marker_name].enabled,
            }))
            markers_submenu:insert(createItem("colorpicker", L("RETICLE_MARKER_ADDITIONAL_" .. uname .. "_COLOR"), {
                getFunc = function() return ColorFromHex(self.config.reticle.markers[marker_name].color) end,
                setFunc = function(r, g, b, a) self.config.reticle.markers[marker_name].color = ColorToHex(r, g, b, a) end,
                disabled = function() return not self.config.reticle.enabled or not self.config.reticle.markers[marker_name].enabled end,
                default = function() return ZO_ColorDef:New(self.defaults.reticle.markers[marker_name].color) end,
            }))
        end

        addSubmenu("RETICLE_MARKER_ADDITIONAL_MARKERS", markers_submenu, {
            disabled = function() return not self.config.reticle.enabled end,
        })
    end


    -- ------------------------
    --  @SECTION NOTIFICATIONS
    -- ------------------------
    addItem("header", "NOTIFICATION")

    do
        local channel_indexes = table:new()
        local channel_names   = table:new()
        for channel_name, channel_index in pairs(CONST.NOTIFICATION_CHANNELS) do
            channel_names:insert(L("NOTIFICATION_CHANNEL_OPTION_" .. channel_name))
            channel_indexes:insert(channel_index)
        end
        addItem("dropdown", "NOTIFICATION_CHANNEL", {
            choices       = channel_names,
            choicesValues = channel_indexes,
            sort          = "numericvalue-up",
            getFunc       = function() return self.config.notifications.channel end,
            setFunc       = function(val) self.config.notifications.channel = val end,
            default       = self.defaults.notifications.channel,
        })
    end
    addItem("divider")

    addItem("checkbox", "CONFIRM_ADD_FRIEND", {
        getFunc = function() return self.config.confirmation.friend end,
        setFunc = function(val)
            self.config.confirmation.friend = val
            self:ToggleHook("AddFriend")
        end,
        default = self.defaults.confirmation.friend,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_FRIEND_INVITE", {
        getFunc = function() return self.config.notifications.friendInvite.enabled end,
        setFunc = function(val)
            self.config.notifications.friendInvite.enabled = val
            self:ToggleHook("IncomingFriendInvite")
        end,
        default = self.defaults.notifications.friendInvite.enabled,
    })
    addItem("checkbox", "NOTIFICATION_FRIEND_INVITE_SCREEN", {
        getFunc  = function() return self.config.notifications.friendInvite.announce end,
        setFunc  = function(val) self.config.notifications.friendInvite.announce = val end,
        disabled = function() return not self.config.notifications.friendInvite.enabled or self.config.notifications.friendInvite.decline end,
        default  = self.defaults.notifications.friendInvite.announce,
    })
    addItem("checkbox", "AUTODECLINE_FRIEND_INVITE", {
        getFunc = function() return self.config.notifications.friendInvite.decline end,
        setFunc = function(val) self.config.notifications.friendInvite.decline = val end,
        default = self.defaults.notifications.friendInvite.decline,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_GROUP_INVITE", {
        getFunc = function() return self.config.notifications.groupInvite.enabled end,
        setFunc = function(val)
            self.config.notifications.groupInvite.enabled = val
            self:ToggleHook("IncomingGroupInvite")
        end,
        default = self.defaults.notifications.groupInvite.enabled,
    })
    addItem("checkbox", "NOTIFICATION_GROUP_INVITE_SCREEN", {
        getFunc  = function() return self.config.notifications.groupInvite.announce end,
        setFunc  = function(val) self.config.notifications.groupInvite.announce = val end,
        disabled = function() return not self.config.notifications.groupInvite.enabled or self.config.notifications.groupInvite.decline end,
        default  = self.defaults.notifications.groupInvite.announce,
    })
    addItem("checkbox", "AUTODECLINE_GROUP_INVITE", {
        getFunc = function() return self.config.notifications.groupInvite.decline end,
        setFunc = function(val) self.config.notifications.groupInvite.decline = val end,
        default = self.defaults.notifications.groupInvite.decline,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_GROUP_JOIN", {
        getFunc = function() return self.config.notifications.groupJoin.enabled end,
        setFunc = function(val)
            self.config.notifications.groupJoin.enabled = val
            self:ToggleHook("GroupChange")
        end,
        default = self.defaults.notifications.groupJoin.enabled,
    })
    addItem("checkbox", "NOTIFICATION_GROUP_JOIN_SCREEN", {
        getFunc  = function() return self.config.notifications.groupJoin.announce end,
        setFunc  = function(val) self.config.notifications.groupJoin.announce = val end,
        disabled = function() return not self.config.notifications.groupJoin.enabled end,
        default  = self.defaults.notifications.groupJoin.announce,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_GROUP_MEMBER", {
        getFunc = function() return self.config.notifications.groupMember.enabled end,
        setFunc = function(val)
            self.config.notifications.groupMember.enabled = val
            self:ToggleHook("GroupChange")
        end,
        default = self.defaults.notifications.groupMember.enabled,
    })
    addItem("checkbox", "NOTIFICATION_GROUP_MEMBER_SCREEN", {
        getFunc  = function() return self.config.notifications.groupMember.announce end,
        setFunc  = function(val) self.config.notifications.groupMember.announce = val end,
        disabled = function() return not self.config.notifications.groupMember.enabled end,
        default  = self.defaults.notifications.groupMember.announce,
    })

    -- ---------------
    --  @SECTION CHAT
    -- ---------------
    addItem("header", "CHAT")
    addItem("description", "CHAT_DESCRIPTION")

    -- Chat blocking submenu
    do
        local chat_block_submenu = table:new()
        chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_GROUPS"))
        chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_GROUPS_DESCRIPTION"))

        -- Contact' groups
        local GROUPS = self.config.groups[CONST.CONTACTS_VILLAINS_ID]
        local category_color = self:getCategoryColor(CONST.CONTACTS_VILLAINS_ID)
        for group_id, group_name in ipairs(GROUPS) do
            local group_icon = self:getGroupIcon(CONST.CONTACTS_VILLAINS_ID, group_id)
            local text = F(L("CHAT_BLOCK_GROUP"), (""):addIcon(group_icon, category_color), group_name)
            chat_block_submenu:insert(createItem("checkbox", text, {
                tooltip = "CHAT_BLOCK_GROUP_TOOLTIP",
                getFunc = function() return self.config.chat.block_groups[group_id] end,
                setFunc = function(val) self.config.chat.block_groups[group_id] = val end,
                default = self.defaults.chat.block_groups[group_id],
            }))
        end

        chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_CHANNELS"))
        chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_CHANNELS_DESCRIPTION"))

        -- Chat channels
        local chat_channels = CONST.CHAT.CHANNELS
        for channel_name, _ in pairs(chat_channels) do
            chat_block_submenu:insert(createItem("checkbox", "CHAT_BLOCK_CHANNEL_" .. channel_name:upper(), {
                getFunc = function() return self.config.chat.block_channels[channel_name] end,
                setFunc = function(val) self.config.chat.block_channels[channel_name] = val end,
                default = self.defaults.chat.block_channels[channel_name],
            }))
        end

        addSubmenu("CHAT_BLOCK", chat_block_submenu)
    end

    addItem("checkbox", "CHAT_INFO", {
        getFunc = function() return not self.config.chat.log end,
        setFunc = function(val) self.config.chat.log = not val end,
        default = self.defaults.chat.log,
    })

    -- -----------------
    --  @SECTION IMPORT
    -- -----------------
    local import_target_friends  = 1
    local import_target_villains = 1

    addItem("header", "IMPORT")

    -- Import Friends
    local groups_list = self:getGroupsList(CONST.CONTACTS_FRIENDS_ID, true, true)

    addItem("description", "IMPORT_FRIENDS")
    addItem("dropdown", "IMPORT_DESTINATION", {
        choices       = groups_list:values(),
        choicesValues = groups_list:keys(),
        sort          = "numericvalue-up",
        getFunc       = function() return import_target_friends end,
        setFunc       = function(val) import_target_friends = val end,
        default       = 1,
    })
    addItem("button", "IMPORT_BUTTON", {
        func = function() self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_IMPORT_FRIENDS, nil, import_target_friends) end,
        disabled = function() return self.processing or (GetNumFriends() == 0) end,
    })
    addItem("divider")

    -- Import Ignored
    groups_list = self:getGroupsList(CONST.CONTACTS_VILLAINS_ID, true, true)

    addItem("description", "IMPORT_IGNORED")
    addItem("dropdown", "IMPORT_DESTINATION", {
        choices       = groups_list:values(),
        choicesValues = groups_list:keys(),
        sort          = "numericvalue-up",
        getFunc       = function() return import_target_villains end,
        setFunc       = function(val) import_target_villains = val end,
        default       = 1,
    })
    addItem("button", "IMPORT_BUTTON", {
        func = function() self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_IMPORT_IGNORED, nil, import_target_villains) end,
        disabled = function() return self.processing or (GetNumIgnored() == 0) end,
    })

    -- ----------------
    --  @SECTION Panel
    -- ----------------

    self.UI.SettingsPanel = LAM:RegisterAddonPanel(self.__namespace .. "_Config", panel_data)
    LAM:RegisterOptionControls(self.__namespace .. "_Config", config_data)
end
