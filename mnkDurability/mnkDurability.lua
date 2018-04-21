mnkDurability = CreateFrame('Frame')
mnkDurability.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')
local t = {}

function mnkDurability:DoOnEvent(event, arg1)
   
    if event == 'PLAYER_LOGIN' then
        mnkDurability.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkDurability', {
            icon = 'Interface\\Icons\\Inv_chest_plate15.blp', 
            type = 'data source', 
            OnEnter = mnkDurability.DoOnEnter, 
            OnClick = mnkDurability.DoOnClick
        })
        self.LDB.label = 'Durability'
    elseif event == 'MERCHANT_SHOW' then
        local c = GetRepairAllCost()

        if GetMoney() >= c and c > 0 then
            RepairAllItems()
            print('Gear repaired for: '..GetCoinTextureString(c))
        
        --guild repairs.
        --GetGuildBankWithdrawMoney()
        --RepairAllItems(1)   
        end
        -- UNIT_INVENTORY_CHANGED happens a jillion times. We only need it to happen for player, at least then we know that
        -- player's items have been loaded and we can actually get item info and durability info. Then unregister it. Otherwise it will fire
        -- so much it will kill the clients fps and loading times.
    elseif event == 'PLAYER_ENTERING_WORLD' then
        mnkDurability:RegisterEvent('UNIT_INVENTORY_CHANGED')    
    elseif event == 'UNIT_INVENTORY_CHANGED' and arg1 == 'player' then
        mnkDurability:UnregisterEvent('UNIT_INVENTORY_CHANGED')
    end

    self.LDB.text = self.GetText()
end

function mnkDurability.DoOnClick(self)
    ToggleCharacter('PaperDollFrame')
end

function mnkDurability.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkDurabilityTooltip', 5, 'LEFT', 'LEFT', 'RIGHT', 'RIGHT', 'RIGHT')
    self.tooltip = tooltip
    
    tooltip:Clear()
    local ItemCount = 0
    local Total = 0
    local Current = 0
    
    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Slot', mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Durability', mnkLibs.Color(COLOR_GOLD)..'Level')
    
    for i in pairs(t) do 
        Current = (Current + t[i].Current)
        Total = (Total + t[i].Max)
        if (t[i].ItemID == nil) then
            pct = '-'
        else
            if (t[i].Max > 0) then
                pct = math.floor((t[i].Current / t[i].Max) * 100)..'%'
            else
                pct = '-'
            end
        end

        local y, x = tooltip:AddLine(t[i].Text, t[i].ItemName, pct, t[i].Level)
        tooltip:SetLineScript(y, 'OnMouseDown', mnkDurability.DoOnMouseDown, t[i].ItemLink)
        tooltip:SetLineScript(y, 'OnEnter', mnkDurability.DoOnMouseEnter, t[i].ItemLink)
        tooltip:SetLineScript(y, 'OnLeave', mnkDurability.DoOnMouseLeave, t[i].ItemLink)  
    end
    
    tooltip:AddLine(' ')
    tooltip:AddLine('Average gear level', '', '', math.floor(mnkDurability.GetAvgILevel()))
    
    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:SetFrameStrata('HIGH')
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkDurability.DoOnMouseDown(self, arg, button) 
    ChatEdit_InsertLink(arg)
end

function mnkDurability.DoOnMouseEnter(self, arg, button)
    if arg ~= nil then
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        GameTooltip:SetHyperlink(arg)
        GameTooltip:Show()
    end
end

function mnkDurability.DoOnMouseLeave(self, arg, button)
    GameTooltip:Hide()
end

function mnkDurability.AddInventory(SlotID, Text)
    local c, m = GetInventoryItemDurability(SlotID)
    
    if c == nil then
        c = 0
    end
    if m == nil then
        m = 0
    end
    
    t[SlotID] = {}
    t[SlotID].Text = Text
    t[SlotID].Current = c
    t[SlotID].Max = m
    t[SlotID].ItemID = GetInventoryItemID('player', SlotID)

    if t[SlotID].ItemID ~= nil then
        local link = GetInventoryItemLink('player', SlotID)
        local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(link)
        
        --when the addon is first loaded after logging in item information is not available.
        if (itemName == nil) or (itemRarity == nil) then
            itemName = 'n/a'
            itemRarity = 0
            itemTexture = 'Interface\\Icons\\Inv_chest_plate15'
        end
        -- GetDetailedItemLevelInfo() returning a different itemlevel to what is diplayed in the tooltip
        --t[SlotID].Level = GetDetailedItemLevelInfo(link) or 0
        t[SlotID].Level = mnkDurability.GetItemLevel(SlotID)
        t[SlotID].ItemLink = link
        _, _, _, color = GetItemQualityColor(itemRarity)
        --print(itemName..' '..itemLevel..' '..itemMinLevel);

        t[SlotID].ItemName = string.format('|T%s:16|t %s', itemTexture, '|c'..color..itemName)
    else
        t[SlotID].ItemName = '-'
    end
end

function mnkDurability.GetAvgILevel()
    local _, equipped = GetAverageItemLevel()
    return equipped
end

function mnkDurability.GetItemLevel(slotID)
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
    tip:SetInventoryItem("player", slotID)

    for l = 1, #tip.leftside do
        local t = tip.leftside[l]:GetText()
        if t and t:find('Item Level') then
            local _, i = string.find(t, 'Item Level%s%d')
            return string.sub(t, i) or 0
        end
    end
    return 0
end

function mnkDurability:GetText()
    t = {}
    local Total = 0
    local Current = 0
    local Lowest = 100
    local Percent = 100
    
    mnkDurability.AddInventory(1, 'Head')
    mnkDurability.AddInventory(2, 'Neck')
    mnkDurability.AddInventory(3, 'Shoulder')
    mnkDurability.AddInventory(15, 'Back')
    mnkDurability.AddInventory(5, 'Chest')
    mnkDurability.AddInventory(6, 'Waist')
    mnkDurability.AddInventory(7, 'Legs')
    mnkDurability.AddInventory(8, 'Feet')
    mnkDurability.AddInventory(9, 'Wrist')
    mnkDurability.AddInventory(10, 'Gloves')
    mnkDurability.AddInventory(11, 'Finger 1')
    mnkDurability.AddInventory(12, 'Finger 2')
    mnkDurability.AddInventory(13, 'Trinket 1')
    mnkDurability.AddInventory(14, 'Trinket 2')
    mnkDurability.AddInventory(16, 'Main Hand')
    mnkDurability.AddInventory(17, 'Off Hand')
    mnkDurability.AddInventory(18, 'Ranged')
    
    for i in pairs(t) do 
        if (t[i].Max ~= nil) and (t[i].Current ~= nil) then
            if (math.floor((t[i].Current / t[i].Max) * 100) < Lowest) then
                Lowest = math.floor((t[i].Current / t[i].Max) * 100)
            end
            
            Current = (Current + t[i].Current)
            Total = (Total + t[i].Max)
        end 
    end
    
    Percent = math.floor((Current / Total) * 100)

    if (Lowest ~= Percent) then
        return Lowest..'%/'..Percent..'%'..mnkLibs.Color(COLOR_WHITE) ..' i'..mnkLibs.Color(COLOR_GOLD)..math.floor(mnkDurability.GetAvgILevel())
    else
        return Percent..'%'..mnkLibs.Color(COLOR_WHITE)..' i'..mnkLibs.Color(COLOR_GOLD)..math.floor(mnkDurability.GetAvgILevel())
    end
end

mnkDurability:SetScript('OnEvent', mnkDurability.DoOnEvent)
mnkDurability:RegisterEvent('PLAYER_LOGIN')
mnkDurability:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkDurability:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
mnkDurability:RegisterEvent('UPDATE_INVENTORY_ALERTS')
mnkDurability:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
mnkDurability:RegisterEvent('ITEM_UPGRADE_MASTER_UPDATE')
mnkDurability:RegisterEvent('MERCHANT_SHOW')   
