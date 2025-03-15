local LEJ                                    = LibExtendedJournal

local L                                      = XelosesContacts.getString
local F                                      = XelosesContacts.formatString
local T                                      = type

XELOSES_CONTACTS_LIST_HEADER_HEIGHT          = 32
XELOSES_CONTACTS_LIST_CELL_HEIGHT            = 30
XELOSES_CONTACTS_LIST_CELL_PADDING           = 10
XELOSES_CONTACTS_LIST_ICON_SIZE              = 26
XELOSES_CONTACTS_LIST_ICON_SPACING           = 2
XELOSES_CONTACTS_LIST_ICON_PADDING           = XELOSES_CONTACTS_LIST_CELL_PADDING + XELOSES_CONTACTS_LIST_ICON_SPACING
XELOSES_CONTACTS_LIST_ICON_WIDTH             = XELOSES_CONTACTS_LIST_ICON_SIZE + (XELOSES_CONTACTS_LIST_ICON_SPACING * 2)
XELOSES_CONTACTS_LIST_BUTTON_SIZE            = 32
XELOSES_CONTACTS_LIST_BUTTON_SIZE_MINI       = XELOSES_CONTACTS_LIST_BUTTON_SIZE / 2

XELOSES_CONTACTS_LIST_COLUMN_ACCOUNT_WIDTH   = 170
XELOSES_CONTACTS_LIST_COLUMN_GROUP_WIDTH     = 150
XELOSES_CONTACTS_LIST_COLUMN_NOTE_WIDTH      = 350
XELOSES_CONTACTS_LIST_COLUMN_TIMESTAMP_WIDTH = 150
XELOSES_CONTACTS_LIST_CELL_GROUP_WIDTH       = XELOSES_CONTACTS_LIST_COLUMN_GROUP_WIDTH - XELOSES_CONTACTS_LIST_ICON_WIDTH

local DATA_TYPE                              = 1
local DEFAULT_SORT_ORDER                     = ZO_SORT_ORDER_UP

local SELF_INSTANCE
local CONST

-- ---------------
--  @SECTION Init
-- ---------------

XelosesContactsList                          = ExtendedJournalSortFilterList:Subclass()

function XelosesContactsList:New(parent_obj)
    CONST              = parent_obj.CONST -- store pointer to CONSTANTS table

    local list         = ExtendedJournalSortFilterList.New(self, XelosesContactsFrame, nil, parent_obj)

    list.index_columns = table:new({
        [1] = "Account",
        [2] = "Group",
        [3] = "Note",
        [4] = "Timestamp",
    })

    SELF_INSTANCE      = list -- store object instance to use in places where "self" is not available

    return list
end

function XelosesContactsList:Setup(parent)
    self.parent = parent
    self.CONST = parent.CONST

    ZO_ScrollList_AddDataType(self.list, DATA_TYPE, "XelosesContactsListRow", 30, function(...) self:SetupItemRow(...) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

    self:SetAlternateRowBackgrounds(true)
    self:SetEmptyText(L("UI_INFO_NO_CONTACTS"))

    local sort_keys       = {
        ["account"]   = { caseInsensitive = true },
        ["group"]     = { caseInsensitive = true, tiebreaker = "account", tieBreakerSortOrder = DEFAULT_SORT_ORDER },
        ["note"]      = { caseInsensitive = true, tiebreaker = "group", tieBreakerSortOrder = DEFAULT_SORT_ORDER },
        ["timestamp"] = { isNumeric = true },
    }
    self.currentSortKey   = "group"
    self.currentSortOrder = DEFAULT_SORT_ORDER
    self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)

    self.sortFunction = function(a, b)
        if (not self.initialized or not self:isShown()) then return end -- prevent unnecessary updates

        -- sort by Group name instead of Group ID
        local group_name_a = self.parent:getContactGroupName(a.data) or ""
        local group_name_b = self.parent:getContactGroupName(b.data) or ""
        local term_a = { account = a.data.account, group = group_name_a:upper(), note = a.data.note, timestamp = a.data.timestamp }
        local term_b = { account = b.data.account, group = group_name_b:upper(), note = b.data.note, timestamp = b.data.timestamp }

        return ZO_TableOrderingFunction(term_a, term_b, self.currentSortKey, sort_keys, self.currentSortOrder)
    end

    self.categoryID   = CONST.CONTACTS_FRIENDS_ID
    self.groupID      = 0

    self:InitContextMenu()
    self:InitKeybinds()
    self:SetupControls()

    self.initialized = true
end

function XelosesContactsList:SetupControls()
    self.UI = {
        list            = self.list or self.frame:GetNamedChild("List"),
        headers         = self.frame:GetNamedChild("Headers"),
        cbCategory      = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("CategoryFilter")),
        cbGroup         = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("GroupFilter")),
        searchBox       = self.frame:GetNamedChild("SearchFieldBox"),
        btnSearchReset  = self.frame:GetNamedChild("SearchReset"),
        btnAddContact   = self.frame:GetNamedChild("AddContact"),
        btnOpenSettings = self.frame:GetNamedChild("OpenSettings"),
        lbCountContacts = self.frame:GetNamedChild("CounterContacts"),
        lbCountFiltered = self.frame:GetNamedChild("CounterFiltered"),
    }

    self.UI.btnSearchReset:SetHidden(true)
    self.UI.lbCountFiltered:SetHidden(true)

    self.parent:SetControlTooltip(self.UI.btnAddContact, "UI_BTN_ADD_CONTACT_TOOLTIP")
    self.parent:SetControlTooltip(self.UI.btnOpenSettings, "UI_BTN_OPEN_SETTINGS_TOOLTIP")
    self.parent:SetControlTooltip(self.UI.btnSearchReset, "UI_BTN_SEARCH_RESET_TOOLTIP")

    self.UI.btnAddContact:SetHandler("OnClicked", function() self.parent:AddContact() end)
    self.UI.btnOpenSettings:SetHandler("OnClicked", function() self.parent:OpenSettings() end)
    self.UI.btnSearchReset:SetHandler("OnClicked", function() self:SearchReset() end)
    self.UI.searchBox:SetHandler("OnTextChanged", function() self:onSearchTextChanged() end)

    self:SetupCategoryList()
end

-- ----------------
--  @SECTION State
-- ----------------

function XelosesContactsList:Show()
    if (not self.initialized) then return end

    LEJ.Show(CONST.UI.TAB_NAME)
end

function XelosesContactsList:Hide()
    if (not self.initialized) then return end

    if (self:isShown()) then
        self:Toggle()
    end
end

function XelosesContactsList:Toggle()
    if (not self.initialized) then return end

    LEJ.Show(CONST.UI.TAB_NAME, true) -- second param of LEJ.Show() method is a "Toggle" flag
end

function XelosesContactsList:isShown()
    local _LEJ = LibExtendedJournalInternal
    return LEJ.IsTabActive(CONST.UI.TAB_NAME) and SCENE_MANAGER:IsShowing(_LEJ.SCENE_NAME)
end

-- ----------------------
--  @SECTION Master list
-- ----------------------

function XelosesContactsList:BuildMasterList()
    self.masterList = table:new()
    for name, data in pairs(self.parent.contacts) do
        local entry = {
            account   = name,
            category  = data.category,
            group     = data.group,
            timestamp = data.timestamp,
            note      = data.note,
        }
        self.masterList:insert(entry)
    end
end

function XelosesContactsList:RefreshList()
    self:RefreshData()
    self:RefreshContactsCounter()
end

-- ------------------------
--  @SECTION Category list
-- ------------------------

function XelosesContactsList:SetupCategoryList()
    local category_list = self.parent:getCategoryList(true)

    self:InitializeComboBox(
        self.UI.cbCategory,
        { list = category_list },
        self.categoryID,
        true,
        function(...)
            self:onCategorySelect(...)
        end
    )
end

function XelosesContactsList:getSelectedCategory()
    return self.categoryID or CONST.CONTACTS_FRIENDS_ID
end

function XelosesContactsList:SetSelectedCategory(category_id)
    if (not category_id) then return end

    local category_name = self.parent:getCategoryName(category_id, true)
    if (not category_name) then return end

    self.categoryID = category_id
    self:SetTitle(category_name)
    self:SetupGroupsList(category_id)
    self:UpdateKeybinds()
end

-- -----------------------
--  @SECTION Groups lists
-- -----------------------

function XelosesContactsList:SetupGroupsList(category_id)
    local groups_list = table:new()
    groups_list:insert({
        id = 0,
        label = "<" .. L("ALL") .. ">",
    })

    local gList = self.parent:getGroupsList(category_id, true, true)
    for gID, gName in ipairs(gList) do
        local entry = {
            id = gID,
            label = gName,
        }

        groups_list:insert(entry)
    end

    groups_list:sort(
        function(a, b)
            return a.id < b.id
        end
    )

    self:InitializeComboBox(
        self.UI.cbGroup,
        {
            list = groups_list,
            key = "label",
            dataKey = "id",
        },
        1,
        true,
        function(...)
            self:onGroupSelect(...)
        end
    )
end

function XelosesContactsList:RefreshGroupsList(category_id)
    if (not self.initialized or self.categoryID ~= category_id) then return end

    self:SetupGroupsList(self.categoryID)
end

function XelosesContactsList:getSelectedGroup()
    return self.groupID or 0
end

function XelosesContactsList:SetSelectedGroup(group_id)
    if (group_id ~= 0 and not self.parent:validateContactGroup(self.categoryID, group_id)) then return end

    self.groupID = group_id

    -- change sort order depends on current sort order and "Group" column visibility
    local sort
    if (group_id ~= 0 and self.currentSortKey == "group") then
        sort = "account"
    elseif (group_id == 0 and self.currentSortKey == "account") then
        sort = "group"
    end
    if (sort) then
        self.currentSortKey = sort
        self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
    end

    self:SetColumnVisibility("Group", self.groupID == 0) -- hide "Group" column if list was filtered by contact group
end

-- ----------------------
--  @SECTION UI controls
-- ----------------------

function XelosesContactsList:SetTitle(title)
    if (not title) then return end

    --[[
    local topBar = LibExtendedJournalInternal.controls.frame.menu
    if (not topBar) then return end

    local lbTitle = topBar and topBar:GetNamedChild("Label")
    ]]
    local lbTitle = LibExtendedJournalInternal.controls.subtitle
    if (not lbTitle) then return end

    lbTitle:SetText(title)
end

function XelosesContactsList:RefreshContactsCounter()
    local counter = self.parent:getContactsCount()

    self.UI.lbCountContacts:SetHidden(counter.total == 0)

    if (counter.total > 0) then
        local s = F(L("UI_CONTACTS_COUNT"), counter.friends, counter.villains)
        self.UI.lbCountContacts:SetText(s)
    end
end

-- -----------------
--  @SECTION Filter
-- -----------------

function XelosesContactsList:FilterScrollList()
    local scroll_data = table:new(ZO_ScrollList_GetDataList(self.list))

    ZO_ClearNumericallyIndexedTable(scroll_data)

    local search_term = self:getSearchTerm()
    local isFiltered = (search_term ~= "")

    local function _filter(_data)
        return (
            (self.categoryID == _data.category) and
            (self.groupID == 0 or self.groupID == _data.group) and
            (
                not isFiltered or
                _data.account:isearch(search_term) or
                (self.parent.config.ui.search_note and _data.note and _data.note:isearch(search_term))
            )
        )
    end

    for _, data in ipairs(self.masterList or {}) do
        if (_filter(data)) then
            scroll_data:insert(ZO_ScrollList_CreateDataEntry(DATA_TYPE, data))
        end
    end

    self.UI.lbCountFiltered:SetHidden(not isFiltered)

    if (isFiltered) then
        self:SetEmptyText(L("UI_INFO_NO_CONTACTS_FOUND"))
        local s = F(L("UI_FILTERED_CONTACTS_COUNT"), #scroll_data)
        self.UI.lbCountFiltered:SetText(s)
    else
        self:SetEmptyText(L("UI_INFO_NO_CONTACTS"))
    end
end

function XelosesContactsList:getSearchTerm()
    local s = self.UI.searchBox:GetText():trim()
    return (s ~= "") and s or ""
end

function XelosesContactsList:SearchReset()
    self.UI.searchBox:SetText("")
end

-- ----------------------
--  @SECTION UI list row
-- ----------------------

function XelosesContactsList:SetupItemRow(control, data)
    local cell
    local img
    local showGroup = (self.groupID == 0)

    -- Account name
    cell = control:GetNamedChild("Account")
    cell:SetText(data.account)

    -- Contact's group
    cell = control:GetNamedChild("Group")
    self:SetupCellDisplay(cell, "Group", showGroup)
    if (showGroup) then
        cell.normalColor = ZO_DEFAULT_TEXT
        cell:SetText(self.parent:getContactGroupName(data))
    end

    -- Group icon
    cell = control:GetNamedChild("GroupIcon")
    cell:SetTexture(self.parent:getGroupIcon(data.category, data.group))

    -- Personal note
    cell = control:GetNamedChild("Note")
    cell.normalColor = ZO_DEFAULT_TEXT
    cell:SetText(data.note or "")
    cell:SetHidden(not data.note or data.note == "")

    -- Date/time added
    cell = control:GetNamedChild("Timestamp")
    cell.normalColor = ZO_DEFAULT_TEXT
    cell:SetText(self.parent:formatTimestamp(data.timestamp)) -- TimeFunctions_GetLocalizedDateTime(data.timestamp)

    self:SetupRow(control, data)
end

-- ------------------
--  @SECTION Tooltip
-- ------------------

function XelosesContactsList:ShowContactTooltip(contact_data)
    local color_note    = ZO_ColorDef:New(CONST.COLOR.DEFAULT)
    local r, g, b       = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
    local icon_size     = 28

    local category_name = self.parent:getContactCategoryName(contact_data, true)
    local group_name    = self.parent:getContactGroupName(contact_data, true, true, icon_size)
    local date_added    = self.parent:formatTimestamp(contact_data.timestamp):colorize(CONST.COLOR.NOTE)

    local tooltip       = LEJ.InitializeTooltip()

    -- Header (category & date added)
    local tooltip_ext   = LEJ.TooltipExtensionInitialize(
        false,                                      -- show divider
        date_added,                                 -- top-left text
        category_name,                              -- top-right text
        self.parent.__namespace .. "ContactTooltip" -- tooltip object internal name
    )
    tooltip_ext:Finalize(tooltip, true)

    local function AddEmptyLine()
        tooltip:AddLine("", "ZoFontWinH4")
    end

    -- Account name
    AddEmptyLine()
    tooltip:AddLine(contact_data.account, "ZoFontWinH1", r, g, b)
    AddEmptyLine()

    -- Group
    tooltip:AddLine(group_name, "ZoFontWinH3")
    AddEmptyLine()

    -- <divider>
    ZO_Tooltip_AddDivider(tooltip)

    -- Note
    tooltip:AddLine(L(SI_GAMEPAD_CONTACTS_NOTES_TITLE), "ZoFontWinT2", r, g, b)

    r, g, b = ZO_ColorDef:New(CONST.COLOR.DEFAULT):UnpackRGB()
    tooltip:AddLine(contact_data.note, nil, nil, nil, nil, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)

    self.contactTooltip = tooltip
end

function XelosesContactsList:ClearContactTooltip()
    if (not self.contactTooltip) then return end
    ClearTooltip(self.contactTooltip)
    self.contactTooltip = nil
end

-- -----------------------
--  @SECTION Context menu
-- -----------------------

function XelosesContactsList:InitContextMenu()
    local context_menu      = {
        -- Edit contact
        {
            label = XELCONTACTS_MENU_EDIT_CONTACT,
            callback = function(data)
                self.parent:EditContact(data)
            end,
        },

        -- Whisper
        {
            label = SI_SOCIAL_LIST_SEND_MESSAGE,
            callback = function(data)
                self.parent.Chat:Whisper(data.account)
            end,
            visible = function(data)
                return (
                    data.category == CONST.CONTACTS_FRIENDS_ID and
                    IsChatSystemAvailableForCurrentPlatform()
                )
            end,
        },

        -- Group invite
        {
            label = SI_SOCIAL_MENU_INVITE,
            callback = function(data)
                self.parent.Game:GroupInvite(data.account)
            end,
            visible = function(data)
                return (
                    data.category == CONST.CONTACTS_FRIENDS_ID and
                    IsGroupModificationAvailable()
                )
            end,
        },

        -- Teleport
        {
            label = SI_SOCIAL_MENU_JUMP_TO_PLAYER,
            callback = function(data)
                self.parent.Game:TeleportTo(data.account)
            end,
            visible = function(data)
                return (
                    data.category == CONST.CONTACTS_FRIENDS_ID and
                    not self.parent.inCombat and
                    not IsUnitDead("player")
                )
            end,
        },

        -- Visit house
        {
            label = SI_SOCIAL_MENU_VISIT_HOUSE,
            callback = function(data)
                self.parent.Game:VisitHouse(data.account)
            end,
            visible = function()
                return (
                    not self.parent.inCombat and
                    not IsUnitDead("player")
                )
            end,
        },

        -- Send mail
        {
            label = SI_SOCIAL_MENU_SEND_MAIL,
            callback = function(data)
                self.parent.Game:ComposeMail(data.account)
            end,
            visible = function()
                return (
                    not self.parent.inCombat and
                    not IsUnitDead("player")
                )
            end,
        },

        -- Report player
        {
            label = SI_CHAT_PLAYER_CONTEXT_REPORT,
            callback = function(data)
                self.parent.Game:ReportPlayer(data.account)
            end,
            visible = function(data)
                return (
                    data.category == CONST.CONTACTS_VILLAINS_ID
                )
            end,
        },

        -- Remove contact
        {
            label = XELCONTACTS_MENU_REMOVE_CONTACT,
            callback = function(data)
                self.parent:RemoveContact(data)
            end,
        },
    }

    self.context_menu_items = context_menu
end

function XelosesContactsList:ShowContextMenu(control, row_data)
    if (not self.context_menu_items) then self:InitContextMenu() end
    ClearMenu()

    for _, menu_item in ipairs(self.context_menu_items) do
        local label = L(menu_item.label)
        local show = (
            menu_item.visible == nil or
            (T(menu_item.visible) == "function" and menu_item.visible(row_data)) or
            (T(menu_item.visible) == "boolean" and menu_item.visible)
        )

        if (show and label and T(menu_item.callback) == "function") then
            AddMenuItem(
                label,
                function()
                    menu_item.callback(row_data)
                end
            )
        end
    end

    if (not self.list) then
        -- variable "self" can be empty here, so we set the "list" field to prevent errors in the ShowMenu() call
        self.list = (self.UI and self.UI.list) or (self.control and self.control:GetNamedChild("List")) or (self.frame and self.frame:GetNamedChild("List")) or XelosesContactsFrame:GetNamedChild("List")
    end

    self:ShowMenu(control)
end

-- -------------------
--  @SECTION Keybinds
-- -------------------

function XelosesContactsList:InitKeybinds()
    self:RemoveKeybinds()

    -- Static keybinds
    self.staticKeybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        -- Add new Contact
        {
            name     = L("UI_BTN_ADD_CONTACT_TOOLTIP"),
            keybind  = "XELCONTACTS_ADD_CONTACT", --"UI_SHORTCUT_PRIMARY",
            callback = function() self.parent:AddContact() end,
            visible  = function() return not self.parent.processing end,
        },
    }

    -- Personal keybinds
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        -- Whisper
        {
            name     = GetString(SI_SOCIAL_LIST_PANEL_WHISPER),
            keybind  = "UI_SHORTCUT_SECONDARY",
            callback = function()
                local data = ZO_ScrollList_GetData(self.mouseOverRow)
                if (data) then self.parent.Chat:Whisper(data.account) end
            end,
            visible  = function()
                return (
                    self.mouseOverRow ~= nil and
                    self.categoryID == CONST.CONTACTS_FRIENDS_ID
                )
            end,
        },

        -- Group invite
        {
            name     = GetString(SI_FRIENDS_LIST_PANEL_INVITE),
            keybind  = "UI_SHORTCUT_TERTIARY",
            callback = function()
                local data = ZO_ScrollList_GetData(self.mouseOverRow)
                if (data) then self.parent.Game:GroupInvite(data.account) end
            end,
            visible  = function()
                return (
                    self.mouseOverRow ~= nil and
                    IsGroupModificationAvailable()
                )
            end,
        },

        -- Teleport
        {
            name     = GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER),
            keybind  = "UI_SHORTCUT_QUATERNARY",
            callback = function()
                local data = ZO_ScrollList_GetData(self.mouseOverRow)
                if (data) then self.parent.Game:TeleportTo(data.account) end
            end,
            visible  = function()
                return (
                    not self.parent.inCombat and
                    self.mouseOverRow ~= nil and
                    not IsUnitDead("player")
                )
            end,
        },
    }
end

function XelosesContactsList:SetupKeybinds()
    if (not self.staticKeybindStripDescriptor) then self:InitKeybinds() end

    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
    KEYBIND_STRIP:AddKeybindButtonGroup(self.staticKeybindStripDescriptor)
end

function XelosesContactsList:UpdateKeybinds()
    if (not self.keybindStripDescriptor) then self:InitKeybinds() end

    local hasPersonalKeybinds = KEYBIND_STRIP:HasKeybindButtonGroup(self.keybindStripDescriptor)

    if (self:getSelectedCategory() == CONST.CONTACTS_FRIENDS_ID) then
        if (hasPersonalKeybinds) then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
        else
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
        end
    else
        if (hasPersonalKeybinds) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
        end
    end
end

function XelosesContactsList:RemoveKeybinds()
    if (not self.staticKeybindStripDescriptor) then return end

    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.staticKeybindStripDescriptor)

    self.keybindStripDescriptor = nil
    self.staticKeybindStripDescriptor = nil
end

-- -------------------------
--  @SECTION Event Handlers
-- -------------------------

function XelosesContactsList:onSearchTextChanged()
    self.UI.btnSearchReset:SetHidden(self:getSearchTerm():len() == 0)
    self:RefreshFilters()
end

function XelosesContactsList:onCategorySelect(control, name, data)
    self:SetSelectedCategory(data.id)
end

function XelosesContactsList:onGroupSelect(control, name, data)
    self:SetSelectedGroup(data.data or 0)

    if (self.parent.UI.isReady) then
        self:RefreshFilters()
    end
end

-- -------------------------

function XelosesContactsList.onRowMouseEnter(control)
    SELF_INSTANCE:Row_OnMouseEnter(control)

    local data = ZO_ScrollList_GetData(control)
    if (not data.note or data.note == "") then return end

    local lbNote = control:GetNamedChild("Note")
    if (lbNote and lbNote:WasTruncated()) then
        SELF_INSTANCE:ShowContactTooltip(data)
    end
end

function XelosesContactsList.onRowMouseExit(control)
    SELF_INSTANCE:Row_OnMouseExit(control)
    SELF_INSTANCE:ClearContactTooltip()
end

function XelosesContactsList.onRowMouseUp(control, button, upInside)
    if (not upInside) then return end

    local data = ZO_ScrollList_GetData(control)

    if (button == MOUSE_BUTTON_INDEX_LEFT) then
        SELF_INSTANCE.parent:EditContact(data)
    elseif (button == MOUSE_BUTTON_INDEX_RIGHT) then
        SELF_INSTANCE:ShowContextMenu(control, data)
    end
end

-- ------------------
--  @SECTION Utility
-- ------------------

function XelosesContactsList:SetColumnVisibility(column_name, visible)
    if (not column_name) then return end
    local control = self.UI.headers:GetNamedChild(column_name)
    if (not control) then return end
    local width = _G["XELOSES_CONTACTS_LIST_COLUMN_" .. column_name:upper() .. "_WIDTH"]
    if (not width) then return end
    control:SetWidth(visible and width or 0)
    control:SetHidden(not visible)
end

function XelosesContactsList:SetupCellDisplay(cell, column_name, visible)
    if (not cell or not column_name) then return end
    if (cell:IsHidden() == not visible) then return end
    local i = self.index_columns:search(column_name) -- column index
    if (not i) then return end
    local parent = cell:GetParent()
    if (not parent) then return end
    local width = _G["XELOSES_CONTACTS_LIST_COLUMN_" .. column_name:upper() .. "_WIDTH"] -- default column width
    if (not width) then return end
    local should_hide = not visible
    local icon = parent:GetNamedChild(column_name .. "Icon")
    if (icon) then
        icon:SetHidden(should_hide)
    end
    local n = self.index_columns:len() -- columns count

    -- get next and previous cells
    local prev_cell_name = (i > 1) and self.index_columns[i - 1]
    local next_cell_name = (i < n) and self.index_columns[i + 1]
    local prev_cell = prev_cell_name and parent:GetNamedChild(prev_cell_name)
    local next_cell = next_cell_name and parent:GetNamedChild(next_cell_name)

    cell:SetHidden(should_hide)

    -- update adjacent cells
    if (should_hide) then
        -- HIDE CELL
        if (next_cell) then
            -- check if next column is not a last column
            if (n ~= i + 1) then
                -- anchor next cell to previous cell or to parent control
                local padding = prev_cell and XELOSES_CONTACTS_LIST_CELL_PADDING * 2 or 0
                local pos     = prev_cell and RIGHT or LEFT
                next_cell:SetAnchor(LEFT, prev_cell or parent, pos, padding, 0)
            end
            local next_cell_width = next_cell_name and _G["XELOSES_CONTACTS_LIST_COLUMN_" .. next_cell_name:upper() .. "_WIDTH"] or 0
            -- change width of next cell
            if (next_cell_width and next_cell:GetWidth() == next_cell_width) then
                local w = next_cell_width + width
                next_cell:SetWidth(w)
                next_cell:SetDimensions(w, XELOSES_CONTACTS_LIST_CELL_HEIGHT)
            end
        elseif (prev_cell) then
            -- no next cell => current cell is a last cell
            local prev_cell_width = prev_cell_name and _G["XELOSES_CONTACTS_LIST_COLUMN_" .. prev_cell_name:upper() .. "_WIDTH"] or 0
            -- change width of previous cell
            if (prev_cell_width and prev_cell:GetWidth() == prev_cell_width) then
                local w = prev_cell_width + width
                prev_cell:SetWidth(w)
                prev_cell:SetDimensions(w, XELOSES_CONTACTS_LIST_CELL_HEIGHT)
            end
        end
    else
        -- SHOW CELL
        if (next_cell) then
            -- check if next column is not a last column
            if (n ~= i + 1) then
                -- anchor next cell to the current cell
                next_cell:SetAnchor(LEFT, cell, RIGHT, XELOSES_CONTACTS_LIST_CELL_PADDING, 0)
            end
            local next_cell_width = next_cell_name and _G["XELOSES_CONTACTS_LIST_COLUMN_" .. next_cell_name:upper() .. "_WIDTH"] or 0
            -- change width of next cell
            if (next_cell_width and next_cell:GetWidth() > next_cell_width) then
                next_cell:SetWidth(next_cell_width)
                next_cell:SetDimensions(next_cell_width, XELOSES_CONTACTS_LIST_CELL_HEIGHT)
            end
        elseif (prev_cell) then
            -- no next cell => current cell is a last cell
            local prev_cell_width = prev_cell_name and _G["XELOSES_CONTACTS_LIST_COLUMN_" .. prev_cell_name:upper() .. "_WIDTH"] or 0
            -- change width of previous cell
            if (prev_cell_width and prev_cell:GetWidth() > prev_cell_width) then
                prev_cell:SetWidth(prev_cell_width)
                prev_cell:SetDimensions(prev_cell_width, XELOSES_CONTACTS_LIST_CELL_HEIGHT)
            end
        end
    end
end
