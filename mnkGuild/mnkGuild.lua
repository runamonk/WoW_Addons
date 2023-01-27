mnkGuild = CreateFrame('Frame', nil, UIParent, BackdropTemplate)
mnkGuild.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkGuild:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkGuild:RegisterEvent('GUILD_ROSTER_UPDATE')
mnkGuild:RegisterEvent('GUILD_MOTD')
mnkGuild:RegisterEvent('PLAYER_LOGIN')
mnkGuild:RegisterEvent('PLAYER_GUILD_UPDATE')

local LibQTip = LibStub('LibQTip-1.0')
local t = {}

function mnkGuild:GUILD_MOTD()
    mnkGuild:UpdateText()  
end

function mnkGuild:GUILD_ROSTER_UPDATE()
    mnkGuild:UpdateText()  
end 

function mnkGuild:PLAYER_GUILD_UPDATE()
    mnkGuild:UpdateText()  
end 

function mnkGuild:PLAYER_LOGIN()
    mnkGuild.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkGuild', {
        icon = 'Interface\\GuildFrame\\GuildLogo-NoLogo', 
        type = 'data source', 
        OnEnter = function (parent) mnkGuild:OnEnter(parent) end, 
        OnClick = function () mnkGuild:OnClick() end
    })
    self.LDB.label = 'Guild'
    mnkGuild:UpdateText()  
end

function mnkGuild:OnClick()
    ToggleGuildFrame()
end

function mnkGuild:OnEnter(parent)
    local function OnClick(self, arg, button) 
        local sendBNet = false
       
        if arg.client == 'b' then
            sendBNet = true
        end
        
        if button == 'RightButton' then
            if sendBNet then 
                return
            else
                --InviteUnit(arg.name)
                C_PartyInfo.InviteUnit(arg.name)
            end 
        else
            if sendBNet then 
                ChatFrame_SendBNetTell(arg.name)
            else
                ChatFrame_SendTell(arg.name)
            end
        end
    end

    local tooltip = LibQTip:Acquire('mnkGuildTooltip', 5, 'LEFT', 'LEFT', 'LEFT', 'LEFT', 'LEFT')
    
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    if IsInGuild() then
        C_GuildInfo.GuildRoster()
        
        local GuildName = GetGuildInfo('player')
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..GuildName)
        
        local y, x = tooltip:AddLine('')
        --SetCell(lineNum, colNum, value[, font][, justification][, colSpan][, provider][, leftPadding][, rightPadding][, maxWidth][, minWidth][, ...])
        tooltip:SetCell(y, 1, GetGuildRosterMOTD(), nil, 'LEFT', 5, nil, nil, nil, 450, nil)
        tooltip:AddHeader(' ')
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Level', mnkLibs.Color(COLOR_GOLD)..'Rank', mnkLibs.Color(COLOR_GOLD)..'Zone', mnkLibs.Color(COLOR_GOLD)..'Note')
        
        for i = 1, #t do
            local y = tooltip:AddLine(t[i].ClassNameStatus, t[i].level, t[i].rank, t[i].zone, t[i].note)
            tooltip:SetLineScript(y, 'OnMouseDown', OnClick, t[i])
        end

        tooltip:AddLine(' ')

        local l = tooltip:AddLine()
        tooltip:SetCell(l, 1, 'Astrix indicates user is not logged in via a WoW client.', 5)

        local l = tooltip:AddLine()
        tooltip:SetCell(l, 1, 'Left click to send a whisper, right click to invite to group.', 5)

    else
        local l = tooltip:AddLine()
        tooltip:SetCell(l, 1, 'You are not in a guild.', 5)
    end
    tooltip.step = 50 
    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:UpdateScrolling(500)
    --tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    --mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    --tooltip:SetBackdropColor(0, 0, 0, 1) 
    tooltip:EnableMouse(true)   
    tooltip:Show()
end

function mnkGuild:UpdateText()
    local function Status(statusid)
        if statusid == 0 then
            return ''
        elseif statusid == 1 then
            return mnkLibs.Color(COLOR_GREEN)..' <Away>'
        elseif statusid == 2 then
            return mnkLibs.Color(COLOR_RED)..' <Busy>'
        else
            return ''
        end
    end

    t = {}

    if IsInGuild() then
        C_GuildInfo.GuildRoster()
        
        local guildName = GetGuildInfo('player')
        local iTotal, _, iOnline = GetNumGuildMembers()

        if guildName ~= nil then

            mnkGuild.LDB.label = mnkLibs.Color(COLOR_GREEN)..guildName
            mnkGuild.LDB.text = iOnline..'/'..iTotal
            local x = 0

            for i = 1, iTotal do
                local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)
                --local name, description, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _ = GetGuildFactionInfo();
                if online or isMobile then
                    x = x + 1
                    --TTexturePath:size1:size2:xoffset:yoffset:dimx:dimy:coordx1:coordx2:coordy1:coordy2:red:green:blue|t
                    local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[classFileName])
                    --local classIcon = string.format('|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%s:%s:%s:%s|t', c1 * 256, c2 * 256, c3 * 256, c4 * 256)
                    local classIcon = string.format('|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%s:%s:%s:%s|t', (c1 * 256)+4, (c2 * 256)-4, (c3 * 256)+4, (c4 * 256)-4)

                    t[x] = {}
                    t[x].ClassNameStatus = classIcon..' '..mnkLibs.Color(RAID_CLASS_COLORS[class:gsub(' ', ''):upper()] or COLOR_WHITE)..mnkLibs.formatPlayerName(name)..Status(status)
                    t[x].name = name
                    t[x].level = level
                    t[x].rank = rank
                    t[x].zone = zone
                    t[x].note = note

                    if online then
                        t[x].client = 'p'
                    else
                         t[x].client = 'b'
                    end

                    if isMobile then
                        t[x].ClassNameStatus = t[x].ClassNameStatus..mnkLibs.Color(COLOR_WHITE)..'*'
                    end
                end
            end
        end

        local sort_func = function(a, b) return a.name < b.name end
        table.sort(t, sort_func)

    else
        mnkGuild.LDB.text = 'n/a'
    end
end

