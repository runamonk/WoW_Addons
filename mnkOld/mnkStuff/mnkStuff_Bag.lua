
local mnkStuff_Bag = CreateFrame('Frame')

local bag_TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local bag_BACKDROP = {bgFile = bag_TEXTURE, edgeFile = bag_TEXTURE, edgeSize = 1}
local backpack = nil
local BUTTON_SIZE = 18

ToggleBag = function(id)
    if id < 5 and id > -1 then
        mnkStuff_Bag.Toggle(0)
    end
end

ToggleBackpack = function() mnkStuff_Bag.Toggle(0); end

OpenAllBags = function() mnkStuff_Bag.Toggle(1); end

OpenBackpack = function() mnkStuff_Bag.Toggle(1); end

CloseAllBags = function() mnkStuff_Bag.Toggle(2); end

CloseBackpack = function() mnkStuff_Bag.Toggle(2); end

ToggleAllBags = function() mnkStuff_Bag.Toggle(0); end

function mnkStuff_Bag.AddPocketTab(pocket, idx)
    local offset = 0

    if idx == 1 then
        offset = 22 / -1
    else
        offset = 22 * idx /- 1
    end

    pocket.button = CreateFrame('Button', 'button'..pocket.name, backpack)
    pocket.button.pocket = pocket
    pocket.button:SetScript('OnClick', function(self, button) mnkStuff_Bag.OnClickPocket(self, button) end)

    pocket.button:RegisterForClicks('AnyUp')
    pocket.button:SetPoint('RIGHT', backpack, 'LEFT', 0, 0)
    pocket.button:SetPoint('TOP', backpack, 'TOP', 0, offset)
    pocket.button:SetSize(140, 20)

    pocket.button:SetBackdrop(bag_BACKDROP)
    pocket.button:SetBackdropColor(0, 0, 0, 1)
    pocket.button:SetBackdropBorderColor(0, 0, 0, 1)
    pocket.button.font = pocket.button:CreateFontString(nil, 'OVERLAY', 'OswaldRight')
    pocket.button.font:SetPoint('RIGHT', pocket.button, 'RIGHT', -10, 0)
    pocket.button.font:SetPoint('TOP', pocket.button, 'TOP', 0, -1)
    pocket.button.font:SetWordWrap(false)
    pocket.button.font:SetText(pocket.name)
    pocket.button:Show()
end

function mnkStuff_Bag.AddItemToBackpack(itemlink, itemcount, bagnumber, slotnumber)
    local itemName, _, itemRarity, _, _, itemType, itemSubType, itemStackCount, _, itemTexture, _ = GetItemInfo(itemlink)
    local _, _, _, itemColor = GetItemQualityColor(itemRarity or 1)
    local itemNameColored = string.format('%s', '|c'..itemColor..itemName)
    local pocket = mnkStuff_Bag.GetPocket(itemlink)
    local i = mnkStuff_Bag.getIndex(pocket.stuff, itemName)
    if i == -1 then
        i = (#pocket.stuff + 1)
        pocket.stuff[i] = {}
        pocket.stuff[i].name = itemName
        pocket.stuff[i].bagnumber = bagnumber
        pocket.stuff[i].slotnumber = slotnumber
        pocket.stuff[i].itemLink = itemlink
        pocket.stuff[i].itemCount = itemcount
        pocket.stuff[i].itemTexture = itemTexture
        pocket.stuff[i].itemStackCount = itemStackCount
        pocket.stuff[i].itemNameColored = itemNameColored
        pocket.stuff[i].itemicon = CreateFrame('Button', itemName, backpack.content)
        pocket.stuff[i].itemicon.item = pocket.stuff[i]
        pocket.stuff[i].itemicon:SetNormalTexture(itemTexture)
        pocket.stuff[i].itemicon:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        pocket.stuff[i].itemicon:SetFrameStrata('HIGH')
        pocket.stuff[i].itemicon:SetAttribute('type', 'item')
        pocket.stuff[i].itemicon:SetAttribute('item', itemName)
        pocket.stuff[i].itemicon:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_CURSOR'); GameTooltip:ClearLines(); GameTooltip:SetHyperlink(itemlink); GameTooltip:Show(); end)
        pocket.stuff[i].itemicon:SetScript('OnLeave', function(self) GameTooltip:Hide(); end)
        pocket.stuff[i].itemicon:SetScript('OnClick', function(self, button) mnkStuff_Bag.OnClickItem(self, button) end)
        pocket.stuff[i].itemicon:RegisterForClicks('AnyUp')

        pocket.stuff[i].itemicon.itemleveltext = pocket.stuff[i].itemicon:CreateFontString(nil, 'OVERLAY', 'apLeft')
        pocket.stuff[i].itemicon.itemleveltext:SetPoint('BOTTOMLEFT', pocket.stuff[i].itemicon, 'BOTTOMRIGHT', 5, 1)
        pocket.stuff[i].itemicon.itemleveltext:SetWordWrap(false)
        pocket.stuff[i].itemicon.itemleveltext:SetText(Color(COLOR_YELLOW) .. 'i'..GetDetailedItemLevelInfo(itemlink) or nil)
        
        pocket.stuff[i].itemicon.itemtext = pocket.stuff[i].itemicon:CreateFontString(nil, 'OVERLAY', 'apLeft')
        pocket.stuff[i].itemicon.itemtext:SetPoint('BOTTOMLEFT', pocket.stuff[i].itemicon, 'BOTTOMRIGHT', 40, 1)
        pocket.stuff[i].itemicon.itemtext:SetWordWrap(false)
        pocket.stuff[i].itemicon.itemtext:SetText(itemNameColored)

        pocket.stuff[i].itemicon.itemcountext = pocket.stuff[i].itemicon:CreateFontString(nil, 'OVERLAY', 'apLeft')
        pocket.stuff[i].itemicon.itemcountext:SetPoint('LEFT', pocket.stuff[i].itemicon.itemtext, 'RIGHT', 3, 1)
        pocket.stuff[i].itemicon.itemcountext:SetWordWrap(false)
        pocket.stuff[i].itemicon.itemcountext:SetText('')

        local sort_func = function(a, b) return a.name < b.name end
        table.sort(pocket.stuff, sort_func)
    else
        pocket.stuff[i].itemCount = (pocket.stuff[i].itemCount + itemcount)
    end 
end

function mnkStuff_Bag.ClosePocket(pocket)
    --print('ClosePocket: '..pocket.name)
    for b = 1, #pocket.stuff do
        pocket.stuff[b].itemicon:Hide()
    end 
end

function mnkStuff_Bag.CreateBackpack()
    if backpack ~= nil then return end
    backpack = CreateFrame('Frame', 'backpack', UIParent)
    backpack.pockets = {}
    backpack.openpocket = nil
    backpack:EnableMouse(true)
    backpack:SetMovable(true)
    backpack:RegisterForDrag('LeftButton')
    backpack:SetScript('OnDragStart', mnkStuff_Bag.StartDrag)
    backpack:SetScript('OnDragStop', mnkStuff_Bag.StopDrag)
    backpack:SetBackdrop(bag_BACKDROP)
    backpack:SetBackdropColor(0, 0, 0, 1)
    backpack:SetBackdropBorderColor(0, 0.5, 0, 1)
    backpack:SetPoint('BOTTOMLEFT', mnkStuffDB.backpack_xpos, mnkStuffDB.backpack_ypos)
    backpack:SetFrameStrata('HIGH')
    backpack.scrollframe = CreateFrame('ScrollFrame', nil, backpack)
    backpack.scrollframe:SetPoint('TOPLEFT', 2, -4)
    backpack.scrollframe:SetPoint('BOTTOMRIGHT', -2, 4)

    backpack.slider = CreateFrame('Slider', nil, backpack.scrollframe)
    backpack.slider:SetPoint('TOPLEFT', backpack, 'TOPRIGHT', -10, -1)
    backpack.slider:SetPoint('BOTTOMLEFT', backpack, 'BOTTOMRIGHT', -10, 1)
    backpack.slider:SetMinMaxValues(0, 1)
    backpack.slider:SetValueStep(1)
    backpack.slider:SetWidth(10)
    backpack.slider:SetObeyStepOnDrag(true)
    backpack.slider:SetScript('OnValueChanged', function (self) self:GetParent():SetVerticalScroll(self:GetValue()) end)
    backpack.slider.thumb = backpack.slider:CreateTexture(nil, 'OVERLAY')
    backpack.slider.thumb:SetTexture('')
    backpack.slider.thumb:SetColorTexture(0, 0, 0, 1)
    backpack.slider.thumb:SetSize(6, 50)
    backpack.slider:SetThumbTexture(backpack.slider.thumb)
    backpack.slider:SetBackdrop(bag_BACKDROP)
    backpack.slider:SetBackdropColor(0, 0.4, 0, 1)
    backpack.slider:SetBackdropBorderColor(0, 0.5, 0, 1)
    backpack.content = CreateFrame('Frame', nil, backpack.scrollframe)

    backpack:SetScript('OnMouseWheel', 
        function(self, delta)
            if delta == -1 then
                backpack.slider:SetValue(backpack.slider:GetValue() + BUTTON_SIZE)
            else
                backpack.slider:SetValue(backpack.slider:GetValue() - BUTTON_SIZE)
            end
        end)

        backpack.scrollframe:SetScrollChild(backpack.content)
        backpack:SetSize(400, 500)
        backpack.content:SetSize(backpack.scrollframe:GetSize())
        mnkStuff_Bag.HideBackpack()
    end

    function mnkStuff_Bag.CreateBackpackBags()
        if backpack.bagsframe then return end

        backpack.bagsframe = CreateFrame('Frame', 'backpack.bagsframe', backpack)
        backpack.bagsframe.bags = {}
        backpack.bagsframe:SetBackdrop(bag_BACKDROP)
        backpack.bagsframe:SetBackdropColor(0, 0, 0, 1)
        backpack.bagsframe:SetBackdropBorderColor(0, 0.5, 0, 1)
        backpack.bagsframe:SetPoint('LEFT', backpack, 'LEFT', 0, 0)
        backpack.bagsframe:SetPoint('RIGHT', backpack, 'RIGHT', 0, 0)
        backpack.bagsframe:SetPoint('BOTTOM', backpack, 'TOP', 0, 0)
        backpack.bagsframe:SetHeight(36)

        --skip the default bag (0)
        for b = 1, NUM_BAG_SLOTS do
            backpack.bagsframe.bags[b] = {}
            backpack.bagsframe.bags[b].bagname = GetBagName(b)
            backpack.bagsframe.bags[b].button = CreateFrame('Button', 'bag'..b, backpack.bagsframe)
            backpack.bagsframe.bags[b].button:SetBackdrop(bag_BACKDROP)
            backpack.bagsframe.bags[b].button:SetBackdropColor(0.2, 0.2, 0.2, .5)
            backpack.bagsframe.bags[b].button:SetBackdropBorderColor(0, 0.5, 0, 1)
            
            local itemName, itemLink, itemTexture = nil

            if backpack.bagsframe.bags[b].bagname == nil then
                backpack.bagsframe.bags[b].button.itemname = 'Empty'
                backpack.bagsframe.bags[b].button:SetNormalTexture('')
            else
                itemName, itemLink, _, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(backpack.bagsframe.bags[b].bagname)
                backpack.bagsframe.bags[b].button.itemname = itemName
                backpack.bagsframe.bags[b].button.itemlink = itemLink
                backpack.bagsframe.bags[b].button.itemtexture = itemTexture
                backpack.bagsframe.bags[b].button:SetNormalTexture(itemTexture)
                --backpack.bagsframe.bags[b].button:GetNormalTexture():SetTexCoord(0.1, 0.1, 0.1, 0.1);
            end
            if itemLink then
                backpack.bagsframe.bags[b].button:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_CURSOR'); GameTooltip:ClearLines(); GameTooltip:SetHyperlink(itemLink); GameTooltip:Show(); end)
                backpack.bagsframe.bags[b].button:SetScript('OnLeave', function(self) GameTooltip:Hide(); end)
            else
                backpack.bagsframe.bags[b].button:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_CURSOR'); GameTooltip:ClearLines(); GameTooltip:SetText('Empty'); GameTooltip:Show(); end)
                backpack.bagsframe.bags[b].button:SetScript('OnLeave', function(self) GameTooltip:Hide(); end)
            end
            backpack.bagsframe.bags[b].button:SetScript('OnClick', function(self, button) mnkStuff_Bag.Bag_OnClickItem(self, button) end)
            
            if (b) > 1 then
                backpack.bagsframe.bags[b].button:SetPoint('LEFT', backpack.bagsframe.bags[b - 1].button, 'RIGHT', 5, 0)
            else
                backpack.bagsframe.bags[b].button:SetPoint('LEFT', backpack.bagsframe, 'LEFT', 5, 0)
            end

            backpack.bagsframe.bags[b].button:SetSize(26, 26)
            backpack.bagsframe.bags[b].button:Show()
        end
        backpack.bagsframe:Show()
    end

    function mnkStuff_Bag.Bag_OnClickItem(self, button)
        print('click '..button)
    end

    function mnkStuff_Bag:DoOnEvent(event, arg1, arg2)
        --print(event)
        if event == 'PLAYER_ENTERING_WORLD' then
            
            
        elseif event == 'BAG_UPDATE_DELAYED' then
            mnkStuff_Bag:RegisterEvent('BAG_UPDATE')
            mnkStuff_Bag.CreateBackpack()
        elseif event == 'BAG_UPDATE' then
            
        elseif event == 'MERCHANT_SHOW' then
            mnkStuff_Bag.OnSellJunk()
        end
    end

    function mnkStuff_Bag.FillBackpack()

        local b = 0
        -- loop through all bags and cache everything into categorized pockets.  
        for b = 0, NUM_BAG_SLOTS do
            for s = 1, GetContainerNumSlots(b) do
                local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(b, s)
                if itemLink then
                    mnkStuff_Bag.AddItemToBackpack(itemLink, itemCount, b, s)
                end 
            end
        end
        local sort_func = function(a, b) return a.name < b.name end
        table.sort(backpack.pockets, sort_func)
    end

    function mnkStuff_Bag.getIndex(table, item)
        local index = 1
        while table[index] do
            if (item == table[index].name) then
                return index
            end
            index = index + 1
        end
        return - 1
    end

    function mnkStuff_Bag.GetPocket(itemlink)
        local itemName, _, itemRarity, _, _, itemType, _, _, _, _, _ = GetItemInfo(itemlink)
        local pocketname = itemType

        if itemRarity == LE_ITEM_QUALITY_POOR then
            pocketname = 'Junk'
        elseif string.find(itemName, 'Hearthstone') or string.find(itemName, 'Flight Master''s Whistle') then
            pocketname = 'Teleporters'
        end


        local p = mnkStuff_Bag.getIndex(backpack.pockets, pocketname)

        if p == -1 then
            p = (#backpack.pockets + 1)
            backpack.pockets[p] = {}
            backpack.pockets[p].name = pocketname
            backpack.pockets[p].stuff = {}
        end
        return backpack.pockets[p]
    end

    function mnkStuff_Bag.HideBackpack()
        backpack:Hide()
    end

    function mnkStuff_Bag.OpenPocket(pocket)
        if backpack.openpocket ~= nil then
            mnkStuff_Bag.ClosePocket(backpack.openpocket)
        end
        backpack.openpocket = pocket
        backpack.slider:SetValue(0)
        
        local TOTAL_BUTTON_PX = ((BUTTON_SIZE + 4) * #pocket.stuff)
        local TOTAL_VIS_PX = (backpack.content:GetHeight())

        if TOTAL_BUTTON_PX < TOTAL_VIS_PX then
            backpack.slider:Hide()
        else
            TOTAL_BUTTON_PX = TOTAL_BUTTON_PX - backpack.content:GetHeight()
            backpack.slider:SetMinMaxValues(0, TOTAL_BUTTON_PX)
            backpack.slider:Show()
        end

        backpack:EnableMouseWheel(backpack.slider:IsVisible())

        for b = 1, #pocket.stuff do
            if b == 1 then
                pocket.stuff[b].itemicon:SetPoint('TOP', backpack.content)
            else
                pocket.stuff[b].itemicon:SetPoint('TOP', pocket.stuff[b - 1].itemicon, 'BOTTOM', 0, -3)
            end
            pocket.stuff[b].itemicon:SetPoint('LEFT', backpack.content, 'LEFT', 2, 0)
            if pocket.stuff[b].itemCount > 1 then
                pocket.stuff[b].itemicon.itemcountext:SetText(Color(COLOR_RED) .. ' × '..Color(COLOR_GOLD)..pocket.stuff[b].itemCount)
            else
                pocket.stuff[b].itemicon.itemcountext:SetText('')
            end
            pocket.stuff[b].itemicon:Show()
        end 
    end

    function mnkStuff_Bag.OnClickItem(self, button)
        print(self.item.itemLink)
        HandleModifiedItemClick(self.item.itemLink)

        --UseContainerItem(self.item.bagnumber, self.item.slotnumber)
    end

    function mnkStuff_Bag.OnClickPocket(self, button)
        mnkStuff_Bag.OpenPocket(self.pocket)
    end

    function mnkStuff_Bag.OnSellJunk()
        local price = 0
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                if select(4, GetContainerItemInfo(bag, slot)) == LE_ITEM_QUALITY_POOR then
                    --ShowMerchantSellCursor(1)
                    UseContainerItem(bag, slot)
                    price = price + select(11, GetItemInfo(GetContainerItemID(bag, slot)))
                end
            end
        end
        ResetCursor()
        if price ~= 0 then
            DEFAULT_CHAT_FRAME:AddMessage(string.format('Sold junk for: % s', GetCoinTextureString(price)))
        end
    end

    function mnkStuff_Bag.ShowBackpack()
        --print('showbackpack') 
        if not backpack.openpocket then
            if not backpack.bagsframe then
                mnkStuff_Bag.CreateBackpackBags()
            end

            mnkStuff_Bag.FillBackpack()
            mnkStuff_Bag.UpdateTabPockets()
        end

        backpack:Show()
    end

    function mnkStuff_Bag.StartDrag(self, button)
        self:StartMoving()
    end

    function mnkStuff_Bag.StopDrag(self, button)
        self:StopMovingOrSizing()
        mnkStuffDB.backpack_xpos = backpack:GetLeft()
        mnkStuffDB.backpack_ypos = backpack:GetBottom()
    end

    function mnkStuff_Bag.Toggle(var)
        --print('toggle '..var)

        if (var == 2 and not backpack:IsVisible()) or (var == 1 and backpack:IsVisible()) then return end

        if (var == 2 and backpack:IsVisible()) or (var == 0 and backpack:IsVisible()) then
            mnkStuff_Bag.HideBackpack()
        else
            mnkStuff_Bag.ShowBackpack()
        end
    end

    function mnkStuff_Bag.UpdateTabPockets()
        for i = 1, #backpack.pockets do
            mnkStuff_Bag.AddPocketTab(backpack.pockets[i], i)
        end
        
        if #backpack.pockets > 0 and backpack.openpocket == nil then
            mnkStuff_Bag.OpenPocket(backpack.pockets[1])
        end
    end

    mnkStuff_Bag:SetScript('OnEvent', mnkStuff_Bag.DoOnEvent)
    mnkStuff_Bag:RegisterEvent('PLAYER_ENTERING_WORLD')
    mnkStuff_Bag:RegisterEvent('MERCHANT_SHOW')
    mnkStuff_Bag:RegisterEvent('BAG_UPDATE_DELAYED')
    mnkStuff_Bag:RegisterEvent('BAG_SLOT_FLAGS_UPDATED')

   

               