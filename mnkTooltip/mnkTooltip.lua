mnkTooltip = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
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
        local unitName, _ = UnitName(unit)
        local unitRarity = UnitClassification(unit)
        
        if unitRarity ~= 'rare' and cls ~= 'rareelite' then
            unitRarity = ''
        else
            if unitRarity == 'rare' then
                unitRarity = mnkLibs.Color(COLOR_RED)..' (RARE)'
            else
                unitRarity = mnkLibs.Color(COLOR_PURPLE)..' (RARE ELITE)'
            end
        end

        if not UnitIsPlayer(unit) then          
            if UnitIsTapDenied(unit) or UnitIsDeadOrGhost(unit) then        
                GameTooltip:SetBackdropColor(.1, .1, .1, 1) 
                GameTooltipTextLeft1:SetFormattedText(mnkLibs.Color(COLOR_GREY)..unitName..unitRarity)
                if UnitIsTapDenied(unit) then
                    GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'<Tapped>')
                end
            else
                local unitName, _ = UnitName(unit)
                if unitName ~= nil then
                    GameTooltipTextLeft1:SetFormattedText(unitName..unitRarity)
                    local unitReact = UnitReaction(unit, "player");
                    if unitReact <= 3 then
                        GameTooltip:SetBackdropColor(.2, 0, 0, 1) 
                    else
                        GameTooltip:SetBackdropColor(0, 0, 0, 1)
                    end 
                end
            end
        else
            if UnitIsPlayer(unit) then
                GameTooltip:SetBackdropColor(0, 0, 0, 1) 
                local unitClass = UnitClass(unit):gsub(' ', ''):upper() 
                local unitColor = RAID_CLASS_COLORS[unitClass] or COLOR_WHITE
                local unitGuildName, _, _ = GetGuildInfo(unit)
                local unitAFK = UnitIsAFK(unit)
                if unitAFK then unitAFK = ' <AFK>' else unitAFK = '' end

                --leave the hp bar green, it's more consistant. 
                --GameTooltipStatusBar:SetStatusBarColor(unitColor.r, unitColor.g, unitColor.b)
                GameTooltipTextLeft1:SetFormattedText(mnkLibs.Color(unitColor)..mnkLibs.formatPlayerName(unitName)..mnkLibs.Color(COLOR_BLUE)..unitAFK)              
                if unitGuildName ~= nil then
                    GameTooltipTextLeft2:SetFormattedText(mnkLibs.Color(COLOR_GREEN)..'<'..mnkLibs.formatPlayerName(unitGuildName)..'>')
                end

                local unitTarget = unit..'target'
                if UnitExists(unitTarget) then
                    if UnitIsPlayer(unitTarget) then
                        local targetName, _ = UnitName(unitTarget)

                        if UnitIsUnit(targetName, 'player') then
                            GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'Target: <'..mnkLibs.Color(COLOR_RED)..'YOU'..mnkLibs.Color(COLOR_WHITE)..'>')
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
    local tooltip = nil
    for _, tooltip in next, tooltips do
        updateBackdrop(tooltip)
        if tooltip:HasScript("OnTooltipCleared") then
            tooltip:HookScript("OnTooltipCleared", updateBackdrop)
        end
    end
end

mnkTooltip:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkTooltip:RegisterEvent('PLAYER_LOGIN')

