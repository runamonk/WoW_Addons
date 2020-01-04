mnkProfessions = CreateFrame('Frame')
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

function mnkProfessions:GetProfText(p)
    if p ~= nil then
        local _, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(p)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        if skillLevel == maxSkillLevel then
            return string.format('|T%s|t', icon) ..' '..mnkLibs.Color(COLOR_WHITE)..maxSkillLevel
        else 
            return string.format('|T%s|t', icon) ..' '..mnkLibs.Color(COLOR_WHITE)..skillLevel..'/'..maxSkillLevel
        end
    else
        return ''
    end
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
    
    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Profession', SPACER, mnkLibs.Color(COLOR_GOLD)..'Level')

    local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()

    if prof1 ~= nil then
        local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(prof1)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        
        tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
    end

    if prof2 ~= nil then
        local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(prof2)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
    end

    if archaeology ~= nil then
        local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(archaeology)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
    end

    if fishing ~= nil then
        local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(fishing)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
    end 
    
    if cooking ~= nil then
        local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(cooking)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
    end 

    if firstAid ~= nil then
        local name, icon, skillLevel, maxSkillLevel, _, _, _, _, _, _ = GetProfessionInfo(firstAid)
        icon = icon..':16:16:0:0:64:64:4:60:4:60'
        tooltip:AddLine(string.format('|T%s|t %s', icon, name), SPACER, skillLevel..'/'..maxSkillLevel)
    end 

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    -- tooltip:SetBackdrop(GameTooltip:GetBackdrop())
    -- tooltip:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
    -- tooltip:SetBackdropColor(GameTooltip:GetBackdropColor())
    -- tooltip:SetScale(GameTooltip:GetScale())
    mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    tooltip:SetBackdropColor(0, 0, 0, 1) 
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
    self:UpdateText()
end

function mnkProfessions:UpdateText()
    local prof1, prof2, prof3, prof4, prof5, prof6 = GetProfessions()
    
    local s1 = ''
    local s2 = ''

    if prof1 ~= nil then
        s1 = mnkProfessions:GetProfText(prof1)
    end

    if prof2 ~= nil then
        if s1 == '' then
            s1 = mnkProfessions:GetProfText(prof2)
        else
            s2 = mnkProfessions:GetProfText(prof2)
        end
    end

    if (s2 == '') and (prof3 ~= '' or prof4 ~= '' or prof5 ~= '' or prof6 ~= '') then
        if prof3 ~= nil then
            if s1 == '' then
                s1 = mnkProfessions:GetProfText(prof3)
            elseif s2 == '' then
                s2 = mnkProfessions:GetProfText(prof3)
            end
        end
        
        if prof4 ~= nil then
            if s1 == '' then
                s1 = mnkProfessions:GetProfText(prof4)
            elseif s2 == '' then
                s2 = mnkProfessions:GetProfText(prof4)
            end
        end

        if prof5 ~= nil then
            if s1 == '' then
                s1 = mnkProfessions:GetProfText(prof5)
            elseif s2 == '' then
                s2 = mnkProfessions:GetProfText(prof5)
            end
        end
        
        if prof3 ~= nil then
            if s1 == '' then
                s1 = mnkProfessions:GetProfText(prof6)
            elseif s2 == '' then
                s2 = mnkProfessions:GetProfText(prof6)
            end
        end
    end
    

    if s2 ~= '' then
        return s1..' '..s2
    elseif s1 ~= '' then
        return s1
    else
        return 'n/a'
    end
end








