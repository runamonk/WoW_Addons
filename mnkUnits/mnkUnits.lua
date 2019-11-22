mnkUnits = CreateFrame('frame')
mnkUnits.oUF = oUF or ns.oUF
local _, playerClass = UnitClass('player')
local classColor = {}
local _BossBanner_OnEvent = BossBanner_OnEvent;

classColor.r, classColor.g, classColor.b, _ = GetClassColor(playerClass)
--Tags are in mnkLibs\mnkuTags

Config = {
    showfocus = true,
    showparty = true,
    showraid = true, 
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
    mnkLibs.setBackdrop(self.castbarbg, nil, nil, 0, 0, 0, 0)
    self.castbarbg:SetBackdropColor(0, 0, 0, 1)
    self.castbarbg:SetFrameStrata('MEDIUM')
    self.castbarbg:SetSize(self:GetWidth()+2, 18)
    mnkLibs.createBorder(self.castbarbg, 1,-1,-1,1, {1,1,1,1})
    self.castbarbg:Hide()
    self.Castbar = CreateFrame('StatusBar', nil, self.castbarbg)
    self.Castbar:SetAllPoints()
    self.Castbar:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    self.Castbar:SetStatusBarColor(1/5, 1/5, 1/5, 1)
    if UnitIsPlayer(self.unit) then
        self.Castbar.Text = mnkLibs.createFontString(self.Castbar, mnkLibs.Fonts.oswald, 16,  nil, nil, true)
        self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)
    end
    self.Castbar:SetFrameStrata('HIGH') 
    self.Castbar.PostCastStart = function(element, unit) element:GetParent():Show() end
    self.Castbar.PostCastStop = function(element, unit) element:GetParent():Hide() end
    self.Castbar.PostChannelStart = function(element, unit) element:GetParent():Show() end
    self.Castbar.PostChannelStop = function(element, unit) element:GetParent():Hide() end
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
    mnkLibs.setBackdrop(pback, nil, nil, 1, 1, 1, 1)
    pback:SetBackdropColor(0, 0, 0, 0.8)
    pback:SetHeight(170)
    pback:SetWidth(UIParent:GetWidth())
    pback:SetPoint('BOTTOM',0,0)
    pback:SetFrameStrata('BACKGROUND')
    mnkLibs.createBorder(pback, 1, -3, -3, 3, {classColor.r, classColor.g, classColor.b, .5}) 
    pback:Show()

    local pplayer = CreateFrame('Frame', 'mnkBottom', UIParent)
    mnkLibs.setBackdrop(pplayer, nil, nil, 1, 1, 1, 1)
    pplayer:SetBackdropColor(0, 0, 0, 0.8)
    pplayer:SetHeight(64)
    pplayer:SetWidth(281)
	pplayer:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 203)
    pplayer:SetFrameStrata('BACKGROUND')
    mnkLibs.createBorder(pplayer, 1, -1, -1, 1, {classColor.r, classColor.g, classColor.b, .5})
    pplayer:Show()

    local pbackLeft = CreateFrame('Frame', 'mnkButtonsLeft', pback)
    mnkLibs.setBackdrop(pbackLeft, nil, nil, 1, 1, 1, 1)
    pbackLeft:SetBackdropColor(1/5, 1/5, 1/5, 0.8)
    pbackLeft:SetHeight(128)
    pbackLeft:SetWidth(469)
	pbackLeft:SetPoint('CENTER', UIParent, 'BOTTOM', -340, 60)
    pbackLeft:SetFrameStrata('LOW')
    mnkLibs.createBorder(pbackLeft, 0, -1, 0, 0, {classColor.r, classColor.g, classColor.b, .5})
    pbackLeft:Show()  

    local pbackRight = CreateFrame('Frame', 'mnkButtonsRight', pback)
    mnkLibs.setBackdrop(pbackRight, nil, nil, 1, 1, 1, 1)
    pbackRight:SetBackdropColor(1/5, 1/5, 1/5, 0.8)
    pbackRight:SetHeight(128)
    pbackRight:SetWidth(469)
	pbackRight:SetPoint('CENTER', UIParent, 'BOTTOM', 340, 60)
    pbackRight:SetFrameStrata('LOW')
    mnkLibs.createBorder(pbackRight, 0, -1, 0, 0, {classColor.r, classColor.g, classColor.b, .5})
    pbackRight:Show()  
end

local function timer_OnUpdate(button, elapsed)
    if (button.timercount and button.timercount ~= math.huge) then
        button.timercount = max(button.timercount - elapsed, 0)
        if button.timercount > 0 then
            button.timer:SetText(mnkLibs.formatTime(button.timercount))
            if button.timercount <= 3 then
                button.timer:SetTextColor(1, 0, 0)
                button.border:SetBackdropBorderColor(1,0,0,1)
            else
                button.timer:SetTextColor(1, 1, 1)
                button.border:SetBackdropBorderColor(0,0,0,1)
            end
        else
			button.timer:SetText()
		end
    else
        button.border:SetBackdropBorderColor(0,0,0,1)
        button.timer:SetText()
    end
end

local function PostCreateIcon(Auras, button)
    button.count = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 10,  nil, nil, true)
    button.count:ClearAllPoints()
    button.count:SetPoint('TOPRIGHT', button, 0, 2)
    button.timer = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 10,  nil, nil, true)
    button.timer:ClearAllPoints()
    button.timer:SetPoint('BOTTOMLEFT', button, 0, 0)
    button.icon:SetTexCoord(.07, .93, .07, .93)
    button:SetScript('OnClick', function(self, button) CancelUnitBuff('player', self:GetName():match('%d')) end)
    mnkLibs.createBorder(button, 1,-1,-1,1, {0,0,0,1})
end

local function PostUpdateIcon(element, unit, button, index)
    local _, _, _, _, duration, expirationTime = UnitAura(unit, index, button.filter)

    if (duration ~= nil and expirationTime ~= nil) and (duration > 0) and (expirationTime > 0) then
        button.timercount = expirationTime - GetTime()
    else
        button.timercount = math.huge
    end
    button:SetScript('OnUpdate', function(self, elapsed) timer_OnUpdate(self, elapsed) end)
end

local function SetPlayerStatusFlag(self, combatFlag)
	if not combatFlag or combatFlag == nil then
        self.flagCombat:Hide()
    else
        self.flagCombat:Show()   
	end
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

local function CreateUnit(self)
    self:RegisterForClicks('AnyUp')
    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    mnkLibs.setBackdrop(self, nil, nil, 0, 0, 0, 0)
    self:SetBackdropColor(1, 1, 1)
    --self:SetBackdropColor(1/6, 1/6, 1/6)
    -- this isn't needed for party or raid, they set their own defaults and sometimes this causes a taint.
    if self.unit ~= 'party' and self.unit ~= 'raid' then
        self:SetSize(200, 20)
    end
    self.Health = CreateHealthBar(self)
    self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
	self.Health:SetPoint('RIGHT', self, 'RIGHT', 0, 0)
    self.Health:SetAllPoints()

    self.frameValues = CreateFrame('Frame', nil, self)
    self.frameValues:SetFrameLevel(self:GetFrameLevel()+50)
    self.frameValues:SetSize(self:GetSize())
    self.frameValues:SetAllPoints()
end

local function MinimalUnit(self)
    if Config['show'..self.unit] then 
        CreateUnit(self)
        self.unitName = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.unitName:SetAllPoints(self)
        self.unitName:SetJustifyH('CENTER')
        self.unitName:SetWordWrap(false)
        self:Tag(self.unitName, '[mnku:name]')
    end   
end

local function PetUnit(self)
    if Config.showpet then
        self:RegisterForClicks('AnyUp')
        self:SetScript('OnEnter', UnitFrame_OnEnter)
        self:SetScript('OnLeave', UnitFrame_OnLeave)
        self.PetHealth = mnkLibs.createFontString(self, mnkLibs.Fonts.oswald, 18, nil, nil, true)
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
        self:SetSize(201, 20)
        self.HealthValue = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.HealthValue:SetPoint('LEFT', self.Health, 1, 0)
        self:Tag(self.HealthValue, '[mnku:status][mnku:perhp] [mnku:curhp]') 
        self.isResting = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.isResting:SetPoint('RIGHT', self.Health, 'RIGHT', 0, 0)
        self:Tag(self.isResting, '[|cFFFFFF00>resting<|r]')
        self.flagPVP = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagPVP:SetPoint('RIGHT', self.isResting, 'LEFT', 0, 0)
        self:Tag(self.flagPVP, '[|cffff0000>pvp<|r]') 
        self.flagAFK = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagAFK:SetPoint('RIGHT', self.flagPVP, 'LEFT', 0, 0)
        self.flagAFK:SetText(mnkLibs.Color(COLOR_BLUE)..'AFK')
        self.flagDND = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagDND:SetPoint('RIGHT', self.flagPVP, 'LEFT', 0, 0)
        self.flagDND:SetText(mnkLibs.Color(COLOR_BLUE)..'DND')
		self.flagCombat = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.flagCombat:SetPoint('LEFT', self.HealthValue, 'RIGHT', 1, 0)
        self.flagCombat:SetText('|cffff0000'..'×')
        self.flagCombat:Hide()
		
        SetPlayerStatusFlag(self)
        local t = {} 
        for i = 1, 10 do
            local f = CreateFrame('StatusBar', nil, self)
            f:SetStatusBarTexture(mnkLibs.Textures.combo_round)
            f:SetSize(16, 16)

            local n = mnkLibs.createFontString(f, mnkLibs.Fonts.oswald, 10, nil, nil, false)
            n:SetPoint('CENTER', f, 0, 0)
            n:SetText(i)
            n:SetTextColor(0, 0, 0)
            
            if (i == 1) then
                f:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -8)
            else
                f:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', ((f:GetWidth() + 2) * (i - 1)), -8)
            end
            
            t[i] = f
            f:Hide()
        end

        self.ClassPower = t
        self.Runes = t
	
        self.Power = CreateFrame('StatusBar', nil, self)
        self.Power:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        self.Power:SetSize(self:GetWidth(), 3)
        self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, 0)	
        self.Power.frequentUpdates = true
        self.Power.colorPower = true
		
        self.AdditionalPower = CreateFrame('StatusBar', nil, self)
        self.AdditionalPower:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        self.AdditionalPower:SetSize(self:GetWidth(), 3)
        self.AdditionalPower:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, 0)
        self.AdditionalPower.frequentUpdates = true
        self.AdditionalPower.colorPower = true

		self.AlternativePower = CreateFrame('StatusBar', nil, self)
        self.AlternativePower:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
        self.AlternativePower:SetSize(self:GetWidth()+2, 18)
        self.AlternativePower:SetPoint('LEFT', self, 'LEFT', -2, 0)
        self.AlternativePower:SetPoint('BOTTOM', self, 'TOP', 0, 50)	
		mnkLibs.setBackdrop(self.AlternativePower, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
        self.AlternativePower:SetBackdropColor(1, 1, 1, 1)
		self.AlternativePower:SetBackdropColor(1/8, 1/8, 1/8, 1)
        self.AlternativePower:SetFrameStrata('HIGH')
        self.AlternativePower:EnableMouse(true)
        mnkLibs.createBorder(self.AlternativePower, 1,-1,-1,1, {0, 0, 0, 1})

        self.Auras = CreateFrame('Frame', nil, self)
        --self.Auras.onlyShowPlayer = true
        self.Auras.disableCooldown = true
        self.Auras['growth-x'] = 'RIGHT'
        self.Auras['growth-y'] = 'UP'
        self.Auras.spacing = 4
        self.Auras.numTotal = 18
        self.Auras.size = 16
        self.Auras:SetPoint('LEFT', self, 'LEFT', -1, 0)
        self.Auras:SetPoint('BOTTOM', self, 'TOP', 0 , 5)
        self.Auras:SetSize(16*12, 34)
        self.Auras.PostCreateIcon = PostCreateIcon
        self.Auras.PostUpdateIcon = PostUpdateIcon   
    end
end

local function PartyUnit(self)
    if (self.unit == 'party' and Config.showparty) or (self.unit == 'raid' and Config.showraid) then
        CreateUnit(self)
        self.unitName = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18, nil, nil, true)
        self.unitName:SetPoint('LEFT', self.frameValues, 'LEFT', 3, 0)
        self.unitName:SetPoint('RIGHT', self.frameValues, 'RIGHT', -2, 0)
        self.unitName:SetJustifyH('LEFT')
        self:Tag(self.unitName, '[group]  [mnku:leader][raidcolor][name]')
        self.ResurrectIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.ResurrectIndicator:SetPoint('CENTER', self)
        self.ReadyCheckIndicator = self.frameValues:CreateTexture()
        self.ReadyCheckIndicator:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        self.ReadyCheckIndicator:SetSize(16, 16)
        self.GroupRoleIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.GroupRoleIndicator:SetPoint('RIGHT', self, 'RIGHT', -3, 0)
        self.GroupRoleIndicator:SetSize(16, 16)
        self.RaidRoleIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.RaidRoleIndicator:SetPoint('RIGHT', self.GroupRoleIndicator, 'RIGHT', 0, 0)
        self.RaidRoleIndicator:SetSize(16, 16)
        self.RaidRoleIndicator.PostUpdate = function(self, role) 
                                                if role then 
                                                    self:GetParent():GetParent().GroupRoleIndicator:SetAlpha(0) 
                                                else 
                                                    self:GetParent():GetParent().GroupRoleIndicator:SetAlpha(1) 
                                                end
                                            end
        self.RaidTargetIndicator = self.frameValues:CreateTexture(nil, 'OVERLAY')
        self.RaidTargetIndicator:SetPoint('LEFT', self.unitName, 'RIGHT', 5, 0)
        self.RaidTargetIndicator:SetSize(14, 14)
        self.HealthValue = mnkLibs.createFontString(self.frameValues, mnkLibs.Fonts.oswald, 18,  nil, nil, true)
        self.HealthValue:SetPoint('RIGHT', self.GroupRoleIndicator, 'LEFT', -3, 0)
        self:Tag(self.HealthValue, '[mnku:curhp]') 
    end
end

function mnkUnits.CreateUnits(self, unit)
    if not unit then return end
    if (unit == 'pet') then
        PetUnit(self)
    elseif (unit == 'player') then 
        PlayerUnit(self)
    elseif (unit == 'party') or (unit == 'raid') then 
        PartyUnit(self)
    elseif (unit == 'focus') or (unit == 'target') or (unit == 'targettarget') or unit:find('boss') or unit:find('arena') then
        MinimalUnit(self)
    end
end

--Based on code from Phanx, thanks Phanx!
local function UpdateMirrorBars()
    for i = 1, 3 do
        local barname = 'MirrorTimer'..i
        local bar = _G[barname]

        for _, region in pairs({ bar:GetRegions() }) do
            if region.GetTexture and region:GetTexture() == 'SolidTexture' then
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
        bar.bg:SetVertexColor(0, 0, 0, 1)
        bar.text:ClearAllPoints()
        bar.text:SetPoint('LEFT', bar, 4, 0)
        bar.text:SetFont(mnkLibs.Fonts.oswald, 18)
        bar.text:SetTextColor(1/3, 1/3, 1/3)
        bar.border:Hide()
        mnkLibs.createBorder(bar, 1,-1,-1,1, {1,1,1,1})
    end
end

local function SetPlayerCastbarVis(bool)
    if bool == false then
        oUF_mnkUnitsPlayer.castbarbg:SetAlpha(0)
    else
        oUF_mnkUnitsPlayer.castbarbg:SetAlpha(1)
    end
end

function mnkUnits:DoOnEvent(event, unit)
    if event == 'PLAYER_LOGIN' then
        LootWonAlertFrame_ShowAlert = mnkLibs.donothing()
	elseif event == 'PLAYER_REGEN_DISABLED' then
		SetPlayerStatusFlag(oUF_mnkUnitsPlayer, true)
	elseif event == 'PLAYER_REGEN_ENABLED' then
		SetPlayerStatusFlag(oUF_mnkUnitsPlayer, false)
	elseif event == 'PLAYER_ENTERING_WORLD' then
        BuffFrame:UnregisterEvent('UNIT_AURA')
        BuffFrame:Hide()
        TemporaryEnchantFrame:Hide()
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:Hide()
        CompactRaidFrameContainer:Hide()
        CreateBottomPanel()
        UpdateMirrorBars()		
		SetPlayerStatusFlag(oUF_mnkUnitsPlayer)
	elseif event == 'PLAYER_FLAGS_CHANGED' then
		SetPlayerStatusFlag(oUF_mnkUnitsPlayer)
    elseif event == "NAME_PLATE_UNIT_ADDED" then -- hide player castbar when the personal bar is visible, there is a castbar there.
        if UnitIsUnit(unit, "player") then
            SetPlayerCastbarVis(false)
        else
            SetPlayerCastbarVis(true)    
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        SetPlayerCastbarVis(true)
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

    --self:SpawnHeader('party', nil, 'custom [@raid2,exists][@raid3,exists][@raid6,exists][@raid26,exists] hide;show',
    self:SpawnHeader('party', nil, 'solo,party',
        'showParty', true, 
        'showPlayer', false,
        'showRaid', false,
        'yOffset', -3,
        'oUF-initialConfigFunction', [[ self:SetHeight(20) self:SetWidth(200) ]]
    ):SetPoint('TOPLEFT', 25, -50)
    self:SpawnHeader('raid', nil, 'raid',
        'showRaid', true,
        'showSolo', false,
        'showPlayer', true,
        'showParty', false,
        'yOffset', -3,
        'groupFilter', '1,2,3,4,5,6,7,8',
        'groupBy', 'ASSIGNEDROLE',
        'groupingOrder', 'MAINTANK, MAINASSIST, TANK, HEALER, DAMAGER, NONE',
        'maxColumns', 2,
        'unitsPerColumn', 40,
        'columnSpacing', 5,
        'point', 'TOP',
        'startingIndex',1,
        'columnAnchorPoint', 'LEFT',
        'oUF-initialConfigFunction', [[ self:SetHeight(20) self:SetWidth(200) ]]
    ):SetPoint('TOPLEFT', nil, 25, -150)

    for index = 1, MAX_BOSS_FRAMES or 5 do
        local boss = self:Spawn('boss'..index)
        local arena = self:Spawn('arena'..index)

        if (index == 1) then
            boss:SetPoint('TOPRIGHT', -50, -100)
            arena:SetPoint('TOPRIGHT', -50, -100)
        else
            boss:SetPoint('TOP', _G['oUF_mnkUnitsBoss'..index - 1], 'BOTTOM', 0, -6)
            arena:SetPoint('TOP', _G['oUF_mnkUnitsArena'..index - 1], 'BOTTOM', 0, -6)
        end
    end
end)

--change leaveVehicle Button to match my layout.
MainMenuBarVehicleLeaveButton:SetNormalTexture(mnkLibs.Textures.arrow_down)
MainMenuBarVehicleLeaveButton:SetPushedTexture(mnkLibs.Textures.arrow_down_pushed)

mnkUnits:SetScript('OnEvent', mnkUnits.DoOnEvent)
mnkUnits:RegisterEvent('PLAYER_LOGIN')
mnkUnits:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkUnits:RegisterEvent('PLAYER_FLAGS_CHANGED')
mnkUnits:RegisterEvent('NAME_PLATE_UNIT_ADDED')
mnkUnits:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
mnkUnits:RegisterEvent('PLAYER_REGEN_ENABLED')
mnkUnits:RegisterEvent('PLAYER_REGEN_DISABLED')


