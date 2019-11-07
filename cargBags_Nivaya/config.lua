local addon, ns = ...


ns.options = {

filterArtifactPower = true, --set to 'false' to disable the category for items that give Artifact Power

itemSlotSize = 32,	-- Size of item slots

sizes = {
	bags = {
		columnsSmall = 16,
		columnsLarge = 16,
		largeItemCount = 16,	-- Switch to columnsLarge when >= this number of items in your bags
	},
	bank = {
		columnsSmall = 16,
		columnsLarge = 16,
		largeItemCount = 16,	-- Switch to columnsLarge when >= this number of items in the bank
	},	
},


--------------------------------------------------------------
-- Anything below this is only effective when not using RealUI
--------------------------------------------------------------

fonts = {
	-- Font to use for bag captions and other strings
	standard = {
		mnkLibs.Fonts.ap, 	-- Font path
		16, 						-- Font Size
		"",	-- Flags
	},
	
	--Font to use for the dropdown menu
	dropdown = {
		mnkLibs.Fonts.ap, 	-- Font path
		10, 						-- Font Size
		nil,	-- Flags
	},

	-- Font to use for durability and item level
	itemInfo = {
		mnkLibs.Fonts.ap, 	-- Font path
		8, 						-- Font Size
		"",	-- Flags
	},

	-- Font to use for number of items in a stack
	itemCount = {
		mnkLibs.Fonts.ap, 	-- Font path
		16, 						-- Font Size
		"",	-- Flags
	},

},

colors = {
	background = {0.05, 0.05, 0.05, 0.8},	-- r, g, b, opacity
},


}
