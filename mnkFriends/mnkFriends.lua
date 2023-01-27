mnkFriends = CreateFrame('Frame', nil, UIParent, BackdropTemplate)
mnkFriends.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkFriends:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkFriends:RegisterEvent('PLAYER_LOGIN')
mnkFriends:RegisterEvent('FRIENDLIST_UPDATE')
mnkFriends:RegisterEvent('BN_FRIEND_ACCOUNT_OFFLINE')
mnkFriends:RegisterEvent('BN_FRIEND_ACCOUNT_ONLINE')

local LibQTip = LibStub('LibQTip-1.0')
local FRIENDS_TEXTURE_BROADCAST = 'Interface\\FriendsFrame\\BroadcastIcon'
local FRIENDS_TEXTURE_ONLINE = 'Interface\\FriendsFrame\\StatusIcon-Online'

local LastFriendsOnline = 0

function mnkFriends:BN_FRIEND_ACCOUNT_OFFLINE()
    self.LDB.text = mnkFriends:GetNumFriendsOnline()
end

function mnkFriends:BN_FRIEND_ACCOUNT_ONLINE()
    self.LDB.text = mnkFriends:GetNumFriendsOnline()
end

function mnkFriends:FRIENDLIST_UPDATE()
    self.LDB.text = mnkFriends:GetNumFriendsOnline()
end

function mnkFriends:GetNumFriendsOnline()
    --C_FriendList.ShowFriends()
	local i =  C_FriendList.GetNumOnlineFriends()
	local numBNetTotal, numBNetOnline = BNGetNumFriends()

    if LastFriendsOnline ~= (i + numBNetOnline) then
        if ((i + numBNetOnline) > LastFriendsOnline) then
            PlaySoundFile(mnkLibs.Sounds.friend_online, 'Master')
        end
        LastFriendsOnline = (i + numBNetOnline)
    end

    return i + numBNetOnline
end

function mnkFriends:OnClick()
    ToggleFriendsFrame(1)
end

function mnkFriends:OnEnter(parent)
    local function OnMouseDown(self, arg, button) 
        local sendBNet = false
        local name = string.sub(arg,3,string.len(arg))
        
        if string.sub(arg, 1, 2) ~= 'w_' then
            sendBNet = true
        end
        
        if button == 'RightButton' then
            if sendBNet then 
                return
            else
              C_PartyInfo.InviteUnit(name)
            end 
        else
            if sendBNet then 
                ChatFrame_SendBNetTell(name)
            else
                ChatFrame_SendTell(name)
            end
        end
    end

    local tooltip = LibQTip:Acquire('mnkFriendsTooltip', 5, 'LEFT', 'LEFT', 'LEFT', 'LEFT', 'LEFT')
    local status = ""
    local t = {}
    local info = nil

    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    local x = mnkFriends:GetNumFriendsOnline()
    if x > 0 then
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Level', mnkLibs.Color(COLOR_GOLD)..'Zone', mnkLibs.Color(COLOR_GOLD)..'Note')
        x = C_FriendList.GetNumFriends()
        local c = 0
        for i = 1, x do
            info = C_FriendList.GetFriendInfoByIndex(i)
            if info and info.connected then
                c = c + 1
                t[c] = {}
                t[c].name = info.name
                t[c].nameformatted = mnkLibs.Color(RAID_CLASS_COLORS[info.className:gsub(' ', ''):upper()] or COLOR_WHITE)..info.name
                t[c].level = info.level
                t[c].zone = info.area
                t[c].note = info.notes
                t[c].client = 'WoW' 

                if info.afk then
                    t[c].status = mnkLibs.Color(COLOR_GREEN)..' <AFK>'
                elseif info.dnd then
                    t[c].status = mnkLibs.Color(COLOR_RED)..' <DND>'
                end
            end
        end
        
        local _, x = BNGetNumFriends()

        for i = 1, x do
            info = C_BattleNet.GetFriendAccountInfo(i)
            if info and info.gameAccountInfo.isOnline then
                c = c + 1
                t[c] = {}
                
                if info.gameAccountInfo.clientProgram == 'WoW' then
                    t[c].name = info.gameAccountInfo.characterName 
                    t[c].nameformatted = mnkLibs.Color(RAID_CLASS_COLORS[info.gameAccountInfo.className:gsub(' ', ''):upper()] or COLOR_WHITE)..info.gameAccountInfo.characterName
                    t[c].level = info.gameAccountInfo.characterLevel
                    t[c].zone = info.gameAccountInfo.areaName 
                    t[c].client = info.gameAccountInfo.clientProgram 
                else
                    t[c].name = string.sub(info.battleTag, 1, string.find(info.battleTag, '#')-1) 
                    t[c].zone = info.gameAccountInfo.richPresence
                    t[c].client = info.gameAccountInfo.clientProgram 
                end

                t[c].note = info.note
                if info.isAFK then
                    t[c].status = mnkLibs.Color(COLOR_GREEN)..' <AFK>'
                elseif info.isDND then
                    t[c].status = mnkLibs.Color(COLOR_RED)..' <DND>'
                end
            end        
        end

        local sort_func = function(a, b) return a.name < b.name end
        table.sort(t, sort_func)

        for i = 1, #t do
           -- print(t[i].name, ' ', t[i].zone)
            if t[i].client == 'WoW' then
                local y, x = tooltip:AddLine(t[i].nameformatted..status, t[i].level, t[i].zone, t[i].note)
                tooltip:SetLineScript(y, 'OnMouseDown', OnMouseDown, 'w_'..t[i].name)
            else
                local y, x = tooltip:AddLine(t[i].name..status, '', t[i].zone, t[i].note)
                tooltip:SetLineScript(y, 'OnMouseDown', OnMouseDown, 'b_'..t[i].name)      
            end 
        end

    else
        local l = tooltip:AddLine()
        tooltip:SetCell(l, 1, 'No friends are online.', 5)
    end
    
    tooltip:AddLine(' ')
    local l = tooltip:AddLine()
    tooltip:SetCell(l, 1, 'Left click to send a whisper, right click to invite to group.', 5)

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

function mnkFriends:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkFriends', {
        icon = 'Interface\\Icons\\Inv_drink_05.blp', 
        type = 'data source', 
        OnEnter = function (parent) mnkFriends:OnEnter(parent) end, 
        OnClick = function () mnkFriends:OnClick() end
    })

    self.LDB.label = 'Friends'
    self.LDB.text = mnkFriends:GetNumFriendsOnline()
end

