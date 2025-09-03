local HttpService = game:GetService('HttpService')

local GuiLibrary = {
    Start = function(self, Tab)
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        local Window = Library.CreateLib(Tab.Name .. ' - ' .. game.PlaceId, Tab.Theme)

        self.CreateTab = function(TName: string)
            local Tab = Window:NewTab(TName)

            return {
                CreateModule = function(Table)
                    local ModuleReturn = {
                        Enabled = false,
                        Settings = {},
                        Toggle = function(self, val)
                            self.Enabled = val or not self.Enabled
                            task.spawn(function()
                                local suc, ret = pcall(function()
                                    Table.Function(self.Enabled)
                                end)

                                if not suc then
                                    print('[Error]: ' .. ret)
                                end
                            end)
                        end,
                    }

                    local Section = Tab:NewSection(Table.Name)
                    local Toggle = Section:NewToggle('Toggle', Table.Description, function(callback)
                        ModuleReturn:Toggle(callback)
                    end)
                    local KeybindR = Section:NewKeybind('Keybind', 'press a key to toggle the module', Enum.KeyCode.Ampersand, function()
                        ModuleReturn:Toggle();
                    end)

                    function ModuleReturn.CreateToggle(Toggle)
                        local ToggleReturn = {
                            Enabled = false,
                            Toggle = function(self, val)
                                self.Enabled = not self.Enabled
                                task.spawn(function()
                                    local suc, ret = pcall(function()
                                        Toggle.Function(self.Enabled)
                                    end)

                                    if not suc then
                                        print('[Error]: ' .. ret)
                                    end
                                end)
                            end,
                        }

                        local NewToggle = Section:NewToggle(Toggle.Name, Toggle.Description, function(callback)
                            ToggleReturn:Toggle(callback)
                        end)

                        return ToggleReturn
                    end

                    function ModuleReturn.CreateDropdown(Dropdown)
                        local DropdownReturn = {Value = Dropdown.Default or Dropdown.Options[1]}

                        local NewDropdown = Section:NewDropdown(Dropdown.Name, Dropdown.Description, Dropdown.Options, function(value)
                            DropdownReturn.Value = value
                        end)

                        return DropdownReturn
                    end

                    function ModuleReturn.CreateSlider(Slider)
                        local SliderReturn = {Value = Slider.Default or Slider.Max}

                        local NewSlider = Section:NewSlider(Slider.Name, Slider.Description, Slider.Max, Slider.Min, function(value)
                            SliderReturn.Value = value
                        end)

                        return SliderReturn
                    end

                    function ModuleReturn.CreateKeybind(Keybind)
                        local KeybindReturn = {Bind = 'Unknown'}

                        local NewKeybind = Section:NewKeybind(Keybind.Name, Keybind.Description, Keybind.Default or Enum.KeyCode.Ampersand, function()
                            if Keybind.Function then
                                local suc, ret = pcall(Keybind.Function)

                                if not suc then
                                    print('[Error]: ' .. ret)
                                end
                            end
                        end)

                        return KeybindReturn
                    end

                    function ModuleReturn.CreateColorPicker(ColorPicker)
                        local ColorPickerReturn = {Value = {255,255,255}}

                        local NewColorPicker = Section:NewColorPicker(ColorPicker.Name, ColorPicker.Description, ColorPickerReturn.Value, function(val)
                            ColorPickerReturn.Value = val -- no clue what they return here, ill figure it our when I get home fr
                            if ColorPicker.Function then
                                local suc, ret = pcall(ColorPicker.Function)

                                if not suc then
                                    print('[Error]: ' .. ret)
                                end
                            end
                        end)

                        return ColorPickerReturn
                    end

                    function ModuleReturn.CreateLabel(Label)
                        local NewLabel = Section:NewLabel(Label.Name)
                    end

                    return ModuleReturn
                end,
            }
        end
    end,
}

shared.GuiLibrary = GuiLibrary
