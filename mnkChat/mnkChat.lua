mnkChat = CreateFrame("Frame"); 

local hooks = {}; 
local color = "0099FF"
local foundurl = false
local hideFrame = function (self) self:Hide() end; 
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
}; 

-- Stolen straight from PhanxChat.
hooks.FCF_OpenTemporaryWindow = FCF_OpenTemporaryWindow
FCF_OpenTemporaryWindow = function(chatType, ...)
    local frame = hooks.FCF_OpenTemporaryWindow(chatType, ...); 
    mnkChat.SetFrameSettings(frame); 
    return frame; 
end

function mnkChat:DoOnEvent(event, ...)
    QuickJoinToastButton:SetScript("OnShow", hideFrame); 
    QuickJoinToastButton:Hide(); 
    --FriendsMicroButton:SetScript("OnShow", hideFrame);
    ChatFrameMenuButton:SetScript("OnShow", hideFrame); 
    --FriendsMicroButton:Hide();
    ChatFrameMenuButton:Hide(); 

    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame" .. i]; 
        mnkChat.SetFrameSettings(f); 
    end
    if event == "CHAT_MSG_WHISPER" then
        PlaySoundFile(mnkLibs.Sounds.incoming_message, "Master")
    elseif event == "PLAYER_LOGIN" then
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
            ChatTypeInfo[k].sticky = v; 
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
end

local function OnHyperlinkEnter(frame, link, ...)
    local t = link:match("^([^:]+)"); 
    if t == "item" then
        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR"); 
        GameTooltip:SetHyperlink(link); 
        GameTooltip:Show(); 
    end
end

local function OnHyperlinkLeave(frame, ...)
    GameTooltip:Hide(); 
end

function mnkChat.SetFrameSettings(frame)
    frame:SetClampRectInsets(0, 0, 0, 0); 
    frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight()); 
    frame:SetMinResize(200, 40); 
    frame:SetFading(false); 
    frame:SetFont(STANDARD_TEXT_FONT, 11, ""); 
    frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter); 
    frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave); 

    _G[frame:GetName() .. "ButtonFrameUpButton"]:Hide(); 
    _G[frame:GetName() .. "ButtonFrameUpButton"]:SetScript("OnShow", hideFrame); 
    _G[frame:GetName() .. "ButtonFrameDownButton"]:Hide(); 
    _G[frame:GetName() .. "ButtonFrameDownButton"]:SetScript("OnShow", hideFrame); 
    _G[frame:GetName() .. "ButtonFrame"]:Hide(); 
    _G[frame:GetName() .. "ButtonFrame"]:SetScript("OnShow", hideFrame); 
    _G[frame:GetName() .. "ButtonFrameMinimizeButton"]:Hide(); 
    _G[frame:GetName() .. "ButtonFrameMinimizeButton"]:SetScript("OnShow", hideFrame); 
    _G[frame:GetName() .. "EditBox"]:SetAltArrowKeyMode(false); 

    if GetCVar("chatStyle") == "classic" then
        _G[frame:GetName() .. "EditBox"]:ClearAllPoints(); 
        _G[frame:GetName() .. "EditBox"]:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -5, 0); 
        _G[frame:GetName() .. "EditBox"]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 5, 0); 
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
    return "|cff"..color..text.."|r"; 
end

function string.link(text, type, value, color)
    return "|H"..type..":"..tostring(value) .. "|h"..tostring(text):color(color or "ffffff") .. "|h"; 
end

local function highlighturl(before, url, after)
    foundurl = true; 
    return " "..string.link("["..url.."]", "url", url, color) .. " "; 
end

local function searchforurl(frame, text, ...)

    foundurl = false; 

    if string.find(text, "%pTInterface%p+") or string.find(text, "%pTINTERFACE%p+") then
        foundurl = true; 
    end

    if not foundurl then
        --192.168.1.1:1234
        text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlighturl); 
    end
    if not foundurl then
        --192.168.1.1
        text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlighturl); 
    end
    if not foundurl then
        --www.teamspeak.com:3333
        text = string.gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlighturl); 
    end
    if not foundurl then
        --http://www.google.com
        text = string.gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl); 
    end
    if not foundurl then
        --www.google.com
        text = string.gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl); 
    end
    if not foundurl then
        --lol@lol.com
        text = string.gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlighturl); 
    end

    text = string.gsub(text, "%[(%d)%. General%]", "<1> "); 
    text = string.gsub(text, "%[(%d)%. Trade%]", "<2> "); 
    text = string.gsub(text, "%[(%d)%. LocalDefense%]", "<3> "); 

    local fullName, shortName = strmatch(text, "|Hplayer:(.-)|h%[(.-)%]|h"); 

    if fullName ~= nil then
        if strmatch(shortName, "|cff") then
            shortName = gsub(shortName, "%-[^|]+", "")
        else
            shortName = strmatch(shortName, "[^%-]+")
        end
        text = gsub(text, "|Hplayer:(.-)|h%[(.-)%]|h", format("|Hplayer:%s|h[%s]|h", fullName, shortName)); 
    end
    --print(fullName, " ", shortName)
    frame.am(frame, text, ...); 
end

for i = 1, NUM_CHAT_WINDOWS do
    if (i ~= 2) then
        local cf = _G["ChatFrame"..i]; 
        cf.am = cf.AddMessage; 
        cf.AddMessage = searchforurl; 
    end
end

local orig = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(frame, link, text, button)
    local type, value = link:match("(%a+):(.+)")
    if (type == "url") then
        local eb = _G[frame:GetName() .. 'EditBox']; 
        
        eb:Show(); 
        eb:SetText(value); 
        eb:SetFocus(); 
        eb:HighlightText(); 
    else
        orig(self, link, text, button); 
    end
end

SlashCmdList.CLEAR_CHAT = function()
    for i = 1, NUM_CHAT_WINDOWS do
        _G[format("ChatFrame%d", i)]:Clear()
    end
end

mnkChat:SetScript("OnEvent", mnkChat.DoOnEvent); 
mnkChat:RegisterEvent("PLAYER_LOGIN"); 
mnkChat:RegisterEvent("ADDON_LOADED"); 
mnkChat:RegisterEvent("CHAT_MSG_WHISPER"); 

