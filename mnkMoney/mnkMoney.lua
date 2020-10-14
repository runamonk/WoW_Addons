mnkMoney = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
mnkMoney.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkMoney:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

mnkMoney:RegisterEvent('CHAT_MSG_CURRENCY')
mnkMoney:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
mnkMoney:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkMoney:RegisterEvent('PLAYER_LOGIN')
mnkMoney:RegisterEvent('PLAYER_MONEY')
mnkMoney:RegisterEvent('PLAYER_TRADE_MONEY')
mnkMoney:RegisterEvent('SEND_MAIL_COD_CHANGED')
mnkMoney:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
mnkMoney:RegisterEvent('TRADE_MONEY_CHANGED')


local libQTip = LibStub('LibQTip-1.0')
local SPACER = '       '
local currencyOnHand = 0

function  mnkMoney:CHAT_MSG_CURRENCY(event, arg1, arg2)
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
    self:UpdateText()
end

function mnkMoney:CURRENCY_DISPLAY_UPDATE()
    self:UpdateText()
end

function mnkMoney:OnClick()
    ToggleCharacter('TokenFrame')
end

function mnkMoney:OnEnter(parent)   
    local tooltip = libQTip:Acquire('mnkMoneyTooltip', 3, 'LEFT', 'LEFT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Currency', SPACER, mnkLibs.Color(COLOR_GOLD)..'Amount')
    local copper = GetMoney()
    local formattedMoney = GetCoinTextureString(copper)

    tooltip:AddLine('Coin', SPACER, formattedMoney)
    tooltip:AddLine(' ')

    local t = {}
    idx = 0
    for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
        name, isHeader, _, isUnused, _, count, icon, _ = C_CurrencyInfo.GetCurrencyListInfo(i)

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

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
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

function mnkMoney:PLAYER_LOGIN()
    mnkMoney.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkMoney', {
        type = 'data source', 
        icon = nil, 
        OnClick = function () mnkMoney:OnClick() end, 
        OnEnter = function (parent) mnkMoney:OnEnter(parent) end
    })
    self.LDB.label = 'Money'
end

function mnkMoney:PLAYER_ENTERING_WORLD(event, firstTime, reload)
    if firstTime or reload then
        currencyOnHand = GetMoney()
        self:UpdateText()
    end
end

function mnkMoney:PLAYER_MONEY()
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
    self:UpdateText()
end

function mnkMoney:PLAYER_TRADE_MONEY()
    self:UpdateText()
end

function mnkMoney:SEND_MAIL_COD_CHANGED()
    self:UpdateText()
end

function mnkMoney:SEND_MAIL_MONEY_CHANGED()
    self:UpdateText()
end

function mnkMoney:TRADE_MONEY_CHANGED()
    self:UpdateText()
end

function mnkMoney:UpdateText()
    local m = GetMoney()

    local gold, silver, copper = math.floor(m / 100 / 100), math.floor(m / 100 % 100), math.floor(m % 100)
    local text = 0

    if gold > 0 then
        self.LDB.icon = 'Interface\\MoneyFrame\\UI-GoldIcon'
        text = gold
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


