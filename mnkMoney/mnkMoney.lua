mnkMoney = CreateFrame('Frame')
mnkMoney.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
local libQTip = LibStub('LibQTip-1.0')
local SPACER = '       '
local currencyOnHand = 0

function mnkMoney.DoOnClick(self)
    ToggleCharacter('TokenFrame')
end

function mnkMoney:DoOnEvent(event, arg1, arg2)
    if event == 'PLAYER_LOGIN' then
        mnkMoney.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkMoney', {
            type = 'data source', 
            icon = nil, 
            OnClick = mnkMoney.DoOnClick, 
            OnEnter = mnkMoney.DoOnEnter
        })
        self.LDB.label = 'Money'
    end
    if event == 'PLAYER_ENTERING_WORLD' then
        currencyOnHand = GetMoney()
    elseif event == 'CHAT_MSG_LOOT' or event == 'CHAT_MSG_CURRENCY' or event == 'PLAYER_MONEY' then
        --print(event)
        if event == 'CHAT_MSG_LOOT' then
            if arg1 ~= nil then
                local LOOT_ITEM_PATTERN = (LOOT_ITEM_SELF):gsub('%%s', '(.+)')
                local LOOT_ITEM_PUSH_PATTERN = (LOOT_ITEM_PUSHED_SELF):gsub('%%s', '(.+)')
                local LOOT_ITEM_MULTIPLE_PATTERN = (LOOT_ITEM_SELF_MULTIPLE):gsub('%%s', '(.+)'):gsub('%%d', '(%%d+)')
                local LOOT_ITEM_PUSH_MULTIPLE_PATTERN = (LOOT_ITEM_PUSHED_SELF_MULTIPLE):gsub('%%s', '(.+)'):gsub('%%d', '(%%d+)')
                local LOOT_ITEM_CREATED_SELF_PATTERN = LOOT_ITEM_CREATED_SELF:gsub('%%s', '(.+)')
                local l, q = arg1:match(LOOT_ITEM_MULTIPLE_PATTERN)

                --print(l,' * ',q)
                if not l then
                    l, q = arg1:match(LOOT_ITEM_PUSH_MULTIPLE_PATTERN)
                    if not l then
                        q, l = 1, arg1:match(LOOT_ITEM_PATTERN)
                        if not l then
                            q, l = 1, arg1:match(LOOT_ITEM_PUSH_PATTERN)
                            if not l then
                                q, l = 1, arg1:match(LOOT_ITEM_CREATED_SELF_PATTERN)
                            end
                        end
                    end
                end -- not l

                --print('2 ',l)
                if l ~= nil then
                    q = tonumber(q) or 0

                    if l:find('battlepet') then
                        local _, speciesID, _, rarity = (':'):split(l)
                        local color = GetItemQualityColor(rarity)
                        local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
                        local s = string.format('|T%s:12|t %s', icon, '|c'..color..name)
                        CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
                    else
                        local c = ''
                        if q > 1 then
                            c = ' x '..q
                        else
                            c = ''
                        end
                        
                        local itemName, _, rarity, _, _, itemType, subType, _, _, itemIcon, _ = GetItemInfo(l)
                        if rarity > 0 then
                            local x = 0
                            x = GetItemCount(l)
                            local _,_,_,color = GetItemQualityColor(rarity)
                            --print('3 ', x)
                            if x > 0 then
                                x = ' ['..x + q..']'
                            else
                                x = ' '
                            end
                            
                            local s = string.format('|T%s:12|t %s', itemIcon, '|c'..color..itemName..Color(COLOR_WHITE)..c..x)
                            CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
                        end -- if itemtype
                    end -- else
                end -- l
            end -- arg1
        end -- CHAT_MSG_LOOT
        
        if event == 'PLAYER_MONEY' then
            local currency = GetMoney() or 0
            local x = 0
            local sign = nil

            if (currency ~= currencyOnHand) and ((currency > 0) or (currencyOnHand > 0)) then
                if currency > currencyOnHand then
                    x = currency - currencyOnHand
                    currencyOnHand = currency
                    sign = '+'
                elseif currencyOnHand > currency then
                    x = currencyOnHand - currency
                    currencyOnHand = currency
                    sign = '-'
                end
                local s = sign..GetCoinTextureString(x) or nil
                if s ~= nil then
                    CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
                    currencyOnHand = currency
                end 
            end
        end -- PLAYER_MONEY

        if event == 'CHAT_MSG_CURRENCY' then
            local CURRENCY_PATTERN = (CURRENCY_GAINED):gsub('%%s', '(.+)')
            local CURRENCY_MULTIPLE_PATTERN = (CURRENCY_GAINED_MULTIPLE):gsub('%%s', '(.+)'):gsub('%%d', '(%%d+)')
            
            local l, c = arg1:match(CURRENCY_MULTIPLE_PATTERN)
            if not l then
                c, l = 1, arg1:match(CURRENCY_PATTERN)
            end
            if l then
                local name, i, icon = _G.GetCurrencyInfo(tonumber(l:match('currency:(%d+)')))
                local s = string.format('|T%s:12|t %s', icon, name..Color(COLOR_WHITE) .. ' x '..c..' ['..i..']')
                CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
            end
        end --CHAT_MSG_CURRENCY
    end    

    local gold, silver, copper = mnkMoney.GetMoneyText()
    local text = 0

    if gold > 0 then
        self.LDB.icon = 'Interface\\MoneyFrame\\UI-GoldIcon'
        text = TruncNumber(gold, 2)
    elseif silver > 0 then
        self.LDB.icon = 'Interface\\MoneyFrame\\UI-SilverIcon'
        text = silver
    elseif copper > 0 then
        self.LDB.icon = 'Interface\\MoneyFrame\\UI-CopperIcon'
        text = copper
    else
        self.LDB.icon = 'Interface\\MoneyFrame\\UI-CopperIcon'
        text = 0
    end

    self.LDB.text = text
end

function mnkMoney.DoOnEnter(self)
    
    local tooltip = libQTip:Acquire('mnkMoneyTooltip', 3, 'LEFT', 'LEFT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:Clear()
    tooltip:AddHeader(Color(COLOR_GOLD) .. 'Currency', SPACER, Color(COLOR_GOLD) .. 'Amount')
    local gold, silver, copper = mnkMoney.GetMoneyText()
    
    if gold > 0 then
        tooltip:AddLine(format('|T%s:16|t %s', 'Interface\\MoneyFrame\\UI-GoldIcon', 'Gold'), SPACER, TruncNumber(gold, 2))
    elseif silver > 0 then
        tooltip:AddLine(format('|T%s:16|t %s', 'Interface\\MoneyFrame\\UI-SilverIcon', 'Silver'), SPACER, format('%d', silver))
    elseif copper > 0 then
        tooltip:AddLine(format('|T%s:16|t %s', 'Interface\\MoneyFrame\\UI-CopperIcon', 'Copper'), SPACER, format('%d', copper))
    else
        tooltip:AddLine('0.00')
    end

    tooltip:AddLine(' ')
    local t = {}
    idx = 0
    for i = 1, GetCurrencyListSize() do
        name, isHeader, _, isUnused, _, count, icon, _ = GetCurrencyListInfo(i)

        if (isHeader == false) and (isUnused == false) then
            idx = idx + 1
            t[idx] = {}
            t[idx].name = name
            t[idx].icon = format('|T%s:16|t ', icon)
            t[idx].count = count
        end
    end

    local sort_func = function(a, b) return a.name < b.name end
    table.sort(t, sort_func)

    for i = 1, #t do
        tooltip:AddLine(t[i].icon..t[i].name, SPACER, TruncNumber(t[i].count,2))
    end

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkMoney.GetMoneyText()
    local copper = GetMoney()

    return math.floor(copper / 100 / 100), math.floor(copper / 100 % 100), math.floor(copper % 100)
end

mnkMoney:SetScript('OnEvent', mnkMoney.DoOnEvent)

mnkMoney:RegisterEvent('ADDON_LOADED')
mnkMoney:RegisterEvent('BAG_UPDATE')
mnkMoney:RegisterEvent('CHAT_MSG_CURRENCY')
mnkMoney:RegisterEvent('CHAT_MSG_LOOT')
mnkMoney:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
-- mnkMoney:RegisterEvent('GARRISON_TALENT_COMPLETE')
-- mnkMoney:RegisterEvent('GARRISON_TALENT_UPDATE')
-- mnkMoney:RegisterEvent('GARRISON_UPDATE')
-- mnkMoney:RegisterEvent('GROUP_ROSTER_UPDATE')
mnkMoney:RegisterEvent('LOOT_OPENED')
mnkMoney:RegisterEvent('MERCHANT_CLOSED')
mnkMoney:RegisterEvent('MERCHANT_SHOW')
mnkMoney:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkMoney:RegisterEvent('PLAYER_LOGIN')
mnkMoney:RegisterEvent('PLAYER_MONEY')
-- mnkMoney:RegisterEvent('PLAYER_REGEN_DISABLED')
-- mnkMoney:RegisterEvent('PLAYER_REGEN_ENABLED')
mnkMoney:RegisterEvent('PLAYER_TRADE_MONEY')
mnkMoney:RegisterEvent('SEND_MAIL_COD_CHANGED')
mnkMoney:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
mnkMoney:RegisterEvent('TRADE_MONEY_CHANGED')
