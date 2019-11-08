--[[
LICENSE
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

DESCRIPTION:
	Item keys which require tooltip parsing to work
]]
local parent, ns = ...
local cargBags = ns.cargBags

local tipName = parent.."Tooltip"
local tooltip

local function generateTooltip()
	tooltip = CreateFrame("GameTooltip", tipName)
	tooltip:SetOwner(WorldFrame, "ANCHOR_NONE") 
	tooltip:AddFontStrings( 
		tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"), 
		tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
	)
end
local function GetBindText(text)
	local result
	if(text:match(ITEM_BIND_ON_EQUIP)) then result = "equip"
	elseif(text:match(ITEM_SOULBOUND)) then result = "soul"
	elseif(text:match(ITEM_BIND_QUEST)) then result = "quest"
	elseif(text:match(ITEM_BIND_TO_ACCOUNT)) then result = "account"
	elseif(text:match(ITEM_BIND_ON_PICKUP)) then result = "pickup"
	elseif(text:match(ITEM_BIND_ON_USE)) then result = "use" 
	end
	return result
end


cargBags.itemKeys["bindOn"] = function(i)
	if(not i.link) then return end

	if(not tooltip) then generateTooltip() end
	tooltip:ClearLines()
	tooltip:SetBagItem(i.bagID, i.slotID)

	local result = nil
	local bound = nil
	bound = _G[tipName.."TextLeft2"] and _G[tipName.."TextLeft2"]:GetText()
	
	if (bound) then
		result = GetBindText(bound)
	end
	
	if not bound or not result then
		bound = _G[tipName.."TextLeft3"] and _G[tipName.."TextLeft3"]:GetText()
		if (bound) then
			result = GetBindText(bound)
		end
	end
	
	i.bindOn = result
	return result
end

