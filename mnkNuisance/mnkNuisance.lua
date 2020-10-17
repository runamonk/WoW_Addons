mnkNuisance = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
mnkNuisance.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkNuisance_bBlockEnabled = true
mnkNuisance:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkNuisance:RegisterEvent('PLAYER_LOGIN')
mnkNuisance:RegisterEvent('PARTY_INVITE_REQUEST')
mnkNuisance:RegisterEvent('DUEL_REQUESTED')
mnkNuisance:RegisterEvent('PET_BATTLE_PVP_DUEL_REQUESTED')

local LibQTip = LibStub('LibQTip-1.0')
local BlockThisSession = 0

function mnkNuisance:DUEL_REQUESTED()
    if mnkNuisance_bBlockEnabled == true then
        CancelDuel()
        StaticPopup_Hide('DUEL_REQUESTED')
        BlockThisSession = (BlockThisSession + 1)
        self:UpdateText()
        print('Duel declined automtically.')
    end    
end

function mnkNuisance:IsFriend(chatUser)
    local _, i = C_FriendList.GetNumFriends()
    
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

function mnkNuisance:InGuild(chatUser)
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

function mnkNuisance:OnClick()
    mnkNuisance_bBlockEnabled = (mnkNuisance_bBlockEnabled == false)
    self:UpdateText()
end

function mnkNuisance:OnEnter(parent)
    local tooltip = LibQTip:Acquire('mnkNuisanceTooltip', 1, 'LEFT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    tooltip:AddLine('Click to enable or disable blocking of group and duel invites.')

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    tooltip:SetBackdropColor(0, 0, 0, 1)
    tooltip:EnableMouse(true)    
    tooltip:Show()
end

function mnkNuisance:PARTY_INVITE_REQUEST(event, arg1)
    if mnkNuisance_bBlockEnabled == true then
        if self:IsFriend(arg1) == false and self:InGuild(arg1) == false then
            DeclineGroup()
            StaticPopup_Hide('PARTY_INVITE')
            print('Declined group invite from '..arg1)
            --TODO AddIgnore() assholes.
            --SendChatMessage('Thanks for the invite. I auto-decline all group invites by default.', 'WHISPER', nil, arg1)
            BlockThisSession = (BlockThisSession + 1)
            self:UpdateText()
        end
    end
end

function mnkNuisance:PET_BATTLE_PVP_DUEL_REQUESTED()
    if mnkNuisance_bBlockEnabled == true then
        CancelPetDuel()
        StaticPopup_Hide('PET_BATTLE_PVP_DUEL_REQUESTED')
        print('Pet duel declined automtically.')
    end
end

function mnkNuisance:PLAYER_LOGIN()
    mnkNuisance.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkNuisance', {
        icon = '', 
        label = mnkLibs.Color(COLOR_GOLD)..'Nuisance', 
        type = 'data source', 
        OnClick = function() mnkNuisance:OnClick() end, 
        OnEnter = function(parent) mnkNuisance:OnEnter(parent) end
    })
    self:UpdateText()
end

function mnkNuisance:UpdateText()
    if mnkNuisance_bBlockEnabled == true then
        self.LDB.icon = 'Interface\\Icons\\Achievement_dungeon_naxxramas_10man'
        self.LDB.text = mnkLibs.Color(COLOR_RED)..'Blocked '..' ('..BlockThisSession..')'
    else
        self.LDB.icon = 'Interface\\Icons\\Achievement_dungeon_naxxramas'
        self.LDB.text = mnkLibs.Color(COLOR_GREEN)..'Blocking off'
    end
end


