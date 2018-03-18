local NAME, ADDON = ...

local container = {}

function mnkBagsBankBarLoad(self)
    ADDON:CreateAddon(self, container)
end

function container:Init()
    self.__type = mnkBags_TYPE_BANK_BAR

    table.insert(UISpecialFrames, self:GetName())
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)

    self:SetColors(
        {0, 0, 0, 0.6},
        {0.3, 0.3, 0.3, 1}
    )
end

function container:Update()
    for i = 1, 7 do
        _G[self:GetName() .. 'Bag' .. i]:Update()
    end
end

function container:UpdateFromSettings()
    local settings = ADDON.settings:GetSettings(self.__type)

    self:SetColors(
        settings[mnkBags_SETTING_BACKGROUND_COLOR],
        settings[mnkBags_SETTING_BORDER_COLOR]
    )
end

function container:SetColors(background, border)
    self:SetBackdropColor(unpack(background))
    self:SetBackdropBorderColor(unpack(border))
end
