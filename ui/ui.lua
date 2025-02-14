local LUI   = LibExtendedJournal
local LCCC  = LibCodesCommonCode
local XC    = XelosesContacts
local CONST = XC.CONST
local L     = XC.getString

-- ---------------
--  @SECTION Init
-- ---------------

function XC:InitUI()
	self.UI.ReticleMarker = XelosesReticleMarker:New(self, self.config.reticle)

	self.DataChanged      = false
	self.UI.isReady       = false

	LUI.RegisterTab(
		CONST.UI.TAB_NAME,
		{
			title         = L("UI_TITLE"),
			subtitle      = L("UI_TITLE_SUB"),
			iconPrefix    = self.icons.ui.main,
			order         = 990,
			control       = XelosesContactsFrame,
			binding       = "XELCONTACTS",
			settingsPanel = self.settingsPanel,
			slashCommands = { self.slashCmd },
			callbackShow  = function()
				if (not self.UI.isReady) then self:LazyInitUI() end
				self.UI.ContactsList:SetupKeybinds()
				self:RefreshListUI(true)
			end,
			callbackHide  = function()
				self.UI.ContactsList:RemoveKeybinds()
			end,
		}
	)

	LCCC.RegisterLinkHandler("contacts", function() self:ShowUI() end)
end

function XC:LazyInitUI()
	if (self.UI.isReady) then return end

	self.UI.ContactsList = XelosesContactsList:New(self)
	self.DataChanged     = true -- indicate data loaded from SV
	self.UI.isReady      = true
end

-- ---------------------
--  @SECTION Refresh UI
-- ---------------------

function XC:RefreshListUI(force_refresh)
	if (not self.UI.isReady) then return end

	if (force_refresh or XC:isUIShown()) then
		if (self.DataChanged) then
			self.UI.ContactsList:RefreshList()
		else
			self.UI.ContactsList:RefreshFilters()
		end

		self.DataChanged = false
	end
end

function XC:RefreshContactsList(force_refresh)
	if (not self.UI.isReady) then return end
	if (not self.DataChanged) then return end

	self:RefreshListUI(force_refresh)
end

function XC:RefreshContactGroups(category_id)
	-- clear contact groups cache
	if (self.__groups_cache) then
		self.__groups_cache = nil
	end

	if (self.UI.isReady and (not category_id or self.UI.ContactsList.categoryID == category_id)) then
		self.UI.ContactsList:RefreshGroupsList()
	end

	if (self.UI.ContactDialog and self.UI.ContactDialog.initialized and (not category_id or self.UI.ContactDialog.currentCategory == category_id)) then
		self.UI.ContactDialog:RefreshGroupsList()
	end
end

-- ------------------
--  @SECTION Utility
-- ------------------

function XC:ShowUI()
	LUI.Show(CONST.UI.TAB_NAME, true)
end

function XC:isUIShown()
	return LUI.IsTabActive(CONST.UI.TAB_NAME)
end
