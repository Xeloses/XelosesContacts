local NAME = "LibCodesCommonCode"
local VERSION = 25

if (type(_G[NAME]) == "table" and type(_G[NAME].version) == "number" and _G[NAME].version >= VERSION) then return end

local Lib = { version = VERSION }
_G[NAME] = Lib


--------------------------------------------------------------------------------
-- Scope Localizations
--------------------------------------------------------------------------------

local EVENT_MANAGER = EVENT_MANAGER
local BitAnd = BitAnd
local BitOr = BitOr
local BitLShift = BitLShift
local BitRShift = BitRShift
local zo_floor = zo_floor
local zo_plainstrfind = zo_plainstrfind
local zo_strformat = zo_strformat
local zo_strlen = zo_strlen
local zo_strsub = zo_strsub
local zo_min = zo_min
local zo_max = zo_max
local SafeAddVersion = SafeAddVersion
local SafeAddString = SafeAddString
local ZO_CreateStringId = ZO_CreateStringId


--------------------------------------------------------------------------------
-- Color Conversions
--------------------------------------------------------------------------------

do
	local function i2c( n, pos )
		return BitAnd(BitRShift(n, pos), 0xFF) / 255
	end

	local function c2i( n, pos )
		return BitLShift(BitAnd(n * 255, 0xFF), pos)
	end

	function Lib.Int24ToRGB( rgb )
		return i2c(rgb, 16), i2c(rgb, 8), i2c(rgb, 0)
	end

	function Lib.Int24ToRGBA( rgb )
		return i2c(rgb, 16), i2c(rgb, 8), i2c(rgb, 0), 1
	end

	function Lib.Int32ToRGBA( rgba )
		return i2c(rgba, 24), i2c(rgba, 16), i2c(rgba, 8), i2c(rgba, 0)
	end

	function Lib.RGBToInt24( r, g, b )
		return c2i(r, 16) + c2i(g, 8) + c2i(b, 0)
	end

	function Lib.RGBAToInt32( r, g, b, a )
		return c2i(r, 24) + c2i(g, 16) + c2i(b, 8) + c2i(a, 0)
	end

	function Lib.Int24ToInt32( rgb, a )
		return BitOr(BitLShift(rgb, 8), a or 0xFF)
	end

	function Lib.Int32ToInt24( rgba )
		return BitRShift(rgba, 8)
	end

	local function h2c( p, q, t )
		t = t - zo_floor(t)
		if (t < 1/6) then return p + (q - p) * 6 * t end
		if (t < 1/2) then return q end
		if (t < 2/3) then return p + (q - p) * (2/3 - t) * 6 end
		return p
	end

	function Lib.HSLToRGB( h, s, l, a )
		if (s == 0) then
			return l, l, l, a
		else
			local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
			local p = 2 * l - q
			return h2c(p, q, h + 1/3), h2c(p, q, h), h2c(p, q, h - 1/3), a
		end
	end
end


--------------------------------------------------------------------------------
-- 6-Bit Encode/Decode
--------------------------------------------------------------------------------

do
	local DICT = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#%"

	function Lib.Encode( number, size )
		-- Values for size:
		-- 0: Pad result to an even number of bytes (the number 0 will encode to an empty string)
		-- n: Pad result to a minimum length of n bytes
		-- nil: Do not pad results (the number 0 will encode to an empty string)

		local result = ""

		while (number > 0) do
			local p = (number % 0x40) + 1
			result = zo_strsub(DICT, p, p) .. result
			number = zo_floor(number / 0x40)
		end

		-- Pad result as necessary
		if (size == 0) then
			if (zo_strlen(result) % 2 == 1) then
				result = zo_strsub(DICT, 1, 1) .. result
			end
		elseif (size) then
			local padding = size - zo_strlen(result)
			if (padding > 0) then
				result = string.rep(zo_strsub(DICT, 1, 1), padding) .. result
			end
		end

		return result
	end

	function Lib.Decode( code )
		local result = 0

		for i = 1, zo_strlen(code) do
			local found, p = zo_plainstrfind(DICT, zo_strsub(code, i, i))
			if (not found) then return 0 end
			result = (result * 0x40) + (p - 1)
		end

		return result
	end

	function Lib.ReadAndDecode( encoded, pos, bytes )
		local newPos = pos + bytes
		return Lib.Decode(zo_strsub(encoded, pos, newPos - 1)), newPos
	end
end


--------------------------------------------------------------------------------
-- Consolidator for 6-Bit Encoded Data
--------------------------------------------------------------------------------

do
	-- 12th bit (0x800) is a flag
	-- Lower 11 bits encode the length, for a maximum of 0x7FF

	local function consolidate( str, char, flag )
		local result = string.gsub(str, string.format("(%s+)", string.rep(char, 4)), function( capture )
			local length = zo_strlen(capture)
			if (length <= 0x7FF) then
				return "~" .. Lib.Encode(0x800 * flag + length, 2)
			else
				local encoded = ""
				repeat
					local chunk = (length <= 0x7FF) and length or 0x7FF
					encoded = encoded .. "~" .. Lib.Encode(0x800 * flag + chunk, 2)
					length = length - chunk
				until length <= 0
				return encoded
			end
		end)
		return result
	end

	function Lib.Implode( str )
		return consolidate(consolidate(str, "0", 0), "%%", 1)
	end

	function Lib.Explode( str )
		local result = string.gsub(str, "~(..)", function( capture )
			local code = Lib.Decode(capture)
			return string.rep((BitRShift(code, 11) == 0) and "0" or "%", BitAnd(code, 0x7FF))
		end)
		return result
	end
end


--------------------------------------------------------------------------------
-- String Chunk/Unchunk
--
-- Accommodation for the 2000-byte limit for strings in saved variables
--------------------------------------------------------------------------------

do
	local DEFAULT_CHUNK_SIZE = 0x600

	function Lib.Chunk( str, chunkSize )
		if (type(chunkSize) ~= "number") then
			chunkSize = DEFAULT_CHUNK_SIZE
		end

		local length = zo_strlen(str)
		if (length <= chunkSize) then
			return str
		else
			local result = { }
			local i, j = 1
			while (i <= length) do
				j = i + chunkSize
				table.insert(result, zo_strsub(str, i, j - 1))
				i = j
			end
			return result
		end
	end

	function Lib.Unchunk( chunked )
		if (type(chunked) == "string") then
			return chunked
		elseif (type(chunked) == "table") then
			return table.concat(chunked, "")
		else
			return ""
		end
	end
end


--------------------------------------------------------------------------------
-- Concise Server Name
--------------------------------------------------------------------------------

do
	local name = zo_strsplit(" ", GetWorldName())

	function Lib.GetServerName( )
		return name
	end
end


--------------------------------------------------------------------------------
-- Wrapper for initial EVENT_PLAYER_ACTIVATED
--------------------------------------------------------------------------------

do
	local id = 0

	function Lib.RunAfterInitialLoadscreen( func )
		id = id + 1
		local name = string.format("%s%d_%d", NAME, VERSION, id)
		EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function( ... )
			EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)
			func(...)
		end)
	end
end


--------------------------------------------------------------------------------
-- Zone Functions
--------------------------------------------------------------------------------

do
	local name = string.format("%s%d_ZoneChange", NAME, VERSION)
	local callbacks = { }
	local registered = false
	local zoneId, difficulty

	local function onPlayerActivated( )
		local previousZoneId = zoneId
		local currentZoneId = Lib.GetZoneId()
		local currentDifficulty = GetCurrentZoneDungeonDifficulty()

		if (zoneId ~= currentZoneId or difficulty ~= currentDifficulty) then
			zoneId = currentZoneId
			difficulty = currentDifficulty
			for _ , callback in pairs(callbacks) do
				callback(currentZoneId, previousZoneId or 0)
			end
		end
	end

	-- Omit the callback parameter to unregister
	function Lib.MonitorZoneChanges( id, callback )
		callbacks[id] = callback
		if (not registered and next(callbacks)) then
			registered = true
			EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
		end
	end

	function Lib.GetZoneId( )
		return GetZoneId(GetUnitZoneIndex("player"))
	end

	function Lib.GetZoneName( zoneId, useFallback )
		local name = GetZoneNameById(zoneId)
		if (useFallback and name == "") then
			return string.format("[#%d]", zoneId)
		else
			return zo_strformat(SI_ZONE_NAME, name)
		end
	end
end


--------------------------------------------------------------------------------
-- Slash Command Helpers
--------------------------------------------------------------------------------

function Lib.RegisterSlashCommands( func, ... )
	for _, command in ipairs({ ... }) do
		SLASH_COMMANDS[command] = func
	end
	return func
end

function Lib.TokenizeSlashCommandParameters( params )
	local tokens = { }
	if (type(params) == "string") then
		for _, token in ipairs({ zo_strsplit(" ", zo_strlower(params)) }) do
			tokens[token] = true
		end
	end
	return tokens
end


--------------------------------------------------------------------------------
-- Table Functions
--------------------------------------------------------------------------------

function Lib.GetSortedKeys( tbl, first )
	local keys = { }
	for key in pairs(tbl) do
		table.insert(keys, key)
	end
	table.sort(keys, function( a, b )
		if (a == first) then
			return true
		elseif (b == first) then
			return false
		else
			return a < b
		end
	end)
	return keys
end

function Lib.CountTable( tbl )
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

function Lib.ProcessNumericTable( tbl, fn, ... )
	local index = 0
	local prev = 0
	for _, i in ipairs(tbl) do
		local isNumber = type(i) == "number"
		if (isNumber and i < 0) then
			for j = prev + 1, -i do
				index = index + 1
				fn(j, index, ...)
			end
		else
			index = index + 1
			fn(i, index, ...)
			if (isNumber) then
				prev = i
			end
		end
	end
end


--------------------------------------------------------------------------------
-- Convert number-like strings to numbers
--------------------------------------------------------------------------------

function Lib.FixNumber( a )
	if (type(a) == "string" and string.find(a, "^[+-]?[%.%d]*%d$")) then
		return tonumber(a)
	else
		return a
	end
end


--------------------------------------------------------------------------------
-- Clamp a number to a range
--------------------------------------------------------------------------------

function Lib.Clamp( number, min, max )
	return zo_min(zo_max(number, min), max)
end


--------------------------------------------------------------------------------
-- Are two strings identical, ignoring case and formatting flags?
--------------------------------------------------------------------------------

function Lib.MatchStrings( a, b )
	return zo_strformat("<<z:1>>", a) == zo_strformat("<<z:1>>", b)
end


--------------------------------------------------------------------------------
-- Localization Functions
--------------------------------------------------------------------------------

function Lib.RegisterString( id, text, version )
	if (_G[id]) then
		SafeAddString(_G[id], text, version or 1)
	else
		ZO_CreateStringId(id, text)
		if (version) then
			SafeAddVersion(_G[id], version)
		end
	end
end

function Lib.GetLocalizedData( data )
	if (type(data) == "table") then
		return data[GetCVar("Language.2")] or data.default
	end
end


--------------------------------------------------------------------------------
-- Get a list of group members that is sorted by role and name
--------------------------------------------------------------------------------

do
	local ROLE_ORDER = {
		[LFG_ROLE_TANK] = 1,
		[LFG_ROLE_HEAL] = 2,
		[LFG_ROLE_DPS] = 3,
		[LFG_ROLE_INVALID] = 4,
	}

	function Lib.GetSortedGroupMembers( )
		local groupSize = GetGroupSize()

		if (groupSize > 0) then
			local units = { }

			for i = 1, groupSize do
				local unitTag = GetGroupUnitTagByIndex(i)
				if (unitTag) then
					table.insert(units, {
						unitTag = unitTag,
						account = GetUnitDisplayName(unitTag),
						name = GetUnitName(unitTag),
						role = GetGroupMemberSelectedRole(unitTag),
						class = GetUnitClassId(unitTag),
					})
				end
			end

			table.sort(units, function( a, b )
				local ra = ROLE_ORDER[a.role]
				local rb = ROLE_ORDER[b.role]
				if (ra == rb) then
					return a.account < b.account
				else
					return ra < rb
				end
			end)

			return units
		else
			-- Ungrouped
			return { {
				unitTag = "player",
				account = GetDisplayName(),
				name = GetUnitName("player"),
				role = GetSelectedLFGRole(),
				class = GetUnitClassId("player"),
			} }
		end
	end
end


--------------------------------------------------------------------------------
-- Versioning
--------------------------------------------------------------------------------

function Lib.GetAddOnVersion( name )
	local am = GetAddOnManager()
	for i = 1, am:GetNumAddOns() do
		if (am:GetAddOnInfo(i) == name) then
			return am:GetAddOnVersion(i)
		end
	end
	return nil
end

function Lib.FormatVersion( version )
	local fields = { }
	if (type(version) == "number") then
		for i, base in ipairs({ 10, 100, 100, 10000 }) do
			fields[5 - i] = version % base
			version = zo_floor(version / base)
		end
		if (fields[4] == 0) then
			fields[4] = nil
		end
	end
	return table.concat(fields, ".")
end


--------------------------------------------------------------------------------
-- Link Handling
--------------------------------------------------------------------------------

do
	local callbacks = { }
	local registered = false

	local function linkClicked( _, _, _, _, tag, ... )
		if (type(tag) == "string" and callbacks[tag]) then
			callbacks[tag](...)
			return true
		end
	end

	-- Omit the callback parameter to unregister
	function Lib.RegisterLinkHandler( tag, callback )
		callbacks[tag] = callback
		if (not registered and next(callbacks)) then
			registered = true
			LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, linkClicked)
			LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, linkClicked)
		end
	end
end
