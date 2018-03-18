mnkGearSets = CreateFrame("Frame"); 
mnkGearSets.LDB = LibStub:GetLibrary("LibDataBroker-1.1"); 

local LibQTip = LibStub("LibQTip-1.0"); 
local _Elapsed = 0; 

function mnkGearSets:DoOnEvent(event)
    if event == "PLAYER_LOGIN" then
        mnkGearSets.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("mnkGearSets", {
            icon = "Interface\\Icons\\Inv_misc_enggizmos_30.blp", 
            type = "data source", 
            OnEnter = mnkGearSets.DoOnEnter, 
            OnClick = mnkGearSets.DoOnClick
        }); 
        mnkGearSets.LDB.label = "Gear Sets"; 
    end
    mnkGearSets.UpdateText(); 
end

function mnkGearSets.DoOnClick(self, button)
    ToggleCharacter("PaperDollFrame"); 
    --ToggleCharacter("EquipmentManager")
end

function mnkGearSets.DoOnEnter(self)
    local x = GetNumEquipmentSets(); 

    if x > 0 then
        local tooltip = LibQTip:Acquire("mnkGearSetsTooltip", 1, "LEFT", "LEFT"); 

        self.tooltip = tooltip; 
        tooltip:Clear(); 
        tooltip:AddHeader(Color(COLOR_GOLD) .. "Name"); 

        for i = 1, x do
            local name, icon, _ = GetEquipmentSetInfo(i); 
            local y, x = tooltip:AddLine(string.format("|T%s:16|t %s", icon, name)); 
            tooltip:SetLineScript(y, "OnMouseDown", mnkGearSets.DoOnSetClick, name); 
        end
        tooltip:SetAutoHideDelay(.1, self); 
        tooltip:SmartAnchorTo(self); 
        tooltip:SetBackdropBorderColor(0, 0, 0, 0); 
        tooltip:Show(); 
    end
end

function mnkGearSets.DoOnSetClick(self, arg, button) 
    UseEquipmentSet(arg); 
end

function mnkGearSets.UpdateText()
    mnkGearSets.LDB.text = GetNumEquipmentSets(); 
end

mnkGearSets:SetScript("OnEvent", mnkGearSets.DoOnEvent); 
mnkGearSets:RegisterEvent("PLAYER_LOGIN"); 
mnkGearSets:RegisterEvent('UNIT_INVENTORY_CHANGED'); 
mnkGearSets:RegisterEvent('EQUIPMENT_SETS_CHANGED'); 
