local addon, ns = ...
local cargBags = ns.cargBags
local cbmb = cargBags:NewImplementation("mnkBags")
local mbContainer = cbmb:GetContainerClass()
local mbButton = cbmb:GetItemButtonClass()
local mbBags = {}
local bagMain, bagBank, bagReagent, bagJunk, bagNew = nil

local _, playerClass = UnitClass('player')
local classColor = {}
classColor.r, classColor.g, classColor.b, _ = GetClassColor(playerClass)

local mnkBags = CreateFrame('Frame', 'mnkBags', UIParent, BackdropTemplateMixin and "BackdropTemplate")

local _
local skipOnButtonRemove = false
local itemSlotSize = 24
local JunkItemsSold = 0
local NewItemsSold = 0

local mediaPath = [[Interface\AddOns\mnkBags\media\]]
local Textures = {
	Search =		mediaPath .. "Search",
	BagToggle =		mediaPath .. "BagToggle",
	ResetNew =		mediaPath .. "ResetNew",
	Restack =		mediaPath .. "Restack",
	Deposit =		mediaPath .. "Deposit"}

mnkBags:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBags:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkBags:RegisterEvent('MERCHANT_SHOW')
mnkBagsKnownItems = {}

local function createIconButton(name, parent, texture, point, hint)
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
 
local function SellItemsInContainer(container)
	--print(container:GetName(), ' ', #container.buttons)
	local p = 0
	for k,_ in pairs(container.buttons) do
		-- just in case they close the form while selling.
		if (MerchantFrame:IsShown()) then 
			local b = container.buttons[k]
			local clink = GetContainerItemLink(b.bagID, b.slotID)
			if clink then
				-- doing it this way so it's less of a hit, parsing for boe causes lots of overhead.
				local _, _, rarity, _, _, _, _, _, _, _, sellPrice, _, _, _, _, _, _ = GetItemInfo(clink)
				local stackCount = GetItemCount(clink)
				if sellPrice ~= 0 then
					p = p + (sellPrice * stackCount)
					UseContainerItem(b.bagID, b.slotID)
				end
			end
		end
	end
	return p
end

local function SellJunk()
	if (not MerchantFrame:IsShown()) or (#bagJunk.buttons == 0) then return end
	local p = 0
	p = SellItemsInContainer(bagJunk)
	JunkItemsSold = JunkItemsSold + p
	C_Timer.After(0.5, SellJunk) 
end

local function SellNewItems()
	if (not MerchantFrame:IsShown()) or (#bagNew.buttons == 0) then return end
	local p = 0
	p = SellItemsInContainer(bagNew)
	NewItemsSold = NewItemsSold + p
	C_Timer.After(0.5, SellNewItems) 		
end

StaticPopupDialogs["ConfirmSellNewItems"] = {
  text = "Are you sure?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
  	NewItemsSold = 0
    SellNewItems()
	if NewItemsSold > 0 then
		print('New items sold for: ', GetCoinTextureString(NewItemsSold))
		NewItemsSold = 0
	end	      
  end,
  timeout = 0,
  whileDead = false,
  hideOnEscape = true,
  preferredIndex = 3,  
}

function mnkBags:MERCHANT_SHOW(event, addon)
	JunkItemsSold = 0
	SellJunk()
	if JunkItemsSold > 0 then
		print('Junk sold for: ', GetCoinTextureString(JunkItemsSold))
		JunkItemsSold = 0
	end	
end

function mnkBags:PLAYER_ENTERING_WORLD(event, addon)
	if cbmb.notInited then
		cbmb:RegisterBlizzard()
		cbmb:Init()
	end
end

function cbmb:OnOpen()
	for k,_ in pairs(mbBags) do
		if mbBags[k]:ShowOrHide() then
			mbBags[k]:Show()
		end
	end
end

function cbmb:OnClose()
	for k,_ in pairs(mbBags) do
		mbBags[k]:Hide()
	end
end

function cbmb:OnBankOpened()
	cbmb:OnOpen()
end

function cbmb:OnBankClosed()
	cbmb:OnClose()
end

function cbmb:OnInit()
	local function IsBank(item)
		return (item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11)
	end

	local function IsMain(item)
		return (item.bagID >= 0 and item.bagID <= 4) 
	end

	local function ItemNotNull(item)
		return (item ~= nil) and (item.link ~= nil)
	end
	
	local function createBag(bagParent, bagClass)
		local newBagObj = nil
		local bagCaption = bagClass

		if bagCaption == "_bag" then
			bagCaption = "Bags"
		elseif bagCaption == "_bank" then
			bagCaption = "Bank"
		end

		if bagParent and bagClass then 
			newBagObj = mbContainer:New(bagParent..bagClass, bagCaption)
		else
			newBagObj = mbContainer:New(bagClass, bagCaption)
		end

		newBagObj.bagClass = bagClass
		newBagObj.bagParent = bagParent

		if newBagObj.bagClass == "New" then
			newBagObj:SetFilter(function(item)
									return ItemNotNull(item) and (item.rarity > 0) and IsMain(item) and (mnkLibs.GetIndexInTable(mnkBagsKnownItems, item.id) == 0)
				                end, true)	
		elseif newBagObj.bagClass == "Junk" then
			newBagObj:SetFilter(function(item)
									return ItemNotNull(item) and IsMain(item) and (item.rarity == 0)
				                end, true)				
		elseif newBagObj.bagClass == "Reagents" then
			newBagObj:SetFilter(function(item)
									return ItemNotNull(item) and (item.bagID == -3) and (cbmb:AtBank())
				                end, true)			
		else
			newBagObj:SetFilter(function(item)
									    return ItemNotNull(item) and ((item.type == newBagObj.bagClass) and ((newBagObj.bagParent == "_bag" and IsMain(item) and (item.rarity > 0) and mnkLibs.GetIndexInTable(mnkBagsKnownItems, item.id) > 0) or 
									    	                          (newBagObj.bagParent == "_bank" and IsBank(item))))
				                end, true)
		end
		table.insert(mbBags, newBagObj)
		return newBagObj
	end

	for i = 0, NUM_LE_ITEM_CLASSS-1 do
		createBag("_bag", GetItemClassInfo(i))
		createBag("_bank", GetItemClassInfo(i))
	end	
	
	bagJunk = createBag("_bag","Junk")
	bagNew = createBag("_bag", "New")

	local sort_func = function(a, b) return a.name > b.name end
    table.sort(mbBags, sort_func)

	bagReagent = createBag("_bank","Reagents")
	bagBank =  createBag(nil,"_bank")
	bagMain = createBag(nil,"_bag")

	bagMain:SetPoint('BOTTOMRIGHT', -20, 220)
	bagBank:SetPoint('BOTTOMLEFT', 20, 220)

	for k,_ in pairs(mbBags) do
		mbBags[k]:OnContentsChanged(true)
	end
	--print(#mnkBagsKnownItems)
	cbmb:UpdateAnchors()
end

function cbmb:UpdateAllBags()
	for k,_ in pairs(mbBags) do
		mbBags[k]:OnContentsChanged(true)
	end
	cbmb:UpdateAnchors()
end

function cbmb:UpdateAnchors()
	local function SetBagAnchor(bag, lastbag, parentbag)

		local h = GetScreenHeight()
		local i = bag:GetHeight()
		local t = lastbag:GetTop()
		-- Check if the bag will end up off the top of the screen, if so then start a new column of containers.
		if t and (t + i + 25) > h then

			if parentbag == bagMain then
				if parentbag.mywifeisahorder then
					bag:SetPoint("BOTTOMRIGHT", parentbag.mywifeisahorder, "BOTTOMLEFT", -1, 0)
				else
					bag:SetPoint("BOTTOMRIGHT", parentbag, "BOTTOMLEFT", -1, 0)	
				end
				parentbag.mywifeisahorder = bag
			else
				if parentbag.mywifeisahorder then
					bag:SetPoint("BOTTOMLEFT", parentbag.mywifeisahorder, "BOTTOMRIGHT", 1, 0)
				else
					bag:SetPoint("BOTTOMLEFT", parentbag, "BOTTOMRIGHT", 1, 0)	
				end
				parentbag.mywifeisahorder = bag				
			end
			return
		end
		
		if lastbag:ShowOrHide() or (lastbag == bagBank or lastbag == bagMain) then
			bag:SetPoint("BOTTOMLEFT", lastbag, "TOPLEFT", 0, 1)
		else
			bag:SetPoint("BOTTOMLEFT", lastbag, "BOTTOMLEFT", 0, 0)
		end
	end
	--print('UpdateAnchors()')
	local lastBank, lastMain = bagBank, bagMain

	bagMain.mywifeisahorder = nil
	bagBank.mywifeisahorder = nil

	for _, obj in pairs(mbBags) do
		if ((obj.name ~= bagMain.name) and (obj.name ~= bagBank.name)) then

			obj:ClearAllPoints()
			--print('namecheck: ', obj.name, ' ', obj.bagParent)					
			if (obj.bagParent == bagBank.name) then
				SetBagAnchor(obj, lastBank, bagBank)
				lastBank = obj
			else
				--print("Anchor: ", obj.name, ' ', obj.bagParent, ' ', bagMain.name)	
				SetBagAnchor(obj, lastMain, bagMain)
				lastMain = obj
			end
		end
	end
end

function cbmb:UpdateBags()
	for i = -3, 11 do 
		cbmb:UpdateBag(i) 
	end 
end

function mbButton:OnClick(self)
	-- mark an item as known and UpdateBags.
	if IsAltKeyDown() and (self.container == bagNew) then
		--print(self.clink, ' ', self.container:GetName())
		skipOnButtonRemove = true
		local itemid = select(1, GetItemInfoInstant(self.clink))
		if mnkLibs.GetIndexInTable(mnkBagsKnownItems, itemid) == 0 then			
			mnkBagsKnownItems[#mnkBagsKnownItems+1] = itemid
			cbmb:UpdateBags()
		end
		skipOnButtonRemove = false
		ClearCursor()
	end
end

function mbButton:OnCreate(tpl, parent, button)
	button:SetSize(itemSlotSize, itemSlotSize)
	if not button.border then
		mnkLibs.createBorder(button, 1,-1,-1,1, {.2,.2,.2, 1})
	end
end

function mbContainer:GetFirstFreeSlot(self)
	if self == bagBank then		
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
	elseif self == bagReagent then
		local bagID = -3
		local t = GetContainerNumFreeSlots(bagID)
		if t > 0 then
			local tNumSlots = GetContainerNumSlots(bagID)
			for j = 1,tNumSlots do
				local tLink = GetContainerItemLink(bagID,j)
				if not tLink then return bagID,j end
			end
		end
	elseif self == bagMain then
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
	end
	return false
end

function mbContainer:GetNumFreeSlots(self)
	local free, max = 0, 0
	if self == bagMain then
		for i = 0,4 do
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	elseif self == bagReagent then
		free = GetContainerNumFreeSlots(-3)
		max = GetContainerNumSlots(-3)
	elseif self == bagBank then
		local containerIDs = {-1,5,6,7,8,9,10,11}
		for _,i in next, containerIDs do	
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	end
	return free, max
end

function mbContainer:DepositReagentBank()
	DepositReagentBank()
end

function mbContainer:OnButtonRemove(button)
	if skipOnButtonRemove then return end 
	-- remove item from known items
	if button.clink then
		--print("OnButtonRemove:"..button.clink)
		local itemid = select(1, GetItemInfoInstant(button.clink))
		local i = mnkLibs.GetIndexInTable(mnkBagsKnownItems, itemid)
		if (i > 0) and (GetItemCount(itemid) <= 1) then			
			table.remove(mnkBagsKnownItems, i)
		end		
	end
end

function mbContainer:OnContentsChanged(skipUpdateAnchors)
	if cbmb.SkipOnChange then return end
	local buttons = {}

  	for i, button in pairs(self.buttons) do
  		local clink = GetContainerItemLink(button.bagID, button.slotID)

  		if clink then
  			--local name = select(1, GetItemInfo(clink))
  			local item = cbmb:GetItemInfo(button.bagID, button.slotID)
  			buttons[i] = {item.name, item.count, button}
  		else
  			buttons[i] = {nil, 0, button}
  		end
	end
	
	-- sort by name and count
	local function sort(v1, v2)
		if (v1[1] == nil) and (v2[1] == nil) then return false end
		if (v1[1] == nil) or (v2[1] == nil) then return (v1[1] and true or false) end

 		return (v1[1] < v2[1]) or ((v1[1] == v2[1]) and (v1[2] > v2[2]))
	end
	table.sort(buttons, sort)
	local col, row = 0, 0

	local CaptionHeight = 20
	local lb, rb = nil, nil

	for _,v in ipairs(buttons) do
		local button = v[3]
		button:ClearAllPoints()
	  	
	  	-- first row
	  	if not lb and not rb then
	  		button:SetPoint("TOPLEFT", self, "TOPLEFT", 4, CaptionHeight * -1)
	  		rb = button
	  		col = col + 1
	  	else
	  		-- new row
	  		if rb and not lb then
	  			button:SetPoint("TOPLEFT", rb, "BOTTOMLEFT", 0, -1)
	  			rb = button
	  			col = col + 1
	  		else
	  			-- add to current row
				button:SetPoint("TOPLEFT", lb, "TOPRIGHT", 1, 0)
				col = col + 1
			end
		end

		if col == self.Columns then
			lb = nil
			col = 0
		else	
			lb = button
		end
	end

	self:UpdateDimensions(self)

	if self:ShowOrHide() then
		self:Show()
	else
		self:Hide()
	end

	mbContainer:UpdateFreeSlots()

	if not skipUpdateAnchors then
		cbmb:UpdateAnchors()
	end
end

function mbContainer:OnCreate(name)
	if not name then return end
	self.name = name
	--[[  
	 This works better than inserting the the frame in the UISpecialFrames table.
	 if you go to the bank and have both the bank and your bank open, then press 
	 esc the bank won't come back up until you've toggled again. 
	 ]]
	self:EnableKeyboard(1)
	self:SetScript("OnKeyDown",function(self,key)
		if key == 'ESCAPE' then
			self:SetPropagateKeyboardInput(false)
			ToggleAllBags()
		else
			self:SetPropagateKeyboardInput(true)
		end
	end)

	self.Columns = 12
	self:EnableMouse(true)
	self:SetFrameStrata("MEDIUM")
	self.Caption = mnkLibs.createFontString(self, mnkLibs.Fonts.ap, 14, nil, nil, true)
	self.Caption:SetText(self.bagCaption)
	self.Caption:SetPoint("TOPLEFT", 2, 0)
	self.Caption:SetTextColor(.6,.6,.6, 1)
	self:SetScript('OnShow', function (self) self:OnShow() end)
	mnkLibs.createTexture(self, 'BACKGROUND', {.1, .1, .1, 1})
	mnkLibs.createBorder(self, 1,-1,-1,1, {.5,.5,.5, 1})

	local isMain = (name == "_bag") 
	local isBank = (name == "_bank")
	local isReagent = (name == "_bankReagents")

	if (isMain or isBank) then 
		self:SetMovable(true)
		self:SetUserPlaced(true)
		self:RegisterForClicks("LeftButton", "RightButton")
		self:SetScript("OnMouseDown", function() 
			self:ClearAllPoints() 
			self:StartMoving() 
		end)
		self:SetScript("OnMouseUp",  self.StopMovingOrSizing)
		self.bgt:SetColorTexture(.2,.2,.2,1)
		
		self.CloseButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.CloseButton.Caption = mnkLibs.createFontString(self.CloseButton, mnkLibs.Fonts.ap, 18, nil, nil, true)
		self.CloseButton.Caption:SetText("x")
		self.CloseButton.Caption:SetPoint("CENTER")
		self.CloseButton.Caption:SetTextColor(.5,.5,.5, 1)
		self.CloseButton:SetDisabledTexture("")
		self.CloseButton:SetNormalTexture("")
		self.CloseButton:SetPushedTexture("")
		self.CloseButton:SetHighlightTexture("")	
		self.CloseButton:ClearAllPoints()
		self.CloseButton:SetPoint("TOPRIGHT", -1, 0)
		self.CloseButton:SetSize(12,12)
		mnkLibs.setTooltip(self.CloseButton, 'Close')
		self.CloseButton:SetScript("OnClick", function(self) if cbmb:AtBank() then CloseBankFrame() else CloseAllBags() end end)

		if isMain then
			self.pluginBagBar = self:SpawnPlugin("BagBar", {1, 2, 3, 4}, itemSlotSize)
			self.SearchButton = CreateFrame("Button", nil, self)
			self.SearchButton:SetWidth(75) 
			self.SearchButton:SetHeight(18)
			self.SearchButton:SetPoint("TOPLEFT", self, "TOPLEFT", 30, -1)
			self.pluginSearch = self:SpawnPlugin("SearchBar", self.SearchButton)
			self.pluginSearch.isGlobal = true
			self.pluginSearch.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
			self.SearchIcon = self:CreateTexture(nil, "ARTWORK") 
			self.SearchIcon:SetTexture(Textures.Search)
			self.SearchIcon:SetVertexColor(0.8, 0.8, 0.8)
			self.SearchIcon:SetPoint("TOPLEFT", self.SearchButton, "TOPLEFT", 0, 0)
			self.SearchIcon:SetWidth(16)
			self.SearchIcon:SetHeight(16)
		else
			self.pluginBagBar = self:SpawnPlugin("BagBar", {5, 6, 7, 8, 9, 10, 11}, itemSlotSize)
		end
		
		self.pluginBagBar.isGlobal = true
		self.pluginBagBar.AllowFilter = false
		self.pluginBagBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 16)
		self.pluginBagBar:Hide()

		self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", "Toggle Bags")
		self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.bagToggle:SetScript("OnClick", function()
			if(self.pluginBagBar:IsShown()) then 
				self.pluginBagBar:Hide()
			else
				self.pluginBagBar:Show()
			end
			self:UpdateDimensions(self)
		end)
		self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack")
		self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
		self.restackBtn:SetScript("OnClick", function() mbContainer:RestackItems(self) end)		
	end

	if self.name == '_bagNew' then
		self.resetBtn = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.resetBtn:SetSize(12,12)
		self.resetBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -2)
		self.resetBtn:SetScript("OnClick", function() self:ResetNewItems() end)
		mnkLibs.setTooltip(self.resetBtn, 'Mark new items as known.')
		self.resetBtn.Caption = mnkLibs.createFontString(self.resetBtn, mnkLibs.Fonts.ap, 16, nil, nil, true)
		self.resetBtn.Caption:SetText("R")
		self.resetBtn.Caption:SetPoint("CENTER")
		self.resetBtn.Caption:SetTextColor(.5,.5,.5, 1)
		self.resetBtn:SetDisabledTexture("")
		self.resetBtn:SetNormalTexture("")
		self.resetBtn:SetPushedTexture("")
		self.resetBtn:SetHighlightTexture("")
		self.buttonSellItems = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.buttonSellItems.Caption = mnkLibs.createFontString(self.buttonSellItems, mnkLibs.Fonts.ap, 14, nil, nil, true)
		self.buttonSellItems.Caption:SetText("$")
		self.buttonSellItems.Caption:SetPoint("CENTER")
		self.buttonSellItems.Caption:SetTextColor(.5,.5,.5, 1)
		self.buttonSellItems:SetDisabledTexture("")
		self.buttonSellItems:SetNormalTexture("")
		self.buttonSellItems:SetPushedTexture("")
		self.buttonSellItems:SetHighlightTexture("")	
		self.buttonSellItems:ClearAllPoints()
		self.buttonSellItems:SetPoint("TOPRIGHT", self.resetBtn, "TOPLEFT", -2, 0)
		self.buttonSellItems:SetSize(12,12)
		mnkLibs.setTooltip(self.buttonSellItems, 'Sell all items.')
		mnkLibs.setTooltip(self, 'Press alt + left click to mark an item as known.')
		self.buttonSellItems:SetScript("OnClick", 
			function ()
			 	if (not MerchantFrame:IsShown()) then return end
				StaticPopup_Show("ConfirmSellNewItems")
			end)
	end
	
	if isReagent then
		self.reagentBtn = createIconButton("SendReagents", self, Textures.Deposit, "TOPRIGHT", REAGENTBANK_DEPOSIT)
		self.reagentBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, -2)
		self.reagentBtn:SetScript("OnClick", function()	 mbContainer:DepositReagentBank() end)

		self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack")
		self.restackBtn:SetPoint("TOPRIGHT", self.reagentBtn, "TOPLEFT", 0, 1)
		self.restackBtn:SetScript("OnClick", function() mbContainer:RestackItems(self) end)
	end

	if (isMain or isBank or isReagent) then
		self.Drop = CreateFrame("ItemButton", self.name.."Drop", self, BackdropTemplateMixin and "BackdropTemplate")
		self.Drop.NormalTexture = _G[self.Drop:GetName().."NormalTexture"]
		self.Drop.NormalTexture:SetTexture(nil)
		self.Drop:SetSize(itemSlotSize+1,itemSlotSize+1)

		if isMain then
			self.Drop:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 3, 2)
		elseif isBank then
			self.Drop:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 3, 2)
		elseif isReagent then
			self.Drop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 3)
		end

		self.Empty = mnkLibs.createFontString(self.Drop, mnkLibs.Fonts.ap, 16, nil, nil, true)
		self.Empty:SetAllPoints()
		self.Empty:SetJustifyH("CENTER")
		mnkLibs.setBackdrop(self.Drop, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
		self.Drop:SetBackdropColor(.3,.3,.3,1)
		self.Drop:Show()
		self.Empty:Show()

		local GetFirstFreeSlot = function()
			if self.Empty:GetText() == '0' or nil then
				mnkLibs.PrintError('Bag is full')
			else
				PickupContainerItem(mbContainer:GetFirstFreeSlot(self))
			end
		end
		self.Drop:SetScript("OnMouseUp", GetFirstFreeSlot)
		self.Drop:SetScript("OnReceiveDrag", GetFirstFreeSlot)
	end
	
	if self.name == '_bagJunk' then
		self.buttonDeleteJunk = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.buttonDeleteJunk:SetDisabledTexture("")
		self.buttonDeleteJunk:SetNormalTexture("")
		self.buttonDeleteJunk:SetPushedTexture("")
		self.buttonDeleteJunk:SetHighlightTexture("")		
		self.buttonDeleteJunk:ClearAllPoints()
		self.buttonDeleteJunk:SetPoint("TOPRIGHT", 0, -2)
		self.buttonDeleteJunk:SetSize(12,12)

		self.buttonDeleteJunk.Caption = mnkLibs.createFontString(self.buttonDeleteJunk, mnkLibs.Fonts.ap, 16, nil, nil, true)
		self.buttonDeleteJunk.Caption:SetText("D")
		self.buttonDeleteJunk.Caption:SetPoint("CENTER")
		self.buttonDeleteJunk.Caption:SetTextColor(.5,.5,.5, 1)

		mnkLibs.setTooltip(self.buttonDeleteJunk, 'Destroy all junk with a sell price of less than 1g. ALT + Click to destory all junk.')
		self.buttonDeleteJunk:SetScript("OnClick", 
			function(self, button)
				local deleteAll = false
				if button == 'LeftButton' and IsAltKeyDown() then
					deleteAll = true
				end

				for k,_ in pairs(bagJunk.buttons) do
					local b = bagJunk.buttons[k]
					local clink = GetContainerItemLink(b.bagID, b.slotID)
					local sellPrice = select(11, GetItemInfo(clink))
					--print(clink, ' ', deleteAll, ' ', sellPrice)
					if deleteAll or (sellPrice and (sellPrice < 10000)) then
						PickupContainerItem(b.bagID,b.slotID) 
						DeleteCursorItem()
					end
				end
				cbmb:UpdateBags()
			end)
	end

	self:UpdateDimensions(self)
	return self
end

function mbContainer:OnShow()
	-- fill the Reagent bag.
	if self == bagReagent then
		-- Fill the bag but don't do the OnChange events until the very end. This is less intensive.
		cbmb.SkipOnChange = true
		cbmb:UpdateBag(-3)
		cbmb.SkipOnChange = false
		bagReagent:OnContentsChanged()

		if IsReagentBankUnlocked() then
			self.reagentBtn:Show()
		else
			self.reagentBtn:Hide()
			local buyReagent = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
			buyReagent:SetText(BANKSLOTPURCHASE)
			buyReagent:SetWidth(buyReagent:GetTextWidth() + 20)
			buyReagent:SetPoint("CENTER", self, 0, 0)
			mnkLibs.setTooltip(buyReagent, REAGENT_BANK_HELP)
			buyReagent:SetScript("OnClick", function() StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB") end)
			buyReagent:SetScript("OnEvent", function(...) buyReagent:UnregisterEvent("REAGENTBANK_PURCHASED") self.reagentBtn:Show() buyReagent:Hide() end)
			buyReagent:RegisterEvent("REAGENTBANK_PURCHASED")
		end
	end
end

function mbContainer:ResetNewItems()
	skipOnButtonRemove = true
	for k,_ in pairs(bagNew.buttons) do
		local b = bagNew.buttons[k]
		local clink = GetContainerItemLink(b.bagID, b.slotID)
		local itemid = select(1, GetItemInfoInstant(clink))
		-- some items ie battle pets cannot be looked up with GetItemInfo etc. So parse out the id.
		if itemid == nil then
			itemid = select(10, GetContainerItemInfo(b.bagID, b.slotID))
		end

		if mnkLibs.GetIndexInTable(mnkBagsKnownItems, itemid) == 0 then			
			mnkBagsKnownItems[#mnkBagsKnownItems+1] = itemid
		end
	end

	cbmb:UpdateBags()
	skipOnButtonRemove = false
end

function mbContainer:RestackItems(self)
	if self == bagReagent then
		SortReagentBankBags()
	elseif self == bagBank then
		SortBankBags()
	elseif self == bagMain then
		SortBags()
	end
end

function mbContainer:ShowOrHide()
	local result = false
	local hasItems = (#self.buttons > 0) or false
	local isBankBag = (self.bagParent == bagBank.name)
	local isParentBankBag = ((self.bagParent == nil) and (self.name == "_bank"))
	local isParentMainBag = ((self.bagParent == nil) and (self.name == "_bag"))

	if (isParentMainBag or hasItems) then
		result = true 
	elseif (isBankBag or isParentBankBag) and cbmb:AtBank() then
		if isParentBankBag or (self == bagReagent) or hasItems then
			result = true
		end
	elseif (isBankBag == true) and (not cbmb:AtBank()) then     
		result = false
	end

	return result
end

function mbContainer:UpdateDimensions(self)
	local BagBarHeight = 0
	local CaptionHeight = 20
	local rows = 1	

	rows = mnkLibs.Round((#self.buttons/self.Columns),1)
	if (rows == 0) then rows = 1 end
	if ((rows * self.Columns) < #self.buttons) then rows = (rows + 1) end

	self:SetWidth((itemSlotSize+1) * self.Columns + 8) 
	self:SetHeight(((itemSlotSize+1) * rows) + CaptionHeight + 2)
end

function mbContainer:UpdateFreeSlots()
	bagMain.Empty:SetText(mbContainer:GetNumFreeSlots(bagMain))
	bagBank.Empty:SetText(mbContainer:GetNumFreeSlots(bagBank))
	bagReagent.Empty:SetText(mbContainer:GetNumFreeSlots(bagReagent))
end
