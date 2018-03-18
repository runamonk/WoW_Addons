-- Based on code by p3lim
local tags = oUF.Tags
local tagMethods = tags.Methods
local tagEvents = tags.Events
local tagSharedEvents = tags.SharedEvents
local incombat = false;
local gsub = string.gsub
local format = string.format
local floor = math.floor

local DEAD_TEXTURE = [[|TInterface\RaidFrame\Raid-Icon-DebuffDisease:26|t]]

local function Status(unit)
	if (not UnitIsConnected(unit)) then
		return 'Offline'
	elseif (UnitIsGhost(unit)) then
		return 'Ghost'
	elseif (UnitIsDead(unit)) then
		return 'Dead'
	end
end

local events = {
	curhp = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH',
	perhp = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH',
	pethp = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_PET',
	leader = 'PARTY_LEADER_CHANGED',
	cast = 'UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP',
	name = 'UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION UNIT_CLASSIFICATION_CHANGED',
	status = 'UNIT_CONNECTION UNIT_HEALTH',
	combat = 'PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED',
}

for tag, func in next, {
	combat = function(unit)
		if incombat then
			return "×"
		else
			return ""
		end
	end,
	curhp = function(unit)
		if (Status(unit)) then return end
		return TruncNumber(UnitHealth(unit),2)
	end,

	perhp = function(unit)
		if (Status(unit)) then return end

		local cur = UnitHealth(unit)
		local max = UnitHealthMax(unit)

		if (cur > 0) then
			return format('%s%d%%|r', Hex(ColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 1, 1, 1)), cur / max * 100)
		elseif (UnitIsDead(unit)) then
			return DEAD_TEXTURE
		end
	end,
	pethp = function(unit)
		if (UnitIsUnit(unit, 'vehicle')) then return end

		local cur = UnitHealth(unit)
		local max = UnitHealthMax(unit)
		if (cur > 0) then
			return format('%s%d%%|r', Hex(ColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 1, 1, 1)), cur / max * 100)
		elseif (UnitIsDead(unit)) then
			return DEAD_TEXTURE
		end
	end,
	leader = function(unit)
		return UnitIsGroupLeader(unit) and '|cffffff00!|r'
	end,
	cast = function(unit)
		return UnitCastingInfo(unit) or UnitChannelInfo(unit)
	end,
	name = function(unit)
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

		local color = _TAGS['mnku:color'](unit)
		name = color and format('%s%s|r', color, name) or name

		--local rare = _TAGS['rare'](unit)
		--return rare and format('%s |cff0090ff%s|r', name, rare) or name

		local rare = _TAGS['shortclassification'](unit)
		return rare and format('%s |cff0090ff%s|r', name, rare) or name
	end,
	color = function(unit)
		local reaction = UnitReaction(unit, 'player')
		if (UnitIsTapDenied(unit) or not UnitIsConnected(unit)) then
			return '|cff999999'
		elseif (not UnitIsPlayer(unit) and reaction) then
			return Hex(_COLORS.reaction[reaction])
		elseif (UnitFactionGroup(unit) and UnitIsEnemy(unit, 'player') and UnitIsPVP(unit)) then
			return '|cffff0000'
		end
	end,
	status = Status
} do
	tagMethods['mnku:' .. tag] = func
	tagEvents['mnku:' .. tag] = events[tag]
end

-- Modified version of the tags element
local events = {}
local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', function(self, event, unit)
	local strings = events[event]
	if event ~= nil and event  == "PLAYER_REGEN_DISABLED" then
		incombat = true;
	elseif event == "PLAYER_REGEN_ENABLED" then
		incombat = false;
	end
	if (strings) then
		for _, fs in next, strings do
			if (fs:IsVisible() and (tagSharedEvents[event] or fs.parent.unit == unit or fs.overrideUnit == unit)) then
				fs:UpdateTag()
			end
		end
	end
end)

local OnUpdates = {}
local eventlessUnits = {}

local function createOnUpdate(timer)
	local OnUpdate = OnUpdates[timer]
	if (not OnUpdate) then
		local total = timer
		local strings = eventlessUnits[timer]

		local frame = CreateFrame('Frame')
		frame:SetScript('OnUpdate', function(self, elapsed)
			if (total >= timer) then
				for _, fs in next, strings do
					if (fs.parent:IsShown() and (UnitExists(fs.parent.unit) or UnitExists(fs.overrideUnit))) then
						fs:UpdateTag()
					end
				end

				total = 0
			end

			total = total + elapsed
		end)

		OnUpdates[timer] = frame
	end
end

local function OnShow(self)
	for _, fs in next, self.__tags do
		fs:UpdateTag()
	end
end

local function getTagName(tag)
	local s = (tag:match('>+()') or 2)
	local e = tag:match('.*()<+')
	e = (e and e - 1) or -2

	return tag:sub(s, e), s, e
end

local function RegisterEvent(fs, event)
	if (not events[event]) then
		events[event] = {}
	end

	frame:RegisterEvent(event)
	table.insert(events[event], fs)
end

local _PATTERN = '%[..-%]+'
local function RegisterEvents(fs, tagStr)
	for tag in tagStr:gmatch(_PATTERN) do
		tag = getTagName(tag)

		local events = tagEvents[tag]
		if (events) then
			for event in events:gmatch('%S+') do
				RegisterEvent(fs, event)
			end
		end
	end
end

local function UnregisterEvents(fs)
	for event, data in next, events do
		for key, fs2 in next, data do
			if (fs2 == fs) then
				if (#data == 1) then
					frame:UnregisterEvent(event)
				end

				table.remove(data, key)
			end
		end
	end
end

local tagPool = {}
local funcPool = {}
local tmp = {}

local function Tag(self, fs, tagStr)
	if (not fs or not tagStr) then
		return
	end

	if (not self.__tags) then
		self.__tags = {}
		table.insert(self.__elements, OnShow)
	else
		-- Since people ignore everything that is good practice;
		-- Unregister the tag if it already exists.
		for _, tag in next, self.__tags do
			if (fs == tag) then
				-- We don't need to remove it from the __tags table as Untag
				-- handles that for us.
				self:Untag(fs)
			end
		end
	end

	fs.parent = self

	local func = tagPool[tagStr]
	if (not func) then
		local format, numTags = tagStr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s')
		local args = {}

		for bracket in tagStr:gmatch(_PATTERN) do
			local tagFunc = funcPool[bracket] or tagMethods[bracket:sub(2, -2)]
			if (not tagFunc) then
				local tagName, s, e = getTagName(bracket)
				local tag = tagMethods[tagName]
				if (tag) then
					s = s - 2
					e = e + 2

					if (s ~= 0 and e ~= 0) then
						local pre = bracket:sub(2, s)
						local ap = bracket:sub(e, -2)

						tagFunc = function(u, r)
							local str = tag(u, r)
							if (str) then
								return pre .. str .. ap
							end
						end
					elseif (s ~= 0) then
						local pre = bracket:sub(2, s)

						tagFunc = function(u, r)
							local str = tag(u, r)
							if (str) then
								return pre .. str
							end
						end
					elseif (e ~= 0) then
						local ap = bracket:sub(e, -2)

						tagFunc = function(u, r)
							local str = tag(u, r)
							if (str) then
								return str .. ap
							end
						end
					end

					funcPool[bracket] = tagFunc
				end
			end

			if (tagFunc) then
				table.insert(args, tagFunc)
			else
				return error(('Attempted to use invalid tag %s.'):format(bracket), 3)
			end
		end

		if (numTags == 1) then
			func = function(self)
				local parent = self.parent
				local unit = parent.unit
				local overrideUnit = self.overrideUnit

				-- _ENV._COLORS = parent.colors
				return self:SetFormattedText(
					format,
					args[1](overrideUnit or unit, overrideUnit and unit) or ''
				)
			end
		elseif (numTags == 2) then
			func = function(self)
				local parent = self.parent
				local unit = parent.unit
				local overrideUnit = self.overrideUnit

				-- _ENV._COLORS = parent.colors
				return self:SetFormattedText(
					format,
					args[1](overrideUnit or unit, overrideUnit and unit) or '',
					args[2](overrideUnit or unit, overrideUnit and unit) or ''
				)
			end
		elseif (numTags == 3) then
			func = function(self)
				local parent = self.parent
				local unit = parent.unit
				local overrideUnit = self.overrideUnit

				-- _ENV._COLORS = parent.colors
				return self:SetFormattedText(
					format,
					args[1](overrideUnit or unit, overrideUnit and unit) or '',
					args[2](overrideUnit or unit, overrideUnit and unit) or '',
					args[3](overrideUnit or unit, overrideUnit and unit) or ''
				)
			end
		else
			func = function(self)
				local parent = self.parent
				local unit = parent.unit
				local overrideUnit = self.overrideUnit

				-- _ENV._COLORS = parent.colors
				for i, func in next, args do
					tmp[i] = func(overrideUnit or unit, overrideUnit and unit) or ''
				end

				-- We do 1, numTags because tmp can hold several unneeded variables.
				return self:SetFormattedText(format, unpack(tmp, 1, numTags))
			end
		end

		tagPool[tagStr] = func
	end
	fs.UpdateTag = func

	local unit = self.unit
	if (self.__eventless or fs.frequentUpdates) then
		local timer
		if (type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		else
			timer = 1/2
		end

		if (not eventlessUnits[timer]) then
			eventlessUnits = {}
		end

		table.insert(eventlessUnits[timer], fs)

		createOnUpdate(timer)
	else
		RegisterEvents(fs, tagStr)
	end

	table.insert(self.__tags, fs)
end

local function Untag(self, fs)
	if (not fs) then
		return
	end

	UnregisterEvents(fs)

	for _, timers in next, eventlessUnits do
		for key, fs2 in next, timers do
			if (fs2 == fs) then
				table.remove(timers, key)
			end
		end
	end

	for key, fs2 in next, self.__tags do
		if (fs2 == fs) then
			table.remove(self.__tags, key)
		end
	end

	fs.UpdateTag = nil
end

oUF:RegisterMetaFunction('CustomTag', Tag)
oUF:RegisterMetaFunction('CustomUntag', Untag)
