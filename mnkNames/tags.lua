local tags = oUF.Tags.Methods or oUF.Tags
local events = oUF.TagEvents or oUF.Tags.Events

tags['mnknames:color'] = function(unit)
    local reaction = UnitReaction(unit, 'player')
    if (UnitIsTapDenied(unit) or not UnitIsConnected(unit)) then
        return '|cff999999'
    elseif (not UnitIsPlayer(unit) and reaction) then
        return Hex(_COLORS.reaction[reaction])
    elseif (UnitFactionGroup(unit) and UnitIsEnemy(unit, 'player') and UnitIsPVP(unit)) then
        return '|cffff0000'
    end
end

-- tags['mnknames:name'] = function(unit, rolf)
--     return UnitName(rolf or unit)
-- end

tags['mnknames:name'] = function(unit, rolf)
    local name, _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
    if (name) then
        local color = notInterruptible and 'ff9000' or 'ff0000'
        return format('|cff%s%s|r', color, name)
    end
    name, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
    if (name) then
        local color = notInterruptible and 'ff9000' or 'ff0000'
        return format('|cff%s%s|r', color, name)
    end
    name = UnitName(unit)
    --local color = _TAGS['mnknames:color'](unit)
    --name = color and format('%s%s|r', color, name) or name
    local rare = _TAGS['shortclassification'](unit)
    return rare and format('%s |cff0090ff%s|r', name, rare) or name or rolf
end

events['mnknames:name'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION UNIT_ENTERING_VEHICLE UNIT_EXITING_VEHICLE'
events['mnknames:level'] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'
events['mnknames:curhp'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'

tags['mnknames:level'] = function(unit)
    --local c = UnitClassification(unit)
    local l = UnitLevel(unit)
    local d = GetQuestDifficultyColor(l)

    if l <= 0 then l = '??' end

    return string.format('|cff%02x%02x%02x%s|r', d.r * 255, d.g * 255, d.b * 255, l)
end

tags['mnknames:curhp'] = function(unit)
    if (Status(unit)) then return end
    return TruncNumber(UnitHealth(unit), 2)    
end