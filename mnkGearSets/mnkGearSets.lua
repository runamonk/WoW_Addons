mnkGearSets = CreateFrame('Frame')
mnkGearSets.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkGearSets:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkGearSets:RegisterEvent('PLAYER_LOGIN')
mnkGearSets:RegisterEvent('EQUIPMENT_SETS_CHANGED')
mnkGearSets:RegisterEvent('EQUIPMENT_SWAP_FINISHED')


local LibQTip = LibStub('LibQTip-1.0')

function mnkGearSets:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkGearSets', {
        icon = 'Interface\\Icons\\Inv_misc_enggizmos_30.blp', 
        type = 'data source', 
        OnEnter = function (parent) self:OnEnter(parent) end, 
        OnClick = function () self:OnClick() end
    })
    self.LDB.label = 'Gear Sets'
    self:UpdateText()
end

function mnkGearSets:EQUIPMENT_SETS_CHANGED()
    mnkGearSets:UpdateText()
end

function mnkGearSets:EQUIPMENT_SWAP_FINISHED(event, arg1, arg2)
    print(event, ' ', arg1, ' ', arg2)
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


                -- local y = t:AddLine()
                -- t:SetCell(y, 1, string.format('|T%s:16|t %s', tblTabards[i].itemTexture, tblTabards[i].itemName), 1)
                -- t:SetLineScript(y, 'OnMouseDown', mnkReputation.TabardClick, i)
                -- if tblTabards[i].itemName == mnkReputation_db.AutoTabardName then
                --     t:SetCell(y, 2, 'Auto-equip '..string.format('|T%s:16|t', 'Interface\\Buttons\\UI-CheckBox-Check'))
                -- end
            

                local y, x = tooltip:AddLine(string.format('|T%s|t %s', icon..':16:16:0:0:64:64:4:60:4:60', name))
                tooltip:SetLineScript(y, 'OnMouseDown', OnClick, name)
            end
        end
        tooltip:SetAutoHideDelay(.1, parent)
        tooltip:SmartAnchorTo(parent)
        tooltip:SetBackdropBorderColor(0, 0, 0, 0)
        -- tooltip:SetBackdrop(GameTooltip:GetBackdrop())
        -- tooltip:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
        -- tooltip:SetBackdropColor(GameTooltip:GetBackdropColor())
        -- tooltip:SetScale(GameTooltip:GetScale())
        mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
        tooltip:SetBackdropColor(0, 0, 0, 1)
        tooltip:EnableMouse(true)        
        tooltip:Show()
    end
end

function mnkGearSets:UpdateText()
    mnkGearSets.LDB.text = ' '..C_EquipmentSet.GetNumEquipmentSets()
end

