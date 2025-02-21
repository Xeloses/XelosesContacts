local LSC = LibSlashCommander
local L   = XelosesContacts.getString
local T   = type

-- ---------------
--  @SECTION Init
-- ---------------

function XelosesContacts:InitSlashCmd()
	self.slashCmd       = "/contacts"
	self.slashCmdParams = {
		["NEW_CONTACT"] = {
			cmd     = "new",
			tooltip = L("SLASHCMD_NEW_CONTACT_TOOLTIP"),
		},
		["ADD_CONTACT"] = {
			cmd     = "add",
			tooltip = L("SLASHCMD_ADD_CONTACT_TOOLTIP"),
		},
		["OPEN_SETTINGS"] = {
			cmd     = "config",
			tooltip = L("SLASHCMD_OPEN_SETTINGS_TOOLTIP"),
		},
	}
end

-- --------------------------------
--  @SECTION Create slash commands
-- --------------------------------

function XelosesContacts:CreateSlashCmd()
	if (not self.slashCmd) then
		self:InitSlashCmd()
	end

	if (LSC) then
		local cmd = LSC:Register()
		local params_list = table:new()

		cmd:AddAlias(self.slashCmd)
		cmd:SetDescription(L(SI_BINDING_NAME_XELCONTACTS_UI_SHOW))
		cmd:SetCallback(function() self:handleSlashCmd() end)

		for action, param in pairs(self.slashCmdParams) do
			local cmdParam = cmd:RegisterSubCommand()

			cmdParam:AddAlias(param.cmd)
			cmdParam:SetDescription(param.tooltip)
			cmdParam:SetCallback(function(...) self:handleSlashCmd(action, ...) end)

			params_list:insert(param.cmd)
		end

		cmd:SetAutoComplete(params_list)
	else
		SLASH_COMMANDS[self.slashCmd] = function(...)
			self:handleSlashCmd(...)
		end
	end
end

-- -------------------------------
--  @SECTION Handle slash command
-- -------------------------------

function XelosesContacts:handleSlashCmd(action, arg)
	local params = table:new(T(arg) == "string" and arg:split(" "))

	if (action == "NEW_CONTACT") then
		self:AddContact()
	elseif (action == "ADD_CONTACT") then
		local n = params:len()

		local name = (n == 0) and self:validateAccountName(params:get(1))
		if (not name) then return end

		local data
		if (n > 1) then
			params:remove(1)
			data = { note = params:join(" ") }
		end

		self:AddContact(name, data)
	elseif (action == "OPEN_SETTINGS") then
		self:OpenSettings()
	else
		self:ShowUI()
	end
end
