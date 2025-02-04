local T = type

-- ----------------
--  @SECTION Table
-- ----------------

local __table_mt = { __index = table }

--[[
Create a table, allow to use semicolon syntax on created table.

```
Table:new(SourceTable: table) -> Table
Table:new(...any) -> Table
```
]]
function table:new(...)
    local n = select("#", ...)
    local t = {}

    if (n == 1) then
        local a = select(1, ...)
        if (T(a) == "table") then
            t = a
        elseif (a ~= nil) then
            t = { a }
        end
    elseif (n > 1) then
        t = { ... }
    end

    return setmetatable(t, __table_mt)
end

table.join = table.concat -- alias

--[[
Returns length of the table (count of elements; does not count private members, eg. table.__xxx).

```
Table:len() -> Integer
Table:length() -> Integer
Table:count() -> Integer
```
]]
function table:len()
    local l = #self or 0

    if (l == 0) then
        for k, _ in pairs(self) do
            -- check if current element is not a private member
            if (type(k) ~= "string" or k:sub(1, 2) ~= "__") then
                l = l + 1
            end
        end
    end

    return l
end

table.length = table.len -- alias
table.count  = table.len -- alias

--[[
Returns TRUE if table is empty (does not count private members, eg. table.__xxx).

```
Table:isEmpty() -> Boolean
```
]]
function table:isEmpty()
    return self:len() == 0
end

--[[
Check if a table has specified element.

```
Table:has(any Element) -> Boolean
```
]]
function table:has(elem)
    if (#self > 0) then
        return ZO_IsElementInNumericallyIndexedTable(self, elem)
    else
        for k, v in pairs(self) do
            if (v == elem) then return true end
        end
        return false
    end
end

--[[
Returns TRUE if a table has element with specified key.

```
Table:hasKey(any Key) -> Boolean
```
]]
function table:hasKey(key)
    return (self[key] ~= nil)
end

--[[
Returns an element by it's index/key.

```
Table:get(any Key) -> any
```
]]
function table:get(key)
    return self[key]
end

--[[
Insert pair of key=value into table.

```
Table:insertElem(Key: any, Value: any) -> Table
```
]]
function table:insertElem(key, value)
    if (key ~= nil and value ~= nil) then
        self[key] = value
    end

    return self
end

--[[
Remove element with specified key from table and return element's value.

```
Table:removeElem(Key: any) -> Any
```
]]
function table:removeKey(key)
    if (#self == 0 or key == nil or not self[key]) then return end

    local val = self[key]

    if (type(key) == "number") then
        self:remove(key)
    else
        self[key] = nil
    end

    return val
end

--[[
Remove specified element from indexed table and return element's value.

```
Table:removeElem(Element: any) -> Any
```
]]
function table:removeElem(elem)
    if (#self == 0 or elem == nil) then return end

    for i, val in ipairs(self) do
        if (val == elem) then
            self:remove(i)
            return val
        end
    end
end

--[[
Get list (indexed table) of table keys.

```
Table:keys() -> Table
```
]]
function table:keys()
    local keys = table:new()
    for k, _ in pairs(self) do
        keys:insert(k)
    end

    return keys
end

--[[
Get list (indexed table) of values in table.

```
Table:values() -> Table
```
]]
function table:values()
    local values = table:new()
    for _, val in pairs(self) do
        values:insert(val)
    end

    return values
end

--[[
Search table for element with specified value, or string element matching pattern,
or specific element filtered with callback function.

Returns key and value of first matching element (or NIL if no matching elements found).

```
Table:search(value: Any) -> Any, Any
Table:search(pattern: String) -> Any, Any
Table:search(fn_filter: Function) -> Any, Any

fn_filter(value: Any) -> Boolean
```
]]
function table:search(needle)
    if (T(needle) == "function") then
        for key, val in pairs(self) do
            if (needle(val)) then
                return key, val
            end
        end
    elseif (T(needle) == "string" and needle:find("%%%l")) then
        for key, val in pairs(self) do
            local v = (T(val) == "number") and tostring(val) or val
            if (T(v) == "string" and v:match(needle)) then
                return key, val
            end
        end
    else
        for key, val in pairs(self) do
            if (needle == val) then
                return key, val
            end
        end
    end
end

--[[
Add an unpack() method for tables in Lua version lower than v5.2

```
Table.unpack() -> ...<T>
```
]]
---@diagnostic disable-next-line: deprecated
table.unpack = (T(unpack) == "function") and unpack or (T(table.unpack) == "function") and table.unpack or function(t)
    local delim = ":::"
    return zo_strsplit(delim, t:concat(delim))
end

--[[
Creates and returns clone of original table.

```
Table.clone(originalTable: Table, noMeta: Boolean) -> Table
```
]]
function table.clone(original_table, no_meta)
    local function deepcopy(t)
        -- @REF http://lua-users.org/wiki/CopyTable
        if (type(t) == "table") then
            local copy = {}
            for k, v in next, t, nil do
                copy[deepcopy(k)] = deepcopy(v)
            end

            if (not no_meta) then
                setmetatable(copy, deepcopy(getmetatable(t)))
            end

            return copy
        else
            return t -- number, string, boolean, etc
        end
    end

    return deepcopy(original_table)
end

-- -----------------
--  @SECTION String
-- -----------------

--[[
Check if string is empty.

```
String:isEmpty() -> Boolean
```
]]
function string:isEmpty()
    return (self:trim() == "")
end

--[[
Remove starting and trailing spaces from the string.

```
String:trim() -> String
```
]]
function string:trim()
    return tostring(self):gsub("^%s*(.-)%s*$", "%1")
end

--[[
Add given string to the beginning of the initial string optionally separated with space.

```
String:prepend(Str: string|number, addSpaceBetween: boolean?) -> String
```
]]
function string:prepend(str, add_space_between)
    return str .. (add_space_between and " " or "") .. tostring(self)
end

--[[
Add given string to the ending of the initial string optionally separated with space.

```
String:append(Str: string|number, addSpaceBetween: boolean?) -> String
```
]]
function string:append(str, add_space_between)
    return tostring(self) .. (add_space_between and " " or "") .. str
end

--[[
Split string using specified delimiter (or ";" by default) into table
(uses zo_strsplit() to split initial string).

```
String:split(Delimiter: string?) -> Table
```
]]
function string:split(delimiter)
    return table:new(zo_strsplit(delimiter or ";", self))
end

--[[
Case-insensitive plain string search (does not support special sequences in patterns).

```
String:imatch(Pattern: string) -> integer Start, integer End
```
]]
function string:isearch(pattern)
    return tostring(self):upper():find(pattern:upper(), 1, true)
end

--[[
Format string using zo_strformat.

```
String:zo_format(...any) -> String
```
]]
function string:zo_format(...)
    return zo_strformat(self, ...)
end

--[[
Sanitize string: collapse multiple spaces, convert "\" to "/" (to prevent using escape sequnces),
converts double quotes to single quotes, escapes spec. symbols and returns safe string;
optionally can remove all symbols except alphanumeric, underscore, dash and dot from string.

```
String:sanitize(maxLength: integer?, Strict: boolean?) -> String
```
@param integer maxLength  - [optional] Maximum length of resulting string.
@param boolean Strict     - [optional] If set to TRUE then removes all symbols except alphanumeric,
                            underscore, dash, dot and and single quotes from initial string.
                            Otherwise (by default) produce safe string by converting "\" symbols
                            to "/" (to prevent special sequences) and escape spec. symbols.
]]
function string:sanitize(max_length, strict)
    local s = tostring(self):trim()

    s = s:gsub("[ ]+", " ") -- fix multiple spaces

    if (strict) then
        s = s:gsub("[^-_'%.%w]+", "")   -- allow only english letters, numbers, underscore, dash, dot and and single quotes.
    else
        s = s:gsub("[\\]+", "/")        -- disable escape sequences
        s = s:gsub('"', "'")            -- convert double quotes
        s = ("%q"):format(s):sub(2, -2) -- produce safe string
    end

    if (max_length ~= nil and T(max_length) == "number" and max_length > 1 and s:len() > max_length) then
        s = s:sub(1, max_length)
    end

    return s
end

--[[
Return color-coded string.

```
string:colorize(hexColor: string) -> String
```
]]
function string:colorize(hex_color)
    local COLOR_FORMATTER = "|c%s%s|r"

    if (hex_color and T(hex_color) == "string" and hex_color:match("%x+")) then
        local color = (hex_color:len() > 6) and hex_color:sub(1, 6) or hex_color
        return COLOR_FORMATTER:format(color, self)
    end

    return self
end

--[[
Return string prepended with icon

```
string:addIcon(Icon: string, IconColor: string, IconSize: number, SpaceBetween: boolean) -> String
```
@param string Icon          - [optional] Icon texture (will be drawn before text).
@param string IconColor     - [optional] Color of icon (HEX color).
@param string IconSize      - [optional] Size of icon (default: 24).
@param boolean SpaceBetween - [optional] Add space between Icon and Text (default: FALSE)
]]
function string:addIcon(icon, icon_color, icon_size, space_between)
    local s = self
    local size = icon_size or 24

    if (icon) then
        local color          = (T(icon_color) == "string" and icon_color:match("%x+")) and icon_color
        local ICON_FORMATTER = color and "|t%d:%d:%s:inheritColor|t" or "|t%d:%d:%s|t"
        local str_icon       = ICON_FORMATTER:format(size, size, icon):colorize(color)

        return s:prepend(str_icon, space_between)
    end

    return s
end
