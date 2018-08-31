mnkGuild = CreateFrame('Frame')
mnkGuild.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')
local t = {}
local colors = {}
local maxLevel = GetMaxPlayerLevel()

for class, color in pairs(RAID_CLASS_COLORS) do colors[class] = string.format('%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255) end

function mnkGuild:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkGuild.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkGuild', {
            icon = 'Interface\\GuildFrame\\GuildLogo-NoLogo', 
            type = 'data source', 
            OnEnter = mnkGuild.DoOnEnter, 
            OnClick = mnkGuild.DoOnClick
        })
        self.LDB.label = 'Guild'
    end
    mnkGuild.UpdateText()
end

function mnkGuild.DoOnClick(self)
    ToggleGuildFrame()
end

function mnkGuild.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkGuildTooltip', 5, 'LEFT', 'LEFT', 'LEFT', 'LEFT', 'LEFT')
    
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    if IsInGuild() then
        GuildRoster()
        
        local GuildName = GetGuildInfo('player')
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..GuildName)
        --local l = tooltip:AddLine();
        --tooltip:SetCell(l, 1, GetGuildRosterMOTD(), 5);
        
        local y, x = tooltip:AddLine('')
        --SetCell(lineNum, colNum, value[, font][, justification][, colSpan][, provider][, leftPadding][, rightPadding][, maxWidth][, minWidth][, ...])
        tooltip:SetCell(y, 1, GetGuildRosterMOTD(), nil, 'LEFT', 5, nil, nil, nil, 450, nil)


        tooltip:AddHeader(' ')
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Level', mnkLibs.Color(COLOR_GOLD)..'Rank', mnkLibs.Color(COLOR_GOLD)..'Zone', mnkLibs.Color(COLOR_GOLD)..'Note')
        
        for i = 1, #t do
            local y = tooltip:AddLine(t[i].ClassNameStatus, t[i].level, t[i].rank, t[i].zone, t[i].note)
            tooltip:SetLineScript(y, 'OnMouseDown', mnkGuild.MouseHandler, t[i].name)
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
    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling(500)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkGuild.MouseHandler(self, arg, button) 
    if button == 'RightButton' then
        InviteUnit(arg)
    else
        ChatFrame_SendSmartTell(arg)
        --SetItemRef('player:'..arg, '|Hplayer:'..arg..'|h['..arg..'|h', 'LeftButton')
    end
end

function mnkGuild.GetStatus(statusid)
    if statusid == 0 then
        return ''
    elseif statusid == 1 then
        return mnkLibs.Color(COLOR_GREEN)..'<Away>'
    elseif statusid == 2 then
        return mnkLibs.Color(COLOR_RED)..'<Busy>'
    else
        return ''
    end
end

function mnkGuild.UpdateText()
    table.wipe(t)

    if IsInGuild() then
        GuildRoster()
        
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
                    local classIcon = string.format('|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%s:%s:%s:%s|t', c1 * 256, c2 * 256, c3 * 256, c4 * 256)
                    t[x] = {}
                    t[x].ClassNameStatus = classIcon..format(' |cff%s%s', colors[class:gsub(' ', ''):upper()] or 'ffffff', mnkLibs.formatPlayerName(name))..mnkGuild.GetStatus(status)
                    t[x].name = name
                    t[x].level = level
                    t[x].rank = rank
                    t[x].zone = zone
                    t[x].note = note
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


mnkGuild:SetScript('OnEvent', mnkGuild.DoOnEvent)
mnkGuild:RegisterEvent('PLAYER_LOGIN')
mnkGuild:RegisterEvent('GUILD_ROSTER_UPDATE')
mnkGuild:RegisterEvent('GUILD_MOTD')
mnkGuild:RegisterEvent('PLAYER_FLAGS_CHANGED')
mnkGuild:RegisterEvent('PLAYER_GUILD_UPDATE')
