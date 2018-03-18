local NAME, ADDON = ...

ADDON.bagController = {}
ADDON.bagController.__index = ADDON.bagController

local controller = ADDON.bagController

function controller:Init()
    ADDON.events:Add('MERCHANT_SHOW', self)
end

function mnkBagsBagContainer_OnShow()
    mnkBagsBagContainer.mainBar:Show()
    ADDON.events:Add('INVENTORY_SEARCH_UPDATE', controller)
    ADDON.events:Add('BAG_UPDATE', controller)
    ADDON.events:Add('BAG_UPDATE_COOLDOWN', controller)
    ADDON.events:Add('ITEM_LOCK_CHANGED', controller)
    ADDON.events:Add('BAG_UPDATE_DELAYED', controller)
    ADDON.events:Add('mnkBags_BAG_HOVER', controller)
end

function mnkBagsBagContainer_OnHide()
    ADDON.events:Remove('INVENTORY_SEARCH_UPDATE', controller)
    ADDON.events:Remove('BAG_UPDATE', controller)
    ADDON.events:Remove('BAG_UPDATE_COOLDOWN', controller)
    ADDON.events:Remove('ITEM_LOCK_CHANGED', controller)
    ADDON.events:Remove('BAG_UPDATE_DELAYED', controller)
    ADDON.events:Remove('mnkBags_BAG_HOVER', controller)

    if ADDON.settings:GetSettings(mnkBags_TYPE_MAIN)[mnkBags_SETTING_CLEAR_NEW_ITEMS] then
        C_NewItems:ClearAll()
    end
end

function DJDBagsBagsButton_OnClick(self)
    if self:GetChecked() then
        controller:ShowBagBar()
    else
        controller:HideBagBar()
    end
end

function controller:Update()
    ADDON:UpdateBags({0, 1, 2, 3, 4})
    mnkBagsBagContainer:Arrange()
end

function controller:Toggle()
    if mnkBagsBagContainer:IsVisible() then
        self:Close()
    else
        self:Open()
    end
end

function controller:Open()
    self:Update()
    mnkBagsBagContainer:Show()
end

function controller:Close()
    mnkBagsBagContainer:Hide()
end

function controller:OnItemsCleared()
    if mnkBagsBagContainer:IsVisible() then
        self:Update()
    end
end

function controller:BAG_UPDATE(bag)
    ADDON:UpdateBags({bag})
    mnkBagsBagContainer:Arrange()
end

function controller:MERCHANT_SHOW()
    if ADDON.settings:GetSettings(mnkBags_TYPE_MAIN)[mnkBags_SETTING_SELL_JUNK] then
        local price = 0
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1 , GetContainerNumSlots(bag) do
                if select(4, GetContainerItemInfo(bag, slot)) == LE_ITEM_QUALITY_POOR then
                    --ShowMerchantSellCursor(1)
                    UseContainerItem(bag, slot)
                    price = price + select(11, GetItemInfo(GetContainerItemID(bag, slot)))
                end
            end
        end
        ResetCursor()
        if price ~= 0 then
            DEFAULT_CHAT_FRAME:AddMessage(string.format(mnkBags_LOCALE_SOLD_JUNK, GetCoinTextureString(price)))
        end
    end
end

function controller:INVENTORY_SEARCH_UPDATE()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateSearch()
        end
    end
end

function controller:BAG_UPDATE_COOLDOWN()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateCooldown()
        end
    end
end

function controller:ITEM_LOCK_CHANGED(bag, slot)
    if bag then
        if bag >= 0 and bag <= NUM_BAG_SLOTS and slot then
            ADDON.cache:GetItem(bag, slot):UpdateLock()
        end
        if mnkBagsBagContainer.mainBar.bagBar and mnkBagsBagContainer.mainBar.bagBar.bags[bag] then
            mnkBagsBagContainer.mainBar.bagBar.bags[bag]:UpdateLock()
        end
    end
end

function controller:mnkBags_BAG_HOVER(bag, locked)
    if bag and bag >= 0 and bag <= NUM_BAG_SLOTS then
        for bagSlot = 0, NUM_BAG_SLOTS do
            if bagSlot ~= bag then
                for slot = 1, GetContainerNumSlots(bagSlot) do
                    ADDON.cache:GetItem(bagSlot, slot):SetFiltered(locked)
                end
            end
        end
    end
end

function controller:BAG_UPDATE_DELAYED()
    if mnkBagsBagContainer.mainBar.bagBar then
        for _, bagItem in pairs(mnkBagsBagContainer.mainBar.bagBar.bags) do
            bagItem:Update()
        end
    end
end

function controller:ShowBagBar()
    self:GetBagBar():Show()
end

function controller:HideBagBar()
    self:GetBagBar():Hide()
end

function controller:GetBagBar()
    if not mnkBagsBagContainer.mainBar.bagBar then
        local bagBar = CreateFrame('Frame', 'mnkBagsBagBar', mnkBagsBagContainer.mainBar, 'mnkBagsContainerTemplate')
        bagBar.bags = {}

        local prevBag
        for bag = 1, NUM_BAG_SLOTS do
            local bagItem = ADDON:NewBagItem('mnkBagsBag_' .. bag, bag, GetInventorySlotInfo("Bag" .. (bag-1) .. "Slot"))
            bagItem:SetParent(bagBar.container)
            bagItem:SetPoint('TOPRIGHT', prevBag or bagBar.container, prevBag and 'TOPLEFT' or 'TOPRIGHT', prevBag and -5 or 0, 0)
            bagItem:Update()
            bagItem:Show()
            prevBag = bagItem
            bagBar.bags[bagItem:GetID()] = bagItem
        end

        bagBar:SetSize((prevBag:GetWidth() + 5) * NUM_BAG_SLOTS - 5 + bagBar.padding * 2, prevBag:GetHeight() + bagBar.padding * 2)
        bagBar:SetPoint('TOPRIGHT', mnkBagsBagContainer.mainBar, 'BOTTOMRIGHT', 0, -5)

        mnkBagsBagContainer.mainBar.bagBar = bagBar
    end
    return mnkBagsBagContainer.mainBar.bagBar
end