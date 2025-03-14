local L                               = XelosesContacts.getString
local T                               = type

XELOSES_CONTACT_DIALOG_CONTROL_WIDTH  = 200
XELOSES_CONTACT_DIALOG_CONTROL_HEIGHT = 26
XELOSES_CONTACT_DIALOG_BTN_PADDING    = 4
XELOSES_CONTACT_DIALOG_BTN_SIZE       = 26

local XelosesContactDialog            = ZO_Object:Subclass()

-- ----------------------
--  @SECTION Show dialog
-- ----------------------

function XelosesContacts:ShowContactDialog(data)
    if (not self.UI.ContactDialog or not self.UI.ContactDialog.initialized) then
        self.UI.ContactDialog = XelosesContactDialog:New(self) -- Lazy loading
    end

    ZO_Dialogs_ShowDialog(self.CONST.UI.DIALOGS.CONTACT_EDIT.name, data)
end

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContactDialog:New(parent_control)
    local dlg = ZO_Object.New(self)
    dlg:Initialize(parent_control)

    return dlg
end

function XelosesContactDialog:Initialize(parent)
    self.initialized    = false

    self.parent         = parent
    self.frame          = XelosesContactDialogFrame

    local dialogContent = GetControl(self.frame, "XelosesContactDialogContent")

    self.UI             = {
        lbAccountName = GetControl(dialogContent, "AccountNameLabel"),
        edAccountName = GetControl(dialogContent, "AccountName"),
        btnEditAccountName = GetControl(dialogContent, "EditAccountName"),
        lbCategory = GetControl(dialogContent, "CategoryLabel"),
        cbCategory = GetControl(dialogContent, "Category"),
        lbGroup = GetControl(dialogContent, "GroupLabel"),
        cbGroup = GetControl(dialogContent, "Group"),
        lbNote = GetControl(dialogContent, "NoteLabel"),
        edNote = GetControl(dialogContent, "Note"),
        btnSave = GetControl(self.frame, "Save"),
        btnCancel = GetControl(self.frame, "Cancel"),
    }

    self.UI.lbAccountName:SetText(L("UI_DIALOG_CONTACT_ACCOUNT_NAME"))
    self.UI.edAccountName:SetHandler("OnTextChanged", function(...) self:TestAccountName() end)
    self.UI.btnEditAccountName:SetHandler("OnClicked", function(...) self:btnEditAccountName_onClick() end)
    self.parent:SetControlTooltip(self.UI.btnEditAccountName, "UI_BTN_EDIT_ACCOUNT_NAME_TOOLTIP")

    self.UI.lbCategory:SetText(L("UI_DIALOG_CONTACT_CATEGORY"))
    self.UI.lbGroup:SetText(L("UI_DIALOG_CONTACT_GROUP"))
    self.UI.lbNote:SetText(L("UI_DIALOG_CONTACT_NOTE"))

    self.UI.cbCategory.m_comboBox:SetSortsItems(false) -- disable sorting
    self.UI.cbGroup.m_comboBox:SetSortsItems(false)    -- disable sorting

    self:SetupContactCategories()

    ZO_Dialogs_RegisterCustomDialog(
        self.parent.CONST.UI.DIALOGS.CONTACT_EDIT.name,
        {
            customControl = self.frame,
            setup = function(dialog, data)
                self:SetupDialog(dialog, data)
            end,
            title = {
                text = L("UI_DIALOG_TITLE_ADD_CONTACT")
            },
            buttons = {
                {
                    control = self.UI.btnSave,
                    text = SI_DIALOG_ACCEPT,
                    keybind = "DIALOG_PRIMARY",
                    callback = function(dialog)
                        self:SaveContact(dialog)
                        self:ResetDialog()
                    end,
                },
                {
                    control = self.UI.btnCancel,
                    text = SI_DIALOG_CANCEL,
                    keybind = "DIALOG_NEGATIVE",
                    callback = function(dialog)
                        self:ResetDialog()
                    end,
                }
            },
        }
    )
    self.initialized = true
end

-- -----------------------
--  @SECTION Setup dialog
-- -----------------------

function XelosesContactDialog:SetupDialog(dialog, data)
    if (not data) then data = {} end

    local hasAccountName = (data.account and data.account ~= "")
    if (hasAccountName) then
        dialog.info.title.text = L("UI_DIALOG_TITLE_EDIT_CONTACT")
    else
        dialog.info.title.text = L("UI_DIALOG_TITLE_ADD_CONTACT")
    end
    ZO_Dialogs_UpdateDialogTitleText(dialog, dialog.info.title)

    -- Account name
    self.UI.edAccountName:SetText(hasAccountName and data.account or "@")
    ZO_DefaultEdit_SetEnabled(self.UI.edAccountName, not hasAccountName)
    self:HideEditAccountNameButton(not hasAccountName)

    -- Category & Group
    self:SelectCategory(data.category or self.parent.config.default_category)
    if (data.group) then
        self:SelectGroup(data.group)
    end

    -- Note
    if (data.note) then
        self.UI.edNote:SetText(data.note)
    else
        self.UI.edNote:SetText("")
    end

    -- timestamp
    if (data.timestamp) then
        self.contact_timestamp = data.timestamp
    end

    self:SetButtonState(self.UI.btnSave, hasAccountName)
    if (hasAccountName) then
        self.UI.edNote:TakeFocus()
    else
        self.UI.edAccountName:TakeFocus()
    end
end

function XelosesContactDialog:ResetDialog()
    self.UI.edAccountName:SetText("")
    self.UI.edNote:SetText("")

    self:HideEditAccountNameButton(false)

    self.oldAccountName    = nil
    self.currentCategory   = nil
    self.currentGroup      = nil
    self.contact_timestamp = nil
end

-- -----------------------
--  @SECTION Account name
-- -----------------------

function XelosesContactDialog:btnEditAccountName_onClick()
    self.oldAccountName = self.UI.edAccountName:GetText()

    ZO_DefaultEdit_SetEnabled(self.UI.edAccountName, true)
    self:HideEditAccountNameButton()
end

function XelosesContactDialog:TestAccountName()
    local name = self.UI.edAccountName:GetText()

    if (name) then
        local valid_name = "@" .. name:gsub("[~`@!#$^&*({})=+:;\",<>/?|%\\%[%]%%]+", "")
        if (valid_name ~= name) then
            self.UI.edAccountName:SetText(valid_name)
        end

        local state = (XelosesContacts:validateAccountName(valid_name) ~= nil)
        self:SetButtonState(self.UI.btnSave, state)
    end
end

function XelosesContactDialog:HideEditAccountNameButton(hidden)
    if (T(hidden) ~= "boolean") then hidden = true end
    self.UI.btnEditAccountName:SetHidden(hidden)

    local w = XELOSES_CONTACT_DIALOG_CONTROL_WIDTH
    if (not hidden) then
        w = w - XELOSES_CONTACT_DIALOG_BTN_PADDING - XELOSES_CONTACT_DIALOG_BTN_SIZE
    end

    self.UI.edAccountName:SetWidth(w)
end

-- ------------------------------
--  @SECTION Categories & Groups
-- ------------------------------

function XelosesContactDialog:SetupContactCategories()
    local function onCategorySelect(control, name, data)
        self:SelectCategory(data.id)
    end

    self.UI.cbCategory.m_comboBox:ClearItems()

    local category_list = self.parent:getCategoryList(true)

    for category_id, category_name in pairs(category_list) do
        local item = ZO_ComboBox:CreateItemEntry(category_name, onCategorySelect)
        item.id = category_id
        self.UI.cbCategory.m_comboBox:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
    end

    self:SelectCategory(self.currentCategory)
end

function XelosesContactDialog:SetupContactGroups()
    local function onGroupSelect(control, name, data)
        self:SelectGroup(data.id)
    end

    local category_id = self.currentCategory

    self.UI.cbGroup.m_comboBox:ClearItems()

    local groups_list = self.parent:getGroupsList(category_id, true, true)
    for group_id, group_name in ipairs(groups_list) do
        local item = ZO_ComboBox:CreateItemEntry(group_name, onGroupSelect)
        item.id = group_id
        self.UI.cbGroup.m_comboBox:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
    end

    self:SelectGroup(self.currentGroup)
end

function XelosesContactDialog:SelectCategory(category_id)
    if (not category_id or not self.parent:validateContactCategory(category_id)) then
        category_id = self.parent.config.default_category
    end

    if (not self.currentCategory or self.currentCategory ~= category_id) then
        if (self.currentCategory) then
            self.currentGroup = nil -- reset selected group if Category was changed manually by user
        end

        self.currentCategory = category_id
        self.UI.cbCategory.m_comboBox:SelectItemByIndex(category_id, true)
        self:SetupContactGroups()
    end
end

function XelosesContactDialog:SelectGroup(group_id)
    if (not group_id) then group_id = 1 end
    if (not self.parent:getGroupIndexByID(self.currentCategory, group_id)) then return end

    if (not self.currentGroup or self.currentGroup ~= group_id) then
        self.currentGroup = group_id
        self.UI.cbGroup.m_comboBox:SetSelectedItemByEval(function(item) return item.id == group_id end, true)
    end
end

function XelosesContactDialog:RefreshGroupsList(category_id)
    if (not self.initialized or self.currentCategory ~= category_id) then return end
    
    self:SetupContactGroups()
end

-- --------------------
--  @SECTION Save data
-- --------------------

function XelosesContactDialog:SaveContact(dialog)
    local account_name = self.UI.edAccountName:GetText()

    if (self.oldAccountName) then
        self.parent:RenameContact(self.oldAccountName, account_name)
        self.oldAccountName = nil
    end

    local data = {
        account = account_name,
        category = self.currentCategory,
        group = self.currentGroup,
    }

    local note = self.UI.edNote:GetText()
    if (note and note:trim() ~= "") then
        data.note = note
    end

    if (self.contact_timestamp) then
        data.timestamp = self.contact_timestamp
    end

    XelosesContacts:CreateOrUpdateContact(data)
end

-- ------------------
--  @SECTION Utility
-- ------------------

function XelosesContactDialog:SetButtonState(button, enabled, visible)
    if (not button) then return end

    if (enabled == nil) then enabled = true end
    if (visible == nil) then visible = true end

    button:SetEnabled(enabled)
    button:SetHidden(not visible)
    button:SetKeybindEnabled(enabled and visible)
end
