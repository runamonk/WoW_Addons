mnkMisc = CreateFrame('Frame')


function mnkMisc:DoOnEvent(event, arg1, arg2)
    mnkMisc.HideOrderCommandBar()

    if event == 'ADDON_LOADED' then
        local b = _G.OrderHallCommandBar
        if b then
            --print('OrderHallCommandBar Hidden.')
            b:HookScript("OnShow", function() mnkMisc.HideOrderCommandBar() end)
            b:Hide()
        end

        end    
        if arg1 == 'Blizzard_TalkingHeadUI' then
        hooksecurefunc('TalkingHeadFrame_PlayCurrent', function()
            TalkingHeadFrame_CloseImmediately()
            TalkingHeadFrame:Hide()
        end)
    end

    if event == 'PLAYER_ENTERING_WORLD' then
        SetCVar('alwaysCompareItems', 0)
        SetCVar('autoLootDefault', 1)
        SetCVar('enableFloatingCombatText', 1)
    end        

end

SLASH_RL1 = '/rl'
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end

function mnkMisc.HideOrderCommandBar()
    local b = _G.OrderHallCommandBar
	if b then
        b:Hide()
    end
end

-- Hide dragon heads
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()

--Hide open all mail button, it's buggy.
OpenAllMail:Hide()

mnkMisc:SetScript('OnEvent', mnkMisc.DoOnEvent)
mnkMisc:RegisterEvent('ADDON_LOADED')
mnkMisc:RegisterEvent('PLAYER_ENTERING_WORLD')

