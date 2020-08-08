-- Code based on Zorks rMinimap and rObjectiveTracker.
mnkMinimap = CreateFrame('Frame','mnkMinimap')
mnkMinimap.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkMinimap:RegisterEvent('PLAYER_LOGIN')
mnkMinimap:RegisterEvent('PLAYER_ENTERING_WORLD')
mnkMinimap:RegisterEvent('QUEST_ACCEPTED')
mnkMinimap:RegisterEvent('ZONE_CHANGED')
mnkMinimap:RegisterEvent('ZONE_CHANGED_NEW_AREA')

db = {}

local _, playerClass = UnitClass('player')
local classColor = {}

classColor.r, classColor.g, classColor.b, _ = GetClassColor(playerClass)

local function MinimapZoom(self, direction)
    if (direction > 0) then 
        Minimap_ZoomIn()
    else 
        Minimap_ZoomOut() 
    end
end

function mnkMinimap:FilterQuestTracker()
    local currentMap =  C_Map.GetBestMapForUnit("player")
    if not currentMap then return end
    local mapInfo = C_Map.GetMapInfo(currentMap)
    mnkMinimap.LDB.text = ' '..mapInfo.name

    local function EmptyTracker()
        for i = GetNumQuestWatches(), 1, -1 do
            -- check to see if it's in our list of quests that were auto tracked.
            local x = GetQuestIndexForWatch(i)
            local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(x)

            -- only remove auto-tracked quests.
            local l = mnkLibs.GetIndexInTable(db.autoquests, questID)
            if l > 0 then
                RemoveQuestWatch(GetQuestIndexForWatch(i))
                table.remove(db.autoquests, l)
            end
        end
    end

    local function FillTracker()      
        local questsOnMap = C_QuestLog.GetQuestsOnMap(currentMap)

        for i, info in ipairs(questsOnMap) do
            local x = GetNumQuestWatches()

            if x < MAX_WATCHABLE_QUESTS then
                local idx = GetQuestLogIndexByID(info.questID)
                -- make sure they aren't already tracking it, if they are we don't want to auto remove it.
                if IsQuestWatched(idx) then
                    -- 
                else
                    AddQuestWatch(GetQuestLogIndexByID(info.questID))
               
                    if db.autoquests == nil then
                        db.autoquests = {}
                    end

                    --add quest to list of auto-tracked.
                    if mnkLibs.GetIndexInTable(db.autoquests, info.questID) == 0 then
                        db.autoquests[#db.autoquests+1] = info.questID
                    end                   
                end
            end
        end
    end

    EmptyTracker()
    FillTracker()
end

function mnkMinimap:PLAYER_ENTERING_WORLD()
    mnkMinimap.SetQuestTrackerPosition()
    mnkMinimap.SetMinimapPositionAndSize()
    mnkMinimap.FilterQuestTracker()
end

function mnkMinimap:PLAYER_LOGIN()
    self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkMinimap', {
        icon = 'Interface\\Icons\\ability_spy.blp', 
        type = 'data source', 
        OnClick = function (parent, button) 
                    MiniMapWorldMapButton:Click()
                    --ToggleFrame(WorldMapFrame) 
        end
        })
    self.LDB.label = 'Zone:'   
end

function mnkMinimap:QUEST_ACCEPTED()
    mnkMinimap.FilterQuestTracker()
end

function mnkMinimap:SetMinimapPositionAndSize()
    Minimap:SetMaskTexture(mnkLibs.Textures.minimap_mask)
    Minimap:ClearAllPoints()

    if db.mapPosition then
        Minimap:SetPoint("CENTER", UIParent, "BOTTOMLEFT", db.mapPosition.x, db.mapPosition.y)
    else
        Minimap:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
        db.mapPosition = {}
        db.mapPosition.x, db.mapPosition.y = Minimap:GetCenter()
    end
    
    Minimap:SetSize(135,135) 
    Minimap:EnableMouseWheel()
    Minimap:SetMovable(true)
    Minimap:SetUserPlaced(true)
    Minimap:RegisterForDrag('LeftButton')
    Minimap:SetScript('OnDragStart', function() mnkMinimap:MapDrag(true) end)
    Minimap:SetScript('OnDragStop', function() mnkMinimap:MapDrag(false) end)

    MinimapCluster:SetScale(1)
    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', 0, 0)
    MinimapCluster:EnableMouse(false)
    MinimapCluster:SetMovable(true)

    mnkLibs.createBorder(Minimap, 0, 0, 0, 0, {classColor.r, classColor.g, classColor.b, .5}) 
    MinimapBackdrop:Hide()
    MinimapBorder:Hide()
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    MinimapBorderTop:Hide()
    MiniMapWorldMapButton:Hide()
    MinimapZoneText:Hide()

    MiniMapInstanceDifficulty:ClearAllPoints()
    MiniMapInstanceDifficulty:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -4, 0)
    MiniMapInstanceDifficulty:SetScale(0.7)
    GuildInstanceDifficulty:ClearAllPoints()
    GuildInstanceDifficulty:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT',-4,-5)
    GuildInstanceDifficulty:SetScale(0.7)
    MiniMapChallengeMode:ClearAllPoints()
    MiniMapChallengeMode:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT',-4,-10)
    MiniMapChallengeMode:SetScale(0.7)

    QueueStatusMinimapButton:SetParent(Minimap)
    QueueStatusMinimapButton:SetScale(1)
    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetPoint('TOPLEFT', Minimap, -30, -15)
    QueueStatusMinimapButtonBorder:Hide()
    QueueStatusMinimapButton:SetHighlightTexture (nil)
    QueueStatusMinimapButton:SetPushedTexture(nil)

    MiniMapMailFrame:ClearAllPoints()
    MiniMapMailFrame:SetPoint('BOTTOMRIGHT', Minimap, 30, -5)
    MiniMapMailIcon:SetTexture(mnkLibs.Textures.minimap_mail)
    MiniMapMailBorder:SetAlpha(0)

    MiniMapTracking:SetParent(Minimap)
    MiniMapTracking:SetScale(1)
    MiniMapTracking:ClearAllPoints()
    MiniMapTracking:SetPoint('TOPLEFT', Minimap, -30, 5)
    MiniMapTrackingButton:SetHighlightTexture (nil)
    MiniMapTrackingButton:SetPushedTexture(nil)
    MiniMapTrackingBackground:Hide()
    MiniMapTrackingButtonBorder:Hide()

    LoadAddOn('Blizzard_TimeManager')
    TimeManagerClockButton:GetRegions():Hide()
    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetAlpha(0)

    GameTimeFrame:SetParent(Minimap)
    GameTimeFrame:SetScale(0.5)
    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint('TOPRIGHT', Minimap, 50, 3)
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:GetNormalTexture():SetTexCoord(0,1,0,1)
    GameTimeFrame:SetNormalTexture(mnkLibs.Textures.minimap_calendar)
    GameTimeFrame:SetPushedTexture(nil)
    GameTimeFrame:SetHighlightTexture(nil)
	
	VehicleSeatIndicator:ClearAllPoints()
	VehicleSeatIndicator:SetPoint('TOP', UIParent, 'BOTTOM', 0, 325)
	VehicleSeatIndicator.SetPoint = mnkLibs.donothing()
	
    local fs = GameTimeFrame:GetFontString()
    fs:ClearAllPoints()
    fs:SetPoint('CENTER',0,-5)
    fs:SetFont(STANDARD_TEXT_FONT,20)
    fs:SetTextColor(0.2,0.2,0.1,0.9)

    Minimap:SetScript('OnMouseWheel', MinimapZoom)
end

function mnkMinimap:MapDrag(startDrag)
    if (IsAltKeyDown()) and (startDrag) then
        Minimap.isMoving = true
        Minimap:StartMoving()
    elseif (Minimap.isMoving) or (not IsAltKeyDown()) then
        Minimap.isMoving = false
        Minimap:StopMovingOrSizing()
        db.mapPosition = {}
        db.mapPosition.x, db.mapPosition.y = Minimap:GetCenter()
        Minimap:ClearAllPoints()
        Minimap:SetPoint("CENTER", UIParent, "BOTTOMLEFT", db.mapPosition.x, db.mapPosition.y)
    end
end

function mnkMinimap:SetQuestTrackerPosition()
    ObjectiveTrackerFrame:ClearAllPoints(); 
    ObjectiveTrackerFrame:SetHeight(GetScreenHeight()-(GetScreenHeight()*.25))
    ObjectiveTrackerFrame:SetClampedToScreen(true)
    ObjectiveTrackerFrame:SetMovable(true)
    ObjectiveTrackerFrame:SetUserPlaced(true)
    ObjectiveTrackerFrame:EnableMouse(true)
    ObjectiveTrackerFrame:SetResizable(true)
    ObjectiveTrackerFrame:RegisterForDrag('LeftButton')
    ObjectiveTrackerFrame:ClearAllPoints()

    if db.qtPosition then
        ObjectiveTrackerFrame:SetSize(db.qtSize.width, db.qtSize.height)
        ObjectiveTrackerFrame:SetPoint(db.qtPosition.point.p, db.qtPosition.point.rt, db.qtPosition.point.rp, db.qtPosition.point.x, db.qtPosition.point.y)  
    else
        ObjectiveTrackerFrame:SetPoint('TOPRIGHT', UIParent, -5, -30)
        db.qtPosition = {}
        db.qtPosition.point = {}
        db.qtPosition.point.p, db.qtPosition.point.rt, db.qtPosition.point.rp, db.qtPosition.point.x, db.qtPosition.point.y = ObjectiveTrackerFrame:GetPoint()
        db.qtSize = {}
        db.qtSize.width, db.qtSize.height = ObjectiveTrackerFrame:GetSize()        
    end

    ObjectiveTrackerFrame.ResizeButton = CreateFrame("Button", nil, ObjectiveTrackerFrame, "UIPanelCloseButton")
    ObjectiveTrackerFrame.ResizeButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    ObjectiveTrackerFrame.ResizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    ObjectiveTrackerFrame.ResizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    ObjectiveTrackerFrame.ResizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")        
    ObjectiveTrackerFrame.ResizeButton:ClearAllPoints()
    ObjectiveTrackerFrame.ResizeButton:SetPoint("BOTTOMRIGHT", 2, 0)
    ObjectiveTrackerFrame.ResizeButton:SetSize(12,12)
    ObjectiveTrackerFrame.ResizeButton:Show()
    mnkLibs.setTooltip(ObjectiveTrackerFrame.ResizeButton, 'Resize')
    ObjectiveTrackerFrame.ResizeButton:SetScript('OnMouseDown', function() mnkMinimap:QuestTrackerResize(true) end)
    ObjectiveTrackerFrame.ResizeButton:SetScript('OnMouseUp', function() mnkMinimap:QuestTrackerResize(false) end)
    ObjectiveTrackerFrame:SetScript('OnDragStart', function() mnkMinimap:QuestTrackerDrag(true) end)
    ObjectiveTrackerFrame:SetScript('OnDragStop', function() mnkMinimap:QuestTrackerDrag(false) end)
end

function mnkMinimap:QuestTrackerResize(startResize)
    if startResize then
        ObjectiveTrackerFrame.isResizing = true
        ObjectiveTrackerFrame:StartSizing("BOTTOMRIGHT")
    elseif (ObjectiveTrackerFrame.isResizing) then
        ObjectiveTrackerFrame.isResizing = false
        ObjectiveTrackerFrame:StopMovingOrSizing()
        db.qtSize = {}
        db.qtSize.width, db.qtSize.height = ObjectiveTrackerFrame:GetSize()
        --ObjectiveTrackerFrame:ClearAllPoints()
        ObjectiveTrackerFrame:SetSize(db.qtSize.width, db.qtSize.height)
        ObjectiveTrackerFrame:SetPoint(db.qtPosition.point.p, db.qtPosition.point.rt, db.qtPosition.point.rp, db.qtPosition.point.x, db.qtPosition.point.y)
    end
end

function mnkMinimap:QuestTrackerDrag(startDrag)
    if (IsAltKeyDown()) and (startDrag) then
        ObjectiveTrackerFrame.isMoving = true
        ObjectiveTrackerFrame:StartMoving()
    elseif (ObjectiveTrackerFrame.isMoving) then
        ObjectiveTrackerFrame.isMoving = false
        ObjectiveTrackerFrame:StopMovingOrSizing()
        db.qtPosition = {}
        db.qtPosition.point = {}
        db.qtPosition.point.p, db.qtPosition.point.rt, db.qtPosition.point.rp, db.qtPosition.point.x, db.qtPosition.point.y = ObjectiveTrackerFrame:GetPoint()
    end
end

function mnkMinimap:ZONE_CHANGED()
    mnkMinimap.FilterQuestTracker()
end

function mnkMinimap:ZONE_CHANGED_NEW_AREA()
    mnkMinimap.FilterQuestTracker()
end
