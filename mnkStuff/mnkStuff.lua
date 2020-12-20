local NAME, mnkStuff = ...


mnkStuff = CreateFrame('FRAME')


SLASH_mnkBags1, SLASH_mnkBags2 = '/mnkStuff', '/ms'
function SlashCmdList.mnkBags(msg, editbox)
    --TODO OPEN SETTINGS  
end

function mnkStuff:DoOnEvent(event, ...)
    --print(event)
    if event == 'PLAYER_LOGIN' then
        if mnkStuffDB == nil then
            mnkStuffDB = {}
            mnkStuffDB.backpack_xpos = -50
            mnkStuffDB.backpack_ypos = 50
        end
    end
end

mnkStuff:SetScript('OnEvent', mnkStuff.DoOnEvent)
mnkStuff:RegisterEvent('PLAYER_LOGIN')

