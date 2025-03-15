local LAM = LibAddonMenu2
local F   = XelosesContacts.formatString
local T   = type

local __panel

function XelosesContacts:OpenSettings()
    LAM:OpenToPanel(__panel)
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

    local CONTROL_REF_TEMPLATE = self.__prefix .. "LAM_%s"

    local groups_editor_data   = {
        selected_category = self.CONST.CONTACTS_FRIENDS_ID,
        selected_group = 0,
    }

    local import_target_group  = {}

    local changed_colors       = table:new()
    local changed_groups       = table:new()

    local __initialized        = false

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
            hex_color = "EEEEEE"
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

    -- ---------------------------------
    --  @SECTION <LAM Controls: Create>
    -- ---------------------------------

    --[[
        Service functions below utilizes custom field ITEM_DATA.customData :
            customData.color     : String         = "HEX color"            -- text color
            customData.icon      : String|Boolean = "/path/to/texture.dds" -- icon to be placed before text or
                                                                              boolean indicates icon should be taken from CONST data table
            customData.iconSize : Number         = 24                      -- specify size of icon (optional)
            customData.postInit : Boolean        = true                    -- flag indcates component requires post-initialization
    ]]
    local function formatItemText(item_data, text)
        local error_str = "<<MISSING_STRING>>"
        if (not text) then
            if (item_data.customData and item_data.customData.name) then
                text = item_data.customData.name
            else
                return error_str
            end
        end

        local result = text:match("[^A-Z0-9_]+") and text or L(text)
        if (not result) then return error_str end

        if (not item_data.customData) then
            item_data.customData = {}
        end
        if (not item_data.customData.name) then
            item_data.customData.name = text
        end

        if (T(item_data.customData) == "table") then
            if (T(item_data.customData.color) == "string") then
                result = result:colorize(item_data.customData.color)
            end

            if (item_data.customData.icon) then
                if (T(item_data.customData.icon) == "boolean") then
                    item_data.customData.icon = self.CONST.ICONS.UI.CONFIG_PANEL[item_data.customData.name]
                end

                if (T(item_data.customData.icon) == "string") then
                    if (not item_data.customData.iconSize or T(item_data.customData.iconSize) ~= "number") then
                        item_data.customData.iconSize = (item_data.type == "header" or item_data.type == "submenu") and ICON_SIZE_HEADER or ICON_SIZE_TEXT
                    end

                    result = result:addIcon(item_data.customData.icon, item_data.customData.color, item_data.customData.iconSize, true)
                else
                    item_data.customData.icon     = nil
                    item_data.customData.iconSize = nil
                end
            end
        end

        return result
    end

    -- create control's data structure
    local function createItem(item_type, text, params, custom_params)
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
                    if (params.isDangerous) then
                        warn = "\n\n" .. warn:colorize(self.CONST.COLOR.DANGER)
                    end
                    params.warning = self.getString("WARNING"):colorize(self.CONST.COLOR.WARNING) .. " " .. warn
                end
            end

            for key, val in pairs(params) do
                item[key] = val
            end
        end

        if (T(custom_params) == "table") then
            if (not item.customData) then item.customData = {} end

            for key, val in pairs(custom_params) do
                item.customData[key] = val
            end
        end

        if (item.customData and item.customData.postInit) then
            if (item.disabled ~= nil and T(item.disabled) == "function") then
                item.customData.fn_disabled = item.disabled -- store "disabled" callback function
            end

            item.disabled = true -- temporary disable control if it requires post-initialization
        end

        if (item_type == "dropdown") then
            if (item.choices == nil) then
                item.choices       = {}
                item.choicesValues = {}
            end
        elseif (item_type == "iconpicker") then
            if (item.choices == nil) then
                item.choices = {}
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
    local function addItem(item_type, text_id, params, custom_params)
        config_data:insert(createItem(item_type, text_id, params, custom_params))
    end

    -- create control and add it to the submenu
    local function addSubmenuItem(submenu, item_type, text_id, params, custom_params)
        submenu:insert(createItem(item_type, text_id, params, custom_params))
    end

    -- create submenu and add it to the panel
    local function addSubmenu(title, submenu, params, custom_params)
        if (not params) then params = {} end
        params.controls = submenu

        addItem("submenu", title, params, custom_params)
    end

    -- ---------------------------------
    --  @SECTION <LAM Controls: Manage>
    -- ---------------------------------

    -- get control by reference name
    local function getLAMControl(control_ref_name)
        local control_name = CONTROL_REF_TEMPLATE:format(control_ref_name)
        return WINDOW_MANAGER:GetControlByName(control_name)
    end

    -- ----------------
    --  Dropdown lists

    -- reset selection in dropdown lists
    local function resetSelection(control_ref_name)
        local control = getLAMControl(control_ref_name)
        if (control) then
            control:UpdateValue(true) -- reset value
        end
    end

    local function updateDropdownList(control_ref_name, choices_list, choices_values_list)
        local control = getLAMControl(control_ref_name)
        if (control) then
            control.data.choices       = choices_list
            control.data.choicesValues = choices_values_list
            control:UpdateChoices()

            if (__initialized and control.data.customData.postInit) then
                control.data.customData.postInit = false

                if (control.data.customData.fn_disabled) then
                    control.data.disabled = control.data.customData.fn_disabled -- restore "disabled" callback
                else
                    control.data.disabled = false                               -- undo temporary "disabled" state
                end

                control:UpdateDisabled() -- update control state
            end

            control:UpdateValue() -- reload selected value
        end
    end

    -- refresh (reload) contact category selection dropdown lists
    local function refreshCategorySelectionControls()
        local category_list  = self:getCategoryList(true)
        local category_ids   = category_list:keys()
        local category_names = category_list:values()

        local controls       = {
            "GENERAL_SELECT_CATEGORY",
            "GROUPS_EDIT_SELECT_CATEGORY",
        }

        for _, control_name in ipairs(controls) do
            updateDropdownList(control_name, category_names, category_ids)
        end
    end

    -- refresh (reload) contact group selection dropdown lists
    local function refreshGroupSelectionControls(category_id, control_ref_name)
        if (not category_id) then
            category_id = groups_editor_data.selected_category
        end

        local groups_list  = self:getGroupsList(category_id, true, true)
        local groups_ids   = groups_list:keys()
        local groups_names = groups_list:values()

        if (control_ref_name and T(control_ref_name) == "string") then
            -- refresh only one specific control
            updateDropdownList(control_ref_name, groups_names, groups_ids)
        else
            -- refresh all group selection controls
            if (groups_editor_data.selected_category == category_id) then
                updateDropdownList("GROUPS_EDIT_SELECT_GROUP", groups_names, groups_ids)
            end

            local controls = {
                "IMPORT_GROUP_SELECT_%d",
            }

            for _, control_name in ipairs(controls) do
                updateDropdownList(control_name:format(category_id), groups_names, groups_ids)
            end
        end
    end

    -- --------
    --  Colors

    -- refresh/update colorized controls
    local function updateControlColor(control_ref_name)
        local control = getLAMControl(control_ref_name)
        if (control) then
            local category_id = groups_editor_data.selected_category
            local hex_color   = self:getCategoryColor(category_id)

            if (control.data.hexColor ~= hex_color) then -- prevent unnecessary updates
                local color           = ZO_ColorDef:New(hex_color)
                control.data.hexColor = hex_color

                if (control.data.defaultColor) then
                    control.data.defaultColor = color
                end

                if (T(control.data.disabled) == "function" and control.data.disabled()) then return end -- prevent refreshing of disabled control

                control:SetColor(color)
            end
        end
    end

    local function refreshColors(category_id)
        refreshCategorySelectionControls()
        refreshGroupSelectionControls(category_id)

        local controls = {
            "GROUPS_EDIT_ICON",
        }

        for _, control_name in ipairs(controls) do
            updateControlColor(control_name:format(category_id))
        end
    end

    -- --------------------------
    --  @SECTION <Groups Editor>
    -- --------------------------

    local function GroupsEditor_SelectCategory(category_id)
        groups_editor_data.selected_category = category_id
        groups_editor_data.selected_group = 0

        refreshGroupSelectionControls(category_id, "GROUPS_EDIT_SELECT_GROUP")
    end

    local function GroupsEditor_SelectGroup(group_id)
        groups_editor_data.selected_group = group_id

        if (group_id > 0) then
            updateControlColor("GROUPS_EDIT_ICON")
        end
    end

    local function GroupsEditor_CreateGroup()
        local c_id = groups_editor_data.selected_category

        local g = self:CreateGroup(c_id)
        registerGroupChanges(c_id)

        refreshGroupSelectionControls(c_id)
        GroupsEditor_SelectGroup(g.id)
    end

    local function GroupsEditor_RemoveGroup()
        local c_id = groups_editor_data.selected_category

        self:RemoveGroup(c_id, groups_editor_data.selected_group)
        registerGroupChanges(c_id)

        GroupsEditor_SelectGroup(0)
        refreshGroupSelectionControls(c_id)
    end

    local function GroupsEditor_UpdateGroup(data)
        local c_id = groups_editor_data.selected_category
        local g_id = groups_editor_data.selected_group

        local i = self:getGroupIndexByID(c_id, g_id)
        if (not i) then return end

        local GROUP = self.config.groups[c_id][i]
        for k, v in pairs(data) do
            GROUP[k] = v
        end

        if (data.name or data.icon) then
            refreshGroupSelectionControls(c_id) -- refresh group selection controls only if group name or icon was changed
            registerGroupChanges(c_id)          -- register changes for external updates only if group name or icon was changed
        end
    end

    -- ------------------
    --  @SECTION GENERAL
    -- ------------------

    addItem("header", "GENERAL", nil, { icon = true })

    addItem("checkbox", "UI_SEARCH_NOTE", {
        getFunc = function() return self.config.ui.search_note end,
        setFunc = function(val) self.config.ui.search_note = val end,
        default = self.defaults.ui.search_note,
    })

    addItem("dropdown", "DEFAULT_CATEGORY", {
        sort       = "numericvalue-up",
        getFunc    = function() return self.config.default_category end,
        setFunc    = function(val) self.config.default_category = val end,
        default    = self.CONST.CONTACTS_FRIENDS_ID,
        reference  = CONTROL_REF_TEMPLATE:format("GENERAL_SELECT_CATEGORY"),
        customData = {
            postInit     = true,
            disableReset = true,
        },
    })

    -- -----------------
    --  @SECTION COLORS
    -- -----------------

    addItem("header", "COLORS", nil, { icon = true })
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

    addItem("header", "GROUPS", nil, { icon = true })
    addItem("description", "GROUPS_DESCRIPTION")

    -- Category & Group selector
    addItem("dropdown", "GROUPS_SELECT_CATEGORY", {
        width      = "half",
        sort       = "numericvalue-up",
        getFunc    = function() return groups_editor_data.selected_category end,
        setFunc    = GroupsEditor_SelectCategory,
        default    = self.CONST.CONTACTS_FRIENDS_ID,
        reference  = CONTROL_REF_TEMPLATE:format("GROUPS_EDIT_SELECT_CATEGORY"),
        customData = {
            postInit = true,
        },
    })

    addItem("dropdown", "GROUPS_SELECT_GROUP", {
        width      = "half",
        sort       = "numericvalue-up",
        scrollable = 7,
        getFunc    = function() return groups_editor_data.selected_group end,
        setFunc    = GroupsEditor_SelectGroup,
        default    = 0,
        reference  = CONTROL_REF_TEMPLATE:format("GROUPS_EDIT_SELECT_GROUP"),
        customData = {
            postInit = true,
        },
    })

    -- Manage group buttons
    addItem("button", "GROUPS_BUTTON_ADD", {
        width    = "half",
        func     = GroupsEditor_CreateGroup,
        disabled = function()
            return
                self.processing or
                self:getGroupsCount(groups_editor_data.selected_category) >= self.CONST.CONTACT_GROUPS_MAX -- limit groups amount
        end,
    })
    addItem("button", "GROUPS_BUTTON_REMOVE", {
        width       = "half",
        func        = GroupsEditor_RemoveGroup,
        isDangerous = true,
        disabled    = function()
            return
                self.processing or
                groups_editor_data.selected_group <= self.CONST.CONTACT_GROUPS_PREDEFINDED -- disallow removing for predefined groups
        end,
    })

    addItem("description", L("GROUPS_NOTE"), nil, {
        icon  = self.CONST.ICONS.UI.NOTE,
        color = self.CONST.COLOR.NOTE,
    })
    addItem("divider")

    -- Selected group editor
    addItem("editbox", "GROUPS_EDIT_NAME", {
        maxChars    = self.CONST.GROUP_NAME_MAX_LENGTH,
        isMultiline = false,
        getFunc     = function()
            return
                (groups_editor_data.selected_group > 0) and
                self:getGroupName(groups_editor_data.selected_category, groups_editor_data.selected_group) or
                ""
        end,
        setFunc     = function(val) GroupsEditor_UpdateGroup({ name = val:sanitize(self.CONST.GROUP_NAME_MAX_LENGTH) }) end,
        disabled    = function() return groups_editor_data.selected_group == 0 end,
        default     = "",
    })
    addItem("iconpicker", "GROUPS_EDIT_ICON", {
        choices     = self.CONST.ICONS.LIST,
        iconSize    = 36,
        maxColumns  = 6,
        visibleRows = 4.5,
        getFunc     = function()
            return
                (groups_editor_data.selected_group > 0) and
                self:getGroupIcon(groups_editor_data.selected_category, groups_editor_data.selected_group) or
                self.CONST.ICONS.LIST[1]
        end,
        setFunc     = function(val) GroupsEditor_UpdateGroup({ icon = val }) end,
        disabled    = function() return groups_editor_data.selected_group == 0 end,
        reference   = CONTROL_REF_TEMPLATE:format("GROUPS_EDIT_ICON"),
    })
    addItem("checkbox", "GROUPS_EDIT_BLOCK_CHAT", {
        getFunc = function()
            return
                (groups_editor_data.selected_category == self.CONST.CONTACTS_VILLAINS_ID) and
                (groups_editor_data.selected_group > 0) and
                self:isChatBlockedForGroup(groups_editor_data.selected_group) or
                false
        end,
        setFunc = function(val) GroupsEditor_UpdateGroup({ mute = val }) end,
        disabled = function()
            return
                groups_editor_data.selected_category ~= self.CONST.CONTACTS_VILLAINS_ID or
                groups_editor_data.selected_group == 0
        end,
        default = true,
    })

    -- ------------------------
    --  @SECTION CONTEXT MENU
    -- ------------------------

    addItem("header", "CONTEXT_MENU", nil, { icon = true })

    addItem("checkbox", "CONTEXT_MENU_TOGGLE", {
        getFunc = function() return self.config.contextmenu.enabled end,
        setFunc = function(val) self.config.contextmenu.enabled = val end,
        default = self.defaults.contextmenu.enabled,
    })

    addItem("checkbox", "CONTEXT_MENU_SUBMENU", {
        getFunc  = function() return self.config.contextmenu.submenu end,
        setFunc  = function(val) self.config.contextmenu.submenu = val end,
        disabled = function() return not self.config.contextmenu.enabled end,
        default  = self.defaults.contextmenu.submenu,
    })

    -- ---------------
    --  @SECTION CHAT
    -- ---------------

    addItem("header", "CHAT", nil, { icon = true })
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

        -- Chat channels
        chat_block_submenu:insert(createItem("header", "CHAT_BLOCK_CHANNELS"))
        chat_block_submenu:insert(createItem("description", "CHAT_BLOCK_CHANNELS_DESCRIPTION"))

        local chat_channels = self.CONST.CHAT.CHANNELS
        for channel_name, _ in pairs(chat_channels) do
            addSubmenuItem(chat_block_submenu, "checkbox", "CHAT_BLOCK_CHANNEL_" .. channel_name:upper(), {
                getFunc = function() return self.config.chat.block_channels[channel_name] end,
                setFunc = function(val) self.config.chat.block_channels[channel_name] = val end,
                default = self.defaults.chat.block_channels[channel_name],
            })
        end

        addSubmenu("CHAT_BLOCK", chat_block_submenu, nil, {
            icon  = true,
            color = self.CONST.COLOR.DANGER,
        })
    end

    addItem("checkbox", "CHAT_INFO", {
        getFunc = function() return not self.config.chat.log end,
        setFunc = function(val) self.config.chat.log = not val end,
        default = self.defaults.chat.log,
    })

    -- ------------------------
    --  @SECTION NOTIFICATIONS
    -- ------------------------

    addItem("header", "NOTIFICATION", nil, { icon = true })

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

    do
        local notifications_submenu = table:new()

        -- Confirm adding Villain to ESO ingame friends
        addSubmenuItem(notifications_submenu, "checkbox", "CONFIRM_ADD_FRIEND", {
            getFunc = function() return self.config.confirmation.friend end,
            setFunc = function(val)
                self.config.confirmation.friend = val
                self:ToggleHook("AddFriend")
            end,
            default = self.defaults.confirmation.friend,
        })
        addSubmenuItem(notifications_submenu, "divider")

        -- Friend invite fron Villain
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_FRIEND_INVITE", {
            getFunc = function() return self.config.notifications.friendInvite.enabled end,
            setFunc = function(val)
                self.config.notifications.friendInvite.enabled = val
                self:ToggleHook("IncomingFriendInvite")
            end,
            default = self.defaults.notifications.friendInvite.enabled,
        })
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_SCREEN_WARNING", {
            width    = "half",
            getFunc  = function() return self.config.notifications.friendInvite.announce end,
            setFunc  = function(val) self.config.notifications.friendInvite.announce = val end,
            disabled = function() return not self.config.notifications.friendInvite.enabled or self.config.notifications.friendInvite.decline end,
            default  = self.defaults.notifications.friendInvite.announce,
        })
        addSubmenuItem(notifications_submenu, "checkbox", "AUTODECLINE_FRIEND_INVITE", {
            width   = "half",
            getFunc = function() return self.config.notifications.friendInvite.decline end,
            setFunc = function(val) self.config.notifications.friendInvite.decline = val end,
            default = self.defaults.notifications.friendInvite.decline,
        })
        addSubmenuItem(notifications_submenu, "divider")

        -- Group invite fron Villain
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_GROUP_INVITE", {
            getFunc = function() return self.config.notifications.groupInvite.enabled end,
            setFunc = function(val)
                self.config.notifications.groupInvite.enabled = val
                self:ToggleHook("IncomingGroupInvite")
            end,
            default = self.defaults.notifications.groupInvite.enabled,
        })
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_SCREEN_WARNING", {
            width    = "half",
            getFunc  = function() return self.config.notifications.groupInvite.announce end,
            setFunc  = function(val) self.config.notifications.groupInvite.announce = val end,
            disabled = function() return not self.config.notifications.groupInvite.enabled or self.config.notifications.groupInvite.decline end,
            default  = self.defaults.notifications.groupInvite.announce,
        })
        addSubmenuItem(notifications_submenu, "checkbox", "AUTODECLINE_GROUP_INVITE", {
            width   = "half",
            getFunc = function() return self.config.notifications.groupInvite.decline end,
            setFunc = function(val) self.config.notifications.groupInvite.decline = val end,
            default = self.defaults.notifications.groupInvite.decline,
        })
        addSubmenuItem(notifications_submenu, "divider")

        -- Join existing group with Villain
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_GROUP_JOIN", {
            getFunc = function() return self.config.notifications.groupJoin.enabled end,
            setFunc = function(val)
                self.config.notifications.groupJoin.enabled = val
                self:ToggleHook("GroupChange")
            end,
            default = self.defaults.notifications.groupJoin.enabled,
        })
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_SCREEN_WARNING", {
            width    = "half",
            getFunc  = function() return self.config.notifications.groupJoin.announce end,
            setFunc  = function(val) self.config.notifications.groupJoin.announce = val end,
            disabled = function() return not self.config.notifications.groupJoin.enabled end,
            default  = self.defaults.notifications.groupJoin.announce,
        })
        addSubmenuItem(notifications_submenu, "divider")

        -- Villain joins player's group
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_GROUP_MEMBER", {
            getFunc = function() return self.config.notifications.groupMember.enabled end,
            setFunc = function(val)
                self.config.notifications.groupMember.enabled = val
                self:ToggleHook("GroupChange")
            end,
            default = self.defaults.notifications.groupMember.enabled,
        })
        addSubmenuItem(notifications_submenu, "checkbox", "NOTIFICATION_SCREEN_WARNING", {
            width    = "half",
            getFunc  = function() return self.config.notifications.groupMember.announce end,
            setFunc  = function(val) self.config.notifications.groupMember.announce = val end,
            disabled = function() return not self.config.notifications.groupMember.enabled end,
            default  = self.defaults.notifications.groupMember.announce,
        })

        addSubmenu("NOTIFICATION_SETUP", notifications_submenu)
    end

    -- -------------------------
    --  @SECTION RETICLE MARKER
    -- -------------------------

    addItem("header", "RETICLE_MARKER", nil, { icon = true })
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
            addSubmenuItem(markers_submenu, "divider")
            addSubmenuItem(markers_submenu, "checkbox", text, {
                tooltip = "RETICLE_MARKER_ADDITIONAL_" .. uname .. "_TOOLTIP",
                getFunc = function() return self.config.reticle.markers[marker_name].enabled end,
                setFunc = function(val) self.config.reticle.markers[marker_name].enabled = val end,
                disabled = function() return not self.config.reticle.enabled end,
                default = self.defaults.reticle.markers[marker_name].enabled,
            })
            addSubmenuItem(markers_submenu, "colorpicker", L("RETICLE_MARKER_ADDITIONAL_" .. uname .. "_COLOR"), {
                getFunc = function() return ColorFromHex(self.config.reticle.markers[marker_name].color) end,
                setFunc = function(r, g, b, a) self.config.reticle.markers[marker_name].color = ColorToHex(r, g, b, a) end,
                disabled = function() return not self.config.reticle.enabled or not self.config.reticle.markers[marker_name].enabled end,
                default = function() return ZO_ColorDef:New(self.defaults.reticle.markers[marker_name].color) end,
            })
        end

        addSubmenu("RETICLE_MARKER_ADDITIONAL_MARKERS", markers_submenu, nil, {
            icon     = self.CONST.ICONS.UI.CONFIG_PANEL.MARKERS,
            iconSize = 28,
            disabled = function() return not self.config.reticle.enabled end,
        })
    end

    -- -----------------
    --  @SECTION IMPORT
    -- -----------------

    addItem("header", "IMPORT", nil, { icon = true })

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
            import_target_group[category_id] = 1

            addItem("description", "IMPORT_" .. category_ref[category_id])
            addItem("dropdown", "IMPORT_DESTINATION", {
                sort       = "numericvalue-up",
                scrollable = 7,
                getFunc    = function() return import_target_group[category_id] end,
                setFunc    = function(val) import_target_group[category_id] = val end,
                default    = 1,
                reference  = CONTROL_REF_TEMPLATE:format("IMPORT_GROUP_SELECT_" .. tostring(category_id)),
                customData = {
                    postInit = true,
                },
            })
            addItem("button", "IMPORT_BUTTON", {
                func = function()
                    self:ShowDialog(
                        self.CONST.UI.DIALOGS["CONFIRM_IMPORT_" .. category_ref[category_id]],
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

        groups_editor_data.selected_category = self.CONST.CONTACTS_FRIENDS_ID
        groups_editor_data.selected_group = 0

        for i, _ in ipairs(import_target_group) do
            import_target_group[i] = 1
        end
    end

    -- ---------------
    --  @SECTION Init
    -- ---------------

    -- handle create settings panel controls
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        if (panel.data.name ~= self.name or __initialized) then return end
        __initialized = true

        refreshCategorySelectionControls()

        for i, _ in ipairs(self:getCategoryList()) do
            refreshGroupSelectionControls(i)
        end
    end)

    -- handle close settings panel
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if (panel.data.name ~= self.name) then return end
        -- or: if (panel.data.name ~= self.name) then return end

        for _, category_id in ipairs(changed_groups) do
            self:RefreshContactGroups(category_id)
            changed_colors:removeElem(category_id) -- prevent double refresh
        end

        for _, category_id in ipairs(changed_colors) do
            self:RefreshContactGroups(category_id)
        end

        -- reset registered changes
        changed_colors = table:new()
        changed_groups = table:new()
    end)

    __panel = LAM:RegisterAddonPanel(self.__namespace .. "_Config", panel_data)
    LAM:RegisterOptionControls(self.__namespace .. "_Config", config_data)
end
