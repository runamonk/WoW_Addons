local P, E, L = unpack(select(2, ...))

local categoryName = L['Collections']
local categoryIndex = 80

local scanTip = CreateFrame('GameTooltip', P.name .. 'ScanTip' .. math.floor(GetTime()), nil, 'GameTooltipTemplate')
scanTip:SetOwner(WorldFrame, 'ANCHOR_NONE')
scanTip.name = scanTip:GetName()

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and type(custom) == 'number') then
		return custom == categoryIndex
	else
		local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
		if(itemClass == LE_ITEM_CLASS_BATTLEPET) then
			-- caged battlepets
			return true
		elseif(itemClass == LE_ITEM_CLASS_MISCELLANEOUS) then
			if(itemSubClass == 2 or itemSubClass == 5) then
				-- uncaged battlepets and mounts
				return true
			elseif(itemSubClass == 4) then
				-- toys
				scanTip:SetBagItem(bagID, slotID)
				scanTip:Show()

				for index = 1, scanTip:NumLines() do
					local line = _G[scanTip.name .. 'TextLeft' .. index]
					if(line and line:GetText() == TOY) then -- "Toy"
						return true
					end
				end
			end
		end
	end
end

P.AddCategory(categoryIndex, categoryName, 'Collections', categoryFilter)
