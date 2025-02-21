local CM  = CALLBACK_MANAGER
local LAM = LibAddonMenu2
local F   = XelosesContacts.formatString
local T   = type

function XelosesContacts:OpenSettings()
    LAM:OpenToPanel(self.UI.SettingsPanel)
end

function XelosesContacts:CreateConfigMenu()
    -- ----------------
    --  @SECTION Panel
    -- ----------------

    local panel_data           = {
        type                = "panel",
        name                = self.name,
        displayName         = self.displayName,
        author              = self.displayAuthorName,
        version             = self:getVersion(),
        keywords            = self.keywords,
        website             = self.url,
        feedback            = self.url_dev .. "issues",
        donation            = function() self.Game:ComposeMail(self.author, "Donation for " .. self.name) end,
        slashCommand        = self.slashCmd .. " " .. self.slashCmdParams["OPEN_SETTINGS"].cmd,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local config_data          = table:new()

    -- --------------------
    --  @SECTION <Utility>
    -- --------------------

    local ICON_SIZE_HEADER     = 36
    local ICON_SIZE_TEXT       = 24

    local CONTROL_REF_TEMPLATE = self.__prefix .. "LAM_%s_%d"

    local import_target_group  = {}

    local changed_colors       = table:new()
    local changed_groups       = table:new()

    -- ---------
    --  Strings

    -- wrapper for load string
    local function L(str, ...)
        local s = self.getString("SETTINGS_" .. str)
        if (not s or s:isEmpty() or s:match("^[_A-Z0-9]+$") or s:find("SETTINGS_", 1, true) == 1) then return end
        return F(s, ...)
    end

    -- --------
    --  Colors

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

    -- --------------------------
    --  Register changed options

    --[[
        Register changed options to apply necessary updates/refreshes on panel close
    ]]

    local function registerColorChanges(category_id)
        if (changed_colors:has(category_id)) then return end

        changed_colors:insert(category_id)
    end

    local function registerGroupChanges(category_id)
        if (changed_groups:has(category_id)) then return end

        changed_groups:insert(category_id)
    end

    -- ---------------------
    --  @SECTION <Controls>
    -- ---------------------

    --[[
        utilize custom properties to format panel item's text:
            panel_item.custom_color     : String         = "HEX color"            -- text color
            panel_item.custom_icon      : String|Boolean = "/path/to/texture.dds" -- icon to be placed before text or
                                                                              boolean indicates icon should be taken from CONST data table
            panel_item.custom_icon_size : Number         = 24                     -- specify size of icon (optional)
    ]]
    local function formatItemText(item_data, text)
        if (T(text) == "string" and not text:isEmpty()) then
            if (not item_data.custom_name) then
                item_data.custom_name = text
            end
        else
            text = item_data.custom_name
        end

        local result = text:match("[^A-Z0-9_]+") and text or L(text)
        if (not result) then return "" end

        if (T(item_data) == "table") then
            if (T(item_data.custom_color) == "string") then
                result = result:colorize(item_data.custom_color)
            end

            if (item_data.custom_icon) then
                if (T(item_data.custom_icon) == "boolean" and item_data.custom_icon) then
                    item_data.custom_icon = self.CONST.ICONS.UI.CONFIG_PANEL[item_data.custom_name]
                elseif (T(item_data.custom_icon) ~= "string") then
                    item_data.custom_icon = nil
                end

                if (not item_data.custom_icon_size or T(item_data.custom_icon_size) ~= "number") then
                    item_data.custom_icon_size = (item_data.type == "header" or item_data.type == "submenu") and ICON_SIZE_HEADER or ICON_SIZE_TEXT
                end

                result = result:addIcon(item_data.custom_icon, item_data.custom_color, item_data.custom_icon_size, true)
            end
        end

        return result
    end

    -- create control's data structure
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

        if (T(params) == "table") then
            if (T(params.tooltip) == "string") then
                params.tooltip = L(params.tooltip)
            elseif (T(params.tooltip) == "table") then
                params.tooltip = table:new(params.tooltip):join(" ")
            elseif (params.tooltip == nil or params.tooltip) then
                params.tooltip = L(text .. "_TOOLTIP")
            end

            if (T(params.warning) == "string") then
                params.warning = L(params.warning)
            elseif (T(params.warning) == "table") then
                params.warning = table:new(params.warning):join("\n")
            elseif (params.warning == nil or params.warning) then
                local warn = L(text .. "_WARNING")
                if (warn) then
                    params.warning = self.getString("WARNING"):colorize(self.CONST.COLOR.WARNING) .. " " .. warn
                end
            end

            for key, val in pairs(params) do
                item[key] = val
            end
        end

        if (item_type == "description") then
            item.text = formatItemText(item, text)
        else
            item.name = formatItemText(item, text)
        end

        return item
    end

    -- create control and add it to the panel
    local function addItem(item_type, text_id, params)
        config_data:insert(createItem(item_type, text_id, params))
    end

    -- create submenu and add it to the panel
    local function addSubmenu(title, submenu, params)
        local submenu_item = createItem("submenu", title, params)
        submenu_item.controls = submenu

        config_data:insert(submenu_item)
    end

    -- ------------------

    -- refresh (reload) group selection dropdown lists
    local function refreshGroupsList(category_id)
        local controls     = {
            -- "GROUPS_EDIT_SELECT",
            "IMPORT_GROUP_SELECT",
        }

        local groups_list  = self:getGroupsList(category_id, true, true)
        local groups_ids   = groups_list:keys()
        local groups_names = groups_list:values()

        for _, control_name in ipairs(controls) do
            local control = _G[CONTROL_REF_TEMPLATE:format(control_name, category_id)]

            if (control) then
                control.data.choices       = groups_names
                control.data.choicesValues = groups_ids
                control:UpdateChoices()
            end
        end
    end

    -- refresh/update colorized controls
    local function refreshColors(category_id)
        refreshGroupsList(category_id)

        local controls = { "GROUPS_EDIT" }

        for _, control_name in ipairs(controls) do
            local control = _G[CONTROL_REF_TEMPLATE:format(control_name, category_id)]

            if (control) then
                control.data.name = formatItemText(control.data)
                control:UpdateValue()
            end
        end

        local control = _G[CONTROL_REF_TEMPLATE:format("GROUPS_EDIT_ICON", category_id)]
        if (control) then
            local color = ZO_ColorDef:New(self:getCategoryColor(category_id))
            control.data.defaultColor = color
            control:SetColor(color)
        end
    end

    -- ------------------
    --  @SECTION GENERAL
    -- ------------------

    addItem("header", "GENERAL", { custom_icon = true })

    addItem("checkbox", "UI_SEARCH_NOTE", {
        getFunc = function() return self.config.ui.search_note end,
        setFunc = function(val) self.config.ui.search_note = val end,
        default = self.defaults.ui.search_note,
    })

    -- -----------------
    --  @SECTION COLORS
    -- -----------------

    addItem("header", "COLORS", { custom_icon = true })
    addItem("description", "COLORS_DESCRIPTION")

    for category_id, category_name in ipairs(self.CONST.CONTACTS_CATEGORIES) do
        addItem("colorpicker", L("COLOR", category_name), {
            getFunc = function() return getColor(category_id) end,
            setFunc = function(r, g, b, a)
                setColor(category_id, r, g, b, a)
                registerColorChanges(category_id)
                refreshColors(category_id)
            end,
            default = function() return ZO_ColorDef:New(self.defaults.colors[category_id]) end,
        })
    end

    -- -----------------
    --  @SECTION GROUPS
    -- -----------------

    addItem("header", "GROUPS", { custom_icon = true })
    addItem("description", "GROUPS_DESCRIPTION")

    -- GROUPS submenu
    for category_id, category_name in ipairs(self.CONST.CONTACTS_CATEGORIES) do
        local GROUPS = self.config.groups[category_id]
        local group_submenu = table:new()
        for group_id, group_name in ipairs(GROUPS) do
            local group_icon = tostring(group_id):addIcon(self:getGroupIcon(category_id, group_id), self:getCategoryColor(category_id))
            local text = L("GROUP_NAME", group_icon)
            group_submenu:insert(createItem("editbox", text, {
                maxChars    = self.CONST.GROUP_NAME_MAX_LENGTH,
                isMultiline = false,
                getFunc     = function() return GROUPS[group_id] end,
                setFunc     = function(val) GROUPS[group_id] = val:sanitize(self.CONST.GROUP_NAME_MAX_LENGTH) end,
                default     = self.defaults.groups[category_id][group_id],
            }))
        end

        addSubmenu(category_name, group_submenu, {
            custom_color = self:getCategoryColor(category_id),
            reference    = CONTROL_REF_TEMPLATE:format("GROUPS_EDIT", category_id),
        })
    end

    -- -------------------------
    --  @SECTION RETICLE MARKER
    -- -------------------------

    addItem("header", "RETICLE_MARKER", { custom_icon = true })
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
        for position, position_index in pairs(self.CONST.UI.RETICLE_MARKER.POSITION) do
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
        min        = self.CONST.UI.RETICLE_MARKER.MIN_OFFSET,
        max        = self.CONST.UI.RETICLE_MARKER.MAX_OFFSET,
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
        choices  = self.CONST.UI.FONT_STYLE,
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
        for title, size in pairs(self.CONST.UI.RETICLE_MARKER.ICON_SIZE) do
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

        local markers_info = self.getString("WARNING"):colorize(self.CONST.COLOR.WARNING) .. " " .. L("RETICLE_MARKER_ADDITIONAL_MARKERS_DESCRIPTION")
        markers_submenu:insert(createItem("description", markers_info))

        local marker_names = table:new(self.config.reticle.markers):keys()
        marker_names:sort()

        for _, marker_name in ipairs(marker_names) do
            local uname = marker_name:upper()
            local icon = (""):addIcon(self.CONST.ICONS.SOCIAL[uname])
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
            custom_icon      = self.CONST.ICONS.UI.CONFIG_PANEL.MARKERS,
            custom_icon_size = 28,
            disabled         = function() return not self.config.reticle.enabled end,
        })
    end


    -- ------------------------
    --  @SECTION NOTIFICATIONS
    -- ------------------------

    addItem("header", "NOTIFICATION", { custom_icon = true })

    do
        local channel_indexes = table:new()
        local channel_names   = table:new()
        for channel_name, channel_index in pairs(self.CONST.NOTIFICATION_CHANNELS) do
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

    addItem("header", "CHAT", { custom_icon = true })
    addItem("description", "CHAT_DESCRIPTION")

    -- Chat cache
    addItem("checkbox", "CHAT_CACHE", {
        getFunc = function() return self.config.chat.cache.enabled end,
        setFunc = function(val)
            self.config.chat.cache.enabled = val
            self.Chat.cache:Toggle(val)
        end,
        default = self.defaults.chat.cache.enabled,
    })
    addItem("slider", "CHAT_CACHE_SIZE", {
        min        = self.CONST.CHAT.CACHE.MIN_SIZE,
        max        = self.CONST.CHAT.CACHE.MAX_SIZE,
        step       = 10,
        clampInput = false,
        getFunc    = function() return self.config.chat.cache.maxsize end,
        setFunc    = function(val)
            self.config.chat.cache.maxsize = val
            self.Chat.cache:SetMaxSize(val)
        end,
        disabled   = function() return not self.config.chat.cache.enabled end,
        default    = self.defaults.chat.cache.maxsize,
    })

    -- Chat blocking submenu
    do
        local chat_block_submenu = table:new()
        chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_GROUPS"))
        chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_GROUPS_DESCRIPTION"))

        -- Contact' groups
        local GROUPS = self.config.groups[self.CONST.CONTACTS_VILLAINS_ID]
        local category_color = self:getCategoryColor(self.CONST.CONTACTS_VILLAINS_ID)
        for group_id, group_name in ipairs(GROUPS) do
            local group_icon = self:getGroupIcon(self.CONST.CONTACTS_VILLAINS_ID, group_id)
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
        local chat_channels = self.CONST.CHAT.CHANNELS
        for channel_name, _ in pairs(chat_channels) do
            chat_block_submenu:insert(createItem("checkbox", "CHAT_BLOCK_CHANNEL_" .. channel_name:upper(), {
                getFunc = function() return self.config.chat.block_channels[channel_name] end,
                setFunc = function(val) self.config.chat.block_channels[channel_name] = val end,
                default = self.defaults.chat.block_channels[channel_name],
            }))
        end

        addSubmenu("CHAT_BLOCK", chat_block_submenu, {
            custom_icon  = true,
            custom_color = self.CONST.COLOR.DANGER,
        })
    end

    addItem("checkbox", "CHAT_INFO", {
        getFunc = function() return not self.config.chat.log end,
        setFunc = function(val) self.config.chat.log = not val end,
        default = self.defaults.chat.log,
    })

    -- -----------------
    --  @SECTION IMPORT
    -- -----------------

    addItem("header", "IMPORT", { custom_icon = true })

    do
        local category_ref = {
            [self.CONST.CONTACTS_FRIENDS_ID]  = "FRIENDS",
            [self.CONST.CONTACTS_VILLAINS_ID] = "VILLAINS"
        }
        local category_counter = {
            [self.CONST.CONTACTS_FRIENDS_ID]  = GetNumFriends,
            [self.CONST.CONTACTS_VILLAINS_ID] = GetNumIgnored,
        }

        for category_id, _ in ipairs(self.CONST.CONTACTS_CATEGORIES) do
            local groups_list                = self:getGroupsList(category_id, true, true)
            local group_ids                  = groups_list:keys()
            local group_names                = groups_list:values()
            local category_ref_name          = category_ref[category_id]

            import_target_group[category_id] = 1

            addItem("description", "IMPORT_" .. category_ref_name)
            addItem("dropdown", "IMPORT_DESTINATION", {
                choices       = group_names,
                choicesValues = group_ids,
                sort          = "numericvalue-up",
                scrollable    = 7,
                getFunc       = function() return import_target_group[category_id] end,
                setFunc       = function(val) import_target_group[category_id] = val end,
                default       = 1,
                reference     = CONTROL_REF_TEMPLATE:format("IMPORT_GROUP_SELECT", category_id),
            })
            addItem("button", "IMPORT_BUTTON", {
                func = function()
                    self:ShowDialog(
                        self.CONST.UI.DIALOGS["CONFIRM_IMPORT_" .. category_ref_name],
                        nil,
                        import_target_group[category_id]
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

    -- ----------------
    --  @SECTION Reset
    -- ----------------

    -- handle reset to defaults settings
    panel_data.resetFunc = function()
        changed_colors = table:new()
        changed_groups = table:new()

        --groups_editor_selected_id = 0

        for i, _ in ipairs(import_target_group) do
            import_target_group[i] = 1
        end
    end

    CM:RegisterCallback("LAM-PanelClosed", function(panel)
        if (panel ~= self.UI.SettingsPanel) then return end

        --[[
        for _, category_id in ipairs(changed_groups) do
            self:RefreshContactGroups(category_id)
            changed_colors:removeElem(category_id) -- prevent double refresh
        end

        for _, category_id in ipairs(changed_colors) do
            self:RefreshContactGroups(category_id)
        end
        ]]

        -- reset registered changes
        changed_colors = table:new()
        changed_groups = table:new()
    end)

    -- ---------------
    --  @SECTION Init
    -- ---------------

    self.UI.SettingsPanel = LAM:RegisterAddonPanel(self.__namespace .. "_Config", panel_data)
    LAM:RegisterOptionControls(self.__namespace .. "_Config", config_data)
end
