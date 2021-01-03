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

local _G = _G

--[[!
	@class ItemButton
		This class serves as the basis for all itemSlots in a container
]]
local ItemButton = cargBags:NewClass("ItemButton", nil, "Button")

--[[!
	Gets a template name for the bagID
	@param bagID <number> [optional]
	@return tpl <string>
]]
function ItemButton:GetTemplate(bagID)
	bagID = bagID or self.bagID
	return (bagID == -3 and "ReagentBankItemButtonGenericTemplate") or (bagID == -1 and "BankItemButtonGenericTemplate") or (bagID and "ContainerFrameItemButtonTemplate") or "",
      (bagID == -3 and ReagentBankFrame) or (bagID == -1 and BankFrame) or (bagID and _G["ContainerFrame"..bagID + 1]) or "";
end 

local mt_gen_key = {__index = function(self,k) self[k] = {}; return self[k]; end}

--[[!
	Fetches a new instance of the ItemButton, creating one if necessary
	@param bagID <number>
	@param slotID <number>
	@return button <ItemButton>
]]
function ItemButton:New(bagID, slotID)
	self.recycled = self.recycled or setmetatable({}, mt_gen_key)
	local tpl, parent = self:GetTemplate(bagID)
	local button = table.remove(self.recycled[tpl]) or self:Create(tpl, parent)
	button.bagID = bagID
	button.slotID = slotID
	button:SetID(slotID)
	button:Show()
	return button
end

--[[!
	Creates a new ItemButton
	@param tpl <string> The template to use [optional]
	@return button <ItemButton>
	@callback button:OnCreate(tpl)
]]
local bFS
function ItemButton:Create(tpl, parent)
	local impl = self.implementation
	impl.numSlots = (impl.numSlots or 0) + 1
	local name = ("%sSlot%d"):format(impl.name, impl.numSlots)
	local button = setmetatable(CreateFrame("ItemButton", name, parent, tpl), self.__index)
	local btnNT = _G[button:GetName().."NormalTexture"]
	local btnNIT = button.NewItemTexture
	local btnBIT = button.BattlepayItemTexture
	if btnNT then btnNT:SetTexture("") end
	if btnNIT then btnNIT:SetTexture("") end
	if btnBIT then btnBIT:SetTexture("") end

	bFS = _G[button:GetName().."Count"]
	bFS.Count = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 16, nil, nil, true)
	bFS:ClearAllPoints()
	bFS:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1.5, 1.5);
	button.glowTex = "Interface\\Buttons\\UI-ActionButton-Border" --! @property glowTex <string> The textures used for the glow
	button.glowAlpha = 0.8 --! @property glowAlpha <number> The alpha of the glow texture
	button.glowBlend = "ADD" --! @property glowBlend <string> The blendMode of the glow texture
	button.glowCoords = { 14/64, 50/64, 14/64, 50/64 } --! @property glowCoords <table> Indexed table of texCoords for the glow texture
	button.bgTex = nil --! @property bgTex <string> Texture used as a background if no item is in the slot

	button.Icon = _G[name.."IconTexture"]
	button.Count = _G[name.."Count"]
	button.Cooldown = _G[name.."Cooldown"]
	button.Quest = _G[name.."IconQuestTexture"]

    button.Count = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 16, nil, nil, true)
    button.Count:SetPoint('BOTTOMRIGHT', 0, 0)
	button.ItemLevel = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 18, nil, nil, true)
    button.ItemLevel:SetPoint('CENTER', 0, 0)
    button.ItemLevel:SetJustifyH('CENTER')
    button.ItemLevel:SetShadowOffset(2, -2)
	button.boe = mnkLibs.createFontString(button, mnkLibs.Fonts.ap, 50, nil, nil, true)
    button.boe:SetPoint('TOPLEFT', -1, 35)
    button.boe:SetJustifyH('LEFT')
    button.boe:SetTextColor(1, 0, 0, 1)
    button.boe:SetText('.')
    button.boe:Hide()

	button:HookScript('OnClick', 
		function (self)
       		if (self.OnClick) then self:OnClick(self) end
       	end)

	if (button.OnCreate) then button:OnCreate(tpl, parent, button) end

	return button
end

--[[!
	Frees an ItemButton, storing it for later use
]]
function ItemButton:Free()
	self:Hide()
	table.insert(self.recycled[self:GetTemplate()], self)
end

--[[!
	Fetches the item-info of the button, just a small wrapper for comfort
	@param item <table> [optional]
	@return item <table>
]]
function ItemButton:getItemInfo(item)
	return self.implementation:GetItemInfo(self.bagID, self.slotID, item)
end

function ItemButton:Update(item)
	if item.texture then
		local tex = item.texture or self.bgTex
		if tex then
			self.Icon:SetTexture(tex)
			self.Icon:SetTexCoord(.08, .92, .08, .92)
		else
			self.Icon:SetColorTexture(1,1,1,0.1)
		end
	else
		self.Icon:SetTexture(self.bgTex)
		self.Icon:SetTexCoord(.08, .92, .08, .92)
	end
	if(item.count and item.count > 1) then
		self.Count:SetText(item.count >= 1e3 and "*" or item.count)
		self.Count:Show()
	else
		self.Count:Hide()
	end
	self.count = item.count
	
	if item.boe then
		self.boe:Show()
	else
		self.boe:Hide()	
	end

	-- Item Level
	if item.link then
		if item.isCompOrMount then
			self.ItemLevel:SetTextColor(1, 0, 0, 1)
		elseif (item.type and (item.level and item.level > 0)) and (item.classid == LE_ITEM_CLASS_WEAPON or    
			                                                        item.classid == LE_ITEM_CLASS_ARMOR or
			                                                        item.classid == LE_ITEM_CLASS_ITEM_ENHANCEMENT) then 
			local r,g,b = GetItemQualityColor(item.rarity);
			self.ItemLevel:SetText(item.level)
			self.ItemLevel:SetTextColor(r, g, b, 1)
			self.ItemLevel:SetShadowColor(r/5, g/5, b/5, 1)	
		else
			self.ItemLevel:SetTextColor(1, 1, 1, 1)
			self.ItemLevel:SetText("")
		end
	else
		self.ItemLevel:SetText("")
	end

	self:UpdateCooldown(item)
	self:UpdateLock(item)
	self:UpdateQuest(item)

	if (self.OnUpdate) then self:OnUpdate(item) end
end

function ItemButton:UpdateCooldown(item)
	--print(item.name, item.cdEnable, item.cdStart, item.cdFinish)
   	if (item.cdEnable == 1 and item.cdStart and item.cdStart > 0) then
   		self.Cooldown:SetCooldown(item.cdStart, item.cdFinish)
   		--self.Cooldown:GetRegions():SetTextColor(1, 0, 0);
		self.Cooldown:GetRegions():SetFont(mnkLibs.Fonts.ap, 16, "")
		--self.Cooldown:GetRegions():Show()
   		self.Cooldown:Show()
   	else
   		self.Cooldown:Hide()
    end

	if (self.OnUpdateCooldown) then self:OnUpdateCooldown(item) end
end

function ItemButton:OnUpdateCooldown(item)
	--print('OnUpdateCooldown')
end

function ItemButton:UpdateLock(item)
	self.Icon:SetDesaturated(item.locked)

	if(self.OnUpdateLock) then self:OnUpdateLock(item) end
end

function ItemButton:UpdateQuest(item)
	if (self.OnUpdateQuest) then self:OnUpdateQuest(item) end
end