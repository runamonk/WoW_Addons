mnkMisc = CreateFrame('Frame')

function mnkMisc:DoOnEvent(event, arg1, arg2)
    if event == 'ADDON_LOADED' then
        if arg1 == 'Blizzard_TalkingHeadUI' then
            hooksecurefunc('TalkingHeadFrame_PlayCurrent', function()
                TalkingHeadFrame_CloseImmediately()
                TalkingHeadFrame:Hide()
            end)
        elseif arg1 == 'mnkMisc' then
            SetCVar('alwaysCompareItems', 0)
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

