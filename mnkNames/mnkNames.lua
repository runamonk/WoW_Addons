mnkNames = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
mnkNames.oUF = oUF or ns.oUF
--Tags are in mnkLibs\mnkuTags
local playerGuildNameNull = "mnkNamesNoGuildName"

local _, playerClass = UnitClass('player')
local playerGuildName = playerGuildNameNull

local classColor = {}
local _
classColor.r, classColor.g, classColor.b, _ = GetClassColor(playerClass)

local cvars = {
    nameplateGlobalScale = .8, 
    --NamePlateHorizontalScale = .6, 
    NamePlateVerticalScale = 1, 
    nameplateLargerScale = 1, 
    nameplateMaxScale = 1, 
    nameplateMinScale = .6, 
    nameplateSelectedScale = 1, 
    nameplateMaxAlpha = .3, 
    nameplateMaxAlphaDistance = 4, 
    nameplateMinAlpha = .3, 
    nameplateMinAlphaDistance = 4, 
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
local addonScale = 1

local function UpdateThreat(self, event, unit)
    local _, _, threatpct, _, _ = UnitDetailedThreatSituation("player", unit)
    local s
    if threatpct and threatpct >= 1 then
        --print(self.unit, ' ', unit, ' ', threatpct,  ' ', rawthreatpct,  ' ', threatvalue)

        if threatpct <= 20 then
            s = "."
        elseif threatpct <= 40 then
            s = ".."
        elseif threatpct <= 60 then
            s = "..."
        elseif threatpct <= 80 then
            s = "...."
        else
            s = "....."
        end
    else
        s = ""
    end
    self.ThreatText:SetText(mnkLibs.Color(COLOR_WHITE)..s)
end

function mnkNames.CreateStyle(self, unit)

    if not self.SetBackdrop then
         Mixin(self, BackdropTemplateMixin)
    end
    self:SetScale(addonScale)

    self.disableMovement = true
    self.Health = CreateFrame("StatusBar", nil, self, BackdropTemplateMixin and "BackdropTemplate")
    self.Health:SetAllPoints()
    self.Health:SetStatusBarTexture(mnkLibs.Textures.background)
    self.Health:GetStatusBarTexture():SetHorizTile(false)
    self.Health.colorHealth = false
    self.Health.colorClass = false
    self.Health.colorReaction = false
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
    
    self.ThreatText = mnkLibs.createFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, nil, nil, true)
    self.ThreatText:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, 4)
    self.ThreatText:SetJustifyH("LEFT")
    self.ThreatText:SetWidth(self.Name:GetWidth())
    self.ThreatText:SetHeight(3)

    self.Level = mnkLibs.createFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, nil, nil, true)
    self.Level:SetPoint("LEFT", self.Health, -20, 0)
    self.Level:SetJustifyH("LEFT")
    self.Level:SetWidth(25)
    self.Level:SetHeight(25)
    self:Tag(self.Level, '[mnku:level]')
    self.RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
    self.RaidTargetIndicator:SetPoint('LEFT', self, 'RIGHT', 8, 0)
    self.RaidTargetIndicator:SetSize(16, 16)
    self.Castbar = CreateFrame("StatusBar", nil, self, BackdropTemplateMixin and "BackdropTemplate")
    self.Castbar:SetStatusBarTexture(mnkLibs.Textures.bar)
    self.Castbar:GetStatusBarTexture():SetHorizTile(false)
    self.Castbar.bg = self.Castbar:CreateTexture(nil, 'BORDER')
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetAlpha(0.3)
    self.Castbar.bg:SetTexture(mnkLibs.Textures.background)
    self.Castbar.bg:SetColorTexture(1 / 3, 1 / 3, 1 / 3)
    mnkLibs.setBackdrop(self.Castbar, nil, nil, .8, .8, .8, .8)
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
    mnkLibs.setBackdrop(self, nil, nil, .8, .8, .8, .8)
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", UpdateThreat)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", UpdateThreat)    
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
    mnkLibs.createBorder(button, 0.8, -0.8, -0.8, 0.8, {0,0,0,1})
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
        local guildName = nil
        if UnitIsPlayer(self.unit) == true then
            guildName, _, _ = GetGuildInfo(self.unit);
        end

        if UnitIsPlayer(self.unit) == true and (guildName ~= playerGuildName) then
            --print(UnitName(self.unit), ' ', guildName)
            self:Hide()
        else
            self:Show()
            local s = UnitClassification(self.unit)
            UpdateThreat(self, nil, self.unit)
           
            if s == 'rare' or s == 'rareelite' or s == 'worldboss' then
                self.Health:SetStatusBarColor(0.5, 0.3, 1, 1)
            else
                local i = UnitReaction(self.unit, 'player')
                
                if i and i <= 3 then
                    self.Health:SetStatusBarColor(1, 0, 0, 1) 
                elseif i and i > 5 then
                    self.Health:SetStatusBarColor(0, 1, 0, 1)
                else 
                    self.Health:SetStatusBarColor(0.7, 0.7, 0, 1)
                end
            end

    		if (UnitExists('target') and UnitIsUnit('target', self.unit)) then
    			if (lastNameplate ~= nil and lastNameplate ~= self) then
                    lastNameplate:SetBackdropColor(0, 0, 0, 1)                 
    			end
    			self:SetBackdropColor(1, 1, 1, 1)
    			lastNameplate = self
    		else
    			self:SetBackdropColor(0, 0, 0, 1)
    		end

            if UnitIsPlayer(self.unit) == true and (guildName == playerGuildName) then
                self.Health:SetStatusBarColor(.1, 1, .1, 1)
            end
        end  		
	end
end

local function SetMyGuild()
    playerGuildName, _, _ = GetGuildInfo("player") or playerGuildNameNull 
end

function mnkNames:PLAYER_ENTERING_WORLD(event, firstTime)
    if firstTime then
        addonScale = mnkLibs.GetUIScale()
    end
end

function mnkNames:PLAYER_GUILD_UPDATE()
    SetMyGuild()
end 

function mnkNames:PLAYER_LOGIN()
    SetMyGuild()
end 

mnkNames.oUF:RegisterStyle("mnkNames", mnkNames.CreateStyle)
mnkNames.oUF:SetActiveStyle("mnkNames")
mnkNames.oUF:SpawnNamePlates("mnkNames", mnkNames.OnNameplatesCallback, cvars)

mnkNames:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkNames:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkNames:RegisterEvent('PLAYER_GUILD_UPDATE')
mnkNames:RegisterEvent('PLAYER_LOGIN')


