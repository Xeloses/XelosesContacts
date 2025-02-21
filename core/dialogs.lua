local L = XelosesContacts.getString
local T = type

-- -------------------------
--  @SECTION Define dialogs
-- -------------------------

function XelosesContacts:InitDialogs()
	self.CONST.UI.DIALOGS = {
		-- Create/Edit contact dialog
		CONTACT_EDIT             = {
			name = self.__prefix .. "DIALOG_EDIT_CONTACT",
		},

		-- Confirmation dialog: Remove contact
		CONFIRM_CONTACT_REMOVE   = {
			name = self.__prefix .. "DIALOG_CONFIRM_CONTACT_REMOVE",
			callback = function(dialog)
				-- Remove contact
				self:RemoveContact(dialog.data, { confirmed = true })
			end
		},

		-- Confirmation dialog: Invite Villain to group
		CONFIRM_INVITE_VILLAIN   = {
			name = self.__prefix .. "DIALOG_CONFIRM_INVITE_VILLAIN",
			callback = function(dialog)
				-- Invite contact to group
				self.Game:GroupInvite(dialog.data.account)
			end
		},

		-- Confirmation dialog: Add Villain to friends
		CONFIRM_BEFRIEND_VILLAIN = {
			name = self.__prefix .. "DIALOG_CONFIRM_BEFRIEND_VILLAIN",
			callback = function(dialog)
				-- Send friend invite request
				self.Game:addFriend(dialog.data.name, true)
			end
		},

		-- Confirmation dialog: Import ESO ingame friends
		CONFIRM_IMPORT_FRIENDS   = {
			name = self.__prefix .. "DIALOG_CONFIRM_IMPORT_FRIENDS",
			callback = function(dialog)
				-- Import ESO ingame friends
				self:ImportESOFriends(dialog.data.param)
			end
		},

		-- Confirmation dialog: Import ESO ingame ignored players
		CONFIRM_IMPORT_IGNORED   = {
			name = self.__prefix .. "DIALOG_CONFIRM_IMPORT_IGNORED",
			callback = function(dialog)
				-- Import ESO ingame ignored players list
				self:ImportESOIgnored(dialog.data.param)
			end
		},

		-- Confirmation dialog: friends and foes from Namez addon
		CONFIRM_IMPORT_NAMEZ     = {
			name = self.__prefix .. "DIALOG_CONFIRM_IMPORT_NAMEZ",
			callback = function(dialog)
				-- Import ESO ingame ignored players list
				self.Integrations.Namez:Import(dialog.data.friends_group_id, dialog.data.foes_group_id)
			end
		},

		-- Notification dialog: Import completed
		NOTIFY_IMPORT_COMPLETED  = {
			name = self.__prefix .. "DIALOG_NOTIFY_IMPORT_COMPLETED",
		},
	}
end

-- ----------------------
--  @SECTION Show dialog
-- ----------------------

function XelosesContacts:ShowDialog(dialog, text_params, data)
	if (not dialog or not dialog.name) then return end

	local dialog_data = {}
	if (data) then
		local _t = T(data)
		if (_t == "table") then
			dialog_data = data
		elseif (_t == "string" or _t == "number") then
			dialog_data = { param = data }
		end
	end

	if (not dialog.skip) then
		-- lazy load dialog
		if (not ZO_Dialogs_IsDialogRegistered(dialog.name)) then
			self:CreateDialog(dialog)
		end

		local params = {}
		if (text_params) then
			if (T(text_params) == "table" and #text_params > 0) then
				params = { mainTextParams = text_params }
			elseif (T(text_params) == "string" and text_params ~= "") then
				params = { mainTextParams = { text_params } }
			elseif (T(text_params) == "number") then
				params = { mainTextParams = { tostring(text_params) } }
			end
		end

		return ZO_Dialogs_ShowDialog(dialog.name, dialog_data, params)
	elseif (T(dialog.callback) == "function") then
		-- skip dialog
		dialog.callback({ data = dialog_data })
	end
end

-- ------------------------
--  @SECTION Create dialog
-- ------------------------

function XelosesContacts:CreateDialog(dialog_config)
	if (not dialog_config or not dialog_config.name) then return end
	local dialog_id = dialog_config.name:sub((self.__prefix .. "DIALOG_"):len() + 1)
	local dialog_type = dialog_id:match("^(%u+)_%u+")
	if (not dialog_type) then return end
	local text = L(dialog_config.text or dialog_id)
	if (not text or text == "") then return end

	local dialog = {
		title = {
			text = self.displayName
		},
		mainText = {
			text = (dialog_type == "WARNING") and L("WARNING") or text,
			align = TEXT_ALIGN_CENTER
		},
	}

	local dialog_buttons = {
		["NOTIFY"] = {
			{ text = SI_OK, callback = dialog_config.callback },
		},
		["WARNING"] = {
			{ text = SI_DIALOG_ACCEPT, callback = dialog_config.callback },
		},
		["CONFIRM"] = {
			{ text = SI_YES, callback = dialog_config.callback },
			{ text = SI_NO },
		},
	}

	dialog.buttons = dialog_buttons[dialog_type]

	if (dialog_type == "WARNING") then
		dialog.warning = {
			text  = text,
			align = TEXT_ALIGN_CENTER
		}
	elseif (dialog_type == "CONFIRM") then
		local warning_text = L(dialog_id .. "_WARNING")
		if (warning_text and not warning_text:match("^[_%u]+$")) then
			dialog.warning = {
				text = L("WARNING") .. "\n" .. warning_text,
				align = TEXT_ALIGN_CENTER
			}
		end
	end

	ZO_Dialogs_RegisterCustomDialog(dialog_config.name, dialog)
end
