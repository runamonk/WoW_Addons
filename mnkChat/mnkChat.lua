mnkChat = CreateFrame('Frame')
mnkChat.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkChat.hooks = {}
local libQTip = LibStub('LibQTip-1.0')
local myaddonName = ...

mnkChat_db = {}
mnkChat_db.Messages = {}
mnkChat_db.NEW_MESSAGES = 0

local MAX_MESSAGES = 10
local font = CreateFont('tooltipFont')
font:SetFont(mnkLibs.Fonts.abf, 12)

local StickyTypeChannels = {
    SAY = 1, 
    YELL = 0, 
    EMOTE = 0, 
    PARTY = 1, 
    RAID = 1, 
    GUILD = 1, 
    OFFICER = 1, 
    WHISPER = 1, 
    CHANNEL = 1, 
}

local tabs = {'Left','Middle','Right','SelectedLeft','SelectedRight','SelectedMiddle','HighlightLeft','HighlightMiddle','HighlightRight'}

mnkChat.hooks.ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow

SLASH_CLEAR_CHAT1 = '/clear'
ChatFontNormal:SetFont(mnkLibs.Fonts.ap, 14, '')
ChatFontNormal:SetShadowOffset(1,1)
ChatFontNormal:SetShadowColor(0,0,0)

FloatingChatFrame_OnMouseScroll = function(self, dir)
    if(dir > 0) then
        if(IsShiftKeyDown()) then
            self:ScrollToTop()
        else
            self:ScrollUp()
        end
    else
        if(IsShiftKeyDown()) then
            self:ScrollToBottom()
        else
            self:ScrollDown()
        end
    end
end
SlashCmdList.CLEAR_CHAT = function()
    for i = 1, NUM_CHAT_WINDOWS do
        _G[format('ChatFrame%d', i)]:Clear()
    end
end

function ChatFrame_OnHyperlinkShow(frame, link, text, button)
    local type, value = link:match('(%a+):(.+)')
    if (type == 'url') then
        local eb = _G[frame:GetName()..'EditBox']
        
        eb:Show()
        eb:SetText(value)
        eb:SetFocus()
        eb:HighlightText()
    else
        mnkChat.hooks.ChatFrame_OnHyperlinkShow(self, link, text, button)
    end
end

function mnkChat.DoOnChat(event, message, playername, _, _, _, playerstatus, _, _, _, lineid, _, guid, pid)
    if message ~= nil then
        CombatText_AddMessage(mnkLibs.formatPlayerName(playername)..': '..message, CombatText_StandardScroll, 255, 0, 0, nil, false)
        table.insert(mnkChat_db.Messages, 1, {time, name, message})
        mnkChat_db.Messages[1].time = date('%I:%M:%S:%p')
        if string.find(playername, '-') == nil then
            mnkChat_db.Messages[1].name = playername
        else
            mnkChat_db.Messages[1].name = mnkLibs.formatPlayerName(playername)
        end
        mnkChat_db.Messages[1].fullname = playername
        mnkChat_db.Messages[1].message = message

        mnkChat_db.NEW_MESSAGES = mnkChat_db.NEW_MESSAGES + 1
        if #mnkChat > MAX_MESSAGES then
            for i = #mnkChat_db.Messages, MAX_MESSAGES + 1, -1 do
                table.remove(mnkChat_db.Messages, i)
            end
        end
    end
end

function mnkChat:DoOnEvent(event, ...)
    if string.sub(event, 1, 8) == 'CHAT_MSG' then
        PlaySoundFile(mnkLibs.Sounds.incoming_message, 'Master')
        mnkChat.DoOnChat(event, ...)
    elseif event == 'PLAYER_ENTERING_WORLD' then
        local initialLogin, reloadingUI = ...
        if initialLogin or reloadingUI then
            mnkChat.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkChat', {
                icon = mnkLibs.Textures.icon_none, 
                type = 'data source', 
                OnEnter = mnkChat.DoOnEnter, 
                OnClick = mnkChat.DoOnClick
            })
            QuickJoinToastButton:Hide() 
            QuickJoinToastButton:HookScript('OnShow', QuickJoinToastButton.Hide)
            ChatFrameMenuButton:Hide()
            ChatFrameMenuButton:HookScript('OnShow', ChatFrameMenuButton.Hide)
            ChatFrameChannelButton:Hide()
            ChatFrameChannelButton:HookScript('OnShow', ChatFrameChannelButton.Hide)
            
            CHAT_WHISPER_GET = '>> %s: '
            CHAT_WHISPER_INFORM_GET = '<< %s: '
            CHAT_YELL_GET = '|Hchannel:Yell|h<Y> |h %s: '
            CHAT_SAY_GET = '|Hchannel:Say|h<S> |h %s: '
            CHAT_BATTLEGROUND_GET = '|Hchannel:Battleground|h<BG> |h %s: '
            CHAT_BATTLEGROUND_LEADER_GET = [[|Hchannel:Battleground|h<BGL> |h %s: ]]
            CHAT_GUILD_GET = '|Hchannel:Guild|h<G> |h %s: '
            CHAT_OFFICER_GET = '|Hchannel:Officer|h<O> |h %s: '
            CHAT_PARTY_GET = '|Hchannel:Party|h<P> |h %s: '
            CHAT_PARTY_LEADER_GET = [[|Hchannel:Party|h<PL> |h %s: ]]
            CHAT_PARTY_GUIDE_GET = CHAT_PARTY_LEADER_GET
            CHAT_RAID_GET = '|Hchannel:Raid|h<R> |h %s: '
            CHAT_RAID_LEADER_GET = [[|Hchannel:Raid|h<RL> |h %s: ]]
            CHAT_RAID_WARNING_GET = [[|Hchannel:RaidWarning|h<RW> |h %s: ]]
            
            CHAT_MONSTER_PARTY_GET = CHAT_PARTY_GET
            CHAT_MONSTER_SAY_GET = CHAT_SAY_GET
            CHAT_MONSTER_WHISPER_GET = CHAT_WHISPER_GET
            CHAT_MONSTER_YELL_GET = CHAT_YELL_GET
            
            for k, v in pairs(StickyTypeChannels) do
                ChatTypeInfo[k].sticky = v
            end
            
            --toggle class colors
            for i, v in pairs(CHAT_CONFIG_CHAT_LEFT) do
                ToggleChatColorNamesByClassGroup(true, v.type)
            end
            
            --this is to toggle class colors for all the global channels that is not listed under CHAT_CONFIG_CHAT_LEFT
            for iCh = 1, 15 do
                ToggleChatColorNamesByClassGroup(true, 'CHANNEL'..iCh)
            end

            for i = 1, NUM_CHAT_WINDOWS do
                mnkChat.SetupFrame(_G['ChatFrame' .. i])
            end

            mnkChat.hooks.FCF_OpenTemporaryWindow = FCF_OpenTemporaryWindow
            FCF_OpenTemporaryWindow = function(chatType, ...)
                local frame = mnkChat.hooks.FCF_OpenTemporaryWindow(chatType, ...)
                mnkChat.SetupFrame(frame)
                return frame
            end   
        end
    end
    mnkChat.UpdateText()
end

function mnkChat.DoOnClick(self, button)
    if self.tooltip ~= nil then
        self.tooltip:Hide()
    end

    if button == 'RightButton' then
        mnkChat_db.Messages = {}
        mnkChat.UpdateText()
    end
end

function mnkChat.DoOnEnter(self)
    mnkChat_db.NEW_MESSAGES = 0
    if #mnkChat_db.Messages == 0 then
        return
    end

    mnkChat.UpdateText()
    local tooltip = libQTip:Acquire('mnkChatTooltip', 2, 'LEFT', 'LEFT')
    tooltip:SetFont(font)

    self.tooltip = tooltip 
    tooltip:Clear()

    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Message')

    for i = 1, #mnkChat_db.Messages do
        if mnkChat_db.Messages[i].message ~= nil then
            local y, x = tooltip:AddLine(mnkChat_db.Messages[i].name, '')
            tooltip:SetCell(y, 2, mnkChat_db.Messages[i].time..' '..mnkChat_db.Messages[i].message, nil, 'LEFT', nil, nil, nil, nil, GetScreenWidth() / 4, nil)
            tooltip:SetLineScript(y, 'OnMouseDown', mnkChat.DoOnMessageClick, mnkChat_db.Messages[i].fullname)
        end
    end

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling(500)
    tooltip.step = 50
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkChat.DoOnMessageClick(self, arg, button) 
    SetItemRef('player:'..arg, '|Hplayer:'..arg..'|h['..arg..'|h', 'LeftButton')
end

function mnkChat.UpdateText()
    if mnkChat_db.NEW_MESSAGES > 0 then
        mnkChat.LDB.icon = mnkLibs.Textures.icon_new
    else
        mnkChat.LDB.icon = mnkLibs.Textures.icon_none
    end
    mnkChat.LDB.text = mnkChat_db.NEW_MESSAGES
end

function mnkChat.AddMessage(frame, message, ...)
    if string.find(message, 'Changed Channel') or string.find(message, 'Left Channel') then return end
    -- stolen straight from rChat by Zork.
    message = message:gsub('|h%[(%d+)%. .-%]|h', '|h%1.|h')
    message = message:gsub('([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')

    -- Thanks Phanx
    local PLAYER_STYLE = '%s'
    local PLAYER_LINK = '|Hplayer:%s|h' .. PLAYER_STYLE .. '|h'
    local PLAYER_BN_LINK = '|HBNplayer:%s|h' .. PLAYER_STYLE .. '%s|h'
    local PLAYER_PATTERN = '|Hplayer:(.-)|h%[(.-)%]|h'
    local BNPLAYER_PATTERN = '|HBNplayer:(.-|k:(%d+).-)|h%[(.-)%](.*)|h'
    local playerData, playerName = strmatch(message, PLAYER_PATTERN)
    if playerData then
        if strmatch(playerName, '|cff') then
            playerName = gsub(playerName, '%-[^|]+', '')
        else
            playerName = strmatch(playerName, '[^%-]+')
        end
         message = gsub(message, PLAYER_PATTERN, format(PLAYER_LINK, playerData, playerName))
    end

    local bnData, bnID, bnName, bnExtra = strmatch(message, BNPLAYER_PATTERN)
    if bnData and bnID then
        local toastIcon = strmatch(message, '|TInterface\\FriendsFrame\\UI%-Toast%-ToastIcons.-|t')
        if toastIcon then
            local gameIcon = strmatch(message, '|TInterface\\ChatFrame\\UI%-ChatIcon.-|t')
            if gameIcon then
                message = gsub(message, escape(toastIcon), gameIcon, 1)
                bnExtra = gsub(bnExtra, '%s?%(.-%)', '')
            end
        end
        message = gsub(message, BNPLAYER_PATTERN, format(PLAYER_BN_LINK, bnData, bnName, bnExtra or ''))
    end

	mnkChat.hooks[frame].AddMessage(frame, message, ...)
end

function mnkChat.SetupFrame(frame)
    frame:SetClampRectInsets(0, 0, 0, 0)
    frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
    frame:SetMinResize(200, 40) 
    frame:SetFading(false) 
    frame:SetClampedToScreen(false)
    frame:SetScript('OnHyperlinkEnter', function (frame, link, ...)
        local t = link:match('^([^:]+)')
        if t == 'item' then
            GameTooltip:SetOwner(frame, 'ANCHOR_CURSOR') 
            GameTooltip:SetHyperlink(link) 
            GameTooltip:Show() 
        end
    end)
    frame:SetScript('OnHyperlinkLeave', function (frame, ...) GameTooltip:Hide() end)
    frame.ScrollToBottomButton:Hide()
    frame.ScrollToBottomButton:HookScript('OnShow', frame.ScrollToBottomButton.Hide)
    frame.ScrollBar:Hide()
    frame.ScrollBar:HookScript('OnShow', frame.ScrollBar.Hide)

    _G[frame:GetName()..'ButtonFrame']:Hide()
    _G[frame:GetName()..'ButtonFrame']:HookScript('OnShow', _G[frame:GetName()..'ButtonFrame'].Hide)
    _G[frame:GetName()..'ButtonFrameMinimizeButton']:Hide()
    _G[frame:GetName()..'ButtonFrameMinimizeButton']:HookScript('OnShow', _G[frame:GetName()..'ButtonFrameMinimizeButton'].Hide)
    _G[frame:GetName()..'EditBox']:SetAltArrowKeyMode(false)
    
    if GetCVar('chatStyle') == 'classic' then
        _G[frame:GetName()..'EditBox']:ClearAllPoints()
        _G[frame:GetName()..'EditBox']:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 0)
        _G[frame:GetName()..'EditBox']:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, 0)
        _G[frame:GetName()..'EditBox']:SetHeight(25)
    end

    local tex = { _G[frame:GetName()..'EditBox']:GetRegions()}
    for t = 6, #tex do tex[t]:SetAlpha(0) end
    mnkLibs.createTexture(_G[frame:GetName()..'EditBox'], 'BACKGROUND', {1/6, 1/6, 1/6, 1})
    mnkLibs.createBorder(_G[frame:GetName()..'EditBox'], 0, 0, 0, 0, {1/4, 1/4, 1/4, 1})

    _G[frame:GetName()..'EditBoxLeft']:Hide()
    _G[frame:GetName()..'EditBoxMid']:Hide()
    _G[frame:GetName()..'EditBoxRight']:Hide()
    _G[frame:GetName()]:SetFont(mnkLibs.Fonts.ap, 14, '')
    _G[frame:GetName()].SetFont = mnkLibs.donothing
    _G[frame:GetName()..'TabText']:SetFont(mnkLibs.Fonts.oswald, 18, '')
    _G[frame:GetName()..'TabText']:SetShadowOffset(1,1)
    _G[frame:GetName()..'TabText']:SetShadowColor(0,0,0)
    _G[frame:GetName()..'TabText'].SetShadowOffset = mnkLibs.donothing
    _G[frame:GetName()..'TabText'].SetShadowColor = mnkLibs.donothing
    _G[frame:GetName()..'TabText']:SetTextColor(1,1,1)
    _G[frame:GetName()..'TabText']:SetVertexColor(1,1,1)
    _G[frame:GetName()..'TabText'].SetTextColor = mnkLibs.donothing
    _G[frame:GetName()..'TabText'].SetVertexColor = mnkLibs.donothing

    
    -- remove the tab textures.
    for index, value in pairs(tabs) do _G[frame:GetName()..'Tab'..value]:SetTexture(nil) end

	if frame ~= COMBATLOG then
        if not mnkChat.hooks[frame] then
            mnkChat.hooks[frame] = {}
		end
		if not mnkChat.hooks[frame].AddMessage then
			mnkChat.hooks[frame].AddMessage = frame.AddMessage
			frame.AddMessage = mnkChat.AddMessage
		end
	end
end

mnkChat:SetScript('OnEvent', mnkChat.DoOnEvent)
mnkChat:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkChat:RegisterEvent('CHAT_MSG_WHISPER')
mnkChat:RegisterEvent('CHAT_MSG_BN_WHISPER')
