local S = GetString
local _L = ZO_CreateStringId

local function L(id, value, ...)
    local params = { ... }
    if (params and #params > 0) then value = string.format(value, ...) end
    return _L("XELCONTACTS_" .. id, value)
end

-- ============================
-- === English localization ===
-- ===      (default)       ===
-- ============================

L("ALL", "All")
L("DECLINED", "declined")
L("WARNING", "WARNING!")
L("ERROR", "Error")

-- Contact types:
L("FRIENDS", "Friends")
L("FRIEND", "Friend")
L("VILLAINS", "Villains")
L("VILLAIN", "Villain")

-- Contact groups (default):
L("GROUP_11", "Friend")
L("GROUP_12", "Teammate")
L("GROUP_13", "Housing")
L("GROUP_14", "Service")
L("GROUP_15", "RP")

L("GROUP_21", "Foe")
L("GROUP_22", "Toxic")
L("GROUP_23", "Spammer")
L("GROUP_24", "Cheater")
L("GROUP_25", "Mischief")

-- Group roles:
L("DPS", "DPS")
L("TANK", "Tank")
L("HEAL", "Healer")

-- Social:
L("ESO_FRIEND", "Friend")
L("ESO_IGNORED", "Ignored")
L("ESO_GUILDMATE", "\"<<1>>\" guildmate")

-- Notifications and Warnings:
L("CONTACT_ADDED", "Player <<LINK>> has been added to Contacts.")
L("CONTACT_REMOVED", "Contact <<1>> has been removed.")
L("TARGET_IN_CONTACTS", "Target player <<LINK>> already in Contacts.")
L("CHAT_WHISPER_BLOCKED", "<<LINK>> is a <<ICON>><<GROUP>>. Chat is blocked for this group of Villains.")
L("GROUP_WITH_VILLAIN", "You have joined a group with <<ICON>><<GROUP>> <<LINK>>!")
L("GROUP_JOINED_VILLAIN", "<<ICON>><<GROUP>> <<LINK>> joined your group!")
L("FRIEND_INVITE_FROM_VILLAIN", "<<ICON>><<GROUP>> <<LINK>> requests to be a friends!")
L("GROUP_INVITE_FROM_VILLAIN", "<<ICON>><<GROUP>> <<NAME>> invites you to his group!")
L("CONFIRM_CONTACT_ADD", "Are you sure want to add player <<1>> to Contacts?")
L("CONFIRM_CONTACT_REMOVE", "Are you sure want to remove <<1>> from Contacts?")
L("CONFIRM_INVITE_VILLAIN", "Are you sure want to invite <<2>> <<1>> to group?")
L("CONFIRM_INVITE_VILLAIN_WARNING", "Invite Villain to the group!")
L("CONFIRM_BEFRIEND_VILLAIN", "Are you sure want to add a <<2>> <<1>> to friends?")
L("CONFIRM_BEFRIEND_VILLAIN_WARNING", "Add Villain to friends!")
L("CONFIRM_IMPORT_FRIENDS", "Are you sure want to import all ESO ingame friends to Contacts?")
L("CONFIRM_IMPORT_IGNORED", "Are you sure want to import all ESO ingame ignored players to Contacts?")
L("CONFIRM_IMPORT_NAMEZ", "Are you sure want to import all friends and foes from Namez addon to Contacts?")
L("NOTIFY_IMPORT_COMPLETED", "Import completed.\n\nAdded <<1>> new Contacts.")

-- UI/List:
L("UI_TITLE", "Contacts")
L("UI_TITLE_SUB", "Friends and Villains")
L("UI_INFO_NO_CONTACTS", "You do not have contacts.")
L("UI_INFO_NO_CONTACTS_FOUND", "No contacts found.")
L("UI_HEADER_ACCOUNT", "Account")
L("UI_HEADER_GROUP", "Group")
L("UI_HEADER_NOTE", "Note")
L("UI_HEADER_TIMESTAMP", "Added")
L("UI_BTN_ADD_CONTACT_TOOLTIP", "Add new Contact")
L("UI_BTN_OPEN_SETTINGS_TOOLTIP", "Open addon settins")
L("UI_BTN_SEARCH_RESET_TOOLTIP", "Reset search")
L("UI_CONTACTS_COUNT", "Total contacts: %d friend(s) and %d villain(s).")
L("UI_FILTERED_CONTACTS_COUNT", "Found %d contact(s).")

-- UI/Dialog:
L("UI_DIALOG_TITLE_ADD_CONTACT", "Add new contact")
L("UI_DIALOG_TITLE_EDIT_CONTACT", "Edit contact")
L("UI_BTN_EDIT_ACCOUNT_NAME_TOOLTIP", "Edit account name")
L("UI_DIALOG_CONTACT_ACCOUNT_NAME", "Account name:")
L("UI_DIALOG_CONTACT_CATEGORY", "Type:")
L("UI_DIALOG_CONTACT_GROUP", "Group:")
L("UI_DIALOG_CONTACT_NOTE", "Personal note:")
L("UI_DIALOG_BUTTON_SAVE", "Save")

-- Context menu:
L("MENU_ADD_CONTACT", "Add to contacts")
L("MENU_EDIT_CONTACT", "Edit contact")
L("MENU_REMOVE_CONTACT", "Remove from contacts")

-- Settings:
L("SETTINGS_GENERAL", "General")
L("SETTINGS_UI_SEARCH_NOTE", "Allow search by Contact's personal note")
L("SETTINGS_UI_SEARCH_NOTE_TOOLTIP", "Search Contacts by account name and personal note in Contacts list. Turn this setting OFF to search by account name only.")
L("SETTINGS_COLORS", "Colors")
L("SETTINGS_COLORS_DESCRIPTION", "Contacts highlight colors.")
L("SETTINGS_COLOR", "<<1>> color")
L("SETTINGS_RETICLE_MARKER", "Reticle target marker")
L("SETTINGS_RETICLE_MARKER_DESCRIPTION", "Display a marker near the reticle when targeting Friends or Villains.")
L("SETTINGS_RETICLE_MARKER_ENABLE", "Enable")
L("SETTINGS_RETICLE_MARKER_DISABLE_COMBAT", "Disable in combat")
L("SETTINGS_RETICLE_MARKER_DISABLE_COMBAT_TOOLTIP", "Disable reticle targets detecting in combat (may improve perfomance).")
L("SETTINGS_RETICLE_MARKER_DISABLE_GROUP_DUNGEON", "Disable in group dungeons")
L("SETTINGS_RETICLE_MARKER_DISABLE_GROUP_DUNGEON_TOOLTIP", "Disable reticle targets detecting in group dungeons and group arenas.")
L("SETTINGS_RETICLE_MARKER_DISABLE_TRIAL", "Disable in trials")
L("SETTINGS_RETICLE_MARKER_DISABLE_TRIAL_TOOLTIP", "Disable reticle targets detecting in trials (may improve perfomance in trials).")
L("SETTINGS_RETICLE_MARKER_DISABLE_PVP", "Disable in PvP-zones")
L("SETTINGS_RETICLE_MARKER_DISABLE_PVP_TOOLTIP", "Disable reticle targets detecting in PvP-zones: Cyrodiil, Imperial city, battlegrounds (may improve perfomance in those zones).")
L("SETTINGS_RETICLE_MARKER_POSITION", "Marker position")
L("SETTINGS_RETICLE_MARKER_POSITION_TOOLTIP", "Reticle target marker position.")
L("SETTINGS_RETICLE_MARKER_POSITION_ABOVE", "Above reticle")
L("SETTINGS_RETICLE_MARKER_POSITION_BELOW", "Below reticle")
L("SETTINGS_RETICLE_MARKER_OFFSET", "Marker offset")
L("SETTINGS_RETICLE_MARKER_OFFSET_TOOLTIP", "Offset upward if marker is above the reticle, or offset downward if marker is below the reticle.")
L("SETTINGS_RETICLE_MARKER_FONT_SIZE", "Font size")
L("SETTINGS_RETICLE_MARKER_FONT_STYLE", "Font decoration")
L("SETTINGS_RETICLE_MARKER_ICON_ENABLE", "Display big icon")
L("SETTINGS_RETICLE_MARKER_ICON_ENABLE_TOOLTIP", "Display additional big icon above or under text.")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE", "Big icon size")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE_SMALL", "Small (32x32)")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE_MEDIUM", "Medium (48x48)")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE_BIG", "Big (64x64)")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_MARKERS", "Additional markers")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_MARKERS_DESCRIPTION", "Additional markers may have slightly perfomance impact in places with many players aroud (e.g. cities).")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_FRIEND", "Add marker for <<1>>ESO friends")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_FRIEND_TOOLTIP", "") -- dummy string to be overwrote in localization files (optional)
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_FRIEND_COLOR", "ESO friends marker color")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_IGNORED", "Add marker for <<1>>ignored players")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_IGNORED_TOOLTIP", "") -- dummy string to be overwrote in localization files (optional)
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_IGNORED_COLOR", "Ignored players marker color")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_GUILDMATE", "Add marker for <<1>>guildmates")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_GUILDMATE_TOOLTIP", "") -- dummy string to be overwrote in localization files (optional)
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_GUILDMATE_COLOR", "Guildmates marker color")
L("SETTINGS_NOTIFICATION", "Notifications and warnings")
L("SETTINGS_NOTIFICATION_DESCRIPTION", "Onsreen and chat notifications / warnings for contacts.")
L("SETTINGS_NOTIFICATION_CHANNEL", "Notifications and info messages channel")
L("SETTINGS_NOTIFICATION_CHANNEL_TOOLTIP", "Where to send notifications and info messages.")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_BOTH", "Both (chat+screen)")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_CHAT", "Chat")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_SCREEN", "Screen")
L("SETTINGS_NOTIFICATION_GROUP_JOIN", "Show warning when join a group with Villain")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_TOOLTIP", "Show warning (depends on selection above) when join a group with Villain.")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_SCREEN", "Onsreen warning when join a group with Villain")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_SCREEN_TOOLTIP", "Show big center screen warning when join a group with Villain.")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER", "Show warning when Villain joined your group")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_TOOLTIP", "Show warning (depends on selection above) when Villain joined your group.")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_SCREEN", "Onsreen warning when Villain joined your group")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_SCREEN_TOOLTIP", "Show big center screen warning when Villain joined your group.")
L("SETTINGS_NOTIFICATION_GROUP_INVITE", "Show warning when Villain invites you to group")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_TOOLTIP", "Show warning (depends on selection above) when Villain invites you to group.")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_SCREEN", "Onsreen warning when Villain invites you to group")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_SCREEN_TOOLTIP", "Show big center screen warning when Villain invites you to group.")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE", "Show warning when recieve friend request from Villain")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_TOOLTIP", "Show warning (depends on selection above) when recieve friend request from Villain.")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_SCREEN", "Onsreen warning when recieve friend request from Villain")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_SCREEN_TOOLTIP", "Show big center screen warning when recieve friend request from Villain.")
L("SETTINGS_AUTODECLINE_FRIEND_INVITE", "Auto-decline friend invites from Villains")
L("SETTINGS_AUTODECLINE_FRIEND_INVITE_TOOLTIP", "Automatically decline friend invites if inviter is a Villain.")
L("SETTINGS_AUTODECLINE_GROUP_INVITE", "Auto-decline group invites from Villains")
L("SETTINGS_AUTODECLINE_GROUP_INVITE_TOOLTIP", "Automatically decline group invites if inviter is a Villain.")
L("SETTINGS_CONFIRM_ADD_FRIEND", "Confirm adding Villain as friend")
L("SETTINGS_CONFIRM_ADD_FRIEND_TOOLTIP", "Show confirmation dialog when trying to add Villain to ESO ingame friends.")
L("SETTINGS_CHAT", "Chat")
L("SETTINGS_CHAT_DESCRIPTION", "Chat settings.")
L("SETTINGS_CHAT_CACHE", "Context menu for more chat messages")
L("SETTINGS_CHAT_CACHE_TOOLTIP", "Enable chat caching to provide 'Add to Contacts' context menu item on most chat messages.\n\nTurning this option OFF will clear all existing cache!")
L("SETTINGS_CHAT_CACHE_WARNING", "Chat caching may have a little performance impact on old low-end PC when there are a lot of incoming messages in a row in Zone and/or Say chat channels.")
L("SETTINGS_CHAT_CACHE_SIZE", "Chat cache max size")
L("SETTINGS_CHAT_CACHE_SIZE_TOOLTIP", "Maximum accounts (with associated characters) stored in the cache.")
L("SETTINGS_CHAT_CACHE_SIZE_WARNING", "Bigger cache size may have increased performance impact on old low-end PC. Don't change cache size if you are unsure about it.")
L("SETTINGS_CHAT_BLOCK", "Chat blocking")
L("SETTINGS_CHAT_BLOCK_GROUPS", "Groups")
L("SETTINGS_CHAT_BLOCK_GROUPS_DESCRIPTION", "Setup chat blocking for Villains per group.")
L("SETTINGS_CHAT_BLOCK_GROUP", "Block chat for category <<1>> (<<2>>)")
L("SETTINGS_CHAT_BLOCK_GROUP_TOOLTIP", "Block chat messages from this Villains group.")
L("SETTINGS_CHAT_BLOCK_CHANNELS", "Chat channels")
L("SETTINGS_CHAT_BLOCK_CHANNELS_DESCRIPTION", "Setup chat channels for blocking messages from Villains (only messages from Villains categories selected above will be blocked).")
L("SETTINGS_CHAT_BLOCK_CHANNEL_SAY", "%s, %s, %s", S(SI_CHAT_CHANNEL_NAME_SAY), S(SI_CHAT_CHANNEL_NAME_YELL), S(SI_CHAT_CHANNEL_NAME_EMOTE))
L("SETTINGS_CHAT_BLOCK_CHANNEL_ZONE", S(SI_CHAT_CHANNEL_NAME_ZONE))
L("SETTINGS_CHAT_BLOCK_CHANNEL_GROUP", S(SI_CHAT_CHANNEL_NAME_PARTY))
L("SETTINGS_CHAT_BLOCK_CHANNEL_GUILD", "Guild and Guild officer")
L("SETTINGS_CHAT_BLOCK_CHANNEL_WHISPER", S(SI_CHAT_CHANNEL_NAME_WHISPER))
L("SETTINGS_CHAT_BLOCK_CHANNEL_TOOLTIP", "Block chat messages from Villains in this channel.")
L("SETTINGS_CHAT_INFO", "Do not print informational messages in chat")
L("SETTINGS_CHAT_INFO_TOOLTIP", "Do not print informational messages ('Contact added', 'Contact removed', etc) in chat.")
L("SETTINGS_GROUPS", "Groups")
L("SETTINGS_GROUPS_DESCRIPTION", "Edit contacts groups.")
L("SETTINGS_GROUP_NAME", "Group <<1>> name:")
L("SETTINGS_IMPORT", "Import")
L("SETTINGS_IMPORT_DESCRIPTION", "Import Friends and Villains from ESO ingame friends list and ignored list.")
L("SETTINGS_IMPORT_BUTTON", "Import")
L("SETTINGS_IMPORT_DESTINATION", "Add to group:")
L("SETTINGS_IMPORT_DESTINATION_TOOLTIP", "Import players to selected group.")
L("SETTINGS_IMPORT_FRIENDS", "Import ESO ingame friends into Contacts.")
L("SETTINGS_IMPORT_VILLAINS", "Import ESO ingame ignored players into Contacts.")

-- Slash commands:
L("SLASHCMD_NEW_CONTACT_TOOLTIP", "Open new contact dialog")
L("SLASHCMD_ADD_CONTACT_TOOLTIP", "Add new contact")
L("SLASHCMD_OPEN_SETTINGS_TOOLTIP", "Open addon settings panel")

-- Keybinds:
_L("SI_BINDING_NAME_XELCONTACTS_UI_SHOW", "Open contacts list")
_L("SI_BINDING_NAME_XELCONTACTS_ADD_CONTACT", "Add target to contacts")
