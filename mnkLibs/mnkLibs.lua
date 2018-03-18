local parent, ns = ...
oUF = ns.oUF

mnkLibs = CreateFrame("Frame")
mnkLibs.Fonts = {
    oswald = "Interface\\AddOns\\mnkLibs\\Fonts\\oswald.ttf",
    abf = "Interface\\AddOns\\mnkLibs\\Fonts\\abf.ttf",
    ap = "Interface\\AddOns\\mnkLibs\\Fonts\\ap.ttf"
}

mnkLibs.Textures = {
    background = "Interface\\AddOns\\mnkLibs\\Assets\\background",
    border = "Interface\\AddOns\\mnkLibs\\Assets\\border",
    bar = "Interface\\AddOns\\mnkLibs\\Assets\\bar",
    edge = "Interface\\AddOns\\mnkLibs\\Assets\\edge"
 }


COLOR_GREEN = {r = 153, g = 255, b = 0}; 
COLOR_WHITE = {r = 255, g = 255, b = 255}; 
COLOR_GOLD = {r = 255, g = 215, b = 0}; 
COLOR_YELLOW = {r = 255, g = 245, b = 105}; 
COLOR_RED = {r = 204, g = 0, b = 0}; 
COLOR_BLUE = {r = 51, g = 153, b = 255}; 
COLOR_PURPLE = {r = 128, g = 114, b = 194}; 
COLOR_GREY = {r = 168, g = 168, b = 168}; 

function PrintError(Message)
    UIErrorsFrame:AddMessage(Message, 1.0, 0.0, 0.0); 
end

function RGBToHex(r, g, b)
    r = r <= 255 and r >= 0 and r or 0; 
    g = g <= 255 and g >= 0 and g or 0; 
    b = b <= 255 and b >= 0 and b or 0; 
    return string.format("|cff%02x%02x%02x", r, g, b); 
end

function Color(t)
    return RGBToHex(t.r, t.g, t.b); 
end

function ToPCT(num)
    return format(TEXT("%.1f%%"), (num * 100)); 
end

function ReadableMemory(bytes)
    if bytes < 1024 then
        return format("%.2f", bytes) .. " kb"; 
    else
        return format("%.2f", bytes / 1024) .. " mb"; 
    end

end

function TruncNumber(num, places)
    local ret = 0; 
    local placeValue = ("%%.%df"):format(places or 0); 
    if not num then
        return 0; 
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. "T"; -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. "B"; -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. "M"; -- million
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000) .. "K"; -- thousand
    else
        ret = num; -- hundreds
    end
    return ret; 
end

function StripServerName(fullName)
    --PrintError(fullName)
    if fullName ~= nil then
        local i = string.find(fullName, "-"); 
        if i ~= nil then
            return string.sub(fullName, 1, i - 1); 
        else
            return fullName; 
        end
    else
        return nil; 
    end
end

function CreateFontString(frame, font, size, outline, layer)
    local fs = frame:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFont(font, size, outline)
    fs:SetShadowColor(0, 0, 0, 1)
    fs:SetShadowOffset(1, -1)
  return fs
end

function CreateDropShadow(frame, point, edge, color)
    local shadow = CreateFrame("Frame", nil, frame)
    shadow:SetFrameLevel(0)
    shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -point, point)
    shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", point, -point)
    shadow:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = mnkLibs.Textures.edge, 
    tile = false,
    tileSize = 32,
    edgeSize = edge,
    insets = {
          left = -edge,
          right = -edge,
          top = -edge,
          bottom = -edge
        }
    })
    shadow:SetBackdropColor(0, 0, 0, 0)
    shadow:SetBackdropBorderColor(unpack(color))
end


function SetBackdrop(self, inset_l, inset_r, inset_t, inset_b)
  self:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
          left = -inset_l,
          right = -inset_r,
          top = -inset_t,
          bottom = -inset_b
        }
  }
  self:SetBackdropColor(0, 0, 0, 1)
end