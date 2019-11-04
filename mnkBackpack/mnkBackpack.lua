-- Backpack external layout based on code by P3lim.
local addonName = ...
local COLUMNS = 12; 

local ICON_TEXTURES = [[Interface\AddOns\mnkLibs\Assets\icons]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}
local scanTip = CreateFrame("GameTooltip", "scanTip", UIParent, "GameTooltipTemplate")

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
    Container.Title = mnkLibs.createFontString(Container, mnkLibs.Fonts.oswald, 14)
    Container.Title:SetPoint('TOPLEFT', 6, -5)
    Container.Title:SetText(Container.name)
    Container.columns = COLUMNS; 
    Container:EnableMouse(true)

    local Anchor = CreateFrame('Frame', '$parentAnchor', Container)
    Anchor:SetPoint('TOPLEFT', 10, -26)
    Anchor:SetSize(1, 1) -- needs a size
    Container.anchor = Anchor

    Container:SetBackdrop(BACKDROP)
    Container:SetBackdropColor(0, 0, 0, 1)
    Container:SetBackdropBorderColor(0.2, 0.2, 0.2)
    Container.extraPaddingY = 16 -- needs a little extra because of the title
    Container:SetFrameStrata('HIGH'); 
    if (Container == BackpackBank) then
        Container:SetBackdropColor(1/5, 1/8, 1/8, 1)
    elseif (Container == Backpack) then
        Container:SetBackdropColor(1/8, 1/5, 1/8, 1)
        Container.extraPaddingY = 36 -- needs more space for the footer
        Backpack.buttonClose = CreateFrame('button', nil, Container)
        mnkLibs.setTooltip(Backpack.buttonClose,'Click to close backpack.')
        Backpack.buttonClose:SetFrameLevel(Container:GetFrameLevel() + 2)
        Backpack.buttonClose:SetPoint('BOTTOMLEFT', 3, 1)
        Backpack.buttonClose:SetSize(16, 16)
        Backpack.buttonClose:HookScript('OnClick', function () Backpack:Hide() end )
        Backpack.buttonClose:Show()
        Backpack.buttonClose.Texture = Backpack.buttonClose:CreateTexture('$parentIcon', 'OVERLAY')
        Backpack.buttonClose.Texture:SetAllPoints()
        Backpack.buttonClose.Texture:SetTexture(ICON_TEXTURES)
        Backpack.buttonClose.Texture:SetTexCoord(0, 0.25, 0, 0.25)
        Backpack.buttonClose.Texture:SetVertexColor(1, 0.1, 0.1)
    end
end

local function SkinSlot(Slot)
    Slot:SetSize(32, 32)
    Slot:SetBackdrop(BACKDROP)
    Slot:SetBackdropColor(0.1, 0.1, 0.1, 1)
    Slot:SetBackdropBorderColor(0, 0, 0)
    Slot.ItemLevel = mnkLibs.createFontString(Slot, mnkLibs.Fonts.ap, 18, nil, nil, true)
    Slot.ItemLevel:SetPoint('CENTER', 0, 0)
    Slot.ItemLevel:SetJustifyH('CENTER')
    Slot.ItemLevel:SetShadowOffset(2, -2)
    Slot.Icon:ClearAllPoints()
    Slot.Icon:SetPoint('TOPLEFT', 1, -1)
    Slot.Icon:SetPoint('BOTTOMRIGHT', -1, 1)
    Slot.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    Slot.Count = mnkLibs.createFontString(Slot, mnkLibs.Fonts.ap, 16, nil, nil, true)
    Slot.Count:SetPoint('BOTTOMRIGHT', 0, 0)
    Slot.Count:Show()
    Slot.boe = mnkLibs.createFontString(Slot, mnkLibs.Fonts.ap, 50, nil, nil, true)
    Slot.boe:SetPoint('TOPLEFT', -3, 37)
    Slot.boe:SetJustifyH('LEFT')
    Slot.boe:SetTextColor(1, 0, 0, 1)
    Slot.boe:SetText('.')
    Slot.boe:Hide()
	
    -- Slot.PushedTexture:ClearAllPoints()
    -- Slot.PushedTexture:SetPoint('TOPLEFT', 1, -1)
    -- Slot.PushedTexture:SetPoint('BOTTOMRIGHT', -1, 1)
    -- Slot.PushedTexture:SetColorTexture(1, 1, 1, 0.3)
    -- Slot.HighlightTexture:ClearAllPoints()
    -- Slot.HighlightTexture:SetPoint('TOPLEFT', 1, -1)
    -- Slot.HighlightTexture:SetPoint('BOTTOMRIGHT', -1, 1)
    -- Slot.HighlightTexture:SetColorTexture(0, 0.6, 1, 0.3)
    -- Slot.NormalTexture:SetSize(0.1, 0.1)

    if (Slot.QuestIcon) then Slot.QuestIcon:Hide() end
    if (Slot.NewItem) then Slot.NewItem:Hide() end
    if (Slot.Flash) then Slot.Flash:Hide() end
    if (Slot.BattlePay) then Slot.BattlePay:Hide() end
end

Backpack:AddLayout('mnkBackpack', SkinContainer, SkinSlot)

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
            local link = GetContainerItemLink(Slot.bagID, Slot.slotID)
              if link then
                local itemBOE = false
                local itemLevel = 0
                scanTip:ClearLines()
                -- Weird issue with the tooltip not refilling/painting with the details of a bank item. This
                -- resolves that issue and it makes no sense why.
                if Slot.bagID < 0 then
                    scanTip:SetHyperlink(link)
                end
                scanTip:SetOwner(UIParent,"ANCHOR_NONE")
                scanTip:SetBagItem(Slot.bagID, Slot.slotID)
                for i=1, 5 do
                    local l = _G["scanTipTextLeft"..i]:GetText()
                    if itemLevel == 0 and l and l:find('Item Level') then
                        local _, c = string.find(l, 'Item Level%s%d')
                        -- check for boosted levels ie Chromeie scenarios.
                        local _, x = string.find(l, " (", 1, true)
                        if x then
                            itemLevel = tonumber(string.sub(l, c, x-2)) or 0
                        end
                        itemLevel = tonumber(string.sub(l, c)) or 0            
                    end
                    
                    if itemBOE == false and l and l:find(ITEM_BIND_ON_EQUIP) then
                        itemBOE = true
                    end 
                end
                
                if itemLevel > 0 then
                    Slot.ItemLevel:SetText(itemLevel)
                    Slot.ItemLevel:SetTextColor(1, 1, 1, 1)
                    Slot.ItemLevel:SetShadowColor(r/5, g/5, b/5, 1)
                    Slot.ItemLevel:Show()
                else
                    Slot.ItemLevel:SetText()
                    Slot.ItemLevel:Hide()
                end
        
                if itemBOE == true then
                    Slot.boe:Show()
                else
                    Slot.boe:Hide()
                end        
            end
        else
            Slot.ItemLevel:Hide()
            Slot.boe:Hide()
        end
        if (itemQuestID or questItem) then
            Slot:SetBackdropBorderColor(1, 1, 0)
        elseif (itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
            Slot:SetBackdropBorderColor(r, g, b)
        else
            Slot:SetBackdropBorderColor(0, 0, 0)
        end
    else
        Slot.ItemLevel:Hide()
        Slot.boe:Hide()
    end
end)

Backpack:On('PostCreateMoney', function(Money)
    Money:ClearAllPoints()
    Money:SetPoint('BOTTOMRIGHT', -4, 3)
    Money:SetFont(mnkLibs.Fonts.ap, 16, '')
    Money:SetShadowOffset(0, 0)
end)

local function OnSearchOpen(self)
    local SearchBox = self:GetParent()
    SearchBox:SetPoint('LEFT', 0, 0)
    SearchBox:SetWidth(SearchBox:GetParent():GetWidth()-50)
    SearchBox.searchButton:Hide()
    SearchBox.Editbox:Show()
    SearchBox.Editbox.Texture:Show()
    Backpack.buttonClose:Hide()
end

local function OnSearchClosed(self)
    local SearchBox = self:GetParent()
    SearchBox:ClearAllPoints()
    SearchBox:SetPoint('BOTTOM', 0, 2)
    SearchBox:SetSize(18,18)
    SearchBox.Editbox:SetText('')
    SearchBox.Editbox.Texture:Hide()
    SearchBox.Editbox:Hide()
    SearchBox.searchButton:Show()
    Backpack.buttonClose:Show()
end

Backpack:On('PostCreateSearch', function(SearchBox)
    SearchBox:ClearAllPoints()
    SearchBox:SetPoint('BOTTOM', 0, 2)
    SearchBox:SetSize(16,16)
    SearchBox:SetFrameLevel(SearchBox:GetParent():GetFrameLevel() + 1)
    SearchBox:SetAlpha(1)
    SearchBox.SetAlpha = mnkLibs.donothing
    SearchBox.searchButton = CreateFrame('button', nil, SearchBox) 
    mnkLibs.setTooltip(SearchBox.searchButton, 'Click to search, press ESC to cancel.')
    SearchBox.searchButton:SetPoint('CENTER', 0, -1)
    SearchBox.searchButton:SetSize(16, 16)
    SearchBox.searchButton:SetFrameLevel(SearchBox:GetParent():GetFrameLevel() + 2)
    SearchBox.searchButton:HookScript('OnClick', OnSearchOpen)
    SearchBox.searchButton:Show()
    SearchBox.searchButton.Texture = SearchBox.searchButton:CreateTexture('$parentIcon', 'OVERLAY')
    SearchBox.searchButton.Texture:SetAllPoints()
    SearchBox.searchButton.Texture:SetTexture(ICON_TEXTURES)
    SearchBox.searchButton.Texture:SetTexCoord(0.75, 1, 0.75, 1)
    SearchBox.Editbox:SetFont(mnkLibs.Fonts.ap, 16, '')
    SearchBox.Editbox:SetShadowOffset(0, 0)
    SearchBox.Editbox:HookScript('OnEscapePressed', OnSearchClosed)
    SearchBox.Editbox.Texture = SearchBox.Editbox:CreateTexture('$parentIcon', 'OVERLAY')
    SearchBox.Editbox.Texture:SetPoint('RIGHT', SearchBox.Editbox, 'LEFT', -5, 0)
    SearchBox.Editbox.Texture:SetSize(16, 16)
    SearchBox.Editbox.Texture:SetTexture(ICON_TEXTURES)
    SearchBox.Editbox.Texture:SetTexCoord(0.75, 1, 0.75, 1)
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
