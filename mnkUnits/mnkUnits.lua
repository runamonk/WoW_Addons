mnkUnits = CreateFrame('frame')
mnkUnits.oUF = oUF or ns.oUF

Config = {
    showFocus = true,
    showParty = true,
    showPlayer = true,
    showTarget = false,
    showTargetTarget = false
}

local function CreateCastBar(self)
    self.Castbar = CreateFrame('StatusBar', nil, self)
    self.Castbar:SetAllPoints(self.Health)
    self.Castbar:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    self.Castbar:SetStatusBarColor(0, 0, 0, 0)
    self.Castbar:SetFrameStrata('HIGH') 
    self.Castbar.PostCastStart = PostUpdateCast
    self.Castbar.PostCastInterruptible = PostUpdateCast
    self.Castbar.PostCastNotInterruptible = PostUpdateCast
    self.Castbar.PostChannelStart = PostUpdateCast
    self.Castbar.Spark = self.Castbar:CreateTexture(nil, 'OVERLAY')
    self.Castbar.Spark:SetSize(1, self.Health:GetHeight())
    self.Castbar.Spark:SetColorTexture(1, 1/8, 1/8)
    self.Castbar.Spark:SetBlendMode('ADD')
end

local function CreateHealthBar(self)
    local h = CreateFrame('StatusBar', nil, self)
    h:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    h:SetStatusBarColor(0, 0, 0)
    h:SetReverseFill(false) 
    h.frequentUpdates = true
    local b = self:CreateTexture(nil, 'BORDER')
    b:SetAllPoints(h)
    b:SetColorTexture(1 / 5, 1 / 5, 1 / 5)
    return h
end

local function CreateUnit(self)
    self:RegisterForClicks('AnyUp')
    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    self:SetBackdrop({bgFile = 'Interface\\ChatFrame\\ChatFrameBackground', insets = {top = -1, bottom = -1, left = -1, right = -1}})
    self:SetBackdropColor(0, 0, 0)
    self:SetSize(160, 20)
    self.Health = CreateHealthBar(self)
    self.Health:SetHeight(20)
    self.Health:SetPoint('TOPRIGHT')
    self.Health:SetPoint('TOPLEFT')
    self.frameValues = CreateFrame('Frame', nil, self)
    self.frameValues:SetFrameLevel(20)
end

local function PostCreateIcon(Auras, button)
    local count = button.count
    count:ClearAllPoints()
    count:SetFont(mnkLibs.Fonts.ap, 10, 'OUTLINE')
    count:SetPoint('TOPRIGHT', button, 3, 3)
    local timer = button.cd:GetRegions()
    timer:SetFont(mnkLibs.Fonts.ap, 10, 'OUTLINE')
    timer:SetPoint('BOTTOMLEFT', button, 0, 0)
    button.icon:SetTexCoord(.07, .93, .07, .93)
    button.overlay:SetTexture(mnkLibs.Textures.border)
    button.overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
end

local function PostUpdateCast(element, unit)
    local Spark = element.Spark
    if (not element.notInterruptible and UnitCanAttack('player', unit)) then
        Spark:SetColorTexture(1, 0, 0)
    else
        Spark:SetColorTexture(1, 1, 1)
    end
end

local function UpdateThreat(self, event, unit)
    if (unit ~= self.unit) then
        return
    end

    local situation = UnitThreatSituation(unit)
    if (situation and situation > 0) then
        local r, g, b = GetThreatStatusColor(situation)
        self.ThreatIndicator:SetBackdropColor(r, g, b, 1)
    else
        self.ThreatIndicator:SetBackdropColor(0, 0, 0, 0)
    end
end

local function FocusUnit(self)
    if Config.showFocus then
        CreateUnit(self)
        self.Name = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, 'OVERLAY')
        self.Name:SetPoint('CENTER', self, 'CENTER')
        self:Tag(self.Name, '[mnku:name]')
        self:SetWidth(200)
    end
end

local function PlayerUnit(self)
    if Config.showPlayer then
        CreateUnit(self)
        self.HealthValue = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, '')
        self.HealthValue:SetPoint('LEFT', self.Health, 1, 1)
        self:Tag(self.HealthValue, '[mnku:status][mnku:perhp] [mnku:curhp]') 
        self.PetHealth = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, 'OVERLAY')
        self.PetHealth:SetPoint('RIGHT', self.Health, 'RIGHT', -1, 1)
        self.PetHealth.overrideUnit = 'pet'
        self:Tag(self.PetHealth, '[mnku:pethp]')
        self.isResting = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.isResting:SetPoint('LEFT', self, 'TOPLEFT', -25, -11)
        self:Tag(self.isResting, '[|cFFFFFF00>resting<|r]')
        
        local t = {} 
        for i = 1, 10 do
            local f = CreateFrame('StatusBar', nil, self)
            f:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
            f:SetSize(16, 10)

            local n = CreateFontString(f, mnkLibs.Fonts.oswald, 10, nil, nil, false)
            n:SetPoint('CENTER', f, 0, 0)
            n:SetText(i)
            n:SetTextColor(0, 0, 0)
            
            if (i == 1) then
                f:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -4)
            else
                f:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', ((f:GetWidth() + 2) * (i - 1)), -4)
            end

            t[i] = f
        end

        self.ClassPower = t
        self.Runes = t
        self.flagCombat = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, 'OVERLAY')
        self.flagCombat:SetPoint('LEFT', self.HealthValue, 'RIGHT', 1, 0)
        self.flagCombat:SetText('|cffff0000'..'×')
        self.flagCombat:Hide()
        self:RegisterEvent('PLAYER_REGEN_ENABLED', function(unit) unit.flagCombat:Hide() end)
        self:RegisterEvent('PLAYER_REGEN_DISABLED', function(unit) unit.flagCombat:Show() end)
        self.flagPVP = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, 'OVERLAY')
        self.flagPVP:SetPoint('LEFT', self.HealthValue, 'RIGHT', 6, 0)
        self:Tag(self.flagPVP, '[|cffff0000>pvp<|r]') 
        self.Power = CreateFrame('StatusBar', nil, self.Health)
        self.Power:SetPoint('BOTTOMRIGHT')
        self.Power:SetPoint('BOTTOMLEFT')
        self.Power:SetHeight(2)
        self.Power:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        self.Power.frequentUpdates = true
        self.Power.colorPower = false
        self.Power.colorClass = true
        self.Power.colorTapping = false
        self.Power.colorDisconnected = false
        self.Power.colorReaction = false 
        self.ThreatIndicator = CreateFrame('Frame', nil, self)
        self.ThreatIndicator:SetPoint('TOPRIGHT', 2, 2)
        self.ThreatIndicator:SetPoint('BOTTOMLEFT', -2, -2)
        self.ThreatIndicator:SetFrameStrata('BACKGROUND')
        SetBackdrop(self.ThreatIndicator, mnkLibs.Textures.border, 0, 0, 0, 0)
        self.ThreatIndicator.Override = UpdateThreat
        self.Auras = CreateFrame('Frame', nil, self)
        self.Auras.spacing = 1
        self.Auras.numTotal = 12
        self.Auras:SetPoint('LEFT', self, 'LEFT', -1, 0)
        self.Auras:SetPoint('BOTTOM', self, 'TOP', 0 , 5)
        self.Auras:SetSize(self.Health:GetWidth(), 16)
        self.Auras.PostCreateIcon = PostCreateIcon
        self:SetWidth(200)
        CreateCastBar(self)
    end
end

local function PartyUnit(self)
    if Config.showParty then
        CreateUnit(self)
        self.Name = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, '')
        self.Name:SetPoint('LEFT', self.Health, 3, 0)
        self.Name:SetPoint('RIGHT', self:GetWidth() - 2)
        self:Tag(self.Name, '[mnku:leader][raidcolor][name]')
        self.ResurrectIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.ResurrectIndicator:SetPoint('CENTER', self)
        self.ReadyCheckIndicator = self:CreateTexture()
        self.ReadyCheckIndicator:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        self.ReadyCheckIndicator:SetSize(14, 14)
        self.GroupRoleIndicator = self:CreateTexture(nil, 'OVERLAY')
        self.GroupRoleIndicator:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        self.GroupRoleIndicator:SetSize(14, 14)
        self.GroupRoleIndicator:SetAlpha(0)
        self:HookScript('OnEnter', function() RoleIcon:SetAlpha(1) end)
        self:HookScript('OnLeave', function() RoleIcon:SetAlpha(0) end)
    end
end

local function TargetUnit(self)
    if Config.showTarget then
        CreateUnit(self)
        self.HealthValue = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil)
        self.HealthValue:SetPoint('RIGHT', self.Health, -2, 0)
        self.HealthValue:SetWordWrap(false)
        self:Tag(self.HealthValue, '[mnku:curhp]')
        self.Name = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, '')
        self.Name:SetJustifyH('LEFT')
        self.Name:SetPoint('LEFT', self.Health, 2, 0)
        self.Name:SetPoint('RIGHT', self.HealthValue, 'LEFT')
        self.Name:SetWordWrap(false)
        self:Tag(self.Name, '[mnku:name]')
        self.Level = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.Level:SetPoint('LEFT', self, 'TOPLEFT', -25, -10)
        self:Tag(self.Level, '[mnku:level]')
        self.RaidTargetIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.RaidTargetIndicator:SetPoint('LEFT', self, 'RIGHT', 10, 0)
        self.RaidTargetIndicator:SetSize(16, 16)
        self:SetWidth(250)
        CreateCastBar(self)   
    end
end

local function TargetTargetUnit(self)
    if Config.showTargetTarget then
        CreateUnit(self)
        self.Name = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, 'OVERLAY')
        self.Name:SetPoint('CENTER', self, 'CENTER')
        self:Tag(self.Name, '[mnku:name]')
        self:SetWidth(200)
    end
end

function mnkUnits.CreateUnits(self, unit)
    if (unit == 'player') then 
        PlayerUnit(self)
    elseif (unit == 'target') then 
        TargetUnit(self)
    elseif (unit == 'targettarget') then
        TargetTargetUnit(self)
    elseif (unit == 'party' or unit == 'raid') then 
        PartyUnit(self)
    elseif (unit == 'focus') then
        FocusUnit(self)
    end
end

function mnkUnits:DoOnEvent(event, arg1, arg2)
    if event == 'PLAYER_ENTERING_WORLD' then
        BuffFrame:UnregisterEvent("UNIT_AURA")
        BuffFrame:Hide()
        TemporaryEnchantFrame:Hide()
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:Hide()
        CompactRaidFrameContainer:Hide()
    end
end

mnkUnits.oUF:RegisterStyle('mnku', mnkUnits.CreateUnits)
mnkUnits.oUF:SetActiveStyle('mnku')
mnkUnits.oUF:Factory(function(self)
    self:Spawn('player'):SetPoint('CENTER', -300, -250)
    self:Spawn('focus'):SetPoint('TOPLEFT', oUF_mnkuPlayer, 0, 26)
    self:Spawn('target'):SetPoint('CENTER', 300, -250)
    --self:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF_mnkuTarget, 0, 26)
    
    self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide', 
        'showParty', true, 
        'showRaid', true, 
        'showPlayer', true, 
        'yOffset', -6, 
        'groupBy', 'ASSIGNEDROLE', 
        'groupingOrder', 'TANK,HEALER,DAMAGER', 
        'oUF-initialConfigFunction', [[
        self:SetHeight(19)
        self:SetWidth(126)
        ]]
    ):SetPoint('TOPLEFT', 25, -50)

    for index = 1, MAX_BOSS_FRAMES or 5 do
        local boss = self:Spawn('boss' .. index)
        local arena = self:Spawn('arena' .. index)

        if (index == 1) then
            boss:SetPoint('TOPRIGHT', -50, -100)
            arena:SetPoint('TOPRIGHT', -50, -100)
        else
            boss:SetPoint('TOP', _G['oUF_mnkuBoss' .. index - 1], 'BOTTOM', 0, -6)
            arena:SetPoint('TOP', _G['oUF_mnkuArena' .. index - 1], 'BOTTOM', 0, -6)
        end
    end
end)

mnkUnits:SetScript('OnEvent', mnkUnits.DoOnEvent)
mnkUnits:RegisterEvent('PLAYER_ENTERING_WORLD')
