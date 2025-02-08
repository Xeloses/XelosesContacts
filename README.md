# Xeloses' Contacts

**License**: [GNU GPL v3](https://github.com/Xeloses/XelosesContacts/blob/main/LICENSE)

**Change log**: [read](https://github.com/Xeloses/XelosesContacts/blob/master/CHANGELOG.md)

**Addon page at ESOUI**: [link](https://www.esoui.com/downloads/info4025-XelosesContacts.html)

## Description

**Xeloses' Contacts** is an [Elder Scrolls Online](https://www.elderscrollsonline.com) addon that provides unlimited Friends and Villains list with UI and additional features.

This addon works with account names, not character names, so no matter which character your contacts loggen in, they are still be accessible!

#### You can open Contacts window using one of the following ways:
* hotkey (*setup it in addons keybinds*),
* button in main menu ("Extended Journal" button),
* slash command (*see below*).

#### To add player to Contacts you can use:
* context menu at:
  - Friends list window,
  - Ignored players list window,
  - Group window,
  - Guild roster window,
  - chat links (*note that not all chat links can be used, only those which provides account name via ingame API*);
* hotkey (*setup it in addons keybinds*) to add player under your reticle;
* slash command (*see below*).

## Features:
* unlimited Friends and Villains list:
  - lists are server-wide (shared between all accounts and characters on the server);
* text notes for Friends and Villains;
* groups for Friends and Villains to split lists:
  - 5 predefined groups for Friends and 5 for Villains;
  - customizable group names;
* add players to Contacts using context menus in Friends list window, Group window, Guild roster window, on chat links;
* add player under reticle to Contacts;
* hide chat messages from Villains (*configurable*):
  - configure groups of Villains to hide chat messages from;
  - configure chat channels where messages from selected groups of Villains should be hidden;
* auto decline friend and group invites from Villains (*optional*);
* display a marker near the reticle when targeting Friends or Villains:
  - display icon and group name of targeted Friend or Villain;
  - may also display marker for guildmates, ESO ingame friends, ignored players (*optional*);
  - option to disable target scanning in combat, in PvP-zones, in group dungeons/arenas, in Trials;
* notifications:
  - notification when joining group with Villain (*optional*);
  - notification when Villain joins your group (*optional*);
  - notification when Villain invites you to group (*optional*);
  - notification when Villain sends you a friend request (*optional*);
  - confirmation dialog when adding Villain to ESO ingame Friends (*optional*);
* import contacts from ingame Friends and Ignored list (including their correspondend notes).

### UI:
* Contacts window with Friends and Villains list (*see screenshots*);
* filter list by group;
* search contacts by account name and personal note;
* Whisper, Group invite, Send mail, Visit house and Teleport to from Contacts window.

### Slash commands:
* **/contacts** - open Contacts window;
* **/contacts config** - open addon settings.

With [LibSlashCommander](https://esoui.com/downloads/info1508-LibSlashCommander.html) installed additional command options can be used:
* **/contacts new** - show new contact dialog;
* **/contacts add @account_name [*optional personal note*]** - add @account_name to Contacts.

## Dependencies

#### Required libraries:
* [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-libaddonmenu.html)
* [LibCustomMenu](https://www.esoui.com/downloads/info1146-LibCustomMenu.html)
* [LibSavedVars](https://esoui.com/downloads/info2161-LibSavedVars.html)
* [LibExtendedJournal](https://www.esoui.com/downloads/info4031-LibExtendedJournal.html)

#### Optional:
* [LibChatMessage](https://esoui.com/downloads/info2382-LibChatMessage.html) *(highly reccomended)*
* [LibSlashCommander](https://esoui.com/downloads/info1508-LibSlashCommander.html) to use slash commands with arguments.
* [LibDebugLogger](https://esoui.com/downloads/info2275-LibDebugLogger.html) + [DebugLogViewer](https://esoui.com/downloads/info2389-DebugLogViewer.html) to get access to blocked chat messages from Villains (*blocked messages will be available in DebugLogViewer window*).

## Language support
* **English**
* **Russian**
* **German** by **[Baertram](https://www.esoui.com/forums/member.php?u=2028)**

*I'm sorry for my english, its not my native language and I didn't learn it at schooll/college, so I can make some mistakes.*

If you wanna help with translation feel free to contact me [here](https://www.esoui.com/forums/private.php?do=newpm&u=35044) on ESOUI or at [GitHub](https://github.com/Xeloses/XelosesContacts/issues). Any help in the translation is welcome!

## Known issues
* No gamepad support atm.
* Not all chat links can be used for adding players to Contacts.
* [pChat](https://www.esoui.com/downloads/info93-pChatChatcustomizationamphelplo....html) with a specific configuration creates chat links with account name before character name, those links can't be processed properly by addon.

## Reporting an issue:
Before you [report](https://github.com/Xeloses/XelosesContacts/issues/new?template=bug_report.md) something, please make sure you have installed the latest version of all your addons (include libraries) and check the comment section + [GitHub issues](https://github.com/Xeloses/XelosesContacts/issues) section for known issues.

Please cover the following points in your report:
1) How to reproduce an issue, which steps/conditions did you take to set to issue?
2) What actually happened?
3) What were you trying to do? Which steps did you take?
4) Can you reproduce it a second time after logging out and in again (or /reloadui)?

Screenshots are also very useful to figure out what is going wrong.

## Donations
If you like my work you can support me by sending some thanking gift or in-game gold to **@Savaoth** on **EU** server. Feel free to contact me via ingame mail to check which DLC I don't own :)

## Roadmap / Future plans
**[!]** *No guarantees or time frames when it will be implemented.*

* Add player to contacts using context menu on group/raid frames.
* Show contact status (online/afk/offline) in Contacts window.
* Mark Friends or Villains in group window.
* Backup/export contacts.
* [LibChatMenuButton](https://www.esoui.com/downloads/info3805-LibChatMenuButton.html) integration.
* [OdySupportIcons](https://www.esoui.com/downloads/info2834-OdySupportIcons-GroupRoleIconsMore.html) integration.
* Import contacts from [Namez](https://www.esoui.com/downloads/info3411-Namez-Moreinfowhenyouputyourreticleonotherplayers.html) addon.

## Disclaimer
> This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
