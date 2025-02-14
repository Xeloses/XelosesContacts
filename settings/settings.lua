local CM    = CALLBACK_MANAGER
local LAM   = LibAddonMenu2
local XC    = XelosesContacts
local CONST = XC.CONST
local F     = XC.formatString
local T     = type

function XC:OpenSettings()
    LAM:OpenToPanel(self.UI.SettingsPanel)
end

function XC:CreateConfigMenu()
    -- ----------------
    --  @SECTION Panel
    -- ----------------

    local panel_data            = {
        type                = "panel",
        name                = self.name,
        displayName         = self.displayName,
        author              = self.author,
        version             = self:getVersion(),
        keywords            = "social contact friend villain ignore mark",
        website             = self.url,
        feedback            = self.url_dev .. "issues",
        slashCommand        = self.slashCmd .. " " .. self.slashCmdParams["OPEN_SETTINGS"].cmd,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    -- --------------------
    --  @SECTION <Utility>
    -- --------------------

    local color_note            = "999999"
    local color_warn            = "CC3333"

    local icon_size_text        = 24
    local icon_size_header      = 36

    local control_name_template = self.__prefix .. "LAM_%s_%d"

    local groups_changed        = false
    panel_data.resetFunc        = function() groups_changed = false end -- handle reset to defaults settings

    -- -------------------
    --  Utility

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
    --  Panel controls

    local config_data = table:new()

    local function createItem(item_type, text, params)
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

        if (T(text) ~= "string" or text:isEmpty()) then return end

        local item_text = text:match("[^A-Z0-9_]+") and text or L(text)

        if (T(params) == "table") then
            local item_color
            if (T(params.color) == "string") then
                item_color = params.color
            end
            params.color = nil
            item_text    = item_text:colorize(item_color)

            local item_icon
            if (T(params.icon) == "string") then
                item_icon = params.icon
            elseif (params.icon) then
                item_icon = CONST.ICONS.UI.CONFIG_PANEL[text]
            end
            local item_icon_size = params.icon_size or (item_type == "header" and icon_size_header) or icon_size_text
            item_text            = item_text:addIcon(item_icon, item_color, item_icon_size)
            params.icon          = nil
            params.icon_size     = nil

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

        if (item_type == "description") then
            item.text = item_text
        else
            item.name = item_text
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

    local function updateGroupsList(category_id)
        local controls     = { "GROUPS_EDIT_SELECT", "IMPORT_GROUP_SELECT" }

        local groups_list  = self:getGroupsList(category_id, true, true)
        local groups_ids   = groups_list:keys()
        local groups_names = groups_list:values()

        for _, control_name in ipairs(controls) do
            local control = _G[control_name_template:format(control_name, category_id)]

            if (control) then
                control.data.choices       = groups_names
                control.data.choicesValues = groups_ids
                control:UpdateChoices()
            end
        end
    end

    -- ------------------
    --  @SECTION GENERAL
    -- ------------------
    addItem("header", "GENERAL", { icon = true })

    addItem("checkbox", "UI_SEARCH_NOTE", {
        getFunc = function() return self.config.ui.search_note end,
        setFunc = function(val) self.config.ui.search_note = val end,
        default = self.defaults.ui.search_note,
    })

    -- -----------------
    --  @SECTION COLORS
    -- -----------------

    addItem("header", "COLORS", { icon = true })
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

    addItem("header", "GROUPS", { icon = true })
    addItem("description", "GROUPS_DESCRIPTION")

    -- GROUPS submenus
    for category_id, category_name in ipairs(CONST.CONTACTS_CATEGORIES) do
        local category_color    = self:getCategoryColor(category_id)
        local selected_group_id = 0

        local GROUPS            = self.config.groups[category_id]
        local group_submenu     = table:new()

        local function updateSelectedGroupData(data)
            local i = self:getGroupIndexByID(category_id, selected_group_id)
            if (not i) then return end

            for k, v in pairs(data) do
                GROUPS[i][k] = v
            end

            groups_changed = true
            updateGroupsList(category_id)
        end

        -- ----------------------------------------

        group_submenu:insert(createItem("divider"))

        -- Group selector
        do
            local groups_list = self:getGroupsList(category_id, true, true)
            local group_ids   = groups_list:keys()
            local group_names = groups_list:values()

            group_submenu:insert(createItem("dropdown", "GROUPS_SELECT", {
                choices       = group_names,
                choicesValues = group_ids,
                sort          = "numericvalue-up",
                scrollable    = 7,
                getFunc       = function() return selected_group_id end,
                setFunc       = function(val) selected_group_id = val end,
                default       = 0,
                reference     = control_name_template:format("GROUPS_EDIT_SELECT", category_id),
            }))
        end

        -- Manage group buttons
        group_submenu:insert(createItem("button", "GROUPS_BUTTON_ADD", {
            width    = "half",
            func     = function()
                local g = self:CreateGroup(category_id)
                selected_group_id = g.id
                updateGroupsList(category_id)
            end,
            --requiresReload = true,
            disabled = function() return self.processing or #GROUPS >= CONST.CONTACTS_GROUPS_MAX end, -- limit groups amount
        }))
        group_submenu:insert(createItem("button", "GROUPS_BUTTON_REMOVE", {
            width       = "half",
            func        = function()
                self:RemoveGroup(category_id, selected_group_id)
                selected_group_id = 0
                updateGroupsList(category_id)
            end,
            warning     = L("GROUPS_BUTTON_REMOVE_WARNING"):colorize("DD3333"),
            isDangerous = true,
            -- requiresReload = true,
            disabled    = function() return self.processing or selected_group_id <= 5 end, -- disallow removing of predefined groups
        }))

        group_submenu:insert(createItem(
            "description",
            L("GROUPS_NOTE", self:getGroupTitle(category_id, 1)),
            {
                color = color_note,
                icon = CONST.ICONS.UI.NOTE,
            }
        ))

        -- Selected group editor
        group_submenu:insert(createItem("header", "GROUPS_EDIT"))
        group_submenu:insert(createItem("editbox", "GROUPS_EDIT_NAME", {
            maxChars    = CONST.GROUP_NAME_MAX_LENGTH,
            isMultiline = false,
            getFunc     = function() return (selected_group_id > 0) and self:getGroupName(category_id, selected_group_id) or "" end,
            setFunc     = function(val) updateSelectedGroupData({ name = val:sanitize(CONST.GROUP_NAME_MAX_LENGTH) }) end,
            disabled    = function() return selected_group_id == 0 end,
            default     = "",
            reference   = control_name_template:format("GROUPS_EDIT_NAME", category_id),
        }))
        group_submenu:insert(createItem("iconpicker", "GROUPS_EDIT_ICON", {
            choices      = CONST.ICONS.LIST,
            iconSize     = 28,
            defaultColor = ZO_ColorDef:New(self:getCategoryColor(category_id)),
            maxColumns   = 7,
            visibleRows  = 5.5,
            getFunc      = function() return (selected_group_id > 0) and self:getGroupIcon(category_id, selected_group_id) or CONST.ICONS.LIST[1] end,
            setFunc      = function(val) updateSelectedGroupData({ icon = val }) end,
            disabled     = function() return selected_group_id == 0 end,
            default      = CONST.ICONS.LIST[1],
            reference    = control_name_template:format("GROUPS_EDIT_ICON", category_id),
        }))

        addSubmenu(category_name:colorize(category_color), group_submenu)
    end

    -- -------------------------
    --  @SECTION RETICLE MARKER
    -- -------------------------

    addItem("header", "RETICLE_MARKER", { icon = true, icon_size = 24 })
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

        local marker_names = table:new(self.config.reticle.markers):keys()
        marker_names:sort()

        for _, marker_name in ipairs(marker_names) do
            local uname = marker_name:upper()
            local icon = (""):addIcon(CONST.ICONS.SOCIAL[uname])
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

    addItem("header", "NOTIFICATION", { icon = true })

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

    addItem("header", "CHAT", { icon = true })
    addItem("description", "CHAT_DESCRIPTION")

    -- Chat blocking submenu
    do
        local chat_block_submenu = table:new()
        chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_GROUPS"))
        chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_GROUPS_DESCRIPTION"))

        -- Contact' groups
        local category_color = self:getCategoryColor(CONST.CONTACTS_VILLAINS_ID)
        local groups_list    = self:getGroupsList(CONST.CONTACTS_VILLAINS_ID, true, true)
        for group_id, group_name in ipairs(groups_list) do
            if (group_id <= 5) then
                chat_block_submenu:insert(createItem("checkbox", F(L("CHAT_BLOCK_GROUP"), group_name), {
                    tooltip = "CHAT_BLOCK_GROUP_TOOLTIP",
                    getFunc = function() return self.config.chat.block_groups[group_id] end,
                    setFunc = function(val) self.config.chat.block_groups[group_id] = val end,
                    default = self.defaults.chat.block_groups[group_id],
                }))
            end
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

        local submenu_title = L("CHAT_BLOCK"):colorize(color_warn):addIcon(CONST.ICONS.UI.CONFIG_PANEL.CHAT_BLOCK, color_warn, 36)
        addSubmenu(submenu_title, chat_block_submenu)
    end

    addItem("checkbox", "CHAT_INFO", {
        getFunc = function() return not self.config.chat.log end,
        setFunc = function(val) self.config.chat.log = not val end,
        default = self.defaults.chat.log,
    })

    -- -----------------
    --  @SECTION IMPORT
    -- -----------------

    addItem("header", "IMPORT", { icon = true })

    do
        local category_ref = {
            [CONST.CONTACTS_FRIENDS_ID]  = "FRIENDS",
            [CONST.CONTACTS_VILLAINS_ID] = "VILLAINS"
        }
        local category_counter = {
            [CONST.CONTACTS_FRIENDS_ID]  = GetNumFriends,
            [CONST.CONTACTS_VILLAINS_ID] = GetNumIgnored,
        }

        local import_target = {}

        for category_id, category_name in ipairs(CONST.CONTACTS_CATEGORIES) do
            local groups_list          = self:getGroupsList(category_id, true, true)
            local group_ids            = groups_list:keys()
            local group_names          = groups_list:values()
            local category_ref_name    = category_ref[category_id]

            import_target[category_id] = 1

            addItem("description", "IMPORT_" .. category_ref_name)
            addItem("dropdown", "IMPORT_DESTINATION", {
                choices       = group_names,
                choicesValues = group_ids,
                sort          = "numericvalue-up",
                scrollable    = 5,
                getFunc       = function() return import_target[category_id] end,
                setFunc       = function(val) import_target[category_id] = val end,
                default       = 1,
                reference     = control_name_template:format("IMPORT_GROUP_SELECT", category_id),
            })
            addItem("button", "IMPORT_BUTTON", {
                func = function()
                    self:ShowDialog(
                        CONST.UI.DIALOGS["CONFIRM_IMPORT_" .. category_ref_name],
                        nil,
                        import_target[category_id]
                    )
                end,
                disabled = function()
                    local fn_counter = category_counter[category_id]
                    return self.processing or (fn_counter() == 0)
                end,
            })
            addItem("divider")
        end
    end

    -- @TODO test & remove/uncomment
    --[[
    -- Import Friends
    do
        local groups_list = self:getGroupsList(CONST.CONTACTS_FRIENDS_ID, true, true)
        local group_ids   = groups_list:keys()
        local group_names = groups_list:values()

        addItem("description", "IMPORT_FRIENDS")
        addItem("dropdown", "IMPORT_DESTINATION", {
            choices       = group_names,
            choicesValues = group_ids,
            sort          = "numericvalue-up",
            scrollable    = 5,
            getFunc       = function() return import_target.friends end,
            setFunc       = function(val) import_target.friends = val end,
            default       = 1,
            reference     = control_name_template:format("IMPORT_GROUP_SELECT", CONST.CONTACTS_FRIENDS_ID),
        })
        addItem("button", "IMPORT_BUTTON", {
            func = function() self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_IMPORT_FRIENDS, nil, import_target.friends) end,
            disabled = function() return self.processing or (GetNumFriends() == 0) end,
        })
        addItem("divider")
    end


    -- Import Ignored
    do
        local groups_list = self:getGroupsList(CONST.CONTACTS_VILLAINS_ID, true, true)
        local group_ids   = groups_list:keys()
        local group_names = groups_list:values()

        addItem("description", "IMPORT_IGNORED")
        addItem("dropdown", "IMPORT_DESTINATION", {
            choices       = group_names,
            choicesValues = group_ids,
            sort          = "numericvalue-up",
            scrollable    = 5,
            getFunc       = function() return import_target.villains end,
            setFunc       = function(val) import_target.villains = val end,
            default       = 1,
            reference     = control_name_template:format("IMPORT_GROUP_SELECT", CONST.CONTACTS_VILLAINS_ID),
        })
        addItem("button", "IMPORT_BUTTON", {
            func = function() self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_IMPORT_VILLAINS, nil, import_target.villains) end,
            disabled = function() return self.processing or (GetNumIgnored() == 0) end,
        })
    end
    ]]
    -- ----------------
    --  @SECTION Init
    -- ----------------

    self.UI.SettingsPanel = LAM:RegisterAddonPanel(self.__namespace .. "_Config", panel_data)
    LAM:RegisterOptionControls(self.__namespace .. "_Config", config_data)

    CM:RegisterCallback("LAM-PanelClosed", function(panel)
        if (panel ~= self.UI.SettingsPanel) then return end

        if (groups_changed) then
            self:RefreshContactGroups()
        end
    end)
end
