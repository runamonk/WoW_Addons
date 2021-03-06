--[[
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]
local addon, ns = ...
local cargBags = ns.cargBags

--[[!
	@class Implementation
		The Implementation-class serves as the basis for your cargBags-instance, handling
		item-data-fetching and dispatching events for containers and items.
]]
local Implementation = cargBags:NewClass("Implementation", nil, "Button")
Implementation.instances = {}
Implementation.itemKeys = {}

local toBagSlot = cargBags.ToBagSlot
local L

local defaultFilters = {
	n = function(i, arg) return i.name and i.name:lower():match(arg) end,
	t = function(i, arg) return (i.type and i.type:lower():match(arg)) or (i.subType and i.subType:lower():match(arg)) or (i.equipLoc and i.equipLoc:lower():match(arg)) end,
	b = function(i, arg) return i.bindOn and i.bindOn:match(arg) end,
	q = function(i, arg) return i.rarity == tonumber(arg) end,
	bag = function(i, arg) return i.bagID == tonumber(arg) end,
	quest = function(i, arg) return i.isQuestItem end,

	_default = "n",
}

--[[!
	Creates a new instance of the class
	@param name <string>
	@return impl <Implementation>
]]
function Implementation:New(name)
	if(self.instances[name]) then return error(("cargBags: Implementation '%s' already exists!"):format(name)) end
	if(_G[name]) then return error(("cargBags: Global '%s' for Implementation is already used!"):format(name)) end

	local impl = setmetatable(CreateFrame("Button", name, UIParent), self.__index)
	impl.name = name

	impl:SetAllPoints()
	impl:EnableMouse(nil)
	impl:Hide()

	cargBags.SetScriptHandlers(impl, "OnEvent", "OnShow", "OnHide")

	impl.contByID = {} --! @property contByID <table> Holds all child-Containers by index
	impl.contByName = {} --!@ property contByName <table> Holds all child-Containers by name
	impl.buttons = {} -- @property buttons <table> Holds all ItemButtons by bagSlot
	impl.bagSizes = {} -- @property bagSizes <table> Holds the size of all bags
	impl.events = {} -- @property events <table> Holds all event callbacks
	impl.notInited = true -- @property notInited <bool>
	impl.itemCache = {}

	self.instances[name] = impl

	return impl
end

--[[!
	Script handler, inits and updates the Implementation when shown
	@callback OnOpen
]]
function Implementation:OnShow()
	if (self.notInited) and (not InCombatLockdown()) then
		self:Init()
	end

	if (self.OnOpen) then self:OnOpen() end
	self:OnEvent("BAG_UPDATE")
end

--[[!
	Script handler, closes the Implementation when hidden
	@callback OnClose
]]
function Implementation:OnHide()
	if(self.notInited) then return end

	if(self.OnClose) then self:OnClose() end
	if(self:AtBank()) then CloseBankFrame() end
end

function Implementation:SpawnPlugin(name, ...)
	if(cargBags.plugins[name]) then
		local plugin = cargBags.plugins[name](self, ...)
		if(plugin) then
			plugin.parent = self
		end
		return plugin
	end
end

function Implementation:ParseTextFilter(text, filters, textFilters)
	filters = filters or cargBags.classes.FilterSet:New()
	textFilters = textFilters or defaultFilters

	for match in text:gmatch("[^,;&]+") do
		local mod, type, value = match:trim():match("^(!?)(.-)[:=]?([^:=]*)$")
		mod = (mod == "!" and -1) or true
		if(value and type ~= "" and textFilters[type]) then
			filters:SetExtended(textFilters[type], value:lower(), mod)
		elseif(value and type == "" and textFilters._default) then
			local name = textFilters._default
			filters:SetExtended(textFilters[name], value:lower(), mod)
		end
	end

	return filters
end

--[[!
	Toggles the implementation
	@param forceopen <bool> Only open it
]]
function Implementation:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

--[[!
	Fetches an implementation by name
	@param name <string>
	@return impl <Implementation>
]]
function Implementation:Get(name)
	return self.instances[name]
end

--[[!
	Fetches a child-Container by name
	@param name <string>
	@return container <Container>
]]
function Implementation:GetContainer(name)
	return self.contByName[name]
end

--[[!
	Fetches a implementation-owned class by relative name

	The relative class names are prefixed by the name of the implementation
	e.g. :GetClass("Button") -> ImplementationButton
	It is just to prevent people from overwriting each others classes

	@param name <string> The relative class name
	@param create <bool> Creates it, if it doesn't exist
	@param ... Arguments to pass to cargBags:NewClass(name, ...) when creating
	@return class <table> The class prototype
]]
function Implementation:GetClass(name, create, ...)
	if(not name) then return end

	name = self.name..name
	local class = cargBags.classes[name]
	if(class or not create) then return class end

	class = cargBags:NewClass(name, ...)
	class.implementation = self
	return class
end

--[[!
	Wrapper for :GetClass() using a Container
	@note Container-classes have the full name "ImplementationNameContainer"
	@param name <string> The relative container class name
	@return class <table> The class prototype
]]
function Implementation:GetContainerClass(name)
	return self:GetClass((name or "").."Container", true, "Container")
end

--[[!
	Wrapper for :GetClass() using an ItemButton
	@note ItemButton-Classes have the full name "ImplementationNameItemButton"
	@param name <string> The relative itembutton class name
	@return class <table> The class prototype
]]
function Implementation:GetItemButtonClass(name)
	return self:GetClass((name or "").."ItemButton", true, "ItemButton")
end

--[[!
	Sets the ItemButton class to use for spawning new buttons
	@param name <string> The relative itembutton class name
	@return class <table> The newly set class
]]
function Implementation:SetDefaultItemButtonClass(name)
	self.buttonClass = self:GetItemButtonClass(name)
	return self.buttonClass
end

--[[!
	Registers the implementation to overwrite Blizzards Bag-Toggle-Functions
	@note This function only works before PLAYER_LOGIN and can be overwritten by other Implementations
]]
function Implementation:RegisterBlizzard()
	cargBags:RegisterBlizzard(self)
end

local _registerEvent = UIParent.RegisterEvent
local _isEventRegistered = UIParent.IsEventRegistered

--[[!
	Registers an event callback - these are only called if the Implementation is currently shown
	The events do not have to be 'blizz events' - they can also be internal messages
	@param event <string> The event to register for
	@param key Something passed to the callback as arg #1, also serves as identification
	@param func <function> The function to call on the event
]]
function Implementation:RegisterEvent(event, key, func)
	local events = self.events
	
	if(not events[event]) then
		events[event] = {}
	end

	events[event][key] = func
	if(event:upper() == event and not _isEventRegistered(self, event)) then
		_registerEvent(self, event)
	end
end

--[[!
	Returns whether the Implementation has the specified event callback
	@param event <string> The event of the callback
	@param key The identification of the callback [optional]
]]
function Implementation:IsEventRegistered(event, key)
	return self.events[event] and (not key or self.events[event][key])
end

--[[!
	Script handler, dispatches the events
]]
function Implementation:OnEvent(event, ...)
	if(not (self.events[event] and self:IsShown())) then return end

	for key, func in pairs(self.events[event]) do
		func(key, event, ...)
	end
end

--[[!
	Inits the implementation by registering events
	@callback OnInit
]]
function Implementation:Init()
	if (not self.notInited) then return end
	if (InCombatLockdown()) then
		return
	end
	
	self.notInited = nil

	if(self.OnInit) then self:OnInit() end

	if(not self.buttonClass) then
		self:SetDefaultItemButtonClass()
	end

	self:RegisterEvent("BAG_UPDATE", self, self.BAG_UPDATE)
	self:RegisterEvent("BAG_UPDATE_COOLDOWN", self, self.BAG_UPDATE_COOLDOWN)
	self:RegisterEvent("ITEM_LOCK_CHANGED", self, self.ITEM_LOCK_CHANGED)
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self, self.PLAYERBANKSLOTS_CHANGED)
	self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED", self, self.PLAYERREAGENTBANKSLOTS_CHANGED)
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self, self.UNIT_QUEST_LOG_CHANGED)
	self:RegisterEvent("BAG_CLOSED", self, self.BAG_CLOSED)
end

--[[!
	Returns whether the user is currently at the bank
	@return atBank <bool>
]]
function Implementation:AtBank()
	return cargBags.atBank
end

--[[
	Fetches a button by bagID-slotID-pair
	@param bagID <number>
	@param slotID <number>
	@return button <ItemButton>
]]
function Implementation:GetButton(bagID, slotID)
	return self.buttons[toBagSlot(bagID, slotID)]
end

--[[!
	Stores a button by bagID-slotID-pair
	@param bagID <number>
	@param slotID <number>
	@param button <ItemButton> [optional]
]]
function Implementation:SetButton(bagID, slotID, button)
	self.buttons[toBagSlot(bagID, slotID)] = button
end

local defaultItem = cargBags:NewItemTable()

--[[!
	Fetches the itemInfo of the item in bagID/slotID into the table
	@param bagID <number>
	@param slotID <number>
	@param i <table> [optional]
	@return i <table>
]]

local function IsItemBOE(item)
	if item.link and item.type and item.level > 0 and (item.classid == LE_ITEM_CLASS_WEAPON or 
				                                       item.classid == LE_ITEM_CLASS_ARMOR or
				                                       item.classid == LE_ITEM_CLASS_ITEM_ENHANCEMENT) then
		local scanTip = CreateFrame("GameTooltip", "scanTip", UIParent, "GameTooltipTemplate")
		scanTip:ClearLines()
		scanTip:SetHyperlink(item.link)	
		scanTip:SetOwner(UIParent,"ANCHOR_NONE")
		scanTip:SetBagItem(item.bagID, item.slotID)
		local l = ""

		for i=2, 4 do
			if _G["scanTipTextLeft"..i] then
				l = _G["scanTipTextLeft"..i]:GetText() or ""
				if l and l:find(ITEM_BIND_ON_EQUIP) then
					return true
				end
			end 
		end
	end
	return false
end

function Implementation:IsCached(clink, item, bagID, slotID)
	for i, _ in pairs(self.itemCache) do 
		if self.itemCache[i].link == clink and self.itemCache[i].bagID == bagID and self.itemCache[i].slotID == slotID then
			--print('IsCached: ', clink)
			mnkLibs.copyTable(self.itemCache[i].item, item)
			-- item is cached and stackable, we need to update the count.
			item.count = select(2, GetContainerItemInfo(bagID, slotID))
			return true
		end
	end

	return false
end

function Implementation:doCacheItem(item, bagID, slotID)
	local i = #self.itemCache+1
	self.itemCache[i] = {}
	self.itemCache[i].link = item.link
	self.itemCache[i].bagID = bagID
	self.itemCache[i].slotID = slotID
	self.itemCache[i].item = {}

	mnkLibs.copyTable(item, self.itemCache[i].item)
end

function Implementation:doDeleteCacheItem(link, bagID, slotID)
	--print('doDeleteCacheItem: ', link)
	for i, _ in pairs(self.itemCache) do
		if not link and self.itemCache[i].bagID == bagID and self.itemCache[i].slotID == slotID then
			table.remove(self.itemCache, i)
			return
		elseif self.itemCache[i].link == link and self.itemCache[i].bagID == bagID and self.itemCache[i].slotID == slotID then
			table.remove(self.itemCache, i)
			return
		end
	end
end

function Implementation:GetItemInfo(bagID, slotID, i)
	i = i or defaultItem
	for k in pairs(i) do i[k] = nil end

	i.bagID = bagID
	i.slotID = slotID
	i.boe = false
	i.isCompOrMount = false

	local clink = GetContainerItemLink(bagID, slotID)
	if (clink) then
		-- check if the item has been cached yet, if so we'll pull it from memory instead of the server.
		if self:IsCached(clink, i, bagID, slotID) then 
			return i	
		else
			local _
			i.texture, i.count, i.locked, i.quality, i.readable, _, i.link, _, _, i.id = GetContainerItemInfo(bagID, slotID)
			i.cdStart, i.cdFinish, i.cdEnable = GetContainerItemCooldown(bagID, slotID)
			i.isQuestItem, i.questID, i.questActive = GetContainerItemQuestInfo(bagID, slotID)
			i.isInSet, i.setName = GetContainerItemEquipmentSetInfo(bagID, slotID)
			local texture

			i.name, _, i.rarity, i.level, i.minLevel, i.type, i.subType, i.stackCount, i.equipLoc, texture, i.sellPrice, i.classid, i.subclassid  = GetItemInfo(clink)

			-- default items that come through without proper information as misc.
			if i.name == nil then
				local data, name = strmatch(clink, "|H(.-)|h(.-)|h")
				local  _, _, level, rarity, _, _, _, id = strmatch(data, "(%w+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
				i.type = GetItemClassInfo(15) -- Misc
				i.rarity = tonumber(rarity) or 0
				i.name = name
				i.level = tonumber(level) or 0
				i.classid = tonumber(LE_ITEM_CLASS_MISCELLANEOUS)	
				--print(i.link, ' ', i.name, ' ', i.id, ' ', i.classid, ' ', i.type, ' ', i.level)
			end
			
			if i.classid == LE_ITEM_CLASS_MISCELLANEOUS and (i.subclassid == LE_ITEM_MISCELLANEOUS_COMPANION_PET or i.subclassid == LE_ITEM_MISCELLANEOUS_MOUNT) then
				i.isCompOrMount = true
			end

			if (i.level > 0) and (i.classid == LE_ITEM_CLASS_WEAPON or i.classid == LE_ITEM_CLASS_ARMOR or i.classid == LE_ITEM_CLASS_ITEM_ENHANCEMENT) then 
				--print(i.link, ' ', i.type)
				if IsItemBOE(i) then
					i.boe = true
				end
				if i.rarity == LE_ITEM_QUALITY_ARTIFACT then
					-- for artifact weapons, GetItemInfo returns the actual ilvl
				else
					i.level = GetDetailedItemLevelInfo(clink) or i.level	--GetContainerItemLevel(clink, bagID, slotID) or i.level
				end
			end
			-- get the item spell to determine if the item is an Artifact Power boosting item
			-- if IsArtifactPowerItem(i.id) then
			-- 	i.type = ARTIFACT_POWER
			-- end
			--cache the item info so that we're not constantly looking it up and causing freezing or ui crashes.
			self:doCacheItem(i, bagID, slotID)
			return i
		end
		--print("GetItemInfo:", i.isInSet, i.setName, i.name)
	else
		return i
	end
end

--[[!
	Updates the defined slot, creating/removing buttons as necessary
	@param bagID <number>
	@param slotID <number>
]]
function Implementation:UpdateSlot(bagID, slotID)
	local item = self:GetItemInfo(bagID, slotID)
	local button = self:GetButton(bagID, slotID)
	local container = self:GetContainerForItem(item, button)
	
	--print('UpdateSlot() ', item.link, ' ', bagID, ' ', slotID)
	if(container) then
		if(button) then
			if(container ~= button.container) then
				self:doDeleteCacheItem(item.link, bagID, slotID)			
				button.container:RemoveButton(button)
				container:AddButton(button)
			end
		else
			button = self.buttonClass:New(bagID, slotID)
			self:doDeleteCacheItem(nil, bagID, slotID)
			self:SetButton(bagID, slotID, button)
			container:AddButton(button)
		end
		button:Update(item)
	elseif(button) then
		self:doDeleteCacheItem(item.link, bagID, slotID)
		button.container:RemoveButton(button)
		self:SetButton(bagID, slotID, nil)
		button:Free()
	end
end

local closed

--[[!
	Updates a bag and its containing slots
	@param bagID <number>
]]
function Implementation:UpdateBag(bagID)
	local numSlots
	if(closed) then
		numSlots, closed = 0
	else
		numSlots = GetContainerNumSlots(bagID)
	end
	local lastSlots = self.bagSizes[bagID] or 0
	self.bagSizes[bagID] = numSlots

	for slotID=1, numSlots do
		self:UpdateSlot(bagID, slotID)
	end
	for slotID=numSlots+1, lastSlots do
		local button = self:GetButton(bagID, slotID)
		if(button) then
			self:doDeleteCacheItem(nil, bagID, slotID)
			button.container:RemoveButton(button)
			self:SetButton(bagID, slotID, nil)
			button:Free()
		end
	end
end

--[[!
	Updates a set of items
	@param bagID <number> [optional]
	@param slotID <number> [optional]
	@callback Container:OnBagUpdate(bagID, slotID)
]]
function Implementation:BAG_UPDATE(event, bagID, slotID)
	--print(event, ' ', bagID, ' : ', slotID)
	if(bagID and slotID) then
		local item = self:GetItemInfo(bagID, slotID)
		self:doDeleteCacheItem(item.link, bagID, slotID)
		self:UpdateSlot(bagID, slotID)
	elseif(bagID) then
		self:UpdateBag(bagID)
	else
		self.SkipOnChange = true
		for bagID = -2, 11 do
			self:UpdateBag(bagID)
		end
		self.SkipOnChange = false
		self:UpdateAllBags()	
	end
end

--[[!
	Updates a bag of the implementation (fired when it is removed)
	@param bagID <number>
]]
function Implementation:BAG_CLOSED(event, bagID)
	closed = bagID
	self:BAG_UPDATE(event, bagID)
end

--[[!
	Fired when the item cooldowns need to be updated
	@param bagID <number> [optional]
]]
function Implementation:BAG_UPDATE_COOLDOWN(event, bagID)
	if(bagID) then
		for slotID=1, GetContainerNumSlots(bagID) do
			local button = self:GetButton(bagID, slotID)
			if(button) then
				local item = self:GetItemInfo(bagID, slotID)
				button:UpdateCooldown(item)
			end
		end
	else
		for id, container in pairs(self.contByID) do
			for i, button in pairs(container.buttons) do
				local item = self:GetItemInfo(button.bagID, button.slotID)
				button:UpdateCooldown(item)
			end
		end
	end
end

--[[!
	Fired when the item is picked up or released
	@param bagID <number>
	@param slotID <number> [optional]
]]
function Implementation:ITEM_LOCK_CHANGED(event, bagID, slotID)
	if(not slotID) then return end

	local button = self:GetButton(bagID, slotID)
	if(button) then
		local item = self:GetItemInfo(bagID, slotID)
		self:doDeleteCacheItem(item.link, bagID, slotID)
		button:UpdateLock(item)
	end
end

--[[!
	Fired when bank bags or slots need to be updated
	@param bagID <number>
	@param slotID <number> [optional]
]]
function Implementation:PLAYERBANKSLOTS_CHANGED(event, bagID, slotID)
	if(bagID <= NUM_BANKGENERIC_SLOTS) then
		slotID = bagID
		bagID = -1
	else
		bagID = bagID - NUM_BANKGENERIC_SLOTS
	end
	self:BAG_UPDATE(event, bagID, slotID)
end

--[[!
	Fired when reagent bank slots need to be updated
	@param bagID <number>
	@param slotID <number> [optional]
]]
function Implementation:PLAYERREAGENTBANKSLOTS_CHANGED(event, slotID)
	local bagID = -3

	self:BAG_UPDATE(event, bagID, slotID)
end

--[[
	Fired when the quest log of a unit changes
]]
function Implementation:UNIT_QUEST_LOG_CHANGED(event)
	for id, container in pairs(self.contByID) do
		for i, button in pairs(container.buttons) do
			local item = self:GetItemInfo(button.bagID, button.slotID)
			button:UpdateQuest(item)
		end
	end
end
