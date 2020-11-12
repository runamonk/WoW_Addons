local addon, ns = ...
local cargBags = ns.cargBags
local cbmb = cargBags:NewImplementation("mnkBags")
local mnkBagsContainer = cbmb:GetContainerClass()
local mnkBagsButton = cbmb:GetItemButtonClass()
local mnkBags = CreateFrame('Frame', 'mnkBags', UIParent, BackdropTemplateMixin and "BackdropTemplate")

mnkBags:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBags:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkBags:RegisterEvent('MERCHANT_SHOW')

mnkBagsKnownItems = {}
skipOnButtonRemove = false

local _
local itemSlotSize = 32
local itemSlotPadding = 4
local itemSlotSpacer = 2
local _Bags = {}
local mediaPath = [[Interface\AddOns\mnkBags\media\]]
local Textures = {
	Search =		mediaPath .. "Search",
	BagToggle =		mediaPath .. "BagToggle",
	ResetNew =		mediaPath .. "ResetNew",
	Restack =		mediaPath .. "Restack",
	Deposit =		mediaPath .. "Deposit"}
local NewItemsSold = 0
local JunkItemsSold = 0

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
	if (not MerchantFrame:IsShown()) or (#_Bags.bagJunk.buttons == 0) then return end
	local p = 0
	p = SellItemsInContainer(_Bags.bagJunk)
	JunkItemsSold = JunkItemsSold + p
	C_Timer.After(0.5, SellJunk) 
end

local function SellNewItems()
	if (not MerchantFrame:IsShown()) or (#_Bags.bagNew.buttons == 0) then return end
	local p = 0
	p = SellItemsInContainer(_Bags.bagNew)
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
		mnkBagsButton:Scaffold("Default")
		cbmb:RegisterBlizzard()
		cbmb:Init()
	end
end

function cbmb:OnOpen()
	for k,_ in pairs(_Bags) do
		if _Bags[k]:ShowOrHide() then
			_Bags[k]:Show()
		end
	end
end

function cbmb:OnClose()
	for k,_ in pairs(_Bags) do
		_Bags[k]:Hide()
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

	_Bags.bankArmor	= mnkBagsContainer:New("mb_BankArmor")
	_Bags.bankGem = mnkBagsContainer:New("mb_BankGem")
	_Bags.bankConsumables =	mnkBagsContainer:New("mb_BankCons")
	_Bags.bankArtifactPower = mnkBagsContainer:New("mb_BankArtifactPower")
	_Bags.bankBattlePet	= mnkBagsContainer:New("mb_BankBattlePet")
	_Bags.bankQuest	= mnkBagsContainer:New("mb_BankQuest")
	_Bags.bankTrade	= mnkBagsContainer:New("mb_BankTrade")
	_Bags.bankReagent = mnkBagsContainer:New("mb_BankReagent")
	_Bags.bank = mnkBagsContainer:New("mb_Bank")

	_Bags.bankArmor:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and ((item.type == mbLocals.Armor) or (item.type == mbLocals.Weapon)) end, true)
	_Bags.bankGem:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and (item.type == mbLocals.Gem) end, true)
	_Bags.bankQuest:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and (item.type == mbLocals.Quest) end, true)
	_Bags.bankConsumables:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and (item.type == mbLocals.Consumables) end, true)
	_Bags.bankArtifactPower:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and (item.type == mbLocals.ArtifactPower) end, true)
	_Bags.bankBattlePet:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and (item.type == mbLocals.BattlePet) end, true)
	_Bags.bankTrade:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) and (item.type == mbLocals.Trades) end, true)
	_Bags.bankReagent:SetFilter(function(item) return ItemNotNull(item) and (item.bagID == -3) end, true)
	_Bags.bank:SetFilter(function(item) return ItemNotNull(item) and IsBank(item) end, true)

	_Bags.bagJunk = mnkBagsContainer:New("mb_Junk")
	_Bags.bagNew = mnkBagsContainer:New("mb_NewItems")
	_Bags.armor	= mnkBagsContainer:New("mb_Armor")
	_Bags.gem = mnkBagsContainer:New("mb_Gem")
	_Bags.quest	= mnkBagsContainer:New("mb_Quest")
	_Bags.consumables = mnkBagsContainer:New("mb_Consumables")
	_Bags.artifactpower	= mnkBagsContainer:New("mb_ArtifactPower")
	_Bags.battlepet	= mnkBagsContainer:New("mb_BattlePet")
	_Bags.tradegoods = mnkBagsContainer:New("mb_TradeGoods")
	_Bags.main = mnkBagsContainer:New("mb_Bag")

	_Bags.bagJunk:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.rarity == 0) end, true)
	_Bags.bagNew:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and  (mnkLibs.GetIndexInTable(mnkBagsKnownItems, item.id) == 0) end, true)
	_Bags.armor:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and ((item.type == mbLocals.Armor) or (item.type == mbLocals.Weapon)) end, true)
	_Bags.gem:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.type == mbLocals.Gem) end, true)
	_Bags.quest:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.type == mbLocals.Quest) end, true)
	_Bags.consumables:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.type == mbLocals.Consumables) end, true)
	_Bags.artifactpower:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.type == mbLocals.ArtifactPower) end, true)
	_Bags.battlepet:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.type == mbLocals.BattlePet) end, true)
	_Bags.tradegoods:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) and (item.type == mbLocals.Trades) end, true)
	_Bags.main:SetFilter(function(item) return ItemNotNull(item) and IsMain(item) end, true)

	_Bags.main:SetPoint('BOTTOMRIGHT', -20, 200)
	_Bags.bank:SetPoint('BOTTOMRIGHT', _Bags.main, 'BOTTOMLEFT', -20, 0)

	for k,_ in pairs(_Bags) do
		_Bags[k]:OnContentsChanged(true)
	end
	--print(#mnkBagsKnownItems)
	cbmb:UpdateAnchors()
end

function cbmb:UpdateAllBags()
	for k,_ in pairs(_Bags) do
		_Bags[k]:OnContentsChanged(true)
	end
	cbmb:UpdateAnchors()
end

function cbmb:UpdateAnchors()
	local function SetBagAnchor(bag, lastbag, parentbag)

		local h = GetScreenHeight()
		local i = bag:GetHeight()
		local t = lastbag:GetTop()
		-- Check if the bag will end up off the top of the screen, if so then start a new column of containers.
		if (t + i) > h then
			if parentbag.mywifeisahorder then
				bag:SetPoint("BOTTOMRIGHT", parentbag.mywifeisahorder, "BOTTOMLEFT", -16, 0)
			else
				bag:SetPoint("BOTTOMRIGHT", parentbag, "BOTTOMLEFT", -16, 0)	
			end
			parentbag.mywifeisahorder = bag
			return
		end
		
		if lastbag:ShowOrHide() or (lastbag == _Bags.bank or lastbag == _Bags.main) then
			bag:SetPoint("BOTTOMLEFT", lastbag, "TOPLEFT", 0, 12)
		else
			bag:SetPoint("BOTTOMLEFT", lastbag, "BOTTOMLEFT", 0, 0)
		end
	end
	--print('UpdateAnchors()')
	local lastBank, lastMain = _Bags.bank, _Bags.main
	_Bags.bank.mywifeisahorder = nil
	_Bags.main.mywifeisahorder = nil

	for k,_ in pairs(_Bags) do	
		if not ((k == 'main') or (k == 'bank')) then
			_Bags[k]:ClearAllPoints()					
			if (_Bags[k].name:sub(1, string.len('mb_Bank')) == 'mb_Bank') then	
				SetBagAnchor(_Bags[k], lastBank, _Bags.bank)
				lastBank = _Bags[k]
			else
				SetBagAnchor(_Bags[k], lastMain, _Bags.main)
				lastMain = _Bags[k]
			end
		end
	end
end

function cbmb:UpdateBags()
	for i = -3, 11 do 
		cbmb:UpdateBag(i) 
	end 
end

function mnkBagsContainer:GetFirstFreeSlot(self)
	if self == _Bags.bank then		
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
	elseif self == _Bags.bankReagent then
		local bagID = -3
		local t = GetContainerNumFreeSlots(bagID)
		if t > 0 then
			local tNumSlots = GetContainerNumSlots(bagID)
			for j = 1,tNumSlots do
				local tLink = GetContainerItemLink(bagID,j)
				if not tLink then return bagID,j end
			end
		end
	elseif self == _Bags.main then
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

function mnkBagsContainer:GetNumFreeSlots(self)
	local free, max = 0, 0
	if self == _Bags.main then
		for i = 0,4 do
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	elseif self == _Bags.bankReagent then
		free = GetContainerNumFreeSlots(-3)
		max = GetContainerNumSlots(-3)
	elseif self == _Bags.bank then
		local containerIDs = {-1,5,6,7,8,9,10,11}
		for _,i in next, containerIDs do	
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	end
	return free, max
end

function mnkBagsContainer:DepositReagentBank()
	DepositReagentBank()
end

function mnkBagsContainer:OnButtonRemove(button)
	if skipOnButtonRemove then return end 
	-- remove item from known items
	if button.clink then
		--print("OnButtonRemove:"..button.clink)
		local itemid = select(1, GetItemInfoInstant(button.clink))
		local i = mnkLibs.GetIndexInTable(mnkBagsKnownItems, itemid) 
		if i > 0 then			
			table.remove(mnkBagsKnownItems, i)
		end		
	end
end

function mnkBagsContainer:OnContentsChanged(skipUpdateAnchors)
	if cbmb.SkipOnChange then return end

	--print('OnChanged ',  self.name)
	local col, row = 0, 0
	local CaptionHeight = 20
	local buttonIDs = {}

  	for i, button in pairs(self.buttons) do
  		local clink = GetContainerItemLink(button.bagID, button.slotID)

  		if clink then
  			--local name = select(1, GetItemInfo(clink))
  			local item = cbmb:GetItemInfo(button.bagID, button.slotID)
  			buttonIDs[i] = {item.name, item.count, button}
  		else
  			buttonIDs[i] = {nil, 0, button}
  		end
	end
	
	-- sort by name and count
	local function sort(v1, v2)
		if (v1[1] == nil) and (v2[1] == nil) then return false end
		if (v1[1] == nil) or (v2[1] == nil) then return (v1[1] and true or false) end

 		return (v1[1] < v2[1]) or ((v1[1] == v2[1]) and (v1[2] > v2[2]))
	end

	table.sort(buttonIDs, sort)

	for _,v in ipairs(buttonIDs) do
		local button = v[3]
		button:ClearAllPoints()
	  
		local xPos = col * (itemSlotSize + itemSlotPadding) + itemSlotSpacer
		local yPos = (-1 * row * (itemSlotSize + itemSlotPadding)) - CaptionHeight

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
	local yPos = (-1 * row * (itemSlotSize + itemSlotPadding)) - CaptionHeight

	local tDrop = self.Drop
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

	self:UpdateDimensions(self)

	if self:ShowOrHide() then
		self:Show()
	else
		self:Hide()
	end

	mnkBagsContainer:UpdateFreeSlots()

	if not skipUpdateAnchors then
		cbmb:UpdateAnchors()
	end
end

function mnkBagsContainer:OnCreate(name)
	if not name then return end
	self.name = name

	-- this works better than inserting the the frame in the UISpecialFrames table.
	-- if you go to the bank and have both the bank and your bank open, then press esc the bank won't come back up until you've toggled again.
	self:EnableKeyboard(1);
	self:SetScript("OnKeyDown",function(self,key)
		if key == 'ESCAPE' then
			self:SetPropagateKeyboardInput(false)
			ToggleAllBags()
		else
			self:SetPropagateKeyboardInput(true)
		end
	end);

	self.Columns = 12
	self:EnableMouse(true)
	self:SetFrameStrata("MEDIUM")
	self.Caption = mnkLibs.createFontString(self, mnkLibs.Fonts.ap, 16, nil, nil, true)
	self.Caption:SetText(mbLocals.bagCaptions[self.name])
	self.Caption:SetPoint("TOPLEFT", 0, 2)
	self:SetScript('OnShow', function (self) self:OnShow() end)
	self.background = CreateFrame("Frame", nil, self)
	mnkLibs.setBackdrop(self, mnkLibs.Textures.background, nil, 4, 4, 4, 4)
	mnkLibs.createBorder(self, 4,-4,-5,5, {1/3,1/3,1/3,1})
	self.background:SetFrameStrata("HIGH")
	self.background:SetFrameLevel(1)
	self:SetBackdropColor(0, 0, 0, 1)

	local isMain = (name == "mb_Bag") 
	local isBank = (name == "mb_Bank")
	local isReagent = (name == "mb_BankReagent")

	if (isMain or isBank) then 
		self:SetBackdropColor(1/8, 1/8, 1/8, 1)
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
		mnkLibs.setTooltip(self.CloseButton, 'Close')
		self.CloseButton:SetScript("OnClick", function(self) if cbmb:AtBank() then CloseBankFrame() else CloseAllBags() end end)

		if isMain then
			self.pluginBagBar = self:SpawnPlugin("BagBar", "backpack+bags")
			self.pluginBagBar:SetSize(self.pluginBagBar:LayoutButtons("grid", 4))
			self.SearchButton = CreateFrame("Button", nil, self)
			self.SearchButton:SetWidth((itemSlotSize+itemSlotPadding) * self.Columns-itemSlotSize) -- subtract both buttons.
			self.SearchButton:SetHeight(18)
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
			self.pluginBagBar = self:SpawnPlugin("BagBar", "bank")
			self.pluginBagBar:SetSize(self.pluginBagBar:LayoutButtons("grid", 7))
		end
		
		self.pluginBagBar.isGlobal = true
		self.pluginBagBar.AllowFilter = false
		self.pluginBagBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 25)
		self.pluginBagBar:Hide()

		self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", "Toggle Bags")
		self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
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
		self.restackBtn:SetScript("OnClick", function() mnkBagsContainer:RestackItems(self) end)		
	end

	if self.name == 'mb_NewItems' then
		self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "TOPRIGHT", "Reset New")
		self.resetBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.resetBtn:SetScript("OnClick", function() self:ResetNewItems() end)

		self.buttonSellItems = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.buttonSellItems:SetDisabledTexture("Interface\\AddOns\\mnkBags\\media\\Sell")
		self.buttonSellItems:SetNormalTexture("Interface\\AddOns\\mnkBags\\media\\Sell")
		self.buttonSellItems:SetPushedTexture("Interface\\AddOns\\mnkBags\\media\\Sell")
		self.buttonSellItems:SetHighlightTexture("Interface\\AddOns\\mnkBags\\media\\Sell")		
		self.buttonSellItems:ClearAllPoints()
		self.buttonSellItems:SetPoint("TOPRIGHT", self.resetBtn, "TOPLEFT", -2, -1)
		self.buttonSellItems:SetSize(12,12)
		mnkLibs.setTooltip(self.buttonSellItems, 'Sell all items in New bag.')
		self.buttonSellItems:SetScript("OnClick", 
			function ()
			 	if (not MerchantFrame:IsShown()) then return end
				StaticPopup_Show("ConfirmSellNewItems")
			end)
	end
	
	if isReagent then
		self.reagentBtn = createIconButton("SendReagents", self, Textures.Deposit, "TOPRIGHT", REAGENTBANK_DEPOSIT)
		self.reagentBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 4, 0)
		self.reagentBtn:SetScript("OnClick", function()	 mnkBagsContainer:DepositReagentBank() end)

		self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack")
		self.restackBtn:SetPoint("TOPRIGHT", self.reagentBtn, "TOPLEFT", -3, 1)
		self.restackBtn:SetScript("OnClick", function() mnkBagsContainer:RestackItems(self) end)
	end

	if (isMain or isBank or isReagent) then
		self.Drop = CreateFrame("ItemButton", self.name.."Drop", self)
		self.Drop.NormalTexture = _G[self.Drop:GetName().."NormalTexture"]
		self.Drop.NormalTexture:SetTexture(nil)
		self.Drop:SetSize(itemSlotSize,itemSlotSize)
		self.Empty = mnkLibs.createFontString(self, mnkLibs.Fonts.ap, 16, nil, nil, true)
		self.Empty:SetPoint("BOTTOMRIGHT", self.Drop, "BOTTOMRIGHT", -3, 3)
		self.Empty:SetJustifyH("LEFT")
		mnkLibs.createBorder(self.Drop, 0.8, -0.8, -0.8, 0.8, {1/2,1/2,1/2,1})
		self.Drop:Show()
		self.Empty:Show()

		local GetFirstFreeSlot = function()
			if self.Empty:GetText() == '0' or nil then
				mnkLibs.PrintError('Bag is full')
			else
				PickupContainerItem(mnkBagsContainer:GetFirstFreeSlot(self))
			end
		end
		self.Drop:SetScript("OnMouseUp", GetFirstFreeSlot)
		self.Drop:SetScript("OnReceiveDrag", GetFirstFreeSlot)
	end
	if self.name == 'mb_Junk' then
		self.buttonDeleteJunk = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		self.buttonDeleteJunk:SetDisabledTexture("Interface\\AddOns\\mnkBags\\media\\JunkDelete")
		self.buttonDeleteJunk:SetNormalTexture("Interface\\AddOns\\mnkBags\\media\\JunkDelete")
		self.buttonDeleteJunk:SetPushedTexture("Interface\\AddOns\\mnkBags\\media\\JunkDelete")
		self.buttonDeleteJunk:SetHighlightTexture("Interface\\AddOns\\mnkBags\\media\\JunkDelete")		
		self.buttonDeleteJunk:ClearAllPoints()
		self.buttonDeleteJunk:SetPoint("TOPRIGHT", 2, 0)
		self.buttonDeleteJunk:SetSize(12,12)
		mnkLibs.setTooltip(self.buttonDeleteJunk, 'Destroy all junk with a sell price of less than 1g. ALT + Click to destory all junk.')
		self.buttonDeleteJunk:SetScript("OnClick", 
			function(self, button)
				local deleteAll = false
				if button == 'LeftButton' and IsAltKeyDown() then
					deleteAll = true
				end

				for k,_ in pairs(_Bags.bagJunk.buttons) do
					local b = _Bags.bagJunk.buttons[k]
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

function mnkBagsContainer:OnShow()
	-- fill the Reagent bag.
	if self == _Bags.bankReagent then
		-- Fill the bag but don't do the OnChange events until the very end. This is less intensive.
		cbmb.SkipOnChange = true
		cbmb:UpdateBag(-3)
		cbmb.SkipOnChange = false
		_Bags.bankReagent:OnContentsChanged()

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

function mnkBagsContainer:ResetNewItems()
	skipOnButtonRemove = true
	for k,_ in pairs(_Bags.bagNew.buttons) do
		local b = _Bags.bagNew.buttons[k]
		local clink = GetContainerItemLink(b.bagID, b.slotID)
		local itemid = select(1, GetItemInfoInstant(clink))
		if mnkLibs.GetIndexInTable(mnkBagsKnownItems, itemid) == 0 then			
			mnkBagsKnownItems[#mnkBagsKnownItems+1] = itemid
		end
	end

	cbmb:UpdateBags()
	skipOnButtonRemove = false
end

function mnkBagsContainer:RestackItems(self)
	if self == _Bags.bankReagent then
		SortReagentBankBags()
	elseif self == _Bags.bank then
		SortBankBags()
	elseif self == _Bags.main then
		SortBags()
	end
end

function mnkBagsContainer:ShowOrHide()
	local result = (#self.buttons > 0) or false
	local isBankBag = (self.name:sub(1, string.len('mb_Bank')) == 'mb_Bank') 

	if ((isBankBag == true) and cbmb:AtBank() and ((#self.buttons > 0) or  -- Bank bag? Has items in it?
		                                           (self == _Bags.bankReagent) or (self == _Bags.bank))) or -- always show main and reagent bags
	                                               (self == _Bags.main) then -- main bag		
		result = true
	-- bank bag, but not at bank? 
	elseif (isBankBag == true) and (not cbmb:AtBank()) then     
		result = false
	end

	return result
end

function mnkBagsContainer:UpdateDimensions(self)
	local BagBarHeight = 0
	local CaptionHeight = 28
	local buttonCount = 0
	local rows = 1	

	-- primary bags or bankRequest bag should always have an free slot counter.
	if self.bagToggle or self == _Bags.bankReagent then
		buttonCount = 1
		if self.bagToggle then 
			if self.pluginBagBar and self.pluginBagBar:IsShown() then 
				BagBarHeight = 60
			else 
				BagBarHeight = 16
			end
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

function mnkBagsContainer:UpdateFreeSlots()
	_Bags.main.Empty:SetText(mnkBagsContainer:GetNumFreeSlots(_Bags.main))
	_Bags.bank.Empty:SetText(mnkBagsContainer:GetNumFreeSlots(_Bags.bank))
	_Bags.bankReagent.Empty:SetText(mnkBagsContainer:GetNumFreeSlots(_Bags.bankReagent))
end
