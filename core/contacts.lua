local XC    = XelosesContacts
local CONST = XC.CONST
local L     = XC.getString
local T     = type

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

function XC:isChatBlocked(contact)
    local contact_data = self:getContactData(contact)
    return (contact_data and self:isVillain(contact_data) and self:isChatBlockedForGroup(contact_data.group)) or false
end

function XC:isChatBlockedForGroup(group_id)
    return (group_id ~= nil) and self.config.chat.block_groups[group_id]
end

function XC:validateContactCategory(category_id)
    return (category_id ~= nil and CONST.CONTACTS_CATEGORIES[category_id] ~= nil)
end

function XC:validateContactGroup(category_id, group_id)
    if (not self:validateContactCategory(category_id) or group_id == nil) then return false end

    return (self:getGroupIndexByID(category_id, group_id) ~= nil)
end

-- --------------------------------
--  @SECTION Categories and Groups
-- --------------------------------

function XC:getCategoryName(category_id)
    return CONST.CONTACTS_CATEGORIES[category_id]
end

function XC:getCategoryColor(category_id)
    return self.config.colors[category_id] or self.colors.default
end

function XC:getGroupIndexByID(category_id, group_id)
    if (not self:validateContactCategory(category_id)) then return end

    -- lazy init cache
    if (not self.__groups_cache) then self.__groups_cache = {} end
    if (not self.__groups_cache[category_id]) then self.__groups_cache[category_id] = table:new() end

    if (self.__groups_cache[category_id]:hasKey(group_id)) then
        return self.__groups_cache[category_id]:get(group_id)
    end

    for i, group in ipairs(self.config.groups[category_id]) do
        if (group.id == group_id) then
            self.__groups_cache[category_id]:insertElem(group_id, i)
            return i
        end
    end
end

function XC:getGroupByID(category_id, group_id)
    local i = self:getGroupIndexByID(category_id, group_id)
    return i and self.config.groups[category_id][i]
end

function XC:getGroupName(category_id, group_id)
    local group = self:getGroupByID(category_id, group_id)
    return group and group.name
end

function XC:getGroupIcon(category_id, group_id)
    local group = self:getGroupByID(category_id, group_id)
    return group and group.icon
end

function XC:getGroupTitle(category_id, group_id, colorized)
    return self:getGroupName(category_id, group_id):addIcon(self:getGroupIcon(category_id, 1), colorized and self:getCategoryColor(category_id))
end

function XC:getGroupsList(category_id, with_icons, colorized)
    local result = table:new()
    if (not CONST.CONTACTS_CATEGORIES[category_id]) then return result end

    for _, group in ipairs(self.config.groups[category_id]) do
        local name = group.name
        if (with_icons) then
            local color = colorized and self:getCategoryColor(category_id)
            name = name:addIcon(group.icon, color, nil, true)
        end
        result:insertElem(group.id, name)
    end

    result:sortByKeys()
    return result
end

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
    if (not contact_data) then return end

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
    if (not contact_data) then return end

    local category_name = self:getCategoryName(contact_data.category)
    if (not category_name or category_name:isEmpty()) then return end

    if (colorize) then
        category_name = category_name:colorize(self:getCategoryColor(contact_data.category))
    end

    return category_name
end

function XC:getContactGroupName(contact, colorize, with_icon)
    local contact_data = self:getContactData(contact)
    if (not contact_data) then return end

    local group_name = self:getGroupName(contact_data.category, contact_data.group)
    if (not group_name or group_name:isEmpty()) then return end

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

-- ------------------------
--  @SECTION Manage groups
-- ------------------------

function XC:getNewGroupID(category_id)
    local ids = table:new()
    local max = 0

    for _, group in ipairs(self.config.groups[category_id]) do
        if (group.id > max) then max = group.id end
        ids:insert(group.id)
    end

    if (ids:len() == 5) then return 6 end

    for i = 6, max do
        if (not ids:has(i)) then return i end
    end

    return max + 1
end

function XC:CreateGroup(category_id, name, icon)
    local group_id   = self:getNewGroupID(category_id) -- generate ID for new group
    local group_name = (T(name) == "string" and not name:isEmpty()) and name:sanitize(CONST.GROUP_NAME_MAX_LENGTH) or L("GROUP_NEW")
    local group_icon = (T(icon) == "string" and not icon:match("^.+%.dds$")) and icon or CONST.ICONS.LIST[1]

    local group      = {
        id   = group_id,
        name = group_name,
        icon = group_icon,
    }
    table.insert(self.config.groups[category_id], group)

    self:RefreshContactGroups(category_id)

    return group
end

function XC:RemoveGroup(category_id, group_id)
    self.processing = true -- indicates possibly long process started

    -- move contacts from removing group to default (first) group
    self:MoveContacts(category_id, group_id, 1)
    self:RefreshContactsList(true)

    local i = self:getGroupIndexByID(category_id, group_id)
    table.remove(self.config.groups[category_id], i)
    self:RefreshContactGroups(category_id)

    self.processing = false -- indicates possibly long process ended
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

    local account_name = self:validateAccountName(contact_data.account, true)

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
    local contact_data = self:getContactData(contact)
    local new_contact_data = table.clone(contact_data)

    local old_name = contact_data.account
    self:DeleteContact(contact_data, true)

    self:SaveContact(new_contact_data, true)

    -- @LOG Contact renamed
    self.parent:Log("Rename contact [%s] -> [%s].", old_name, new_name)

    self:RefreshContactsList() -- do refresh here because SaveContact() was called with silent=true
end

function XC:MoveContacts(category_id, from_group_id, to_group_id)
    if (not self:validateContactGroup(category_id, from_group_id) or not self:validateContactGroup(category_id, to_group_id)) then return end
    self.processing = true -- indicates possibly long process started

    local n = 0
    for contact_name, contact_data in pairs(self.contacts) do
        if (contact_data.group == from_group_id) then
            contact_data.group   = to_group_id
            contact_data.account = contact_name -- necessary for SaveContact() method
            self:SaveContact(contact_data, true)

            n = n + 1
        end
    end

    self.processing = false -- indicates possibly long process started
    return n
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

-- -----------------------

function XC:SaveContact(contact_data, silent)
    local function createDataStr(data)
        return ("%s;%d;%d;%s"):format(tostring(data.timestamp), data.category, data.group, data.note or "")
    end

    -- @DEBUG
    self:Debug("XC:SaveContact(contact_data, silent = %s)", tostring(silent))
    self:Debug("  -> contact_data = { account: \"%s\", category: %d, group: %d }", contact_data.account or "<<NULL>>", contact_data.category, contact_data.group)

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
    self.DataChanged = true -- signal data was changed (to refresh contacts list on show)

    if (not silent) then
        -- @LOG Contact created
        self:Log("Contact %s: %s%s", isNew and "added" or "updated", contact_name, isNew and (" <%s::%s>"):format(self:getCategoryName(contact_data.category), self:getGroupName(contact_data.category, contact_data.group)) or "")

        self:RefreshContactsList()
    end
end

function XC:DeleteContact(contact_data, silent)
    self.SV.contacts[contact_data.account] = nil
    self.contacts[contact_data.account] = nil
    self.DataChanged = true -- signal data was changed (to refresh contacts list on show)

    if (not silent) then
        -- @LOG Contact removed
        self:Log("Player [%s] has been removed from Contacts.", contact_data.account)

        self:Notify(L("CONTACT_REMOVED"), contact_data.account)

        XC:RefreshContactsList()
    end

    return true
end

-- --------------------
--  @SECTION Load data
-- --------------------

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

function XC:LoadContacts()
    self.contacts = table:new()
    for contact_name, data_str in pairs(self.SV.contacts) do
        local contact_data = parseDataStr(data_str)
        if (contact_data) then
            self.contacts:insertElem(contact_name, contact_data)
        end
    end
end
