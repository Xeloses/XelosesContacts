local L = XelosesContacts.getString
local T = type

-- ----------------------------
--  @SECTION Contacts category
-- ----------------------------

function XelosesContacts:getCategoryName(category_id)
    return self.CONST.CONTACTS_CATEGORIES[category_id]
end

function XelosesContacts:getCategoryColor(category_id)
    return self.config.colors[category_id] or self.CONST.COLOR.DEFAULT
end

-- -------------------------
--  @SECTION Contacts group
-- -------------------------

function XelosesContacts:getGroupName(category_id, group_id)
    return self.config.groups[category_id] and self.config.groups[category_id][group_id]
end

function XelosesContacts:getGroupIcon(category_id, group_id)
    if (not self.CONST.ICONS.GROUPS[category_id] or not self.CONST.ICONS.GROUPS[category_id][group_id]) then return end
    return self.CONST.ICONS.GROUPS[category_id][group_id]
end

function XelosesContacts:getGroupsList(category_id, with_icons, colorized)
    local result = table:new()
    if (not self.CONST.CONTACTS_CATEGORIES[category_id]) then return result end

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

-- ---------------------------
--  @SECTION Checkups / Tests
-- ---------------------------

function XelosesContacts:isChatBlockedForGroup(group_id)
    return (group_id ~= nil) and self.config.chat.block_groups[group_id]
end

function XelosesContacts:validateContactCategory(category_id)
    return (category_id ~= nil and self.CONST.CONTACTS_CATEGORIES[category_id] ~= nil)
end

function XelosesContacts:validateContactGroup(category_id, group_id)
    return (self:validateContactCategory(category_id) and group_id ~= nil and self.config.groups[category_id][group_id] ~= nil)
end
