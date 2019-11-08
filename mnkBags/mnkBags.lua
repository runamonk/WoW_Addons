local addon, ns = ...
local cargBags = ns.cargBags

mnkBags = CreateFrame('Frame', 'mnkBags', UIParent)
mnkBags:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkBags:RegisterEvent("ADDON_LOADED")

local cbNivaya = cargBags:GetImplementation("Nivaya")

local L = cBnivL
cB_Bags = {}
cB_BagHidden = {}

local ItemSetCaption = (IsAddOnLoaded('ItemRack') and "ItemRack ") or (IsAddOnLoaded('Outfitter') and "Outfitter ") or "Item "
local bankOpenState = false

-- function cbNivaya:ShowBags(...)
	-- local bags = {...}
	-- for i = 1, #bags do
		-- local bag = bags[i]
		-- if not cB_BagHidden[bag.name] then
			-- bag:Show()
		-- end
	-- end
-- end

-- function cbNivaya:HideBags(...)
	-- local bags = {...}
	-- for i = 1, #bags do
		-- local bag = bags[i]
		-- bag:Hide()
	-- end
-- end

function cbNivaya:ShowBags(...)
	local bags = {...}
	for i = 1, #bags do
		local bag = bags[i]
		if not cB_BagHidden[bag.name] then
			bag:Show()
		end
	end
end

function cbNivaya:HideBags(...)
	local bags = {...}
	for i = 1, #bags do
		local bag = bags[i]
		bag:Hide()
	end
end



function mnkBags:ADDON_LOADED(event, addon)

	if (addon ~= 'mnkBags') then return end
	self:UnregisterEvent(event)

	cBniv.BagPos = true

	-----------------
	-- Frame Spawns
	-----------------
	local C = cbNivaya:GetContainerClass()

	-- bank bags
	cB_Bags.bankArmor		= C:New("cBniv_BankArmor")
	cB_Bags.bankGem			= C:New("cBniv_BankGem")
	cB_Bags.bankConsumables	= C:New("cBniv_BankCons")
	cB_Bags.bankArtifactPower	= C:New("cBniv_BankArtifactPower")
	cB_Bags.bankBattlePet	= C:New("cBniv_BankPet")
	cB_Bags.bankQuest		= C:New("cBniv_BankQuest")
	cB_Bags.bankTrade		= C:New("cBniv_BankTrade")
	cB_Bags.bankReagent		= C:New("cBniv_BankReagent")
	cB_Bags.bank			= C:New("cBniv_Bank")
		
	cB_Bags.bankArmor		:SetExtendedFilter(cB_Filters.fItemClass, "BankArmor")
	cB_Bags.bankGem			:SetExtendedFilter(cB_Filters.fItemClass, "BankGem")
	cB_Bags.bankConsumables :SetExtendedFilter(cB_Filters.fItemClass, "BankConsumables")
	cB_Bags.bankArtifactPower	:SetExtendedFilter(cB_Filters.fItemClass, "BankArtifactPower")
	cB_Bags.bankBattlePet	:SetExtendedFilter(cB_Filters.fItemClass, "BankBattlePet")
	cB_Bags.bankQuest		:SetExtendedFilter(cB_Filters.fItemClass, "BankQuest")
	cB_Bags.bankTrade		:SetExtendedFilter(cB_Filters.fItemClass, "BankTradeGoods")
	cB_Bags.bankReagent		:SetMultipleFilters(true, cB_Filters.fBankReagent, cB_Filters.fHideEmpty)
	cB_Bags.bank			:SetMultipleFilters(true, cB_Filters.fBank, cB_Filters.fHideEmpty)

	-- inventory bags
	cB_Bags.bagJunk		= C:New("cBniv_Junk")
	cB_Bags.bagNew		= C:New("cBniv_NewItems")
	cB_Bags.armor		= C:New("cBniv_Armor")
	cB_Bags.gem			= C:New("cBniv_Gem")
	cB_Bags.quest		= C:New("cBniv_Quest")
	cB_Bags.consumables	= C:New("cBniv_Consumables")
	cB_Bags.artifactpower	= C:New("cBniv_ArtifactPower")
	cB_Bags.battlepet	= C:New("cBniv_BattlePet")
	cB_Bags.tradegoods	= C:New("cBniv_TradeGoods")
	cB_Bags.main		= C:New("cBniv_Bag")

	cB_Bags.bagJunk		:SetExtendedFilter(cB_Filters.fItemClass, "Junk")
	cB_Bags.bagNew		:SetFilter(cB_Filters.fNewItems, true)
	cB_Bags.armor		:SetExtendedFilter(cB_Filters.fItemClass, "Armor")
	cB_Bags.gem			:SetExtendedFilter(cB_Filters.fItemClass, "Gem")
	cB_Bags.quest		:SetExtendedFilter(cB_Filters.fItemClass, "Quest")
	cB_Bags.consumables	:SetExtendedFilter(cB_Filters.fItemClass, "Consumables")
	cB_Bags.artifactpower	:SetExtendedFilter(cB_Filters.fItemClass, "ArtifactPower")
	cB_Bags.battlepet	:SetExtendedFilter(cB_Filters.fItemClass, "BattlePet")
	cB_Bags.tradegoods	:SetExtendedFilter(cB_Filters.fItemClass, "TradeGoods")
	cB_Bags.main		:SetMultipleFilters(true, cB_Filters.fBags, cB_Filters.fHideEmpty)

	cB_Bags.main:SetPoint("BOTTOMRIGHT", -99, 26)
	cB_Bags.bank:SetPoint("TOPLEFT", 20, -20)
	
	cbNivaya:CreateAnchors()
	cbNivaya:Init()
	cbNivaya:ToggleBagPosButtons()
end

function cbNivaya:CreateAnchors()
	-----------------------------------------------
	-- Store the anchoring order:
	-- read: "tar" is anchored to "src" in the direction denoted by "dir".
	-----------------------------------------------
	local function CreateAnchorInfo(src, tar, dir)
		tar.AnchorTo = src
		tar.AnchorDir = dir
		if src then
			if not src.AnchorTargets then src.AnchorTargets = {} end
			src.AnchorTargets[tar] = true
		end
	end
	
	-- neccessary if this function is used to update the anchors:
	for k,_ in pairs(cB_Bags) do
		if not ((k == 'main') or (k == 'bank')) then cB_Bags[k]:ClearAllPoints() end
		cB_Bags[k].AnchorTo = nil
		cB_Bags[k].AnchorDir = nil
		cB_Bags[k].AnchorTargets = nil
	end

	-- Main Anchors:
	CreateAnchorInfo(nil, cB_Bags.main, "Bottom")
	CreateAnchorInfo(nil, cB_Bags.bank, "Bottom")

	-- Bank Anchors:
	CreateAnchorInfo(cB_Bags.bank, 				cB_Bags.bankArmor, "Bottom")
	CreateAnchorInfo(cB_Bags.bankArmor, 		cB_Bags.bankGem, "Bottom")
	CreateAnchorInfo(cB_Bags.bankGem, 			cB_Bags.bankTrade, "Bottom")
	CreateAnchorInfo(cB_Bags.bankTrade, 		cB_Bags.bankReagent, "Bottom")
	CreateAnchorInfo(cB_Bags.bankReagent, 		cB_Bags.bankConsumables, "Bottom")
	CreateAnchorInfo(cB_Bags.bankConsumables, 	cB_Bags.bankQuest, "Bottom")
	CreateAnchorInfo(cB_Bags.bankQuest, 		cB_Bags.bankArtifactPower, "Bottom")
	CreateAnchorInfo(cB_Bags.bankArtifactPower, cB_Bags.bankBattlePet, "Bottom")
	
	-- Bag Anchors:
	CreateAnchorInfo(cB_Bags.main, 	        cB_Bags.armor, 			"Top")
	CreateAnchorInfo(cB_Bags.armor, 		cB_Bags.gem, 			"Top")
	CreateAnchorInfo(cB_Bags.gem, 			cB_Bags.artifactpower,	"Top")
	CreateAnchorInfo(cB_Bags.artifactpower,	cB_Bags.battlepet, 		"Top")
	CreateAnchorInfo(cB_Bags.battlepet, 	cB_Bags.tradegoods, 	"Top")
	CreateAnchorInfo(cB_Bags.tradegoods, 	cB_Bags.consumables, 	"Top")
	CreateAnchorInfo(cB_Bags.consumables, 	cB_Bags.quest, 			"Top")
	CreateAnchorInfo(cB_Bags.quest, 		cB_Bags.bagJunk, 		"Top")
	CreateAnchorInfo(cB_Bags.bagJunk, 		cB_Bags.bagNew, 		"Top")
	
	-- Finally update all anchors:
	for _,v in pairs(cB_Bags) do cbNivaya:UpdateAnchors(v) end
end

function cbNivaya:UpdateAnchors(self)
	if not self.AnchorTargets then return end
	for v,_ in pairs(self.AnchorTargets) do
		local t, u = v.AnchorTo, v.AnchorDir
		if t then
			local h = cB_BagHidden[t.name]
			v:ClearAllPoints()
			if	not h		and u == "Top"		then v:SetPoint("BOTTOM", t, "TOP", 0, 9)
			elseif	h		and u == "Top"		then v:SetPoint("BOTTOM", t, "BOTTOM")
			elseif	not h	and u == "Bottom"	then v:SetPoint("TOP", t, "BOTTOM", 0, -9)
			elseif	h		and u == "Bottom"	then v:SetPoint("TOP", t, "TOP")
			elseif	u == "Left"					then v:SetPoint("BOTTOMRIGHT", t, "BOTTOMLEFT", -9, 0)
			elseif	u == "Right"				then v:SetPoint("TOPLEFT", t, "TOPRIGHT", 9, 0) end
		end
	end
end

function cbNivaya:OnOpen()
	cB_Bags.main:Show()
	cbNivaya:ShowBags(cB_Bags.armor, cB_Bags.bagNew, cB_Bags.gem, cB_Bags.quest, cB_Bags.consumables, cB_Bags.artifactpower, cB_Bags.battlepet,  cB_Bags.tradegoods, cB_Bags.bagJunk)
end

function cbNivaya:OnClose()
	cbNivaya:HideBags(cB_Bags.main, cB_Bags.armor, cB_Bags.bagNew, cB_Bags.gem, cB_Bags.quest, cB_Bags.consumables, cB_Bags.artifactpower, cB_Bags.battlepet, cB_Bags.tradegoods, cB_Bags.bagJunk)
end

function cbNivaya:OnBankOpened() 
	cB_Bags.bank:Show(); 
	cbNivaya:ShowBags(cB_Bags.bankReagent, cB_Bags.bankArmor, cB_Bags.bankGem, cB_Bags.bankQuest, cB_Bags.bankTrade, cB_Bags.bankConsumables, cB_Bags.bankArtifactPower, cB_Bags.bankBattlePet) 
end

function cbNivaya:OnBankClosed()
	cbNivaya:HideBags(cB_Bags.bank, cB_Bags.bankReagent, cB_Bags.bankArmor, cB_Bags.bankGem, cB_Bags.bankQuest, cB_Bags.bankTrade, cB_Bags.bankConsumables, cB_Bags.bankArtifactPower, cB_Bags.bankBattlePet)
end

function cbNivaya:ToggleBagPosButtons()
	cBniv.BagPos = not cBniv.BagPos
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
			NivayacBniv_Bank.reagentBtn:Show()
		else
			NivayacBniv_Bank.reagentBtn:Hide()
			local buyReagent = CreateFrame("Button", nil, NivayacBniv_BankReagent, "UIPanelButtonTemplate")
			buyReagent:SetText(BANKSLOTPURCHASE)
			buyReagent:SetWidth(buyReagent:GetTextWidth() + 20)
			buyReagent:SetPoint("CENTER", NivayacBniv_BankReagent, 0, 0)
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
				NivayacBniv_Bank.reagentBtn:Show()
				buyReagent:Hide()
			end)
			if Aurora then
				local F = Aurora[1]
				F.Reskin(buyReagent)
			end
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
