-- Backpack external layout based on code by p3lim.
local addonName = ...
local COLUMNS = 12; 

local ICON_TEXTURES = [[Interface\AddOns\mnkLibs\Assets\icons]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

LibStub('LibDropDown'):RegisterStyle(addonName, {
    gap = 18, 
    padding = 8, 
    spacing = 0, 
    backdrop = {
        bgFile = [[Interface\ChatFrame\ChatFrameBackground]], 
        edgeFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeSize = 1
    }, 
    backdropColor = CreateColor(0, 0, 0, 1), 
    backdropBorderColor = CreateColor(0.2, 0.2, 0.2)
})

Backpack.Dropdown:SetStyle(addonName)
Backpack.Dropdown:SetFrameLevel(Backpack:GetFrameLevel() + 2)

local function SkinContainer(Container)
    Container.Title = CreateFontString(Container, mnkLibs.Fonts.oswald, 14)
    Container.Title:SetPoint('TOPLEFT', 6, -5)
    Container.Title:SetText(Container.name)
    Container.columns = COLUMNS; 

    local Anchor = CreateFrame('Frame', '$parentAnchor', Container)
    Anchor:SetPoint('TOPLEFT', 10, -26)
    Anchor:SetSize(1, 1) -- needs a size
    Container.anchor = Anchor

    Container:SetBackdrop(BACKDROP)
    Container:SetBackdropColor(0, 0, 0, 1)
    Container:SetBackdropBorderColor(0.2, 0.2, 0.2)
    Container.extraPaddingY = 16 -- needs a little extra because of the title
    Container:SetFrameStrata('HIGH'); 
    --Container:SetScale(0.9)

    if (Container == Backpack) then
        Container.extraPaddingY = 36 -- needs more space for the footer
    end
end

local function SkinSlot(Slot)
    Slot:SetSize(32, 32)
    Slot:SetBackdrop(BACKDROP)
    Slot:SetBackdropColor(0.1, 0.1, 0.1, 1)
    Slot:SetBackdropBorderColor(0, 0, 0)
    Slot.ItemLevel = CreateFontString(Slot, mnkLibs.Fonts.ap, 20, nil, nil, true)
    Slot.ItemLevel:SetPoint('CENTER', 0, 0)
    Slot.ItemLevel:SetJustifyH('CENTER')
    Slot.Icon:ClearAllPoints()
    Slot.Icon:SetPoint('TOPLEFT', 1, -1)
    Slot.Icon:SetPoint('BOTTOMRIGHT', -1, 1)
    Slot.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    Slot.Count = CreateFontString(Slot, mnkLibs.Fonts.ap, 16, nil, nil, true)
    Slot.Count:SetPoint('BOTTOMRIGHT', 0, 0)
    Slot.Count:Show()
    Slot.boe = CreateFontString(Slot, mnkLibs.Fonts.ap, 50, nil, nil, true)
    Slot.boe:SetPoint('TOPLEFT', -5, 35)
    Slot.boe:SetJustifyH('LEFT')
    Slot.boe:SetTextColor(1, 0, 0, 1)
    Slot.boe:SetText('.')
    Slot.boe:Hide()
    Slot.PushedTexture:ClearAllPoints()
    Slot.PushedTexture:SetPoint('TOPLEFT', 1, -1)
    Slot.PushedTexture:SetPoint('BOTTOMRIGHT', -1, 1)
    Slot.PushedTexture:SetColorTexture(1, 1, 1, 0.3)
    Slot.HighlightTexture:ClearAllPoints()
    Slot.HighlightTexture:SetPoint('TOPLEFT', 1, -1)
    Slot.HighlightTexture:SetPoint('BOTTOMRIGHT', -1, 1)
    Slot.HighlightTexture:SetColorTexture(0, 0.6, 1, 0.3)
    Slot.NormalTexture:SetSize(0.1, 0.1)

    if (Slot.QuestIcon) then Slot.QuestIcon:Hide() end
    if (Slot.NewItem) then Slot.NewItem:Hide() end
    if (Slot.Flash) then Slot.Flash:Hide() end
    if (Slot.BattlePay) then Slot.BattlePay:Hide() end
end

Backpack:AddLayout('mnkBackpack', SkinContainer, SkinSlot)

local function IsItemBOE(bagID, slotID)
    local link = GetContainerItemLink(bagID, slotID)
    if link then 
        local tip, leftside = CreateFrame('GameTooltip', 'mnkBackpackScanTooltip'), {}

        for i = 1, 5 do
            local L, R = tip:CreateFontString(), tip:CreateFontString()
            L:SetFontObject(GameFontNormal)
            R:SetFontObject(GameFontNormal)
            tip:AddFontStrings(L, R)
            leftside[i] = L
        end
        tip.leftside = leftside
        tip:ClearLines()

        tip:SetOwner(UIParent, 'ANCHOR_NONE')
        tip:SetBagItem(bagID, slotID)

        -- third line for equipment is the bind type/status
        local t = tip.leftside[3]:GetText()
        
        if t and t:find(ITEM_BIND_ON_EQUIP) then
            return true
        end

        tip:Hide()
    end

    return false
end

Backpack:Override('UpdateSlot', function(Slot)
    local itemTexture, itemCount, isLocked, itemQuality, isReadable, isLootable, _, _, _, itemID = Backpack:GetContainerItemInfo(Slot.bagID, Slot.slotID)
    local questItem, itemQuestID, itemQuestActive = Backpack:GetContainerItemQuestInfo(Slot.bagID, Slot.slotID)
    local r, g, b, hex = GetItemQualityColor(itemQuality)

    local Icon = Slot.Icon
    Icon:SetTexture(itemTexture)
    Icon:SetDesaturated(isLocked)

    Slot.Count:SetText(itemCount > 1e3 and '*' or itemCount > 1 and itemCount or '')
    if (itemID) then
        local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
        if (itemQuality >= LE_ITEM_QUALITY_UNCOMMON and (itemClass == LE_ITEM_CLASS_WEAPON or itemClass == LE_ITEM_CLASS_ARMOR or (itemClass == LE_ITEM_CLASS_GEM and itemSubClass == 11))) then
            local ItemLevel = Slot.ItemLevel
            ItemLevel:SetFormattedText('|c%s%s|r', hex, Slot.itemLevel)
            ItemLevel:Show()

            local b = IsItemBOE(Slot.bagID, Slot.slotID)

            if b then
                Slot.boe:Show()
            else
                Slot.boe:Hide()
            end

        else
            Slot.ItemLevel:Hide()
        end

        if (itemQuestID or questItem) then
            Slot:SetBackdropBorderColor(1, 1, 0)
        elseif (itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
            Slot:SetBackdropBorderColor(r, g, b)
        else
            Slot:SetBackdropBorderColor(0, 0, 0)
        end
    end
end)

Backpack:On('PostCreateMoney', function(Money)
    Money:ClearAllPoints()
    Money:SetPoint('BOTTOMRIGHT', -5, 5)
    Money:SetFont(mnkLibs.Fonts.ap, 16, '')
    Money:SetShadowOffset(0, 0)
end)

local function OnSearchOpen(self)
    self.Icon:Hide()
    self:SetFrameLevel(self:GetFrameLevel() + 1)
end

local function OnSearchClosed(self)
    local SearchBox = self:GetParent()
    SearchBox.Icon:Show()
    SearchBox:SetFrameLevel(SearchBox:GetFrameLevel() - 1)
end

Backpack:On('PostCreateSearch', function(SearchBox)
    SearchBox:SetBackdrop(BACKDROP)
    SearchBox:SetBackdropColor(0, 0, 0, 0.9)
    SearchBox:SetBackdropBorderColor(0, 0, 0)
    SearchBox:HookScript('OnClick', OnSearchOpen)

    local SearchBoxIcon = SearchBox:CreateTexture('$parentIcon', 'OVERLAY')
    SearchBoxIcon:SetPoint('CENTER')
    SearchBoxIcon:SetSize(16, 16)
    SearchBoxIcon:SetTexture(ICON_TEXTURES)
    SearchBoxIcon:SetTexCoord(0.75, 1, 0.75, 1)
    SearchBox.Icon = SearchBoxIcon

    local Editbox = SearchBox.Editbox
    Editbox:SetFont(mnkLibs.Fonts.ap, 16, '')
    Editbox:SetShadowOffset(0, 0)
    Editbox:HookScript('OnEscapePressed', OnSearchClosed)

    local EditboxIcon = Editbox:CreateTexture('$parentIcon', 'OVERLAY')
    EditboxIcon:SetPoint('RIGHT', Editbox, 'LEFT', -4, 0)
    EditboxIcon:SetSize(16, 16)
    EditboxIcon:SetTexture(ICON_TEXTURES)
    EditboxIcon:SetTexCoord(0.75, 1, 0.75, 1)
    Editbox.Icon = EditboxIcon
end)

Backpack:On('PostCreateContainerButton', function(Button)
    Button.Texture:SetTexture(ICON_TEXTURES)
end)

Backpack:On('PostCreateBagSlots', function(Button)
    Button:GetParent().ToggleBagSlots.Texture:SetTexCoord(0, 0.25, 0.25, 0.5)
end)

local function OnClickDepositReagents(self)
    DepositReagentBank(); 
end

Backpack:On('PostCreateDepositReagents', function(Button)
    Button.Texture:SetTexCoord(0.5, 0.75, 0, 0.25)
    Button:HookScript('OnClick', OnClickDepositReagents)

    OnClickDepositReagents(Button)
end)

local function OnClickAutoDeposit(self)
    if (BackpackDB.autoDepositReagents) then
        self.Texture:SetVertexColor(0, 0.6, 1)
    else
        self.Texture:SetVertexColor(0.3, 0.3, 0.3)
    end
end

Backpack:On('PostCreateAutoDeposit', function(Button)
    Button.Texture:SetTexCoord(0.5, 0.75, 0, 0.25)
    Button:HookScript('OnClick', OnClickAutoDeposit)

    OnClickAutoDeposit(Button)
end)

local function OnClickSellJunk(self)
    if (BackpackDB.autoSellJunk) then
        self.Texture:SetVertexColor(1, 0.1, 0.1)
    else
        self.Texture:SetVertexColor(0.3, 0.3, 0.3)
    end
end

Backpack:On('PostCreateSellJunk', function(Button)
    Button.Texture:SetTexCoord(0, 0.25, 0, 0.25)
    Button:HookScript('OnClick', OnClickSellJunk)

    OnClickSellJunk(Button)
end)

Backpack:On('PostCreateResetNew', function(Button)
    Button.Texture:SetTexCoord(0.75, 1, 0, 0.25)
end)

Backpack:On('PostCreateRestack', function(Button, SecondButton)
    Button.Texture:SetTexCoord(0.25, 0.5, 0, 0.25)

    if (SecondButton) then
        SecondButton.Texture:SetTexCoord(0.25, 0.5, 0, 0.25)
    end
end)

local function OnClickToggleLock(self)
    if (Backpack.locked) then
        self.Texture:SetTexCoord(0, 0.25, 0.75, 1)
        self.Texture:SetVertexColor(1, 1, 1)
    else
        self.Texture:SetTexCoord(0.25, 0.5, 0.75, 1)
        self.Texture:SetVertexColor(0.1, 1, 0.1)
    end
end

Backpack:On('PostCreateToggleLock', function(Button)
    Button:HookScript('OnClick', OnClickToggleLock)
    OnClickToggleLock(Button)
end)
