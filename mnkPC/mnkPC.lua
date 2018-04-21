mnkPC = CreateFrame('Frame')
mnkPC.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')
local _Elapsed = 0

function mnkPC:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkPC.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkPC', {
            icon = 'Interface\\Icons\\Achievement_guildperk_fasttrack.blp', 
            type = 'data source', 
            OnEnter = mnkPC.DoOnEnter
        })
        mnkPC.LDB.label = 'FPS/Latency'
    end
    mnkPC.UpdateText()
end

function mnkPC.DoOnEnter(self)

end

function mnkPC.DoOnUpdate(self, elapsed)
    _Elapsed = _Elapsed + elapsed

    if _Elapsed >= 1 then 
        mnkPC.UpdateText()
        _Elapsed = 0
    end
end

function mnkPC.UpdateText()
    local down, up, lagHome, lagWorld = GetNetStats()
    mnkPC.LDB.text = math.floor(GetFramerate())..' fps / '..lagWorld..' ms'
end

mnkPC:SetScript('OnEvent', mnkPC.DoOnEvent)
mnkPC:SetScript('OnUpdate', mnkPC.DoOnUpdate)
mnkPC:RegisterEvent('PLAYER_LOGIN')

