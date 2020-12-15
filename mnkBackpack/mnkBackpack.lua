
local mbBags = {}
local bagMain, bagBank, bagReagent, bagJunk, bagNew = nil

local mnkBackpack = CreateFrame('Frame', 'mnkBags', UIParent, BackdropTemplateMixin and "BackdropTemplate")

local _
local JunkItemsSold = 0
local NewItemsSold = 0

local mediaPath = [[Interface\AddOns\mnkBags\media\]]
local Textures = {
	Search =	mediaPath .. "Search",
	BagToggle =	mediaPath .. "BagToggle",
	ResetNew =	mediaPath .. "ResetNew",
	Restack =	mediaPath .. "Restack",
	Deposit =	mediaPath .. "Deposit"}

mnkBackpack:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBackpack:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkBackpackKnownItems = {}

function mnkBags:PLAYER_ENTERING_WORLD(event, firstTime, reload)
	if firstTime then
		for i = 0, NUM_LE_ITEM_CLASSS-1 do
			CreateBag("_bag", GetItemClassInfo(i))
			CreateBag("_bank", GetItemClassInfo(i))
		end

		bagJunk = CreateBag("_bag","Junk")
		bagNew = CreateBag("_bag", "New")

		local sort_func = function(a, b) return a.name > b.name end
	    table.sort(mbBags, sort_func)

		bagReagent = CreateBag("_bank","Reagents")
		bagBank = CreateBag(nil,"_bank")
		bagMain = CreateBag(nil,"_bag")
		bagMain:SetPoint('BOTTOMRIGHT', -20, 220)
		bagBank:SetPoint('BOTTOMLEFT', 20, 220)
	end
end

function mnkBackpack:CreateBag(bagParent, bagClass)
	local bag = CreateFrame("Frame", bagParent..bagClass, self)

	table.insert(mbBags, bag)
	return bag
end


