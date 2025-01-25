local S = GetString

--Do not use ZO_CreateStringId for the same string constant twice! Use SafeAddString function and increase the version number by +1 instead. Described here:
--https://wiki.esoui.com/How_to_add_localization_support
local _SAV = SafeAddString

local function L(id, value, ...)
    local params = { ... }
    if (params and #params > 0) then value = string.format(value, ...) end
    return _SAV(_G["XELCONTACTS_" .. tostring(id)], value, 2)
end

-- ============================
-- === Russian localization ===
-- ============================

L("ALL", "Все")
L("DECLINED", "отклонено")
L("WARNING", "WARNING!")
L("ERROR", "ОШИБКА")

-- Contact types:
L("FRIENDS", "Друзья")
L("FRIEND", "Друг")
L("VILLAINS", "Недруги")
L("VILLAIN", "Недруг")

-- Contact groups (default):
L("GROUP_11", "Друг")
L("GROUP_12", "Данжи/Триалы")
L("GROUP_13", "Домики")
L("GROUP_14", "Услуги")
L("GROUP_15", "RP")

L("GROUP_21", "Враг")
L("GROUP_22", "Токсик")
L("GROUP_23", "Спаммер")
L("GROUP_24", "Читер")
L("GROUP_25", "Вредитель")

-- Roles:
L("DPS", "ДД")
L("TANK", "Танк")
L("HEAL", "Целитель")

-- Notifications and Warnings:
L("CONTACT_ADDED", "Игрок <<LINK>> был добавлен в Контакты.")
L("CONTACT_REMOVED", "Контакт <<1>> удален.")
L("TARGET_IN_CONTACTS", "Игрок <<LINK>> уже есть в Контактах.")
L("CHAT_WHISPER_BLOCKED", "<<LINK>> - <<ICON>><<GROUP>>. Чат заблокирован для этой группы контактов.")
L("GROUP_WITH_VILLAIN", "Вы вступили в группу с <<ICON>><<GROUP>> <<LINK>>!")
L("GROUP_JOINED_VILLAIN", "<<ICON>><<GROUP>> <<LINK>> присоединился к Вашей группе!")
L("FRIEND_INVITE_FROM_VILLAIN", "<<ICON>><<GROUP>> <<LINK>> хочет добавить Вас в друзья!")
L("GROUP_INVITE_FROM_VILLAIN", "<<ICON>><<GROUP>> <<NAME>> приглашает Вас в группу!")
L("CONFIRM_CONTACT_ADD", "Вы уверены что хотите добавить <<1>> в Контакты?")
L("CONFIRM_CONTACT_REMOVE", "Вы уверены что хотите убрать <<1>> из Контактов?")
L("CONFIRM_INVITE_VILLAIN", "Вы уверены что хотите пригласить <<2>> <<1>> в группу?")
L("CONFIRM_INVITE_VILLAIN_WARNING", "Приглашение недруга в группу!")
L("CONFIRM_BEFRIEND_VILLAIN", "Вы уверены что хотите добавить <<2>> <<1>> в друзья?")
L("CONFIRM_BEFRIEND_VILLAIN_WARNING", "Добавление недруга в друзья!")
L("CONFIRM_IMPORT_FRIENDS", "Вы уверены что хотите импортировать всех игроков из списка друзей ESO в Контакты?")
L("CONFIRM_IMPORT_IGNORED", "Вы уверены что хотите импортировать всех игнорируемых игроков в Контакты?")
L("CONFIRM_IMPORT_NAMEZ", "Вы уверены что хотите импортировать всех друзей и врагов из аддона Namez в Контакты?")
L("NOTIFY_IMPORT_COMPLETED", "Импорт завершен.\n\nДобавлено <<1>> новых контактов.")

-- UI/List:
L("UI_TITLE", "Контакты")
L("UI_TITLE_SUB", "Друзья и Недруги")
L("UI_INFO_NO_CONTACTS", "Список контактов пуст.")
L("UI_INFO_NO_CONTACTS_FOUND", "Контакты не найдены.")
L("UI_HEADER_ACCOUNT", "Аккаунт")
L("UI_HEADER_GROUP", "Группа")
L("UI_HEADER_NOTE", "Примечание")
L("UI_HEADER_TIMESTAMP", "Дата добавления")
L("UI_BTN_ADD_CONTACT_TOOLTIP", "Добавить новый контакт")
L("UI_BTN_OPEN_SETTINGS_TOOLTIP", "Перейти к настройкам")
L("UI_BTN_SEARCH_RESET_TOOLTIP", "Очистить поиск")
L("UI_CONTACTS_COUNT", "Всего контактов: %d друзей and %d недругов.")
L("UI_FILTERED_CONTACTS_COUNT", "Найдено %d контакт(ы).")

-- UI/Dialogs:
L("UI_DIALOG_TITLE_ADD_CONTACT", "Новый контакт")
L("UI_DIALOG_TITLE_EDIT_CONTACT", "Редактировать")
L("UI_BTN_EDIT_ACCOUNT_NAME_TOOLTIP", "Изменить имя аккаунта")
L("UI_DIALOG_CONTACT_ACCOUNT_NAME", "Имя аккаунта:")
L("UI_DIALOG_CONTACT_CATEGORY", "Категория:")
L("UI_DIALOG_CONTACT_GROUP", "Группа:")
L("UI_DIALOG_CONTACT_NOTE", "Примечания:")
L("UI_DIALOG_BUTTON_SAVE", "Сохранить")

-- Context menu:
L("MENU_ADD_CONTACT", "Добавить в Контакты")
L("MENU_EDIT_CONTACT", "Редактировать")
L("MENU_REMOVE_CONTACT", "Убрать из Контактов")

-- Settings:
L("SETTINGS_GENERAL", "Основные")
L("SETTINGS_UI_SEARCH_NOTE", "Поиск в примечаниях")
L("SETTINGS_UI_SEARCH_NOTE_TOOLTIP", "Включить поиск контактов по имени аккаунта и по тексту примечания. Отключите эту опцию, чтобы искать только по имени аккаунта.")
L("SETTINGS_COLORS", "Цвета")
L("SETTINGS_COLORS_DESCRIPTION", "Цветовая маркировка контактов.")
L("SETTINGS_COLOR", "<<1>>")
L("SETTINGS_NOTIFICATION", "Оповещения")
L("SETTINGS_NOTIFICATION_DESCRIPTION", "Настройки оповещения и предупреждений.")
L("SETTINGS_NOTIFICATION_CHANNEL", "Канал оповещений")
L("SETTINGS_NOTIFICATION_CHANNEL_TOOLTIP", "Куда отправлять оповещения и предупреждения.")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_BOTH", "Чат + Экран")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_CHAT", "Чат")
L("SETTINGS_NOTIFICATION_CHANNEL_OPTION_SCREEN", "Экран")
L("SETTINGS_NOTIFICATION_GROUP_JOIN", "Оповещать о вступлении в группу с недругом")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_TOOLTIP", "Показывать оповещение при вступлении в группу, в которой есть игроки из списка недругов.")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_SCREEN", "Крупное оповещение в центре экрана")
L("SETTINGS_NOTIFICATION_GROUP_JOIN_SCREEN_TOOLTIP", "Показывать крупное оповещение в центре экрана при вступлении в группу, в которой есть игроки из списка недругов.")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER", "Оповещать когда недруг присоединяется к группе")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_TOOLTIP", "Показывать оповещение когда недруг присоединяется к Вашей группе.")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_SCREEN", "Крупное оповещение в центре экрана")
L("SETTINGS_NOTIFICATION_GROUP_MEMBER_SCREEN_TOOLTIP", "Показывать крупное оповещение в центре экрана когда недруг присоединяется к Вашей группе.")
L("SETTINGS_NOTIFICATION_GROUP_INVITE", "Оповещать когда недруг приглашает Вас в группу")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_TOOLTIP", "Показывать оповещение когда недруг приглашает Вас в группу.")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_SCREEN", "Крупное оповещение в центре экрана")
L("SETTINGS_NOTIFICATION_GROUP_INVITE_SCREEN_TOOLTIP", "Показывать крупное оповещение в центре экрана когда недруг приглашает Вас в группу.")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE", "Оповещать когда недруг хочет добавить Вас в друзья")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_TOOLTIP", "Показывать оповещение когда недруг хочет добавить Вас в друзья.")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_SCREEN", "Крупное оповещение в центре экрана")
L("SETTINGS_NOTIFICATION_FRIEND_INVITE_SCREEN_TOOLTIP", "Показывать крупное оповещение в центре экрана когда недруг хочет добавить Вас в друзья.")
L("SETTINGS_AUTODECLINE_FRIEND_INVITE", "Отклонять приглашения в друзья от Недругов")
L("SETTINGS_AUTODECLINE_FRIEND_INVITE_TOOLTIP", "Автоматически отклонять приглашения в друзья от Недругов.")
L("SETTINGS_AUTODECLINE_GROUP_INVITE", "Отклонять приглашения в группу от Недругов")
L("SETTINGS_AUTODECLINE_GROUP_INVITE_TOOLTIP", "Автоматически отклонять приглашения в группу от Недругов.")
L("SETTINGS_CONFIRM_ADD_FRIEND", "Подтверждение при добавлении недруга в список друзей ESO.")
L("SETTINGS_CONFIRM_ADD_FRIEND_TOOLTIP", "Показывать диалог подтверждения при добавлении недругов в список друзей ESO.")
L("SETTINGS_CHAT", "Чат")
L("SETTINGS_CHAT_DESCRIPTION", "Настройки чата.")
L("SETTINGS_CHAT_BLOCK", "Блокировка чата")
L("SETTINGS_CHAT_BLOCK_GROUPS", "Группы")
L("SETTINGS_CHAT_BLOCK_GROUPS_DESCRIPTION", "Блокировка чата по группам:")
L("SETTINGS_CHAT_BLOCK_GROUP", "Блокировать чат для группы <<1>> (<<2>>)")
L("SETTINGS_CHAT_BLOCK_GROUP_TOOLTIP", "Скрывать сообщения чата для недругов из этой группы.")
L("SETTINGS_CHAT_BLOCK_CHANNELS", "Каналы чата")
L("SETTINGS_CHAT_BLOCK_CHANNELS_DESCRIPTION", "Блокировать сообщения чата от недругов в следующих каналах чата (блокироваться будут только сообщения от групп недругов, выбранных выше):")
L("SETTINGS_CHAT_BLOCK_CHANNEL_SAY", "%s, %s, %s", S(SI_CHAT_CHANNEL_NAME_SAY), S(SI_CHAT_CHANNEL_NAME_YELL), S(SI_CHAT_CHANNEL_NAME_EMOTE))
L("SETTINGS_CHAT_BLOCK_CHANNEL_ZONE", S(SI_CHAT_CHANNEL_NAME_ZONE))
L("SETTINGS_CHAT_BLOCK_CHANNEL_GROUP", S(SI_CHAT_CHANNEL_NAME_PARTY))
L("SETTINGS_CHAT_BLOCK_CHANNEL_GUILD", "Гильдия (включая офицерский канал)")
L("SETTINGS_CHAT_BLOCK_CHANNEL_WHISPER", S(SI_CHAT_CHANNEL_NAME_WHISPER))
L("SETTINGS_CHAT_BLOCK_CHANNEL_TOOLTIP", "Блокировать сообщения чата от недругов в этом канале.")
L("SETTINGS_CHAT_INFO", "Не отображать информационные сообщения в чате")
L("SETTINGS_CHAT_INFO_TOOLTIP", "Не отправлять информационные сообщения (такие как 'Контакт был добавлен', 'Контакт был удален', и т.п.) в чат.")
L("SETTINGS_GROUPS", "Группы")
L("SETTINGS_GROUPS_DESCRIPTION", "Редактировать группы контактов.")
L("SETTINGS_GROUP_NAME", "Название группы <<1>>:")
L("SETTINGS_IMPORT", "Импорт")
L("SETTINGS_IMPORT_DESCRIPTION", "Импорт контактов из игровых списков ESO.")
L("SETTINGS_IMPORT_BUTTON", "Импортировать")
L("SETTINGS_IMPORT_DESTINATION", "Добавить в группу:")
L("SETTINGS_IMPORT_DESTINATION_TOOLTIP", "Группа, в которую будут импортированы контакты.")
L("SETTINGS_IMPORT_FRIENDS", "Импортировать игроков из списка друзей ESO.")
L("SETTINGS_IMPORT_IGNORED", "Импортировать игнорируемых игроков ESO.")

-- Slash commands:
L("SLASHCMD_NEW_CONTACT_TOOLTIP", "Показать диалог добавления контакта")
L("SLASHCMD_ADD_CONTACT_TOOLTIP", "Добавить в контакты")
L("SLASHCMD_OPEN_SETTINGS_TOOLTIP", "Открыть настройки аддона")

-- Keybinds:
_SAV("SI_BINDING_NAME_XELCONTACTS_UI_SHOW", "Список контактов", 2)
_SAV("SI_BINDING_NAME_XELCONTACTS_ADD_CONTACT", "Добавить цель в Контакты", 2)
