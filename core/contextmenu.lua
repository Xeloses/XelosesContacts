local LCM   = LibCustomMenu
local XC    = XelosesContacts
local CONST = XC.CONST
local L     = XC.getString

-- ---------------
--  @SECTION Init
-- ---------------

function XC:SetupContextMenus()
    self:SetupChatContextMenu()
    self:SetupFriendListContextMenu()
    self:SetupIgnoreListContextMenu()
    self:SetupGuildRosterContextMenu()
    self:SetupGroupWindowContextMenu()
end

-- --------------------
--  @SECTION Menu item
-- --------------------

---@private
function XC:CreateContactMenuItem(account_name, note, category)
    if (not account_name or self:isInContacts(account_name)) then return end
    local item = { name = L("MENU_ADD_CONTACT") }
    if (category) then
        if (category == CONST.CONTACTS_FRIENDS_ID) then
            item.callback = function() self:AddContact_Friend(account_name, note) end
        elseif (category == CONST.CONTACTS_VILLAINS_ID) then
            item.callback = function() self:AddContact_Villain(account_name, note) end
        end
    else
        item.callback = function() self:AddContact(account_name, { note = note }) end
    end
    return item
end

local function addContactMenuItem(data, category)
    local target_name = XC:validateAccountName(data.displayName)
    if (target_name) then
        local menu_item = XC:CreateContactMenuItem(target_name, data.note, category)
        if (menu_item) then return AddCustomMenuItem(menu_item.name, menu_item.callback) end
    end
end

local function addFriendMenuItem(data)
    return addContactMenuItem(data, CONST.CONTACTS_FRIENDS_ID)
end

local function addVillainMenuItem(data)
    return addContactMenuItem(data, CONST.CONTACTS_VILLAINS_ID)
end

-- ----------------
--  @SECTION Menus
-- ----------------

function XC:SetupChatContextMenu()
    LCM:RegisterPlayerContextMenu(
        function(player_name, raw_name)
            return addContactMenuItem({ displayName = player_name })
        end,
        LCM.CATEGORY_LAST
    )
end

function XC:SetupFriendListContextMenu()
    LCM:RegisterFriendsListContextMenu(addFriendMenuItem, LCM.CATEGORY_LAST)
end

function XC:SetupIgnoreListContextMenu()
    LCM:RegisterIgnoreListContextMenu(addVillainMenuItem, LCM.CATEGORY_LAST)
end

function XC:SetupGuildRosterContextMenu()
    LCM:RegisterGuildRosterContextMenu(addContactMenuItem, LCM.CATEGORY_LAST)
end

function XC:SetupGroupWindowContextMenu()
    LCM:RegisterGroupListContextMenu(addContactMenuItem, LCM.CATEGORY_LAST)
end
