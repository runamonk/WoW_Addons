mnkMount = CreateFrame("Frame"); 
mnkMount.LDB = LibStub:GetLibrary("LibDataBroker-1.1"); 

BINDING_HEADER_MNKMOUNT = "mnkMount LDB"; 
BINDING_NAME_RANDOM_MOUNT = "Load random mount"; 

local libQTip = LibStub("LibQTip-1.0"); 
local libAG = LibStub("AceGUI-3.0"); 
local fConfig = nil; 
local Hotkey = ""; 

tblMounts = {}; 

scroll = nil; 

function mnkMount:DoOnEvent(event)
    if event == "PLAYER_LOGIN" then
        mnkMount.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("mnkMounts", {
            icon = "Interface\\Icons\\Ability_mount_blackpanther.blp", 
            type = "data source", 
            OnEnter = mnkMount.DoOnEnter, 
            OnClick = mnkMount.DoOnClick
        }); 

        Hotkey, _ = GetBindingKey("RANDOM_MOUNT"); 

        mnkMount.LDB.label = "Mounts"; 
        mnkMount.UpdateText(); 
        --mnkMount.Test();
    end
end

function mnkMount.DoOnEnter(self)
    local tooltip = libQTip:Acquire("mnkMountsToolTip", 1, "LEFT"); 
    self.tooltip = tooltip; 
    tooltip:Clear(); 
    
    if #tblMounts > 0 then
        tooltip:AddHeader(Color(COLOR_GOLD) .. "Favorites" .. " ("..table.getn(tblMounts) .. ")"); 

        for i = 1, #tblMounts do
            local mName, _, mIcon, _, isUsable = C_MountJournal.GetMountInfoByID(tblMounts[i].mID); 
            local sName = ""; 

            if isUsable == false then
                sName = Color(COLOR_GREY)..mName; 
            else
                sName = mName; 
            end
            
            local y = tooltip:AddLine(string.format("|T%s:16|t", mIcon) .. " "..sName); 
            --local y = tooltip:AddLine(sName);

            tooltip:SetLineScript(y, "OnMouseDown", mnkMount.DoOnMouseDown, tblMounts[i].mID); 
        end
    end

    if (#tblMounts == 0) then
        tooltip:AddLine(Color(COLOR_GOLD) .. "No mounts flagged as favorite."); 
        tooltip:AddLine(Color(COLOR_GOLD) .. "Right click on mnkMounts icon to open config."); 
    end

    tooltip:SetAutoHideDelay(.1, self); 
    tooltip:SmartAnchorTo(self); 
    tooltip:Show(); 
end

function mnkMount.DoOnClick(self, button)
    if button == "RightButton" then
        if fConfig ~= nil then
            return; 
        end

        fConfig = libAG:Create("Frame"); 
        fConfig:SetCallback("OnClose", mnkMount.DoOnConfigClose); 
        fConfig:SetTitle("mnkMounts Favorite Mounts"); 
        fConfig:SetStatusText("Check all your favorite mounts."); 
        fConfig:SetLayout("Custom_Layout"); 
        fConfig:SetHeight(550); 
        fConfig:SetWidth(400); 
        fConfig:EnableResize(false); 
        fConfig:PauseLayout(); 

        scroll = mnkMount.AddGroup(fConfig, "Mounts", -2); 
        
        local tblMountIDs = C_MountJournal.GetMountIDs(); 
        local tblMountsAll = {}; 
        local c = 0; 
        
        for i = 1, #tblMountIDs do
            local mName, spellID, mIcon, active, isUsable, _, isFavorite, _, _, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(tblMountIDs[i]); 
            
            if isCollected == true and hideOnChar == false then
                local _, _, _, _, mType = C_MountJournal.GetMountInfoExtraByID(tblMountIDs[i]); 
                c = (c + 1); 
                tblMountsAll[c] = {}; 
                tblMountsAll[c].mName = mName; 
                tblMountsAll[c].mID = tblMountIDs[i]; 
                tblMountsAll[c].mIcon = mIcon; 
                tblMountsAll[c].mType = mType; 
            end
        end 
        
        local sort_func = function(a, b) return a.mName < b.mName end
        table.sort(tblMountsAll, sort_func); 
        
        for i = 1, #tblMountsAll do
            mnkMount.AddCheckbox(mnkMount.GetCheckValue(tblMountsAll[i].mID), tblMountsAll[i].mID, tblMountsAll[i].mName, tblMountsAll[i].mIcon, tblMountsAll[i].mType); 
        end 
        
        table.wipe(tblMountsAll); 
        table.wipe(tblMountIDs); 
        
        l = libAG:Create("Label"); 
        l:SetText("Silver check allows a flying mount to be included in the random selection in a no fly area ie Draenor & Pandaria."); 
        fConfig:AddChild(l); 
        l:SetPoint("BOTTOMLEFT", 5, 50); 
        l:SetWidth(365); 


        l = libAG:Create("Label"); 
        l:SetText("Summon random mount hotkey"); 
        fConfig:AddChild(l); 
        l:SetPoint("BOTTOMLEFT", 5, 13); 

        k = libAG:Create("Keybinding"); 
        k:SetCallback("OnKeyChanged", mnkMount.DoOnHotkeyChanged); 
        k:SetKey(Hotkey); 
        fConfig:AddChild(k); 
        k:SetWidth(100); 
        k:SetPoint("BOTTOMLEFT", 170, 7); 
        fConfig:ResumeLayout(); 
    elseif button == "LeftButton" then
        ToggleCollectionsJournal(1); 
    end
end

function mnkMount.AddCheckbox(value, mID, mName, mIcon, mType)
    local c = libAG:Create("CheckBox"); 
    c:SetValue(value); 
    c:SetCallback("OnValueChanged", mnkMount.DoCheckOnClick); 
    c:SetLabel(string.format("|T%s:22|t %s", mIcon, mName)); 
    c:SetWidth(385); 
    c:SetUserData("mID", mID); 
    c:SetUserData("type", mnkMount.GetMountType(mType)); 
    
    if c:GetUserData("type") == "f" then
        c:SetTriState(true); 
    else
        c:SetTriState(false); 
    end

    scroll:AddChild(c); 
end

function mnkMount.AddGroup(frame, title, pos)
    local g = libAG:Create("InlineGroup"); 
    frame:AddChild(g); 

    g:SetTitle(""); 
    g:SetFullWidth(false); 
    g:SetFullHeight(false); 
    g:SetHeight(400); 
    g:SetWidth(370); 
    g:SetLayout("Custom_Layout"); 
    g:SetPoint("TOPLEFT", pos, 0); 

    local s = libAG:Create("ScrollFrame"); 
    g:AddChild(s); 
    s:SetPoint("TOPLEFT", 0, 0); 
    s:SetHeight(g.frame.height - 45); 
    s:SetWidth(g.frame.width - 20); 
    s:SetLayout("List"); 
    return s; 
end

function mnkMount.CheckPlayerCanFly()
    --local result = false;
    -- there is a bug in some of the instanced zones, they return true for IsFlyable()
    local c = GetCurrentMapContinent(); 
    if c == -1 then
        return false
    else
        return IsFlyableArea(); 
    end
    -- if IsFlyableArea() and not mnkMount.InDraeZone() then
    -- if (mnkMount.InOutland()) and (IsUsableSpell("Expert Riding") or IsUsableSpell("Master Riding")) then
    -- result = true;
    -- elseif (mnkMount.InOldWorld() or mnkMount.InMaelstrom() or mnkMount.InPandaria()) and IsUsableSpell("Flight Master's License") then
    -- result = true;
    -- elseif mnkMount.InNorthrend() and IsUsableSpell("Cold Weather Flying") then
    -- result = true;
    -- end
    -- else
    -- result = false;
    -- end

    -- return result;
end

function mnkMount.DoOnConfigClose(frame)
    table.wipe(tblMounts); 
    
    local x = 0; 
    for i = 1, #scroll.children do
        local v = scroll.children[i]:GetValue(); 

        if v == true or v == nil then
            x = (x + 1); 
            tblMounts[x] = {}; 
            tblMounts[x].mID = scroll.children[i]:GetUserData("mID"); 
            tblMounts[x].value = v; 
            tblMounts[x].type = scroll.children[i]:GetUserData("type"); 
            tblMounts[x].icon = scroll.children[i]:GetUserData("mIcon"); 
        end
    end 

    mnkMount.UpdateText(); 

    if Hotkey ~= nil and Hotkey ~= "" then
        SetBinding(Hotkey, "RANDOM_MOUNT"); 
    else
        SetBinding("RANDOM_MOUNT"); 
    end
    SaveBindings(2); 
    
    libAG:Release(frame); 
    fConfig = nil; 
end

function mnkMount.DoCheckOnClick(self, event, value)

end

function mnkMount.DoOnHotkeyChanged(self, event, key)
    Hotkey = key; 
end

function mnkMount.DoOnMouseDown(button, arg)
    C_MountJournal.SummonByID(arg); 
end

function mnkMount.DoRandomMount()
    
    if IsMounted() then
        Dismount(); 
    elseif InCombatLockdown() then
        PrintError("Cannot summon random mount while in combat."); 
    else
        local tf = {}; 
        local tg = {}; 
        local sh = nil; 
        
        for i = 1, #tblMounts do
            --PrintError(tblMounts[i].type)
            
            local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(tblMounts[i].mID); 
            if isUsable then
                if tblMounts[i].type == "f" then 
                    tf[#tf + 1] = tblMounts[i].mID; 
                end
                if (tblMounts[i].type == "g") or (tblMounts[i].type == "f" and tblMounts[i].value == nil) then
                    tg[#tg + 1] = tblMounts[i].mID; 
                end
                if tblMounts[i].type == "s" then
                    sh = tblMounts[i].mID; 
                end
            end
        end
        
        --PrintError("g:"..#tg, " f:"..#tf)
        if mnkMount.InVashZone() and IsSwimming() and sh ~= nil then
            C_MountJournal.SummonByID(sh); 
        elseif mnkMount.CheckPlayerCanFly() then
            C_MountJournal.SummonByID(tf[math.random(1, #tf)]); 
        elseif #tg > 0 then
            C_MountJournal.SummonByID(tg[math.random(1, #tg)]); 
        else
            PrintError("mnkMount: Cannot randomly summon a mount.")
        end 
    end 
end


function mnkMount.GetMountType(typeid)
    --http://wowpedia.org/API_C_MountJournal.GetMountInfoExtra
    -- 230 for most ground mounts
    -- 231 for  [Riding Turtle] and Sea Turtle
    -- 232 for Vashj'ir Seahorse (was named Abyssal Seahorse prior to Warlords of Draenor)
    -- 241 for [[Blue Qiraji Battle Tank|Blue, Green, Red, and Yellow Qiraji Battle Tank (restricted to use inside Temple of Ahn'Qiraj)
    -- 242 for Swift Spectral Gryphon (hidden in the mount journal, used while dead in certain zones)
    -- 247 for Red Flying Cloud
    -- 248 for most flying mounts, including those that change capability based on riding skill
    -- 254 for Subdued Seahorse
    -- 269 for Azure and Crimson Water Strider
    
    if typeid == 248 or typeid == 247 or typeid == 247 then 
        return "f"; 
    elseif (typeid == 230 or typeid == 231 or typeid == 269) then
        return "g"; 
    elseif typeid == 232 then
        return "s"; 
    else
        return "u"; 
    end
end

--[[
-1 - Cosmic map
0 - Azeroth
1 - Kalimdor
2 - Eastern Kingdoms
3 - Outland
4 - Northrend
5 - The Maelstrom
6 - Pandaria
7 - Draenor
]]--

function mnkMount.InLegionZone()
    local c = GetCurrentMapContinent(); 
    return c == 8; 
end

function mnkMount.InDraeZone()
    local c = GetCurrentMapContinent(); 
    return c == 7; 
end

function mnkMount.InMaelstrom()
    local c = GetCurrentMapContinent(); 
    return c == 5; 
end

function mnkMount.InNorthrend()
    local c = GetCurrentMapContinent(); 
    return c == 4; 
end

function mnkMount.InOldWorld()
    local c = GetCurrentMapContinent(); 
    if c == 0 or c == 1 or c == 2 then
        return true; 
    else
        return false; 
    end
end

function mnkMount.InOutland()
    local c = GetCurrentMapContinent(); 
    return c == 3; 
end

function mnkMount.InPandaria()
    local c = GetCurrentMapContinent(); 
    return c == 6; 
end

function mnkMount.InVashZone()
    local a = {610, 613, 614, 615}; 
    local id = GetCurrentMapAreaID(); 
    return mnkMount.InTable(a, id); 
end

function mnkMount.InTable(t, id)
    local result = false; 
    for i = 1, #t do
        if t[i] == id then
            result = true; 
            break; 
        end
    end
    return result
end

function mnkMount.GetCheckValue(id)
    local result = false; 
    for i = 1, #tblMounts do
        if tblMounts[i].mID == id then
            result = tblMounts[i].value; 
            break; 
        end
    end

    return result; 
end

function mnkMount.UpdateText()
    mnkMount.LDB.text = #tblMounts; 
end

function mnkMount.Test()
    local tblMountIDs = C_MountJournal.GetMountIDs(); 
    for i = 1, #tblMountIDs do
        local mName, _, mIcon = C_MountJournal.GetMountInfoByID(tblMountIDs[i]); 
        print(string.format("|T%s:22|t %s", mIcon, mName)); 
    end 
end

mnkMount:SetScript("OnEvent", mnkMount.DoOnEvent); 
mnkMount:RegisterEvent("PLAYER_LOGIN"); 
mnkMount:RegisterEvent("PLAYER_ENTERING_WORLD"); 

