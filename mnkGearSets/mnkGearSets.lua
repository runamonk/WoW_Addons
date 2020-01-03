mnkGearSets = CreateFrame('Frame')
mnkGearSets.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkGearSets:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkGearSets:RegisterEvent('PLAYER_LOGIN')
mnkGearSets:RegisterEvent('EQUIPMENT_SETS_CHANGED')

local LibQTip = LibStub('LibQTip-1.0')

function mnkGearSets:PLAYER_LOGIN()
    mnkGearSets.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkGearSets', {
        icon = 'Interface\\Icons\\Inv_misc_enggizmos_30.blp', 
        type = 'data source', 
        OnEnter = function (parent) mnkGearSets:OnEnter(parent) end, 
        OnClick = function () mnkGearSets:OnClick() end
    })
    mnkGearSets.LDB.label = 'Gear Sets'
    mnkGearSets:UpdateText()
end

function mnkGearSets:EQUIPMENT_SETS_CHANGED()
    mnkGearSets:UpdateText()
end

function mnkGearSets:OnClick()
    ToggleCharacter('PaperDollFrame')
    if CharacterFrame:IsShown() then
        PaperDollSidebarTab3:Click()
    end
end

function mnkGearSets:OnEnter(parent)
    local function OnClick(self, arg, button)
        C_EquipmentSet.UseEquipmentSet(C_EquipmentSet.GetEquipmentSetID(arg));
    end

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
                local y, x = tooltip:AddLine(string.format('|T%s|t %s', icon..':16:16:0:0:64:64:4:60:4:60', name))
                tooltip:SetLineScript(y, 'OnMouseDown', OnClick, name)
            end
        end
        tooltip:SetAutoHideDelay(.1, parent)
        tooltip:SmartAnchorTo(parent)
        tooltip:SetBackdropBorderColor(0, 0, 0, 0)
        tooltip:Show()
    end
end

function mnkGearSets:UpdateText()
    mnkGearSets.LDB.text = ' '..C_EquipmentSet.GetNumEquipmentSets()
end

