mnkLoots = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
mnkLoots.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkLoots_LootHistory = {}

mnkLoots:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkLoots:RegisterEvent('PLAYER_LOGIN')
mnkLoots:RegisterEvent('LOOT_OPENED')
--mnkLoots:RegisterEvent('LOOT_CLOSED')
mnkLoots:RegisterEvent('CHAT_MSG_LOOT')

local LibQTip = LibStub('LibQTip-1.0')
local lootedItems = {}
local MAX_HISTORY_ITEMS = 30

LootFrame:Hide()
LootFrame.Show = mnkLibs.donothing()
LootFrame:UnregisterAllEvents()

function mnkLoots:AddItem(itemLink, slotid, count)

    local function inLootedItemsTable(table, id)
        for i = 1, #table do
            if table[i].id == id then
                return i
            end
        end
        return false
    end

    --print('AddItem:', itemLink)
    local _ = nil
    local itemId, itemIcon, itemName, itemCount, itemRarity, itemClassID, itemSubClassID = nil

    if slotid then
        itemIcon, itemName, itemCount, _, itemRarity, _, _, _, _ = GetLootSlotInfo(slotid)
    else
        itemName, _, itemRarity, _, _, _, _, _, _, itemIcon, _, itemClassID, itemSubClassID, _, _, _, _ = GetItemInfo(itemLink)        
    end

    itemId = select(1, GetItemInfoInstant(itemLink))

    if itemId and itemRarity > 0 then
        --print(itemId, ' ', itemLink, ' ', itemIcon, ' ', itemName, ' ', itemCount, ' ', itemRarity)
        --print('AddItem',count,itemCount)
        local idx = inLootedItemsTable(lootedItems, itemId) 
        if not idx then
            local c = #lootedItems+1
            lootedItems[c] = {}
            lootedItems[c].name = itemName
            lootedItems[c].id = itemId
            lootedItems[c].link = itemLink
            lootedItems[c].count = count--(count or 0) + GetItemCount(itemLink)
            lootedItems[c].rarity = itemRarity
            lootedItems[c].icon = itemIcon
            if itemClassID == LE_ITEM_CLASS_MISCELLANEOUS and (itemSubClassID == LE_ITEM_MISCELLANEOUS_COMPANION_PET or itemSubClassID == LE_ITEM_MISCELLANEOUS_MOUNT) then
                lootedItems[c].highlight = true
            else
                lootedItems[c].highlight = false
            end
            self:AddItemToHistory(lootedItems[c])
        else
            lootedItems[idx].count = (lootedItems[idx].count or 1) + (itemCount or 1)
            self:AddItemToHistory(lootedItems[idx])
        end
    end
end

function mnkLoots:AddItemToHistory(item)
    local function inLootHistoryTable(item)
        for i=1, #mnkLoots_LootHistory do
            if mnkLoots_LootHistory[i] and mnkLoots_LootHistory[i].link == item.link then
                --print('found:', item.link)
                return i
            end
        end
        return 0        
    end

    if item.rarity < 2 then return end

    local r = inLootHistoryTable(item)
    if r == 0 then
        r = #mnkLoots_LootHistory+1
        mnkLoots_LootHistory[r] = item
        mnkLoots_LootHistory[r].lootcount = 1
        mnkLoots_LootHistory[r].zone = GetZoneText()
        mnkLoots_LootHistory[r].timestamp = date("%m/%d/%y %H:%M:%S")
    else
        mnkLoots_LootHistory[r].lootcount = mnkLoots_LootHistory[r].lootcount + 1
        mnkLoots_LootHistory[r].timestamp = date("%m/%d/%y %H:%M:%S")
    end
end

function mnkLoots:CHAT_MSG_LOOT(event, arg1)

    local function getItemAndCount(str, format)
        local pattern = ""     
        pattern = format:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", function(c) return "%"..c end)
        pattern = pattern:gsub("%%%%([sd])", {
                                 ["s"] = "(.-)",
                                 ["d"] = "(%d+)",
                               })
        return str:match(pattern)
    end
    if arg1 ~= nil then
        local l = nil
        local c = nil     
        l, c = getItemAndCount(arg1, LOOT_ITEM_SELF_MULTIPLE) 
        if not l then
            l, c = getItemAndCount(arg1, LOOT_ITEM_SELF)
        end
        if not l then
            l, c = getItemAndCount(arg1, LOOT_ITEM_PUSHED_SELF_MULTIPLE)
        end
        if not l then
            l, _ = getItemAndCount(arg1, LOOT_ITEM_PUSHED_SELF)
        end
        if not l then
            l, c = getItemAndCount(arg1, LOOT_ITEM_CREATED_SELF_MULTIPLE)
        end        
        if not l then
            l, _ = getItemAndCount(arg1, LOOT_ITEM_CREATED_SELF)
        end
        if not l then
            l, _ = getItemAndCount(arg1, LOOT_ROLL_YOU_WON)
        end
        --print(l, c)
        if l then
            self:AddItem(l)
            self:ShowPhatLoots()
        end      
    end
end

function mnkLoots:OnClick(parent, button)
    if button == 'RightButton' and IsAltKeyDown() then
        mnkLoots.tooltip:Hide()
        mnkLoots_LootHistory = {}
        print('Loot history cleared')
    end
end

function mnkLoots:OnEnter(parent)
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
    local t = {}
    local tooltip = LibQTip:Acquire('mnkLootsTooltip', 3, 'LEFT','LEFT','RIGHT')
    self.tooltip = tooltip
    mnkLoots.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip.step = 50 
    
    tooltip:Clear()
    
    mnkLibs.copyTable(mnkLoots_LootHistory, t)
    --add index and then sort descending so newest at top.
    for i=1, #t do t[i].index = i end
    table.sort(t, function(a, b) return a.index > b.index end)

    if #t == 0 then
        tooltip:AddLine('No loot history.')
    else
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Zone')
        local c = 0
        for i=1, #t do
            if  t[i] then
 
                if t[i].lootcount > 1 then
                    s = string.format('|T%s|t %s', t[i].icon..':16:16:0:0:64:64:4:60:4:60', t[i].link)..' x '..t[i].lootcount
                else
                    s = string.format('|T%s|t %s', t[i].icon..':16:16:0:0:64:64:4:60:4:60', t[i].link)
                end

                if t[i].highlight then
                    s = mnkLibs.Color(COLOR_RED)..'>'..s..mnkLibs.Color(COLOR_RED)..'<'
                end

                local y, _ = tooltip:AddLine(s, t[i].zone)
                tooltip:SetLineScript(y, 'OnEnter', OnMouseEnter, t[i].link)
                tooltip:SetLineScript(y, 'OnLeave', OnMouseLeave, nil)
            end
        end
    end    

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:UpdateScrolling(400)
    tooltip:SetFrameStrata('HIGH')
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    tooltip:SetBackdropColor(0, 0, 0, 1)    
    tooltip:EnableMouse(true)
    tooltip:Show()
end

function mnkLoots:LOOT_OPENED()
    local function GetNumFreeSlots()
        local free = 0
        for i = 0, 4 do
            free = free + GetContainerNumFreeSlots(i)
        end
        return free
    end

    -- don't run with auto loot enabled, it will conflict with blizzard code 
    -- to auto loot and sometimes cause an instant disconnect.
    if GetCVar('autoLootDefault') == 1 then return end
    lootedItems = {}

    for i = GetNumLootItems(), 1, -1 do
        local f = GetNumFreeSlots()
        if f == 0 then
            CombatText_AddMessage(mnkLibs.Color(COLOR_RED)..'INVENTORY IS FULL!', CombatText_StandardScroll, 255, 255, 255, nil, false) 
            print('INVENTORY IS FULL.')
            CloseLoot()
            break
        end

        -- local link = GetLootSlotLink(i)
        -- if link then
        --     self:AddItem(link,i)
        -- end
        LootSlot(i)
        ConfirmLootSlot(i)
    end
end

function mnkLoots:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkLoots', {
        icon = 'Interface\\Icons\\Inv_box_04.blp', 
        type = 'data source', 
        OnEnter = function (parent) self:OnEnter(parent) end, 
        OnClick = function (parent, button) self:OnClick(parent, button) end
        })
    self.LDB.label = 'Loots'
    self.LDB.text = ' Loots'
    SetCVar('autoLootDefault', 0)
end

function mnkLoots:ShowPhatLoots()
    local function doit()
        for i = 1, #lootedItems do
            if i > #lootedItems then return end

            if lootedItems[i].link:find('battlepet') then
                local _, speciesID, _, rarity = (':'):split(lootedItems[i].link)
                local color = GetItemQualityColor(rarity)
                local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
                local s = string.format('|T%s|t %s', icon..':16:16:0:0:64:64:4:60:4:60', '|c'..color..name)
                CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
            else
                --local itemName, _, rarity, _, _, itemType, subType, _, _, itemIcon, _ = GetItemInfo(lootedItems[i].link)
                --print(lootedItems[i].name, ' ', lootedItems[i].rarity )
                if lootedItems[i].rarity and lootedItems[i].rarity > 0 then
                    local _,_,_,color = GetItemQualityColor(lootedItems[i].rarity)
                    local itemCount = GetItemCount(lootedItems[i].link)--lootedItems[i].count
                    if itemCount > 1 then
                        itemCount = ' ['..itemCount..']'
                    else
                        itemCount = ' '
                    end

                    if lootedItems[i].highlight then
                        color = mnkLibs.Color(COLOR_RED)
                    else
                        color = ' |c'..color
                    end

                    local s = string.format('|T%s|t %s', lootedItems[i].icon..':16:16:0:0:64:64:4:60:4:60', color..lootedItems[i].name..mnkLibs.Color(COLOR_WHITE)..itemCount)
                    --print("ShowPhatLoots:", s, itemCount)
                    CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
                end
            end
            table.remove(lootedItems, i)
        end

        lootedItems = {}

        if #mnkLoots_LootHistory > MAX_HISTORY_ITEMS then
            local c = #mnkLoots_LootHistory-MAX_HISTORY_ITEMS
            --print('HistoryCount: ', #mnkLoots_LootHistory, ' to remove: ', c)
            for i = 1, #mnkLoots_LootHistory do
                if i > c then break end
                mnkLoots_LootHistory[i] = nil
            end

            -- compress the table back down.
            for i = #mnkLoots_LootHistory, 1, -1 do
                if not mnkLoots_LootHistory[i] then
                    table.remove(mnkLoots_LootHistory, i)
                end
            end         
            --print('Count:', #mnkLoots_LootHistory)
        end  
    end
    -- this is a terrible way to handle this but I cannot think of a better way to actually get all the items looted that is accurate
    -- and shows all the items looted, created etc. Since the chat message comes in before the actual bag is updated
    -- don't actually get the itemcount until after a forced delay.
    C_Timer.After(.5, function() doit() end) 
end
