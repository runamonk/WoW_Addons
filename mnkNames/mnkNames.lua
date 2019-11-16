mnkNames = CreateFrame("Frame")
mnkNames.oUF = oUF or ns.oUF
--Tags are in mnkLibs\mnkuTags

local cvars = {
    nameplateGlobalScale = .8, 
    NamePlateHorizontalScale = .8, 
    NamePlateVerticalScale = .8, 
    nameplateLargerScale = .8, 
    nameplateMaxScale = .8, 
    nameplateMinScale = .8, 
    nameplateSelectedScale = 1, 
    nameplateMaxAlpha = .4, 
    nameplateMaxAlphaDistance = 90, 
    nameplateMinAlpha = .4, 
    nameplateMinAlphaDistance = 0, 
    nameplateSelectedAlpha = 1,
	nameplatePersonalShowAlways = 0
}

local cfg_name_width = 190
local cfg_name_height = 12
local cfg_frame_width = 200
local cfg_frame_height = 20
local cfg_font_height = 15

local cfg_debuffs_num = 6
local cfg_debuffs_rows = 1
local cfg_debuffs_size = 24
local cfg_debuffs_spacing = 5
local lastNameplate = nil

function mnkNames.CreateStyle(self, unit)
    self.disableMovement = true
    self.frameValues = CreateFrame('Frame', nil, self)
    self.frameValues:SetFrameLevel(self:GetFrameLevel()+50)
    self.frameValues:SetSize(self:GetSize())
    self.frameValues:SetAllPoints()
	
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetAllPoints()
    self.Health:SetStatusBarTexture(mnkLibs.Textures.background)
    self.Health:GetStatusBarTexture():SetHorizTile(false)
    self.Health.colorHealth = true
    self.Health.colorClass = true
    self.Health.colorReaction = true
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.frequentUpdates = true
	self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg:SetAlpha(0.20)
    self.Health.bg:SetTexture(mnkLibs.Textures.bar)
    self.HealthValue = mnkLibs.createFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, nil, nil, true)
    self.HealthValue:SetPoint('RIGHT', self.Health, -2, 0)
    self.HealthValue:SetWordWrap(false)
	self:Tag(self.HealthValue, '[mnku:curhp]')
    
	self.Name = mnkLibs.createFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, nil, nil, true)
    self.Name:SetWordWrap(false)
    self.Name:SetPoint("LEFT", self.Health, 4, 0)
    self.Name:SetJustifyH("LEFT")
    self.Name:SetWidth(cfg_name_width-(self.HealthValue:GetWidth()+8))
    self:Tag(self.Name, '[mnku:name]')
	
	
	
    self.Level = mnkLibs.createFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, nil, nil, true)
    self.Level:SetPoint("LEFT", self.Health, -20, 0)
    self.Level:SetJustifyH("LEFT")
    self.Level:SetWidth(25)
    self.Level:SetHeight(25)
    self:Tag(self.Level, '[mnku:level]')
    self.RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
    self.RaidTargetIndicator:SetPoint('LEFT', self, 'RIGHT', 8, 0)
    self.RaidTargetIndicator:SetSize(16, 16)
    self.Castbar = CreateFrame("StatusBar", nil, self)
    self.Castbar:SetStatusBarTexture(mnkLibs.Textures.bar)
    self.Castbar:GetStatusBarTexture():SetHorizTile(false)
    self.Castbar.bg = self.Castbar:CreateTexture(nil, 'BORDER')
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetAlpha(0.3)
    self.Castbar.bg:SetTexture(mnkLibs.Textures.background)
    self.Castbar.bg:SetColorTexture(1 / 3, 1 / 3, 1 / 3)
    mnkLibs.setBackdrop(self.Castbar, nil, nil, 1, 1, 1, 1)
    self.Castbar:SetBackdropColor(0, 0, 0, 1)
    self.Castbar:SetStatusBarColor(1, 1, 1, 1)
    self.Castbar:SetWidth(cfg_frame_width)
    self.Castbar:SetHeight(cfg_frame_height)
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
    self.Castbar.Text = mnkLibs.createFontString(self.Castbar, mnkLibs.Fonts.oswald, cfg_font_height, nil, nil, true)
    self.Castbar.Text:SetHeight(cfg_font_height)
    self.Castbar.Text:SetWidth(cfg_name_width)
    self.Castbar.Text:SetPoint("CENTER", self.Castbar, 0, 0)
    self.Castbar.PostCastInterruptible = mnkNames.CastbarSpellUpdate
    self.Castbar.PostCastStart = mnkNames.CastbarSpellUpdate
    self.Castbar.PostCastNotInterruptible = mnkNames.CastbarSpellUpdate
    self.Castbar.PostCastStart = mnkNames.CastbarSpellUpdate
    self.Castbar.PostChannelStart = mnkNames.CastbarSpellUpdate

    self.Debuffs = CreateFrame("Frame", nil, self)
    self.Debuffs:SetSize((cfg_debuffs_num * (cfg_debuffs_size + 9)) / cfg_debuffs_rows, (cfg_debuffs_size + 9) * cfg_debuffs_rows)
    self.Debuffs.num = cfg_debuffs_num
    self.Debuffs.size = cfg_debuffs_size
    self.Debuffs.spacing = cfg_debuffs_spacing
    self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8)
    self.Debuffs.initialAnchor = "BOTTOMLEFT"
    self.Debuffs["growth-x"] = "RIGHT"
    self.Debuffs['growth-y'] = "UP"
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.disableCooldown = true
    self.Debuffs.PostCreateIcon = mnkNames.PostCreateIcon
    self.Debuffs.PostUpdateIcon = mnkNames.PostUpdateIcon
    self:SetSize(cfg_frame_width, cfg_frame_height)
    self:SetPoint("CENTER", 0, 0)
    self:SetScale(1)
    mnkLibs.setBackdrop(self, nil, nil, 1, 1, 1, 1)
end

function mnkNames.CastbarSpellUpdate(element, unit)
    if (not element.notInterruptible and UnitCanAttack('player', unit)) and (not UnitIsTapDenied(unit)) then
        element:SetStatusBarColor(0, 1, 0, 1)
    else
        element:SetStatusBarColor(1/2, 0, 0, 1)
    end
end

function mnkNames.timer_OnUpdate(button, elapsed)
	if button.timercount then
		button.timercount = max(button.timercount - elapsed, 0)
		if button.timercount > 0 and button.timercount ~= math.huge then
            button.timer:SetFormattedText("%.0f", button.timercount)
            if button.timercount <= 3 then
                button.border:SetBackdropBorderColor(1,0,0,1)
            else
                button.border:SetBackdropBorderColor(0,0,0,1)
            end
        else
			button.timer:SetText()
		end
	end
end

function mnkNames.PostCreateIcon(Auras, button)
    button.count = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 12,  nil, nil, true)
    button.count:ClearAllPoints()
    button.count:SetPoint('TOPRIGHT', button, 0, 0)
    button.timer = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 16,  nil, nil, true)
    button.timer:ClearAllPoints()
    button.timer:SetPoint('BOTTOMLEFT', button, 0, 0)
    button.timer:SetTextColor(1, 1, 1)
    button.icon:SetTexCoord(.07, .93, .07, .93)
    mnkLibs.createBorder(button, 1,-1,-1,1, {0,0,0,1})
end

function mnkNames.PostUpdateIcon(element, unit, button, index)
    local _, _, _, _, duration, expirationTime = UnitAura(unit, index, button.filter)

    if duration and duration > 0 then
        button.timercount = expirationTime - GetTime()
    else
        button.timercount = math.huge
    end

    button:SetScript('OnUpdate', function(self, elapsed) mnkNames.timer_OnUpdate(self, elapsed) end)
end

function mnkNames.OnNameplatesCallback(self)
	if not self then
		if lastNameplate then
			lastNameplate:SetBackdropColor(0, 0, 0, 1)
		end
	else
		if (UnitExists('target') and UnitIsUnit('target', self.unit)) then
			if (lastNameplate ~= nil and lastNameplate ~= self) then
				lastNameplate:SetBackdropColor(0, 0, 0, 1)
			end
			self:SetBackdropColor(1, 1, 1, 1)
			lastNameplate = self
		else
			self:SetBackdropColor(0, 0, 0, 1)
		end  		
	end
end

function mnkNames.DoOnEvent(self, event, unit, frame)
    -- Hide the default castbar when the personal bar is visible. 
    if event == 'NAME_PLATE_UNIT_ADDED' and UnitIsUnit(unit, "player") then
        mnkNames.SetCastbarVis(false)
    elseif event == 'NAME_PLATE_UNIT_REMOVED' and UnitIsUnit(unit, "player")  then
        mnkNames.SetCastbarVis(true)
    end    
end

function mnkNames.SetCastbarVis(bool)
    if bool == false then
        CastingBarFrame.Show = CastingBarFrame.Hide
        CastingBarFrame:Hide()
    else
       CastingBarFrame.Show = nil     
    end
end


mnkNames.oUF:RegisterStyle("mnkNames", mnkNames.CreateStyle)
mnkNames.oUF:SetActiveStyle("mnkNames")
mnkNames.oUF:SpawnNamePlates("mnkNames", mnkNames.OnNameplatesCallback, cvars)

mnkNames:SetScript('OnEvent', mnkNames.DoOnEvent)
mnkNames:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkNames:RegisterEvent('NAME_PLATE_UNIT_ADDED')
mnkNames:RegisterEvent('NAME_PLATE_UNIT_REMOVED')