-- Unit Style for oUF. Based on code by P3lim.
-- 
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1}}

local fontOswald = mnkLibs.Fonts.oswald
local font1l = CreateFont('font1l')
font1l:SetFont(fontOswald, 18, '')
font1l:SetShadowOffset(0, 0)
font1l:SetJustifyH('LEFT'); 

local font1r = CreateFont('font1r')
font1r:SetFont(fontOswald, 18, 'OUTLINE')
font1r:SetShadowOffset(0, 0)
font1r:SetJustifyH('RIGHT'); 

local font2l = CreateFont('font2l')
font2l:SetFont(fontOswald, 10, '')
font2l:SetShadowOffset(0, 0)
font2l:SetJustifyH('LEFT'); 

local font2c = CreateFont('font2c')
font2c:SetFont(fontOswald, 10, '')
font2c:SetShadowOffset(0, 0)
font2c:SetJustifyH('CENTER'); 

local function UpdateHealth(self, event, unit)
    if (not unit or self.unit ~= unit) then
        return
    end

    local element = self.Health
    element:SetShown(UnitIsConnected(unit))

    if (element:IsShown()) then
        local cur = UnitHealth(unit)
        local max = UnitHealthMax(unit)
        element:SetMinMaxValues(0, max)
        element:SetValue(max - cur)
    end
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

local UnitSpecific = {
    player = function(self)
        local PetHealth = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1r')
        PetHealth:SetPoint('RIGHT', self.HealthValue, 'LEFT', 0, 1)
        PetHealth.overrideUnit = 'pet'
        self:CustomTag(PetHealth, '[mnku:pethp]')

        local resting = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1r')
        resting:SetPoint('LEFT', self, 'TOPLEFT', -25, -11)
        self:Tag(resting, '[|cFFFFFF00>resting<|r]')

        local classcombo = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1r')
        classcombo:SetPoint('LEFT', self, 'TOPLEFT', -25, -11)
        self:Tag(classcombo, '[|cFFFFFFFF>cpoints<|r]')

        local HealthValue = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        HealthValue:SetPoint('LEFT', self.Health, 2, 1)
        self:Tag(HealthValue, '[mnku:status][mnku:perhp] [mnku:curhp]')
        self:SetWidth(230)

        local incombat = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        incombat:SetPoint('LEFT', HealthValue, 'RIGHT', 1, 0)
        self:CustomTag(incombat, '[|cffff0000>mnku:combat<|r]')

        local pvp = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        pvp:SetPoint('LEFT', incombat, 'RIGHT', 1, 0)
        self:Tag(pvp, '[|cffff0000>pvp<|r]')

        local Power = CreateFrame('StatusBar', nil, self.Health)
        Power:SetPoint('BOTTOMRIGHT')
        Power:SetPoint('BOTTOMLEFT')
        Power:SetHeight(2)
        Power:SetStatusBarTexture(TEXTURE)
        Power.frequentUpdates = true
        Power.colorPower = false
        Power.colorClass = true
        Power.colorTapping = false
        Power.colorDisconnected = false
        Power.colorReaction = false
        self.Power = Power
    end, 
    target = function(self)
        local Name = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        Name:SetPoint('LEFT', self.Health, 2, 0)
        Name:SetPoint('RIGHT', self.HealthValue, 'LEFT')
        Name:SetWordWrap(false)
        self:Tag(Name, '[mnku:name]')

        local lvl = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1r')
        lvl:SetPoint('LEFT', self, 'TOPLEFT', -25, -10)
        self:Tag(lvl, '[|cFFFFFF00>level<|r]')

        local resting = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font2l')
        resting:SetPoint('LEFT', self, 'TOPLEFT', 2, 2)
        self:Tag(resting, '[|cFFFFFF00>resting<|r]')

        local HealthValue = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1r')
        HealthValue:SetPoint('RIGHT', self.Health, -2, 0)
        HealthValue:SetWordWrap(false)
        self:Tag(HealthValue, '[mnku:curhp]')
        self.Castbar.PostCastStart = PostUpdateCast
        self.Castbar.PostCastInterruptible = PostUpdateCast
        self.Castbar.PostCastNotInterruptible = PostUpdateCast
        self.Castbar.PostChannelStart = PostUpdateCast
        
        self:SetWidth(230)
    end, 
    party = function(self)
        local Name = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        Name:SetPoint('LEFT', self.Health, 3, 0)
        Name:SetPoint('RIGHT', self.HealthValue, 'LEFT')
        Name:SetJustifyH('LEFT')
        Name:SetWordWrap(false)
        self:Tag(Name, '[mnku:leader][raidcolor][name]')

        local Resurrect = self.StringParent:CreateTexture(nil, 'OVERLAY')
        Resurrect:SetPoint('CENTER', self)
        Resurrect:SetSize(16, 16)
        self.ResurrectIndicator = Resurrect

        local ReadyCheck = self:CreateTexture()
        ReadyCheck:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        ReadyCheck:SetSize(14, 14)
        self.ReadyCheckIndicator = ReadyCheck

        local RoleIcon = self:CreateTexture(nil, 'OVERLAY')
        RoleIcon:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        RoleIcon:SetSize(14, 14)
        RoleIcon:SetAlpha(0)
        self.GroupRoleIndicator = RoleIcon

        self:HookScript('OnEnter', function() RoleIcon:SetAlpha(1) end)
        self:HookScript('OnLeave', function() RoleIcon:SetAlpha(0) end)
        self:Tag(self.HealthValue, '[mnku:status][mnku:perhp<|cff0090ff|r]')
    end, 
    boss = function(self)
        self:Tag(self.HealthValue, '[mnku:perhp<|cff0090ff|r]')
    end, 
    arena = function(self)
        local Name = self.StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        Name:SetPoint('LEFT', self.Health, 3, 0)
        Name:SetPoint('RIGHT', self.HealthValue, 'LEFT')
        Name:SetJustifyH('LEFT')
        Name:SetWordWrap(false)
        self:Tag(Name, '[raidcolor][name]')
    end
}
UnitSpecific.raid = UnitSpecific.party

local function Shared(self, unit)
    unit = unit:match('^(.-)%d+') or unit
    self:RegisterForClicks('AnyUp')
    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    self:SetBackdrop(BACKDROP)
    self:SetBackdropColor(0, 0, 0)

    local Health = CreateFrame('StatusBar', nil, self)
    Health:SetStatusBarTexture(TEXTURE)
    Health:SetStatusBarColor(1 / 3, 1 / 3, 1 / 3)
    Health:SetReverseFill(true)
    Health.Override = UpdateHealth
    Health.frequentUpdates = true
    self.Health = Health

    local HealthBG = self:CreateTexture(nil, 'BORDER')
    HealthBG:SetAllPoints(Health)
    HealthBG:SetColorTexture(0, 0, 0)

    local StringParent = CreateFrame('Frame', nil, self)
    StringParent:SetFrameLevel(20)
    self.StringParent = StringParent

    local HealthValue = StringParent:CreateFontString(nil, 'OVERLAY', 'font1r')
    HealthValue:SetPoint('RIGHT', Health, -2, 0)
    self.HealthValue = HealthValue

    if (unit == 'player' or unit == 'target') then
        Health:SetHeight(20) 
        local Castbar = CreateFrame('StatusBar', nil, self)
        Castbar:SetAllPoints(Health)
        Castbar:SetStatusBarTexture(TEXTURE)
        Castbar:SetStatusBarColor(0, 0, 0, 0)
        Castbar:SetFrameStrata('HIGH')
        self.Castbar = Castbar
        local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
        Spark:SetSize(1, Health:GetHeight())
        Spark:SetColorTexture(1, 0, 0)
        Castbar.Spark = Spark
        Health:SetPoint('TOPRIGHT')
        Health:SetPoint('TOPLEFT')
    else
        Health:SetAllPoints()
    end

    if (unit == 'focus' or unit == 'targettarget' or unit == 'boss') then
        local Name = StringParent:CreateFontString(nil, 'OVERLAY', 'font1l')
        Name:SetPoint('LEFT', Health, 2, 0)
        Name:SetPoint('RIGHT', HealthValue, 'LEFT')
        Name:SetWordWrap(false)
        self:Tag(Name, '[mnku:color][name]')
    else
        local RaidTarget = StringParent:CreateTexture(nil, 'OVERLAY')
        RaidTarget:SetPoint('TOP', self, 0, 8)
        RaidTarget:SetSize(16, 16)
        self.RaidTargetIndicator = RaidTarget
        local Threat = CreateFrame('Frame', nil, self)
        Threat:SetPoint('TOPRIGHT', 2, 2)
        Threat:SetPoint('BOTTOMLEFT', -2, -2)
        Threat:SetFrameStrata('BACKGROUND')
        SetBackdrop(Threat, mnkLibs.Textures.border, 0, 0, 0, 0)
        Threat.Override = UpdateThreat
        self.ThreatIndicator = Threat
    end
    
    self:SetSize(161, 20)

    if (UnitSpecific[unit]) then
        return UnitSpecific[unit](self)
    end
end

oUF:RegisterStyle('mnku', Shared)
oUF:Factory(function(self)
    self:SetActiveStyle('mnku')
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
    ):SetPoint('TOP', Minimap, 'BOTTOM', 0, -10)

    for index = 1, 5 do
        local boss = self:Spawn('boss' .. index)
        local arena = self:Spawn('arena' .. index)

        if (index == 1) then
            boss:SetPoint('TOP', oUF_mnkuRaid, 'BOTTOM', 0, -20)
            arena:SetPoint('TOP', oUF_mnkuRaid, 'BOTTOM', 0, -20)
        else
            boss:SetPoint('TOP', _G['oUF_mnkuBoss' .. index - 1], 'BOTTOM', 0, -6)
            arena:SetPoint('TOP', _G['oUF_mnkuArena' .. index - 1], 'BOTTOM', 0, -6)
        end
    end
end)
