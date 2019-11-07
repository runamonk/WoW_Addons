local addon, ns = ...


ns.options = {

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
