mnkChat = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
mnkChat.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkChat.hooks = {}
mnkChat:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkChat:RegisterEvent('PLAYER_LOGIN')
mnkChat:RegisterEvent('CHAT_MSG_WHISPER')
mnkChat:RegisterEvent('CHAT_MSG_BN_WHISPER')

local libQTip = LibStub('LibQTip-1.0')

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

mnkChat.hooks.ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow

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

local function escape(str)
    return gsub(str, "([%%%+%-%.%[%]%*%?])", "%%%1")
end

local function unescape(str)
    return gsub(str, "%%([%%%+%-%.%[%]%*%?])", "%1")
end

function mnkChat:Message(event, message, playername, _, _, _, _, _, _, _, _, _, _, bnSenderID)
    --"text", "playerName", "languageName", "channelName", "playerName2", "specialFlags", zoneChannelID, channelIndex, "channelBaseName", unused, 
    -- lineID, "guid", bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons

    if message ~= nil then
        --print(event, ' ', playername, bnSenderID)
        PlaySoundFile(mnkLibs.Sounds.incoming_message, 'Master')
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
        mnkChat_db.Messages[1].isbn = bnSenderID 
        mnkChat_db.NEW_MESSAGES = mnkChat_db.NEW_MESSAGES + 1
        if #mnkChat > MAX_MESSAGES then
            for i = #mnkChat_db.Messages, MAX_MESSAGES + 1, -1 do
                table.remove(mnkChat_db.Messages, i)
            end
        end
    end
    mnkChat:UpdateText()
end

function mnkChat:CHAT_MSG_WHISPER(event, ...)
    mnkChat:Message(event, ...)    
end

function mnkChat:CHAT_MSG_BN_WHISPER(event, ...)
    mnkChat:Message(event, ...)    
end

function mnkChat:OnClick(self, button)
    if button == 'RightButton' then
        mnkChat.tooltip:Hide()
        mnkChat_db.Messages = {}
        print('Chat history cleared.')
        mnkChat:UpdateText()
    end
end

function mnkChat:OnEnter(parent)
    function OnClick(self, arg, button)
        if arg.isbn and arg.isbn > 0 then
            ChatFrame_SendBNetTell(arg.fullname)
        else
            ChatFrame_SendTell(arg.fullname)
        end
    end

    mnkChat_db.NEW_MESSAGES = 0
    if #mnkChat_db.Messages == 0 then
        return
    end

    mnkChat.UpdateText()
    local tooltip = libQTip:Acquire('mnkChatTooltip', 3, 'LEFT', 'LEFT', 'RIGHT')
    tooltip:SetFont(font)

    self.tooltip = tooltip 
    mnkChat.tooltip = tooltip

    tooltip:Clear()

    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Message', mnkLibs.Color(COLOR_GOLD)..'Timestamp')

    for i = 1, #mnkChat_db.Messages do
        if mnkChat_db.Messages[i].message ~= nil then
            local y, x = tooltip:AddLine(mnkChat_db.Messages[i].name, '')
            tooltip:SetCell(y, 2, mnkChat_db.Messages[i].message, nil, 'LEFT', nil, nil, nil, nil, GetScreenWidth() / 4, nil)
            tooltip:SetCell(y, 3, mnkChat_db.Messages[i].time, nil, 'RIGHT', nil, nil, nil, nil, nil, nil)
            tooltip:SetLineScript(y, 'OnMouseDown', OnClick, mnkChat_db.Messages[i])
        end
    end

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:UpdateScrolling(500)
    tooltip.step = 50
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    -- tooltip:SetBackdrop(GameTooltip:GetBackdrop())
    -- tooltip:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
    -- tooltip:SetBackdropColor(GameTooltip:GetBackdropColor())
    -- tooltip:SetScale(GameTooltip:GetScale())
    mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    tooltip:SetBackdropColor(0, 0, 0, 1)    
    tooltip:Show()
end

function mnkChat:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkChat', {
        icon = mnkLibs.Textures.icon_none, 
        type = 'data source', 
        OnEnter = function (parent) self:OnEnter(parent) end, 
        OnClick = function (parent, button) self:OnClick(parent, button) end
    })
    mnkLibs.setBackdrop(self, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    self:SetBackdropColor(0, 0, 0, 1)

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
        mnkChat:SetupFrame(_G['ChatFrame' .. i])
    end

    self.hooks.FCF_OpenTemporaryWindow = FCF_OpenTemporaryWindow
    FCF_OpenTemporaryWindow = function(chatType, ...)
        local frame = mnkChat.hooks.FCF_OpenTemporaryWindow(chatType, ...)
        self:SetupFrame(frame)
        return frame
    end
    self:UpdateText()   
end

function mnkChat:SetupFrame(frame)
    local function AddMessage(frame, message, ...)
        if string.find(message, 'Changed Channel') or string.find(message, 'Left Channel') then return end
        -- stolen straight from rChat by Zork.
        message = message:gsub('|h%[(%d+)%. .-%]|h', '|h%1.|h')
        message = message:gsub('([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')

        -- Thanks Phanx
        local PLAYER_LINK = '|Hplayer:%s|h%s|h'
        local PLAYER_PATTERN = '|Hplayer:(.-)|h%[(.-)%]|h'
        local playerData, playerName = strmatch(message, PLAYER_PATTERN)

        if playerData then
            playerName = gsub(playerName, '%-[^|]+', '')
            message = gsub(message, PLAYER_PATTERN, format(PLAYER_LINK, playerData, playerName))
        end
        mnkChat.hooks[frame].AddMessage(frame, message, ...)
    end

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
			frame.AddMessage = AddMessage
		end
	end
end

function mnkChat:UpdateText()
    if mnkChat_db.NEW_MESSAGES > 0 then
        mnkChat.LDB.icon = mnkLibs.Textures.icon_new
    else
        mnkChat.LDB.icon = mnkLibs.Textures.icon_none
    end
    mnkChat.LDB.text = ' '..mnkChat_db.NEW_MESSAGES
end
