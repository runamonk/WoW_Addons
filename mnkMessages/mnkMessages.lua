mnkMessages = CreateFrame("Frame")
mnkMessages.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local libQTip = LibStub("LibQTip-1.0")

tMessages = {}
MAX_MESSAGES = 10
NEW_MESSAGES = 0

function mnkMessages:DoOnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        mnkMessages.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("mnkMessages", {
            icon = mnkLibs.Textures.icon_none, 
            type = "data source", 
            OnEnter = mnkMessages.DoOnEnter, 
            OnClick = mnkMessages.DoOnClick
        }) 
    elseif string.sub(event, 1, 8) == "CHAT_MSG" then
        mnkMessages.DoOnChat(event, ...)
    end
    mnkMessages.UpdateText()
end

function mnkMessages.DoOnChat(event, message, playername, _, _, _, playerstatus, _, _, _, lineid, _, guid, pid)

    if message ~= nil then
        CombatText_AddMessage(StripServerName(playername) .. ": "..message, CombatText_StandardScroll, 255, 0, 0, nil, false); 
        table.insert(tMessages, 1, {time, name, message})
        tMessages[1].time = date("%I:%M:%S:%p")
        if string.find(playername, "-") == nil then
            tMessages[1].name = playername
        else
            tMessages[1].name = StripServerName(playername)
        end
        tMessages[1].fullname = playername
        tMessages[1].message = message

        NEW_MESSAGES = NEW_MESSAGES + 1
        if #mnkMessages > MAX_MESSAGES then
            for i = #tMessages, MAX_MESSAGES + 1, -1 do
                table.remove(tMessages, i)
            end
        end
    end
end

function mnkMessages.DoOnClick(self, button)
    if self.tooltip ~= nil then
        self.tooltip:Hide()
    end

    if button == "RightButton" then
        tMessages = {}
        mnkMessages.UpdateText()
    end
end

function mnkMessages.DoOnEnter(self)
    NEW_MESSAGES = 0
    if #tMessages == 0 then
        return
    end

    mnkMessages.UpdateText()
    local tooltip = libQTip:Acquire("mnkMessagesTooltip", 2, "LEFT", "LEFT")

    self.tooltip = tooltip 
    tooltip:Clear()

    tooltip:AddHeader(Color(COLOR_GOLD) .. "Name", Color(COLOR_GOLD) .. "Message"); 

    for i = 1, #tMessages do
        if tMessages[i].message ~= nil then
            local y, x = tooltip:AddLine(tMessages[i].name, ""); 
            tooltip:SetCell(y, 2, tMessages[i].time.." "..tMessages[i].message, nil, "LEFT", nil, nil, nil, nil, GetScreenWidth() / 4, nil); 
            tooltip:SetLineScript(y, "OnMouseDown", mnkMessages.DoOnMessageClick, tMessages[i].fullname); 
        end
    end

    tooltip:SetAutoHideDelay(.1, self); 
    tooltip:SmartAnchorTo(self); 
    tooltip:UpdateScrolling(500); 
    tooltip:SetBackdropBorderColor(0, 0, 0, 0); 
    tooltip:Show(); 
end

function mnkMessages.DoOnMessageClick(self, arg, button) 
    SetItemRef("player:"..arg, "|Hplayer:"..arg.."|h["..arg.."|h", "LeftButton")
end

function mnkMessages.UpdateText()
    if NEW_MESSAGES > 0 then
        mnkMessages.LDB.icon = mnkLibs.Textures.icon_new
    else
        mnkMessages.LDB.icon = mnkLibs.Textures.icon_none
    end
    mnkMessages.LDB.text = NEW_MESSAGES
end

mnkMessages:SetScript("OnEvent", mnkMessages.DoOnEvent)
mnkMessages:RegisterEvent("PLAYER_LOGIN")
mnkMessages:RegisterEvent("CHAT_MSG_WHISPER")
mnkMessages:RegisterEvent("CHAT_MSG_BN_WHISPER")

