local Kavo = loadstring(game:HttpGet('https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua'))()
local Window = Kavo.CreateLib('One Shot', 'Ocean')

local GuiLibrary = {
    Tabs = {},
}

for _, value in {
    'Combat',
    'Player',
    'Movement',
    'Render',
    'Misc',
} do
    local Tab = Window:NewTab(value)
    local Section = Tab:NewSection(value)

    GuiLibrary.Tabs[value] = Section
end

shared.GuiLibrary = GuiLibrary;

return GuiLibrary;
