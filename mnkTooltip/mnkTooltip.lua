--thanks to an old post by Phanx.

mnkTooltip = CreateFrame('Frame')

local bInCombat = false

local colors = {}
local cls = ''
for class, color in pairs(RAID_CLASS_COLORS) do colors[class] = string.format('%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255) end

function mnkTooltip:DoOnEvent(self, event, ...)
    if event == 'PLAYER_REGEN_ENABLED' then
        bInCombat = true
    elseif event == 'PLAYER_REGEN_DISABLED' then
        bInCombat = false
    end
end

local function OnTooltipSetSpell(self)
    local id = select(3, self:GetSpell())
    if id ~= nil and id ~= '' then
        GameTooltip:AddLine(mnkLibs.Color(COLOR_WHITE)..'Spell ID: '..id)
    end
end

local function OnTooltipSetUnit()
    if bInCombat then 
        GameTooltip:Hide()
    else
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
end

local function OnTooltipSetItem()

end

local function OnShow()
    GameTooltip.shoppingTooltips[1]:SetBackdropBorderColor(0, 0, 0, 0); -- hide the border. 
    GameTooltip.shoppingTooltips[2]:SetBackdropBorderColor(0, 0, 0, 0); -- hide the border. 
    GameTooltip:SetBackdropBorderColor(0, 0, 0, 0); -- hide the border. 
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



GameTooltip:HookScript('OnTooltipSetUnit', OnTooltipSetUnit)
GameTooltip:HookScript('OnTooltipSetSpell', OnTooltipSetSpell)
GameTooltip:HookScript('OnTooltipSetItem', OnTooltipSetItem)
GameTooltip:HookScript('OnShow', OnShow)

mnkTooltip:SetScript('OnEvent', mnkTooltip.DoOnEvent)
mnkTooltip:RegisterEvent('PLAYER_REGEN_DISABLED')
mnkTooltip:RegisterEvent('PLAYER_REGEN_ENABLED')
