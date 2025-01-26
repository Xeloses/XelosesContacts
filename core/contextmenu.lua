local LCM   = LibCustomMenu
local XC    = XelosesContacts
local CONST = XC.CONST
local L     = XC.getString

-- ---------------
--  @SECTION Init
-- ---------------

function XC:SetupContextMenus()
    self:SetupChatContextMenu()
    self:SetupGuildRosterContextMenu()
    self:SetupGroupWindowContextMenu()
    self:SetupFriendListContextMenu()
    self:SetupIgnoreListContextMenu()
end

-- --------------------
--  @SECTION Menu item
-- --------------------

local function createContactMenuItem(account_name, note, category)
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

local function addContactContextMenuItem(data, category)
    local target_name = XC:validateAccountName(data.displayName)
    if (target_name) then
        local menu_item = XC:createContactMenuItem(target_name, data.note, category)
        if (menu_item) then return AddCustomMenuItem(menu_item.name, menu_item.callback) end
    end
end

-- ----------------
--  @SECTION Menus
-- ----------------

local function onSocialListRowMouseUp(list, control, button, upInside, category)
    if (button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
        local data = ZO_ScrollList_GetData(control)
        local menu_item = XC:createContactMenuItem(data.displayName, data.note, category)
        if (menu_item) then AddMenuItem(menu_item.name, menu_item.callback) end
        list:ShowMenu(control)
    end
end

function XC:SetupChatContextMenu()
    LCM:RegisterPlayerContextMenu(
        function(player_name, raw_name)
            return addContactContextMenuItem({ displayName = player_name })
        end, 
        LCM.CATEGORY_LAST
    )
end

function XC:SetupGuildRosterContextMenu()
    LCM:RegisterGuildRosterContextMenu(addContactContextMenuItem, LCM.CATEGORY_LAST)
end

function XC:SetupGroupWindowContextMenu()
    LCM:RegisterGroupListContextMenu(addContactContextMenuItem, LCM.CATEGORY_LAST)
end

function XC:SetupFriendListContextMenu()
    LCM:RegisterFriendsListContextMenu(addContactContextMenuItem, LCM.CATEGORY_LAST)
end

function XC:SetupIgnoreListContextMenu()
    local onMouseUp = IGNORE_LIST.IgnoreListPanelRow_OnMouseUp
    IGNORE_LIST.IgnoreListPanelRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside, CONST.CONTACTS_VILLAINS_ID)
    end
end
