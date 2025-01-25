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

--Get the @displayName from the current chat message where one opened the player contextMenu (if pChat is loaded and
--the pChat settings add the @displayName at the currently clicked chat message)
local function getPChatMessageDisplayName(player_name)
    --As the XelosesContacts.txt adds an optional dependency to pChat, pChat's player contextmenu should be executed before
    --XelosesContacts chat player contextmenu appears. Means: pChat will return the currently found displayName in the variable
    --pChat.lastCheckDisplayNameData = { displayName=guildMemberOrFriendDisplayname, index=guildOrFriendIndexFound, isOnline=isOnline, type = "guild" or "friend"}
    -->This variable is currently only filled if the user activated pChat settings to add the "Teleport to" context menu entries
    if pChat and pChat.lastCheckDisplayNameData then
        return pChat.lastCheckDisplayNameData.displayName
    end
    return player_name
end

function XC:SetupChatContextMenu()
    --[[
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
   ]]

   --Beartram 20250125 - Example how to use LibCustomMenu here
   --AddCustomMenuItem function accepts the same params as AddMenuItem, and LibCustomMenu supports submenus too (benefit) if needed
   local function chatPlayerContextMenuAddition(player_name, raw_Name)
       player_name = getPChatMessageDisplayName(player_name)
       local target_name = XC:validateAccountName(player_name)
       if (target_name) then
           local menu_item = XC:createContactMenuItem(target_name)
           if (menu_item) then
               AddCustomMenuItem(menu_item.name, menu_item.callback)
               ShowMenu() --shows at current MouseOverControl (where we right clicked)
           end
       end
   end
   LibCustomMenu:RegisterPlayerContextMenu(chatPlayerContextMenuAddition, LibCustomMenu.CATEGORY_LAST)
end

function XC:SetupGuildRosterContextMenu()
    --Beartram 20250125 - Do not overwrite! Use LibCustomMenu API please!
    local onMouseUp = GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp
    GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside)
    end
end

function XC:SetupGroupWindowContextMenu()
    --Beartram 20250125 - Do not overwrite! Use LibCustomMenu API please!
    local onMouseUp = GROUP_LIST.GroupListRow_OnMouseUp
    GROUP_LIST.GroupListRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside)
    end
end

function XC:SetupFriendListContextMenu()
    --Beartram 20250125 - Do not overwrite! Use LibCustomMenu API please!
    local onMouseUp = FRIENDS_LIST.FriendsListRow_OnMouseUp
    FRIENDS_LIST.FriendsListRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside, CONST.CONTACTS_FRIENDS_ID)
    end
end

function XC:SetupIgnoreListContextMenu()
    --Beartram 20250125 - Do not overwrite! Use LibCustomMenu API please!
    local onMouseUp = IGNORE_LIST.IgnoreListPanelRow_OnMouseUp
    IGNORE_LIST.IgnoreListPanelRow_OnMouseUp = function(list, control, button, upInside)
        onMouseUp(list, control, button, upInside)
        onSocilaListRowMouseUp(list, control, button, upInside, CONST.CONTACTS_VILLAINS_ID)
    end
end
