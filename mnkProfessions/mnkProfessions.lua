mnkProfessions = CreateFrame('Frame', nil, UIParent, BackdropTemplate)
mnkProfessions.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkProfessions:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

mnkProfessions:RegisterEvent('PLAYER_LOGIN')
mnkProfessions:RegisterEvent('CHAT_MSG_SKILL')
mnkProfessions:RegisterEvent('SKILL_LINES_CHANGED')

local libQTip = LibStub('LibQTip-1.0')
local SPACER = '       '
local t = {}

function mnkProfessions:CHAT_MSG_SKILL(event, arg)
    CombatText_AddMessage(arg, CombatText_StandardScroll, 255, 255, 255, nil, false)
end

function mnkProfessions:OnClick(self)
    ToggleSpellBook(BOOKTYPE_PROFESSION)
end

function mnkProfessions:OnEnter(parent) 
    local tooltip = libQTip:Acquire('mnkProfessionsTooltip', 3, 'LEFT', 'LEFT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    
    local prof1, prof2, prof3, prof4, prof5 = GetProfessions()

    local function AddProfLine(p)
        if p then
            local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(p)
            icon = icon..':16:16:0:0:64:64:4:60:4:60'
            tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
        end
    end

    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Profession', SPACER, mnkLibs.Color(COLOR_GOLD)..'Level')

    local prof1, prof2, prof3, prof4, prof5 = GetProfessions()
    AddProfLine(prof1)
    AddProfLine(prof2)
    AddProfLine(prof3)
    AddProfLine(prof4)
    AddProfLine(prof5)

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    --tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    --mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    --tooltip:SetBackdropColor(0, 0, 0, 1) 
    tooltip:EnableMouse(true)   
    tooltip:Show()
end

function mnkProfessions:PLAYER_LOGIN()
    mnkProfessions.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkProfessions', {
        type = 'data source', 
        icon = '', 
        OnClick = function() self:OnClick() end, 
        OnEnter = function(parent) self:OnEnter(parent) end
    })
    self.LDB.label = 'Professions'
    self.LDB.text = self:UpdateText()
end

function mnkProfessions:SKILL_LINES_CHANGED()
    self.LDB.text = self:UpdateText()
end

function mnkProfessions:UpdateText()
    local s1 = ""
    local s2 = ""
    local prof1, prof2, prof3, prof4, prof5 = GetProfessions()
    
    local function GetProfText(p)
        if p ~= nil then
            local _, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(p)
            icon = icon..':16:16:0:0:64:64:4:60:4:60'
            if skillLevel == maxSkillLevel then
                return string.format('|T%s|t', icon) ..' '..mnkLibs.Color(COLOR_GOLD)..maxSkillLevel
            else 
                return string.format('|T%s|t', icon) ..' '..mnkLibs.Color(COLOR_GOLD)..skillLevel..mnkLibs.Color(COLOR_WHITE)..'/'..mnkLibs.Color(COLOR_GOLD)..maxSkillLevel
            end
        else
            return ''
        end
    end

    local function AddProfText(p)
        if not p then return end

        if s1 == "" and p then
            s1 = GetProfText(p)
        elseif s1 ~= "" and s2 == "" and p then
            s2 = GetProfText(p)
        end
    end

    AddProfText(prof1)
    AddProfText(prof2)
    AddProfText(prof3)
    AddProfText(prof4)
    AddProfText(prof5)
   
   --print(s1, s2)
    if s1 ~= "" and s2 ~= "" then
        return s1..' '..s2
    elseif s1 ~= "" then
        return s1
    else
        return 'n/a'
    end
end
