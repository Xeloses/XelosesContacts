local LCM = LibCustomMenu
local L   = XelosesContacts.getString
local F   = XelosesContacts.formatString

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContacts:SetupContextMenus()
    self:SetupChatContextMenu()
    self:SetupFriendListContextMenu()
    self:SetupIgnoreListContextMenu()
    self:SetupGuildRosterContextMenu()
    self:SetupGroupWindowContextMenu()
end

-- --------------------
--  @SECTION Menu item
-- --------------------

function XelosesContacts:CreateContactMenuItem(account_name, note, category)
    if (not account_name or self:isInContacts(account_name)) then return end

    local item = {
        name = L("MENU_ADD_CONTACT"),
    }

    if (category) then
        if (category == self.CONST.CONTACTS_FRIENDS_ID) then
            item.callback = function() self:AddContact_Friend(account_name, note) end
        elseif (category == self.CONST.CONTACTS_VILLAINS_ID) then
            item.callback = function() self:AddContact_Villain(account_name, note) end
        end
    else
        item.callback = function()
            self:AddContact(account_name, {
                category = self.config.default_category,
                note = note,
            })
        end
    end

    return item
end

function XelosesContacts:CreateContactSubmenuItem(account_name, note)
    if (not account_name or self:isInContacts(account_name)) then return end

    local entries = {
        {
            label = F(L("MENU_ADD_CONTACT_SUBMENU"), L("FRIEND")),
            callback = function() self:AddContact_Friend(account_name, note) end,
        },
        {
            label = F(L("MENU_ADD_CONTACT_SUBMENU"), L("VILLAIN")),
            callback = function() self:AddContact_Villain(account_name, note) end,
        }
    }

    return entries
end

function XelosesContacts:addContactMenuItem(data, category)
    if (not self.config.contextmenu.enabled) then return end

    local target_name = data.displayName
    if (not IsDecoratedDisplayName(target_name)) then
        target_name = self.Chat.cache:Get(target_name)
    end

    if (not target_name) then return end

    if (not self.config.contextmenu.submenu or category) then
        local menu_item = self:CreateContactMenuItem(target_name, data.note, category)
        if (menu_item) then
            return AddCustomMenuItem(menu_item.name, menu_item.callback)
        end
    else
        local submenu_entries = self:CreateContactSubmenuItem(target_name, data.note)
        if (submenu_entries) then
            return AddCustomSubMenuItem(L("MENU_ADD_CONTACT"), submenu_entries)
        end
    end
end

function XelosesContacts:addFriendMenuItem(data)
    return self:addContactMenuItem(data, self.CONST.CONTACTS_FRIENDS_ID)
end

function XelosesContacts:addVillainMenuItem(data)
    return self:addContactMenuItem(data, self.CONST.CONTACTS_VILLAINS_ID)
end

-- ----------------
--  @SECTION Menus
-- ----------------

function XelosesContacts:SetupChatContextMenu()
    LCM:RegisterPlayerContextMenu(
        function(player_name, raw_name)
            return self:addContactMenuItem({ displayName = player_name })
        end,
        LCM.CATEGORY_LAST
    )
end

function XelosesContacts:SetupFriendListContextMenu()
    LCM:RegisterFriendsListContextMenu(function(data) return self:addFriendMenuItem(data) end, LCM.CATEGORY_LAST)
end

function XelosesContacts:SetupIgnoreListContextMenu()
    LCM:RegisterIgnoreListContextMenu(function(data) return self:addVillainMenuItem(data) end, LCM.CATEGORY_LAST)
end

function XelosesContacts:SetupGuildRosterContextMenu()
    LCM:RegisterGuildRosterContextMenu(function(data) return self:addContactMenuItem(data) end, LCM.CATEGORY_LAST)
end

function XelosesContacts:SetupGroupWindowContextMenu()
    LCM:RegisterGroupListContextMenu(function(data) return self:addContactMenuItem(data) end, LCM.CATEGORY_LAST)
end
