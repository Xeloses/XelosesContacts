# CHANGELOG

### Version 1.2.9 *(2025-06-10)*
* **Features:**:
  * **Reticle target marker** updates:
    * Ossein Cage added to the Trials list.

### Version 1.2.8 *(2025-06-05)*
* API bump for Update 46;
* Updated required library versions.

### Version 1.2.7 *(2025-05-05)*
* Updated required library versions.

### Version 1.2.6 *(2025-05-03)*
* **Bug fixes:**
  * Minor bug fixes.

### Version 1.2.5 *(2025-04-13)*
* **Bug fixes:**
  * Fixed an issue with import.

### Version 1.2.4 *(2025-03-18)*
* **Features:**:
  * **Chat blocking** updates:
    * disallow initiating private chat with Villains from blocked groups via chat links.
  * **Reticle target marker** updates:
    * added option "Display mode" to select display text only, icon only, or both text and icon for Reticle marker;
    * added option to configure colorizing of game reticle when targeting Contacts.

### Version 1.2.3 *(2025-03-15)*
* **QoL changes**:
  * initially selected category in Contacts list UI no more affected by "Default category for **__new__** contacts" option;
  * newly created Villain groups now have chat blocking turned ON by default *(it will not affect previously created custom groups)*.
* **Bug fixes:**
  * Minor bug fixes.

### Version 1.2.2 *(2025-03-07)*
* API bump for Update 45;
* Minor bug fixes.

### Version 1.2.1 *(2025-03-07)*
* Bug fixes.

### Version 1.2.0 *(2025-03-02)*
* **New features:**
  * **Custom contact groups**:
    * add/remove custom contact groups:
      * up to 40 additional custom groups can be created *(up to 20 for friends and up to 20 for Villains);*
      * any custom group can be removed;
        * existing contacts from removed group will be automatically moved to the first predefined group;
        * predefined groups can not be removed;
    * edit name and icon of any contact group (include predefined);
    * setup chat blocking for any custom Villain group.
* **Misc.:**
  * Colorized Contacts category dropdowns.
  * Updated Contact tooltip appearance.
  * Improved PvP-zones detection for battlegrounds.
  * Reorganized Settings panel elements.

### Version 1.1.4 *(2025-02-22)*
* **Features:**
  * **Chat caching** updates:
    * added Group chat to caching chat channels list to provide context menu on all teammates in the chat;
    * increased maximum available cache size to 1000.

### Version 1.1.3 *(2025-02-20)*
* **New features:**
  * Added **Chat caching**
    * cache last **N** *(max cache size can be configured in settings)* seen chat message senders in Zone and Say chat channels to provide account name for context menu;
    * "***Add to Contacts***" context menu item should be available for much more chat messages;
    * can be disabled in settings.
* **Misc.:**
  * Changed Settings panel appearance.

### Version 1.1.2 *(2025-02-10)*
* **Bug fixes:**
  * Fixed an issue with chat blocking *(it should work again now)*.

### Version 1.1.1 *(2025-02-08)*
* **Features:**:
  * **Reticle target marker** updates:
    * Added "Disable in Group dungeons" option.
    * Added auto disable feature:
      * auto disable reticle target tracking in solo arenas *(e.g. Maelstorm arena)*;
      * auto disable reticle target tracking in Infinite archive;
      * auto disable reticle target tracking in group dungeons, group arenas and trials if player is not in group;
        * auto re-enable reticle target tracking when players joins group while in group dungeon, group arena or trial.
    * Little perfomance optimizations for reticle target tracking.
    * Improved PvP-zones detection.
    * Slightly ajusted default settings.
* **Bug fixes:**
  * Fixed an issue with context menu of ESO friends list and ignored players list.
  * Fixed duplicate contacts issue.
  * Fixed spellchecking in Edit contact dialog.
* **Dependencies:**
  * **[LibExtendedJournal](https://www.esoui.com/downloads/info4031-LibExtendedJournal.html)** no longer included in the addon archive and should be installed separately *(it was released as a standalone library)*.
* **Translation:**
  * Updated **German** translation (by [Baertram](https://www.esoui.com/forums/member.php?u=2028)).

### Version 1.1.0 *(2025-02-07)*
* **New features:**
  * Added **Reticle target marker**.
  * Added a watcher to auto-rename contacts when associated player from ESO ingame friends has been renamed.
* **Dependencies:**
  * Code updates for **LibCustomMenu** v7.3.0
* **Bug fixes:**
    * multiple minor bug fixes.

### Version 1.0.3 *(2025-02-01)*
* **Bug fixes:**
  * Fixed an issue with account names containing non-english letters.

### Version 1.0.2 *(2025-01-26)*
* **Dependencies:**
  * **LibCustomMenu** added to dependencies.
* **Translation:**
  * Added **German** translation (by [Baertram](https://www.esoui.com/forums/member.php?u=2028)).
* **Misc.:**
  * Code improvements for better compatibility with other addons.

### Version 1.0.1 *(2025-01-25)*
* **Bug fixes:**
  * Fixed teleportation retry delay.
  * Fixed issue with folders structure inside archive.

### Version 1.0.0 *(2025-01-23)*
* **Initial release**.
