mnkNuisance = CreateFrame('Frame')
mnkNuisance.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkNuisance_bBlockEnabled = true

local LibQTip = LibStub('LibQTip-1.0')
local BlockThisSession = 0

function mnkNuisance:DoOnEvent(event, arg1)

    if event == 'PLAYER_LOGIN' then
        mnkNuisance.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkNuisance', {
            icon = '', 
            label = mnkLibs.Color(COLOR_GOLD)..'Nuisance', 
            type = 'data source', 
            OnClick = mnkNuisance.DoOnClick, 
            OnEnter = mnkNuisance.DoOnEnter
        })
        mnkNuisance.SetIcon()
    elseif event == 'PET_BATTLE_PVP_DUEL_REQUESTED' then
        if mnkNuisance_bBlockEnabled == true then
            CancelPetDuel()
            StaticPopup_Hide('PET_BATTLE_PVP_DUEL_REQUESTED')
            mnkLibs.PrintError('Pet duel declined automtically.')
        end
    elseif event == 'DUEL_REQUESTED' then
        if mnkNuisance_bBlockEnabled == true then
            CancelDuel()
            StaticPopup_Hide('DUEL_REQUESTED')
            mnkLibs.PrintError('Duel declined automtically.')
        end
    elseif (event == 'PARTY_INVITE_REQUEST') then
        if mnkNuisance_bBlockEnabled == true then
            if mnkNuisance.IsFriend(arg1) == false and mnkNuisance.InGuild(arg1) == false then
                DeclineGroup()
                StaticPopup_Hide('PARTY_INVITE')
                mnkLibs.PrintError('Declined group invite from '..arg1)
                SendChatMessage('Thanks for the invite. I auto-decline all group invites by default.', 'WHISPER', nil, arg1)
                BlockThisSession = (BlockThisSession + 1)
                mnkNuisance.SetIcon()
            end
        end
    end
end

function mnkNuisance.DoOnClick(self)
    mnkNuisance_bBlockEnabled = (mnkNuisance_bBlockEnabled == false)
    mnkNuisance.SetIcon()
end

function mnkNuisance.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkNuisanceTooltip', 1, 'LEFT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    tooltip:AddLine('Click to enable or disable blocking of group and duel invites.')

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkNuisance.IsFriend(chatUser)
    local _, i = GetNumFriends()
    
    if chatUser ~= nil then
        for x = 1, i do
            local name = GetFriendInfo(i)
            if name ~= nil then
                if mnkLibs.formatPlayerName(name) == mnkLibs.formatPlayerName(chatUser) then
                    print('mnkNuisnace: Allowing invite request from friend '..chatUser)
                    return true
                end
            end 
        end

        local _, i = BNGetNumFriends()
        
        for x = 1, i do
            local _, _, _, _, toonName, _, _, isOnline, _, _, _, _, _, _, _, _ = BNGetFriendInfo(x)
            if toonName ~= nil then
                --print(toonName)
                --print(chatUser)
                if isOnline and mnkLibs.formatPlayerName(toonName) == mnkLibs.formatPlayerName(chatUser) then
                    print('mnkNuisnace: Allowing invite request from battle.net friend '..chatUser)
                    return true
                end
            end
        end
    end
    return false
end

function mnkNuisance.InGuild(chatUser)
    if IsInGuild() then
        GuildRoster()
        local _, _, iOnline = GetNumGuildMembers()

        for i = 1, iOnline do
            local name, _, _, _, _, _, _, _, online, _, _, _, _, _ = GetGuildRosterInfo(i)

            --mnkLibs.PrintError(online, ' n:', string.sub(name, 1, string.find(name, '-')-1)), ' c:', chatUser)
            if online and (mnkLibs.formatPlayerName(name) == mnkLibs.formatPlayerName(chatUser)) then
                print('mnkNuisnace: Allowing invite request from guildie '..name)
                return true
            end
        end
    end
    return false
end

function mnkNuisance.SetIcon()
    if mnkNuisance_bBlockEnabled == true then
        mnkNuisance.LDB.icon = 'Interface\\Icons\\Achievement_dungeon_naxxramas_10man'
        mnkNuisance.LDB.text = mnkLibs.Color(COLOR_RED)..'Blocked '..' ('..BlockThisSession..')'
    else
        mnkNuisance.LDB.icon = 'Interface\\Icons\\Achievement_dungeon_naxxramas'
        mnkNuisance.LDB.text = mnkLibs.Color(COLOR_GREEN)..'Blocking off'
    end
end

mnkNuisance:SetScript('OnEvent', mnkNuisance.DoOnEvent)
mnkNuisance:RegisterEvent('PLAYER_LOGIN')
mnkNuisance:RegisterEvent('PARTY_INVITE_REQUEST')
mnkNuisance:RegisterEvent('DUEL_REQUESTED')
mnkNuisance:RegisterEvent('PET_BATTLE_PVP_DUEL_REQUESTED')
