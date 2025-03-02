local XC = XelosesContacts

-- -----------------
--  @SECTION Public
-- -----------------

function XC:ImportESOFriends(target_group)
    self:ImportESOList(self.CONST.CONTACTS_FRIENDS_ID, target_group)
end

function XC:ImportESOIgnored(target_group)
    self:ImportESOList(self.CONST.CONTACTS_VILLAINS_ID, target_group)
end

-- -----------------
--  @SECTION Import
-- -----------------

function XC:ImportESOList(category, target_group)
    if (self.processing) then return end

    local group = target_group or 1
    local contact_data
    local n = 0
    local cnt = 0
    local getInfo

    if (category == self.CONST.CONTACTS_FRIENDS_ID) then
        n = GetNumFriends()
        getInfo = GetFriendInfo
    elseif (category == self.CONST.CONTACTS_VILLAINS_ID) then
        n = GetNumIgnored()
        getInfo = GetIgnoredInfo
    end

    if (not getInfo) then
        self:Debug("ImportContacts ERROR: incorrect category")
        return false
    end

    if (n == 0) then
        self:Debug("ImportContacts ERROR: nothing to import (0 players in list)")
        return false
    end

    self.processing = true -- indicate import process is running

    for i = 1, n do
        local display_name, note = getInfo(i)
        if (display_name) then
            if (not self:isInContacts(display_name)) then
                contact_data = {
                    account = display_name,
                    category = category,
                    group = group,
                    note = (note ~= "") and note or nil,
                }

                self:SaveContact(contact_data, true)
                cnt = cnt + 1
            end
        end
    end

    self:RefreshContactsList()

    self.processing = false -- indicate import process completed

    -- @LOG Import contacts
    local s = ((category == self.CONST.CONTACTS_FRIENDS_ID) and "friends") or ((category == self.CONST.CONTACTS_VILLAINS_ID) and "ignored players") or "<Unknown category>"
    self:Log("Import ESO ingame %s completed: added %d contacts.", s, cnt)
    zo_callLater( -- use async call to show dialog if function was called from another dialog callback
        function()
            self:ShowDialog(self.CONST.UI.DIALOGS.NOTIFY_IMPORT_COMPLETED, cnt)
        end,
        30
    )

    return true
end
