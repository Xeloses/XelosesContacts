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
        -- website             = self.url,
        -- feedback            = self.url .. "#feedback",
        -- donation            = self.url .. "#donate",
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

    local function L(str, ...)
        return F(self.getString("SETTINGS_" .. str), ...)
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
        if (params) then
            if (params.tooltip) then
                params.tooltip = (T(params.tooltip) == "boolean") and L(text .. "_TOOLTIP") or (T(params.tooltip) == "string") and L(params.tooltip) or nil
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

    local function addSubmenu(title, submenu)
        if (not title or T(title) ~= "string" or title == "" or not submenu or T(submenu) ~= "table" or #submenu == 0) then return end
        config_data:insert({ type = "submenu", name = (title:match("[A-Z_]+") == title) and L(title) or title, controls = submenu })
    end

    -- ------------------
    --  @SECTION GENERAL
    -- ------------------
    addItem("header", "GENERAL")

    addItem("checkbox", "UI_SEARCH_NOTE", {
        tooltip = true,
        getFunc = function()
            return self.config.ui.search_note
        end,
        setFunc = function(val)
            self.config.ui.search_note = val
        end,
        default = self.defaults.ui.search_note,
    })

    -- -----------------
    --  @SECTION COLORS
    -- -----------------
    addItem("header", "COLORS")
    addItem("description", "COLORS_DESCRIPTION")

    for category_id, category_name in ipairs(CONST.CONTACTS_CATEGORIES) do
        addItem("colorpicker", L("COLOR", category_name), {
            getFunc = function()
                return getColor(category_id)
            end,
            setFunc = function(r, g, b, a)
                setColor(category_id, r, g, b, a)
            end,
            default = function()
                return ZO_ColorDef:New(self.defaults.colors[category_id])
            end,
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
                maxChars = CONST.GROUP_NAME_MAX_LENGTH,
                isMultiline = false,
                getFunc = function()
                    return GROUPS[group_id]
                end,
                setFunc = function(val)
                    GROUPS[group_id] = val:sanitize(CONST.GROUP_NAME_MAX_LENGTH)
                end,
                default = self.defaults.groups[category_id][group_id],
            }))
        end
        addSubmenu(category_name, group_submenu)
    end

    -- ------------------------
    --  @SECTION NOTIFICATIONS
    -- ------------------------
    addItem("header", "NOTIFICATION")

    do
        local channel_indexes = table:new()
        local channel_names = table:new()
        for channel_name, channel_index in pairs(CONST.NOTIFICATION_CHANNELS) do
            channel_names:insert(L("NOTIFICATION_CHANNEL_OPTION_" .. channel_name))
            channel_indexes:insert(channel_index)
        end
        addItem("dropdown", "NOTIFICATION_CHANNEL", {
            tooltip = true,
            choices = channel_names,
            choicesValues = channel_indexes,
            getFunc = function()
                return self.config.notifications.channel
            end,
            setFunc = function(val)
                self.config.notifications.channel = val
            end,
            default = self.defaults.notifications.channel,
        })
    end
    addItem("divider")

    addItem("checkbox", "CONFIRM_ADD_FRIEND", {
        tooltip = true,
        getFunc = function()
            return self.config.confirmation.friend
        end,
        setFunc = function(val)
            self.config.confirmation.friend = val
            self:UpdateHook("AddFriend")
        end,
        default = self.defaults.confirmation.friend,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_FRIEND_INVITE", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.friendInvite.enabled
        end,
        setFunc = function(val)
            self.config.notifications.friendInvite.enabled = val
            self:UpdateHook("IncomingFriendInvite")
        end,
        default = self.defaults.notifications.friendInvite.enabled,
    })
    addItem("checkbox", "NOTIFICATION_FRIEND_INVITE_SCREEN", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.friendInvite.announce
        end,
        setFunc = function(val)
            self.config.notifications.friendInvite.announce = val
        end,
        disabled = function()
            return not self.config.notifications.friendInvite.enabled or self.config.notifications.friendInvite.decline
        end,
        default = self.defaults.notifications.friendInvite.announce,
    })
    addItem("checkbox", "AUTODECLINE_FRIEND_INVITE", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.friendInvite.decline
        end,
        setFunc = function(val)
            self.config.notifications.friendInvite.decline = val
        end,
        default = self.defaults.notifications.friendInvite.decline,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_GROUP_INVITE", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupInvite.enabled
        end,
        setFunc = function(val)
            self.config.notifications.groupInvite.enabled = val
            self:UpdateHook("IncomingGroupInvite")
        end,
        default = self.defaults.notifications.groupInvite.enabled,
    })
    addItem("checkbox", "NOTIFICATION_GROUP_INVITE_SCREEN", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupInvite.announce
        end,
        setFunc = function(val)
            self.config.notifications.groupInvite.announce = val
        end,
        disabled = function()
            return not self.config.notifications.groupInvite.enabled or self.config.notifications.groupInvite.decline
        end,
        default = self.defaults.notifications.groupInvite.announce,
    })
    addItem("checkbox", "AUTODECLINE_GROUP_INVITE", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupInvite.decline
        end,
        setFunc = function(val)
            self.config.notifications.groupInvite.decline = val
        end,
        default = self.defaults.notifications.groupInvite.decline,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_GROUP_JOIN", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupJoin.enabled
        end,
        setFunc = function(val)
            self.config.notifications.groupJoin.enabled = val
            self:UpdateHook("GroupChange")
        end,
        default = self.defaults.notifications.groupJoin.enabled,
    })
    addItem("checkbox", "NOTIFICATION_GROUP_JOIN_SCREEN", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupJoin.announce
        end,
        setFunc = function(val)
            self.config.notifications.groupJoin.announce = val
        end,
        disabled = function()
            return not self.config.notifications.groupJoin.enabled
        end,
        default = self.defaults.notifications.groupJoin.announce,
    })
    addItem("divider")

    addItem("checkbox", "NOTIFICATION_GROUP_MEMBER", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupMember.enabled
        end,
        setFunc = function(val)
            self.config.notifications.groupMember.enabled = val
            self:UpdateHook("GroupChange")
        end,
        default = self.defaults.notifications.groupMember.enabled,
    })
    addItem("checkbox", "NOTIFICATION_GROUP_MEMBER_SCREEN", {
        tooltip = true,
        getFunc = function()
            return self.config.notifications.groupMember.announce
        end,
        setFunc = function(val)
            self.config.notifications.groupMember.announce = val
        end,
        disabled = function()
            return not self.config.notifications.groupMember.enabled
        end,
        default = self.defaults.notifications.groupMember.announce,
    })

    -- ---------------
    --  @SECTION CHAT
    -- ---------------
    addItem("header", "CHAT")
    addItem("description", "CHAT_DESCRIPTION")

    -- Chat blocking submenu
    local chat_block_submenu = table:new()
    chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_GROUPS"))
    chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_GROUPS_DESCRIPTION"))

    do
        local GROUPS = self.config.groups[CONST.CONTACTS_VILLAINS_ID]
        local category_color = self:getCategoryColor(CONST.CONTACTS_VILLAINS_ID)
        for group_id, group_name in ipairs(GROUPS) do
            local group_icon = self:getGroupIcon(CONST.CONTACTS_VILLAINS_ID, group_id)
            local text = F(L("CHAT_BLOCK_GROUP"), (""):addIcon(group_icon, category_color), group_name)
            chat_block_submenu:insert(createItem("checkbox", text, {
                tooltip = "CHAT_BLOCK_GROUP_TOOLTIP",
                getFunc = function()
                    return self.config.chat.block_groups[group_id]
                end,
                setFunc = function(val)
                    self.config.chat.block_groups[group_id] = val
                end,
                default = self.defaults.chat.block_groups[group_id],
            }))
        end
    end

    chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_CHANNELS"))
    chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_CHANNELS_DESCRIPTION"))

    do
        local chat_channels = CONST.CHAT.CHANNELS
        for channel_name, _ in pairs(chat_channels) do
            chat_block_submenu:insert(createItem("checkbox", "CHAT_BLOCK_CHANNEL_" .. channel_name:upper(), {
                getFunc = function()
                    return self.config.chat.block_channels[channel_name]
                end,
                setFunc = function(val)
                    self.config.chat.block_channels[channel_name] = val
                end,
                default = self.defaults.chat.block_channels[channel_name],
            }))
        end
    end

    addSubmenu("CHAT_BLOCK", chat_block_submenu)

    addItem("checkbox", "CHAT_INFO", {
        tooltip = true,
        getFunc = function()
            return not self.config.chat.log
        end,
        setFunc = function(val)
            self.config.chat.log = not val
        end,
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
        tooltip = true,
        choices = groups_list:values(),
        choicesValues = groups_list:keys(),
        getFunc = function()
            return import_target_friends
        end,
        setFunc = function(val)
            import_target_friends = val
        end,
        default = 1,
    })
    addItem("button", "IMPORT_BUTTON", {
        func = function()
            self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_IMPORT_FRIENDS, nil, import_target_friends)
        end,
        disabled = function()
            return self.processing or (GetNumFriends() == 0)
        end,
    })
    addItem("divider")

    -- Import Ignored
    groups_list = self:getGroupsList(CONST.CONTACTS_VILLAINS_ID, true, true)

    addItem("description", "IMPORT_IGNORED")
    addItem("dropdown", "IMPORT_DESTINATION", {
        tooltip = true,
        choices = groups_list:values(),
        choicesValues = groups_list:keys(),
        getFunc = function()
            return import_target_villains
        end,
        setFunc = function(val)
            import_target_villains = val
        end,
        default = 1,
    })
    addItem("button", "IMPORT_BUTTON", {
        func = function()
            self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_IMPORT_IGNORED, nil, import_target_villains)
        end,
        disabled = function()
            return self.processing or (GetNumIgnored() == 0)
        end,
    })

    self.UI.SettingsPanel = LAM:RegisterAddonPanel(self.__namespace .. "_Config", panel_data)
    LAM:RegisterOptionControls(self.__namespace .. "_Config", config_data)
end
