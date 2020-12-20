local mnkBackpack = CreateFrame('Frame', 'mnkBackpack', UIParent, BackdropTemplateMixin and "BackdropTemplate")
local Bags = {}
local bagMain, bagBank, bagReagent, bagJunk, bagNew = nil
local _
local doInit = true
local JunkItemsSold = 0
local NewItemsSold = 0

local mediaPath = [[Interface\AddOns\mnkBackpack\media\]]
local Textures = {
	Search =	mediaPath .. "Search",
	BagToggle =	mediaPath .. "BagToggle",
	ResetNew =	mediaPath .. "ResetNew",
	Restack =	mediaPath .. "Restack",
	Deposit =	mediaPath .. "Deposit"}

mnkBackpack:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBackpack:RegisterEvent('PLAYER_ENTERING_WORLD')

mnkBackpackKnownItems = {}

function mnkBackpack:CreateBag(bagParent, bagName)
	--print(bagParent, bagName)
	local bag = CreateFrame("Frame", (bagParent or "")..bagName, self)
	bag.Caption = bagName

	table.insert(Bags, bag)
	return bag
end

function mnkBackpack:Toggle()

end

function mnkBackpack:PLAYER_ENTERING_WORLD(event, firstTime, reload)
	if doInit or firstTime then
		ToggleBackpack = function(self) mnkBackpack:Toggle() end
		OpenAllBags = function(self) mnkBackpack:Toggle() end
		OpenBackpack = function(self) mnkBackpack:Toggle() end
		CloseAllBags = function(self) mnkBackpack:Toggle() end
		CloseBackpack = function(self) mnkBackpack:Toggle() end
		ToggleAllBags = function(self) mnkBackpack:Toggle() end

		for i = 0, NUM_LE_ITEM_CLASSS-1 do
			self:CreateBag("_bag", GetItemClassInfo(i))
			self:CreateBag("_bank", GetItemClassInfo(i))
		end

		bagJunk = self:CreateBag("_bag","Junk")
		bagNew = self:CreateBag("_bag", "New")

		local sort_func = function(a, b) return a:GetName() > b:GetName() end
	    table.sort(Bags, sort_func)

		bagReagent = self:CreateBag("_bank","Reagents")
		bagBank = self:CreateBag(nil,"_bank")
		bagMain = self:CreateBag(nil,"_bag")

		bagMain:SetPoint('BOTTOMRIGHT', -20, 220)
		bagBank:SetPoint('BOTTOMLEFT', 20, 220)
	end
end


