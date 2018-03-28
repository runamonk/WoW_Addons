mnkMoney = CreateFrame('Frame')
mnkMoney.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
local libQTip = LibStub('LibQTip-1.0')
local SPACER = '       '

function mnkMoney.DoOnClick(self)
    ToggleCharacter('TokenFrame')
end

function mnkMoney:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkMoney.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkMoney', {
            type = 'data source', 
            icon = nil, 
            OnClick = mnkMoney.DoOnClick, 
            OnEnter = mnkMoney.DoOnEnter
        })
        self.LDB.label = 'Money'
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
        tooltip:AddLine(t[i].icon..t[i].name, SPACER, TruncNumber(t[i].count))
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
mnkMoney:RegisterEvent('PLAYER_LOGIN')
mnkMoney:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
mnkMoney:RegisterEvent('MERCHANT_CLOSED')
mnkMoney:RegisterEvent('PLAYER_MONEY')
mnkMoney:RegisterEvent('PLAYER_TRADE_MONEY')
mnkMoney:RegisterEvent('TRADE_MONEY_CHANGED')
mnkMoney:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
mnkMoney:RegisterEvent('SEND_MAIL_COD_CHANGED')
mnkMoney:RegisterEvent('BAG_UPDATE')



