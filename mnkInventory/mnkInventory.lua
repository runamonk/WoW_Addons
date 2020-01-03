mnkInventory = CreateFrame('Frame', 'mnkInventory')
mnkInventory.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local tInventoryItems = {}
local LibQTip = LibStub('LibQTip-1.0')
local StatusBarCellProvider, StatusBarCell = LibQTip:CreateCellProvider()
local AverageItemLevel = 0
local MAX_SLOTS = 19

mnkInventory:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkInventory:RegisterEvent('PLAYER_LOGIN')
mnkInventory:RegisterEvent('MERCHANT_SHOW')
mnkInventory:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
mnkInventory:RegisterEvent('PLAYER_ENTERING_WORLD') 
mnkInventory:RegisterEvent('ITEM_UPGRADE_MASTER_UPDATE')
mnkInventory:RegisterEvent('CONFIRM_XP_LOSS')
mnkInventory:RegisterEvent('PLAYER_DEAD')
mnkInventory:RegisterEvent('PLAYER_UNGHOST')
mnkInventory:RegisterEvent('UPDATE_INVENTORY_ALERTS')

function mnkInventory:CHAT_MSG_COMBAT_MISC_INFO()
    self:UpdateAll()
end

function mnkInventory:CONFIRM_XP_LOSS()
	self:UpdateAll()
end

function mnkInventory:ITEM_UPGRADE_MASTER_UPDATE()
	self:UpdateAlliLevels()
end

function mnkInventory:MERCHANT_SHOW(event, ...)
	local c = GetRepairAllCost()
    if GetMoney() >= c and c > 0 then
        RepairAllItems()
        local eventFrame = CreateFrame('Frame')
        eventFrame:SetScript('OnEvent', function() 
        	eventFrame:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
        	self:UpdateAll()
    	end)
		eventFrame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
        print('Gear repaired for: '..GetCoinTextureString(c))
    --guild repairs.
    --GetGuildBankWithdrawMoney()
    --RepairAllItems(1)
    end 
end

function mnkInventory:PLAYER_DEAD()
	self:UpdateAll()
end

function mnkInventory:PLAYER_ENTERING_WORLD(event, firstTime, reload)
	if not firstTime then
		self:UpdateAll()
	end
end

function mnkInventory:PLAYER_EQUIPMENT_CHANGED(event, slotid, hasCurrent)
	self:UpdateSlotInfo(slotid)
	self:CalculateAverageiLevel()
end

function mnkInventory:PLAYER_LOGIN()
	self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkInventory', {
	    icon = 'Interface\\Icons\\Inv_chest_plate15.blp', 
	    type = 'data source', 
	    OnEnter = function (parent) mnkInventory:OnEnter(parent) end, 
	    OnClick = function () mnkInventory.OnClick() end
        })
	self.LDB.label = 'Inventory'
	self:GetInventoryItems()
end

function mnkInventory:PLAYER_UNGHOST()
	self:UpdateAll()
end

function mnkInventory:UPDATE_INVENTORY_ALERTS()
	self:UpdateAll()
end

function mnkInventory:CalculateAverageiLevel()
    --AverageItemLevel = math.floor(select(2, GetAverageItemLevel()))
    --GetAverageItemLevel() is returning a cached calculation, so it's out of sync when I need it.
    local t = 0
    AverageItemLevel = 0

    for i=0, #tInventoryItems do
    	if tInventoryItems[i] and tInventoryItems[i].link then
    		if e ~= 'BODY' and e ~= 'TABARD' then
	    		local e = tInventoryItems[i].EquipLoc
	    		t = t + tInventoryItems[i].iLevel
	    		-- 2H and Ranged weapons are counted twice because they count as two slots.
	    		if e == '2HWEAPON' or e == 'RANGED' then
	    			t = t + tInventoryItems[i].iLevel
	    		end
	    	end
    	end
    end
    if t > 0 then
        AverageItemLevel = math.floor(t/16) -- divide by 16 (slots)
    end
end

function mnkInventory:GetInventoryItems()
	tInventoryItems = {}
	for slotid=1, MAX_SLOTS do
		self:UpdateSlotInfo(slotid)
	end
end

function mnkInventory:GetItemDurability(slotid)
	local c, m = GetInventoryItemDurability(slotid)
	--print('GetItemDurability ', slotid, ' ', #tInventoryItems[slotid], ' ', c, ' ', m)
	if tInventoryItems[slotid] and c and m then
		tInventoryItems[slotid].CurDur = c
		tInventoryItems[slotid].MaxDur = m
	end
end

function mnkInventory:GetItemLevel(slotid)
    -- GetDetailedItemLevelInfo() is not accurate.
	local link = GetInventoryItemLink('player', slotid)
	if link then
        local tip = CreateFrame("GameTooltip", "scanTip", UIParent, "GameTooltipTemplate")
        tip:ClearLines()
        tip:SetOwner(UIParent,"ANCHOR_NONE")
        tip:SetInventoryItem("player", slotid)
        for i=2, 3 do
            if _G["scanTipTextLeft"..i] then
                local l = _G["scanTipTextLeft"..i]:GetText() or ""
                if l and l:find('Item Level') then
                    local _, i = string.find(l, 'Item Level%s%d')
                    -- check for boosted levels ie Chromeie scenarios.
                    local _, x = string.find(l, " (", 1, true)
                    if x then
                        return string.sub(l, i, x-2) or '-'
                    end
                    return string.sub(l, i) or -'-'            
                end
            end 
        end
    end

    return 0
end

function mnkInventory:OnClick()
    ToggleCharacter('PaperDollFrame')
end

function mnkInventory:OnEnter(parent)
	local function OnMouseDown(self, arg, button) 
    	ChatEdit_InsertLink(arg)
	end

	local function OnMouseEnter(self, arg, button)
	    if arg ~= nil then
	        GameTooltip_SetDefaultAnchor(GameTooltip, self)
	        GameTooltip:SetHyperlink(arg)
	        GameTooltip:Show()
	    end
	end

	local function OnMouseLeave(self, arg, button)
	    GameTooltip:Hide()
	end

    local tooltip = LibQTip:Acquire('mnkInventoryTooltip', 5, 'LEFT', 'LEFT', 'RIGHT', 'RIGHT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    local ItemCount = 0
    local Total = 0
    local Current = 0

    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Slot', mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Durability', mnkLibs.Color(COLOR_GOLD)..'Level')
    
    for i,v in pairs(tInventoryItems) do
    	if v and v.link then 
	        if v.CurDur then
		        Current = (Current + v.CurDur)
		        Total = (Total + v.MaxDur)

	            if (v.MaxDur > 0) then
	                pct = math.floor((v.CurDur / v.MaxDur) * 100)..'%'
	            else
	                pct = '-'
	            end
	        else
	        	pct = '-'
	        end
           		
	        local y, x = tooltip:AddLine(v.EquipLoc, v.link, pct, v.iLevel)
	        tooltip:SetCell(y, 2, i, 1 , StatusBarCellProvider, 0)
	        tooltip:SetLineScript(y, 'OnMouseDown', OnMouseDown, v.link)
	        tooltip:SetLineScript(y, 'OnEnter', OnMouseEnter, v.link)
	        tooltip:SetLineScript(y, 'OnLeave', OnMouseLeave, v.link)
	    end  
    end   
    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:SetFrameStrata('HIGH')
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkInventory:SetText()
	local Percent, Current, Total = 0, 0, 0
    for i=1, #tInventoryItems do
        if tInventoryItems[i] and tInventoryItems[i].MaxDur and tInventoryItems[i].CurDur then
            Current = (Current + tInventoryItems[i].CurDur)
            Total = (Total + tInventoryItems[i].MaxDur)
        end 
    end

    if Current > 0 and Total > 0 then
        Percent = math.floor((Current / Total) * 100)
    else
        Percent = '0'
    end
    
    self:CalculateAverageiLevel()
	self.LDB.text =  Percent..'%'..mnkLibs.Color(COLOR_WHITE)..' i'..mnkLibs.Color(COLOR_GOLD)..AverageItemLevel
end

function mnkInventory:UpdateAll()
	for i=1, #tInventoryItems do
		self:GetItemDurability(i)
	end
	self:SetText()
end

function mnkInventory:UpdateAlliLevels()
	for i=1, #tInventoryItems do
		tInventoryItems[i].iLevel = self:GetItemLevel(i)
	end
	self:SetText()
end

function mnkInventory:UpdateSlotInfo(slotid)
	tInventoryItems[slotid] = {}
	local link = GetInventoryItemLink('player', slotid)

	if link then	
		local itemName, _, itemRarity, _, _, _, _, _,itemEquipLoc, itemIcon, _, _, _, _, _, _, _ = GetItemInfo(link) 

		-- item not cached yet, we'll wait and get it when it's ready.
		if not itemName then
	        local eventFrame = CreateFrame('Frame')
	        eventFrame:SetScript('OnEvent', function() 
	        	eventFrame:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
	        	self:UpdateSlotInfo(slotid)
	    	end)
			eventFrame:RegisterEvent('GET_ITEM_INFO_RECEIVED')
		else
			--print('UpdateSlotInfo() ', itemName, ' ', link, ' ', itemEquipLoc)
            local id = GetInventoryItemID("player", slotid)
            local isAzeritePowered = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link)

			tInventoryItems[slotid].link = link
			tInventoryItems[slotid].Name = itemName
			tInventoryItems[slotid].Rarity = itemRarity
			tInventoryItems[slotid].EquipLoc = self:TidyEquipLocName(itemEquipLoc) 
			tInventoryItems[slotid].Icon = itemIcon
			tInventoryItems[slotid].iLevel = self:GetItemLevel(slotid)
            tInventoryItems[slotid].id = id
            tInventoryItems[slotid].isAzeritePowered = isAzeritePowered
            if isAzeritePowered then
            
            end

			self:GetItemDurability(slotid)
		end
	end
	self:SetText()
end

function mnkInventory:TidyEquipLocName(itemEquipLoc)
 	--print(itemEquipLoc)
	if itemEquipLoc and itemEquipLoc:sub(1, 8) == 'INVTYPE_' then 
		return itemEquipLoc:sub(9, string.len(itemEquipLoc)) 
	else 
		return itemEquipLoc 
	end
end

function StatusBarCell:getContentHeight()
    return self.bar:GetHeight()
end

function StatusBarCell:InitializeCell()
    self.bar = CreateFrame('StatusBar',nil, self)
    self.bar:SetSize(350, 16)
    self.bar:SetPoint('CENTER')
    self.bar:SetMinMaxValues(0, 100)
    self.bar:SetPoint('LEFT', self, 'LEFT', 0, 0)
    self.bar:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    mnkLibs.setBackdrop(self.bar, nil, nil, 1, 1, 1, 1)

    self.fsName = self.bar:CreateFontString(nil, 'OVERLAY')
    self.fsName:SetPoint('LEFT', self.bar, 'LEFT', 5, 0)
    self.fsName:SetWidth(250)
	self.fsName:SetFontObject(_G.GameTooltipText)
    self.fsName:SetShadowColor(0, 0, 0)
    self.fsName:SetShadowOffset(1, -1)
    self.fsName:SetDrawLayer('OVERLAY')
	self.fsName:SetJustifyH('LEFT')
    self.fsName:SetTextColor(1, 1, 1)
    self.fsName:SetFontObject(mnkLibs.DefaultTooltipFont)

    self.fsTogo = self.bar:CreateFontString(nil, 'OVERLAY')
    self.fsTogo:SetPoint('RIGHT', self.bar, 'RIGHT', -5, 0)
    self.fsTogo:SetWidth(150)
	self.fsTogo:SetFontObject(_G.GameTooltipText)
    self.fsTogo:SetShadowColor(0, 0, 0)
    self.fsTogo:SetShadowOffset(1, -1)
    self.fsTogo:SetDrawLayer('OVERLAY')
	self.fsTogo:SetJustifyH('RIGHT')
    self.fsTogo:SetTextColor(1, 1, 1)
    self.fsTogo:SetFontObject(mnkLibs.DefaultTooltipFont)
end

function StatusBarCell:SetupCell(tooltip, data, justification, font, r, g, b)
    local azeriteItemLocation = nil
    local azeriteItem = nil
    local azItemXP, azItemTotalXP = 0
    if C_AzeriteItem.HasActiveAzeriteItem() then
        azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation); 
        azItemXP, azItemTotalXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
    end    
    local link = GetInventoryItemLink('player', data)
    local itemName, itemRarity, itemTexture
    local showBar = false
    if link then
        itemName, _, itemRarity, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(link)
        --print(link, ' ', itemName, ' ', itemTexture)
        if itemRarity then             
            _, _, _, color = GetItemQualityColor(itemRarity)
        else
            color = COLOR_WHITE
        end
        
        self.fsTogo:SetText()
        if azeriteItem and azeriteItem:GetItemName() == itemName then
            if not itemTexture then
                print(link, ' ', itemName)
            end
            itemName = string.format('|T%s|t %s', itemTexture..':16:16:0:0:64:64:4:60:4:60', '|c'..color..itemName..' [Level '..C_AzeriteItem.GetPowerLevel(azeriteItemLocation)..']')
            
            self.bar:SetValue(math.min((azItemXP/azItemTotalXP) * 100, 100))
            self.fsTogo:SetText(mnkLibs.formatNumToPercentage(azItemXP/azItemTotalXP)..' - '..(azItemTotalXP-azItemXP)..' to next level')
            showBar = true
        else
            itemName = string.format('|T%s|t %s', itemTexture..':16:16:0:0:64:64:4:60:4:60', '|c'..color..itemName)
            showBar = false
        end
    else
        itemName = '-'
        showBar = false
    end

    self.fsName:SetText(itemName)

    if showBar then
        self.bar:SetStatusBarColor(50,50,50, .2)
        self.bar:SetBackdropColor(0, 0, 0, 1)
    else
        self.bar:SetStatusBarColor(50,50,50, 0)
        self.bar:SetBackdropColor(0, 0, 0, 0)
    end

    return self.bar:GetWidth(), self.bar:GetHeight()
end

function StatusBarCell:ReleaseCell()

end
