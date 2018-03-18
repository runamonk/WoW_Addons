mnkNames = CreateFrame("Frame")

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
    local health = CreateFrame("StatusBar", nil, self)
    health:SetAllPoints()
    health:SetStatusBarTexture(mnkLibs.Textures.background)
    health:GetStatusBarTexture():SetHorizTile(false)
    health.colorHealth = true
    health.colorClass = true
    health.colorReaction = true
    health.colorTapping = true
    health.colorDisconnected = true
    health.bg = health:CreateTexture(nil, "BACKGROUND")
    health.bg:SetAllPoints(health)
    health.bg:SetAlpha(0.20)
    health.bg:SetTexture(mnkLibs.Textures.bar)
    self.Health = health
    self.Name = CreateFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, "")
    self.Name:SetPoint("CENTER", self.Health, 0, 0)
    self.Name:SetJustifyH("CENTER")
    self.Name:SetWidth(cfg_name_width)
    self:Tag(self.Name, '[mnknames:name]')
    self.Level = CreateFontString(self.Health, mnkLibs.Fonts.oswald, cfg_font_height, "")
    self.Level:SetPoint("LEFT", self.Health, -20, 0)
    self.Level:SetJustifyH("LEFT")
    self.Level:SetWidth(25)
    self.Level:SetHeight(25)
    self:Tag(self.Level, '[mnknames:level]')
    local RaidIcon = self:CreateTexture(nil, 'OVERLAY')
    RaidIcon:SetPoint('LEFT', self, 'RIGHT', 8, 0)
    RaidIcon:SetSize(16, 16)
    self.RaidTargetIndicator = RaidIcon
    local castbar = CreateFrame("StatusBar", nil, self)
    castbar:SetStatusBarTexture(mnkLibs.Textures.bar)
    castbar:GetStatusBarTexture():SetHorizTile(false)
    castbar.bg = castbar:CreateTexture(nil, 'BORDER')
    castbar.bg:SetAllPoints()
    castbar.bg:SetAlpha(0.3)
    castbar.bg:SetTexture(mnkLibs.Textures.background)
    castbar.bg:SetColorTexture(1 / 3, 1 / 3, 1 / 3)
    SetBackdrop(castbar, 1, 1, 1, 1)
    castbar:SetBackdropColor(0, 0, 0, 1)
    castbar:SetStatusBarColor(1, 1, 1, 1)
    castbar:SetWidth(cfg_frame_width)
    castbar:SetHeight(cfg_frame_height)
    castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
    castbar.Text = castbar:CreateFontString(nil, "OVERLAY")
    castbar.Text:SetTextColor(1, 1, 1)
    castbar.Text:SetShadowOffset(1, -1)
    castbar.Text:SetJustifyH("CENTER")
    castbar.Text:SetHeight(cfg_font_height)
    castbar.Text:SetFont(mnkLibs.Fonts.oswald, cfg_font_height, "THINOUTLINE")
    castbar.Text:SetWidth(cfg_name_width)
    castbar.Text:SetPoint("CENTER", castbar, 0, 0)
    self.Castbar = castbar
    local debuffs = CreateFrame("Frame", nil, self)
    debuffs:SetSize((cfg_debuffs_num * (cfg_debuffs_size + 9)) / cfg_debuffs_rows, (cfg_debuffs_size + 9) * cfg_debuffs_rows)
    debuffs.num = cfg_debuffs_num
    debuffs.size = cfg_debuffs_size
    debuffs.spacing = cfg_debuffs_spacing
    debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8)
    debuffs.initialAnchor = "BOTTOMLEFT"
    debuffs["growth-x"] = "RIGHT"
    debuffs['growth-y'] = "UP"
    debuffs.onlyShowPlayer = true
    debuffs.PostCreateIcon = mnkNames.PostCreateIcon
    self.Debuffs = debuffs
    self:SetSize(cfg_frame_width, cfg_frame_height)
    self:SetPoint("CENTER", 0, 0)
    self:SetScale(1)
    SetBackdrop(self, 1, 1, 1, 1)
    CreateDropShadow(self, 1, 1, {0, 0, 0, 1})
end

function mnkNames.PostCreateIcon(Auras, button)
    local count = button.count
    count:ClearAllPoints()
    count:SetFont(mnkLibs.Fonts.oswald, 12, 'OUTLINE')
    count:SetPoint('TOPRIGHT', button, 3, 3)
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

oUF:RegisterStyle("mnkNames", mnkNames.CreateStyle)
oUF:SetActiveStyle("mnkNames")
oUF:SpawnNamePlates("mnkNames", mnkNames.OnNameplatesCallback, cvars)
