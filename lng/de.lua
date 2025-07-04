local S = GetString
local _L = function(id, value, version) return SafeAddString(id, value, version or 2) end

local function L(id, value, ...)
    local params = { ... }
    if (params and #params > 0) then value = string.format(value, ...) end
    return _L(_G["XELCONTACTS_" .. tostring(id)], value)
end

-- ===========================
-- === German localization ===
-- ===========================
-- by Baertram (https://www.esoui.com/forums/member.php?userid=2028)

-- ==============================
-- // Untranslated strings:
L("SETTINGS_DEFAULT_CATEGORY", "Default category for new Contacts")
L("SETTINGS_DEFAULT_CATEGORY_TOOLTIP", "This category will be selected by default when adding new Contact (you still can select another category in the New contact dialog).")

L("SETTINGS_GROUPS_NOTE", "Note:\n  - all contacts from removed groups will be automatically moved to the first predefined group;\n  - predefinded groups are persistent and can not be removed;\n  - changes may not appear until reload UI.")
L("SETTINGS_GROUPS_SELECT_CATEGORY", "Contacts category:")
L("SETTINGS_GROUPS_SELECT_GROUP", "Select group to edit:")
L("SETTINGS_GROUPS_BUTTON_ADD", "Create group")
L("SETTINGS_GROUPS_BUTTON_ADD_TOOLTIP", "Create new group.")
L("SETTINGS_GROUPS_BUTTON_REMOVE", "Remove group")
L("SETTINGS_GROUPS_BUTTON_REMOVE_TOOLTIP", "Remove selected group.")
L("SETTINGS_GROUPS_BUTTON_REMOVE_WARNING", "Selected group will be removed permanently!")
L("SETTINGS_GROUPS_EDIT", "Edit group")
L("SETTINGS_GROUPS_EDIT_NAME", "Group name:")
L("SETTINGS_GROUPS_EDIT_ICON", "Group icon:")
L("SETTINGS_GROUPS_EDIT_BLOCK_CHAT", "Block chat for this group")
L("SETTINGS_GROUPS_EDIT_BLOCK_CHAT_TOOLTIP", "Block (hide) chat messages from contacts in this group.")

L("SETTINGS_CONTEXT_MENU", "Context menu")
L("SETTINGS_CONTEXT_MENU_TOGGLE", "Enable \"%s\" context menu item", S(XELCONTACTS_MENU_ADD_CONTACT))
L("SETTINGS_CONTEXT_MENU_TOGGLE_TOOLTIP", "Enable \"%s\" context menu item in context menus on players in group window, guild roster, chat links, friends list, etc.", S(XELCONTACTS_MENU_ADD_CONTACT))
L("SETTINGS_CONTEXT_MENU_TOGGLE_WARNING", "If you turn off this option you will not be able to add players to Contacts via context menu. Slash commands and hotkey for adding players to Contacts still be available.")
L("SETTINGS_CONTEXT_MENU_SUBMENU", "Use submenu in context menu")
L("SETTINGS_CONTEXT_MENU_SUBMENU_TOOLTIP", "Add submenu under \"%s\" context menu item.", S(XELCONTACTS_MENU_ADD_CONTACT))

L("SETTINGS_CHAT_CACHE", "Context menu for more chat messages")
L("SETTINGS_CHAT_CACHE_TOOLTIP", "Enable chat caching to provide 'Add to Contacts' context menu item on most chat messages.\n\nTurning this option OFF will clear all existing cache!")
L("SETTINGS_CHAT_CACHE_WARNING", "Chat caching may have a little performance impact on old low-end PC when there are a lot of incoming messages in a row in Zone and/or Say chat channels.")
L("SETTINGS_CHAT_CACHE_SIZE", "Chat cache max size")
L("SETTINGS_CHAT_CACHE_SIZE_TOOLTIP", "Maximum accounts (with associated characters) stored in the cache.")
L("SETTINGS_CHAT_CACHE_SIZE_WARNING", "Bigger cache size may have increased performance impact on old low-end PC. Don't change cache size if you are unsure about it.")

L("SETTINGS_NOTIFICATION_SETUP", "Setup notifications")
L("SETTINGS_NOTIFICATION_SCREEN_WARNING", "Big onsreen warning")
L("SETTINGS_NOTIFICATION_SCREEN_WARNING_TOOLTIP", "Show big center screen warning.")

L("SETTINGS_RETICLE_MARKER_DISPLAY_MODE", "Display mode:")
L("SETTINGS_RETICLE_MARKER_DISPLAY_MODE_FULL", "Full")
L("SETTINGS_RETICLE_MARKER_DISPLAY_MODE_TEXT", "Text only")
L("SETTINGS_RETICLE_MARKER_DISPLAY_MODE_ICON", "Big icon only")
L("SETTINGS_RETICLE_MARKER_COLORIZE_RETICLE", "Change reticle color")
L("SETTINGS_RETICLE_MARKER_COLORIZE_RETICLE_TOOLTIP", "Change reticle color when targeting Contacts.")
-- // End of Untranslated strings
-- ==============================

L("ALL", "Alle")
L("DECLINED", "abgelehnt")
L("WARNING", "WARNUNG!")
L("ERROR", "FEHLER")

-- Contact types:
L("FRIENDS", "Freunde")
L("FRIEND", "Freund")
L("VILLAINS", "Schurken")
L("VILLAIN", "Schurke")

-- Contact groups (default):
L("GROUP_11", "Freund")
L("GROUP_12", "Teamkollege")
L("GROUP_13", "Häuser")
L("GROUP_14", "Service")
L("GROUP_15", "Rollenspiel")

L("GROUP_21", "Feind")
L("GROUP_22", "Toxisch")
L("GROUP_23", "Spammer")
L("GROUP_24", "Cheater")
L("GROUP_25", "Unfug")

-- Group roles:
L("DPS", "DPS")
L("TANK", "Tank")
L("HEAL", "Heiler")

-- Social:
L("ESO_FRIEND", "Freund")
L("ESO_IGNORED", "Ignoriert")                  -- // Google translate
L("ESO_GUILDMATE", "\"<<1>>\" gildenmitglied") -- // Google translate

-- Notifications and Warnings:
L("CONTACT_ADDED", "Spieler <<LINK>> wurde zu den Kontakten hinzugefügt.")
L("CONTACT_REMOVED", "Kontakt <<1>> wurde entfernt.")
L("TARGET_IN_CONTACTS", "Zielspieler <<LINK>> bereits in den Kontakten.")
L("CHAT_WHISPER_BLOCKED", "<<LINK>> ist ein <<ICON>><<GROUP>>. Chat ist für diese Gruppe von Schurken gesperrt.")
L("GROUP_WITH_VILLAIN", "Du bist einer Gruppe mit <<ICON>><<GROUP>> <<LINK>> beigetreten!")
L("GROUP_JOINED_VILLAIN", "<<ICON>><<GROUP>> <<LINK>> ist deiner Gruppe beigetreten!")
L("FRIEND_INVITE_FROM_VILLAIN", "<<ICON>><<GROUP>> <<LINK>> bittet um Freundschaft!")
L("GROUP_INVITE_FROM_VILLAIN", "<<ICON>><<GROUP>> <<NAME>> lädt dich zu seiner Gruppe ein!")
L("CONFIRM_CONTACT_ADD", "Möchtest du Spieler <<1>> wirklich zu den Kontakten hinzufügen?")
L("CONFIRM_CONTACT_REMOVE", "Möchtest du <<1>> wirklich aus den Kontakten entfernen?")
L("CONFIRM_INVITE_VILLAIN", "Möchtest du <<2>> <<1>> wirklich zur Gruppe einladen?")
L("CONFIRM_INVITE_VILLAIN_WARNING", "Bösewicht wird der Gruppe hinzugefügt!")
L("CONFIRM_BEFRIEND_VILLAIN", "Möchtest du <<2>> <<1>> wirklich zu den Freunden hinzufügen?")
L("CONFIRM_BEFRIEND_VILLAIN_WARNING", "Bösewicht wird den Freunden hinzugefügt!")
L("CONFIRM_IMPORT_FRIENDS", "Möchten Sie wirklich alle ESO-Freunde im Spiel in die Kontakte importieren?")
L("CONFIRM_IMPORT_IGNORED", "Möchten Sie wirklich alle ignorierten ESO-Spieler im Spiel in die Kontakte importieren?")
L("CONFIRM_IMPORT_NAMEZ", "Möchten Sie wirklich alle Freunde und Feinde aus dem Namez AddOn in die Kontakte importieren?")
L("NOTIFY_IMPORT_COMPLETED", "Import abgeschlossen.\n\n<<1>> neue Kontakte hinzugefügt.")

-- UI/Liste:
L("UI_TITLE", "Kontakte")
L("UI_TITLE_SUB", "Freunde und Schurken")
L("UI_INFO_NO_CONTACTS", "Sie haben keine Kontakte.")
L("UI_INFO_NO_CONTACTS_FOUND", "Keine Kontakte gefunden.")
L("UI_HEADER_ACCOUNT", "Konto")
L("UI_HEADER_GROUP", "Gruppe")
L("UI_HEADER_NOTE", "Hinweis")
L("UI_HEADER_TIMESTAMP", "Hinzugefügt")
L("UI_BTN_ADD_CONTACT_TOOLTIP", "Neuen Kontakt hinzufügen")
L("UI_BTN_OPEN_SETTINGS_TOOLTIP", "AddOn Einstellungen öffnen")
L("UI_BTN_SEARCH_RESET_TOOLTIP", "Suche zurücksetzen")
L("UI_CONTACTS_COUNT", "Kontakte insgesamt: %d Freund(e) und %d Bösewicht(e).")
L("UI_FILTERED_CONTACTS_COUNT", "%d Kontakt(e) gefunden).")

-- UI/Dialog:
L("UI_DIALOG_TITLE_ADD_CONTACT", "Neuen Kontakt hinzufügen Kontakt")
L("UI_DIALOG_TITLE_EDIT_CONTACT", "Kontakt bearbeiten")
L("UI_BTN_EDIT_ACCOUNT_NAME_TOOLTIP", "Kontonamen bearbeiten")
L("UI_DIALOG_CONTACT_ACCOUNT_NAME", "Kontoname:")
L("UI_DIALOG_CONTACT_CATEGORY", "Typ:")
L("UI_DIALOG_CONTACT_GROUP", "Gruppe:")
L("UI_DIALOG_CONTACT_NOTE", "Persönliche Notiz:")
L("UI_DIALOG_BUTTONE", "Speichern")

-- Kontextmenü:
L("MENU_ADD_CONTACT", "Zu Kontakten hinzufügen")
L("MENU_ADD_CONTACT_SUBMENU", "<<1>> hinzufügen") -- // Google translate
L("MENU_EDIT_CONTACT", "Kontakt bearbeiten")
L("MENU_REMOVE_CONTACT", "Aus Kontakten entfernen")

-- Einstellungen:
L("SETTINGS_GENERAL", "Allgemein")
L("SETTINGS_UI_SEARCH_NOTE", "Suche nach persönlichen Notizen des Kontakts zulassen")
L("SETTINGS_UI_SEARCH_NOTE_TOOLTIP", "Kontakte nach Kontonamen und persönlichen Notizen in der Kontaktliste suchen. Schalten Sie diese Einstellung AUS, um nur nach dem Kontonamen zu suchen.")

L("SETTINGS_COLORS", "Farben")
L("SETTINGS_COLORS_DESCRIPTION", "Hervorhebungsfarben für Kontakte.")
L("SETTINGS_COLOR", "<<1>> Farbe")

L("SETTINGS_GROUPS", "Gruppen")
L("SETTINGS_GROUPS_DESCRIPTION", "Kontaktgruppen bearbeiten.")

L("SETTINGS_CHAT", "Chat")
L("SETTINGS_CHAT_DESCRIPTION", "Chat-Einstellungen.")
L("SETTINGS_CHAT_BLOCK", "Chat-Blockierung")
L("SETTINGS_CHAT_BLOCK_CHANNELS", "Chatkanäle")
L("SETTINGS_CHAT_BLOCK_CHANNELS_DESCRIPTION", "Chatkanäle zum Blockieren von Nachrichten von Schurken einrichten.")
L("SETTINGS_CHAT_BLOCK_CHANNELS_NOTE", "Note: nur Nachrichten aus den oben ausgewählten Schurkenkategorien werden blockiert.")
L("SETTINGS_CHAT_BLOCK_CHANNEL_SAY", "%s, %s, %s", S(SI_CHAT_CHANNEL_NAME_SAY), S(SI_CHAT_CHANNEL_NAME_YELL), S(SI_CHAT_CHANNEL_NAME_EMOTE))
L("SETTINGS_CHAT_BLOCK_CHANNEL_ZONE", S(SI_CHAT_CHANNEL_NAME_ZONE))
L("SETTINGS_CHAT_BLOCK_CHANNEL_GROUP", S(SI_CHAT_CHANNEL_NAME_PARTY))
L("SETTINGS_CHAT_BLOCK_CHANNEL_GUILD", "Gilde und Gildenoffizier")
L("SETTINGS_CHAT_BLOCK_CHANNEL_WHISPER", S(SI_CHAT_CHANNEL_NAME_WHISPER))
L("SETTINGS_CHAT_BLOCK_CHANNEL_TOOLTIP", "Chatnachrichten von Schurken in diesem Kanal blockieren.")
L("SETTINGS_CHAT_INFO", "Keine Informationsnachrichten im Chat drucken")
L("SETTINGS_CHAT_INFO_TOOLTIP", "Keine Informationsnachrichten ('Kontakt hinzugefügt', 'Kontakt entfernt' usw.) im Chat drucken.")

L("SETTINGS_NOTIFICATION", "Benachrichtigungen und Warnungen")
L("SETTINGS_NOTIFICATION_DESCRIPTION", "Bildschirm- und Chat-Benachrichtigungen/Warnungen für Kontakte.")
L("SETTINGS_NOTIFICATION_CHANNEL", "Kanal für Benachrichtigungen und Infonachrichten")
L("SETTINGS_NOTIFICATION_CHANNEL_TOOLTIP", "Wohin Benachrichtigungen und Infonachrichten gesendet werden sollen.")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_BOTH", "Beide (Chat+Bildschirm)")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_CHAT", "Chat")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_SCREEN", "Bildschirm")
L("SETTINGS_NOTIFICATION_GROUP_JOIN", "Warnung anzeigen, wenn einer Gruppe mit Bösewicht beigetreten wird")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_TOOLTIP", "Warnung anzeigen (hängt von der Auswahl oben ab), wenn einer Gruppe mit Bösewicht beigetreten wird.")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER", "Warnung anzeigen, wenn Bösewicht Ihrer Gruppe beigetreten ist.")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_TOOLTIP", "Warnung anzeigen (hängt von der Auswahl oben ab), wenn Bösewicht Ihrer Gruppe beigetreten ist.")
L("SETTINGS_NOTIFICATION_GROUP_INVITE", "Warnung anzeigen, wenn Bösewicht Sie zur Gruppe einlädt.")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_TOOLTIP", "Warnung anzeigen (hängt von der Auswahl oben ab), wenn Bösewicht Sie zur Gruppe einlädt. Gruppe.")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE", "Warnung anzeigen, wenn Freundschaftsanfrage vom Bösewicht empfangen wird")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_TOOLTIP", "Warnung anzeigen (hängt von der Auswahl oben ab), wenn Freundschaftsanfrage vom Bösewicht empfangen wird.")
L("SETTINGS_AUTODECLINE_FRIEND_INVITE", "Automatisch ablehnen")
L("SETTINGS_AUTODECLINE_FRIEND_INVITE_TOOLTIP", "Freundschaftseinladungen automatisch ablehnen, wenn der Einladende ein Bösewicht ist.")
L("SETTINGS_AUTODECLINE_GROUP_INVITE", "Automatisch ablehnen")
L("SETTINGS_AUTODECLINE_GROUP_INVITE_TOOLTIP", "Gruppeneinladungen automatisch ablehnen, wenn der Einladende ein Bösewicht.")
L("SETTINGS_CONFIRM_ADD_FRIEND", "Hinzufügen von Bösewicht als Freund bestätigen")
L("SETTINGS_CONFIRM_ADD_FRIEND_TOOLTIP", "Bestätigungsdialog anzeigen, wenn versucht wird, Bösewicht zu den ESO-Freunden im Spiel hinzuzufügen.")

L("SETTINGS_RETICLE_MARKER", "Fadenkreuz-Zielmarkierung")
L("SETTINGS_RETICLE_MARKER_DESCRIPTION", "Zeige eine Markierung neben dem Fadenkreuz, wenn du Freunde oder Schurken anvisierst.")
L("SETTINGS_RETICLE_MARKER_ENABLE", "Aktivieren")
L("SETTINGS_RETICLE_MARKER_DISABLE_COMBAT", "Im Kampf deaktivieren")
L("SETTINGS_RETICLE_MARKER_DISABLE_COMBAT_TOOLTIP", "Deaktiviere die Fadenkreuz-Zielerkennung im Kampf (kann die Leistung verbessern).")
L("SETTINGS_RETICLE_MARKER_DISABLE_GROUP_DUNGEON", "In Gruppendungeons deaktivieren")                                                        -- // Google translate
L("SETTINGS_RETICLE_MARKER_DISABLE_GROUP_DUNGEON_TOOLTIP", "Deaktiviere die Fadenkreuz-Zielerkennung in Gruppendungeons und Gruppenarenen.") -- // Google translate
L("SETTINGS_RETICLE_MARKER_DISABLE_TRIAL", "In Raids/Trials deaktivieren")
L("SETTINGS_RETICLE_MARKER_DISABLE_TRIAL_TOOLTIP", "Deaktiviere die Fadenkreuz-Zielerkennung in Raids/Trrials (kann die Leistung verbessern).")
L("SETTINGS_RETICLE_MARKER_DISABLE_PVP", "In PvP-Zonen deaktivieren")
L("SETTINGS_RETICLE_MARKER_DISABLE_PVP_TOOLTIP", "Zielerkennung per Fadenkreuz in PvP-Zonen deaktivieren: Cyrodiil, Kaiserstadt, Schlachtfelder (kann die Leistung in diesen Zonen verbessern).")
L("SETTINGS_RETICLE_MARKER_POSITION", "Markierungsposition")
L("SETTINGS_RETICLE_MARKER_POSITION_TOOLTIP", "Position der Zielmarkierung am Fadenkreuz.")
L("SETTINGS_RETICLE_MARKER_POSITION_ABOVE", "Über dem Fadenkreuz")
L("SETTINGS_RETICLE_MARKER_POSITION_BELOW", "Unter dem Fadenkreuz")
L("SETTINGS_RETICLE_MARKER_OFFSET", "Markierung Offset")
L("SETTINGS_RETICLE_MARKER_OFFSET_TOOLTIP", "Nach oben verschieben, wenn sich die Markierung über dem Fadenkreuz befindet, oder nach unten verschieben, wenn sich die Markierung unter dem Fadenkreuz befindet.")
L("SETTINGS_RETICLE_MARKER_FONT_SIZE", "Schriftgröße")
L("SETTINGS_RETICLE_MARKER_FONT_STYLE", "Schriftdekoration")
L("SETTINGS_RETICLE_MARKER_ICON_ENABLE", "Symbol anzeigen")
L("SETTINGS_RETICLE_MARKER_ICON_ENABLE_TOOLTIP", "Zusätzliches Symbol über oder unter dem Text anzeigen.")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE", "Symbolgröße")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE_SMALL", "Klein (32x32)")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE_MEDIUM", "Mittel (48x48)")
L("SETTINGS_RETICLE_MARKER_ICON_SIZE_BIG", "Groß (64x64)")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_MARKERS", "Zusätzliche Markierungen")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_MARKERS_DESCRIPTION", "Zusätzliche Markierungen können an Orten mit vielen Spielern leicht die Leistung beeinträchtigen (z. B. Städte).")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_FRIEND", "Markierung für <<1>>ESO-Freunde hinzufügen")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_FRIEND_COLOR", "Markierungsfarbe für ESO-Freunde")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_IGNORED", "Markierung für <<1>>ignorierte Spieler hinzufügen")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_IGNORED_COLOR", "Markierungsfarbe für ignorierte Spieler")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_GUILDMATE", "Markierung für <<1>>Gildenmitglieder hinzufügen")
L("SETTINGS_RETICLE_MARKER_ADDITIONAL_GUILDMATE_COLOR", "Markierungsfarbe für Gildenmitglieder")

L("SETTINGS_IMPORT", "Importieren")
L("SETTINGS_IMPORT_DESCRIPTION", "Freunde und Bösewichte aus der ESO-Freundesliste und der Ignorierten-Liste im Spiel importieren.")
L("SETTINGS_IMPORT_BUTTON", "Importieren")
L("SETTINGS_IMPORT_DESTINATION", "Zur Gruppe hinzufügen:")
L("SETTINGS_IMPORT_DESTINATION_TOOLTIP", "Spieler in ausgewählte Gruppe importieren.")
L("SETTINGS_IMPORT_FRIENDS", "ESO-Freunde im Spiel in Kontakte importieren.")
L("SETTINGS_IMPORT_IGNORED", "ESO-Ignorierte Spieler im Spiel in Kontakte importieren.")

-- Slash commands:
L("SLASHCMD_NEW_CONTACT_TOOLTIP", "Dialogfeld \'Neuen Kontakt öffnen\'")
L("SLASHCMD_ADD_CONTACT_TOOLTIP", "Neuen Kontakt hinzufügen")
L("SLASHCMD_OPEN_SETTINGS_TOOLTIP", "AddOn-Einstellungsfenster öffnen")

-- Keybinds:
_L("SI_BINDING_NAME_XELCONTACTS_UI_SHOW", "Kontakte öffnen")
_L("SI_BINDING_NAME_XELCONTACTS_ADD_CONTACT", "Ziel zu Kontakten hinzufügen")
