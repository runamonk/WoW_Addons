local NAME, ADDON = ...

--region Types

mnkBags_TYPE_CONTAINER = 'container'
mnkBags_TYPE_ITEM_CONTAINER = 'itemContainer'
mnkBags_TYPE_SUB_CLASS = 'mnkBags_sub_classes'
mnkBags_TYPE_MAIN = 'mnkBags_main_settings'
mnkBags_TYPE_MAIN_BAR = 'mnkBags_main_bar'
mnkBags_TYPE_BANK_BAR = 'mnkBags_bank_bar'

mnkBags_FORMATTER_MASONRY = 1
mnkBags_FORMATTER_BOX = 2

--endregion

--region Settings

mnkBags_SETTING_BACKGROUND_COLOR = 'mnkBags_background_color'
mnkBags_SETTING_BORDER_COLOR = 'mnkBags_border_color'
mnkBags_SETTING_TEXT_COLOR = 'mnkBags_text_color'
mnkBags_SETTING_PADDING = 'mnkBags_padding'
mnkBags_SETTING_SPACING = 'mnkBags_spacing'
mnkBags_SETTING_SCALE = 'mnkBags_scale'
mnkBags_SETTING_CLEAR_NEW_ITEMS = 'mnkBags_clear_new_items'
mnkBags_SETTING_FORMATTER = 'mnkBags_formatter'
mnkBags_SETTING_FORMATTER_VERT = 'mnkBags_formatter_vert'
mnkBags_SETTING_FORMATTER_MAX_ITEMS = 'mnkBags_formatter_max_items'
mnkBags_SETTING_FORMATTER_MAX_HEIGHT = 'mnkBags_formatter_max_height'
mnkBags_SETTING_FORMATTER_BOX_COLS = 'mnkBags_formatter_box_cols'
mnkBags_SETTING_TRUNCATE_SUB_CLASS = 'mnkBags_truncate_sub_class'
mnkBags_SETTING_TEXT_SIZE = 'mnkBags_truncate_text_size'
mnkBags_SETTING_STACK_ALL = 'mnkBags_stack_all_items'
mnkBags_SETTING_SELL_JUNK = 'mnkBags_auto_sell_junk'
mnkBags_SETTING_DEPOSIT_REAGENT = 'mnkBags_auto_deposit_reagents'
mnkBags_SETTING_BOE = 'mnkBags_class_boe'
mnkBags_SETTING_BOA = 'mnkBags_class_boa'

--endregion

--region Locale

local localeText= {}
localeText['enUS'] = function()
    mnkBags_LOCALE_MAIN_SETTINGS = 'Main Settings:'
    mnkBags_LOCALE_ITEM_CONTAINER_SETTINGS = 'Item Container Settings:'
    mnkBags_LOCALE_CONTAINER_SETTINGS = 'Category Container Settings:'
    mnkBags_LOCALE_SUB_CLASS_SETTINGS = 'Sub Class Settings:'
    mnkBags_LOCALE_MAIN_BAR_SETTINGS = 'Main Bar Settings:'
    mnkBags_LOCALE_BANK_BAR_SETTINGS = 'Bank Bar Settings:'
    mnkBags_LOCALE_FORMAT_SETTINGS = 'Format Settings:'
    mnkBags_LOCALE_SETTINGS = 'mnkBags Settings:'
    mnkBags_LOCALE_CLEAR_NEW_ITEMS = 'Clear new items'
    mnkBags_LOCALE_BACKGROUND_COLOR = 'Background color'
    mnkBags_LOCALE_BORDER_COLOR = 'Border color'
    mnkBags_LOCALE_TEXT_COLOR = 'Text color'
    mnkBags_LOCALE_PADDING = 'Padding'
    mnkBags_LOCALE_SPACING = 'Spacing'
    mnkBags_LOCALE_SCALE = 'Scale'
    mnkBags_LOCALE_TEXT_SIZE = 'Text size'
    mnkBags_LOCALE_STACK_ALL = 'Stack all items'
    mnkBags_LOCALE_SELL_JUNK = 'Auto sell junk'
    mnkBags_LOCALE_DEPOSIT_REAGENT = 'Auto deposit reagents'
    mnkBags_LOCALE_MASONRY = 'Masonry'
    mnkBags_LOCALE_BOX = 'Box'
    mnkBags_LOCALE_CATEGORY_DIALOG_TITLE = 'Set category for: %s'
    mnkBags_LOCALE_GLOBAL = 'Global'
    mnkBags_LOCALE_BOE = 'BoE'
    mnkBags_LOCALE_BOA = 'BoA'
    mnkBags_LOCALE_VERTICAL = 'Vertical'
    mnkBags_LOCALE_MAX_ITEMS = 'Max items'
    mnkBags_LOCALE_MAX_HEIGHT = 'Max height'
    mnkBags_LOCALE_SOLD_JUNK = 'Sold junk for: %s'
    mnkBags_LOCALE_CLEAR_NEW_ITEMS_CLOSE = 'Clear new items on close'
end

localeText['deDE'] = function()
    mnkBags_LOCALE_MAIN_SETTINGS = 'Allgemein:'
    mnkBags_LOCALE_ITEM_CONTAINER_SETTINGS = 'Gegenstandsbehälter:'
    mnkBags_LOCALE_CONTAINER_SETTINGS = 'Kategoriebehälter:'
    mnkBags_LOCALE_SUB_CLASS_SETTINGS = 'Untergliederung:'
    mnkBags_LOCALE_MAIN_BAR_SETTINGS = 'Hauptleiste:'
    mnkBags_LOCALE_BANK_BAR_SETTINGS = 'Bankleiste:'
    mnkBags_LOCALE_FORMAT_SETTINGS = 'Format:'
    mnkBags_LOCALE_SETTINGS = 'mnkBags-Einstellungen:'
    mnkBags_LOCALE_CLEAR_NEW_ITEMS = 'Neue Gegenstände leeren'
    mnkBags_LOCALE_BACKGROUND_COLOR = 'Hintergrundfarbe'
    mnkBags_LOCALE_BORDER_COLOR = 'Rahmenfarbe'
    mnkBags_LOCALE_TEXT_COLOR = 'Schriftfarbe'
    mnkBags_LOCALE_PADDING = 'Einrückung'
    mnkBags_LOCALE_SPACING = 'Abstand'
    mnkBags_LOCALE_SCALE = 'Skalierung'
    mnkBags_LOCALE_TEXT_SIZE = 'Schriftgröße'
    mnkBags_LOCALE_STACK_ALL = 'Alle Gegenstände stapeln'
    mnkBags_LOCALE_SELL_JUNK = 'Schrott autom. verkaufen'
    mnkBags_LOCALE_DEPOSIT_REAGENT = 'Material automatisch einlagern'
    mnkBags_LOCALE_MASONRY = 'Mauerwerk'
    mnkBags_LOCALE_BOX = 'Kiste'
    mnkBags_LOCALE_CATEGORY_DIALOG_TITLE = 'Kategorie festlegen für: %s'
    mnkBags_LOCALE_GLOBAL = 'Global'
    mnkBags_LOCALE_BOE = 'Beim Anlegen gebunden'
    mnkBags_LOCALE_BOA = 'Battle.net-Accountgebunden'
    mnkBags_LOCALE_VERTICAL = 'Vertikal'
    mnkBags_LOCALE_MAX_ITEMS = 'Max. Gegenstände'
    mnkBags_LOCALE_MAX_HEIGHT = 'Max. Höhe'
    mnkBags_LOCALE_SOLD_JUNK = 'Schrott verkauft für: %s'
    mnkBags_LOCALE_CLEAR_NEW_ITEMS_CLOSE = 'Neue Artikel beim Schließen löschen'
end

localeText['zhTW'] = function()
    mnkBags_LOCALE_MAIN_SETTINGS = '主設定:'
    mnkBags_LOCALE_ITEM_CONTAINER_SETTINGS = '分類外觀設定:'
    mnkBags_LOCALE_CONTAINER_SETTINGS = '背包外觀設定:'
    mnkBags_LOCALE_SUB_CLASS_SETTINGS = '子分類設定:'
    mnkBags_LOCALE_MAIN_BAR_SETTINGS = '主要功能列設定:'
    mnkBags_LOCALE_BANK_BAR_SETTINGS = '銀行功能列設定:'
    mnkBags_LOCALE_FORMAT_SETTINGS = '排列方式設定:'
    mnkBags_LOCALE_SETTINGS = 'mnkBags 背包設定:'
    mnkBags_LOCALE_CLEAR_NEW_ITEMS = '清理新物品'
    mnkBags_LOCALE_BACKGROUND_COLOR = '背景顏色'
    mnkBags_LOCALE_BORDER_COLOR = '邊框顏色'
    mnkBags_LOCALE_TEXT_COLOR = '文字顏色'
    mnkBags_LOCALE_PADDING = '內距'
    mnkBags_LOCALE_SPACING = '間距'
    mnkBags_LOCALE_SCALE = '縮放大小'
    mnkBags_LOCALE_TEXT_SIZE = '文字大小'
    mnkBags_LOCALE_STACK_ALL = '堆疊所有物品'
    mnkBags_LOCALE_SELL_JUNK = '自動賣垃圾'
    mnkBags_LOCALE_DEPOSIT_REAGENT = '自動存放材料'
    mnkBags_LOCALE_MASONRY = '磚牆'
    mnkBags_LOCALE_BOX = '方盒'
    mnkBags_LOCALE_CATEGORY_DIALOG_TITLE = '設定分類: %s'
    mnkBags_LOCALE_GLOBAL = '全部'
    mnkBags_LOCALE_BOE = '裝備綁定'
    mnkBags_LOCALE_BOA = '帳號綁定'
    mnkBags_LOCALE_VERTICAL = '垂直'
    mnkBags_LOCALE_MAX_ITEMS = '分類寬度最多物品數目'
    mnkBags_LOCALE_MAX_HEIGHT = '最大高度'
    mnkBags_LOCALE_SOLD_JUNK = '賣出垃圾獲得: %s'
    mnkBags_LOCALE_CLEAR_NEW_ITEMS_CLOSE = '清除關閉的新項目'
end

if localeText[GetLocale()] then
    localeText[GetLocale()]()
else
    localeText['enUS']()
end

--endregion
