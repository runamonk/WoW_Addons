mnkGearSets = CreateFrame('Frame')
mnkGearSets.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local LibQTip = LibStub('LibQTip-1.0')
local _Elapsed = 0
local _
function mnkGearSets:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkGearSets.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkGearSets', {
            icon = 'Interface\\Icons\\Inv_misc_enggizmos_30.blp', 
            type = 'data source', 
            OnEnter = mnkGearSets.DoOnEnter, 
            OnClick = mnkGearSets.DoOnClick
        })
        mnkGearSets.LDB.label = 'Gear Sets'
    end
    mnkGearSets.UpdateText()
end

function mnkGearSets.DoOnClick(self, button)
    ToggleCharacter('PaperDollFrame')
    if CharacterFrame:IsShown() then
        PaperDollSidebarTab3:Click()
    end
end

function mnkGearSets.DoOnEnter(self)
    local x = C_EquipmentSet.GetNumEquipmentSets()
    -- this will return a zero based count. zero = none.
    if x > 0 then
        local tooltip = LibQTip:Acquire('mnkGearSetsTooltip', 1, 'LEFT', 'LEFT')
        self.tooltip = tooltip
        tooltip:SetFont(mnkLibs.DefaultTooltipFont)
        tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
        tooltip:Clear()
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name')
        -- this is a zero index.
        for i = 0, x-1 do
            local name, icon = C_EquipmentSet.GetEquipmentSetInfo(i)
            --name, texture, setIndex, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = C_EquipmentSet.GetEquipmentSetInfo(index)
            --print(i, ' ', name, ' ', icon)
            if name ~= nil then
                local y, x = tooltip:AddLine(string.format('|T%s:16|t %s', icon, name))
                tooltip:SetLineScript(y, 'OnMouseDown', mnkGearSets.DoOnSetClick, name)
            end
        end
        tooltip:SetAutoHideDelay(.1, self)
        tooltip:SmartAnchorTo(self)
        tooltip:SetBackdropBorderColor(0, 0, 0, 0)
        tooltip:Show()
    end
end

function mnkGearSets.DoOnSetClick(self, arg, button)
    C_EquipmentSet.UseEquipmentSet(C_EquipmentSet.GetEquipmentSetID(arg));
end

function mnkGearSets.UpdateText()
    mnkGearSets.LDB.text = C_EquipmentSet.GetNumEquipmentSets()
end

mnkGearSets:SetScript('OnEvent', mnkGearSets.DoOnEvent)
mnkGearSets:RegisterEvent('PLAYER_LOGIN')
mnkGearSets:RegisterEvent('UNIT_INVENTORY_CHANGED')
mnkGearSets:RegisterEvent('EQUIPMENT_SETS_CHANGED')
