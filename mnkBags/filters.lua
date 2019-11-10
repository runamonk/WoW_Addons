local addon, ns = ...
local cargBags = ns.cargBags

local _cargBags = cargBags:NewImplementation("mnkBags_cargBags")
_cargBags:RegisterBlizzard()
function _cargBags:UpdateBags() for i = -3, 11 do _cargBags:UpdateBag(i) end end

local L = mnkBags_Locals
_Filters = {}
mnkBagsKnownItems = mnkBagsKnownItems or {}
_ItemClass = {}

--------------------
--Basic filters
--------------------
_Filters.fBags = function(item) return item.bagID >= 0 and item.bagID <= 4 end
_Filters.fBank = function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
_Filters.fBankReagent = function(item) return item.bagID == -3 end
_Filters.fHideEmpty = function(item) return item.link ~= nil end

------------------------------------
-- General Classification (cached)
------------------------------------
_Filters.fItemClass = function(item, container)
	if not item.id or not item.name then return false end	-- incomplete data (itemID or itemName missing), return (item that aren't loaded yet will get classified on the next successful call)
	if not _ItemClass[item.id] then _cargBags:ClassifyItem(item) end
	
	local t, bag = _ItemClass[item.id]

	local isBankBag = item.bagID == -1 or (item.bagID >= 5 and item.bagID <= 11)
	if isBankBag then
		bag = (t) and "Bank"..t or "Bank"
	else
		bag = (t ~= "NoClass") and t or "Bag"
	end

	return bag == container
end

function _cargBags:ClassifyItem(item)
	-- junk
	if (item.rarity == 0) then _ItemClass[item.id] = "Junk"; return true end

	-- type based filters
	if item.type then
		if		(item.type == L.Armor) or (item.type == L.Weapon)	then _ItemClass[item.id] = "Armor"; return true
		elseif	(item.type == L.Gem)								then _ItemClass[item.id] = "Gem"; return true
		elseif	(item.type == L.Quest)								then _ItemClass[item.id] = "Quest"; return true
		elseif	(item.type == L.Trades)								then _ItemClass[item.id] = "TradeGoods"; return true
		elseif	(item.type == L.Consumables)						then _ItemClass[item.id] = "Consumables"; return true
		elseif	(item.type == ARTIFACT_POWER)						then _ItemClass[item.id] = "ArtifactPower"; return true
		elseif	(item.type == L.BattlePet)							then _ItemClass[item.id] = "BattlePet"; return true
		end
	end
	
	_ItemClass[item.id] = "NoClass"
end

------------------------------------------
-- New Items filter and related functions
------------------------------------------
_Filters.fNewItems = function(item)
	if not ((item.bagID >= 0) and (item.bagID <= 4)) then return false end
	if not item.link then return false end
	if not mnkBagsKnownItems[item.id] then return true end
	local t = GetItemCount(item.id)
	return (t > mnkBagsKnownItems[item.id]) and true or false
end


