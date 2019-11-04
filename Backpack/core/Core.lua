local P, E = unpack(select(2, ...))

local Backpack = CreateFrame('Frame', P.name, UIParent)
Backpack:Hide()
Backpack.locked = true
Backpack.Dropdown = LibStub('LibDropDown'):NewMenu(Backpack)
P.MixinAPI(Backpack)

local Bank = CreateFrame('Frame', '$parentBank', Backpack)
Bank:Hide()
Bank:HookScript('OnHide', function()
	if(P.atBank) then
		CloseBankFrame()
	end
end)

Backpack:SetScript('OnHide', function()
	Bank:Hide()
end)

function E:ADDON_LOADED(addon)
	if(addon == P.name) then
		BackpackBankDB = BackpackBankDB or {}
		BackpackKnownItems = BackpackKnownItems or {}

		BackpackDB = BackpackDB or {categories={}} -- rest of defaults set by Wasabi

		BackpackCategoriesDB = BackpackCategoriesDB or {categories={}} -- weird, I know
		BackpackContainerOrderDB = BackpackContainerOrderDB or {{},{}}

		for _, categoryInfo in next, P.categories do
			local categoryIndex = categoryInfo.index
			if(not BackpackCategoriesDB.categories[categoryIndex]) then
				BackpackCategoriesDB.categories[categoryIndex] = {enabled = true}
			end

			if(BackpackCategoriesDB.categories[categoryIndex].enabled) then
				if(categoryIndex ~= 1002) then -- no reagentbank for default inventory
					P.CreateContainer(categoryInfo, Backpack)
				end

				P.CreateContainer(categoryInfo, Bank)
			end
		end

		P.InitializePosition(Backpack)
		P.InitializePosition(Bank)

		-- Hide on escape
		table.insert(UISpecialFrames, P.name)

		return true
	end
end

function E:PLAYER_LOGIN()
	if(Backpack:GetContainerNumSlots(BANK_CONTAINER) > 0) then
		P.InitializeBank()
	end

	P.LoadModules()

	return true
end

function E:UI_SCALE_CHANGED()
	P.UpdateContainerPositions(Backpack)
	P.UpdateContainerPositions(Bank)
end

function E.BAG_UPDATE(event, bagID)
	if(not P.HasParent(BACKPACK_CONTAINER)) then
		-- doesn't seem to have its own event
		P.InitializeAllSlots(BACKPACK_CONTAINER)
	end

	if(not P.HasParent(bagID)) then
		P.InitializeAllSlots(bagID)
	end

	if(P.HasParent(bagID)) then
		P.UpdateContainerSlots(bagID, event)
		P.PositionSlots()
	end
end

function E.ITEM_LOCK_CHANGED(event, bagID, slotID)
	if(P.HasParent(bagID)) then
		if(slotID) then
			P.UpdateSlot(bagID, slotID, event)
		else
			P.UpdateContainerSlots(bagID, event)
		end

		P.PositionSlots()
	end
end

function E:BAG_UPDATE_COOLDOWN()
	if(Backpack:IsVisible()) then
		P.UpdateContainerCooldowns(BACKPACK_CONTAINER, NUM_BAG_SLOTS)
	end

	if(Bank:IsVisible()) then
		P.UpdateContainerCooldowns(BANK_CONTAINER)
		P.UpdateContainerCooldowns(NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
	end
end

function E.QUEST_ACCEPTED(event)
	P.UpdateAllSlots(event)
end

function E.UNIT_QUEST_LOG_CHANGED(event, unit)
	if(unit == 'player') then
		P.UpdateAllSlots(event)
	end
end

function E.PLAYERBANKSLOTS_CHANGED(event, slotID)
	if(P.HasParent(BANK_CONTAINER)) then
		P.UpdateSlot(BANK_CONTAINER, slotID, event)

		if(Bank:IsVisible()) then
			P.PositionSlots()
		end
	end
end

function E.PLAYERREAGENTBANKSLOTS_CHANGED(event, slotID)
	if(P.HasParent(REAGENTBANK_CONTAINER)) then
		P.UpdateSlot(REAGENTBANK_CONTAINER, slotID, event)

		if(Bank:IsVisible()) then
			P.PositionSlots()
		end
	end
end

local function REAGENTBANK_PURCHASED(event)
	P.InitializeAllSlots(REAGENTBANK_CONTAINER)
	P.UpdateContainerSlots(REAGENTBANK_CONTAINER, event)
	P.PositionSlots()

	return true
end

function E.BANKFRAME_OPENED(event)
	P.atBank = true

	if(not P.HasParent(BANK_CONTAINER)) then
		P.InitializeBank()
	end

	if(Bank:IsVisible() or Backpack:IsVisible()) then
		P.UpdateAllSlots(event)
		P.PositionSlots()
	end

	Backpack:Toggle(true, true)
end

function E:BANKFRAME_CLOSED()
	P.atBank = false
	Backpack:Toggle(false)
end

P.query = {}
function E.GET_ITEM_INFO_RECEIVED(event)
	if(#P.query > 0) then
		for index, Slot in next, P.query do
			local bagID, slotID = Slot.bagID, Slot.slotID
			local itemLink = Backpack:GetContainerItemLink(bagID, slotID)
			if(itemLink and GetItemInfo(itemLink)) then
				table.remove(P.query, index)
				P.UpdateSlot(bagID, slotID, event)
			end
		end

		P.PositionSlots()
	end
end

function P.InitializeBank()
	P.InitializeAllSlots(BANK_CONTAINER)

	if(IsReagentBankUnlocked()) then
		P.InitializeAllSlots(REAGENTBANK_CONTAINER)
	else
		E:RegisterEvent('REAGENTBANK_PURCHASED', REAGENTBANK_PURCHASED)
	end
end

local callbacks = {}
function P.Fire(event, ...)
	local eventCallbacks = callbacks[event]
	if(eventCallbacks) then
		for _, callback in next, eventCallbacks do
			callback(...)
		end
	end
end

local overrides, layout = {}
function P.Override(event, ...)
	if(overrides[event]) then
		overrides[event](...)
		return true
	end
end

function P.SkinCallback(event, ...)
	if(layout) then
		if(event == 'Slot') then
			layout.slotFunc(...)
		elseif(event == 'Container') then
			layout.containerFunc(...)
		end
	end
end

function P.Expose(name, reference)
	Backpack[name] = reference
end

-- @name Backpack:Toggle
-- @usage Backpack:Toggle([force, [includeBank]])
-- @param force       - Boolean to force open/close the bags
-- @param includeBank - Boolean to open "offline" bank as well
P.Expose('Toggle', function(self, force, includeBank)
	local shouldShow, shouldShowBank

	if(not includeBank and BackpackDB.bankmodifier) then
		local mod = BackpackDB.bankmodifier
		if(mod ~= 0) then
			includeBank = _G[BackpackDB.bankmodifier]()
		end
	end

	local isShown = self:IsShown()
	if(((not isShown and force ~= false) or force) and not (isShown and not force)) then
		shouldShow = true
	end

	if(includeBank and not Bank:IsShown() and Backpack:GetContainerNumSlots(BANK_CONTAINER) > 0) then
		shouldShowBank = true
	end

	if(not P.HasParent(BACKPACK_CONTAINER)) then
		-- BAG_UPDATE doesn't fire after reloads when the character doesn't have any additional bags.
		-- we force update for the backpack, then for each container that has slots.
		E.BAG_UPDATE('OnShow', BACKPACK_CONTAINER)

		for bagID = 1, 4 do
			if(GetContainerNumSlots(bagID) > 0) then
				E.BAG_UPDATE('OnShow', bagID)
			end
		end
	end

	if(shouldShow or shouldShowBank) then
		if(not isShown) then
			P.UpdateAllSlots('OnShow')
			P.PositionSlots()
		end

		self:Show()

		if(shouldShowBank) then
			Bank:Show()
		end
	elseif(not shouldShow) then
		self:Hide()
	end
end)

-- @name Backpack:On
-- @usage Backpack:On(event, callback)
-- @param event    - Event to listen for
-- @param callback - Function that will be called when the event happens
P.Expose('On', function(self, event, callback)
	if(not callbacks[event]) then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], callback)
end)

-- @name Backpack:AddLayout
-- @usage Backpack:AddLayout(name, containerFunc, slotFunc)
-- @param name          - Name of layout
-- @param containerFunc - Function that will apply skin to containers
-- @param slotFunc      - Function that will apply skin to slots
P.Expose('AddLayout', function(_, name, containerFunc, slotFunc)
	-- TODO: argcheck

	if(layout) then
		P.error(L['A layout already exists (%s)'], layout.name)
	else
		layout = {
			name = name,
			slotFunc = slotFunc,
			containerFunc = containerFunc,
		}

		-- skin all containers
		for parentContainer, containers in next, P.GetAllContainers() do
			for categoryIndex, Container in next, containers do
				containerFunc(Container)
			end
		end

		-- skin all slots
		for bagID, Parent in next, P.GetAllParents() do
			for slotID, Slot in next, P.GetAllSlots(bagID) do
				slotFunc(Slot)
			end
		end
	end
end)

-- @name Backpack:Override
-- @usage Backpack:Override(event, func)
-- @param event - Event to override
-- @param func  - Function to override the event with
P.Expose('Override', function(_, event, func)
	-- TODO: argcheck

	if(overrides[event]) then
		P.error(L['Override for "%s" already exists'], event)
	else
		overrides[event] = func
	end
end)

P.noop = function() end
