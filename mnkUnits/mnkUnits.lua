mnkUnits = CreateFrame('frame')
mnkUnits.oUF = oUF or ns.oUF
local _, playerClass = UnitClass('player')
local classColor = {}
classColor.r, classColor.g, classColor.b, _ = GetClassColor(playerClass)
--Tags are in mnkLibs\mnkuTags

Config = {
    showfocus = true,
    showparty = true,
    showplayer = true,
    showpet = true,
    showtarget = true,
    showtargettarget = false,
    showboss1 = true,
    showboss2 = true,
    showboss3 = true,
    showboss4 = true,
    showboss5 = true,
    showarena1 = true,
    showarena2 = true,
    showarena3 = true,
    showarena4 = true,
    showarena5 = true
}

local function CreateCastBar(self)
    self.castbarbg = CreateFrame('Frame', nil, self)
    self.castbarbg:SetPoint('LEFT', self, 'LEFT', -1, 0)
    self.castbarbg:SetPoint('BOTTOM', self, 'TOP', 0, 4)
    SetBackdrop(self.castbarbg, nil, nil, 1, 1, 1, 1)
    self.castbarbg:SetBackdropColor(classColor.r/2, classColor.g/2, classColor.b/2, 1)
    self.castbarbg:SetFrameStrata('MEDIUM')
    self.castbarbg:SetSize(self:GetWidth()+2, 18)
    self.castbarbg:Hide()
    self.Castbar = CreateFrame('StatusBar', nil, self.castbarbg)
    self.Castbar:SetAllPoints()
    self.Castbar:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    self.Castbar:SetStatusBarColor(1/4, 1/4, 1/4, 1)
    if UnitIsPlayer(self.unit) then
        self.Castbar.Text = CreateFontString(self.Castbar, mnkLibs.Fonts.oswald, 16,  nil, nil, true)
        self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)
    end
    self.Castbar:SetFrameStrata('HIGH') 
    self.Castbar.PostCastStart = function(element, unit) element:GetParent():Show() end
    self.Castbar.PostCastStop = function(element, unit) element:GetParent():Hide() end
    self.Castbar.PostChannelStart = function(element, unit) element:GetParent():Show() end
    self.Castbar.PostChannelStop = function(element, unit) element:GetParent():Hide() end
    self.Castbar.Spark = self.Castbar:CreateTexture(nil, 'OVERLAY')
    self.Castbar.Spark:SetSize(1, self.castbarbg:GetHeight())
    self.Castbar.Spark:SetColorTexture(1, 0, 0, 1)
end

local function CreateHealthBar(self)
    local h = CreateFrame('StatusBar', nil, self)
    h:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    if UnitIsPlayer(self.unit) then
        h:SetStatusBarColor(classColor.r/5, classColor.g/5, classColor.b/5)
    else
        h:SetStatusBarColor(0, 0, 0)
    end
    h:SetReverseFill(false) 
    h.frequentUpdates = true
    local b = self:CreateTexture(nil, 'BORDER')
    b:SetAllPoints(h)
    b:SetColorTexture(1/4,0,0)
    return h
end

local function CreateBottomPanel()
    local pback = CreateFrame('Frame', 'mnkBottom', UIParent)
    SetBackdrop(pback, nil, nil, 1, 1, 1, 1)
    pback:SetBackdropColor(0, 0, 0, 0.8)
    pback:SetHeight(170)
    pback:SetWidth(UIParent:GetWidth())
    pback:SetPoint('BOTTOM',0,0)
    pback:SetFrameStrata('BACKGROUND')
    CreateBorder(pback, 1, -3, -3, 3, {classColor.r, classColor.g, classColor.b, .5}) 
    pback:Show()

    local pplayer = CreateFrame('Frame', 'mnkBottom', UIParent)
    SetBackdrop(pplayer, nil, nil, 1, 1, 1, 1)
    pplayer:SetBackdropColor(0, 0, 0, 0.8)
    pplayer:SetHeight(64)
    pplayer:SetWidth(281)
    pplayer:SetPoint('BOTTOM',0,171)
    pplayer:SetFrameStrata('BACKGROUND')
    CreateBorder(pplayer, 1, -1, -1, 1, {classColor.r, classColor.g, classColor.b, .5})
    pplayer:Show()

    local pbackLeft = CreateFrame('Frame', 'mnkButtonsLeft', pback)
    SetBackdrop(pbackLeft, nil, nil, 1, 1, 1, 1)
    pbackLeft:SetBackdropColor(1/5, 1/5, 1/5, 0.8)
    pbackLeft:SetHeight(130)
    pbackLeft:SetWidth(469)
    pbackLeft:SetPoint('BOTTOM', 0, 0)
    pbackLeft:SetPoint('LEFT', 530, 0)
    pbackLeft:SetFrameStrata('LOW')
    CreateBorder(pbackLeft, 0, -1, 0, 0, {classColor.r, classColor.g, classColor.b, .5})
    pbackLeft:Show()  

    local pbackRight = CreateFrame('Frame', 'mnkButtonsRight', pback)
    SetBackdrop(pbackRight, nil, nil, 1, 1, 1, 1)
    pbackRight:SetBackdropColor(1/5, 1/5, 1/5, 0.8)
    pbackRight:SetHeight(130)
    pbackRight:SetWidth(469)
    pbackRight:SetPoint('BOTTOM', 0, 0)
    pbackRight:SetPoint('LEFT', 1235, 0)
    pbackRight:SetFrameStrata('LOW')
    CreateBorder(pbackRight, 0, -1, 0, 0, {classColor.r, classColor.g, classColor.b, .5})
    pbackRight:Show()  
end

local function PostCreateIcon(Auras, button)
    local count = button.count
    count:ClearAllPoints()
    count:SetFont(mnkLibs.Fonts.ap, 10, 'OUTLINE')
    count:SetPoint('TOPRIGHT', button, 3, 3)
    local timer = button.cd:GetRegions()
    timer:SetFont(mnkLibs.Fonts.ap, 8, 'OUTLINE')
    timer:SetPoint('BOTTOMLEFT', button, 1, 1)
    button.icon:SetTexCoord(.07, .93, .07, .93)
    button.overlay:SetTexture(mnkLibs.Textures.border)
    button.overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
    button:SetScript('OnClick', function(self, button) CancelUnitBuff('player', self:GetName():match('%d')) end)
end

local function SetFlagVis(self)
    if UnitIsAFK(self.unit) then
        self.flagAFK:Show()
    else
        self.flagAFK:Hide()   
    end
    if UnitIsDND(self.unit) then
        self.flagDND:Show()
    else
        self.flagDND:Hide()   
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

local function CreateUnit(self)
    self:RegisterForClicks('AnyUp')
    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    SetBackdrop(self, nil, nil, 1, 1, 1, 1)
    self:SetBackdropColor(1/6, 1/6, 1/6)

    self:SetSize(200, 20)
    self.Health = CreateHealthBar(self)
    self.Health:SetHeight(20)
    self.Health:SetPoint('TOPRIGHT')
    self.Health:SetPoint('TOPLEFT')
    self.frameValues = CreateFrame('Frame', nil, self)
    self.frameValues:SetFrameLevel(20)
end

local function MinimalUnit(self)
    if Config['show'..self.unit] then 
        CreateUnit(self)
        self.Name = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.Name:SetAllPoints(self)
        self.Name:SetJustifyH("CENTER")
        self:Tag(self.Name, '[mnku:name]')
    end   
end

local function PetUnit(self)
    if Config.showpet then
        self:RegisterForClicks('AnyUp')
        self:SetScript('OnEnter', UnitFrame_OnEnter)
        self:SetScript('OnLeave', UnitFrame_OnLeave)
        self.PetHealth = CreateFontString(self, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.PetHealth:SetPoint('CENTER', self, 0, 0)
        self:Tag(self.PetHealth, '[mnku:pethp]')
        self:SetSize(36, oUF_mnkUnitsPlayer:GetHeight())
        self:SetScale(oUF_mnkUnitsPlayer:GetScale())
    end
end

local function PlayerUnit(self)
    if Config.showplayer then
        CreateUnit(self)
        CreateCastBar(self)
        self:SetSize(200, 26)
        self.HealthValue = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.HealthValue:SetPoint('LEFT', self.Health, 1, 1)
        self:Tag(self.HealthValue, '[mnku:status][mnku:perhp] [mnku:curhp]') 
        self.isResting = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.isResting:SetPoint('RIGHT', self.Health, 'RIGHT', 0, 0)
        self:Tag(self.isResting, '[|cFFFFFF00>resting<|r]')
        self.flagPVP = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagPVP:SetPoint('RIGHT', self.isResting, 'LEFT', -2, 0)
        self:Tag(self.flagPVP, '[|cffff0000>pvp<|r]') 
        self.flagAFK = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagAFK:SetPoint('RIGHT', self.flagPVP, 'LEFT', -2, 0)
        self.flagAFK:SetText(Color(COLOR_BLUE)..'AFK')
        self.flagDND = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagDND:SetPoint('RIGHT', self.flagPVP, 'LEFT', -2, 0)
        self.flagDND:SetText(Color(COLOR_BLUE)..'DND') 
        SetFlagVis(self)
        local t = {} 
        for i = 1, 10 do
            local f = CreateFrame('StatusBar', nil, self)
            f:SetStatusBarTexture(mnkLibs.Textures.combo_round)
            f:SetSize(16, 16)

            local n = CreateFontString(f, mnkLibs.Fonts.oswald, 10, nil, nil, false)
            n:SetPoint('CENTER', f, 0, 0)
            n:SetText(i)
            n:SetTextColor(0, 0, 0)
            
            if (i == 1) then
                f:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -2)
            else
                f:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', ((f:GetWidth() + 2) * (i - 1)), -2)
            end
            
            t[i] = f
            f:Hide()
        end

        self.ClassPower = t
        self.Runes = t
        self.flagCombat = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagCombat:SetPoint('LEFT', self.HealthValue, 'RIGHT', 1, 0)
        self.flagCombat:SetText('|cffff0000'..'×')
        self.flagCombat:Hide()
        self:RegisterEvent('PLAYER_REGEN_ENABLED', function(unit) unit.flagCombat:Hide() end)
        self:RegisterEvent('PLAYER_REGEN_DISABLED', function(unit) unit.flagCombat:Show() end)
        self:RegisterEvent('PLAYER_FLAGS_CHANGED', function(self) SetFlagVis(self) end)
        self.Power = CreateFrame('StatusBar', nil, self.Health)
        self.Power:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        self.Power:SetSize(self:GetWidth(), 3)
        self.Power:SetPoint('LEFT', self, 0, -9)
        self.Power.frequentUpdates = true
        self.Power.colorPower = true
        SetBackdrop(self.Power, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
        self.Power:SetBackdropColor(1/7, 1/7, 1/7, 1)
        self.AdditionalPower = CreateFrame('StatusBar', nil, self.Health)
        self.AdditionalPower:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        self.AdditionalPower:SetSize(self:GetWidth(), 3)
        self.AdditionalPower:SetPoint('LEFT', self, 0, -12)
        self.AdditionalPower.frequentUpdates = true
        self.AdditionalPower.colorPower = true
        SetBackdrop(self.AdditionalPower, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
        self.AdditionalPower:SetBackdropColor(1/7, 1/7, 1/7, 1)
        self.ThreatIndicator = CreateFrame('Frame', nil, self.Health)
        self.ThreatIndicator:SetSize((self:GetWidth()/2), 1)
        self.ThreatIndicator:SetPoint('CENTER', self, 0, -6)
        self.ThreatIndicator:SetFrameStrata('LOW')
        SetBackdrop(self.ThreatIndicator, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
        self.ThreatIndicator.Override = UpdateThreat
        self.Auras = CreateFrame('Frame', nil, self)
        self.Auras.spacing = 1
        self.Auras.numTotal = 14
        self.Auras:SetPoint('LEFT', self, 'LEFT', -2, 0)
        self.Auras:SetPoint('BOTTOM', self, 'TOP', 0 , 5)
        self.Auras:SetSize(self.Health:GetWidth(), 16)
        self.Auras.PostCreateIcon = PostCreateIcon
    end
end

local function PartyUnit(self)
    if Config.showparty then
        CreateUnit(self)
        self.Name = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.Name:SetPoint('LEFT', self.Health, 3, 0)
        self.Name:SetPoint('RIGHT', self:GetWidth() - 2)
        self:Tag(self.Name, '[mnku:leader][raidcolor][name]')
        self.HealthValue = CreateFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.HealthValue:SetPoint('RIGHT', self.Health, -2, 0)
        self:Tag(self.HealthValue, '[mnku:curhp]') 

        self.ResurrectIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.ResurrectIndicator:SetPoint('CENTER', self)
        self.ReadyCheckIndicator = self:CreateTexture()
        self.ReadyCheckIndicator:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        self.ReadyCheckIndicator:SetSize(14, 14)
        self.GroupRoleIndicator = self:CreateTexture(nil, 'OVERLAY')
        self.GroupRoleIndicator:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        self.GroupRoleIndicator:SetSize(14, 14)
        self.GroupRoleIndicator:SetAlpha(0)
        self:HookScript('OnEnter', function() self.GroupRoleIndicator:SetAlpha(1) end)
        self:HookScript('OnLeave', function() self.GroupRoleIndicator:SetAlpha(0) end)
    end
end

function mnkUnits.CreateUnits(self, unit)
    if (unit == 'pet') then
        PetUnit(self)
    elseif (unit == 'player') then 
        PlayerUnit(self)
    elseif (unit == 'party' or unit == 'raid') then 
        PartyUnit(self)
    elseif (unit == 'focus') or (unit == 'target') or (unit == 'targettarget') or unit:find('boss') or unit:find('arena') then
        MinimalUnit(self)
    end
end

--Based on code from Phanx, thanks Phanx!
local function UpdateMirrorBars()
    for i = 1, 3 do
        local barname = "MirrorTimer" .. i
        local bar = _G[barname]

        for _, region in pairs({ bar:GetRegions() }) do
            if region.GetTexture and region:GetTexture() == "SolidTexture" then
                region:Hide()
            end
        end
        bar:SetParent(UIParent)
        bar:SetWidth(200)
        bar:SetHeight(20)
        bar.bar = bar:GetChildren()
        bar.bg, bar.text, bar.border = bar:GetRegions()
        bar.bar:SetAllPoints(bar)
        bar.bar:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        bar.bg:ClearAllPoints()
        bar.bg:SetAllPoints(bar)
        bar.bg:SetTexture(mnkLibs.Textures.background)
        bar.bg:SetVertexColor(1, 1, 1, 1)
        bar.text:ClearAllPoints()
        bar.text:SetPoint("LEFT", bar, 4, 0)
        bar.text:SetFont(mnkLibs.Fonts.oswald, 18, 'OUTLINE')
        bar.border:Hide()
        SetBackdrop(bar, nil, nil, 1, 1, 1, 1)
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
        CreateBottomPanel()
        UpdateMirrorBars()
    end
end

mnkUnits.oUF:RegisterStyle('mnkUnits', mnkUnits.CreateUnits)
mnkUnits.oUF:SetActiveStyle('mnkUnits')
mnkUnits.oUF:Factory(function(self)
    self:Spawn('player'):SetPoint('CENTER', -300, -250)
    self:Spawn('pet'):SetPoint('LEFT', oUF_mnkUnitsPlayer, 'RIGHT', 5, 0)
    self:Spawn('focus'):SetPoint('TOPLEFT', oUF_mnkUnitsPlayer, 0, 26)
    self:Spawn('target'):SetPoint('TOPLEFT', 25, -25)
    self:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF_mnkUnitsTarget, 0, 26)
    self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide', 
        'showParty', true, 
        'showRaid', true, 
        'showPlayer', true, 
        'yOffset', -6, 
        'groupBy', 'ASSIGNEDROLE', 
        'groupingOrder', 'TANK,HEALER,DAMAGER', 
        'oUF-initialConfigFunction', [[
        self:SetHeight(20)
        self:SetWidth(200)
        ]]
    ):SetPoint('TOPLEFT', 25, -50)

    for index = 1, MAX_BOSS_FRAMES or 5 do
        local boss = self:Spawn('boss' .. index)
        local arena = self:Spawn('arena' .. index)

        if (index == 1) then
            boss:SetPoint('TOPRIGHT', -50, -100)
            arena:SetPoint('TOPRIGHT', -50, -100)
        else
            boss:SetPoint('TOP', _G['oUF_mnkUnitsBoss' .. index - 1], 'BOTTOM', 0, -6)
            arena:SetPoint('TOP', _G['oUF_mnkUnitsArena' .. index - 1], 'BOTTOM', 0, -6)
        end
    end
end)

--change leaveVehicle Button to match my layout.
MainMenuBarVehicleLeaveButton:SetNormalTexture(mnkLibs.Textures.arrow_down)
MainMenuBarVehicleLeaveButton:SetPushedTexture(mnkLibs.Textures.arrow_down_pushed)

mnkUnits:SetScript('OnEvent', mnkUnits.DoOnEvent)
mnkUnits:RegisterEvent('PLAYER_ENTERING_WORLD')
