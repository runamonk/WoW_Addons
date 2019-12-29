mnkMoney = CreateFrame('Frame')
mnkMoney.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
local libQTip = LibStub('LibQTip-1.0')
local SPACER = '       '
local currencyOnHand = 0
local _

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
    elseif event == 'CHAT_MSG_CURRENCY' or event == 'PLAYER_MONEY' then
      
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
                local s = string.format('|T%s:12|t %s', icon, name..mnkLibs.Color(COLOR_WHITE)..' x '..c..' ['..i..']')
                CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
            end
        end --CHAT_MSG_CURRENCY
    end    

    local gold, silver, copper = mnkMoney.GetMoneyText()
    local text = 0

    if gold > 0 then
        self.LDB.icon = 'Interface\\MoneyFrame\\UI-GoldIcon'
        text = mnkLibs.formatNumber(gold, 2)
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
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Currency', SPACER, mnkLibs.Color(COLOR_GOLD)..'Amount')
    local gold, silver, copper = mnkMoney.GetMoneyText()
    
    if gold > 0 then
        tooltip:AddLine(format('|T%s:16|t %s', 'Interface\\MoneyFrame\\UI-GoldIcon', 'Gold'), SPACER, mnkLibs.formatNumber(gold, 2))
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
        tooltip:AddLine(t[i].icon..t[i].name, SPACER, mnkLibs.formatNumber(t[i].count,2))
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

mnkMoney:RegisterEvent('CHAT_MSG_CURRENCY')
mnkMoney:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
mnkMoney:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkMoney:RegisterEvent('PLAYER_LOGIN')
mnkMoney:RegisterEvent('PLAYER_MONEY')
mnkMoney:RegisterEvent('PLAYER_TRADE_MONEY')
mnkMoney:RegisterEvent('SEND_MAIL_COD_CHANGED')
mnkMoney:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
mnkMoney:RegisterEvent('TRADE_MONEY_CHANGED')
