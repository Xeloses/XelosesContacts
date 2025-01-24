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

---@private
function XC:createContactMenuItem(account_name, note, category)
    if (self:isInContacts(account_name)) then return end
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

-- ----------------
--  @SECTION Menus
-- ----------------

local function onSocilaListRowMouseUp(list, control, button, upInside, category)
    if (button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
        local data = ZO_ScrollList_GetData(control)
        local menu_item = XC:createContactMenuItem(data.displayName, data.note, category)
        if (menu_item) then AddMenuItem(menu_item.name, menu_item.callback) end
        list:ShowMenu(control)
    end
end

function XC:SetupChatContextMenu()
    local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
    CHAT_SYSTEM.ShowPlayerContextMenu = function(chat, player_name, raw_name)
        local menu = ShowPlayerContextMenu(chat, player_name, raw_name)
        local target_name = XC:validateAccountName(player_name)
        if (target_name) then
            local menu_item = XC:createContactMenuItem(target_name)
            if (menu_item) then AddMenuItem(menu_item.name, menu_item.callback) end
        end
        ShowMenu(chat)
        return menu
    end
end

function XC:SetupGuildRosterContextMenu()
    local onMouseUp = GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp
    GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside)
    end
end

function XC:SetupGroupWindowContextMenu()
    local onMouseUp = GROUP_LIST.GroupListRow_OnMouseUp
    GROUP_LIST.GroupListRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside)
    end
end

function XC:SetupFriendListContextMenu()
    local onMouseUp = FRIENDS_LIST.FriendsListRow_OnMouseUp
    FRIENDS_LIST.FriendsListRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside, CONST.CONTACTS_FRIENDS_ID)
    end
end

function XC:SetupIgnoreListContextMenu()
    local onMouseUp = IGNORE_LIST.IgnoreListPanelRow_OnMouseUp
    IGNORE_LIST.IgnoreListPanelRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside, CONST.CONTACTS_VILLAINS_ID)
    end
end
