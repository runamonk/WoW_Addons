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
	local sendBNet = false
	local name = string.sub(arg,3,string.len(arg))
	
	if string.sub(arg, 1, 2) == 'b_' then
		sendBNet = true
	end
	
    if button == 'RightButton' then
        if sendBNet then 
            return
        else
		  InviteUnit(name)
        end 
    else
		if sendBNet then 
			ChatFrame_SendBNetTell(name)
		else
			ChatFrame_SendTell(name)
		end
    end
end

function mnkFriends.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkFriendsTooltip', 5, 'LEFT', 'LEFT', 'LEFT', 'LEFT', 'LEFT')
    local status = ""
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    local x = mnkFriends.GetNumFriendsOnline()
    if x > 0 then
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Level', mnkLibs.Color(COLOR_GOLD)..'Zone', mnkLibs.Color(COLOR_GOLD)..'Note')
    else
        local l = tooltip:AddLine()
        tooltip:SetCell(l, 1, 'No friends are online.', 5)
    end

    for i = 1, x do
        local info = C_FriendList.GetFriendInfoByIndex(i)

        if info and info.connected and info.name ~= nil then 
			if info.afk then
				status = mnkLibs.Color(COLOR_GREEN)..' <AFK>'
			elseif info.dnd then
				status = mnkLibs.Color(COLOR_RED)..' <DND>'
			else
				status = " "
			end
			
			local y, x = tooltip:AddLine(string.format('|T%s:16|t', WOW_ICON)..format('|cff%s%s', colors[info.className:gsub(' ', ''):upper()] or 'ffffff', info.name)..status, info.level, info.area, info.notes)
			tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, 'p_'..info.name)
        end
    end
    
    if x > 0 then
        tooltip:AddLine(' ')
    end
    
    local _, i = BNGetNumFriends()
    
    for x = 1, i do
        local _, presenceName, battleTag, _, toonName, toonID, _, isOnline, lastOnline, _, _, _, noteText, _, _, _ = BNGetFriendInfo(x)

        if isOnline then
			local friendInfo = C_BattleNet.GetFriendAccountInfo(x)

			if friendInfo.isAFK then
				status = mnkLibs.Color(COLOR_GREEN)..' <AFK>'
			elseif friendInfo.isDND then
				status = mnkLibs.Color(COLOR_RED)..' <DND>'
			else
				status = " "
			end
			
            if friendInfo.gameAccountInfo.clientProgram == 'WoW' then 
                local y, x = tooltip:AddLine(string.format('|T%s:16|t', WOW_ICON)..format('|cff%s%s', colors[friendInfo.gameAccountInfo.className:gsub(' ', ''):upper()] or 'ffffff', presenceName..' ('..toonName..')')..status, friendInfo.gameAccountInfo.characterLevel, friendInfo.gameAccountInfo.areaName, friendInfo.note)
                tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, 'p_'..friendInfo.gameAccountInfo.characterName..'-'..friendInfo.gameAccountInfo.realmName)
            else
                local y, x = tooltip:AddLine(string.format('|T%s:16|t', BNET_ICON)..presenceName..status, '', '', noteText)
				
                tooltip:SetLineScript(y, 'OnMouseDown', mnkFriends.DoOnMouseDown, 'b_'..presenceName)
            end
        end
    end
    
    tooltip:AddLine(' ')
    local l = tooltip:AddLine()
    tooltip:SetCell(l, 1, 'Left click to send a whisper, right click to invite to group.', 5)

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling(500)
    tooltip.step = 50
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkFriends.DoOnClick(self)
    ToggleFriendsFrame(1)
end

function mnkFriends.GetNumFriendsOnline()
    C_FriendList.ShowFriends()
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
