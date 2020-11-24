mnkTooltip = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

local cls = ''
local tooltips = { 
        GameTooltip,
        DropDownList1MenuBackdrop,
        DropDownList2MenuBackdrop,
        ItemRefTooltip,
        ItemRefShoppingTooltip1,
        ItemRefShoppingTooltip2,
        ShoppingTooltip1,
        ShoppingTooltip2,
        SmallTextTooltip,       
        WorldMapCompareTooltip1,
        WorldMapCompareTooltip2,
        WorldMapTooltip }

local function updateBackdrop(self, style)
    Mixin(self, BackdropTemplateMixin)   
    mnkLibs.setBackdrop(self,"Interface\\Tooltips\\UI-Tooltip-Border", "Interface\\Buttons\\WHITE8x8", 0, 0, 0, 0)
    self:SetBackdropBorderColor(.2, .2, .2, 1)
    self:SetBackdropColor(0, 0, 0, 1)    
end

local function OnTooltipSetUnit()
    local _, unit = GameTooltip:GetUnit()

    if unit ~= nil then
        cls = UnitClassification(unit)
        if cls ~= 'rare' and cls ~= 'rareelite' then
            cls = ''
        else
            if cls == 'rare' then
                cls = mnkLibs.Color(COLOR_RED)..' (RARE)'
            else
                cls = mnkLibs.Color(COLOR_PURPLE)..' (RARE ELITE)'
            end
        end

        if not UnitIsPlayer(unit) then
            
            if UnitIsTapDenied(unit) then
                local unitName, _ = UnitName(unit)
                GameTooltipTextLeft1:SetFormattedText(mnkLibs.Color(COLOR_GREY)..unitName..cls)
                GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'<<Tapped>>')
            else
                local unitName, _ = UnitName(unit)
                if unitName ~= nil then
                    GameTooltipTextLeft1:SetFormattedText(unitName..cls)
                end
            end
        else
            if UnitIsPlayer(unit) then
                local unitClass = UnitClass(unit):gsub(' ', ''):upper() 
                local unitName, _ = UnitName(unit)
                local unitColor = RAID_CLASS_COLORS[unitClass] or COLOR_WHITE

                GameTooltipStatusBar:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b)
                GameTooltipTextLeft1:SetFormattedText(mnkLibs.Color(unitColor)..mnkLibs.formatPlayerName(unitName))

                local guildName, _, _ = GetGuildInfo(unit)
                if guildName ~= nil then
                    guildName = mnkLibs.formatPlayerName(guildName)
                    GameTooltipTextLeft2:SetFormattedText(mnkLibs.Color(COLOR_GREEN)..'<'..guildName..'>')
                end

                local unitTarget = unit..'target'
                if UnitExists(unitTarget) then
                    if UnitIsPlayer(unitTarget) then
                        local targetName, _ = UnitName(unitTarget)

                        if UnitIsUnit(targetName, 'player') then
                            GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'Target: <<YOU>>')
                        else
                            GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'Target: '..targetName)
                        end
                    end
                end
            end
        end
    end
end

function mnkTooltip:PLAYER_LOGIN()
    hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
        local f = GetMouseFocus()
        
        if not f or f == WorldFrame or type(f) == 'table' then
            tooltip:SetOwner(parent, 'ANCHOR_CURSOR')
        else
            tooltip:ClearAllPoints()
            tooltip:SetOwner(parent, 'ANCHOR_NONE')
            tooltip:SetPoint('BOTTOM', f, 'TOP', 0, 5)
        end
    end)

    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint("LEFT",3,0)
    GameTooltipStatusBar:SetPoint("RIGHT",-3,0)
    GameTooltipStatusBar:SetPoint("BOTTOM",0,3)
    GameTooltipStatusBar:SetHeight(4)
    GameTooltipStatusBar:SetStatusBarTexture(mnkLibs.Textures.background)
    GameTooltipStatusBar:GetStatusBarTexture():SetHorizTile(false)

    GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
    GameTooltipStatusBar.bg:SetTexture(mnkLibs.Textures.bar)
    GameTooltipStatusBar.bg:SetAllPoints()
    GameTooltipStatusBar.bg:SetColorTexture(1,1,1)
    GameTooltipStatusBar.bg:SetVertexColor(0,0,0,0.5)
    
    GameTooltip:HookScript('OnTooltipSetUnit', OnTooltipSetUnit)
    GameTooltip:HookScript('OnShow', function() 
        if IsControlKeyDown() then 
            GameTooltip:Hide()
        end 
    end)
    hooksecurefunc("SharedTooltip_SetBackdropStyle", updateBackdrop)

    for i, tooltip in next, tooltips do
        updateBackdrop(tooltip)
        if tooltip:HasScript("OnTooltipCleared") then
            tooltip:HookScript("OnTooltipCleared", updateBackdrop)
        end
    end
end

mnkTooltip:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkTooltip:RegisterEvent('PLAYER_LOGIN')

