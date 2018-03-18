local NAME, ADDON = ...

function truncate(number, decimals)
    return number - (number % (0.1 ^ decimals))
end

function mnkBagsInitSettingsSlider(slider, name, min, max, step, type, setting)
    local value = ADDON.settings:GetSettings(type)[setting]

    _G[slider:GetName() .. 'Text']:SetText(tostring(name) .. ' - ' .. value)
    _G[slider:GetName() .. 'Low']:SetText(tostring(min))
    _G[slider:GetName() .. 'High']:SetText(tostring(max))
    slider:SetMinMaxValues(min, max)
    slider.type = type
    slider.setting = setting
    slider.name = name

    local onChange = slider:GetScript('OnValueChanged')
    slider:SetScript('OnValueChanged', nil)
    slider:SetValue(value)
    slider:SetValueStep(step)
    slider:SetScript('OnValueChanged', onChange)
end

function mnkBagsSettingsSlider_OnChange(self, value)
    if self.setting == "mnkBags_scale" then
        _G[self:GetName() .. 'Text']:SetText(tostring(self.name) .. ' - ' .. truncate(value,1))
        ADDON.settings:SetSettings(self.type, self.setting, truncate(value,1), 1)
    else
        _G[self:GetName() .. 'Text']:SetText(tostring(self.name) .. ' - ' .. floor(value))
        ADDON.settings:SetSettings(self.type, self.setting, floor(value), 1)
    end
end

function mnkBagsInitSettingsColorPicker(picker, type, setting)
    picker.type = type
    picker.setting = setting

    picker:SetBackdropColor(unpack(ADDON.settings:GetSettings(type)[setting]))
end

function mnkBagsSettingsColorPicker_OnClick(self)
    local r, g, b, a = self:GetBackdropColor()

    local function callback(restore)
        local newR, newG, newB, newA = r, g, b, a;
        if not restore then
            newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
        end

        local out = { newR, newG, newB, newA }
        self:SetBackdropColor(unpack(out))

        ADDON.settings:SetSettings(self.type, self.setting, out)
    end

    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, callback, callback;
    ColorPickerFrame:SetColorRGB(r, g, b, a);
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
    ColorPickerFrame.previousValues = { r, g, b, a };
    ShowUIPanel(ColorPickerFrame)
end

function mnkBagsInitSettingsCheckBox(checkbox, name, type, setting, arrangeType)
    checkbox.type = type
    checkbox.setting = setting
    checkbox.arrangeType = arrangeType

    _G[checkbox:GetName() .. "Text"]:SetText(name)

    checkbox:SetChecked(ADDON.settings:GetSettings(type)[setting])
end

function mnkBagsSettingsCheckBox_OnChange(checkbox, checked)
    ADDON.settings:SetSettings(checkbox.type, checkbox.setting, checked, checkbox.arrangeType)
end

function mnkBagsCategoryDialogLoad(id, name)
    mnkBagsCategoryDialog:Show()
    mnkBagsCategoryDialog.name:SetText(string.format(mnkBags_LOCALE_CATEGORY_DIALOG_TITLE, name))
    mnkBagsCategoryDialog.id = id

    local userDefined = ADDON.settings:GetUserDefinedList()
    local globalDefined = ADDON.settings:GetGlobalUserDefinedList()
    local current = userDefined[id] or globalDefined[id]

    if current then
        mnkBagsCategoryDialog.edit:SetText(current)
        mnkBagsCategoryDialog.global:SetChecked(userDefined[id] == nil)
    else
        mnkBagsCategoryDialog.edit:SetText('')
        mnkBagsCategoryDialog.global:SetChecked(false)
    end
    mnkBagsCategoryDialog.edit:SetFocus()

    UIDropDownMenu_Initialize(mnkBagsCategoryDialog.dropdown, function(self, level)
        local unique = {}
        for _, v in pairs(ADDON.settings:GetUserDefinedList()) do
            unique[v] = true
        end
        for _, v in pairs(ADDON.settings:GetGlobalUserDefinedList()) do
            unique[v] = true
        end

        if next(unique) ~= nil then
            local info
            for k, _ in pairs(unique) do
                info = UIDropDownMenu_CreateInfo()
                info.text = k
                info.value = k
                info.func = mnkBagsCategoryDialog_DropDownClick
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
end

function mnkBagsCategoryDialog_DropDownClick(self)
    UIDropDownMenu_SetSelectedID(mnkBagsCategoryDialog.dropdown, self:GetID())
    mnkBagsCategoryDialog.edit:SetText(self.value)
end

function mnkBagsCategoryDialog_Done()
    local global = mnkBagsCategoryDialog.global:GetChecked()
    local text = mnkBagsCategoryDialog.edit:GetText()
    if text and text ~= '' then
        if global then
            ADDON.settings:AddGlobalDefinedItem(mnkBagsCategoryDialog.id, text)
        else
            ADDON.settings:AddUserDefinedItem(mnkBagsCategoryDialog.id, text)
        end
        mnkBagsCategoryDialog:Hide()
    end
end

function mnkBagsCategoryDialog_Clear()
    ADDON.settings:ClearUserDefinedItem(mnkBagsCategoryDialog.id)
    mnkBagsCategoryDialog:Hide()
end

function mnkBagsFormatSettings_OnLoad(self)
    self.box:Show()
end