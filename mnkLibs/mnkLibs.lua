local _, ns = ...
oUF = ns.oUF

mnkLibs = CreateFrame('Frame')
mnkLibs.Fonts = {
    oswald  = 'Interface\\AddOns\\mnkLibs\\Fonts\\oswald.ttf', 
    abf     = 'Interface\\AddOns\\mnkLibs\\Fonts\\abf.ttf', 
    ap      = 'Interface\\AddOns\\mnkLibs\\Fonts\\ap.ttf',
    arialn  = 'Fonts\\ARIALN.TTF',
    frizqt = 'Fonts\\FRIZQT__.TTF'
}

local FUIScale = nil

mnkLibs.DefaultTooltipFont = CreateFont("mnkLibsDefaultFont")
mnkLibs.DefaultTooltipFont:SetFont(mnkLibs.Fonts.abf, 14, "")

mnkLibs.Textures = {
    arrow_down          = 'Interface\\AddOns\\mnkLibs\\Assets\\arrow_down',
    arrow_down_pushed   = 'Interface\\AddOns\\mnkLibs\\Assets\\arrow_down_pushed',
    background          = 'Interface\\AddOns\\mnkLibs\\Assets\\background', 
    bar                 = 'Interface\\AddOns\\mnkLibs\\Assets\\bar', 
    border              = 'Interface\\AddOns\\mnkLibs\\Assets\\border', 
    chatframe           = 'Interface\\ChatFrame\\ChatFrameBackground',
    combo_diamond       = 'Interface\\AddOns\\mnkLibs\\Assets\\combo_diamond',
    combo_pentaarrow    = 'Interface\\AddOns\\mnkLibs\\Assets\\combo_pentaarrow',
    combo_round         = 'Interface\\AddOns\\mnkLibs\\Assets\\combo_round',
    icon_new            = 'Interface\\AddOns\\mnkLibs\\Assets\\icon_new', 
    icon_none           = 'Interface\\AddOns\\mnkLibs\\Assets\\icon_none',
    minimap_calendar    = 'Interface\\AddOns\\mnkLibs\\Assets\\minimap_calendar',
    minimap_mail        = 'Interface\\AddOns\\mnkLibs\\Assets\\minimap_mail', 
    minimap_mask        = 'Interface\\AddOns\\mnkLibs\\Assets\\minimap_mask'
}

mnkLibs.Sounds = {
    friend_online       = 'Interface\\AddOns\\mnkLibs\\Assets\\snd_friend_online.ogg', 
    incoming_message    = 'Interface\\AddOns\\mnkLibs\\Assets\\snd_incoming_message.ogg'
}

COLOR_GREEN = {r = 153, g = 255, b = 0}
COLOR_DKGREEN = {r = 250, g = 220, b = 50}
COLOR_WHITE = {r = 255, g = 255, b = 255}
COLOR_GOLD = {r = 255, g = 215, b = 0}
COLOR_YELLOW = {r = 255, g = 245, b = 105}
COLOR_RED = {r = 204, g = 0, b = 0}
COLOR_BLUE = {r = 51, g = 153, b = 255}
COLOR_PURPLE = {r = 128, g = 114, b = 194}
COLOR_GREY = {r = 168, g = 168, b = 168}

function mnkLibs.arrangeAsGrid(parent, buttons, columns, spacing, xOffset, yOffset)
    columns, spacing = columns or 8, spacing or 5
    xOffset, yOffset = xOffset or 0, yOffset or 0
    local width, height = 0, 0
    local col, row = 0, 0

    for i, button in ipairs(buttons) do
        if not button then return end

        if(i == 1) then
            width, height = button:GetSize()
        end

        col = i % columns
        if(col == 0) then col = columns end
        row = math.ceil(i/columns)
        local xPos = (col-1) * (width + spacing)
        local yPos = -1 * (row-1) * (height + spacing)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos+xOffset, yPos+yOffset)
    end

    return columns * (width+spacing)-spacing, row * (height+spacing)-spacing
end

function mnkLibs.Color(t)
    return mnkLibs.convertRGBtoHex(t.r, t.g, t.b)
end

function mnkLibs.convertRGBtoHex(r, g, b)
    r = (r <= 255 and r >= 1 and r) or (r and r > 0 and r < 1 and r * 255) or 1
    g = (g <= 255 and g >= 1 and g) or (g and g > 0 and g < 1 and g * 255) or 1
    b = (b <= 255 and b >= 1 and b) or (b and b > 0 and b < 1 and b * 255) or 1
    return string.format('|cff%02x%02x%02x', r, g, b)
end

function mnkLibs.copyTable(src, dest)
    for index, value in pairs(src) do
        if type(value) == "table" then
            dest[index] = {}
            mnkLibs.copyTable(value, dest[index])
        else
            dest[index] = value
        end
    end
end

function mnkLibs.createBorder(parent, top, bottom, left, right, color)
    parent.border = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    parent.border:SetPoint('TOP', top, top)
    parent.border:SetPoint('BOTTOM', bottom, bottom)
    parent.border:SetPoint('LEFT', left, left)
    parent.border:SetPoint('RIGHT', right, right)
    parent.border:SetBackdrop({ edgeFile = [[Interface\Buttons\WHITE8x8]], edgeSize = mnkLibs.GetPixel() })
    --parent.border:SetBackdropColor(unpack(color))
    parent.border:SetBackdropBorderColor(unpack(color)) 
end

function mnkLibs.createFontString(frame, font, size, outline, layer, shadow, shadowcolor) 
    local fs = frame:CreateFontString(nil, layer or 'OVERLAY')   
    fs:SetFont(font, size, outline)

    if shadow then
        if not shadowcolor then
            shadowcolor = {0, 0, 0, 1}
        end

        --fs:SetShadowColor(shadowcolor)
        fs:SetShadowColor(0, 0, 0, 0)
        fs:SetShadowOffset(1, -1)
    else
        fs:SetShadowColor(0, 0, 0, 0)
        fs:SetShadowOffset(0, 0)
    end
    return fs
end

function mnkLibs.createTexture(self, type, color)
    local t = self:CreateTexture(nil, type)
    self.bgt = t
    t:SetAllPoints(self)
    t:SetColorTexture(unpack(color))
end   

function mnkLibs.donothing()
    return
 end

function mnkLibs.formatNumber(num, places)
    local ret = 0
    local placeValue = ('%%.%df'):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000)..'T'; -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000)..'B'; -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000)..'M'; -- million
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000)..'K'; -- thousand
    else
        ret = num; -- hundreds
    end
    return ret
end

function mnkLibs.formatNumToPercentage(num, places)
    if places == 0 or places == nil then
        return format('%.0f%%', (num * 100))
    else
        return format('%.'..places..'f%%', (num * 100))
    end
end

function mnkLibs.formatMemory(bytes)
    if bytes < 1024 then
        return format('%.2f', bytes)..' kb'
    else
        return format('%.2f', bytes / 1024)..' mb'
    end
end

function mnkLibs.formatPlayerName(fullName)
    if fullName ~= nil then
        local i = string.find(fullName, '-')
        if i ~= nil then
            return string.sub(fullName, 1, i - 1)
        else
            return fullName
        end
    else
        return nil
    end
end

function mnkLibs.formatTime(s)
    local day, hour, minute = 86400, 3600, 60
  
    if s >= day then
      return format('%dd', floor(s/day + 0.5))
    elseif s >= hour then
      return format('%dh', floor(s/hour + 0.5))
    elseif s >= minute then
      return format('%dm', floor(s/minute + 0.5))
    end
    return format('%d', mod(s, minute))
  end

function mnkLibs.GetIndexInTable(table, val)
    if table == nil then
        return 0
    end
    
    for i=1,#table do
        if table[i] == val then
            return i
        end
    end
    return 0
end

function mnkLibs.GetPixel()
    return PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1);
end

function mnkLibs.GetUIScale()
    --local scale = string.match(GetCVar("gxWindowedResolution"), "%d+x(%d+)")  
    -- local uiScale = UIParent:GetScale()
    -- return (768/scale/uiScale)   
    local physicalWidth, physicalHeight = GetPhysicalScreenSize();
    return 768.0 / physicalHeight;
end

function mnkLibs.PrintError(Message)
    UIErrorsFrame:AddMessage(Message, 1.0, 0.0, 0.0)
end

function mnkLibs.Round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

function mnkLibs.setBackdrop(self, bgfile, edgefile, inset_l, inset_r, inset_t, inset_b)

    if not self.SetBackdrop then
        Mixin(self, BackdropTemplateMixin)
    end
    
    self:ClearBackdrop()
    bf = 'Interface\\ChatFrame\\ChatFrameBackground'

    local backdropInfo =
    {
        bgFile = bf,
        edgeFile = edgefile,
        borderColor = {0.1,0.1,0.1,0.6}, 
        edgeSize = 1,
        tile = false, 
        tileSize = 0, 
        insets = {
            left = -inset_l, 
            right = -inset_r, 
            top = -inset_t, 
            bottom = -inset_b }
    } 

    self:SetBackdrop(backdropInfo)
    self:SetBackdropColor(0, 0, 0, 1)
end

function mnkLibs.setTooltip(self, tooltiptext)
    self:SetScript('OnEnter', function (self)
        if(self.tooltipText) then
            GameTooltip:SetOwner(self, self.tooltipAnchor or 'ANCHOR_TOP')
            GameTooltip:SetText(self.tooltipText)
            GameTooltip:Show()
        end
    end)
    self:SetScript('OnLeave', GameTooltip_Hide)
    self.tooltipText = tooltiptext   
end 





        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

       