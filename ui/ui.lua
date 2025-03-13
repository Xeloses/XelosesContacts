local LEJ  = LibExtendedJournal
local LCCC = LibCodesCommonCode

local L    = XelosesContacts.getString

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContacts:InitUI()
	self.UI.ReticleMarker = XelosesReticleMarker:Initialize(self, self.config.reticle)

	LEJ.RegisterTab(
		self.CONST.UI.TAB_NAME,
		{
			title         = L("UI_TITLE"),
			subtitle      = L("UI_TITLE_SUB"),
			iconPrefix    = self.icon,
			order         = 990,
			control       = XelosesContactsFrame,
			binding       = "XELCONTACTS",
			settingsPanel = self.settingsPanel,
			slashCommands = { self.slashCmd },
			callbackShow  = function()
				if (not self.UI.isReady) then
					self:LazyInitUI()
				end

				self:RefreshContactsList(true)
				self.UI.ContactsList:SetupKeybinds()
			end,
			callbackHide  = function()
				self.UI.ContactsList:RemoveKeybinds()
			end,
		}
	)

	LCCC.RegisterLinkHandler("contacts", function() self:ShowUI() end)
end

function XelosesContacts:LazyInitUI()
	if (self.UI.isReady) then return end

	self.UI.ContactsList = XelosesContactsList:New(self)
	self.UI.isReady      = true
end

-- ---------------------
--  @SECTION Refresh UI
-- ---------------------

function XelosesContacts:RefreshContactsList(force_refresh)
	if (not self.UI.isReady) then return end

	if (force_refresh or self:isUIShown()) then
		if (self.DataChanged) then
			self.UI.ContactsList:RefreshList()
			self.DataChanged = false
		else
			self.UI.ContactsList:RefreshFilters()
		end
	end
end

function XelosesContacts:RefreshContactGroups(category_id)
	-- reset contact groups cache
	if (self.__groups_cache ~= nil) then
		if (category_id) then
			self.__groups_cache[category_id] = table:new()
		else
			self.__groups_cache = nil
		end
	end

	if (self.UI.isReady) then
		self.UI.ContactsList:RefreshGroupsList(category_id)
	end

	if (self.UI.ContactDialog) then
		self.UI.ContactDialog:RefreshGroupsList(category_id)
	end
end

-- ------------------
--  @SECTION Utility
-- ------------------

function XelosesContacts:ShowUI()
	if (not self.UI.isReady) then return end

	self.UI.ContactsList:Show()
end

function XelosesContacts:isUIShown()
	return self.UI.isReady and self.UI.ContactsList:isShown()
end
