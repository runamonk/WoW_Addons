local NAME, ADDON = ...

function ADDON:PrintTable(tbl, lvl)
    local prefix = ''
    lvl = lvl or 0
    for _ = 1, lvl do
        prefix = prefix .. '   '
    end
    for k, v in pairs(tbl) do
        print(prefix, k, v)
        if (type(v) == 'table') then
            ADDON:PrintTable(v, lvl + 1)
        end
    end
end

ADDON.settings = {}
local settings = ADDON.settings

function settings:Init()
    self.realm = GetRealmName()
    self.player = UnitName("player")

    mnkBags_DB = mnkBags_DB or {}
    --Changed this so that all settings are saved to none (realm) with a user of all. This
    --way all my users have the same layout for the bags.
    
--[[    mnkBags_DB[self.realm] = mnkBags_DB[self.realm] or {}
    mnkBags_DB[self.realm][self.player] = mnkBags_DB[self.realm][self.player] or {}
    mnkBags_DB[self.realm][self.player].userDefined = mnkBags_DB[self.realm][self.player].userDefined or {}
    mnkBags_DB[self.realm][self.player].hiddenContainers = mnkBags_DB[self.realm][self.player].hiddenContainers or {}--]]
    mnkBags_DB["none"] = mnkBags_DB["none"] or {}
    mnkBags_DB["none"]["all"] = mnkBags_DB["none"]["all"] or {}
    mnkBags_DB["none"]["all"].userDefined = mnkBags_DB["none"]["all"].userDefined or {}
    mnkBags_DB["none"]["all"].hiddenContainers = mnkBags_DB["none"]["all"].hiddenContainers or {}

    mnkBags_DB.userDefined = mnkBags_DB.userDefined or {}

    self.default = {
        [mnkBags_TYPE_MAIN] = {
            [mnkBags_SETTING_STACK_ALL] = true,
            [mnkBags_SETTING_SELL_JUNK] = true,
            [mnkBags_SETTING_DEPOSIT_REAGENT] = false,
            [mnkBags_SETTING_SCALE] = 0.8,
            [mnkBags_SETTING_CLEAR_NEW_ITEMS] = true,
        },
        [mnkBags_TYPE_CONTAINER] = {
            [mnkBags_SETTING_BACKGROUND_COLOR] = {0.0, 0.0, 0.0, 1},
            [mnkBags_SETTING_BORDER_COLOR] = {0.0, 0.0, 0.0, 1},
            [mnkBags_SETTING_PADDING] = 5.5,
            [mnkBags_SETTING_SPACING] = 2,
            [mnkBags_SETTING_FORMATTER] = mnkBags_FORMATTER_BOX,
            [mnkBags_SETTING_FORMATTER_VERT] = false,
            [mnkBags_SETTING_FORMATTER_MAX_ITEMS] = 5,
            [mnkBags_SETTING_FORMATTER_MAX_HEIGHT] = 68,
            [mnkBags_SETTING_FORMATTER_BOX_COLS] = 6,
            [mnkBags_SETTING_TRUNCATE_SUB_CLASS] = false,
        },
        [mnkBags_TYPE_ITEM_CONTAINER] = {
            [mnkBags_SETTING_BACKGROUND_COLOR] = {0.08, 0.08, 0.08, 1},
            [mnkBags_SETTING_BORDER_COLOR] = {0, 0, 0, 1},
            [mnkBags_SETTING_TEXT_COLOR] = {1, 1, 1, 1},
            [mnkBags_SETTING_TEXT_SIZE] = 10,
            [mnkBags_SETTING_PADDING] = 5,
            [mnkBags_SETTING_SPACING] = 3,
        },
        [mnkBags_TYPE_SUB_CLASS] = {
            [LE_ITEM_CLASS_ARMOR] = false,
            [LE_ITEM_CLASS_CONSUMABLE] = false,
            [LE_ITEM_CLASS_GEM] = false,
            [LE_ITEM_CLASS_GLYPH] = false,
            [LE_ITEM_CLASS_ITEM_ENHANCEMENT] = false,
            [LE_ITEM_CLASS_MISCELLANEOUS] = false,
            [LE_ITEM_CLASS_RECIPE] = false,
            [LE_ITEM_CLASS_TRADEGOODS] = false,
            [LE_ITEM_CLASS_WEAPON] = false,
            [mnkBags_SETTING_BOE] = false,
            [mnkBags_SETTING_BOA] = false,
        },
        [mnkBags_TYPE_MAIN_BAR] = {
            [mnkBags_SETTING_BACKGROUND_COLOR] = {0, 0, 0, 0.6},
            [mnkBags_SETTING_BORDER_COLOR] = {0, 0, 0, 1},
        },
        [mnkBags_TYPE_BANK_BAR] = {
            [mnkBags_SETTING_BACKGROUND_COLOR] = {0, 0, 0, 0.6},
            [mnkBags_SETTING_BORDER_COLOR] = {0, 0, 0, 1},
        }
    }

    self:Update()
end

function settings:Update(force)
    self:UpdateBag(mnkBagsBagContainer, ADDON.bagController, ADDON.cache.bagContainers, force)
    self:UpdateBag(mnkBagsBankContainer, ADDON.bankController, ADDON.cache.bankContainers, force)
    self:UpdateBag(mnkBagsReagentContainer, ADDON.bankController, ADDON.cache.reagentContainers, force)
    self:UpdateBar(mnkBagsBagContainer.mainBar)
    self:UpdateBar(mnkBagsBankBar)

    local scale = self:GetSettings(mnkBags_TYPE_MAIN)[mnkBags_SETTING_SCALE]
    mnkBagsBagContainer:SetScale(scale)
    mnkBagsBankBar:SetScale(scale)
end

function settings:UpdateBar(bar)
    bar:UpdateFromSettings()
end

function settings:UpdateBag(bag, controller, list, force)
    bag:UpdateFromSettings()
    for _, container in pairs(list) do
        container:UpdateFromSettings()
    end

    if bag:IsVisible() and force == 1 then
        bag:Arrange(true)
    elseif bag:IsVisible() and force == 2 then
        controller:Update()
    end
end

function settings:IsContainerHidden(container)
    return mnkBags_DB["none"]["all"].hiddenContainers[container]
end

function settings:SetContainerHidden(container)
    mnkBags_DB["none"]["all"].hiddenContainers[container] = true
end

function settings:SetContainerVisible(container)
    mnkBags_DB["none"]["all"].hiddenContainers[container] = nil
end

function settings:GetSettings(type)
    local settings = mnkBags_DB["none"]["all"][type] or {}
    self:MigrateSettings(settings, self.default[type]or {})

    return settings
end

function settings:SetSettings(type, setting, out, force)
    mnkBags_DB["none"]["all"][type] = mnkBags_DB["none"]["all"][type] or {}
    mnkBags_DB["none"]["all"][type][setting] = out

    self:Update(force)
end

function settings:GetUserDefinedList()
    return mnkBags_DB["none"]["all"].userDefined
end

function settings:AddUserDefinedItem(id, name)
    mnkBags_DB["none"]["all"].userDefined[id] = name
    self:Update(2)
end

function settings:GetGlobalUserDefinedList()
    return mnkBags_DB.userDefined
end

function settings:AddGlobalDefinedItem(id, name)
    mnkBags_DB.userDefined[id] = name
    self:Update(2)
end

function settings:ClearUserDefinedItem(id)
    mnkBags_DB["none"]["all"].userDefined[id] = nil
    mnkBags_DB.userDefined[id] = nil
    self:Update(2)
end

function settings:MigrateSettings(table, default)
    for k, v in pairs(default) do
        if table[k] ~= nil then
            if type(v) ~= type(table[k]) then
                table[k] = v
            elseif type(v) == 'table' then
                self:MigrateSettings(table[k], v)
            end
        else
            table[k] = v
        end
    end
end