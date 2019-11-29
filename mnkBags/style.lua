local addon, ns = ...
local cargBags = ns.cargBags

local mediaPath = [[Interface\AddOns\mnkBags\media\]]
local Textures = {
	Search =		mediaPath .. "Search",
	BagToggle =		mediaPath .. "BagToggle",
	ResetNew =		mediaPath .. "ResetNew",
	Restack =		mediaPath .. "Restack",
	Deposit =		mediaPath .. "Deposit"
}

local _
local itemSlotSize = 32
local itemSlotPadding = 4
local itemSlotSpacer = 2
local BagFrames, BankFrames =  {}, {}

local cbmb = cargBags:GetImplementation("mb")
local MyContainer = cbmb:GetContainerClass()

local function createIconButton(name, parent, texture, point, hint, isBag)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(17)
	button:SetHeight(17)
	
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetPoint(point, button, point, point == "BOTTOMLEFT" and 2 or -2, 2)
	button.icon:SetWidth(16)
	button.icon:SetHeight(16)
	button.icon:SetTexture(texture)
	button.icon:SetVertexColor(0.8, 0.8, 0.8)
	mnkLibs.setTooltip(button, hint)

	button.tag = name	
	return button
end

local function GetFirstFreeSlot(bagtype)
	if bagtype == "bag" then
		for i = 0,4 do
			local t = GetContainerNumFreeSlots(i)
			if t > 0 then
				local tNumSlots = GetContainerNumSlots(i)
				for j = 1,tNumSlots do
					local tLink = GetContainerItemLink(i,j)
					if not tLink then return i,j end
				end
			end
		end
	elseif bagtype == "bankReagent" then
		local bagID = -3
		local t = GetContainerNumFreeSlots(bagID)
		if t > 0 then
			local tNumSlots = GetContainerNumSlots(bagID)
			for j = 1,tNumSlots do
				local tLink = GetContainerItemLink(bagID,j)
				if not tLink then return bagID,j end
			end
		end
	else
		local containerIDs = {-1,5,6,7,8,9,10,11}
		for _,i in next, containerIDs do
			local t = GetContainerNumFreeSlots(i)
			if t > 0 then
				local tNumSlots = GetContainerNumSlots(i)
				for j = 1,tNumSlots do
					local tLink = GetContainerItemLink(i,j)
					if not tLink then return i,j end
				end
			end
		end	
	end
	return false
end

local function GetNumFreeSlots(bagType)
	local free, max = 0, 0
	if bagType == "bag" then
		for i = 0,4 do
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	elseif bagType == "bankReagent" then
		free = GetContainerNumFreeSlots(-3)
		max = GetContainerNumSlots(-3)
	else
		local containerIDs = {-1,5,6,7,8,9,10,11}
		for _,i in next, containerIDs do	
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	end
	return free, max
end

local function resetNewItems()
	mnkBagsKnownItems = mnkBagsKnownItems or {}
	if not mnkBagsGlobals.clean then
		for item, numItem in next, mnkBagsKnownItems do
			if type(item) == "string" then
				mnkBagsKnownItems[item] = nil
			end
		end
		mnkBagsGlobals.clean = true
	end
	for bag = 0, 4 do
		local tNumSlots = GetContainerNumSlots(bag)
		if tNumSlots > 0 then
			for slot = 1, tNumSlots do
				local item = cbmb:GetItemInfo(bag, slot)
				if item.id then
					if mnkBagsKnownItems[item.id] then
						mnkBagsKnownItems[item.id] = mnkBagsKnownItems[item.id] + (item.stackCount and item.stackCount or 0)
					else
						mnkBagsKnownItems[item.id] = item.stackCount and item.stackCount or 0
					end
				end
			end 
		end
	end
	cbmb:UpdateBags()
end

local function restackItems(self)
	local tBag, tBank = (self.name == "mb_Bag"), (self.name == "mb_Bank")
	if tBank then
		self:RegisterEvent('BAG_UPDATE_DELAYED')
		SortBankBags()
	elseif tBag then
		SortBags()
	end
end

function MyContainer:OnContentsChanged(forced)

	local col, row = 0, 0
	local yPosOffs = 20

	local tName = self.name
	local tBankBags = string.find(tName, "Bank")
	local tBank = tBankBags or (tName == "mb_Bank")
	local tReagent = (tName == "mb_BankReagent")
	
	local numSlotsBag = {GetNumFreeSlots("bag")}
	local numSlotsBank = {GetNumFreeSlots("bank")}
	local numSlotsReagent = {GetNumFreeSlots("bankReagent")}
	
	local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
	local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
	local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]
	
	local oldColumns = self.Columns
	
	self.Columns = 12
	
	local needColumnUpdate = (self.Columns ~= oldColumns)

	local buttonIDs = {}
  	for i, button in pairs(self.buttons) do
  		local clink = GetContainerItemLink(button.bagID, button.slotID)
  		if clink then
  			local name = select(1, GetItemInfo(clink))
  			buttonIDs[i] = { name, button}
  		else
  			buttonIDs[i] = { nil, button}
  		end
	end
	
	-- sort by name.
	local function sort(v1, v2)
		if (v1[1] == nil) and (v2[1] == nil) then return false end
		if (v1[1] == nil) or (v2[1] == nil) then return (v1[1] and true or false) end

 		return v1[1] < v2[1] 
	end

	table.sort(buttonIDs, sort)

	for _,v in ipairs(buttonIDs) do
		local button = v[2]
		button:ClearAllPoints()
	  
		local xPos = col * (itemSlotSize + itemSlotPadding) + itemSlotSpacer
		local yPos = (-1 * row * (itemSlotSize + itemSlotPadding)) - yPosOffs

		button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
		if(col >= self.Columns-1) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end

	-- compress empty slots.
	local xPos = col * (itemSlotSize + itemSlotPadding) + itemSlotSpacer
	local yPos = (-1 * row * (itemSlotSize + itemSlotPadding)) - yPosOffs

	local tDrop = self.DropTarget
	if tDrop then
		tDrop:ClearAllPoints()
		tDrop:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
		if(col >= self.Columns-1) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end
	
	_Bags.main.EmptySlotCounter:SetText(GetNumFreeSlots("bag"))
	_Bags.bank.EmptySlotCounter:SetText(GetNumFreeSlots("bank"))
	_Bags.bankReagent.EmptySlotCounter:SetText(GetNumFreeSlots("bankReagent"))

	self:UpdateDimensions(self)

	if self:ShowOrHide() then
		self:Show()
	else
		self:Hide()
	end

	cbmb:UpdateAnchors()

	--update all other bags as well
	if needColumnUpdate and not forced then
		if tBankBags then
			local t = BankFrames
			for i=1,#t do
				if t[i].name ~= tName then
					t[i]:OnContentsChanged(true)
				end
			end
		else
			local t = BagFrames
			for i=1,#t do
				if t[i].name ~= tName then
					t[i]:OnContentsChanged(true)
				end
			end
		end
	end
end

function MyContainer:OnCreate(name, settings)
	settings = settings or {}
	self.Settings = settings
	self.name = name
	self.Columns = 12
	self:EnableMouse(true)
	self:SetFrameStrata("HIGH")

	self.Caption = mnkLibs.createFontString(self, mnkLibs.Fonts.ap, 16, nil, nil, true)
	self.Caption:SetText(mbLocals.bagCaptions[self.name])
	self.Caption:SetPoint("TOPLEFT", 0, 2)

	self.background = CreateFrame("Frame", nil, self)
	mnkLibs.setBackdrop(self, mnkLibs.Textures.background, nil, 4, 4, 4, 4)
	mnkLibs.createBorder(self, 5,-5,-5,5, {1/3,1/3,1/3,1})
	self.background:SetFrameStrata("HIGH")
	self.background:SetFrameLevel(1)
	self:SetBackdropColor(0, 0, 0, 1)

	local tBag, tBank, tReagent = (name == "mb_Bag"), (name == "mb_Bank"), (name == "mb_BankReagent")
	local tBankBags = string.find(name, "Bank")
	table.insert((tBankBags and BankFrames or BagFrames), self)
	
	local numSlotsBag = {GetNumFreeSlots("bag")}
	local numSlotsBank = {GetNumFreeSlots("bank")}
	local numSlotsReagent = {GetNumFreeSlots("bankReagent")}
	local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
	local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
	local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]

	tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

	if (tBag or tBank) then 
		self:SetMovable(true)
		self:SetUserPlaced(true)
		self:RegisterForClicks("LeftButton", "RightButton")
		self:SetScript("OnMouseDown", function() 
			self:ClearAllPoints() 
			self:StartMoving() 
		end)
		self:SetScript("OnMouseUp",  self.StopMovingOrSizing)

		self.CloseButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.CloseButton:SetDisabledTexture("Interface\\AddOns\\mnkBags\\media\\Close")
		self.CloseButton:SetNormalTexture("Interface\\AddOns\\mnkBags\\media\\Close")
		self.CloseButton:SetPushedTexture("Interface\\AddOns\\mnkBags\\media\\Close")
		self.CloseButton:SetHighlightTexture("Interface\\AddOns\\mnkBags\\media\\Close")		
		self.CloseButton:ClearAllPoints()
		self.CloseButton:SetPoint("TOPRIGHT", 2, 0)
		self.CloseButton:SetSize(12,12)
		self.CloseButton:SetScript("OnClick", function(self) if cbmb:AtBank() then CloseBankFrame() else CloseAllBags() end end)

		if tBag then
			self:SetBackdropColor(1/8, 1/5, 1/8, 1)
			self.pluginBagBar = self:SpawnPlugin("BagBar", "backpack+bags")
			self.pluginBagBar:SetSize(self.pluginBagBar:LayoutButtons("grid", 4))
			self.SearchButton = CreateFrame("Button", nil, self)
			self.SearchButton:SetWidth(self:GetWidth()-32) -- subtract both buttons.
			self.SearchButton:SetHeight(16)
			self.SearchButton:SetPoint("BOTTOMLEFT", 5, -8)
			self.SearchButton:SetPoint("BOTTOMRIGHT", -86, -8)


			self.pluginSearch = self:SpawnPlugin("SearchBar", self.SearchButton)
			self.pluginSearch.isGlobal = true
			self.pluginSearch.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
			self.SearchIcon = self:CreateTexture(nil, "ARTWORK") 
			self.SearchIcon:SetTexture(Textures.Search)
			self.SearchIcon:SetVertexColor(0.8, 0.8, 0.8)
			self.SearchIcon:SetPoint("BOTTOMLEFT", self.SearchButton, "BOTTOMLEFT", -3, 8)
			self.SearchIcon:SetWidth(16)
			self.SearchIcon:SetHeight(16)
		else
			self:SetBackdropColor(1/5, 1/8, 1/8, 1)
			self.pluginBagBar = self:SpawnPlugin("BagBar", "bank")
			self.pluginBagBar:SetSize(self.pluginBagBar:LayoutButtons("grid", 7))
		end
		
		self.pluginBagBar.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		self.pluginBagBar.isGlobal = true
		self.pluginBagBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 25)
		self.pluginBagBar:Hide()

		self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", "Toggle Bags", tBag)
		self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
		self.bagToggle:SetScript("OnClick", function()
			if(self.pluginBagBar:IsShown()) then 
				self.pluginBagBar:Hide()
			else
				self.pluginBagBar:Show()
			end
			self:UpdateDimensions(self)
		end)
		
		self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack", tBag)
		self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
		self.restackBtn:SetScript("OnClick", function() restackItems(self) end)
	end

	if self.name == 'mb_NewItems' then
		self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "TOPRIGHT", "Reset New", tBag)
		self.resetBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.resetBtn:SetScript("OnClick", function() resetNewItems(self) end)
	end
	
	if self.name == 'mb_BankReagent' then
		self.reagentBtn = createIconButton("SendReagents", self, Textures.Deposit, "TOPRIGHT", REAGENTBANK_DEPOSIT, tBag)
		self.reagentBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 4, 0)
		self.reagentBtn:SetScript("OnClick", function()	DepositReagentBank() end)
	end

	-- Item drop target
	if (tBag or tBank or tReagent) then
		self.DropTarget = CreateFrame("ItemButton", self.name.."DropTarget", self)
		local dtNT = _G[self.DropTarget:GetName().."NormalTexture"]
		if dtNT then dtNT:SetTexture(nil) end
		
		self.DropTarget.bg = CreateFrame("Frame", nil, self.DropTarget)
		self.DropTarget.bg:SetAllPoints()	
		mnkLibs.setBackdrop(self.DropTarget.bg, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
		self.DropTarget.bg:SetBackdropColor(1, 1, 1, 0.1)
		self.DropTarget.bg:SetBackdropBorderColor(0, 0, 0, 1)

		self.DropTarget:SetWidth(itemSlotSize+1)
		self.DropTarget:SetHeight(itemSlotSize+1)
		
		local DropTargetProcessItem = function()
			local bID, sID = GetFirstFreeSlot((tBag and "bag") or (tBank and "bank") or "bankReagent")
			if bID then PickupContainerItem(bID, sID) end
		end
		self.DropTarget:SetScript("OnMouseUp", DropTargetProcessItem)
		self.DropTarget:SetScript("OnReceiveDrag", DropTargetProcessItem)

		self.EmptySlotCounter = mnkLibs.createFontString(self, mnkLibs.Fonts.ap, 16, nil, nil, true)
		self.EmptySlotCounter:SetPoint("BOTTOMRIGHT", self.DropTarget, "BOTTOMRIGHT", -3, 3)
		self.EmptySlotCounter:SetJustifyH("LEFT")
		
		self.DropTarget:Show()
		self.EmptySlotCounter:Show()
	end

	self:UpdateDimensions(self)
	return self
end

function MyContainer:ShowOrHide()
	local result = (#self.buttons > 0) or false

	-- alway show primary/reagent bags 
	-- add checks for bags with ammo or soul in the name?
	if ((self.name == 'mb_BankReagent') and cbmb:AtBank()) or ((self.name == 'mb_Bank') and cbmb:AtBank()) or (self.name == 'mb_Bag') then		
		result = true
	elseif (self.name == 'mb_BankReagent') and not cbmb:AtBank() then
		result = false
	end

	return result
end

function MyContainer:UpdateDimensions(self)
	local BagBarHeight = 0
	local CaptionHeight = 28
	local buttonCount = 0
	local rows = 1	

	if self.bagToggle then
		buttonCount = 1 -- dropbutton/emptybuttoncounter
		if self.pluginBagBar and self.pluginBagBar:IsShown() then 
			BagBarHeight = 60
		else 
			BagBarHeight = 16
		end
	else
		BagBarHeight = 0
	end

	buttonCount = buttonCount + #self.buttons

	if buttonCount > 0 then
		rows = mnkLibs.Round((#self.buttons/self.Columns),1)
		if (rows == 0) then rows = 1 end
		if ((rows * self.Columns) < buttonCount) then rows = (rows + 1) end
		--print(self:GetName(), ' ', self.columns, ' ', buttonCount, ' ', rows)
	end

	self:SetWidth((itemSlotSize + itemSlotPadding) * self.Columns )
	self:SetHeight(((itemSlotSize + itemSlotPadding) * rows) + (BagBarHeight + CaptionHeight) - 8)
end

function MyContainer:BAG_UPDATE_DELAYED()
	self:UnregisterEvent('BAG_UPDATE_DELAYED')
	SortReagentBankBags()
end

------------------------------------------
-- MyButton specific
------------------------------------------
local MyButton = cbmb:GetItemButtonClass()
MyButton:Scaffold("Default")

