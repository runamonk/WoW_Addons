mnkReputation = CreateFrame('Frame', nil, UIParent, BackdropTemplate)
mnkReputation.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkReputation:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

mnkReputation:RegisterEvent('PLAYER_LOGIN')
mnkReputation:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkReputation:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
mnkReputation:RegisterEvent('PLAYER_GUILD_UPDATE')
mnkReputation:RegisterEvent('UPDATE_FACTION')
mnkReputation:RegisterEvent('MAJOR_FACTION_RENOWN_LEVEL_CHANGED')

local libQTip = LibStub('LibQTip-1.0')
local libAG = LibStub('AceGUI-3.0')
local fConfig = nil
local StatusBarCellProvider, StatusBarCell = libQTip:CreateCellProvider()

mnkReputation_db = {}
mnkReputation_db.Watched = {}

local tblAllFactions = {}
local tblTabards = {}
local sFactions = nil

local function GetFactionColor(standingid)
    if standingid == 8 then
        return COLOR_PURPLE
    elseif standingid >= 1 and standingid <= 3 then
        return COLOR_RED
    elseif standingid == 4 then
        return COLOR_GREY
    elseif standingid == 5 then
        return COLOR_DKGREEN
    elseif standingid == 6 then
        return COLOR_GREEN
    elseif standingid == 7 then
        return COLOR_BLUE
    else
        return COLOR_WHITE
    end
end

--[[ function mnkReputation:AddCheckbox(scrollbox, checked, name, standingid, standing, rating)
    local c = libAG:Create('CheckBox')
    c:SetValue(checked)
    c:SetLabel(name..' ['..mnkLibs.Color(GetFactionColor(standingid or 0))..standing..mnkLibs.Color(COLOR_WHITE)..'] '..mnkLibs.Color(COLOR_WHITE)..rating)
    c:SetUserData('name', name)
    c:SetWidth(400)
    scrollbox:AddChild(c)
end ]]

--[[ function mnkReputation:AddLabel(scrollbox, name, standing)
    local c = libAG:Create('Label')
    c:SetText(' ')
    scrollbox:AddChild(c)

    local c = libAG:Create('Label')
    c:SetText(mnkLibs.Color(COLOR_GOLD)..name..standing)
    c:SetWidth(400)
    scrollbox:AddChild(c)
end ]]

function mnkReputation:CHAT_MSG_COMBAT_FACTION_CHANGE(event, arg1)
    CombatText_AddMessage(mnkLibs.Color(COLOR_BLUE)..arg1, CombatText_StandardScroll, 255, 255, 255, nil, false)
    mnkReputation:UpdateText()    
end

function mnkReputation:GetAllFactions()
    table.wipe(tblAllFactions)

    local x = GetNumFactions()
    local idx = 0
    local header = ''
    
    for i = 1, x do
        local name, _, standingId, _, max, current, _, _, isHeader, isCollapsed, hasRep, _, _,  factionID = GetFactionInfo(i)
        local pCurrent, pMax = 0
        local pReward = false
        local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)    
        local dataMajor = C_MajorFactions.GetMajorFactionData(factionID)
        local standing = ""

        if (isCollapsed == false) then
            if isHeader then
                header = name
            end

            if (isHeader == false) or (isHeader and hasRep) then

                local isParagon = C_Reputation.IsFactionParagon(factionID)
                if isParagon then
                    pCurrent, pMax, _, pReward = C_Reputation.GetFactionParagonInfo(factionID);
                    -- if pCurrent is greater than 10000, the first character is paragon level.
                    -- if event == 'CHAT_MSG_LOOT' then
                    --     print(name, 'pReward:', pReward)
                    -- end
                    if pCurrent and pMax then
                        if pCurrent >= pMax then
                            current = string.sub(tostring(pCurrent), #tostring(pCurrent)-3,#tostring(pCurrent))
                        else
                            current = pCurrent
                        end
                        max = pMax
                    -- else
                    --     print('GetFactionParagonInfo() returned nil.', ' name:', name, ' pCurrent:', pCurrent, ' pMax:', pMax, ' factionID:', factionID)
                    end
                end

                standing = _G['FACTION_STANDING_LABEL'..standingId]
                local renownlevel = null

                if (dataMajor ~= null) then
                    current = dataMajor.renownReputationEarned
                    max = dataMajor.renownLevelThreshold
                    renownlevel = "Renown "..dataMajor.renownLevel
                    --print(name.." "..current.." "..max.." "..renownlevel)
                end

                if (repInfo.name ~= null) then 
                    current = repInfo.standing or 0
                    max = repInfo.nextThreshold or current
                    --print(name.." "..current.." / "..max)
                end
                
                idx = idx + 1
                tblAllFactions[idx] = {}
                if header == 'Guild' then
                    header = '.Guild.'
                end
            
                tblAllFactions[idx].header = header
                tblAllFactions[idx].name = name
                tblAllFactions[idx].standingid = standingId
                tblAllFactions[idx].standing = standing
                tblAllFactions[idx].current = current
                tblAllFactions[idx].max = max
                tblAllFactions[idx].hasrep = hasRep
                tblAllFactions[idx].hasreward = pReward
                tblAllFactions[idx].ranklevel = rankInfo.currentLevel
                tblAllFactions[idx].rankmaxlevel = rankInfo.maxLevel
                tblAllFactions[idx].renownlevel = renownlevel
            end
        end
    end

    local function sort_func(a, b)
        if a.header == b.header then
            return a.name < b.name
        else
            return a.header < b.header
        end
    end

    table.sort(tblAllFactions, sort_func)
end

function mnkReputation:GetRepLeft(amt)
    if amt == 0 or amt == 1 then
        return ''
    else
        return amt --mnkLibs.formatNumber(amt, 0)
    end
end

function mnkReputation:InTable(t, name)
    local result = false
    for i = 1, #t do 
        if t[i].name == name then
            result = true
        end
    end
    return result
end

function mnkReputation:OnClick(event, button)
    if button == 'LeftButton' then
        ToggleCharacter('ReputationFrame')
    end
end

function mnkReputation:OnEnter(parent)
    local color = COLOR_WHITE
    local tooltip = libQTip:Acquire('mnkReputationToolTip', 2, 'LEFT', 'LEFT')
    local y, x = nil
    
    mnkReputation.tooltip = tooltip
    
    tooltip:Clear()
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    if #mnkReputation_db.Watched == 0 then
        tooltip:AddLine('You have not selected any factions to display.')
        tooltip:AddLine('Right click on mnkReputation to open the config.')
    else 
        table.sort(tblAllFactions, function(a, b) return a.name < b.name end)

        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Factions', nil)

        for i = 1, #tblAllFactions do
            --if mnkReputation:InTable(mnkReputation_db.Watched, tblAllFactions[i].name) == true then
                y, _ = tooltip:AddLine()
                tooltip:SetCell(y, 1, tblAllFactions[i], 2 , StatusBarCellProvider)
            --end
        end
    end

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:UpdateScrolling(500)
    tooltip.step = 50
    --tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    --mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    --tooltip:SetBackdropColor(0, 0, 0, 1)
    tooltip:EnableMouse(true)    
    tooltip:Show()
end

function mnkReputation:PLAYER_ENTERING_WORLD(event, firstTime, reload)
    if firstTime or reload then
        self:UpdateText()
    end
end

function mnkReputation:PLAYER_GUILD_UPDATE()
    self:UpdateText()
end

function mnkReputation:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkReputation', {
        icon = 'Interface\\Icons\\Inv_misc_bone_skull_02.blp', 
        type = 'data source', 
        OnEnter = function(parent) self:OnEnter(parent) end, 
        OnClick = function(event, button) self:OnClick(event, button) end
    })
    
    self.LDB.label = 'Factions'
end

function mnkReputation:UpdateTable(t, scrollbox)
    table.wipe(t)    
    local x = 0
    for i = 1, #scrollbox.children do
        if scrollbox.children[i].type == 'CheckBox' and scrollbox.children[i]:GetValue() == true then
            x = (x + 1)
            t[x] = {}
            t[x].name = scrollbox.children[i]:GetUserData('name')
        end
    end 
end

function mnkReputation:MAJOR_FACTION_RENOWN_LEVEL_CHANGED()
    self:UpdateText()
end

function mnkReputation:UPDATE_FACTION()
    self:UpdateText()
end

function mnkReputation:UpdateText()
    self:GetAllFactions()  
    self.LDB.text = mnkLibs.Color(COLOR_GOLD)..#tblAllFactions
end

function StatusBarCell:getContentHeight()
    return self.bar:GetHeight()
end

function StatusBarCell:InitializeCell()
    self.bar = CreateFrame('StatusBar',nil, self)
    self.bar:SetSize(400, 16)
    self.bar:SetPoint('CENTER')
    self.bar:SetMinMaxValues(0, 100)
    self.bar:SetPoint('LEFT', self, 'LEFT', 1, 0)
    self.bar:SetStatusBarTexture('Interface\\ChatFrame\\ChatFrameBackground')
    self.fsName = self.bar:CreateFontString(nil, 'OVERLAY')
    self.fsName:SetPoint('LEFT', self.bar, 'LEFT', 5, 0)
    self.fsName:SetWidth(300)
    self.fsName:SetFontObject(_G.GameTooltipText)
    self.fsName:SetShadowColor(0, 0, 0)
    self.fsName:SetShadowOffset(1, -1)
    self.fsName:SetDrawLayer('OVERLAY')
    self.fsName:SetJustifyH('LEFT')
    self.fsName:SetTextColor(1, 1, 1)
    self.fsName:SetFontObject(mnkLibs.DefaultTooltipFont)
    self.fsTogo = self.bar:CreateFontString(nil, 'OVERLAY')
    self.fsTogo:SetPoint('RIGHT', self.bar, 'RIGHT', -5, 0)
    self.fsTogo:SetWidth(100)
    self.fsTogo:SetFontObject(_G.GameTooltipText)
    self.fsTogo:SetShadowColor(0, 0, 0)
    self.fsTogo:SetShadowOffset(1, -1)
    self.fsTogo:SetDrawLayer('OVERLAY')
    self.fsTogo:SetJustifyH('RIGHT')
    self.fsTogo:SetTextColor(1, 1, 1)
    self.fsTogo:SetFontObject(mnkLibs.DefaultTooltipFont)
end

function StatusBarCell:ReleaseCell()

end

function StatusBarCell:SetupCell(tooltip, data, justification, font, r, g, b)
    if (type(data) == "table") then 
        if data.header == '.Guild.' then
            self.fsName:SetText(mnkLibs.Color(COLOR_GREEN)..'<'..mnkLibs.Color(GetFactionColor(data.standingid))..data.name..mnkLibs.Color(COLOR_GREEN)..'>')
        elseif data.renownlevel ~= null then
            self.fsName:SetText(mnkLibs.Color(COLOR_WHITE)..data.name.." ["..data.renownlevel.."]")
        elseif data.rankmaxlevel ~= null or data.ranklevel ~= null then
            self.fsName:SetText(mnkLibs.Color(COLOR_WHITE)..data.name.." [Rank"..data.ranklevel.."/"..data.rankmaxlevel.."]")
        elseif data.hasreward then
            self.fsName:SetText(mnkLibs.Color(COLOR_GOLD)..data.name)
        else
            self.fsName:SetText(mnkLibs.Color(GetFactionColor(data.standingid))..data.name)
        end
        self.fsTogo:SetText(mnkLibs.Color(GetFactionColor(data.standingid))..mnkReputation:GetRepLeft(data.max - data.current))
        local c = GetFactionColor(data.standingid)
        if (data.renownlevel ~= null) then
            c = COLOR_BLUE
        end
        self.bar:SetStatusBarColor(c.r/255/2, c.g/255/2, c.b/255/2, 1)
        self.bar:SetValue(math.min((data.current or 0 / data.max) * 100, 100))
        return self.bar:GetWidth(), self.bar:GetHeight()
    else
        -- Just text so create a background with the bar.
        self.fsName:SetWidth(self.bar:GetWidth())
        self.fsName:SetText(data)
        self.fsTogo:SetText("")
        self.bar:SetStatusBarColor(0, 0, 0, 0.5)
        self.bar:SetValue(100, 100)
        return self.bar:GetWidth(), self.bar:GetHeight()    
    end
end


