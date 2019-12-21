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
            SetCVar('autoLootDefault', 1)
            --SetCVar('floatingCombatTextCombatDamage', 1)
            SetCVar('enableFloatingCombatText', 1)
            SetCVar('colorChatNamesByClass', 1)
            SetCVar('chatStyle', 'classic')
            OrderHall_CheckCommandBar = mnkLibs.donothing
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

mnkMisc:SetScript('OnEvent', mnkMisc.DoOnEvent)
mnkMisc:RegisterEvent('ADDON_LOADED')

