local XC           = XelosesContacts
local CONST        = XC.CONST
local L            = XC.getString
local T            = type

---@diagnostic disable-next-line: deprecated
local table_unpack = (T(table.unpack) == "function") and table.unpack or unpack -- workaround for function changes in Lua vearsion 5.2+

-- ---------------
--  @SECTION Libs
-- ---------------

---@private
function XC:InitLibs()
    if (LibChatMessage ~= nil) then
        self.Chat.lib = LibChatMessage(self.tag, self.tag)
    end

    if (LibDebugLogger ~= nil) then
        self.logger = LibDebugLogger(self.__namespace)
    end
end

-- ----------------------
--  @SECTION Log / Debug
-- ----------------------

function XC:Log(msg, ...)
    if (not self.logger) then return end
    self.logger:Info(msg, ...)
end

function XC:LogWarning(msg, ...)
    if (not self.logger) then return end
    self.logger:Warn(msg, ...)
end

function XC:LogError(msg, ...)
    if (not self.logger) then return end
    self.logger:Error(msg, ...)
end

function XC:Debug(msg, ...)
    if (not self.logger or not self.debug) then return end
    self.logger:Debug(msg, ...)
end

-- ------------------
--  @SECTION Strings
-- ------------------

--[[
Format string with params.
Replaces special patterns with corresponding strings, and returns resulting string.

```
XelosesContacts.formatString(Str: string, ...any)
XelosesContacts.formatString(Str: string, Contact: table, any ...)
XelosesContacts.formatString(Str: string, FormatParams: table)
```
@param string Str         - Initial string to be formatted. May contain patterns for replacement.
                            Supports all patterns of string.format() and indexed params
                            (eg. <<1>>, <<2>>, etc).
                            Does not support mixed kinds of params (eg. both "%s" and "<<1>>" in the
                            same pattern).
@param table Contact      - [optional] If present the Contact will be used to replace following
                            patterns:
                                <<NAME>>  - account name,
                                <<LINK>>  - account link,
                                <<TYPE>>  - contact type (Friend or Villain),
                                <<GROUP>> - contact's group name,
                                <<ICON>>  - contact's group icon.
                            Patterns are case insensitive, but if whole word written in uppercase
                            (eg, <<NAME>>) then pattern will be replaces with colorized string
                            using the color of contact's group.
                            Otherwise (eg, <<Name>> or <<name>>) it will not be colorized.
@param table FormatParams - [optional] Table with format params. May contain following fields:
                            contact    - same as above,
                            textParams - list of params to be used to replace common patterns
                            (eg. %s, %d, <<1>>, <<2>>, etc).
@param any ...            - [optional] Arguments for string formatting.
]]
function XC.formatString(str, ...)
    local _t = T(str)
    if (_t ~= "string" and _t ~= "number" or str == "") then return "" end

    local result = str
    if (_t == "number" and _G[str]) then
        result = GetString(str)
    end

    local params = table:new({ ... })
    local contact
    local n = params:len()
    local a = (n > 0) and params:get(1)

    if (T(a) == "table") then
        if (a.account) then
            contact = XC:getContactData(a.account)
            params:remove(1)
        else
            if (T(a.contact) == "table" and a.contact.account) then
                contact = a.contact
            end

            if (T(a.textParams) == "table" and #a.textParams) then
                params = a.textParams
            else
                params = table:new()
            end
        end
    end

    if (contact) then
        result = result:gsub("<<(%u+)>>", function(s)
            local placeholder = s:upper()
            local colorize = (s == placeholder)
            local placeholders = {
                ["NAME"]  = function() return XC:getContactName(contact, colorize) end,
                ["LINK"]  = function() return XC:getContactLink(contact, colorize) end,
                ["TYPE"]  = function() return XC:getContactCategoryName(contact, colorize) end,
                ["GROUP"] = function() return XC:getContactGroupName(contact, colorize) end,
                ["ICON"]  = function() return XC:getContactGroupIcon(contact, colorize) end,
            }

            return placeholders[placeholder]() or "<<Incorrect placeholder>>"
        end)
    end

    if (params and #params > 0) then
        if (result:find("<<%d>>")) then
            result = result:zo_format(params:unpack())
        elseif (result:find("[^%%]+%%[a-z]") or result:find("^%%[a-z]")) then
            result = result:format(params:unpack())
        end
    end

    return result
end

local F = XC.formatString

--[[
Creates clickable account link from account name.

```
XelosesContacts:getAccountLink(AccountName: string)
```
]]
function XC:getAccountLink(account_name)
    return ZO_LinkHandler_CreateDisplayNameLink(account_name)
end

--[[
Creates clickable character link from character name.

```
XelosesContacts:getCharacterLink(CharacterName: string)
```
]]
function XC:getCharacterLink(character_name)
    return ZO_LinkHandler_CreateCharacterLink(character_name)
end

-- --------------------
--  @SECTION Date/Time
-- --------------------

--[[
Returns string with formatted date/time (YYYY-MM-DD HH:mm).

```
XelosesContacts:formatTimestamp(Timestamp: number)
```
]]
function XC:formatTimestamp(t)
    if (t and t > 0) then
        return os.date("%Y-%m-%d %H:%M", t)
    else
        return "(unknown)"
    end
end

-- -------------
--  @SECTION UI
-- -------------

function XC:SetControlTooltip(control, tooltip_text)
    local str = L(tooltip_text)
    control:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(control, TOP, str) end)
    control:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
end

-- --------------------------
--  @SECTION Data management
-- --------------------------

function XC:FlushData()
    GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(self.__namespace)
end

-- ---------------------
--  @SECTION Validation
-- ---------------------

function XC:validateAccountName(name, noStrictTest)
    if (T(name) == "string" and not name:isEmpty()) then
        name = zo_strformat("<<C:1>>", name)

        if (name == self.accountName) then return end -- do not process local player
        if (name:sub(1, 1) ~= "@") then return end

        local s = name:sub(2)
        local l = s:len()

        -- account name may have only 3..20 symbols
        if (l < CONST.ACCOUNT_NAME_MIN_LENGTH or l > CONST.ACCOUNT_NAME_MAX_LENGTH) then return end

        if (not noStrictTest) then
            -- account name may contain only letters, numbers, dot, dash, single quote, underscore
            if (s:find("[~`@!#$^&*({})=+:;\",<>/?|%\\%[%]%%]+")) then return end

            -- account name may contain only 1 non-alphanumeric symbol (dot, dash, single quote or underscore)
            if (s ~= s:match("^[^_'-%.]+[_'-%.]?[^_'-%.]+$")) then return end
        end

        return name
    end
end

-- -----------------
--  @SECTION Service
-- -----------------

--[[
Returns string prepended with colorized addon tag.
```
@return string
```
]]
---@private
function XC:addPrefix(str)
    local prefix = "[" .. self.tag .. "]"
    return prefix:colorize(self.colors.tag) .. " " .. str
end

--[[
Returns formatted addon version.
```
@return string
```
]]
function XC:getVersion()
    local vMajor = math.floor(self.version / 10000)
    local vMinor = math.floor((self.version - vMajor * 10000) / 100)
    local vPatch = math.floor(self.version - vMajor * 10000 - vMinor * 100)
    return ("%d.%d.%d"):format(vMajor, vMinor, vPatch)
end

--[[
Retrieves and returns addon version from manifest file.
```
@return number
```
]]
---@private
function XC:getAddonVersionFromManifest()
    local AM = GetAddOnManager()
    local addons_count = AM:GetNumAddOns()
    local addon_name

    for i = 1, addons_count do
        addon_name = AM:GetAddOnInfo(i)
        if (addon_name == self.__namespace) then
            local v = AM:GetAddOnVersion(i)
            self.version = v
            return v
        end
    end

    return self.version or 1 -- Fallback: return default version
end
