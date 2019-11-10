local addon, ns = ...
local cargBags = ns.cargBags

mnkBags = CreateFrame('Frame', 'mnkBags', UIParent)
mnkBags:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBags:RegisterEvent("ADDON_LOADED")

local _cargBags = cargBags:GetImplementation("mnkBags_cargBags")

local L = mnkBags_Locals
_Bags = {}
_BagHidden = {}
mnkBagsGlobals = {}


function mnkBags:ADDON_LOADED(event, addon)

	if (addon ~= 'mnkBags') then return end
	self:UnregisterEvent(event)
	-----------------
	-- Frame Spawns
	-----------------
	local C = _cargBags:GetContainerClass()

	-- bank bags
	_Bags.bankArmor			= C:New("bag_BankArmor")
	_Bags.bankGem			= C:New("bag_BankGem")
	_Bags.bankConsumables	= C:New("bag_BankCons")
	_Bags.bankArtifactPower	= C:New("bag_BankArtifactPower")
	_Bags.bankBattlePet		= C:New("bag_BankPet")
	_Bags.bankQuest			= C:New("bag_BankQuest")
	_Bags.bankTrade			= C:New("bag_BankTrade")
	_Bags.bankReagent		= C:New("bag_BankReagent")
	_Bags.bank				= C:New("bag_Bank")
		
	_Bags.bankArmor			:SetExtendedFilter(_Filters.fItemClass, "BankArmor")
	_Bags.bankGem			:SetExtendedFilter(_Filters.fItemClass, "BankGem")
	_Bags.bankConsumables 	:SetExtendedFilter(_Filters.fItemClass, "BankConsumables")
	_Bags.bankArtifactPower	:SetExtendedFilter(_Filters.fItemClass, "BankArtifactPower")
	_Bags.bankBattlePet		:SetExtendedFilter(_Filters.fItemClass, "BankBattlePet")
	_Bags.bankQuest			:SetExtendedFilter(_Filters.fItemClass, "BankQuest")
	_Bags.bankTrade			:SetExtendedFilter(_Filters.fItemClass, "BankTradeGoods")
	_Bags.bankReagent		:SetMultipleFilters(true, _Filters.fBankReagent, _Filters.fHideEmpty)
	_Bags.bank				:SetMultipleFilters(true, _Filters.fBank, _Filters.fHideEmpty)

	-- inventory bags
	_Bags.bagJunk		= C:New("bag_Junk")
	_Bags.bagNew		= C:New("bag_NewItems")
	_Bags.armor			= C:New("bag_Armor")
	_Bags.gem			= C:New("bag_Gem")
	_Bags.quest			= C:New("bag_Quest")
	_Bags.consumables	= C:New("bag_Consumables")
	_Bags.artifactpower	= C:New("bag_ArtifactPower")
	_Bags.battlepet		= C:New("bag_BattlePet")
	_Bags.tradegoods	= C:New("bag_TradeGoods")
	_Bags.main			= C:New("bag_Bag")

	_Bags.bagJunk		:SetExtendedFilter(_Filters.fItemClass, "Junk")
	_Bags.bagNew		:SetFilter(_Filters.fNewItems, true)
	_Bags.armor			:SetExtendedFilter(_Filters.fItemClass, "Armor")
	_Bags.gem			:SetExtendedFilter(_Filters.fItemClass, "Gem")
	_Bags.quest			:SetExtendedFilter(_Filters.fItemClass, "Quest")
	_Bags.consumables	:SetExtendedFilter(_Filters.fItemClass, "Consumables")
	_Bags.artifactpower	:SetExtendedFilter(_Filters.fItemClass, "ArtifactPower")
	_Bags.battlepet		:SetExtendedFilter(_Filters.fItemClass, "BattlePet")
	_Bags.tradegoods	:SetExtendedFilter(_Filters.fItemClass, "TradeGoods")
	_Bags.main			:SetMultipleFilters(true, _Filters.fBags, _Filters.fHideEmpty)

	_Bags.main:SetPoint("BOTTOMRIGHT", -20, 200)
	_Bags.bank:SetPoint("TOPLEFT", 20, -50)
	
	_cargBags:UpdateAnchors()
	_cargBags:Init()
	--_cargBags:ToggleBagPosButtons()
end

function _cargBags:UpdateAnchors()
	local lastBank, lastMain
	--local t = {}	
	--for k in pairs(_Bags) do table.insert(t, k) end
	--table.sort(t)
	--for _, k in ipairs(t) do print(k, ' ', _Bags[k]) end
	
	for k,_ in pairs(_Bags) do
		
		if not ((k == 'main') or (k == 'bank')) then
			_Bags[k]:ClearAllPoints()					
			if (_Bags[k].name:sub(1, 10) == 'bag_Bank') then	
				if not lastBank then lastBank = _Bags.bank end
				if not _BagHidden[lastBank.name] then
					_Bags[k]:SetPoint("TOPLEFT", lastBank, "BOTTOMLEFT", 0, -9)
				else
					_Bags[k]:SetPoint("TOPLEFT", lastBank, "TOPLEFT", 0, 0)
				end
				lastBank = _Bags[k]
			else
				if not lastMain then lastMain = _Bags.main end
				if not _BagHidden[lastMain.name] then
					_Bags[k]:SetPoint("BOTTOMLEFT", lastMain, "TOPLEFT", 0, 9)
				else
					_Bags[k]:SetPoint("BOTTOMLEFT", lastMain, "BOTTOMLEFT", 0, 0)
				end
				lastMain = _Bags[k]
			end		
		end
	end
end

function _cargBags:OnOpen()
	for k,_ in pairs(_Bags) do
		if (_Bags[k].name:sub(1, 10) ~= 'bag_Bank') and not _BagHidden[_Bags[k].name] then
			_Bags[k]:Show()
		end
	end
end

function _cargBags:OnClose()
	for k,_ in pairs(_Bags) do
		_Bags[k]:Hide()
	end
end

function _cargBags:OnBankOpened()
	for k,_ in pairs(_Bags) do
		if not _BagHidden[_Bags[k].name] then
			_Bags[k]:Show()
		end
	end 
end

function _cargBags:OnBankClosed()
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
				local button = _cargBags.buttonClass:New(bagID, slotID)
				buttonCollector[#buttonCollector+1] = button
				_cargBags:SetButton(bagID, slotID, nil)
			end
		end
		for i,button in pairs(buttonCollector) do
			if button.container then
				button.container:RemoveButton(button)
			end
			button:Free()
		end
		_cargBags:UpdateBags()

		if IsReagentBankUnlocked() then
			mnkBags_cargBagsbag_Bank.reagentBtn:Show()
		else
			mnkBags_cargBagsbag_Bank.reagentBtn:Hide()
			local buyReagent = CreateFrame("Button", nil, mnkBags_cargBagsbag_BankReagent, "UIPanelButtonTemplate")
			buyReagent:SetText(BANKSLOTPURCHASE)
			buyReagent:SetWidth(buyReagent:GetTextWidth() + 20)
			buyReagent:SetPoint("CENTER", mnkBags_cargBagsbag_BankReagent, 0, 0)
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
				mnkBags_cargBagsbag_Bank.reagentBtn:Show()
				buyReagent:Hide()
			end)

			buyReagent:RegisterEvent("REAGENTBANK_PURCHASED")
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

function mnkBags:ResetItemClass()
	for k,v in pairs(_ItemClass) do
		if v == "NoClass" then
			_ItemClass[k] = nil
		end
	end
	_cargBags:UpdateBags()
end
