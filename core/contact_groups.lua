local L = XelosesContacts.getString
local T = type

-- ---------------------------
--  @SECTION Checkups / Tests
-- ---------------------------

function XelosesContacts:isChatBlockedForGroup(group_id)
    local group = self:getGroupByID(self.CONST.CONTACTS_VILLAINS_ID, group_id)
    return group and group.mute
end

function XelosesContacts:validateContactCategory(category_id)
    return (category_id ~= nil and self.CONST.CONTACTS_CATEGORIES[category_id] ~= nil)
end

function XelosesContacts:validateContactGroup(category_id, group_id)
    return (self:validateContactCategory(category_id) and group_id ~= nil and self.config.groups[category_id][group_id] ~= nil)
end

-- ---------------------------
--  @SECTION Contact category
-- ---------------------------

function XelosesContacts:getCategoryName(category_id, colorized)
    local category_name = self.CONST.CONTACTS_CATEGORIES[category_id]

    if (colorized) then
        return category_name:colorize(self:getCategoryColor(category_id))
    end

    return category_name
end

function XelosesContacts:getCategoryColor(category_id)
    return self.config.colors[category_id] or self.CONST.COLOR.DEFAULT
end

-- ------------------------

function XelosesContacts:getCategoryList(colorized)
    local result = table:new()

    for category_id, _ in ipairs(self.CONST.CONTACTS_CATEGORIES) do
        result:insertElem(category_id, self:getCategoryName(category_id, colorized))
    end

    result:sort()
    return result
end

-- ------------------------
--  @SECTION Contact group
-- ------------------------

function XelosesContacts:getGroupIndexByID(category_id, group_id)
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

function XelosesContacts:getGroupByID(category_id, group_id)
    local i = self:getGroupIndexByID(category_id, group_id)
    return i and self.config.groups[category_id][i]
end

function XelosesContacts:getGroupsCount(category_id)
    if (not self:validateContactCategory(category_id)) then return 0 end

    local counter = 0

    for i, _ in ipairs(self.config.groups[category_id]) do
        counter = counter + 1
    end

    return counter
end

-- ------------------------

function XelosesContacts:getGroupName(category_id, group_id, with_icon, colorized_icon, colorized_text)
    local group = self:getGroupByID(category_id, group_id)
    if (not group) then return end

    local color      = self:getCategoryColor(category_id)
    local group_name = group.name

    if (colorized_text or (not with_icon and colorized_icon)) then
        group_name = group_name:colorize(color)
    end

    if (with_icon) then
        return group_name:addIcon(group.icon, colorized_icon and color)
    end

    return group_name
end

function XelosesContacts:getGroupIcon(category_id, group_id)
    local group = self:getGroupByID(category_id, group_id)
    return group and group.icon
end

-- ------------------------

function XelosesContacts:getGroupsList(category_id, with_icons, colorized)
    local result = table:new()
    if (not self:validateContactCategory(category_id)) then return result end

    for _, group in ipairs(self.config.groups[category_id]) do
        local group_name = group.name
        if (with_icons) then
            local color = colorized and self:getCategoryColor(category_id)
            group_name = group_name:addIcon(group.icon, color, nil, true)
        end

        result:insertElem(group.id, group_name)
    end

    result:sortByKeys()
    return result
end

-- ------------------------
--  @SECTION Manage groups
-- ------------------------

function XelosesContacts:getNewGroupID(category_id)
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

function XelosesContacts:CreateGroup(category_id, name, icon)
    local group_id   = self:getNewGroupID(category_id) -- generate ID for new group
    local group_name = (T(name) == "string" and not name:isEmpty()) and name:sanitize(self.CONST.GROUP_NAME_MAX_LENGTH) or L("GROUP_NEW")
    local group_icon = (T(icon) == "string" and icon:match("%.dds$")) and icon or self.CONST.ICONS.LIST[1]

    local group      = {
        id   = group_id,
        name = group_name,
        icon = group_icon,
    }
    
    if (category_id == self.CONST.CONTACTS_VILLAINS_ID) then
        group.mute = true
    end
    
    table.insert(self.config.groups[category_id], group)

    return group
end

function XelosesContacts:RemoveGroup(category_id, group_id)
    self.processing = true -- indicates possibly long process started

    -- move contacts from removing group to default (first) group
    self:MoveContacts(category_id, group_id, 1)

    local i = self:getGroupIndexByID(category_id, group_id)
    table.remove(self.config.groups[category_id], i)

    self.processing = false -- indicates possibly long process ended
end
