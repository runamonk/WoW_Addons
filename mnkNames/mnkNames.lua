mnkNames = CreateFrame('Frame')

local cvars = {
    nameplateGlobalScale = .8, 
    NamePlateHorizontalScale = .8, 
    NamePlateVerticalScale = .8, 
    nameplateLargerScale = 1.5, 
    nameplateMaxScale = .8, 
    nameplateMinScale = .8, 
    nameplateSelectedScale = 1, 
    nameplateMaxAlpha = .4, 
    nameplateMaxAlphaDistance = 40, 
    nameplateMinAlpha = .4, 
    nameplateMinAlphaDistance = 0, 
    nameplateSelectedAlpha = 1
}

local cfg_name_width = 190
local cfg_name_height = 12
local cfg_frame_width = 200
local cfg_frame_height = 20
local cfg_font_height = 15

local cfg_debuffs_num = 6
local cfg_debuffs_rows = 1
local cfg_debuffs_size = 24
local cfg_debuffs_spacing = 1
local lastNameplate = nil

function mnkNames.CreateStyle(self, unit)
    self.disableMovement = true
    self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetAllPoints()
    self.Health:SetStatusBarTexture(mnkLibs.Textures.background)
    self.Health:GetStatusBarTexture():SetHorizTile(false)
    self.Health.colorHealth = true
    self.Health.colorClass = true
    self.Health.colorReaction = true
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.background = self.Health:CreateTexture(nil, 'BACKGROUND')
    self.Health.background:SetAllPoints(health)
    self.Health.background:SetAlpha(0.20)
    self.Health.background:SetTexture(mnkLibs.Textures.bar)
    self.Name = CreateFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, '')
    self.Name:SetPoint('CENTER', self.Health, 0, 0)
    self.Name:SetJustifyH('CENTER')
    self.Name:SetWidth(cfg_name_width)
    self:Tag(self.Name, '[mnknames:name]')
    self.Level = CreateFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, '')
    self.Level:SetPoint('LEFT', self.Health, -20, 0)
    self.Level:SetJustifyH('LEFT')
    self.Level:SetWidth(25)
    self.Level:SetHeight(25)
    self:Tag(self.Level, '[mnknames:level]')
    self.RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
    self.RaidTargetIndicator:SetPoint('LEFT', self, 'RIGHT', 8, 0)
    self.RaidTargetIndicator:SetSize(16, 16)
    self.Castbar = CreateFrame('StatusBar', nil, self)
    self.Castbar:SetStatusBarTexture(mnkLibs.Textures.bar)
    self.Castbar:GetStatusBarTexture():SetHorizTile(false)
    self.Castbar.background = self.Castbar:CreateTexture(nil, 'BORDER')
    self.Castbar.background:SetAllPoints()
    self.Castbar.background:SetAlpha(0.3)
    self.Castbar.background:SetTexture(mnkLibs.Textures.background)
    self.Castbar.background:SetColorTexture(1 / 3, 1 / 3, 1 / 3)
    SetBackdrop(self.Castbar, nil, 1, 1, 1, 1)
    self.Castbar:SetBackdropColor(0, 0, 0, 1)
    self.Castbar:SetStatusBarColor(1, 1, 1, 1)
    self.Castbar:SetWidth(cfg_frame_width)
    self.Castbar:SetHeight(cfg_frame_height)
    self.Castbar:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -5)
    self.Castbar.Text = self.Castbar:CreateFontString(nil, 'OVERLAY')
    self.Castbar.Text:SetTextColor(1, 1, 1)
    self.Castbar.Text:SetShadowOffset(1, -1)
    self.Castbar.Text:SetJustifyH('CENTER')
    self.Castbar.Text:SetHeight(cfg_font_height)
    self.Castbar.Text:SetFont(mnkLibs.Fonts.oswald, cfg_font_height, 'THINOUTLINE')
    self.Castbar.Text:SetWidth(cfg_name_width)
    self.Castbar.Text:SetPoint('CENTER', castbar, 0, 0)
    self.Debuffs = CreateFrame('Frame', nil, self)
    self.Debuffs:SetSize((cfg_debuffs_num * (cfg_debuffs_size + 9)) / cfg_debuffs_rows, (cfg_debuffs_size + 9) * cfg_debuffs_rows)
    self.Debuffs.num = cfg_debuffs_num
    self.Debuffs.size = cfg_debuffs_size
    self.Debuffs.spacing = cfg_debuffs_spacing
    self.Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 8)
    self.Debuffs.initialAnchor = 'BOTTOMLEFT'
    self.Debuffs['growth-x'] = 'RIGHT'
    self.Debuffs['growth-y'] = 'UP'
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.PostCreateIcon = mnkNames.PostCreateIcon
    self:SetSize(cfg_frame_width, cfg_frame_height)
    self:SetPoint('CENTER', 0, 0)
    self:SetScale(1)
    SetBackdrop(self, nil, 1, 1, 1, 1)
    CreateDropShadow(self, 1, 1, {0, 0, 0, 1})
end

function mnkNames.PostCreateIcon(Auras, button)
    button.count:ClearAllPoints()
    button.count:SetFont(mnkLibs.Fonts.oswald, 12, 'OUTLINE')
    button.count:SetPoint('TOPRIGHT', button, 3, 3)
    button.icon:SetTexCoord(.07, .93, .07, .93)
    button.overlay:SetTexture(mnkLibs.Textures.border)
    button.overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
end

function mnkNames.OnNameplatesCallback(self, event, unit)
    if (UnitExists('target') and UnitIsUnit('target', unit)) then
        if (lastNameplate ~= nil and lastNameplate ~= self) then
            lastNameplate:SetBackdropColor(0, 0, 0, 1)
        end
        self:SetBackdropColor(1, 1, 1, 1)
        lastNameplate = self
    else
        self:SetBackdropColor(0, 0, 0, 1)
    end
end

oUF:RegisterStyle('mnkNames', mnkNames.CreateStyle)
oUF:SetActiveStyle('mnkNames')
oUF:SpawnNamePlates('mnkNames', mnkNames.OnNameplatesCallback, cvars)
