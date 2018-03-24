local tags = oUF.Tags.Methods or oUF.Tags
local events = oUF.TagEvents or oUF.Tags.Events

tags['mnknames:name'] = function(unit, rolf)
    return UnitName(rolf or unit)
end
events['mnknames:name'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION UNIT_ENTERING_VEHICLE UNIT_EXITING_VEHICLE'

tags['mnknames:level'] = function(unit)
    --local c = UnitClassification(unit)
    local l = UnitLevel(unit)
    local d = GetQuestDifficultyColor(l)

    if l <= 0 then l = '??' end

    return string.format('|cff%02x%02x%02x%s|r', d.r * 255, d.g * 255, d.b * 255, l)
end
events['mnknames:level'] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'
