mnkGearSets = CreateFrame('Frame')
mnkGearSets.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkGearSets:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkGearSets:RegisterEvent('PLAYER_LOGIN')
mnkGearSets:RegisterEvent('EQUIPMENT_SETS_CHANGED')

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

function mnkGearSets:OnClick()
    ToggleCharacter('PaperDollFrame')
    if CharacterFrame:IsShown() then
        PaperDollSidebarTab3:Click()
    end
end

function mnkGearSets:OnEnter(parent)
    local function OnClick(self, arg, button)
        self:Hide()
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
            local name, icon, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(i)
            local color = COLOR_WHITE
            --name, texture, setIndex, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = C_EquipmentSet.GetEquipmentSetInfo(index)
            --print(i, ' ', name, ' ', icon)
            if name ~= nil then
                if isEquipped then
                    color = COLOR_GREEN
                end

                local y, x = tooltip:AddLine(string.format('|T%s|t %s', icon..':16:16:0:0:64:64:4:60:4:60', mnkLibs.Color(color)..name))
                tooltip:SetLineScript(y, 'OnMouseDown', function(self, arg, button) OnClick(tooltip, arg, button) end, name)
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

