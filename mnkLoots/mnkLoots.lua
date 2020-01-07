mnkLoots = CreateFrame('frame')
mnkLoots.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

mnkLoots:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkLoots:RegisterEvent('PLAYER_LOGIN')
mnkLoots:RegisterEvent('LOOT_OPENED')
mnkLoots:RegisterEvent('LOOT_CLOSED')
mnkLoots:RegisterEvent('CHAT_MSG_LOOT')

local LibQTip = LibStub('LibQTip-1.0')
local lootedItems = {}

SetCVar('autoLootDefault', 0)

LootFrame:Hide()
LootFrame.Show = mnkLibs.donothing()
LootFrame:UnregisterAllEvents()

local function AlreadyLooted(table, id)
    for i = 1, #table do
        if table[i].id == id then
            return i
        end
    end
    return false
end

function mnkLoots:CHAT_MSG_LOOT(event, arg1)
    if arg1 ~= nil then
        local LOOT_ITEM_PUSH_PATTERN = (LOOT_ITEM_PUSHED_SELF):gsub('%%s', '(.+)')
        local LOOT_ITEM_CREATED_SELF_PATTERN = LOOT_ITEM_CREATED_SELF:gsub('%%s', '(.+)')

        _, l = 1, arg1:match(LOOT_ITEM_PUSH_PATTERN)
        if not l then
            _, l = 1, arg1:match(LOOT_ITEM_CREATED_SELF_PATTERN)
        end

        if not l then return end
        local itemName, _, rarity, _, _, itemType, subType, _, _, itemIcon, _ = GetItemInfo(l)
        if rarity > 0 then
            -- delay the itemcount until the bags catch up with the server. really stupid.
            C_Timer.After(.5, function ()             
                local itemCount = GetItemCount(l)
                local _,_,_,color = GetItemQualityColor(rarity)
                           
                if itemCount > 1 then
                    itemCount = ' ['..itemCount..']'
                else
                    itemCount = ' '
                end

                local s = string.format('|T%s|t %s', itemIcon..':16:16:0:0:64:64:4:60:4:60', ' |c'..color..itemName..mnkLibs.Color(COLOR_WHITE)..itemCount)
                CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false) 
            end)
        end        
    end
end

function mnkLoots:LOOT_CLOSED()
    for i = 1, #lootedItems do
        --print('id: ', lootedItems[i].id, ' ', lootedItems[i].link)
        if lootedItems[i].link:find('battlepet') then
            local _, speciesID, _, rarity = (':'):split(lootedItems[i].link)
            local color = GetItemQualityColor(rarity)
            local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
            local s = string.format('|T%s|t %s', icon..':16:16:0:0:64:64:4:60:4:60', '|c'..color..name)
            CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
        else
            --local itemName, _, rarity, _, _, itemType, subType, _, _, itemIcon, _ = GetItemInfo(lootedItems[i].link)
            if lootedItems[i].rarity and lootedItems[i].rarity > 0 then
                local _,_,_,color = GetItemQualityColor(lootedItems[i].rarity)
                local itemCount = lootedItems[i].count
                if itemCount > 1 then
                    itemCount = ' ['..itemCount..']'
                else
                    itemCount = ' '
                end
                local s = string.format('|T%s|t %s', lootedItems[i].icon..':16:16:0:0:64:64:4:60:4:60', ' |c'..color..lootedItems[i].name..mnkLibs.Color(COLOR_WHITE)..itemCount)
                CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
            end
        end
     
    end
    lootedItems = {}
end

function mnkLoots:LOOT_OPENED()
    -- don't run with auto loot enabled, it will conflict with blizzard code 
    -- to auto loot and sometimes cause an instant disconnect.
    if GetCVar('autoLootDefault') == 1 then return end
    lootedItems = {}

    for i = GetNumLootItems(), 1, -1 do
        local link = GetLootSlotLink(i)
        local itemicon, itemname, itemcount, _, itemrarity, _, _, _, _ = GetLootSlotInfo(i)
        
        if link then  	
           	if not itemcount then itemcount = 0 end
            local id = select(1, GetItemInfoInstant(link))
            --print(id, ' ', link, ' ', itemicon, ' ', itemname, ' ', itemcount, ' ', itemrarity)

            if id then
	            local idx = AlreadyLooted(lootedItems, id) 
	            if not idx then
	                local c = #lootedItems+1
	                lootedItems[c] = {}
	                lootedItems[c].name = itemname
	                lootedItems[c].id = id
	                lootedItems[c].link = link
	                lootedItems[c].count = (itemcount or 1) + (GetItemCount(link) or 1)
	                lootedItems[c].rarity = itemrarity
	                lootedItems[c].icon = itemicon
	            else
	           		lootedItems[idx].count = (lootedItems[idx].count or 1) + (itemcount or 1)
            	end
	        end   
        end
        LootSlot(i)
        ConfirmLootSlot(i)
    end
end

function mnkLoots:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkLoots', {
        icon = 'Interface\\Icons\\ability_hunter_beastcall02.blp', 
        type = 'data source', 
        OnEnter = function (parent) self:OnEnter(parent) end, 
        OnClick = nil
        })
    self.LDB.label = 'Loots'
    self.LDB.text = ' Loots'
end

function mnkLoots:OnEnter(parent)
    local tooltip = LibQTip:Acquire('mnkLootsTooltip', 1, 'LEFT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name')
 
    -- local sort_func = function(a, b) return a.name < b.name end
    -- table.sort(t, sort_func)

    -- for i=1, #t do
    --     tooltip:AddLine(t[i].name..' ('..t[i].difficulty..')', t[i].progress, SecondsToTime(t[i].reset))
    -- end    

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:SetFrameStrata('HIGH')
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    -- tooltip:SetBackdrop(GameTooltip:GetBackdrop())
    -- tooltip:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
    -- tooltip:SetBackdropColor(GameTooltip:GetBackdropColor())
    -- tooltip:SetScale(GameTooltip:GetScale())
    mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    tooltip:SetBackdropColor(0, 0, 0, 1)    
    tooltip:EnableMouse(true)
    tooltip:Show()
end


