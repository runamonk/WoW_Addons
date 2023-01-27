mnkMisc = CreateFrame('Frame')
mnkMisc:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkMisc:RegisterEvent('ADDON_LOADED')
mnkMisc:RegisterEvent('PLAYER_LOGIN')

function mnkMisc:ADDON_LOADED(event, arg1, arg2)
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
        --OrderHall_CheckCommandBar = mnkLibs.donothing
    end
end

function mnkMisc:PLAYER_LOGIN()
    -- Hide dragon heads
    -- MainMenuBarArtFrame.LeftEndCap:Hide()
    -- MainMenuBarArtFrame.RightEndCap:Hide()

    --Hide open all mail button, we both hate it.
    --OpenAllMail:Hide()

    --BossBanner:Hide()
    --BossBanner.Hide = mnkLibs.donothing()
    --BossBanner.Show = mnkLibs.donothing()
    --BossBanner:UnregisterAllEvents()
end

SLASH_RL1 = '/rl'
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end
