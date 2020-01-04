mnkLockouts = CreateFrame('frame', 'mnkLockouts')
mnkLockouts.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
mnkLockouts:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
mnkLockouts:RegisterEvent('PLAYER_LOGIN')

local t = {}
local LibQTip = LibStub('LibQTip-1.0')

function mnkLockouts:PLAYER_LOGIN()
	self.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkLockouts', {
	    icon = 'Interface\\Icons\\ability_hunter_beastcall02.blp', 
	    type = 'data source', 
	    OnEnter = function (parent) mnkLockouts:OnEnter(parent) end, 
	    OnClick = nil
        })
	self.LDB.label = 'Lockouts'
	self.LDB.text = ' Lockouts'
end

function mnkLockouts:OnEnter(parent)
    local tooltip = LibQTip:Acquire('mnkLockoutsTooltip', 3, 'LEFT', 'RIGHT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()

    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Name', mnkLibs.Color(COLOR_GOLD)..'Progress', mnkLibs.Color(COLOR_GOLD)..'Expiration')
    
	t = {}
	local r = 0
	local c = GetNumSavedInstances()
	local name, id, reset,locked, difficultyName, numEncounters, encounterProgress
	for i=1, c do
		name, _, reset, _, locked, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if locked then
			r = r + 1
			t[r] = {}
			t[r].name = name
			t[r].reset = reset
			t[r].difficulty = difficultyName
			t[r].progress = '['..encounterProgress..'/'..numEncounters..']'
		end
	end

    local sort_func = function(a, b) return a.name < b.name end
    table.sort(t, sort_func)

    for i=1, #t do
    	tooltip:AddLine(t[i].name..' ('..t[i].difficulty..')', t[i].progress, SecondsToTime(t[i].reset))
    end    

    tooltip:SetAutoHideDelay(.1, parent)
    tooltip:SmartAnchorTo(parent)
    tooltip:SetFrameStrata('HIGH')
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    -- tooltip:SetBackdrop(GameTooltip:GetBackdrop())
    -- tooltip:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
    -- tooltip:SetBackdropColor(GameTooltip:GetBackdropColor())
    -- tooltip:SetScale(GameTooltip:GetScale())
    mnkLibs.setBackdrop(tooltip, mnkLibs.Textures.background, nil, 0, 0, 0, 0)
    tooltip:SetBackdropColor(0, 0, 0, 1)    
    tooltip:EnableMouse(true)
    tooltip:Show()
end



