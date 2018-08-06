mnkFriends = CreateFrame('Frame')
mnkFriends.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')
local FRIENDS_TEXTURE_BROADCAST = 'Interface\\FriendsFrame\\BroadcastIcon'
local FRIENDS_TEXTURE_ONLINE = 'Interface\\FriendsFrame\\StatusIcon-Online'
local BNET_ICON = 'Interface\\FriendsFrame\\Battlenet-Portrait'
local WOW_ICON = 'Interface\\FriendsFrame\\Battlenet-WoWicon'

local LastFriendsOnline = 0
local colors = {}
for class, color in pairs(RAID_CLASS_COLORS) do colors[class] = string.format('%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255) end

function mnkFriends.DoOnMouseDown(self, arg, button) 

    if button == 'RightButton' then
        InviteUnit(arg)
    else
        --SetItemRef('player:'..arg, '|Hplayer:'..arg..'|h['..arg..'|h', 'LeftButton')
        ChatFrame_SendSmartTell(arg)
        --SendChatMessage(msg, 'WHISPER', nil, GetUnitName('PLAYERTARGET'))
    end
end

function mnkFriends.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkFriendsTooltip', 5, 'LEFT', 'LEFT', 'LEFT', 'LEFT', 'LEFT')
    
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    local x = mnkFriends.GetNumFriendsOnline()
    if x > 0 then
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Level', mnkLibs.Color(COLOR_GOLD)..'Zone', mnkLibs.Color(COLOR_GOLD)..'Note')
    else
        local l = tooltip:AddLine()
        tooltip:SetCell(l, 1, 'No friends are online.', 5)
    end

    for i = 1, x do
        local name, level, class, zone, online, status, note = GetFriendInfo(i)
        if online and name ~= nil then 
            -- local c1,c2,c3,c4 = unpack(CLASS_ICON_TCOORDS[classFileName])
            -- local classIcon = string.format('|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%s:%s:%s:%s|t', c1*256,c2*256,c3*256,c4*256)

            if status ~= '' and status ~= nil then
                local y, x = tooltip:AddLine(string.format('|T%s:16|t', WOW_ICON)..format('|cff%s%s', colors[class:gsub(' ', ''):upper()] or 'ffffff', name)..status, level, zone, note)
                tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, name)
            else
                local y, x = tooltip:AddLine(string.format('|T%s:16|t', WOW_ICON)..format('|cff%s%s', colors[class:gsub(' ', ''):upper()] or 'ffffff', name), level, zone, note)
                tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, name)
            end 
        end
    end
    
    if x > 0 then
        tooltip:AddLine(' ')
    end
    
    local _, i = BNGetNumFriends()
    
    for x = 1, i do
        local _, presenceName, battleTag, _, toonName, toonID, _, isOnline, lastOnline, _, _, _, noteText, _, _, _ = BNGetFriendInfo(x)

        if isOnline then
            local _, _, client, realmName, _, _, _, class, _, zoneName, level, _, _, _, _, _, _, _, _ = BNGetGameAccountInfo(toonID)

            --unknown, toonName, client, realmName, realmID, faction, race, class, unknown, zoneName, level, gameText, broadcastText, broadcastTime, unknown, presenceID
            --local  _, _, client, _, _, _, _, class, _, zoneName, level, _, _, _, _, _ = BNGetToonInfo(toonID);

            if client == 'WoW' then 
                local y, x = tooltip:AddLine(string.format('|T%s:16|t', WOW_ICON)..format('|cff%s%s', colors[class:gsub(' ', ''):upper()] or 'ffffff', presenceName..' ('..toonName..')'), level, zoneName, noteText)
                tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, toonName..'-'..realmName)
            else
                local y, x = tooltip:AddLine(string.format('|T%s:16|t', BNET_ICON)..presenceName, '', '', noteText)
                tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, presenceName)
            end
        end
    end
    
    tooltip:AddLine(' ')
    local l = tooltip:AddLine()
    tooltip:SetCell(l, 1, 'Left click to send a whisper, right click to invite to group.', 5)

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling(500)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkFriends.DoOnClick(self)
    ToggleFriendsFrame(1)
end

function mnkFriends.GetNumFriendsOnline()
    local _, i = GetNumFriends()
    local _, x = BNGetNumFriends()

    if LastFriendsOnline ~= (i + x) then
        if ((i + x) > LastFriendsOnline) then
            PlaySoundFile(mnkLibs.Sounds.friend_online, 'Master')
        end
        LastFriendsOnline = (i + x)
    end

    return i + x
end

function mnkFriends:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkFriends.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkFriends', {
            icon = 'Interface\\Icons\\Inv_drink_05.blp', 
            type = 'data source', 
            OnEnter = mnkFriends.DoOnEnter, 
            OnClick = mnkFriends.DoOnClick
        })
    end
    self.LDB.label = 'Friends'
    self.LDB.text = mnkFriends.GetNumFriendsOnline()
end

mnkFriends:SetScript('OnEvent', mnkFriends.DoOnEvent)
mnkFriends:RegisterEvent('PLAYER_LOGIN')
mnkFriends:RegisterEvent('FRIENDLIST_UPDATE')
mnkFriends:RegisterEvent('PLAYER_FLAGS_CHANGED')
mnkFriends:RegisterEvent('BN_FRIEND_ACCOUNT_OFFLINE')
mnkFriends:RegisterEvent('BN_FRIEND_ACCOUNT_ONLINE')
mnkFriends:RegisterEvent('BN_FRIEND_INFO_CHANGED')
