local P, E, L = unpack(select(2, ...))

local categoryName = L['Junk']
local categoryIndex = 1e3

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and type(custom) == 'number') then
		return custom == categoryIndex
	else
		local _, _, _, quality = Backpack:GetContainerItemInfo(bagID, slotID)
		return quality == LE_ITEM_QUALITY_POOR
	end
end

local sortFunc = function(slotA, slotB)
	local _, _, _, _, _, _, _, _, _, _, worthA = GetItemInfo(slotA.itemID)
	local _, _, _, _, _, _, _, _, _, _, worthB = GetItemInfo(slotB.itemID)
	return ((worthA or 0) * slotA.itemCount) > ((worthB or 0) * slotB.itemCount)
end

P.AddCategory(categoryIndex, categoryName, 'Junk', categoryFilter, sortFunc)

local lastNumItems = 0
local function Update(event)
	if(BackpackDB.autoSellJunk) then
		if(event == 'MERCHANT_SHOW' or lastNumItems > 0) then
			lastNumItems = 0

			local Container = P.GetCategoryContainer(Backpack, 1e3)
			for _, Slot in next, Container.slots do
				if(not MerchantFrame:IsShown()) then
					return
				end

				lastNumItems = lastNumItems + 1
				UseContainerItem(Slot.bagID, Slot.slotID)
			end
		end
	end
end

local function OnClick(self)
	BackpackDB.autoSellJunk = not BackpackDB.autoSellJunk
end

local function Init(self)
	local Button = P.CreateContainerButton('ToggleSellJunk', categoryIndex)
	Button:SetScript('OnClick', OnClick)
	Button.tooltipText = L['Toggle auto-vendoring']
	self.ToggleSellJunk = Button

	P.Fire('PostCreateSellJunk', Button)
end

Backpack:AddModule('SellJunk', Init, Update, false, 'MERCHANT_SHOW', 'MERCHANT_CLOSED', 'BAG_UPDATE_DELAYED')
