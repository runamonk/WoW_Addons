mnkXP = CreateFrame('Frame')
mnkXP.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')

function mnkXP:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkXP.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkXP', {
            icon = 'Interface\\Icons\\Inv_misc_bomb_04.blp', 
            type = 'data source', 
            OnEnter = mnkXP.DoOnEnter
        })
        self.LDB.label = 'XP'
    end
    
    self.LDB.text = self.GetXPText()
end

function mnkXP.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkXPTooltip', 3, 'LEFT', 'RIGHT', 'RIGHT')
    self.tooltip = tooltip

    local extXP = GetXPExhaustion()
    
    if extXP == nil then
        extXP = 0
    end 
    
    tooltip:Clear()
    tooltip:AddLine(Color(COLOR_GOLD) .. 'XP', TruncNumber(UnitXP('player'), 2) .. ' of '..TruncNumber(UnitXPMax('player'), 2), Color(COLOR_BLUE)..ToPCT(UnitXP('player') / UnitXPMax('player')))
    --tooltip:AddLine(Color(COLOR_GOLD) .. 'XP Left', TruncNumber(UnitXPMax('player') - UnitXP('player'), 2), Color(COLOR_BLUE)..ToPCT((UnitXPMax('player') - UnitXP('player')) / UnitXPMax('player')))
    tooltip:AddLine(Color(COLOR_GOLD) .. 'Rested XP', TruncNumber(extXP, 2), Color(COLOR_GREEN)..ToPCT((extXP / UnitXPMax('player'))))

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkXP:GetXPText()
    local iRestXP = (((GetXPExhaustion() or 0) / UnitXPMax('player')) * 100)
    local restXP = format(TEXT('%.1f%%'), iRestXP)
    local currXP = format(TEXT('%.1f%%'), ((UnitXP('player') / UnitXPMax('player')) * 100))

    if UnitLevel('player') == GetMaxPlayerLevel() then
        return UnitLevel('player')
    elseif iRestXP < 1 then -- only show rested xp when you have at least 1% of total, it looks silly otherwise.
        return UnitLevel('player')..Color(COLOR_WHITE) .. ' - '..Color(COLOR_BLUE)..currXP
    else
        return UnitLevel('player')..Color(COLOR_WHITE) .. ' - '..Color(COLOR_BLUE)..currXP..Color(COLOR_WHITE) .. ' - '..Color(COLOR_GREEN)..restXP
    end
end

mnkXP:SetScript('OnEvent', mnkXP.DoOnEvent)
mnkXP:RegisterEvent('PLAYER_LOGIN')
mnkXP:RegisterEvent('PLAYER_LEVEL_UP')
mnkXP:RegisterEvent('PLAYER_XP_UPDATE')
mnkXP:RegisterEvent('UPDATE_EXHAUSTION')
