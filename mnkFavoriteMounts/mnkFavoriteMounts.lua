mnkFavoriteMounts = CreateFrame('Frame')
mnkFavoriteMounts.LDB = LibStub:GetLibrary('LibDataBroker-1.1')

local libQTip = LibStub('LibQTip-1.0')
local libAG = LibStub('AceGUI-3.0')

function mnkFavoriteMounts:DoOnEvent(event)
    if event == 'PLAYER_LOGIN' then
        mnkFavoriteMounts.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkFavoriteMountss', {
            icon = 'Interface\\Icons\\Ability_mount_blackpanther.blp', 
            type = 'data source', 
            OnEnter = mnkFavoriteMounts.DoOnEnter, 
            OnClick = mnkFavoriteMounts.DoOnClick
        })

        Hotkey, _ = GetBindingKey('RANDOM_MOUNT')

        mnkFavoriteMounts.LDB.label = 'Favorite Mounts'
    end
end

function mnkFavoriteMounts.DoOnEnter(self)
    local tooltip = libQTip:Acquire('mnkFavoriteMountssToolTip', 1, 'LEFT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    local tblMountIDs = C_MountJournal.GetMountIDs()
    local tblMounts = {}
    local c = 0

    if #tblMountIDs > 0 then
        tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Favorites')
        
        for i = 1, #tblMountIDs do
            local mName, spellID, mIcon, active, isUsable, _, isFavorite, _, _, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(tblMountIDs[i])
            
            if isFavorite == true and isCollected == true and hideOnChar == false then
                c = (c + 1)
                tblMounts[c] = {}
                tblMounts[c].mName = mName
                tblMounts[c].mID = mountID
                tblMounts[c].mIcon = mIcon
            end
        end
        
        local sort_func = function(a, b) return a.mName < b.mName end
        table.sort(tblMounts, sort_func)

        for i = 1, #tblMounts do
            local y = tooltip:AddLine(string.format('|T%s:16|t', tblMounts[i].mIcon)..' '..tblMounts[i].mName)
            tooltip:SetLineScript(y, 'OnMouseDown', mnkFavoriteMounts.DoOnMouseDown, tblMounts[i].mID)
        end 
    end

    if (c == 0) then
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

