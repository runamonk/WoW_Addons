local tags = oUF.Tags.Methods or oUF.Tags
local events = oUF.TagEvents or oUF.Tags.Events
local DEAD_TEXTURE = '|TInterface\\RaidFrame\\Raid-Icon-DebuffDisease:18|t'

events['mnku:cast']     = 'UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP'
events['mnku:curhp']    = 'UNIT_HEALTH UNIT_MAXHEALTH'
events['mnku:leader']   = 'PARTY_LEADER_CHANGED'
events['mnku:level']    = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'
events['mnku:name']     = 'UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP UNIT_NAME_UPDATE UNIT_FACTION UNIT_CLASSIFICATION_CHANGED'
events['mnku:perhp']    = 'UNIT_HEALTH UNIT_MAXHEALTH'
events['mnku:pethp']    = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_PET'
events['mnku:status']   = 'UNIT_CONNECTION UNIT_HEALTH'

tags['mnku:cast'] = function(unit)
    return UnitCastingInfo(unit) or UnitChannelInfo(unit)
end

tags['mnku:color'] = function(unit)
    local reaction = UnitReaction(unit, 'player')
    if (UnitIsTapDenied(unit) or not UnitIsConnected(unit)) then
        return '|cff999999'
    elseif (not UnitIsPlayer(unit) and reaction) then
        return Hex(_COLORS.reaction[reaction])
    elseif (UnitFactionGroup(unit) and UnitIsEnemy(unit, 'player') and UnitIsPVP(unit)) then
        return '|cffff0000'
    end
end

tags['mnku:curhp'] = function(unit)
    if (Status(unit)) then return end
    return mnkLibs.formatNumber(UnitHealth(unit), 2)
end

tags['mnku:leader'] = function(unit)
    return UnitIsGroupLeader(unit) and '|cffffff00!|r'
end

tags['mnku:level'] = function(unit)
    local l = UnitLevel(unit)
    local d = GetQuestDifficultyColor(l)
    local s = nil

    if l <= 0 then 
        l = '??'
        s = mnkLibs.Color(COLOR_RED)..l
    else
        s = Hex(d)..l
    end
    return s     
end

tags['mnku:name'] = function(unit)
    local name = UnitName(unit)
    local rare = _TAGS['shortclassification'](unit) or ''
	if rare == '-' then rare = "" else rare = ' '..rare end
	
    if string.len(name) > 25 then
        name = string.sub(name, 1, 25)..'...'
    end

	if UnitIsPVP(unit) then
		return mnkLibs.Color(COLOR_YELLOW)..name..rare
	else
		return mnkLibs.Color(COLOR_WHITE)..name..rare
	end
end

tags['mnku:perhp'] = function(unit)
    if (Status(unit)) then return end

    local cur = UnitHealth(unit)
    local max = UnitHealthMax(unit)

    if (cur > 0) then
        return format('%s%d%%|r', Hex(ColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 1, 1, 1)), cur / max * 100)
    elseif (UnitIsDead(unit)) then
        return DEAD_TEXTURE
    end
end

tags['mnku:pethp'] = function(unit)
    if (UnitIsUnit(unit, 'vehicle')) then return end
    local cur = UnitHealth(unit)
    local max = UnitHealthMax(unit)
    if (cur > 0) then
        return format('%s%d%%|r', Hex(ColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 1, 1, 1)), cur / max * 100)
    elseif (UnitIsDead(unit)) then
        return DEAD_TEXTURE
    end
end

tags['mnku:status'] = function(unit)
    return Status(unit)
end

function Status(unit)
    if (not UnitIsConnected(unit)) then
        return 'Offline'
    elseif (UnitIsGhost(unit)) then
        return 'Ghost'
    elseif (UnitIsDead(unit)) then
        return 'Dead'
    end
end       