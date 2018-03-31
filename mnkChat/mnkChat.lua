mnkChat = CreateFrame("Frame")
mnkChat.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
local libQTip = LibStub('LibQTip-1.0')

tMessages = {}
MAX_MESSAGES = 10
NEW_MESSAGES = 0


local hooks = {}
local color = "0099FF"
local foundurl = false
local hideFrame = function (self) self:Hide() end
local tabs = {"Left","Middle","Right","SelectedLeft","SelectedRight","SelectedMiddle","HighlightLeft","HighlightMiddle","HighlightRight"}
SLASH_CLEAR_CHAT1 = "/clear"

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

-- Stolen straight from PhanxChat.
hooks.FCF_OpenTemporaryWindow = FCF_OpenTemporaryWindow
FCF_OpenTemporaryWindow = function(chatType, ...)
    local frame = hooks.FCF_OpenTemporaryWindow(chatType, ...)
    mnkChat.SetFrameSettings(frame)
    return frame
end

function mnkChat.DoOnChat(event, message, playername, _, _, _, playerstatus, _, _, _, lineid, _, guid, pid)

    if message ~= nil then
        CombatText_AddMessage(StripServerName(playername) .. ': '..message, CombatText_StandardScroll, 255, 0, 0, nil, false)
        table.insert(tMessages, 1, {time, name, message})
        tMessages[1].time = date('%I:%M:%S:%p')
        if string.find(playername, '-') == nil then
            tMessages[1].name = playername
        else
            tMessages[1].name = StripServerName(playername)
        end
        tMessages[1].fullname = playername
        tMessages[1].message = message

        NEW_MESSAGES = NEW_MESSAGES + 1
        if #mnkChat > MAX_MESSAGES then
            for i = #tMessages, MAX_MESSAGES + 1, -1 do
                table.remove(tMessages, i)
            end
        end
    end
end

function mnkChat.DoOnClick(self, button)
    if self.tooltip ~= nil then
        self.tooltip:Hide()
    end

    if button == 'RightButton' then
        tMessages = {}
        mnkChat.UpdateText()
    end
end

function mnkChat.DoOnEnter(self)
    NEW_MESSAGES = 0
    if #tMessages == 0 then
        return
    end

    mnkChat.UpdateText()
    local tooltip = libQTip:Acquire('mnkChatTooltip', 2, 'LEFT', 'LEFT')

    self.tooltip = tooltip 
    tooltip:Clear()

    tooltip:AddHeader(Color(COLOR_GOLD) .. 'Name', Color(COLOR_GOLD) .. 'Message')

    for i = 1, #tMessages do
        if tMessages[i].message ~= nil then
            local y, x = tooltip:AddLine(tMessages[i].name, '')
            tooltip:SetCell(y, 2, tMessages[i].time..' '..tMessages[i].message, nil, 'LEFT', nil, nil, nil, nil, GetScreenWidth() / 4, nil)
            tooltip:SetLineScript(y, 'OnMouseDown', mnkChat.DoOnMessageClick, tMessages[i].fullname)
        end
    end

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling(500)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkChat.DoOnMessageClick(self, arg, button) 
    SetItemRef('player:'..arg, '|Hplayer:'..arg..'|h['..arg..'|h', 'LeftButton')
end

function mnkChat.UpdateText()
    if NEW_MESSAGES > 0 then
        mnkChat.LDB.icon = mnkLibs.Textures.icon_new
    else
        mnkChat.LDB.icon = mnkLibs.Textures.icon_none
    end
    mnkChat.LDB.text = NEW_MESSAGES
end

function mnkChat:DoOnEvent(event, ...)
    QuickJoinToastButton:SetScript("OnShow", hideFrame)
    QuickJoinToastButton:Hide() 
    --FriendsMicroButton:SetScript("OnShow", hideFrame)
    ChatFrameMenuButton:SetScript("OnShow", hideFrame) 
    --FriendsMicroButton:Hide()
    ChatFrameMenuButton:Hide() 

    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame" .. i]
        _G["ChatFrame"..i.."TabText"]:SetFont(mnkLibs.Fonts.oswald, 18, '')
        _G["ChatFrame"..i.."TabText"]:SetTextColor(1,1,1)
        _G["ChatFrame"..i.."TabText"]:SetVertexColor(1,1,1)
        _G["ChatFrame"..i.."TabText"].SetTextColor = function () return end
        _G["ChatFrame"..i.."TabText"].SetVertexColor = function () return end

        -- remove the tab textures.
        for index, value in pairs(tabs) do _G["ChatFrame" .. i..'Tab'..value]:SetTexture(nil) end
                
        mnkChat.SetFrameSettings(f)
    end

    if string.sub(event, 1, 8) == 'CHAT_MSG' then
        PlaySoundFile(mnkLibs.Sounds.incoming_message, "Master")
        mnkChat.DoOnChat(event, ...)
    elseif event == "PLAYER_LOGIN" then
        mnkChat.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkChat', {
            icon = mnkLibs.Textures.icon_none, 
            type = 'data source', 
            OnEnter = mnkChat.DoOnEnter, 
            OnClick = mnkChat.DoOnClick
        }) 

        CHAT_WHISPER_GET = ">> %s: "
        CHAT_WHISPER_INFORM_GET = "<< %s: "
        CHAT_YELL_GET = "|Hchannel:Yell|h<Y> |h %s: "
        CHAT_SAY_GET = "|Hchannel:Say|h<S> |h %s: "
        CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|h<BG> |h %s: "
        CHAT_BATTLEGROUND_LEADER_GET = [[|Hchannel:Battleground|h<BGL> |h %s: ]]
        CHAT_GUILD_GET = "|Hchannel:Guild|h<G> |h %s: "
        CHAT_OFFICER_GET = "|Hchannel:Officer|h<O> |h %s: "
        CHAT_PARTY_GET = "|Hchannel:Party|h<P> |h %s: "
        CHAT_PARTY_LEADER_GET = [[|Hchannel:Party|h<PL> |h %s: ]]
        CHAT_PARTY_GUIDE_GET = CHAT_PARTY_LEADER_GET
        CHAT_RAID_GET = "|Hchannel:Raid|h<R> |h %s: "
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
            ToggleChatColorNamesByClassGroup(true, "CHANNEL"..iCh)
        end
    end
    
    mnkChat.UpdateText()

end

local function OnHyperlinkEnter(frame, link, ...)
    local t = link:match("^([^:]+)")
    if t == "item" then
        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR") 
        GameTooltip:SetHyperlink(link) 
        GameTooltip:Show() 
    end
end

local function OnHyperlinkLeave(frame, ...)
    GameTooltip:Hide() 
end

function mnkChat.SetFrameSettings(frame)
    frame:SetClampRectInsets(0, 0, 0, 0)
    frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
    frame:SetMinResize(200, 40) 
    frame:SetFading(false) 
    frame:SetFont(STANDARD_TEXT_FONT, 11, "") 
    frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
    frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)

    _G[frame:GetName() .. "ButtonFrameUpButton"]:Hide()
    _G[frame:GetName() .. "ButtonFrameUpButton"]:SetScript("OnShow", hideFrame)
    _G[frame:GetName() .. "ButtonFrameDownButton"]:Hide()
    _G[frame:GetName() .. "ButtonFrameDownButton"]:SetScript("OnShow", hideFrame);
    _G[frame:GetName() .. "ButtonFrame"]:Hide()
    _G[frame:GetName() .. "ButtonFrame"]:SetScript("OnShow", hideFrame)
    _G[frame:GetName() .. "ButtonFrameMinimizeButton"]:Hide()
    _G[frame:GetName() .. "ButtonFrameMinimizeButton"]:SetScript("OnShow", hideFrame)
    _G[frame:GetName() .. "EditBox"]:SetAltArrowKeyMode(false)

    if GetCVar("chatStyle") == "classic" then
        _G[frame:GetName() .. "EditBox"]:ClearAllPoints()
        _G[frame:GetName() .. "EditBox"]:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -5, 0)
        _G[frame:GetName() .. "EditBox"]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 5, 0)
    end

end

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

function string.color(text, color)
    return "|cff"..color..text.."|r"
end

function string.link(text, type, value, color)
    return "|H"..type..":"..tostring(value) .. "|h"..tostring(text):color(color or "ffffff") .. "|h"
end

local function highlighturl(before, url, after)
    foundurl = true
    return " "..string.link("["..url.."]", "url", url, color) .. " "
end

local function searchforurl(frame, text, ...)

    foundurl = false

    if string.find(text, "%pTInterface%p+") or string.find(text, "%pTINTERFACE%p+") then
        foundurl = true
    end

    if not foundurl then
        --192.168.1.1:1234
        text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlighturl)
    end
    if not foundurl then
        --192.168.1.1
        text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlighturl)
    end
    if not foundurl then
        --www.teamspeak.com:3333
        text = string.gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlighturl)
    end
    if not foundurl then
        --http://www.google.com
        text = string.gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl)
    end
    if not foundurl then
        --www.google.com
        text = string.gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl)
    end
    if not foundurl then
        --lol@lol.com
        text = string.gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlighturl)
    end

    text = string.gsub(text, "%[(%d)%. General%]", "<1> ")
    text = string.gsub(text, "%[(%d)%. Trade%]", "<2> ")
    text = string.gsub(text, "%[(%d)%. LocalDefense%]", "<3> ")

    local fullName, shortName = strmatch(text, "|Hplayer:(.-)|h%[(.-)%]|h")

    if fullName ~= nil then
        if strmatch(shortName, "|cff") then
            shortName = gsub(shortName, "%-[^|]+", "")
        else
            shortName = strmatch(shortName, "[^%-]+")
        end
        text = gsub(text, "|Hplayer:(.-)|h%[(.-)%]|h", format("|Hplayer:%s|h[%s]|h", fullName, shortName))
    end
    --print(fullName, " ", shortName)
    frame.am(frame, text, ...)
end

for i = 1, NUM_CHAT_WINDOWS do
    if (i ~= 2) then
        local cf = _G["ChatFrame"..i]
        cf.am = cf.AddMessage
        cf.AddMessage = searchforurl
    end
end

local orig = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(frame, link, text, button)
    local type, value = link:match("(%a+):(.+)")
    if (type == "url") then
        local eb = _G[frame:GetName() .. 'EditBox']
        
        eb:Show()
        eb:SetText(value)
        eb:SetFocus()
        eb:HighlightText()
    else
        orig(self, link, text, button)
    end
end

SlashCmdList.CLEAR_CHAT = function()
    for i = 1, NUM_CHAT_WINDOWS do
        _G[format("ChatFrame%d", i)]:Clear()
    end
end

mnkChat:SetScript("OnEvent", mnkChat.DoOnEvent)
mnkChat:RegisterEvent("PLAYER_LOGIN")
mnkChat:RegisterEvent("ADDON_LOADED")
mnkChat:RegisterEvent("CHAT_MSG_WHISPER")
mnkChat:RegisterEvent('CHAT_MSG_WHISPER')
mnkChat:RegisterEvent('CHAT_MSG_BN_WHISPER')
