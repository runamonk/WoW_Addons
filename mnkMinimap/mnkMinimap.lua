-- Code based on Zorks rMinimap and rObjectiveTracker.

mnkMinimap = CreateFrame('Frame')

local function Zoom(self, direction)
  if (direction > 0) then 
    Minimap_ZoomIn()
  else 
    Minimap_ZoomOut() 
  end
end

function mnkMinimap:DoOnEvent(event, arg1)
  if event == 'PLAYER_ENTERING_WORLD' then
    mnkMinimap.SetQuestTrackerPosition()
    mnkMinimap.SetMinimapPositionAndSize()
  end
end

function mnkMinimap:SetMinimapPositionAndSize()
  MinimapCluster:SetScale(1)
  MinimapCluster:ClearAllPoints()
  MinimapCluster:SetPoint("CENTER", UIParent, "BOTTOM", 0, 70)
  MinimapCluster:SetSize(135,135) 
  
  Minimap:SetMaskTexture(mnkLibs.Textures.minimap_mask)
  Minimap:ClearAllPoints()
  Minimap:SetPoint("CENTER", UIParent, "BOTTOM", 0, 70)
  Minimap:SetSize(135,135) 
  Minimap:EnableMouseWheel()

  MinimapBackdrop:Hide()
  MinimapBorder:Hide()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  MinimapBorderTop:Hide()
  MiniMapWorldMapButton:Hide()
  MinimapZoneText:Hide()

  MiniMapInstanceDifficulty:ClearAllPoints()
  MiniMapInstanceDifficulty:SetPoint("BOTTOMRIGHT",Minimap,"BOTTOMLEFT", -4, 0)
  MiniMapInstanceDifficulty:SetScale(0.7)
  GuildInstanceDifficulty:ClearAllPoints()
  GuildInstanceDifficulty:SetPoint("BOTTOMRIGHT",Minimap,"BOTTOMLEFT",-4,-5)
  GuildInstanceDifficulty:SetScale(0.7)
  MiniMapChallengeMode:ClearAllPoints()
  MiniMapChallengeMode:SetPoint("BOTTOMRIGHT",Minimap,"BOTTOMLEFT",-4,-10)
  MiniMapChallengeMode:SetScale(0.7)
  
  QueueStatusMinimapButton:SetParent(Minimap)
  QueueStatusMinimapButton:SetScale(1)
  QueueStatusMinimapButton:ClearAllPoints()
  QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, -30, -5)
  QueueStatusMinimapButtonBorder:Hide()
  QueueStatusMinimapButton:SetHighlightTexture (nil)
  QueueStatusMinimapButton:SetPushedTexture(nil)
  
  MiniMapMailFrame:ClearAllPoints()
  MiniMapMailFrame:SetPoint("BOTTOMRIGHT",Minimap, 30, -5)
  MiniMapMailIcon:SetTexture(mnkLibs.Textures.minimap_mail)
  MiniMapMailBorder:SetAlpha(0)
  
  MiniMapTracking:SetParent(Minimap)
  MiniMapTracking:SetScale(1)
  MiniMapTracking:ClearAllPoints()
  MiniMapTracking:SetPoint("TOPLEFT", Minimap, -30, 5)
  MiniMapTrackingButton:SetHighlightTexture (nil)
  MiniMapTrackingButton:SetPushedTexture(nil)
  MiniMapTrackingBackground:Hide()
  MiniMapTrackingButtonBorder:Hide()
 
  LoadAddOn("Blizzard_TimeManager")
  TimeManagerClockButton:GetRegions():Hide()
  TimeManagerClockButton:ClearAllPoints()
  TimeManagerClockButton:SetAlpha(0)
 
  GameTimeFrame:SetParent(Minimap)
  GameTimeFrame:SetScale(0.5)
  GameTimeFrame:ClearAllPoints()
  GameTimeFrame:SetPoint("TOPRIGHT", Minimap, 50, 3)
  GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
  GameTimeFrame:GetNormalTexture():SetTexCoord(0,1,0,1)
  GameTimeFrame:SetNormalTexture(mnkLibs.Textures.minimap_calendar)
  GameTimeFrame:SetPushedTexture(nil)
  GameTimeFrame:SetHighlightTexture(nil)

  local fs = GameTimeFrame:GetFontString()
  fs:ClearAllPoints()
  fs:SetPoint("CENTER",0,-5)
  fs:SetFont(STANDARD_TEXT_FONT,20)
  fs:SetTextColor(0.2,0.2,0.1,0.9)

  Minimap:SetScript("OnMouseWheel", Zoom)
end

function mnkMinimap:SetQuestTrackerPosition()
  ObjectiveTrackerFrame:ClearAllPoints(); 
  ObjectiveTrackerFrame:SetPoint("TOPRIGHT", UIParent, -5, -25);    
  ObjectiveTrackerFrame.SetPoint = mnkLibs.donothing()
  ObjectiveTrackerFrame:SetClampedToScreen(true)
  ObjectiveTrackerFrame:SetMovable(true)
  ObjectiveTrackerFrame:SetUserPlaced(true)
end

mnkMinimap:SetScript('OnEvent', mnkMinimap.DoOnEvent)
mnkMinimap:RegisterEvent("PLAYER_ENTERING_WORLD")