mnkFavoriteMounts = CreateFrame('Frame')
mnkFavoriteMounts.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local libQTip = LibStub('LibQTip-1.0')
local libAG = LibStub('AceGUI-3.0')

local tblAll = {}
local tblCollected = {}
local tblFavorites = {}
local _

local function parseMounts()
	tblFavorites = {}	
	tblCollected = {}
	
	local c = 0
	local d = 0 
	
    if #tblAll > 0 then
        for i = 1, #tblAll do
            local mName, spellID, mIcon, active, isUsable, _, isFavorite, _, _, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(tblAll[i])
            
			if isCollected == true and hideOnChar == false then
				d = (d + 1)
				tblCollected[d] = {}
                tblCollected[d].mName = mName
                tblCollected[d].mID = mountID
                tblCollected[d].mIcon = mIcon				
			end
			if isFavorite == true and isUsable == true and isCollected == true and hideOnChar == false then
                c = (c + 1)
                tblFavorites[c] = {}
                tblFavorites[c].mName = mName
                tblFavorites[c].mID = mountID
                tblFavorites[c].mIcon = mIcon
            end
        end
        
        local sort_func = function(a, b) return a.mName < b.mName end
        table.sort(tblFavorites, sort_func)
		table.sort(tblCollected, sort_func)
    end	
end

local function getAllMounts()
	tblAll = {}
	tblAll = C_MountJournal.GetMountIDs()
	parseMounts()
    mnkFavoriteMounts.LDB.text = mnkLibs.Color(COLOR_GOLD)..#tblFavorites..mnkLibs.Color(COLOR_WHITE)..' of '..mnkLibs.Color(COLOR_GOLD)..#tblCollected
end

function mnkFavoriteMounts:DoOnEvent(event, firstTime)
    if event == 'PLAYER_LOGIN' then
        mnkFavoriteMounts.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkFavoriteMountss', {
            icon = 'Interface\\Icons\\Ability_mount_blackpanther.blp', 
            type = 'data source', 
            OnEnter = mnkFavoriteMounts.DoOnEnter, 
            OnClick = mnkFavoriteMounts.DoOnClick
        })

        Hotkey, _ = GetBindingKey('RANDOM_MOUNT')
		
        mnkFavoriteMounts.LDB.label = 'Favorite Mounts'
    elseif (event == 'PLAYER_ENTERING_WORLD' and firstTime) or event == 'COMPANION_LEARNED' or event == 'COMPANION_UPDATE' then
		getAllMounts() 
	end
end

function mnkFavoriteMounts.DoOnEnter(self)
    getAllMounts()

    local tooltip = libQTip:Acquire('mnkFavoriteMountssToolTip', 1, 'LEFT')
    self.tooltip = tooltip
    tooltip.step = 50 
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
	
    if #tblFavorites > 0 then
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Favorites - '..mnkLibs.Color(COLOR_GOLD)..#tblFavorites..' of '..#tblCollected)

        for i = 1, #tblFavorites do
            local y = tooltip:AddLine(string.format('|T%s|t', tblFavorites[i].mIcon..':16:16:0:0:64:64:4:60:4:60')..' '..tblFavorites[i].mName)
            tooltip:SetLineScript(y, 'OnMouseDown', mnkFavoriteMounts.DoOnMouseDown, tblFavorites[i].mID)
        end 
    end

    if (#tblFavorites == 0) then
        tooltip:AddLine(mnkLibs.Color(COLOR_GOLD)..'No favorite mounts defined.')
    end

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling(500)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkFavoriteMounts.DoOnClick(self, button)
    ToggleCollectionsJournal(1)
end

function mnkFavoriteMounts.DoOnMouseDown(button, arg)
    C_MountJournal.SummonByID(arg)
end

mnkFavoriteMounts:SetScript('OnEvent', mnkFavoriteMounts.DoOnEvent)
mnkFavoriteMounts:RegisterEvent('PLAYER_LOGIN')
mnkFavoriteMounts:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkFavoriteMounts:RegisterEvent('COMPANION_LEARNED')
mnkFavoriteMounts:RegisterEvent('COMPANION_UPDATE')

