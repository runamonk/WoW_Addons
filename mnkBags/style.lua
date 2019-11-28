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
  				local clink = GetContainerItemLink(bag, slot)
  				if clink then
					local itemID = select(1, GetItemInfoInstant(clink))
					local itemCount = GetItemCount(clink)
					if mnkBagsKnownItems[itemID] then
						mnkBagsKnownItems[itemID] = mnkBagsKnownItems[itemID] + itemCount
					else
						mnkBagsKnownItems[itemID] = itemCount
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
		SortBankBags()
		SortReagentBankBags()
	elseif tBag then
		SortBags()
	end
end

local function SetFrameMovable(f, v)
	f:SetMovable(true)
	f:SetUserPlaced(true)
	f:RegisterForClicks("LeftButton", "RightButton")
	if v then 
		f:SetScript("OnMouseDown", function() 
			f:ClearAllPoints() 
			f:StartMoving() 
		end)
		f:SetScript("OnMouseUp",  f.StopMovingOrSizing)
	else
		f:SetScript("OnMouseDown", nil)
		f:SetScript("OnMouseUp", nil)
	end
end

function MyContainer:OnContentsChanged(forced)

	local col, row = 0, 0
	local yPosOffs = 20
	local isEmpty = true

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
  		--local item = cbmb:GetItemInfo(button.bagID, button.slotID)
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
		isEmpty = false
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

	local t = (tName == "mb_Bag") or (tName == "mb_Bank") or (tName == "mb_BankReagent")
	local tAS = (tName == "mb_Ammo") or (tName == "mb_Soulshards")
	local bankShown = _Bags.bank:IsShown()
	if (not tBankBags and _Bags.main:IsShown() and not (t or tAS)) or (tBankBags and bankShown) then 
		if isEmpty then
			self:Hide()
			if bankShown then
				_Bags.bank:Show()
			end
		else
			self:Show()
		end 
	end

	_BagsHidden[tName] = (not t) and isEmpty or false
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

	local tBag, tBank, tReagent = (name == "mb_Bag"), (name == "mb_Bank"), (name == "mb_BankReagent")
	local tBankBags = string.find(name, "Bank")

	table.insert((tBankBags and BankFrames or BagFrames), self)
	
	local numSlotsBag = {GetNumFreeSlots("bag")}
	local numSlotsBank = {GetNumFreeSlots("bank")}
	local numSlotsReagent = {GetNumFreeSlots("bankReagent")}
	local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
	local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
	local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]

	self:EnableMouse(true)
	self:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

	if (tBag or tBank) then 
		SetFrameMovable(self, true) 
	end

	self.Columns = 12
	self:UpdateDimensions(self)
	
	-- The frame background
	local background = CreateFrame("Frame", nil, self)
	mnkLibs.setBackdrop(background, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
	mnkLibs.createBorder(self, 5,-5,-5,5, {1/3,1/3,1/3,1})
	background:SetFrameStrata("HIGH")
	background:SetFrameLevel(1)

	if (tBank) then
		background:SetBackdropColor(1/5, 1/8, 1/8, 1)
	elseif (tBag) then
		background:SetBackdropColor(1/8, 1/5, 1/8, 1)
	else
		background:SetBackdropColor(0, 0, 0, 1)
	end
	
	background:SetPoint("TOPLEFT", -4, 4)
	background:SetPoint("BOTTOMRIGHT", 4, -4)

	-- Caption, close button
	local caption = mnkLibs.createFontString(background, mnkLibs.Fonts.ap, 16, nil, nil, true)
	
	if (caption) then
		local t = mbLocals.bagCaptions[self.name] or (tBankBags and strsub(self.name, 5))
		if not t then t = self.name end
		if self.Name == "mb_ItemSets" then t=ItemSetCaption..t end
		caption:SetText(t)
		caption:SetPoint("TOPLEFT", 3, -1)
		self.Caption = caption
		
		if (tBag or tBank) then
			local close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
			close:SetDisabledTexture("Interface\\AddOns\\mnkBags\\media\\Close")
			close:SetNormalTexture("Interface\\AddOns\\mnkBags\\media\\Close")
			close:SetPushedTexture("Interface\\AddOns\\mnkBags\\media\\Close")
			close:SetHighlightTexture("Interface\\AddOns\\mnkBags\\media\\Close")		
			close:ClearAllPoints()
			close:SetPoint("TOPRIGHT", 2, 2)
			close:SetSize(12,12)
			close:SetScript("OnClick", function(self) if cbmb:AtBank() then CloseBankFrame() else CloseAllBags() end end)
		end
	end

	if self.name == 'mb_NewItems' then
		self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "TOPRIGHT", "Reset New", tBag)
		self.resetBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.resetBtn:SetScript("OnClick", function() resetNewItems(self) end)
	end
	

  	if (tBag or tBank) then
		local bagButtons = self:SpawnPlugin("BagBar", tBag and "backpack+bags" or "bank")

		if tBag then
			bagButtons:SetSize(bagButtons:LayoutButtons("grid", 4))
		else
			bagButtons:SetSize(bagButtons:LayoutButtons("grid", 7))
		end
		
		bagButtons.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		bagButtons.isGlobal = true
		bagButtons:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 25)
		bagButtons:Hide()

		self.BagBar = bagButtons
		self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", "Toggle Bags", tBag)
		self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.bagToggle:SetScript("OnClick", function()
			if(self.BagBar:IsShown()) then 
				self.BagBar:Hide()
			else
				self.BagBar:Show()
			end
			self:UpdateDimensions(self)
		end)
		
		-- Button to restack items:
		self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack", tBag)
		self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
		self.restackBtn:SetScript("OnClick", function() restackItems(self) end)
		
		-- Button to send reagents to Reagent Bank:
		if tBank then
			local rbHint = REAGENTBANK_DEPOSIT
			self.reagentBtn = createIconButton("SendReagents", self, Textures.Deposit, "BOTTOMRIGHT", rbHint, tBag)
			if self.restackBtn then
				self.reagentBtn:SetPoint("BOTTOMRIGHT", self.restackBtn, "BOTTOMLEFT", 0, 0)
			else
				self.reagentBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
			end
			self.reagentBtn:SetScript("OnClick", function()	DepositReagentBank() end)
		end
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
	
	if tBag then
		local SearchBox = CreateFrame("Button", nil, self)
		SearchBox:SetPoint("BOTTOMLEFT", 5, -6)
		SearchBox:SetPoint("BOTTOMRIGHT", -86, -6)
		SearchBox:SetHeight(16)

		-- Search bar
		local search = self:SpawnPlugin("SearchBar", SearchBox)
		search.isGlobal = true
		search.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		
		local SearchIcon = background:CreateTexture(nil, "ARTWORK")
		SearchIcon:SetTexture(Textures.Search)
		SearchIcon:SetVertexColor(0.8, 0.8, 0.8)
		SearchIcon:SetPoint("BOTTOMLEFT", SearchBox, "BOTTOMLEFT", -3, 8)
		SearchIcon:SetWidth(16)
		SearchIcon:SetHeight(16)
	end
	return self
end

 function MyContainer:UpdateDimensions(self)
	local BagBarHeight = 0
	local CaptionHeight = 28
	local buttonCount = 0
	local rows = 1	

	if self.bagToggle then
		buttonCount = 1
		if self.BagBar and self.BagBar:IsShown() then 
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

------------------------------------------
-- MyButton specific
------------------------------------------
local MyButton = cbmb:GetItemButtonClass()
MyButton:Scaffold("Default")

