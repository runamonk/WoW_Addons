local parent, ns = ...
oUF = ns.oUF

mnkLibs = CreateFrame('Frame')
mnkLibs.Fonts = {
    oswald  = 'Interface\\AddOns\\mnkLibs\\Fonts\\oswald.ttf', 
    abf     = 'Interface\\AddOns\\mnkLibs\\Fonts\\abf.ttf', 
    ap      = 'Interface\\AddOns\\mnkLibs\\Fonts\\ap.ttf'
}

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
    icon_none           = 'Interface\\AddOns\\mnkLibs\\Assets\\icon_none'
}

mnkLibs.Sounds = {
    friend_online       = 'Interface\\AddOns\\mnkLibs\\Assets\\snd_friend_online.ogg', 
    incoming_message    = 'Interface\\AddOns\\mnkLibs\\Assets\\snd_incoming_message.ogg'
}

COLOR_GREEN = {r = 153, g = 255, b = 0}
COLOR_WHITE = {r = 255, g = 255, b = 255}
COLOR_GOLD = {r = 255, g = 215, b = 0}
COLOR_YELLOW = {r = 255, g = 245, b = 105}
COLOR_RED = {r = 204, g = 0, b = 0}
COLOR_BLUE = {r = 51, g = 153, b = 255}
COLOR_PURPLE = {r = 128, g = 114, b = 194}
COLOR_GREY = {r = 168, g = 168, b = 168}

function donothing()
   return
end

function string.color(text, color)
    return "|c"..color..text.."|r"
end

function PrintError(Message)
    UIErrorsFrame:AddMessage(Message, 1.0, 0.0, 0.0)
end

function RGBToHex(r, g, b)
    r = r <= 255 and r >= 0 and r or 0
    g = g <= 255 and g >= 0 and g or 0
    b = b <= 255 and b >= 0 and b or 0
    return string.format('|cff%02x%02x%02x', r, g, b)
end

function round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function QuotedStr(str)
    if str == '' or str == nil then
        return '\'' .. '\''
    else
        return '\''..str..'\''
    end
end

function Color(t)
    return RGBToHex(t.r, t.g, t.b)
end

function ToPCT(num)
    return format(TEXT('%.1f%%'), (num * 100))
end

function ReadableMemory(bytes)
    if bytes < 1024 then
        return format('%.2f', bytes) .. ' kb'
    else
        return format('%.2f', bytes / 1024) .. ' mb'
    end
end

function TruncNumber(num, places)
    local ret = 0
    local placeValue = ('%%.%df'):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. 'T'; -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. 'B'; -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. 'M'; -- million
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000) .. 'K'; -- thousand
    else
        ret = num; -- hundreds
    end
    return ret
end

function StripServerName(fullName)
    --PrintError(fullName)
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

function CreateFontString(frame, font, size, outline, layer, shadow)
    local fs = frame:CreateFontString(nil, layer or 'OVERLAY')   
    fs:SetFont(font, size, outline)
    if shadow then
        fs:SetShadowColor(0, 0, 0, 1)
        fs:SetShadowOffset(1, -1)
    else
        fs:SetShadowColor(0, 0, 0, 0)
        fs:SetShadowOffset(0, 0)
    end
    return fs
end

function CreateDropShadow(frame, point, edge, color)
    local shadow = CreateFrame('Frame', nil, frame)
    shadow:SetFrameLevel(0)
    shadow:SetPoint('TOPLEFT', frame, 'TOPLEFT', -point, point)
    shadow:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', point, -point)
    shadow:SetBackdrop({
        bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', 
        edgeFile = mnkLibs.Textures.border, 
        tile = false, 
        tileSize = 32, 
        edgeSize = edge, 
        insets = {
            left = -edge, 
            right = -edge, 
            top = -edge, 
            bottom = -edge
        }})
    shadow:SetBackdropColor(0, 0, 0, 0)
    shadow:SetBackdropBorderColor(unpack(color))
end

function SetBackdrop(self, bgfile, edgefile, inset_l, inset_r, inset_t, inset_b)
    if not bgFile then
        bgfile = 'Interface\\ChatFrame\\ChatFrameBackground'
    end

    self:SetBackdrop {
        bgFile = bgfile,
        edgeFile = edgefile, 
        edgeSize = 1,
        tile = false, 
        tileSize = 0, 
        insets = {
            left = -inset_l, 
            right = -inset_r, 
            top = -inset_t, 
            bottom = -inset_b
        }}
    self:SetBackdropColor(0, 0, 0, 1)
end

function CreateBorder(parent, top, bottom, left, right, color)
    parent.border = CreateFrame("Frame", nil, parent)
    parent.border:SetPoint('TOP', top, top)
    parent.border:SetPoint('BOTTOM', bottom, bottom)
    parent.border:SetPoint('LEFT', left, left)
    parent.border:SetPoint('RIGHT', right, right)
    parent.border:SetBackdrop({ edgeFile = [[Interface\Buttons\WHITE8x8]], edgeSize = 1 })
    parent.border:SetBackdropBorderColor(unpack(color)) 
end

function CreateBackground(self)
    local t = self:CreateTexture(nil, 'BORDER')
    t:SetAllPoints(self)
    t:SetColorTexture(0, 0, 0)
end       

function Status(unit)
    if (not UnitIsConnected(unit)) then
        return 'Offline'
    elseif (UnitIsGhost(unit)) then
        return 'Ghost'
    elseif (UnitIsDead(unit)) then
        return 'Dead'
    end
end        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

        

       