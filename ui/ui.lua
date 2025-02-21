local LUI  = LibExtendedJournal
local LCCC = LibCodesCommonCode

local L    = XelosesContacts.getString

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContacts:InitUI()
	self.UI.ReticleMarker = XelosesReticleMarker:Initialize(self, self.config.reticle)

	self.DataChanged      = false
	self.UI.isReady       = false

	LUI.RegisterTab(
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

				self.UI.ContactsList:SetupKeybinds()
				self:RefreshUI(true)
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
	self.DataChanged     = true -- indicate data loaded from SV
	self.UI.isReady      = true
end

-- ---------------------
--  @SECTION Refresh UI
-- ---------------------

function XelosesContacts:RefreshUI(noActiveCheck)
	if (not self.UI.isReady) then return end

	if (noActiveCheck or XelosesContacts:isUIShown()) then
		if (self.DataChanged) then
			self.UI.ContactsList:RefreshList()
		else
			self.UI.ContactsList:RefreshFilters()
		end

		self.DataChanged = false
	end
end

-- ------------------
--  @SECTION Utility
-- ------------------

function XelosesContacts:ShowUI()
	LUI.Show(self.CONST.UI.TAB_NAME, true)
end

function XelosesContacts:isUIShown()
	return LUI.IsTabActive(self.CONST.UI.TAB_NAME)
end
