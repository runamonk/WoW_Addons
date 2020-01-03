mnkFavoriteMounts = CreateFrame('Frame', 'mnkFavoriteMounts')
mnkFavoriteMounts.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkFavoriteMounts:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkFavoriteMounts:RegisterEvent('PLAYER_LOGIN')
mnkFavoriteMounts:RegisterEvent('COMPANION_LEARNED')
mnkFavoriteMounts:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkFavoriteMounts:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')

local libQTip = LibStub('LibQTip-1.0')
local libAG = LibStub('AceGUI-3.0')
local tblAll = {}
local intCollected = 0
local tFavorites = {}

function mnkFavoriteMounts:GetAllMounts()
    tblAll = {}
    tFavorites = {}   
    tblAll = C_MountJournal.GetMountIDs()

    local c = 0
    intCollected = 0
    
    if #tblAll > 0 then
        for i = 1, #tblAll do
            local mName, _, mIcon, _, isUsable, _, isFavorite, _, _, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(tblAll[i])

            if isCollected then
                intCollected = intCollected + 1         
            end
            
            if isCollected and isFavorite and isUsable and not hideOnChar then
                c = (c + 1)
                tFavorites[c] = {}
                tFavorites[c].mName = mName
                tFavorites[c].mID = mountID
                tFavorites[c].mIcon = mIcon
            end
        end
        
        local sort_func = function(a, b) return a.mName < b.mName end
        table.sort(tFavorites, sort_func)
    end
    mnkFavoriteMounts.LDB.text = mnkLibs.Color(COLOR_GOLD)..#tFavorites..mnkLibs.Color(COLOR_WHITE)..' of '..mnkLibs.Color(COLOR_GOLD)..intCollected 
end

function mnkFavoriteMounts:OnClick()
    ToggleCollectionsJournal(1)
end

function mnkFavoriteMounts:OnEnter(parent)

    local function OnMouseDown(button, arg)
        C_MountJournal.SummonByID(arg)
    end

    self:GetAllMounts()

    local tooltip = libQTip:Acquire('mnkFavoriteMountsToolTip', 1, 'LEFT')
    self.tooltip = tooltip
    tooltip.step = 50 
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    
    if #tFavorites > 0 then
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Favorites - '..mnkLibs.Color(COLOR_GOLD)..#tFavorites..' of '..intCollected)

        for i = 1, #tFavorites do
            local y = tooltip:AddLine(string.format('|T%s|t', tFavorites[i].mIcon..':16:16:0:0:64:64:4:60:4:60')..' '..tFavorites[i].mName)
            tooltip:SetLineScript(y, 'OnMouseDown', OnMouseDown, tFavorites[i].mID)
        end 
    end

    if (#tFavorites == 0) then
        tooltip:AddLine(mnkLibs.Color(COLOR_GOLD)..'No favorite mounts defined.')
    end

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:UpdateScrolling(500)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkFavoriteMounts:COMPANION_LEARNED()
    self:GetAllMounts()
end

function mnkFavoriteMounts:MOUNT_JOURNAL_USABILITY_CHANGED(event)
    self:GetAllMounts()
end

function mnkFavoriteMounts:PLAYER_ENTERING_WORLD(event, firstTime, reload)
    if firstTime or reload then
        self:GetAllMounts()
    end
end

function mnkFavoriteMounts:PLAYER_LOGIN()
    mnkFavoriteMounts.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkFavoriteMounts', {
        icon = 'Interface\\Icons\\Ability_mount_blackpanther.blp', 
        type = 'data source', 
        OnEnter = function(parent) self:OnEnter(parent) end, 
        OnClick = function() self:OnClick() end  
    })
    mnkFavoriteMounts.LDB.label = 'Favorite Mounts'
end

