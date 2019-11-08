local P = unpack(select(2, ...))

local emptySlots = {}

local function GetFreeSlots(containerID)
	local freeSlots = 0
	if(containerID == BACKPACK_CONTAINER) then
		freeSlots = CalculateTotalNumberOfFreeBagSlots()
	elseif(containerID == BANK_CONTAINER and (P.atBank or BackpackBankDB ~= nil)) then
		freeSlots = Backpack:GetContainerNumFreeSlots(containerID)

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			freeSlots = freeSlots + Backpack:GetContainerNumFreeSlots(bagID)
		end
	elseif(containerID == REAGENTBANK_CONTAINER and (P.atBank or BackpackBankDB ~= nil)) then
		freeSlots = Backpack:GetContainerNumFreeSlots(containerID)
	end

	return freeSlots
end

local function Update(self)
	for _, EmptySlot in next, emptySlots do
		local freeSlots = GetFreeSlots(EmptySlot.bagID)
		EmptySlot.Count:SetText(freeSlots)
	end
end

local function GetContainerEmptySlot(bagID)
	if(Backpack:GetContainerNumFreeSlots(bagID) > 0) then
		for slotID = 1, Backpack:GetContainerNumSlots(bagID) do
			if(not Backpack:GetContainerItemInfo(bagID, slotID)) then
				return bagID, slotID
			end
		end
	end
end

local function GetEmptySlot(containerID)
	if(containerID == BACKPACK_CONTAINER) then
		for index = containerID, NUM_BAG_SLOTS do
			local bagID, slotID = GetContainerEmptySlot(index)
			if(slotID) then
				return bagID, slotID
			end
		end
	elseif(containerID == BANK_CONTAINER) then
		local bagID, slotID = GetContainerEmptySlot(containerID)
		if(slotID) then
			return bagID, slotID
		end

		for index = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			local bagID, slotID = GetContainerEmptySlot(index)
			if(slotID) then
				return bagID, slotID
			end
		end
	elseif(containerID == REAGENTBANK_CONTAINER) then
		local bagID, slotID = GetContainerEmptySlot(containerID)
		if(slotID) then
			return bagID, slotID
		end
	end
end

local function OnDrop(self)
	PickupContainerItem(GetEmptySlot(self.bagID))
end

local function CreateEmptySlot(bagID, categoryIndex)
	local Slot = P.CreateSlot(bagID, 99)
	Slot:SetScript('OnMouseUp', OnDrop)
	Slot:SetScript('OnReceiveDrag', OnDrop)
	Slot:SetScript('OnEnter', nil)
	Slot:Show()

	-- fake info so we get sorted last
	Slot.itemCount = 0
	Slot.itemQuality = 0
	Slot.itemID = 0
	Slot.itemLevel = 0

	P.AddCategorySlot(Slot, P.categories[categoryIndex])

	table.insert(emptySlots, Slot)

	return Slot
end

Backpack:On('PostCreateParent', function(bagID)
	if(bagID == BACKPACK_CONTAINER) then
		Backpack.EmptySlot = CreateEmptySlot(bagID, 1)
	elseif(bagID == BANK_CONTAINER) then
		BackpackBank.EmptySlot = CreateEmptySlot(bagID, 1)
	elseif(bagID == REAGENTBANK_CONTAINER) then
		BackpackBankContainerReagentBank.EmptySlot = CreateEmptySlot(bagID, 1002)
	end

	Update()
end)

Backpack:AddModule('FreeSlots', nil, Update, false, 'BAG_UPDATE_DELAYED', 'BANKFRAME_OPENED')
