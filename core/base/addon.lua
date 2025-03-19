local T         = type

-- ---------------------------
--  @SECTION Addon definition
-- ---------------------------

XelosesContacts = XelosesContacts or {
    __namespace       = "XelosesContacts",
    __prefix          = "XELCONTACTS_",

    name              = "Xeloses' Contacts",
    displayName       = "|cee55eeXeloses|r' Contacts",
    author            = "@Savaoth",
    displayAuthorName = "|cee55eeXeloses|r (|c7799ee@Savaoth|r [PC/EU])",
    tag               = "Contacts",
    keywords          = "social contact friend villain ignore mark",
    url               = "https://www.esoui.com/downloads/info4025-XelosesContacts.html",
    url_dev           = "https://github.com/Xeloses/XelosesContacts/",
    svVersion         = 1, -- Saved Variables version

    icon              = "/esoui/art/contacts/tabicon_friends_",

    initialised       = false,
    loaded            = false,
    processing        = false,

    accountID         = 0,
    characterID       = 0,
    zoneID            = 0,
    zoneInfo          = {},
    inCombat          = false,
    inGroup           = false,

    UI                = { isReady = false },
    Chat              = {},
    Game              = {},

    debug             = true,
}

-- ------------------
--  @SECTION Utility
-- ------------------

function XelosesContacts.getString(str)
    if (T(str) == "string") then
        local s = XelosesContacts.__prefix .. str
        return _G[s] and GetString(_G[s]) or str
    elseif (T(str) == "number") then
        return GetString(str)
    else
        return "<<MISSING_STRING>>"
    end
end

-- create global string with Addon name (used within XML)
ZO_CreateStringId(XelosesContacts.__prefix .. "ADDON_NAME", XelosesContacts.displayName)
