local EM  = GetEventManager()
local LSV = LibSavedVars
local LEJ = LibExtendedJournal
local XC  = XelosesContacts

-- ---------------
--  @SECTION Init
-- ---------------

function XC:Init()
    self:getAddonVersionFromManifest()

    self:InitLibs()
    if (self.log) then self.log:SetEnabled(true) end

    self.SV = LSV:NewAccountWide(self.__namespace .. "Data", self.svVersion, "Account", { config = self.defaults, contacts = {}, }, nil, "$MultiAccountWide"):EnableDefaultsTrimming()
    self.config = self.SV.config
    self:UpdateConfig()

    self:LoadContacts()

    self.LNG           = GetCVar("language.2") -- en / de / fr / es / it / jp / ru
    self.accountName   = GetDisplayName()
    self.characterID   = GetCurrentCharacterId()
    self.characterName = GetUnitName("player")

    self:InitDialogs()
    self:InitUI()
    self:InitHooks()
    self:SetupContextMenus()
    self:InitSlashCmd()
    self:CreateConfigMenu()

    self.initialised = true
    self:Log("%s v%s initialised.", self.name, self:getVersion())
end

-- ------------------
--  @SECTION Loading
-- ------------------

function XC:onCharacterLoaded()
    EM:UnregisterForEvent(self.__namespace .. "RunOnce", EVENT_PLAYER_ACTIVATED)

    if (not self.loaded) then
        self.loaded = true
        self:Log("%s v%s loaded.", self.name, self:getVersion())
    end

    self.inGroup = IsUnitGrouped("player")
    self:onZoneChange()
    self:SetupHook("ZoneChange")
end

function XC:onAddonLoaded(_, addon_name)
    if (addon_name ~= self.__namespace) then return end
    EM:UnregisterForEvent(self.__namespace, EVENT_ADD_ON_LOADED)
    self:Init()
    EM:RegisterForEvent(self.__namespace .. "RunOnce", EVENT_PLAYER_ACTIVATED, function() self:onCharacterLoaded() end)
end

LEJ.Used = true -- libExtendedJournal usage flag (required by the library)

EM:RegisterForEvent(XC.__namespace, EVENT_ADD_ON_LOADED, function(event_id, addon_name) XC:onAddonLoaded(event_id, addon_name) end)
