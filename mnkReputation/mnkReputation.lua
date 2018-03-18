mnkReputation = CreateFrame("Frame"); 
mnkReputation.LDB = LibStub:GetLibrary("LibDataBroker-1.1"); 

local libQTip = LibStub("LibQTip-1.0"); 
local libAG = LibStub("AceGUI-3.0"); 
local fConfig = nil; 
local bEnteredWorld = false; 

tblFactions = {}; 
tblAllFactions = {}; 
tblTabards = {}; 

AutoTabard = nil; 

sFactions = nil; 
iExalted = 0; 
iHated = 0; 
iHonored = 0; 

function mnkReputation:DoOnEvent(event, arg1)
    if event == "PLAYER_LOGIN" then
        mnkReputation.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("mnkReputation", {
            icon = "Interface\\Icons\\Inv_misc_bone_skull_02.blp", 
            type = "data source", 
            OnEnter = mnkReputation.DoOnEnter, 
            OnClick = mnkReputation.DoOnClick
        }); 
        
        mnkReputation.LDB.label = "Factions"; 
    end
    if (event == "PLAYER_LOGIN") or (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
        if (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") and (arg1 ~= nil) then
            CombatText_AddMessage(arg1, CombatText_StandardScroll, 255, 255, 255, nil, false); 
        end
        mnkReputation.GetAllFactions(); 
        mnkReputation.UpdateText(); 
    end
    if (event == "PLAYER_ENTERING_WORLD") or (event == "BAG_UPDATE") then
        if event == "PLAYER_ENTERING_WORLD" and not bEnteredWorld then
            bEnteredWorld = true; 
        end

        if event == "PLAYER_ENTERING_WORLD" and (AutoTabard ~= nil) then
            mnkReputation.CheckTabard(); 
        end
        if bEnteredWorld then
            mnkReputation.GetAllTabards(); 
        end
    end
    if (event == "ZONE_CHANGED_NEW_AREA") and (AutoTabard ~= nil) then
        mnkReputation.CheckTabard(); 
    end
end

function mnkReputation.DoOnClick(self, button)
    if button == "RightButton" then
        --if fConfig ~= nil then
        --  return;
        --end
        if fConfig == nil then
            fConfig = libAG:Create("Frame"); 
            fConfig:SetCallback("OnClose", mnkReputation.DoOnConfigClose); 
            fConfig:SetTitle("mnkReputation Favorite Factions"); 
            fConfig:SetStatusText("Check factions you want to watch."); 
            fConfig:SetHeight(500); 
            fConfig:SetWidth(400); 
            fConfig:EnableResize(false); 
            fConfig:SetLayout("Fill"); 
            fConfig:PauseLayout(); 
            g = libAG:Create("InlineGroup"); 
            g:SetTitle("Factions"); 
            g:SetLayout("Fill"); 

            sFactions = libAG:Create("ScrollFrame"); 
            sFactions:SetLayout("List"); 
            g:AddChild(sFactions); 
            fConfig:AddChild(g); 
        else
            fConfig:Show(); 
        end

        sFactions.ReleaseChildren(sFactions); 
        mnkReputation.GetAllFactions(); 
        local header = ""; 

        for i = 1, #tblAllFactions do
            if header ~= tblAllFactions[i].header then
                header = tblAllFactions[i].header; 
                local s = (tblAllFactions[i].max - tblAllFactions[i].current); 
                mnkReputation.AddLabel(sFactions, header, " ("..tblAllFactions[i].standing.." - "..tostring(s) .. ")"); 
            end
            mnkReputation.AddCheckbox(sFactions, mnkReputation.InTable(tblFactions, tblAllFactions[i].name), tblAllFactions[i].name, tblAllFactions[i].standingid, tblAllFactions[i].standing, mnkReputation.GetRepLeft(tblAllFactions[i].max - tblAllFactions[i].current)); 
        end

        fConfig:ResumeLayout(); 
    elseif button == "LeftButton" then
        ToggleCharacter("ReputationFrame"); 
    end
end

function mnkReputation.DoOnConfigClose(frame)
    mnkReputation.UpdateTable(tblFactions, sFactions); 
    mnkReputation.UpdateText(); 

    --libAG:Release(fConfig);
    --fConfig = nil;
end

function mnkReputation.DoOnEnter(self)
    local color = COLOR_WHITE; 
    local tooltip = libQTip:Acquire("mnkReputationToolTip", 3, "LEFT", "LEFT", "RIGHT"); 

    mnkReputation.tooltip = tooltip; 

    tooltip:Clear(); 
    
    if #tblFactions == 0 then
        tooltip:AddLine("You have not selected any factions to display."); 
        tooltip:AddLine("Right click on mnkReputation to open the config."); 
    else 
        table.sort(tblAllFactions, function(a, b) return a.name < b.name end); 

        tooltip:AddHeader(Color(COLOR_GOLD) .. "Name", Color(COLOR_GOLD) .. "Reputation", Color(COLOR_GOLD) .. "To go"); 

        for i = 1, #tblAllFactions do
            if mnkReputation.InTable(tblFactions, tblAllFactions[i].name) == true then
                if tblAllFactions[i].header == ".Guild." then
                    tooltip:AddLine(Color(mnkReputation.GetFactionColor(tblAllFactions[i].standingid)) .. "<"..tblAllFactions[i].name..">", tblAllFactions[i].standing, mnkReputation.GetRepLeft(tblAllFactions[i].max - tblAllFactions[i].current)); 
                else 
                    tooltip:AddLine(Color(mnkReputation.GetFactionColor(tblAllFactions[i].standingid))..tblAllFactions[i].name, tblAllFactions[i].standing, mnkReputation.GetRepLeft(tblAllFactions[i].max - tblAllFactions[i].current)); 
                end
            end
        end
        
        tooltip:AddLine(" "); 
        local y, x = tooltip:AddLine(); 
        tooltip:SetCell(y, 1, Color(COLOR_PURPLE) .. "Exalted: "..Color(COLOR_WHITE)..iExalted..Color(COLOR_GREEN) .. " Honored/Revered: "..Color(COLOR_WHITE)..iHonored..Color(COLOR_RED) .. " Hated: "..Color(COLOR_WHITE)..iHated, "LEFT", 3); 
    end

    mnkReputation.AddTabards(tooltip); 

    tooltip:SetAutoHideDelay(.1, self); 
    tooltip:SmartAnchorTo(self); 
    tooltip:UpdateScrolling(500); 
    tooltip:SetBackdropBorderColor(0, 0, 0, 0); 
    tooltip:Show(); 
end

function mnkReputation.AddCheckbox(scrollbox, checked, name, standingid, standing, rating)
    local c = libAG:Create("CheckBox"); 
    c:SetValue(checked); 
    c:SetLabel(name.." ["..Color(mnkReputation.GetFactionColor(standingid))..standing..Color(COLOR_WHITE) .. "] "..Color(COLOR_WHITE)..rating); 
    c:SetUserData("name", name); 
    c:SetWidth(400); 
    scrollbox:AddChild(c); 
end

function mnkReputation.AddLabel(scrollbox, name, standing)
    local c = libAG:Create("Label"); 
    c:SetText(" "); 
    scrollbox:AddChild(c); 

    local c = libAG:Create("Label"); 
    c:SetText(Color(COLOR_GOLD)..name..standing); 
    c:SetWidth(400); 
    scrollbox:AddChild(c); 
end

function mnkReputation.AddTabards(t)
    if #tblTabards > 0 then
        t:AddLine(" "); 
        t:AddHeader(Color(COLOR_GOLD) .. "Tabard Name", "", ""); 
        local i = 0; 
        for i = 1, #tblTabards do
            local y = t:AddLine(); 
            t:SetCell(y, 1, string.format("|T%s:16|t %s", tblTabards[i].itemTexture, tblTabards[i].itemName), 2); 
            t:SetLineScript(y, "OnMouseDown", mnkReputation.TabardClick, i); 
            if tblTabards[i].itemName == AutoTabard then
                t:SetCell(y, 3, string.format("|T%s:16|t", "Interface\\Buttons\\UI-CheckBox-Check")); 
            end
        end
        t:AddLine(" "); 
        t:AddLine("Click on a tabard to auto equip in instances.")
    end
end

function mnkReputation.CheckTabard()
    inInstance, instanceType = IsInInstance(); 
    if (not inInstance) or (instanceType == "none") or (AutoTabard == nil) then
        mnkReputation.RemoveTabard(); 
    elseif inInstance and (instanceType ~= "none") then
        mnkReputation.EquipTabard(); 
    end
end

function mnkReputation.EquipTabard()
    EquipItemByName(AutoTabard); 
end

function mnkReputation.GetAllFactions()
    table.wipe(tblAllFactions); 

    local x = GetNumFactions(); 
    local idx = 0; 
    local header = ""; 

    iExalted = 0; 
    iHated = 0; 
    iHonored = 0; 

    for i = 1, x do
        local name, _, standingId, _, max, current, _, _, isHeader, isCollapsed, hasRep, _, _ = GetFactionInfo(i); 

        --name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
        
        if isHeader then
            header = name; 
            --PrintError(name, " ", hasRep);
        end

        if isHeader and isCollapsed then
            ExpandFactionHeader(i); 
            local x = GetNumFactions(); 
        end

        if (isHeader == 0 or isHeader == false) or (isHeader and hasRep) then 
            if standingId == 8 then
                iExalted = iExalted + 1; 
            elseif standingId >= 1 and standingId <= 3 then
                iHated = iHated + 1; 
            elseif standingId >= 4 and standingId <= 7 then
                iHonored = iHonored + 1; 
            end


            idx = idx + 1; 
            tblAllFactions[idx] = {}; 
            if header == "Guild" then
                header = ".Guild."; 
            end
            tblAllFactions[idx].header = header; 
            tblAllFactions[idx].name = name; 
            tblAllFactions[idx].standingid = standingId; 
            tblAllFactions[idx].standing = _G['FACTION_STANDING_LABEL'..standingId]; 
            tblAllFactions[idx].current = current; 
            tblAllFactions[idx].max = max; 
            tblAllFactions[idx].hasrep = hasRep; 
        end
    end

    local function sort_func(a, b)
        if a.header == b.header then
            return a.name < b.name; 
        else
            return a.header < b.header; 
        end
    end

    table.sort(tblAllFactions, sort_func); 
end

function mnkReputation.GetAllTabards()
    tblTabards = {}; 
    local i = 0; 
    local slotId, _, _ = GetInventorySlotInfo("TabardSlot"); 
    local itemId = GetInventoryItemID("player", slotId); 

    if itemId ~= nil then
        i = 1; 
        local itemName, _, _, _, _, _, _, _, itemEquipLoc, itemTexture, _ = GetItemInfo(itemId); 
        tblTabards[i] = {}; 
        tblTabards[i].itemName = itemName; 
        tblTabards[i].itemEquipLoc = itemEquipLoc; 
        tblTabards[i].itemTexture = itemTexture; 
    end

    for b = 0, NUM_BAG_SLOTS do
        for s = 1, GetContainerNumSlots(b) do
            local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(b, s); 
            if itemLink ~= nil then
                local itemName, _, _, _, _, _, _, _, itemEquipLoc, itemTexture, _ = GetItemInfo(itemLink); 
                if itemEquipLoc == "INVTYPE_TABARD" then
                    i = (i + 1); 
                    tblTabards[i] = {}; 
                    tblTabards[i].itemName = itemName; 
                    tblTabards[i].itemEquipLoc = itemEquipLoc; 
                    tblTabards[i].itemTexture = itemTexture; 
                end
            end
        end
    end
    table.sort(tblTabards, function(a, b) return a.itemName < b.itemName end); 
end

function mnkReputation.GetFirstEmptyBagSlot()
    local result = 0; 

    for b = 0, NUM_BAG_SLOTS do
        i, t = GetContainerNumFreeSlots(b); 
        if i > 0 and t == 0 then
            --PrintError(b, " ", i, " ", t)
            --bags are numbered 19 to 23
            return b + 19; 
        end
    end
    return result; 
end

function mnkReputation.GetRepLeft(amt)
    if amt == 0 or amt == 1 then
        return ""; 
    else
        return TruncNumber(amt, 0); 
    end
end


function mnkReputation.GetFactionColor(standingid)
    --[[
1 - Hated
2 - Hostile
3 - Unfriendly
4 - Neutral
5 - Friendly
6 - Honored
7 - Revered
8 - Exalted
]]--

    if standingid == 8 then
        return COLOR_PURPLE; 
    elseif standingid >= 1 and standingid <= 3 then
        return COLOR_RED; 
    elseif standingid == 4 then
        return COLOR_YELLOW; 
    elseif standingid >= 5 and standingid <= 7 then
        return COLOR_GREEN; 
    else
        return COLOR_WHITE; 
    end
end

function mnkReputation.InTable(t, name)
    local result = false
    for i = 1, #t do 
        if t[i].name == name then
            result = true; 
        end
    end
    return result; 
end

function mnkReputation.RemoveTabard()
    ClearCursor(); 
    PickupInventoryItem(GetInventorySlotInfo("TabardSlot")); 
    local b = mnkReputation.GetFirstEmptyBagSlot(); 
    if b == 19 then
        PutItemInBackpack(); 
    else
        PutItemInBag(b); 
    end
    ClearCursor(); 
end

function mnkReputation.TabardClick(self, arg, button)
    local newTabard = string.format("|T%s:16|t %s", tblTabards[arg].itemTexture, tblTabards[arg].itemName); 
    local oldTabard = AutoTabard; 
    local b = nil; 

    local i = 0; 
    local x = mnkReputation.tooltip:GetLineCount(); 

    for i = x, 1, -1 do
        local s = mnkReputation.tooltip.lines[i].cells[1].fontString:GetText(); 
        --if they click on same one we uncheck it.
        if (tblTabards[arg].itemName == oldTabard) then
            if (s == newTabard) then
                mnkReputation.tooltip:SetCell(i, 3, nil); 
                AutoTabard = nil; 
                oldTabard = nil; 
                newTabard = nil; 
            end
            --clicked a new tabard
        elseif string.find(s, tblTabards[arg].itemName) ~= nil then
            mnkReputation.tooltip:SetCell(i, 3, string.format("|T%s:16|t", "Interface\\Buttons\\UI-CheckBox-Check")); 
            AutoTabard = tblTabards[arg].itemName; 
            newTabard = nil; 
        elseif (oldTabard ~= nil) and string.find(s, oldTabard) ~= nil then
            mnkReputation.tooltip:SetCell(i, 3, nil); 
            oldTabard = nil; 
        end
        if (mnkReputation.tooltip.lines[i].is_header) or ((oldTabard == nil) and (newTabard == nil)) then
            break; 
        end
    end

    mnkReputation.CheckTabard(); 
end

function mnkReputation.UpdateTable(t, scrollbox)
    table.wipe(t); 
    
    local x = 0
    for i = 1, #scrollbox.children do
        if scrollbox.children[i].type == "CheckBox" and scrollbox.children[i]:GetValue() == true then
            x = (x + 1); 
            t[x] = {}; 
            t[x].name = scrollbox.children[i]:GetUserData("name"); 
        end
    end 
end

function mnkReputation.UpdateText()
    mnkReputation.LDB.text = Color(COLOR_PURPLE)..iExalted..Color(COLOR_WHITE) .. " / "..Color(COLOR_GREEN)..iHonored..Color(COLOR_WHITE) .. " / "..Color(COLOR_RED)..iHated; 
end

mnkReputation:SetScript("OnEvent", mnkReputation.DoOnEvent); 
mnkReputation:RegisterEvent("PLAYER_LOGIN"); 
mnkReputation:RegisterEvent("PLAYER_ENTERING_WORLD")
mnkReputation:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE"); 
mnkReputation:RegisterEvent("PLAYER_ENTERING_WORLD"); 
mnkReputation:RegisterEvent("ZONE_CHANGED_NEW_AREA"); 
mnkReputation:RegisterEvent("BAG_UPDATE"); 


