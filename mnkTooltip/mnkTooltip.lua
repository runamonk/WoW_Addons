--thanks to an old post by Phanx.

mnkTooltip = CreateFrame('Frame')

local colors = {}
local cls = ''
for class, color in pairs(RAID_CLASS_COLORS) do colors[class] = string.format('%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255) end

local function SetBackdrop()
    -- GameTooltip_UpdateStyle was blowing away my backdrop.
    GameTooltip.GameTooltip_UpdateStyle = mnkLibs.donothing()

    local tooltips = {
        'GameTooltip',
        'ItemRefTooltip',
        'ItemRefShoppingTooltip1',
        'ItemRefShoppingTooltip2',
        'ShoppingTooltip1',
        'ShoppingTooltip2',
        'DropDownList1MenuBackdrop',
        'DropDownList2MenuBackdrop',
        'WorldMapTooltip',
        'WorldMapCompareTooltip1',
        'WorldMapCompareTooltip2',
    }
    
    for i = 1, #tooltips do
        local frame = _G[tooltips[i]]
        frame:SetBackdropBorderColor(0, 0, 0, 0); -- hide the border. 
    end
end

local function OnTooltipSetSpell(self)
    SetBackdrop()   
    local id = select(3, self:GetSpell())
    if id ~= nil and id ~= '' then
        GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'Spell ID: '..id)
    end
end

local function OnTooltipSetUnit()
    SetBackdrop() 

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
                local _, unitClass = UnitClass(unit)
                local unitName, _ = UnitName(unit)
                unitName = mnkLibs.formatPlayerName(unitName)

                if color then
                    GameTooltipTextLeft1:SetFormattedText(format('|cff%s%s', colors[unitClass:gsub(' ', ''):upper()] or 'ffffff', unitName))
                else
                    GameTooltipTextLeft1:SetFormattedText(unitName)
                end

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

local function OnTooltipSetItem()
    SetBackdrop()
end

local function OnShow()
    -- if InCombatLockdown() then 
    --     GameTooltip:Hide()
    -- else
         SetBackdrop()
    -- end
end

hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
    local f = GetMouseFocus()
    
    if f == WorldFrame or type(f) == 'table' then
        tooltip:SetOwner(parent, 'ANCHOR_CURSOR')
    else
        tooltip:ClearAllPoints()
        tooltip:SetOwner(parent, 'ANCHOR_NONE')
        tooltip:SetPoint('BOTTOM', f, 'TOP', 0, 5)
    end
end)


ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", OnTooltipSetItem)

GameTooltip:HookScript('OnTooltipSetUnit', OnTooltipSetUnit)
GameTooltip:HookScript('OnTooltipSetSpell', OnTooltipSetSpell)
GameTooltip:HookScript('OnTooltipSetItem', OnTooltipSetItem)
GameTooltip:HookScript('OnShow', OnShow)