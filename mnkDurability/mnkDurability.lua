mnkDurability = CreateFrame('Frame')
mnkDurability.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')
local t = {}

function mnkDurability:DoOnEvent(event, arg1)
    --print(event, ' ', arg1)
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
    end
    self.LDB.text = self.GetText()
end

function mnkDurability.DoOnClick(self)
    ToggleCharacter('PaperDollFrame')
end

function mnkDurability.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkDurabilityTooltip', 5, 'LEFT', 'LEFT', 'RIGHT', 'RIGHT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    local ItemCount = 0
    local Total = 0
    local Current = 0
    
    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Slot', mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Durability', mnkLibs.Color(COLOR_GOLD)..'Level')
    
    for i,v in pairs(t) do 
        Current = (Current + v.Current)
        Total = (Total + v.Max)
        if (v.ItemID == nil) then
            pct = '-'
        else
            if (v.Max > 0) then
                pct = math.floor((v.Current / v.Max) * 100)..'%'
            else
                pct = '-'
            end
        end
       
        local link = GetInventoryItemLink('player', i)
        local itemName, itemRarity, itemTexture, itemLevel

        if link then
            itemName, _, itemRarity, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(link)            
            _, _, _, color = GetItemQualityColor(itemRarity)
            itemLevel = mnkDurability.GetItemLevel(i)
            itemName = string.format('|T%s:16|t %s', itemTexture, '|c'..color..itemName)
        else
            itemLevel, itemName = '-'
        end

        local y, x = tooltip:AddLine(v.Text, itemName, pct, itemLevel)
        tooltip:SetLineScript(y, 'OnMouseDown', mnkDurability.DoOnMouseDown, link)
        tooltip:SetLineScript(y, 'OnEnter', mnkDurability.DoOnMouseEnter, link)
        tooltip:SetLineScript(y, 'OnLeave', mnkDurability.DoOnMouseLeave, link)  
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

function mnkDurability.AddInventory(slotName)
    local slotID, _ = GetInventorySlotInfo(slotName)
    local c, m = GetInventoryItemDurability(slotID)

    if c == nil then
        c = 0
    end
    if m == nil then
        m = 0
    end
    
    t[slotID] = {}
    t[slotID].Text = slotName:gsub('Slot','')
    t[slotID].Current = c
    t[slotID].Max = m
    t[slotID].ItemID = GetInventoryItemID('player', slotID)
end

function mnkDurability.GetAvgILevel()
    local _, equipped = GetAverageItemLevel()
    return equipped
end

function mnkDurability.GetItemLevel(slotID)
    local tip = CreateFrame("GameTooltip", "scanTip", UIParent, "GameTooltipTemplate")
    tip:ClearLines()
    tip:SetOwner(UIParent,"ANCHOR_NONE")
    tip:SetInventoryItem("player", slotID)
    for i=1, 5 do
        local l = _G["scanTipTextLeft"..i]:GetText()
        if l and l:find('Item Level') then
            local _, i = string.find(l, 'Item Level%s%d')
            -- check for boosted levels ie Chromeie scenarios.
            local _, x = string.find(l, " (", 1, true)
            --print(t, ' ', x)
            if x then
                return string.sub(l, i, x-2) or nil
            end
            return string.sub(l, i) or nil            
        end 
    end

    return false
end

function mnkDurability:GetText()
    t = {}
    local Total = 0
    local Current = 0
    local Lowest = 100
    local Percent = 100
    
    mnkDurability.AddInventory('HeadSlot')
    mnkDurability.AddInventory('NeckSlot')
    mnkDurability.AddInventory('ShoulderSlot')
    mnkDurability.AddInventory('BackSlot')
    mnkDurability.AddInventory('ChestSlot')
    mnkDurability.AddInventory('WaistSlot')
    mnkDurability.AddInventory('LegsSlot')
    mnkDurability.AddInventory('FeetSlot')
    mnkDurability.AddInventory('WristSlot')
    mnkDurability.AddInventory('HandsSlot')
    mnkDurability.AddInventory('Finger0Slot')
    mnkDurability.AddInventory('Finger1Slot')
    mnkDurability.AddInventory('Trinket0Slot')
    mnkDurability.AddInventory('Trinket1Slot')
    mnkDurability.AddInventory('MainHandSlot')
    mnkDurability.AddInventory('SecondaryHandSlot')
    
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
mnkDurability:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
mnkDurability:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
mnkDurability:RegisterEvent('UPDATE_INVENTORY_ALERTS')
mnkDurability:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
mnkDurability:RegisterEvent('ITEM_UPGRADE_MASTER_UPDATE')
mnkDurability:RegisterEvent('MERCHANT_SHOW')   
