mnkBags_Locals = {}
local gl = GetLocale()

mnkBags_Locals.Search = SEARCH
mnkBags_Locals.Armor = GetItemClassInfo(4)
mnkBags_Locals.BattlePet = GetItemClassInfo(17)
mnkBags_Locals.Consumables = GetItemClassInfo(0)
mnkBags_Locals.Gem = GetItemClassInfo(3)
mnkBags_Locals.Quest = GetItemClassInfo(12)
mnkBags_Locals.Trades = GetItemClassInfo(7)
mnkBags_Locals.Weapon = GetItemClassInfo(2)
mnkBags_Locals.ArtifactPower = ARTIFACT_POWER
mnkBags_Locals.bagCaptions = {
	["bag_Bank"] 			= BANK,
	["bag_BankReagent"]	= REAGENT_BANK,
	["bag_BankSets"]		= LOOT_JOURNAL_ITEM_SETS,
	["bag_BankArmor"]		= BAG_FILTER_EQUIPMENT,
	["bag_BankGem"]		= AUCTION_CATEGORY_GEMS,
	["bag_BankQuest"]		= AUCTION_CATEGORY_QUEST_ITEMS,
	["bag_BankTrade"]		= BAG_FILTER_TRADE_GOODS,
	["bag_BankCons"]		= BAG_FILTER_CONSUMABLES,
	["bag_BankArtifactPower"]	= ARTIFACT_POWER,
	["bag_Junk"]			= BAG_FILTER_JUNK,
	["bag_ItemSets"]		= LOOT_JOURNAL_ITEM_SETS,
	["bag_Armor"]			= BAG_FILTER_EQUIPMENT,
	["bag_Gem"]			= AUCTION_CATEGORY_GEMS,
	["bag_Quest"]			= AUCTION_CATEGORY_QUEST_ITEMS,
	["bag_Consumables"]	= BAG_FILTER_CONSUMABLES,
	["bag_ArtifactPower"]	= ARTIFACT_POWER,
	["bag_TradeGoods"]	= BAG_FILTER_TRADE_GOODS,
	["bag_BattlePet"]		= AUCTION_CATEGORY_BATTLE_PETS,
	["bag_Bag"]			= INVENTORY_TOOLTIP,
	["bag_Keyring"]		= KEYRING,
	["bag_NewItems"]      = "New"
}	

