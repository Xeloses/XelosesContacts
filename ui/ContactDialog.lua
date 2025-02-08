local XC                              = XelosesContacts
local CONST                           = XC.CONST
local L                               = XC.getString
local T                               = type
local XelosesContactDialog            = {}

XELOSES_CONTACT_DIALOG_CONTROL_WIDTH  = 200
XELOSES_CONTACT_DIALOG_CONTROL_HEIGHT = 26
XELOSES_CONTACT_DIALOG_BTN_PADDING    = 4
XELOSES_CONTACT_DIALOG_BTN_SIZE       = 26

-- ----------------------
--  @SECTION Show dialog
-- ----------------------

function XC:ShowContactDialog(data)
    if (not XelosesContactDialog.initialized) then XelosesContactDialog:Initialize() end -- Lazy loading
    ZO_Dialogs_ShowDialog(CONST.UI.DIALOGS.CONTACT_EDIT.name, data)
end

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContactDialog:Initialize()
    self.initialized = false
    self.control = XelosesContactDialogFrame
    local dialogContent = GetControl(self.control, "XelosesContactDialogContent")
    self.UI = {
        lbAccountName = GetControl(dialogContent, "AccountNameLabel"),
        edAccountName = GetControl(dialogContent, "AccountName"),
        btnEditAccountName = GetControl(dialogContent, "EditAccountName"),
        lbCategory = GetControl(dialogContent, "CategoryLabel"),
        cbCategory = GetControl(dialogContent, "Category"),
        lbGroup = GetControl(dialogContent, "GroupLabel"),
        cbGroup = GetControl(dialogContent, "Group"),
        lbNote = GetControl(dialogContent, "NoteLabel"),
        edNote = GetControl(dialogContent, "Note"),
        btnSave = GetControl(self.control, "Save"),
        btnCancel = GetControl(self.control, "Cancel"),
    }

    self.UI.lbAccountName:SetText(L("UI_DIALOG_CONTACT_ACCOUNT_NAME"))
    self.UI.edAccountName:SetHandler("OnTextChanged", function(...) self:TestAccountName() end)
    self.UI.btnEditAccountName:SetHandler("OnClicked", function(...) self:btnEditAccountName_onClick() end)

    self.UI.lbCategory:SetText(L("UI_DIALOG_CONTACT_CATEGORY"))
    self.UI.lbGroup:SetText(L("UI_DIALOG_CONTACT_GROUP"))
    self.UI.lbNote:SetText(L("UI_DIALOG_CONTACT_NOTE"))

    XC:SetControlTooltip(self.UI.btnEditAccountName, "UI_BTN_EDIT_ACCOUNT_NAME_TOOLTIP")
    self:SetupContactCategories()

    ZO_Dialogs_RegisterCustomDialog(
        CONST.UI.DIALOGS.CONTACT_EDIT.name,
        {
            customControl = self.control,
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
    self:SelectCategory(data.category or CONST.CONTACTS_FRIENDS_ID)
    self:SelectGroup(data.group or 1)

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

        local state = (XC:validateAccountName(valid_name, true) ~= nil)
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
        self:SelectCategory(data.data.id)
    end
    self.UI.cbCategory.m_comboBox:ClearItems()
    for cID, cName in pairs(CONST.CONTACTS_CATEGORIES) do
        local item = self.UI.cbCategory.m_comboBox:CreateItemEntry(cName, onCategorySelect)
        item.data = { id = cID, name = cName }
        self.UI.cbCategory.m_comboBox:AddItem(item)
    end
    self:SelectCategory(self.currentCategory or CONST.CONTACTS_FRIENDS_ID)
end

function XelosesContactDialog:SetupContactGroups()
    local function onGroupSelect(control, name, data)
        self:SelectGroup(data.data.id)
    end
    local cID = self.currentCategory
    self.UI.cbGroup.m_comboBox:ClearItems()
    for gID, gName in pairs(XC.config.groups[cID]) do
        local gTitle = gName:addIcon(XC:getGroupIcon(cID, gID), XC:getCategoryColor(cID))
        local item = self.UI.cbCategory.m_comboBox:CreateItemEntry(gTitle, onGroupSelect)
        item.data = { id = gID, name = gName }
        self.UI.cbGroup.m_comboBox:AddItem(item)
    end
    self:SelectGroup(self.currentGroup or 1)
end

function XelosesContactDialog:SelectCategory(category_id)
    if (not category_id or not CONST.CONTACTS_CATEGORIES[category_id]) then
        category_id = CONST.CONTACTS_FRIENDS_ID
    end
    if (not self.currentCategory or self.currentCategory ~= category_id) then
        if (self.currentCategory) then
            self.currentGroup = 0 -- reset group if Category was changed manually by user
        end
        self.currentCategory = category_id
        self.UI.cbCategory.m_comboBox:SetSelectedItem(CONST.CONTACTS_CATEGORIES[category_id])
        self:SetupContactGroups()
    end
end

function XelosesContactDialog:SelectGroup(group_id)
    if (not group_id or not XC.config.groups[self.currentCategory][group_id]) then
        group_id = 1
    end
    if (not self.currentGroup or self.currentGroup ~= group_id) then
        self.currentGroup = group_id
        self.UI.cbGroup.m_comboBox:SetSelectedItem(XC.config.groups[self.currentCategory][group_id])
    end
end

-- --------------------
--  @SECTION Save data
-- --------------------

function XelosesContactDialog:SaveContact(dialog)
    local account_name = self.UI.edAccountName:GetText()
    if (self.oldAccountName) then
        XC:DeleteContact({ account = self.oldAccountName }, true)
        -- @LOG Rename contact
        XC:Log("Rename contact [%s] -> [%s].", self.oldAccountName, account_name)
        self.oldAccountName = nil
    end
    local data = { account = account_name, category = self.currentCategory, group = self.currentGroup }
    local note = self.UI.edNote:GetText()
    if (note and note:trim() ~= "") then data.note = note end
    if (self.contact_timestamp) then data.timestamp = self.contact_timestamp end
    XC:CreateOrUpdateContact(data)
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
