local addon, ns = ...
local cargBags = ns.cargBags

mnkBags = CreateFrame('Frame', 'mnkBags', UIParent)
mnkBags:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBags:RegisterEvent("ADDON_LOADED")

local cbNivaya = cargBags:GetImplementation("Nivaya")

local L = cBnivL
_Bags = {}
cB_BagHidden = {}
mnkBagsGlobals = {}


function mnkBags:ADDON_LOADED(event, addon)

	if (addon ~= 'mnkBags') then return end
	self:UnregisterEvent(event)
	-----------------
	-- Frame Spawns
	-----------------
	local C = cbNivaya:GetContainerClass()

	-- bank bags
	_Bags.bankArmor		= C:New("mb_BankArmor")
	_Bags.bankGem			= C:New("mb_BankGem")
	_Bags.bankConsumables	= C:New("mb_BankCons")
	_Bags.bankArtifactPower	= C:New("mb_BankArtifactPower")
	_Bags.bankBattlePet	= C:New("mb_BankPet")
	_Bags.bankQuest		= C:New("mb_BankQuest")
	_Bags.bankTrade		= C:New("mb_BankTrade")
	_Bags.bankReagent		= C:New("mb_BankReagent")
	_Bags.bank			= C:New("mb_Bank")
		
	_Bags.bankArmor		:SetExtendedFilter(cB_Filters.fItemClass, "BankArmor")
	_Bags.bankGem			:SetExtendedFilter(cB_Filters.fItemClass, "BankGem")
	_Bags.bankConsumables :SetExtendedFilter(cB_Filters.fItemClass, "BankConsumables")
	_Bags.bankArtifactPower	:SetExtendedFilter(cB_Filters.fItemClass, "BankArtifactPower")
	_Bags.bankBattlePet	:SetExtendedFilter(cB_Filters.fItemClass, "BankBattlePet")
	_Bags.bankQuest		:SetExtendedFilter(cB_Filters.fItemClass, "BankQuest")
	_Bags.bankTrade		:SetExtendedFilter(cB_Filters.fItemClass, "BankTradeGoods")
	_Bags.bankReagent		:SetMultipleFilters(true, cB_Filters.fBankReagent, cB_Filters.fHideEmpty)
	_Bags.bank			:SetMultipleFilters(true, cB_Filters.fBank, cB_Filters.fHideEmpty)

	-- inventory bags
	_Bags.bagJunk		= C:New("mb_Junk")
	_Bags.bagNew		= C:New("mb_NewItems")
	_Bags.armor		= C:New("mb_Armor")
	_Bags.gem			= C:New("mb_Gem")
	_Bags.quest		= C:New("mb_Quest")
	_Bags.consumables	= C:New("mb_Consumables")
	_Bags.artifactpower	= C:New("mb_ArtifactPower")
	_Bags.battlepet	= C:New("mb_BattlePet")
	_Bags.tradegoods	= C:New("mb_TradeGoods")
	_Bags.main		= C:New("mb_Bag")

	_Bags.bagJunk		:SetExtendedFilter(cB_Filters.fItemClass, "Junk")
	_Bags.bagNew		:SetFilter(cB_Filters.fNewItems, true)
	_Bags.armor		:SetExtendedFilter(cB_Filters.fItemClass, "Armor")
	_Bags.gem			:SetExtendedFilter(cB_Filters.fItemClass, "Gem")
	_Bags.quest		:SetExtendedFilter(cB_Filters.fItemClass, "Quest")
	_Bags.consumables	:SetExtendedFilter(cB_Filters.fItemClass, "Consumables")
	_Bags.artifactpower	:SetExtendedFilter(cB_Filters.fItemClass, "ArtifactPower")
	_Bags.battlepet	:SetExtendedFilter(cB_Filters.fItemClass, "BattlePet")
	_Bags.tradegoods	:SetExtendedFilter(cB_Filters.fItemClass, "TradeGoods")
	_Bags.main		:SetMultipleFilters(true, cB_Filters.fBags, cB_Filters.fHideEmpty)

	_Bags.main:SetPoint("BOTTOMRIGHT", -20, 200)
	_Bags.bank:SetPoint("TOPLEFT", 20, -50)
	
	cbNivaya:UpdateAnchors()
	cbNivaya:Init()
	--cbNivaya:ToggleBagPosButtons()
end

function cbNivaya:UpdateAnchors()
	local lastBank, lastMain
	--local t = {}	
	--for k in pairs(_Bags) do table.insert(t, k) end
	--table.sort(t)
	--for _, k in ipairs(t) do print(k, ' ', _Bags[k]) end
	
	for k,_ in pairs(_Bags) do
		
		if not ((k == 'main') or (k == 'bank')) then
			_Bags[k]:ClearAllPoints()					
			if (_Bags[k].name:sub(1, string.len('mb_Bank')) == 'mb_Bank') then	
				if not lastBank then lastBank = _Bags.bank end
				if not cB_BagHidden[lastBank.name] then
					_Bags[k]:SetPoint("TOPLEFT", lastBank, "BOTTOMLEFT", 0, -9)
				else
					_Bags[k]:SetPoint("TOPLEFT", lastBank, "TOPLEFT", 0, 0)
				end
				lastBank = _Bags[k]
			else
				if not lastMain then lastMain = _Bags.main end
				if not cB_BagHidden[lastMain.name] then
					_Bags[k]:SetPoint("BOTTOMLEFT", lastMain, "TOPLEFT", 0, 9)
				else
					_Bags[k]:SetPoint("BOTTOMLEFT", lastMain, "BOTTOMLEFT", 0, 0)
				end
				lastMain = _Bags[k]
			end		
		end
	end
end

function cbNivaya:OnOpen()
	for k,_ in pairs(_Bags) do
		if (_Bags[k].name:sub(1, string.len('mb_Bank')) ~= 'mb_Bank') and not cB_BagHidden[_Bags[k].name] then
			_Bags[k]:Show()
		end
	end
end

function cbNivaya:OnClose()
	for k,_ in pairs(_Bags) do
		_Bags[k]:Hide()
	end
end

function cbNivaya:OnBankOpened()
	for k,_ in pairs(_Bags) do
		if not cB_BagHidden[_Bags[k].name] then
			_Bags[k]:Show()
		end
	end 
end

function cbNivaya:OnBankClosed()
	for k,_ in pairs(_Bags) do
		_Bags[k]:Hide()
	end
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

local function StatusMsg(str1, str2, data, name, short)
	local R,G,t = '|cFFFF0000', '|cFF00FF00', ''
	if (data ~= nil) then t = data and G..(short and 'on|r' or 'enabled|r') or R..(short and 'off|r' or 'disabled|r') end
	t = (name and '|cFFFFFF00mnkBags:|r ' or '')..str1..t..str2
	ChatFrame1:AddMessage(t)
end

local function StatusMsgVal(str1, str2, data, name)
	local G,t = '|cFF00FF00', ''
	if (data ~= nil) then t = G..data..'|r' end
	t = (name and '|cFFFFFF00mnkBags:|r ' or '')..str1..t..str2
	ChatFrame1:AddMessage(t)
end

local buttonCollector = {}
local Event =  CreateFrame('Frame', nil)
Event:RegisterEvent("PLAYER_ENTERING_WORLD")
Event:SetScript('OnEvent', function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		for bagID = -3, 11 do
			local slots = GetContainerNumSlots(bagID)
			for slotID=1,slots do
				local button = cbNivaya.buttonClass:New(bagID, slotID)
				buttonCollector[#buttonCollector+1] = button
				cbNivaya:SetButton(bagID, slotID, nil)
			end
		end
		for i,button in pairs(buttonCollector) do
			if button.container then
				button.container:RemoveButton(button)
			end
			button:Free()
		end
		cbNivaya:UpdateBags()

		if IsReagentBankUnlocked() then
			Nivayamb_Bank.reagentBtn:Show()
		else
			Nivayamb_Bank.reagentBtn:Hide()
			local buyReagent = CreateFrame("Button", nil, Nivayamb_BankReagent, "UIPanelButtonTemplate")
			buyReagent:SetText(BANKSLOTPURCHASE)
			buyReagent:SetWidth(buyReagent:GetTextWidth() + 20)
			buyReagent:SetPoint("CENTER", Nivayamb_BankReagent, 0, 0)
			buyReagent:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:AddLine(REAGENT_BANK_HELP, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			buyReagent:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			buyReagent:SetScript("OnClick", function()
				StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
			end)
			buyReagent:SetScript("OnEvent", function(...)
				buyReagent:UnregisterEvent("REAGENTBANK_PURCHASED")
				Nivayamb_Bank.reagentBtn:Show()
				buyReagent:Hide()
			end)

			buyReagent:RegisterEvent("REAGENTBANK_PURCHASED")
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

function mnkBags:ResetItemClass()
	for k,v in pairs(cB_ItemClass) do
		if v == "NoClass" then
			cB_ItemClass[k] = nil
		end
	end
	cbNivaya:UpdateBags()
end
