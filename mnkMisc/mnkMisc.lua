mnkMisc = CreateFrame('Frame')
local myaddonName = ...

function mnkMisc:DoOnEvent(event, ...)
    if event == 'ADDON_LOADED' then
        local addonName = ...
        if addonName == 'Blizzard_TalkingHeadUI' then
            hooksecurefunc('TalkingHeadFrame_PlayCurrent', function()
                TalkingHeadFrame_CloseImmediately()
                TalkingHeadFrame:Hide()
            end)
        elseif addonName == myaddonName then
            SetCVar('alwaysCompareItems', 0)
            SetCVar('autoLootDefault', 0)
            --SetCVar('floatingCombatTextCombatDamage', 1)
            SetCVar('enableFloatingCombatText', 1)
            SetCVar('colorChatNamesByClass', 1)
            SetCVar('chatStyle', 'classic')
            OrderHall_CheckCommandBar = mnkLibs.donothing
        end
    elseif event == 'LOOT_READY' then
        -- don't run with auto loot enabled, it will conflict with blizzard code 
        -- to auto loot and sometimes cause an instant disconnect.
        if GetCVar('autoLootDefault') == 1 then return end

        for i = GetNumLootItems(), 1, -1 do
            local link = GetLootSlotLink(i)

            LootSlot(i)
            ConfirmLootSlot(i)
            
            if link then
                if link:find('battlepet') then
                    local _, speciesID, _, rarity = (':'):split(link)
                    local color = GetItemQualityColor(rarity)
                    local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
                    local s = string.format('|T%s|t %s', icon..':16:16:0:0:64:64:4:60:4:60', '|c'..color..name)
                    CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
                else
                    local itemName, _, rarity, _, _, itemType, subType, _, _, itemIcon, _ = GetItemInfo(link)
                    if rarity and rarity > 0 then
                        local _,_,_,color = GetItemQualityColor(rarity)
                        local itemCount = GetItemCount(link)
                        if itemCount > 1 then
                            itemCount = ' ['..itemCount..']'
                        else
                            itemCount = ' '
                        end
                        local s = string.format('|T%s|t %s', itemIcon..':16:16:0:0:64:64:4:60:4:60', '|c'..color..itemName..mnkLibs.Color(COLOR_WHITE)..itemCount)
                        --print(s)
                        CombatText_AddMessage(s, CombatText_StandardScroll, 255, 255, 255, nil, false)
                    end
                end
            end 
        end
    end
end


SLASH_RL1 = '/rl'
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end

-- Hide dragon heads
-- MainMenuBarArtFrame.LeftEndCap:Hide()
-- MainMenuBarArtFrame.RightEndCap:Hide()

--Hide open all mail button, we both hate it.
OpenAllMail:Hide()

BossBanner:Hide()
BossBanner.Hide = mnkLibs.donothing()
BossBanner.Show = mnkLibs.donothing()
BossBanner:UnregisterAllEvents()

LootFrame:Hide()
LootFrame.Show = mnkLibs.donothing()
LootFrame:UnregisterAllEvents()

mnkMisc:SetScript('OnEvent', mnkMisc.DoOnEvent)
mnkMisc:RegisterEvent('ADDON_LOADED')
mnkMisc:RegisterEvent('LOOT_READY')
