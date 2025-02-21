local T = type

-- ---------------
--  @SECTION Init
-- ---------------

XelosesContactsChatCache = ZO_Object:Subclass()

function XelosesContactsChatCache:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function XelosesContactsChatCache:Initialize(parent, params)
    self.tag    = "chat_cache"
    self.parent = parent

    self.db     = {}
    -- self.db.accounts   = { [n] = "AccountName1", [n+1] = "AccountName2", ... }                              -- // indexed table
    -- self.db.characters = { ["CharacterName1"] = n, ["CharacterName2"] = n, ["CharacterName3"] = n+1,  ... } -- // assoc. table
    self:Reset()

    self.enabled  = params.enabled
    self.maxsize  = params.maxsize or 100                                    -- max cached accounts
    self.channels = params.channels or self.parent.CONST.CHAT.CACHE.CHANNELS -- monitored chat channels

    self.limits   = {
        min = self.parent.CONST.CHAT.CACHE.MIN_SIZE,
        max = self.parent.CONST.CHAT.CACHE.MAX_SIZE,
    }

    ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(...) return self.handleChatMessage(self, ...) end)
end

-- -----------------
--  @SECTION PUBLIC
-- -----------------

function XelosesContactsChatCache:IsEnabled()
    return self.enabled
end

function XelosesContactsChatCache:Enable()
    self.enabled = true
end

function XelosesContactsChatCache:Disable()
    self.enabled = false
    self:Reset()
end

function XelosesContactsChatCache:Toggle(enabled)
    if (enabled == nil) then
        enabled = not self.enabled -- toggle (invert) current state
    end

    if (enabled) then
        self:Enable()
    else
        self:Disable()
    end
end

function XelosesContactsChatCache:SetMaxSize(size)
    if (size < self.limits.min) then
        size = self.limits.min
    elseif (size > self.limits.max) then
        size = self.limits.max
    end

    self.maxsize = size

    while (self.maxsize < self.size) do
        self:RemoveOldest()
    end
end

-- ---------------
--  @SECTION DATA
-- ---------------

function XelosesContactsChatCache:Get(character_name)
    local i = self.db.characters[character_name]
    return i and self.db.accounts[i]
end

function XelosesContactsChatCache:Add(account_name, character_name)
    if (self.db.characters:has(character_name)) then return end

    local i = self.db.accounts:getKey(account_name, true)
    if (not i) then
        -- check cache size
        if (self.size >= self.maxsize) then
            self:RemoveOldest() -- remoove oldest record
        end

        self.db.accounts:insert(account_name)
        self.size = self.size + 1
        i = self.db.accounts:len()
    end

    self.db.characters:insertElem(character_name, i)
end

function XelosesContactsChatCache:Remove(account_name_or_index)
    local i

    local t = T(account_name_or_index)

    if (t == "string") then
        i = self.db.accounts:getKey(account_name_or_index, true)
    elseif (t == "number") then
        i = account_name_or_index
    end
    if (not i or not self.db.accounts[i]) then return end

    for char_name, account_index in pairs(self.db.characters) do
        -- remove related records from characters cache
        if (account_index == i) then
            self.db.characters:removeKey(char_name)
        end
    end

    -- remove record from accounts cache
    self.db.accounts[i] = nil
    self.size = self.size - 1
end

function XelosesContactsChatCache:RemoveOldest()
    -- remove oldest (first) record from cache
    local i = next(self.db.accounts, nil) -- get index of first element
    self:Remove(i)
end

function XelosesContactsChatCache:Reset()
    -- reset/clear cache
    self.db.accounts   = table:new()
    self.db.characters = table:new()
    self.size          = 0
end

-- --------------------------
--  @SECTION Chat monitoring
-- --------------------------

function XelosesContactsChatCache:handleChatMessage(_, event_code, channel, from_name, raw_message_text, is_customer_service, from_display_name)
    if (not self.enabled) then return end
    if (event_code ~= EVENT_CHAT_MESSAGE_CHANNEL or
            not self.channels[channel] or                    -- check chat channel
            is_customer_service or                           -- skip customer service messages
            not from_name or                                 -- check character name
            not from_display_name or
            not IsDecoratedDisplayName(from_display_name) or -- check account name
            from_name == from_display_name or
            from_display_name == self.accountName            -- do not process self
        ) then
        return
    end

    local from_char_name = zo_strformat(SI_UNIT_NAME, from_name)
    self:Add(from_display_name, from_char_name)
end
