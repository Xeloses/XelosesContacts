local EM  = GetEventManager()
local LSV = LibSavedVars
local LEJ = LibExtendedJournal

LEJ.Used  = true -- libExtendedJournal usage flag (required by the library)

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContacts:Initialize()
    self:getAddonVersionFromManifest()

    self:InitLibs()
    if (self.log) then self.log:SetEnabled(true) end

    self.LNG           = GetCVar("language.2") -- en / de / fr / es / it / jp / ru
    self.accountName   = GetDisplayName()
    self.characterID   = GetCurrentCharacterId()
    self.characterName = GetUnitName("player")

    self.defaults      = self:getDefaultSettings()
    self.SV            = LSV:NewAccountWide(self.__namespace .. "Data", self.svVersion, "Account", { config = self.defaults, contacts = {}, }, nil, "$MultiAccountWide"):EnableDefaultsTrimming()
    self.config        = self.SV.config
    self:UpdateConfig()

    self:LoadContacts()

    self:InitCache()
    self:InitHooks()

    self:InitDialogs()
    self:InitUI()

    self:SetupContextMenus()
    self:CreateSlashCmd()
    self:CreateConfigMenu()

    self.initialised = true
end

-- ------------------
--  @SECTION Loading
-- ------------------

function XelosesContacts:onCharacterLoaded()
    EM:UnregisterForEvent(self.__namespace .. "RunOnce", EVENT_PLAYER_ACTIVATED)

    if (not self.loaded) then
        self.loaded = true
        self:Log("%s v%s loaded.", self.name, self:getVersion())
    end

    self.inGroup = IsUnitGrouped("player")
    self:onZoneChange()
    self:SetupHook("ZoneChange")
end

function XelosesContacts:onAddonLoaded(_, addon_name)
    if (addon_name ~= self.__namespace) then return end
    EM:UnregisterForEvent(self.__namespace, EVENT_ADD_ON_LOADED)

    self:Initialize()

    EM:RegisterForEvent(self.__namespace .. "RunOnce", EVENT_PLAYER_ACTIVATED, function() self:onCharacterLoaded() end)
end

EM:RegisterForEvent(XelosesContacts.__namespace, EVENT_ADD_ON_LOADED,
    function(event_id, addon_name)
        XelosesContacts:onAddonLoaded(event_id, addon_name)
    end
)
