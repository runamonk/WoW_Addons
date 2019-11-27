local addon, ns = ...
local cargBags = ns.cargBags

local cbmb = cargBags:NewImplementation("mb")
cbmb:RegisterBlizzard()
cbmb.PauseUpdates = false

function cbmb:UpdateBags()
	if cbmb.PauseUpdates then return end
	for i = -3, 11 do cbmb:UpdateBag(i) 
	end 
end

cB_Filters = {}
mnkBagsKnownItems = mnkBagsKnownItems or {}
cB_ItemClass = {}

--------------------
--Basic filters
--------------------
cB_Filters.fBags = function(item) return item.bagID >= 0 and item.bagID <= 4 end
cB_Filters.fBank = function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
cB_Filters.fBankReagent = function(item) return item.bagID == -3 end
cB_Filters.fHideEmpty = function(item) return item.link ~= nil end

------------------------------------
-- General Classification (cached)
------------------------------------
cB_Filters.fItemClass = function(item, container)
	if not item.id or not item.name then return false end	-- incomplete data (itemID or itemName missing), return (item that aren't loaded yet will get classified on the next successful call)
	if not cB_ItemClass[item.id] then cbmb:ClassifyItem(item) end
	
	local t, bag = cB_ItemClass[item.id]

	local isBankBag = item.bagID == -1 or (item.bagID >= 5 and item.bagID <= 11)
	if isBankBag then
		bag = (t) and "Bank"..t or "Bank"
	else
		bag = (t ~= "NoClass") and t or "Bag"
	end

	return bag == container
end

function cbmb:ClassifyItem(item)
	-- junk
	if (item.rarity == 0) then cB_ItemClass[item.id] = "Junk"; return true end

	-- type based filters
	if item.type then
		--print(item.name, ' ', item.type, ' ', item.subType)
		if		(item.type == mbLocals.Armor) or (item.type == mbLocals.Weapon)	then cB_ItemClass[item.id] = "Armor"; return true
		elseif	(item.type == mbLocals.Gem)	then cB_ItemClass[item.id] = "Gem"; return true
		elseif	(item.type == mbLocals.Quest) then cB_ItemClass[item.id] = "Quest"; return true
		elseif	(item.type == mbLocals.Trades) then cB_ItemClass[item.id] = "TradeGoods"; return true
		elseif	(item.type == mbLocals.Consumables)	then cB_ItemClass[item.id] = "Consumables"; return true
		elseif	(item.type == ARTIFACT_POWER) then cB_ItemClass[item.id] = "ArtifactPower"; return true
		elseif	(item.type == mbLocals.BattlePet) then cB_ItemClass[item.id] = "BattlePet"; return true
		end
	end
	
	cB_ItemClass[item.id] = "NoClass"
end

------------------------------------------
-- New Items filter and related functions
------------------------------------------
cB_Filters.fNewItems = function(item)
	if not ((item.bagID >= 0) and (item.bagID <= 4)) then return false end
	if not item.link then return false end
	if not mnkBagsKnownItems[item.id] then return true end
	local t = GetItemCount(item.id)
	return (t > mnkBagsKnownItems[item.id]) and true or false
end


