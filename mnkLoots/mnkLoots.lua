mnkLoots = CreateFrame('frame')
mnkLoots:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkLoots:RegisterEvent('LOOT_OPENED')
mnkLoots:RegisterEvent('LOOT_CLOSED')

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
            else
            	print(link, 'NO ID')
	        end   
        end
        LootSlot(i)
        ConfirmLootSlot(i)
    end
end


