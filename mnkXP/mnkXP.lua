mnkXP = CreateFrame('Frame')
mnkXP.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkXP:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkXP:RegisterEvent('PLAYER_LOGIN')
mnkXP:RegisterEvent('PLAYER_LEVEL_UP')
mnkXP:RegisterEvent('PLAYER_XP_UPDATE')
mnkXP:RegisterEvent('UPDATE_EXHAUSTION')

local LibQTip = LibStub('LibQTip-1.0')

function mnkXP:OnEnter(parent)
    local tooltip = LibQTip:Acquire('mnkXPTooltip', 3, 'LEFT', 'RIGHT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    local extXP = GetXPExhaustion()
    
    if extXP == nil then
        extXP = 0
    end 
    
    tooltip:Clear()
    tooltip:AddLine(mnkLibs.Color(COLOR_GOLD)..'XP', mnkLibs.formatNumber(UnitXP('player'), 2)..' of '..mnkLibs.formatNumber(UnitXPMax('player'), 2), mnkLibs.Color(COLOR_BLUE)..mnkLibs.formatNumToPercentage(UnitXP('player') / UnitXPMax('player')))
    --tooltip:AddLine(mnkLibs.Color(COLOR_GOLD)..'XP Left', TruncNumber(UnitXPMax('player') - UnitXP('player'), 2), mnkLibs.Color(COLOR_BLUE)..mnkLibs.formatNumToPercentage((UnitXPMax('player') - UnitXP('player')) / UnitXPMax('player')))
    tooltip:AddLine(mnkLibs.Color(COLOR_GOLD)..'Rested XP', mnkLibs.formatNumber(extXP, 2), mnkLibs.Color(COLOR_GREEN)..mnkLibs.formatNumToPercentage((extXP / UnitXPMax('player'))))

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

function mnkXP:PLAYER_LEVEL_UP()
    self:UpdateText()
end

function mnkXP:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkXP', {
        icon = 'Interface\\Icons\\Inv_misc_bomb_04.blp', 
        type = 'data source', 
        OnEnter = function (parent) mnkXP:OnEnter(parent) end
    })
    self.LDB.label = 'XP'
    self:UpdateText()
end

function mnkXP:PLAYER_XP_UPDATE()
    self:UpdateText()
end

function mnkXP:UPDATE_EXHAUSTION()
    self:UpdateText()
end

function mnkXP:UpdateText()
    local iRestXP = (((GetXPExhaustion() or 0) / UnitXPMax('player')) * 100) 
    local restXP = format('%.1f%%', iRestXP)
    local currXP = format('%.1f%%', ((UnitXP('player') / UnitXPMax('player')) * 100))

    if UnitLevel('player') == GetMaxPlayerLevel() then
        self.LDB.text = UnitLevel('player')
    elseif iRestXP < 1 then -- only show rested xp when you have at least 1% of total, it looks silly otherwise.
        self.LDB.text = UnitLevel('player')..mnkLibs.Color(COLOR_WHITE)..' - '..mnkLibs.Color(COLOR_BLUE)..currXP
    else
        self.LDB.text = UnitLevel('player')..mnkLibs.Color(COLOR_WHITE)..' - '..mnkLibs.Color(COLOR_BLUE)..currXP..mnkLibs.Color(COLOR_WHITE)..' - '..mnkLibs.Color(COLOR_GREEN)..restXP
    end
end


