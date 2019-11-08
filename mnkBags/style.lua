local addon, ns = ...
local cargBags = ns.cargBags

local _
local L = cBnivL

local mediaPath = [[Interface\AddOns\mnkBags\media\]]
local Textures = {
	Background =	mediaPath .. "texture",
	Search =		mediaPath .. "Search",
	BagToggle =		mediaPath .. "BagToggle",
	ResetNew =		mediaPath .. "ResetNew",
	Restack =		mediaPath .. "Restack",
	Config =		mediaPath .. "Config",
	SellJunk =		mediaPath .. "SellJunk",
	Deposit =		mediaPath .. "Deposit",
	TooltipIcon =	mediaPath .. "TooltipIcon",
	Up =			mediaPath .. "Up",
	Down =			mediaPath .. "Down",
	Left =			mediaPath .. "Left",
	Right =			mediaPath .. "Right",
}

local itemSlotSize = 32
------------------------------------------
-- MyContainer specific
------------------------------------------
local cbNivaya = cargBags:GetImplementation("Nivaya")
local MyContainer = cbNivaya:GetContainerClass()

local function GetClassColor(class)
	if not RAID_CLASS_COLORS[class] then return {1, 1, 1} end
	local classColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	return {classColors.r, classColors.g, classColors.b}
end

local GetNumFreeSlots = function(bagType)
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

local QuickSort;
do
	local func = function(v1, v2)
		if (v1 == nil) or (v2 == nil) then return (v1 and true or false) end
		if v1[1] == -1 or v2[1] == -1 then
			return v1[1] > v2[1] -- empty slots last
		elseif v1[2] ~= v2[2] then
			if v1[2] and v2[2] then
				return v1[2] > v2[2] -- higher quality first
			elseif (v1[2] == nil) or (v2[2] == nil) then
				return (v1[2] and true or false)
			else
				return false
			end
		elseif v1[1] ~= v2[1] then
			return v1[1] > v2[1] -- group identical item ids
		else
			return v1[4] > v2[4] -- full/larger stacks first
		end
	end;
	QuickSort = function(tbl) table.sort(tbl, func) end
end

local BagFrames, BankFrames =  {}, {}

function MyContainer:OnContentsChanged(forced)

	local col, row = 0, 0
	local yPosOffs = self.Caption and 20 or 0
	local isEmpty = true

	local tName = self.name
	local tBankBags = string.find(tName, "Bank")
	local tBank = tBankBags or (tName == "cBniv_Bank")
	local tReagent = (tName == "cBniv_BankReagent")
	
	local numSlotsBag = {GetNumFreeSlots("bag")}
	local numSlotsBank = {GetNumFreeSlots("bank")}
	local numSlotsReagent = {GetNumFreeSlots("bankReagent")}
	
	local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
	local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
	local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]
	
	local oldColums = self.Columns
	
	self.Columns = 12
	
	local needColumnUpdate = (self.Columns ~= oldColums)

	local buttonIDs = {}
  	for i, button in pairs(self.buttons) do
		local item = cbNivaya:GetItemInfo(button.bagID, button.slotID)
		if item.link then
			buttonIDs[i] = { item.id, item.rarity, button, item.count }
		else
			buttonIDs[i] = { -1, -2, button, -1 }
		end
	end
	
	QuickSort(buttonIDs) 

	for _,v in ipairs(buttonIDs) do
		local button = v[3]
		button:ClearAllPoints()
	  
		local xPos = col * (itemSlotSize + 4) + 2
		local yPos = (-1 * row * (itemSlotSize + 4)) - yPosOffs

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
	local xPos = col * (itemSlotSize + 4) + 2
	local yPos = (-1 * row * (itemSlotSize + 4)) - yPosOffs

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
	
	cB_Bags.main.EmptySlotCounter:SetText(GetNumFreeSlots("bag"))
	cB_Bags.bank.EmptySlotCounter:SetText(GetNumFreeSlots("bank"))
	cB_Bags.bankReagent.EmptySlotCounter:SetText(GetNumFreeSlots("bankReagent"))

	
	-- This variable stores the size of the item button container
	self.ContainerHeight = (row + (col > 0 and 1 or 0)) * (itemSlotSize + 2)

	if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
	self:SetWidth((itemSlotSize + 4) * self.Columns + 4)
	local t = (tName == "cBniv_Bag") or (tName == "cBniv_Bank") or (tName == "cBniv_BankReagent")
	local tAS = (tName == "cBniv_Ammo") or (tName == "cBniv_Soulshards")
	local bankShown = cB_Bags.bank:IsShown()
	if (not tBankBags and cB_Bags.main:IsShown() and not (t or tAS)) or (tBankBags and bankShown) then 
		if isEmpty then
			self:Hide()
			if bankShown then
				cB_Bags.bank:Show()
			end
		else
			self:Show()
		end 
	end

	cB_BagHidden[tName] = (not t) and isEmpty or false
	cbNivaya:UpdateAnchors(self)

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

-- Sell Junk
local JS = CreateFrame("Frame")
JS:RegisterEvent("MERCHANT_SHOW")
local function SellJunk()
	if not(cBnivCfg.SellJunk) or (UnitLevel("player") < 5) then return end
	
	local Profit, SoldCount = 0, 0
	local item

	for BagID = 0, 4 do
		for BagSlot = 1, GetContainerNumSlots(BagID) do
			item = cbNivaya:GetItemInfo(BagID, BagSlot)
			if item then
				if item.rarity == 0 and item.sellPrice ~= 0 then
					Profit = Profit + (item.sellPrice * item.count)
					SoldCount = SoldCount + 1
					UseContainerItem(BagID, BagSlot)
				end
			end
		end
	end
	
	if Profit > 0 then
		local g, s, c = math.floor(Profit / 10000) or 0, math.floor((Profit % 10000) / 100) or 0, Profit % 100
		print("Vendor trash sold: |cff00a956+|r |cffffffff"..g.."\124TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0\124t "..s.."\124TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0\124t "..c.."\124TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0\124t".."|r")
	end
end
JS:SetScript("OnEvent", function() SellJunk() end)

-- Restack Items
local restackItems = function(self)
	local tBag, tBank = (self.name == "cBniv_Bag"), (self.name == "cBniv_Bank")
	--local loc = tBank and "bank" or "bags"
	if tBank then
		SortBankBags()
		SortReagentBankBags()
	elseif tBag then
		SortBags()
	end
end

-- Reset New
local resetNewItems = function(self)
	cB_KnownItems = cB_KnownItems or {}
	if not cBniv.clean then
		for item, numItem in next, cB_KnownItems do
			if type(item) == "string" then
				cB_KnownItems[item] = nil
			end
		end
		cBniv.clean = true
	end
	for bag = 0, 4 do
		local tNumSlots = GetContainerNumSlots(bag)
		if tNumSlots > 0 then
			for slot = 1, tNumSlots do
				local item = cbNivaya:GetItemInfo(bag, slot)
				--print("resetNewItems", item.id)
				if item.id then
					if cB_KnownItems[item.id] then
						cB_KnownItems[item.id] = cB_KnownItems[item.id] + (item.stackCount and item.stackCount or 0)
					else
						cB_KnownItems[item.id] = item.stackCount and item.stackCount or 0
					end
				end
			end 
		end
	end
	cbNivaya:UpdateBags()
end
function cbNivResetNew()
	resetNewItems()
end

local UpdateDimensions = function(self)
	local height = 0			-- Normal margin space
	if self.BagBar and self.BagBar:IsShown() then
		height = height + 40	-- Bag button space
	end
	if self.Space then
		height = height + 16	-- additional info display space
	end
	if self.bagToggle then
		local tBag = (self.name == "cBniv_Bag")
		local fheight = (ns.options.fonts.standard[2] + 4)
		local extraHeight = (tBag and self.hintShown) and (fheight + 4) or 0
		height = height + 24 + extraHeight
	end
	if self.Caption then		-- Space for captions
		local fheight = (ns.options.fonts.standard[2] + 12)
		height = height + fheight
	end
	self:SetHeight(self.ContainerHeight + height)
end

local SetFrameMovable = function(f, v)
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

local classColor
local function IconButton_OnEnter(self)
	self.mouseover = true
	
	if not classColor then
		classColor = GetClassColor(select(2, UnitClass("player")))
	end
	self.icon:SetVertexColor(classColor[1], classColor[2], classColor[3])
	
	if self.tooltip then
		self.tooltip:Show()
		self.tooltipIcon:Show()
	end
end

local function IconButton_OnLeave(self)
	self.mouseover = false
	if self.tag == "SellJunk" then
		if cBnivCfg.SellJunk then
			self.icon:SetVertexColor(0.8, 0.8, 0.8)
		else
			self.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	else
		self.icon:SetVertexColor(0.8, 0.8, 0.8)
	end
	if self.tooltip then
		self.tooltip:Hide()
		self.tooltipIcon:Hide()
	end
end

local createIconButton = function (name, parent, texture, point, hint, isBag)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(17)
	button:SetHeight(17)
	
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetPoint(point, button, point, point == "BOTTOMLEFT" and 2 or -2, 2)
	button.icon:SetWidth(16)
	button.icon:SetHeight(16)
	button.icon:SetTexture(texture)
	if name == "SellJunk" then
		if cBnivCfg.SellJunk then
			button.icon:SetVertexColor(0.8, 0.8, 0.8)
		else
			button.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	else
		button.icon:SetVertexColor(0.8, 0.8, 0.8)
	end
	
	button.tooltip = button:CreateFontString()
	button.tooltip:SetFont(unpack(ns.options.fonts.standard))
	button.tooltip:SetJustifyH("RIGHT")
	button.tooltip:SetText(hint)
	button.tooltip:SetTextColor(0.8, 0.8, 0.8)
	button.tooltip:Hide()
	
	button.tooltipIcon = button:CreateTexture(nil, "ARTWORK")
	button.tooltipIcon:SetWidth(16)
	button.tooltipIcon:SetHeight(16)
	button.tooltipIcon:SetTexture(Textures.TooltipIcon)
	button.tooltipIcon:SetVertexColor(0.9, 0.2, 0.2)
	button.tooltipIcon:Hide()
	
	button.tag = name
	button:SetScript("OnEnter", function() IconButton_OnEnter(button) end)
	button:SetScript("OnLeave", function() IconButton_OnLeave(button) end)
	button.mouseover = false
	
	return button
end


local GetFirstFreeSlot = function(bagtype)
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

function MyContainer:OnCreate(name, settings)
	--print("MyContainer:OnCreate", name)
	settings = settings or {}
	self.Settings = settings
	self.name = name

	local tBag, tBank, tReagent = (name == "cBniv_Bag"), (name == "cBniv_Bank"), (name == "cBniv_BankReagent")
	local tBankBags = string.find(name, "Bank")

	table.insert((tBankBags and BankFrames or BagFrames), self)
	
	local numSlotsBag = {GetNumFreeSlots("bag")}
	local numSlotsBank = {GetNumFreeSlots("bank")}
	local numSlotsReagent = {GetNumFreeSlots("bankReagent")}
	
	local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
	local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
	local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]

	self:EnableMouse(true)
	
	self.UpdateDimensions = UpdateDimensions
	
	self:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

	if (tBag or tBank) then 
		SetFrameMovable(self, true) 
	end

	self.Columns = 12
	self.ContainerHeight = 0
	self:UpdateDimensions()
	self:SetWidth((itemSlotSize + 2) * self.Columns + 2)

	-- The frame background
	local color_rb = ns.options.colors.background[1]
	local color_gb = ns.options.colors.background[2]
	local color_bb = ns.options.colors.background[3]
	local alpha_fb = ns.options.colors.background[4]

	-- The frame background
	local background = CreateFrame("Frame", nil, self)
	background:SetBackdrop{
		bgFile = Textures.Background,
		edgeFile = Textures.Background,
		tile = true, tileSize = 16, edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}
	background:SetFrameStrata("HIGH")
	background:SetFrameLevel(1)
    background:SetBackdropColor(0, 0, 0, 1)
    background:SetBackdropBorderColor(0.2, 0.2, 0.2)
	background:SetPoint("TOPLEFT", -4, 4)
	background:SetPoint("BOTTOMRIGHT", 4, -4)

	-- Caption, close button
	local caption = background:CreateFontString(background, "OVERLAY", nil)
	caption:SetFont(unpack(ns.options.fonts.standard))
	if(caption) then
		local t = L.bagCaptions[self.name] or (tBankBags and strsub(self.name, 5))
		if not t then t = self.name end
		if self.Name == "cBniv_ItemSets" then t=ItemSetCaption..t end
		caption:SetText(t)
		caption:SetPoint("TOPLEFT", 3, -1)
		self.Caption = caption
		
		if (tBag or tBank) then
			if (tBank) then
				background:SetBackdropColor(1/5, 1/8, 1/8, 1)
			elseif (tBag) then
				background:SetBackdropColor(1/8, 1/5, 1/8, 1)
			end
			
			local close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
			close:SetDisabledTexture("Interface\\AddOns\\mnkBags\\media\\CloseButton\\UI-Panel-MinimizeButton-Disabled")
			close:SetNormalTexture("Interface\\AddOns\\mnkBags\\media\\CloseButton\\UI-Panel-MinimizeButton-Up")
			close:SetPushedTexture("Interface\\AddOns\\mnkBags\\media\\CloseButton\\UI-Panel-MinimizeButton-Down")
			close:SetHighlightTexture("Interface\\AddOns\\mnkBags\\media\\CloseButton\\UI-Panel-MinimizeButton-Highlight", "ADD")
			close:ClearAllPoints()
			close:SetPoint("TOPRIGHT", 8, 8)
			close:SetScript("OnClick", function(self) if cbNivaya:AtBank() then CloseBankFrame() else CloseAllBags() end end)
		end
	end
		
	--local tBtnOffs = 0
  	if (tBag or tBank) then
		-- Bag bar for changing bags
		local bagType = tBag and "bags" or "bank"
		
		local tS = tBag and "backpack+bags" or "bank"
		local tI = tBag and 4 or 7
				
		local bagButtons = self:SpawnPlugin("BagBar", tS)
		bagButtons:SetSize(bagButtons:LayoutButtons("grid", tI))
		bagButtons.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		bagButtons.isGlobal = true
		
		bagButtons:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, tBag and 40 or 25)
		bagButtons:Hide()

		-- main window gets a fake bag button for toggling key ring
		self.BagBar = bagButtons
		
		-- We don't need the bag bar every time, so let's create a toggle button for them to show
		self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", "Toggle Bags", tBag)
		self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.bagToggle:SetScript("OnClick", function()
			if(self.BagBar:IsShown()) then 
				self.BagBar:Hide()
			--	if self.hint then self.hint:Show() end
			--	self.hintShown = true
			else
				self.BagBar:Show()
			--	if self.hint then self.hint:Hide() end
			--	self.hintShown = false
			end
			self:UpdateDimensions()
		end)

		-- Button to reset new items:
		if tBag then
			self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "BOTTOMRIGHT", "Reset New", tBag)
			self.resetBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
			self.resetBtn:SetScript("OnClick", function() resetNewItems(self) end)
		end
		
		-- Button to restack items:
		self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack", tBag)
		if self.resetBtn then
			self.restackBtn:SetPoint("BOTTOMRIGHT", self.resetBtn, "BOTTOMLEFT", 0, 0)
		else
			self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
		end
		self.restackBtn:SetScript("OnClick", function() restackItems(self) end)
		
		-- Button to send reagents to Reagent Bank:
		if tBank then
			local rbHint = REAGENTBANK_DEPOSIT
			self.reagentBtn = createIconButton("SendReagents", self, Textures.Deposit, "BOTTOMRIGHT", rbHint, tBag)
			--if self.optionsBtn then
			--	self.reagentBtn:SetPoint("BOTTOMRIGHT", self.optionsBtn, "BOTTOMLEFT", 0, 0)
			if self.restackBtn then
				self.reagentBtn:SetPoint("BOTTOMRIGHT", self.restackBtn, "BOTTOMLEFT", 0, 0)
			else
				self.reagentBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
			end
			self.reagentBtn:SetScript("OnClick", function()
				--print("Deposit!!!")
				DepositReagentBank()
			end)
		end

		-- Tooltip positions
		local numButtons = 1
		local btnTable = {self.bagToggle}
		--if self.optionsBtn then numButtons = numButtons + 1; tinsert(btnTable, self.optionsBtn) end
		if self.restackBtn then numButtons = numButtons + 1; tinsert(btnTable, self.restackBtn) end
		if tBag then
			if self.resetBtn then numButtons = numButtons + 1; tinsert(btnTable, self.resetBtn) end
			if self.junkBtn then numButtons = numButtons + 1; tinsert(btnTable, self.junkBtn) end
		end
		if tBank then
			if self.reagentBtn then numButtons = numButtons + 1; tinsert(btnTable, self.reagentBtn) end
		end
		local ttPos = -(numButtons * 15 + 18)
		if tBank then ttPos = ttPos + 3 end
		for k,v in pairs(btnTable) do
			v.tooltip:ClearAllPoints()
			v.tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos, 5.5)
			v.tooltipIcon:ClearAllPoints()
			v.tooltipIcon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos + 5, 1.5)
		end
	end

	-- Item drop target
	if (tBag or tBank or tReagent) then
		self.DropTarget = CreateFrame("ItemButton", self.name.."DropTarget", self)
		local dtNT = _G[self.DropTarget:GetName().."NormalTexture"]
		if dtNT then dtNT:SetTexture(nil) end
		
		self.DropTarget.bg = CreateFrame("Frame", nil, self.DropTarget)
		self.DropTarget.bg:SetAllPoints()
		self.DropTarget.bg:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			tile = false, tileSize = 16, edgeSize = 1,
		})
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
		local infoFrame = CreateFrame("Button", nil, self)
		infoFrame:SetPoint("BOTTOMLEFT", 5, -6)
		infoFrame:SetPoint("BOTTOMRIGHT", -86, -6)
		infoFrame:SetHeight(32)

		-- Search bar
		local search = self:SpawnPlugin("SearchBar", infoFrame)
		search.isGlobal = true
		search.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		
		local searchIcon = background:CreateTexture(nil, "ARTWORK")
		searchIcon:SetTexture(Textures.Search)
		searchIcon:SetVertexColor(0.8, 0.8, 0.8)
		searchIcon:SetPoint("BOTTOMLEFT", infoFrame, "BOTTOMLEFT", -3, 8)
		searchIcon:SetWidth(16)
		searchIcon:SetHeight(16)
		
		-- Hint
		self.hint = background:CreateFontString(nil, "OVERLAY", nil)
		self.hint:SetPoint("BOTTOMLEFT", infoFrame, -0.5, 31.5)
		self.hint:SetFont(unpack(ns.options.fonts.standard))
		self.hint:SetTextColor(1, 1, 1, 0.4)
		self.hint:SetText("")
		self.hintShown = true
		
		-- The money display
		local money = self:SpawnPlugin("TagDisplay", "[money]", self)
		money:SetPoint("TOPRIGHT", self, -30, 0)
		money = mnkLibs.createFontString(self, mnkLibs.Fonts.ap, 12, nil, nil, true)
	end
	return self
end

------------------------------------------
-- MyButton specific
------------------------------------------
local MyButton = cbNivaya:GetItemButtonClass()
MyButton:Scaffold("Default")

