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
local _, ns = ...
local cargBags = ns.cargBags

--[[!
	@class Container
		The container class provides the virtual bags for cargBags
]]
local Container = cargBags:NewClass("Container", nil, "Button")

local mt_bags = {__index=function(self, bagID)
	self[bagID] = CreateFrame("Frame", nil, self.container)
	self[bagID]:SetID(bagID)
	return self[bagID]
end}

--[[!
	Creates a new instance of the class
	@param name <string>
	@param ... Arguments passed to the OnCreate-callback
	@return container <Container>
	@callback container:OnCreate(name, ...)
]]
function Container:New(name, bagCaption, ...)
	local implName = self.implementation.name
	local container = setmetatable(CreateFrame("Button", implName..name), self.__index)

	container.name = name
	container.buttons = {}
	container.bags = setmetatable({container = container}, mt_bags)
	container.implementation.contByName[name] = container
	container.ParseTextFilter = self.implementation.ParseTextFilter
	container.SpawnPlugin = self.implementation.SpawnPlugin
	container.bagCaption = bagCaption
	table.insert(container.implementation.contByID, container)
	container:SetParent(self.implementation)
	if(container.OnCreate) then container:OnCreate(name, ...) end
	return container
end

--[[!
	Adds an ItemButton to this container
	@param button <ItemButton>
	@callback button:OnAdd(self)
	@callback OnButtonAdd(button)
]]
function Container:AddButton(button)
	button.container = self
	button:SetParent(self.bags[button.bagID])
	
	local clink = GetContainerItemLink(button.bagID, button.slotID)
	if clink then
		button.clink = clink
	else
		button.clink = nil
	end

	table.insert(self.buttons, button)
	if(button.OnAdd) then button:OnAdd(self) end
	if(self.OnButtonAdd) then self:OnButtonAdd(button) end
	self:OnContentsChanged()
end

--[[!
	Removes an ItemButton from the container
	@param button <ItemButton>
	@callback button:OnRemove(self)
	@callback OnButtonRemove(button)
]]
function Container:RemoveButton(button)
	for i, single in ipairs(self.buttons) do
		if(button == single) then
			button.container = nil
			if(button.OnRemove) then button:OnRemove(self) end
			if(self.OnButtonRemove) then self:OnButtonRemove(button) end
			table.remove(self.buttons, i)
		end
	end
	self:OnContentsChanged()
end

--[[
	Applies a function to the contained buttons
	@param func <function>
	@param ... Arguments which are passed to the function
]]
function Container:ApplyToButtons(func, ...)
	for i, button in pairs(self.buttons) do
		func(button, ...)
	end
end

function Container:SetTextFilter(text, textFilters)
	self.filters = self:ParseTextFilter(text, self.filters, textFilters)
end