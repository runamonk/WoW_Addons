mnkMisc = CreateFrame("Frame")
currencyOnHand = 0; 

function mnkMisc:DoOnEvent(event, arg1, arg2)
--[[    if OrderHallCommandBar then
        OrderHallCommandBar:Hide(); 
        OrderHallCommandBar.Show = OrderHallCommandBar.Hide; 
    end--]]

    --if addon == "Blizzard_TalkingHeadUI" then
    if event == "ADDON_LOADED" and arg1 == "Blizzard_TalkingHeadUI" then
        hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
            TalkingHeadFrame_CloseImmediately(); 
            TalkingHeadFrame:Hide(); 
        end)
        self:UnregisterEvent("ADDON_LOADED")
    end


    if event == "PLAYER_ENTERING_WORLD" then
        SetCVar("alwaysCompareItems", 0); 
        SetCVar("autoLootDefault", 1); 
        SetCVar("enableFloatingCombatText", 1); 
        currencyOnHand = GetMoney(); 
    elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_CURRENCY" or event == "PLAYER_MONEY" then
        if event == "CHAT_MSG_LOOT" then
            --print("1 "..arg1)
            if arg1 ~= nil then
                local LOOT_ITEM_PATTERN = (LOOT_ITEM_SELF):gsub("%%s", "(.+)");
                local LOOT_ITEM_PUSH_PATTERN = (LOOT_ITEM_PUSHED_SELF):gsub("%%s", "(.+)");
                local LOOT_ITEM_MULTIPLE_PATTERN = (LOOT_ITEM_SELF_MULTIPLE):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)");
                local LOOT_ITEM_PUSH_MULTIPLE_PATTERN = (LOOT_ITEM_PUSHED_SELF_MULTIPLE):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)");
                local LOOT_ITEM_CREATED_SELF_PATTERN  = LOOT_ITEM_CREATED_SELF:gsub("%%s", "(.+)");                
                local l, q = arg1:match(LOOT_ITEM_MULTIPLE_PATTERN)

                --print(l.." * "..q)
                if not l then
                    l, q = arg1:match(LOOT_ITEM_PUSH_MULTIPLE_PATTERN)
                    if not l then
                        q, l = 1, arg1:match(LOOT_ITEM_PATTERN)
                        if not l then
                            q, l = 1, arg1:match(LOOT_ITEM_PUSH_PATTERN)
                            if not l then
                                q, l = 1, arg1:match(LOOT_ITEM_CREATED_SELF_PATTERN)
                            end
                        end
                    end
                end -- not l

                --print("2 "..l)
                if l ~= nil then
                    q = tonumber(q) or 0; 

                    if l:find("battlepet") then
                        local _, speciesID, _, rarity = (":"):split(l); 
                        local color = COLOR_WHITE; 

                        if rarity == 2 then
                            color = COLOR_GREEN; 
                        elseif rarity == 3 then
                            color = COLOR_BLUE; 
                        elseif rarity == 4 then
                            color = COLOR_PURPLE; 
                        elseif rarity == 5 then
                            color = COLOR_GOLD; 
                        else
                            color = COLOR_WHITE; 
                        end

                        local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID); 
                        local s = string.format("|T%s:12|t %s", icon, Color(color)..name); 
                        CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false); 
                    else
                        local c = ""; 
                        if q > 1 then
                            c = " x "..q; 
                        else
                            c = ""; 
                        end
                        
                        local itemName, _, rarity, _, _, itemType, subType, _, _, itemIcon, _ = GetItemInfo(l); 
                        --itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(

                        --print(itemName.." | "..itemType.." | "..subType.." | "..rarity)
                        --if itemType ~= nil and itemName  ~= nil and itemType ~= "Junk" and subType ~= "Junk" then
                        if rarity > 0 then
                            local x = 0; 
                            x = GetItemCount(l); 

                            local color = COLOR_WHITE; 

                            if rarity == 2 then
                                color = COLOR_GREEN; 
                            elseif rarity == 3 then
                                color = COLOR_BLUE; 
                            elseif rarity == 4 then
                                color = COLOR_PURPLE; 
                            elseif rarity == 5 then
                                color = COLOR_GOLD; 
                            else
                                color = COLOR_WHITE; 
                            end
                            
                            if x > 0 then
                                x = " ["..x + q.."]"; 
                            else
                                x = " "; 
                            end
                            
                            local s = string.format("|T%s:12|t %s", itemIcon, Color(color)..itemName..Color(COLOR_WHITE)..c..x); 
                            --print("LOOT:"..s.." | "..itemType.." | "..subType.." | "..rarity.." | "..x)
                            CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false); 
                        end -- if itemtype
                    end -- else
                end -- l
            end -- arg1
        end -- CHAT_MSG_LOOT
        
        if event == "PLAYER_MONEY" then
            local currency = GetMoney(); 
            local x = currency - currencyOnHand or 0; 
            if x > 0 then
                --print(x)
                local s = GetCoinTextureString(x) or nil;
                --print(s)
                if s ~= nil then
                    CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false); 
                    currencyOnHand = currency;
                end 
            end
        end -- PLAYER_MONEY

        if event == "CHAT_MSG_CURRENCY" then
            local CURRENCY_PATTERN = (CURRENCY_GAINED):gsub("%%s", "(.+)")
            local CURRENCY_MULTIPLE_PATTERN = (CURRENCY_GAINED_MULTIPLE):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
            
            local l, c = arg1:match(CURRENCY_MULTIPLE_PATTERN)
            if not l then
                c, l = 1, arg1:match(CURRENCY_PATTERN); 
            end
            if l then
                local name, i, icon = _G.GetCurrencyInfo(tonumber(l:match("currency:(%d+)")))
                local s = string.format("|T%s:12|t %s", icon, name..Color(COLOR_WHITE) .. " x "..c.." ["..i.."]"); 
                --print("CURRENCY: "..s)
                CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false); 
            end
        end --CHAT_MSG_CURRENCY
    end
end

SLASH_RL1 = '/rl'; 
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end

function mnkMisc.QuotedStr(str)
    if str == "" or str == nil then
        return "\"" .. "\""; 
    else
        return "\""..str.."\""; 
    end
end

-- Hide dragon heads
MainMenuBarLeftEndCap:Hide(); 
MainMenuBarRightEndCap:Hide(); 

--Hide open all mail button, it's buggy.
OpenAllMail:Hide(); 

mnkMisc:SetScript("OnEvent", mnkMisc.DoOnEvent); 
mnkMisc:RegisterEvent("PLAYER_ENTERING_WORLD"); 
mnkMisc:RegisterEvent("MERCHANT_SHOW"); 
mnkMisc:RegisterEvent("LOOT_OPENED"); 
mnkMisc:RegisterEvent("GROUP_ROSTER_UPDATE"); 
mnkMisc:RegisterEvent("PLAYER_REGEN_DISABLED"); 
mnkMisc:RegisterEvent("PLAYER_REGEN_ENABLED"); 
mnkMisc:RegisterEvent("GARRISON_TALENT_COMPLETE"); 
mnkMisc:RegisterEvent("GARRISON_TALENT_UPDATE"); 
mnkMisc:RegisterEvent("GARRISON_UPDATE"); 
mnkMisc:RegisterEvent("ADDON_LOADED"); 
mnkMisc:RegisterEvent("BAG_UPDATE"); 
mnkMisc:RegisterEvent("CHAT_MSG_CURRENCY")
mnkMisc:RegisterEvent("CHAT_MSG_LOOT")
mnkMisc:RegisterEvent("PLAYER_MONEY")
