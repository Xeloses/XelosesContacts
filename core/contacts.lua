local XC    = XelosesContacts
local CONST = XC.CONST
local ICONS = XC.ICONS
local L     = XC.getString
local T     = type

-- -----------------------
--  @SECTION Contact data
-- -----------------------

function XC:getContactData(contact)
    if (T(contact) == "table" and contact.account) then
        return contact
    elseif (T(contact) == "string") then
        local data = self.contacts:get(contact)
        if (data) then
            data.account = contact
            return data
        end
    end
end

-- -----------------------

function XC:getContactName(contact, colorize, with_icon)
    local contact_data = self:getContactData(contact)
    if (not contact_data) then
        return ""
    end
    local contact_name = contact_data.account
    if (colorize) then
        contact_name = contact_name:colorize(self:getCategoryColor(contact_data.category))
    end
    if (with_icon) then
        local icon = self:getContactGroupIcon(contact, colorize)
        if (not icon) then
            return contact_name
        end
        contact_name = icon .. contact_name
    end
    return contact_name
end

function XC:getContactLink(contact, colorize, with_icon)
    local contact_data = self:getContactData(contact)
    if (not contact_data) then
        return ""
    end
    local contact_link = self:getAccountLink(contact_data.account)
    if (colorize) then
        contact_link = contact_link:colorize(self:getCategoryColor(contact_data.category))
    end
    if (with_icon) then
        local icon = self:getContactGroupIcon(contact, colorize)
        if (not icon) then
            return contact_link
        end
        contact_link = icon .. contact_link
    end
    return contact_link
end

function XC:getContactCategoryName(contact, colorize)
    local contact_data = self:getContactData(contact)
    if (not contact_data) then
        return ""
    end
    local category_name = self:getCategoryName(contact_data.category)
    if (category_name == "") then
        return category_name
    end
    if (colorize) then
        category_name = category_name:colorize(self:getCategoryColor(contact_data.category))
    end
    return category_name
end

function XC:getContactGroupName(contact, colorize, with_icon)
    local contact_data = self:getContactData(contact)
    if (not contact_data) then
        return ""
    end
    local group_name = self:getGroupName(contact_data.category, contact_data.group)
    if (group_name == "") then return end
    if (colorize) then
        group_name = group_name:colorize(self:getCategoryColor(contact_data.category))
    end
    if (with_icon) then
        local icon = self:getContactGroupIcon(contact, colorize)
        if (not icon) then
            return group_name
        end
        group_name = icon .. group_name
    end
    return group_name
end

function XC:getContactGroupIcon(contact, colorize)
    local contact_data = self:getContactData(contact)
    if (not contact_data) then return end
    local icon = self:getGroupIcon(contact_data.category, contact_data.group)
    if (not icon) then return end
    if (colorize) then
        return (""):addIcon(icon, self:getCategoryColor(contact_data.category))
    end
    return icon
end

-- ------------------------
--  @SECTION Contacts info
-- ------------------------

---@private
function XC:getCategoryName(category_id)
    return CONST.CONTACTS_CATEGORIES[category_id]
end

---@private
function XC:getCategoryColor(category_id)
    return self.config.colors[category_id] or self.colors.default
end

---@private
function XC:getGroupName(category_id, group_id)
    return self.config.groups[category_id] and self.config.groups[category_id][group_id]
end

---@private
function XC:getGroupIcon(category_id, group_id)
    if (not ICONS.GROUPS[category_id] or not ICONS.GROUPS[category_id][group_id]) then return end
    return ICONS.GROUPS[category_id][group_id]
end

---@private
function XC:getGroupsList(category_id, with_icons, colorized)
    local result = table:new()
    if (not CONST.CONTACTS_CATEGORIES[category_id]) then return result end
    for group_id, group_name in ipairs(self.config.groups[category_id]) do
        local name = group_name
        if (with_icons) then
            local icon = self:getGroupIcon(category_id, group_id)
            local color = colorized and self:getCategoryColor(category_id)
            name = name:addIcon(icon, color, nil, true)
        end
        result:insert(group_id, name)
    end
    return result
end

-- -----------------------

function XC:getContactsCount()
    local counter = {
        total = 0,
        friends = 0,
        villains = 0,
    }

    for _, data in pairs(self.contacts) do
        counter.total = counter.total + 1
        if (data.category == CONST.CONTACTS_FRIENDS_ID) then
            counter.friends = counter.friends + 1
        elseif (data.category == CONST.CONTACTS_VILLAINS_ID) then
            counter.villains = counter.villains + 1
        end
    end
    return counter
end

-- ---------------------------
--  @SECTION Checkups / Tests
-- ---------------------------

function XC:isInContacts(name)
    return self:getContactData(name) ~= nil
end

function XC:isFriend(contact)
    local contact_data = self:getContactData(contact)
    local contact_category = contact_data and contact_data.category or 0
    return (contact_category == CONST.CONTACTS_FRIENDS_ID)
end

function XC:isVillain(contact)
    local contact_data = self:getContactData(contact)
    local contact_category = contact_data and contact_data.category or 0
    return (contact_category == CONST.CONTACTS_VILLAINS_ID)
end

---@private
function XC:isChatBlocked(contact)
    local contact_data = self:getContactData(contact)
    return (contact_data and self:isVillain(contact_data) and self:isChatBlockedForGroup(contact_data.group)) or false
end

---@private
function XC:isChatBlockedForGroup(group_id)
    return (group_id ~= nil) and self.config.chat.block_groups[group_id]
end

---@private
function XC:validateContactCategory(category_id)
    return (category_id ~= nil and CONST.CONTACTS_CATEGORIES[category_id] ~= nil)
end

---@private
function XC:validateContactGroup(category_id, group_id)
    return (self:validateContactCategory(category_id) and group_id ~= nil and self.config.groups[category_id][group_id] ~= nil)
end

-- --------------------------
--  @SECTION Manage contacts
-- --------------------------

function XC:AddContact(name, data)
    local contact_data = {}

    if (T(name) == "string" and not name:isEmpty()) then
        contact_data = {
            account  = name,
            category = data and data.category,
            note     = data and data.note,
        }
    else
        if (self:isUIShown()) then
            local category_id = self.UI.ContactsList:getSelectedCategory()
            local group_id = self.UI.ContactsList:getSelectedGroup()
            contact_data = {
                category = category_id,
                group    = (group_id > 0) and group_id or 1,
            }
        elseif (DoesUnitExist("reticleoverplayer") and not AreUnitsEqual("player", "reticleoverplayer")) then
            local account_name = GetUnitDisplayName("reticleoverplayer")
            if (T(account_name) == "string" and not account_name:isEmpty() and account_name:sub(1, 1) == "@") then
                if (self:isInContacts(account_name)) then
                    self:Notify(L("TARGET_IN_CONTACTS"), self:getAccountLink(account_name))
                    return
                end
                contact_data = {
                    account = account_name,
                }
            end
        end
    end
    self:ShowContactDialog(contact_data)
end

function XC:AddContact_Friend(name, note)
    self:AddContact(name, { category = CONST.CONTACTS_FRIENDS_ID, note = note })
end

function XC:AddContact_Villain(name, note)
    self:AddContact(name, { category = CONST.CONTACTS_VILLAINS_ID, note = note })
end

function XC:EditContact(contact_data)
    self:ShowContactDialog(contact_data)
end

-- -----------------------

---@private
function XC:CreateOrUpdateContact(contact_data)
    if (T(contact_data) ~= "table") then
        -- @LOG error: incorrect param
        self:LogError("Error attempt to create or edit contact: incorrect function call.")
        return false
    end

    local isNewContact = (contact_data.timestamp == nil)

    -- Account name
    if (not contact_data.account or contact_data.account == "") then
        -- @LOG error: incorrect account name
        self:LogError("Error attempt to %s contact: empty account name.", isNewContact and "create" or "update")
        return false
    end

    local account_name = self:validateAccountName(contact_data.account)

    if (not account_name) then
        -- @LOG error: incorrect account name
        self:LogError("Error attempt to %s contact [%s]: incorrect account name.", isNewContact and "create" or "update", contact_data.account)
        return false
    else
        contact_data.account = account_name
    end

    -- Contact category
    if (not self:validateContactCategory(contact_data.category)) then
        -- @LOG error: incorrect category
        local _i = contact_data.category and tostring(contact_data.category) or (contact_data.category == 0) and "0" or "<NIL>"
        self:LogError("Error attempt to %s contact [%s]: incorrect category index %s.", isNewContact and "create" or "update", account_name, _i)
        return false
    end

    -- Contact group
    if (not self:validateContactGroup(contact_data.category, contact_data.group)) then
        -- @LOG error: incorrect group
        local _i = contact_data.group and tostring(contact_data.group) or (contact_data.group == 0) and "0" or "<NIL>"
        self:LogError("Error attempt to %s contact [%s]: incorrect group index %s.", isNewContact and "create" or "update", account_name, _i)
        return false
    end

    -- Personal note
    if (contact_data.note and not contact_data.note:isEmpty()) then
        contact_data.note = contact_data.note:sanitize(CONST.CONTACT_NOTE_MAX_LENGTH)
    end

    self:SaveContact(contact_data)
    if (isNewContact) then
        self:Notify(L("CONTACT_ADDED"), contact_data)
    end
    return true
end

function XC:RenameContact(contact, new_name)
    local contact_data = XC:getContactData(contact)
    local new_contact_data = table.clone(contact_data)

    local old_name = contact_data.account
    XC:DeleteContact(contact_data, true)

    new_contact_data.account = new_name
    XC:SaveContact(new_contact_data, true)

    -- @LOG Contact renamed
    XC:Log("Contact %s renamed to %s", old_name, new_name)

    XC.DataChanged = true -- signal data was changed (to refresh contacts list UI on show)
    XC:RefreshUI()
end

---@private
function XC:SaveContact(contact_data, silent)
    local function createDataStr(data)
        return ("%s;%d;%d;%s"):format(tostring(data.timestamp), data.category, data.group, data.note or "")
    end

    local isNew = (contact_data.timestamp == nil)
    local contact_name = contact_data.account
    local new_contact_data = table:new({
        category  = contact_data.category,
        group     = contact_data.group,
        note      = contact_data.note,
        timestamp = contact_data.timestamp or GetTimeStamp(),
    })

    self.SV.contacts[contact_name] = createDataStr(new_contact_data)
    self.contacts[contact_name] = new_contact_data

    if (not silent) then
        -- @LOG Contact created
        self:Log("Contact %s: %s%s", isNew and "added" or "updated", contact_name, isNew and (" <%s::%s>"):format(self:getCategoryName(contact_data.category), self:getGroupName(contact_data.category, contact_data.group)) or "")

        self.DataChanged = true -- signal data was changed (to refresh contacts list UI on show)
        self:RefreshUI()
    end
end

function XC:RemoveContact(contact_data, params)
    local contact = self:getContactData(contact_data)
    if (not contact) then
        -- @LOG error: contact does not exists
        self:LogError("Error attempt to remove contact: contact does not exists.")
        return false
    end

    if (params and params.confirmed) then
        return self:DeleteContact(contact)
    else
        self:ShowDialog(CONST.UI.DIALOGS.CONFIRM_CONTACT_REMOVE, contact.account, contact)
    end
end

---@private
function XC:DeleteContact(contact_data, silent)
    self.SV.contacts[contact_data.account] = nil
    self.contacts[contact_data.account] = nil
    self.DataChanged = true -- signal data was changed (to refresh contacts list on show)

    if (not silent) then
        -- @LOG Contact removed
        self:Log("Player [%s] has been removed from Contacts.", contact_data.account)

        self:Notify(L("CONTACT_REMOVED"), contact_data.account)
        self:RefreshUI()
    end

    return true
end

-- --------------------
--  @SECTION Load data
-- --------------------

---@private
local function parseDataStr(data_str)
    local data        = data_str:split(";")
    local timestamp   = data[1] and tonumber(data[1]) or nil
    local category_id = data[2] and tonumber(data[2]) or nil
    local group_id    = data[3] and tonumber(data[3]) or nil
    local note        = data[4] and data[4]:trim() or nil

    if (not category_id or not group_id or not timestamp) then return end
    if (#data > 4) then note = data:concat(";", 4) end
    local result = {
        category  = category_id,
        group     = group_id,
        timestamp = timestamp,
    }
    if (note and not note:isEmpty()) then
        result.note = note
    end
    return result
end

---@private
function XC:LoadContacts()
    self.contacts = table:new()
    for contact_name, data_str in pairs(self.SV.contacts) do
        local contact_data = parseDataStr(data_str)
        if (contact_data) then
            self.contacts:insertElem(contact_name, contact_data)
        end
    end
end
