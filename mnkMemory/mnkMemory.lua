mnkMemory = CreateFrame('Frame'); 
mnkMemory.LDB = LibStub:GetLibrary('LibDataBroker-1.1'); 

local LibQTip = LibStub('LibQTip-1.0'); 

local _Elapsed = 0; 
local SPACER = '       '; 


function mnkMemory:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkMemory.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkMemory', {
            icon = 'Interface\\Icons\\Inv_misc_note_05.blp', 
            type = 'data source', 
            OnEnter = mnkMemory.DoOnEnter
        }); 
        self.LDB.label = 'Memory'; 
    end
    
    mnkMemory.UpdateText(); 
end

function mnkMemory.DoOnEnter(self)
    local tooltip = LibQTip:Acquire('mnkMemoryTooltip', 3, 'LEFT', 'RIGHT', 'RIGHT'); 
    self.tooltip = tooltip; 

    local taddons = {}; 

    tooltip:Clear(); 
    tooltip:AddHeader(Color(COLOR_GOLD) .. 'Addon', SPACER, Color(COLOR_GOLD) .. 'Memory'); 

    UpdateAddOnMemoryUsage(); 
    for i = 1, GetNumAddOns() do
        local mem = GetAddOnMemoryUsage(i); 
        name, title, _, _, _, _, _ = GetAddOnInfo(i); 
        taddons[i] = {}; 
        taddons[i].name = name; 
        taddons[i].mem = mem; 
    end

    local sort_func = function(a, b) return a.mem > b.mem end
    table.sort(taddons, sort_func); 
    local x = #taddons; 
    
    if x > 10 then
        x = 10; 
    end

    for i = 1, x do
        tooltip:AddLine(taddons[i].name, SPACER, ReadableMemory(taddons[i].mem)); 
    end
    local l = tooltip:AddLine(); 
    tooltip:SetCell(l, 1, 'Displaying highest 10 addons.', 3); 

    tooltip:SetAutoHideDelay(.1, self); 
    tooltip:SmartAnchorTo(self); 
    tooltip:SetBackdropBorderColor(0, 0, 0, 0); 
    tooltip:Show(); 
end

function mnkMemory.DoOnUpdate(self, elapsed)
    _Elapsed = _Elapsed + elapsed; 

    if _Elapsed >= 1 then 
        mnkMemory.UpdateText(); 
        _Elapsed = 0; 
    end
end

function mnkMemory.UpdateText()
    local memTotal = 0; 

    UpdateAddOnMemoryUsage(); 

    for i = 1, GetNumAddOns() do
        memTotal = memTotal + GetAddOnMemoryUsage(i); 
    end
    mnkMemory.LDB.text = ReadableMemory(memTotal); 
end

mnkMemory:SetScript('OnEvent', mnkMemory.DoOnEvent); 
mnkMemory:SetScript('OnUpdate', mnkMemory.DoOnUpdate); 
mnkMemory:RegisterEvent('PLAYER_LOGIN'); 
