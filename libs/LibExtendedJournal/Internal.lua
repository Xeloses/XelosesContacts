if (LibExtendedJournal) then return end
local Public = { }
LibExtendedJournal = Public


--------------------------------------------------------------------------------
-- Internal Components
--------------------------------------------------------------------------------

local Internal = {
	name = "LibExtendedJournal",

	SCENE_NAME = "ExtendedJournalScene",

	initialized = false,
	controls = { },
	tabs = { },
	activeTab = nil,
	settingsVisible = false,
}
LibExtendedJournalInternal = Internal
local Controls = Internal.controls


--------------------------------------------------------------------------------
-- Keybinds and Main Menu
--------------------------------------------------------------------------------

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_EXTENDED_JOURNAL", GetString(SI_LEJ_NAME))
ZO_CreateStringId("SI_BINDING_NAME_EXTENDED_JOURNAL", GetString(SI_LEJ_NAME))
ZO_CreateStringId("SI_BINDING_NAME_EXTENDED_JOURNAL_SETTINGS", GetString(SI_GAME_MENU_SETTINGS))

EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_ADD_ON_LOADED, function( eventCode, addonName )
	if (addonName ~= Internal.name) then return end

	EVENT_MANAGER:UnregisterForEvent(Internal.name, EVENT_ADD_ON_LOADED)

	if (MAIN_MENU_KEYBOARD and MAIN_MENU_KEYBOARD.categoryBar and MAIN_MENU_KEYBOARD.categoryBarFragment) then
		Controls.mainMenu = MAIN_MENU_KEYBOARD.categoryBar
		Internal.mainMenuFragment = MAIN_MENU_KEYBOARD.categoryBarFragment
		Internal.FixMainMenuCategory = function() MAIN_MENU_KEYBOARD.lastCategory = MENU_CATEGORY_CHARACTER end

		local iconPrefix = "/esoui/art/treeicons/achievements_indexicon_prologue_"

		ZO_MenuBar_AddButton(Controls.mainMenu, {
			descriptor = Internal.name,
			categoryName = SI_LEJ_NAME,
			binding = "EXTENDED_JOURNAL",
			normal = iconPrefix .. "up.dds",
			pressed = iconPrefix .. "down.dds",
			highlight = iconPrefix .. "over.dds",
			callback = function() Public.Show() end,
		})
	else
		Internal.FixMainMenuCategory = function() end
	end

	Internal.LoadTooltipColors()
end)


--------------------------------------------------------------------------------
-- Main UI
--------------------------------------------------------------------------------

function Internal.LazyInitialize( initialDescriptor )
	if (Internal.initialized) then return end
	Internal.initialized = true

	--------
	-- Initialize controls
	--------

	Controls.frame = ExtendedJournalFrame
	Controls.menu = Controls.frame:GetNamedChild("MenuBar")
	Controls.subtitle = Controls.menu:GetNamedChild("Label")

	--------
	-- Create the scene
	--------

	-- Scene fragment for our main window
	local fragment = ZO_FadeSceneFragment:New(Controls.frame)
	fragment:RegisterCallback("StateChange", function( oldState, newState )
		if (newState == SCENE_FRAGMENT_SHOWING) then
			Internal.PrepareTabForDisplay(ZO_MenuBar_GetSelectedDescriptor(Controls.menu))
		elseif (newState == SCENE_FRAGMENT_HIDING) then
			Internal.FireCallbackForCurrentTab("Hide")
			Internal.activeTab = nil
			Internal.RefreshSettingsButton()
		end
	end)

	-- Title handler; see /esoui/ingame/scenes/ingamefragments.lua
	local getSetTitleFragment = function( )
		local stfrag = ZO_SetTitleFragment:New()
		stfrag.Show = function( self )
			if (not Controls.title) then
				Controls.title = SCENE_MANAGER:GetCurrentScene():GetFragmentWithCategory("Title"):GetControl():GetNamedChild("Label")
			end
			Internal.UpdateTitle()
			self:OnShown()
		end
		return stfrag
	end

	-- General fragments
	Internal.scene = ZO_Scene:New(Internal.SCENE_NAME, SCENE_MANAGER)
	Internal.scene:AddFragment(fragment)
	Internal.scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	Internal.scene:AddFragment(CODEX_WINDOW_SOUNDS)
	Internal.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	Internal.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	if (not Internal.altMode) then
		Internal.scene:AddFragment(getSetTitleFragment())
		Internal.scene:AddFragment(TITLE_FRAGMENT)
		Internal.scene:AddFragment(RIGHT_BG_FRAGMENT)
	else
		Internal.scene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
	end

	-- Fragments for the top strip
	if (Internal.mainMenuFragment) then
		Internal.scene:AddFragment(Internal.mainMenuFragment)
		Internal.scene:AddFragment(TOP_BAR_FRAGMENT)
		Internal.scene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	end

	--------
	-- Initialize tabs
	--------

	-- Order tabs
	local descriptors = { }
	for descriptor in pairs(Internal.tabs) do
		table.insert(descriptors, descriptor)
	end
	table.sort(descriptors, function( a, b )
		return Internal.tabs[a].order < Internal.tabs[b].order
	end)

	-- Add tabs
	for _, descriptor in ipairs(descriptors) do
		local tab = Internal.tabs[descriptor]

		local control = tab.control
		control:SetParent(Controls.frame)
		control:ClearAnchors()
		control:SetAnchor(TOPLEFT)
		control:SetAnchor(BOTTOMRIGHT)

		local button = {
			descriptor = descriptor,
			categoryName = tab.name,
			title = tab.title,
			subtitle = tab.subtitle,
			callback = Internal.HandleTabSwitch,
		}

		if (not button.title) then
			-- Compatibility with legacy name format
			button.title, button.subtitle = zo_strsplit(":", Internal.GetString(tab.name))
		end

		if (tab.iconPrefix) then
			button.normal = tab.iconPrefix .. "up.dds"
			button.pressed = tab.iconPrefix .. "down.dds"
			button.highlight = tab.iconPrefix .. "over.dds"
		else
			button.normal = tab.iconNormal
			button.pressed = tab.iconPressed
			button.highlight = tab.iconHighlight
		end

		ZO_MenuBar_AddButton(Controls.menu, button)
	end

	-- Select initial tab
	if (initialDescriptor) then
		ZO_MenuBar_SelectDescriptor(Controls.menu, initialDescriptor, true)
	else
		ZO_MenuBar_SelectFirstVisibleButton(Controls.menu, true)
	end

	--------
	-- Make the footer comboboxes open upwards
	--------

	SecurePostHook(ZO_COMBO_BOX_DROPDOWN_KEYBOARD, "Show", function( self, comboBox )
		if (comboBox.shouldOpenAbove == true) then
			self.control:ClearAnchors()
			self.control:SetAnchor(BOTTOMLEFT, comboBox:GetContainer(), TOPLEFT)
		end
	end)

	--------
	-- Alternate Mode
	--------

	if (type(Internal.altMode) == "function") then
		Internal.altMode()
	end
end

function Internal.GetString( str )
	if (type(str) == "string") then
		return str
	elseif (type(str) == "number") then
		return GetString(str)
	else
		return ""
	end
end

function Internal.UpdateTitle( title )
	Internal.currentTitle = title or Internal.currentTitle
	if (Controls.title) then
		Controls.title:SetText(Internal.currentTitle or "")
	end
end

function Internal.HandleTabSwitch( button )
	if (SCENE_MANAGER:IsShowing(Internal.SCENE_NAME)) then
		Internal.PrepareTabForDisplay(button.descriptor)
	end

	if (not Internal.altMode) then
		Internal.UpdateTitle(Internal.GetString(button.title))
		Controls.subtitle:SetText(Internal.GetString(button.subtitle))
	else
		Controls.subtitle:SetText(Internal.GetString(button.categoryName))
	end

	for descriptor, tab in pairs(Internal.tabs) do
		if (descriptor == button.descriptor) then
			tab.control:SetHidden(false)
		else
			tab.control:SetHidden(true)
		end
	end
end

function Internal.PrepareTabForDisplay( descriptor )
	local tab = nil
	if (descriptor) then
		tab = Internal.tabs[descriptor]
	end

	if (Internal.activeTab ~= tab) then
		Internal.FireCallbackForCurrentTab("Hide")
	end
	Internal.activeTab = tab
	Internal.FireCallbackForCurrentTab("Show")

	Internal.RefreshSettingsButton()
end

function Internal.FireCallbackForCurrentTab( event )
	local fn = Internal.activeTab and Internal.activeTab["callback" .. event]
	if (fn) then fn() end
end

function Internal.RefreshSettingsButton( )
	local button = {
		name = GetString(SI_BINDING_NAME_EXTENDED_JOURNAL_SETTINGS),
		keybind = "EXTENDED_JOURNAL_SETTINGS",
		callback = Public.InvokeSettings,
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
	}

	local settingsAvailable = LibAddonMenu2 and Internal.activeTab and Internal.activeTab.settingsPanel

	if (settingsAvailable and not Internal.settingsVisible) then
		Internal.settingsVisible = true
		KEYBIND_STRIP:AddKeybindButton(button)
	elseif (not settingsAvailable and Internal.settingsVisible) then
		Internal.settingsVisible = false
		KEYBIND_STRIP:RemoveKeybindButton(button)
	end
end
