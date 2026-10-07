--[[
    Kumpulan UI Library Example
    This script demonstrates how to load and use the `kumpulan_ui_library.lua` component system.
]]

-- Usually you would load the library via HTTP:
-- local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AREXANS/kumpulan-ui/main/kumpulan_ui_library.lua"))()

-- For local testing within executor environments, if running locally:
local UI = loadstring(readfile("kumpulan_ui_library.lua"))()

local Window = UI:Window({
    Name = "My Custom Hub",
    Content = "Premium Script",
    Size = UDim2.fromOffset(760, 500),
    Color = Color3.fromRGB(120, 90, 255),
    Keybind = Enum.KeyCode.RightControl,
    Search = true,
})

-- Create a Tab
local MainTab = Window:AddTab({
    Name = "General",
    Icon = "⌂",
})

local SettingsTab = Window:AddTab({
    Name = "Settings",
    Icon = "⚙",
})

-- Create a Section in Main Tab
local CombatSection = MainTab:AddSection({
    Name = "Combat Modifications",
})

-- Add Button
CombatSection:AddButton({
    Name = "Aimbot [OP]",
    Callback = function()
        Window:Notify({
            Title = "Combat System",
            Content = "Aimbot activated successfully.",
        })
    end,
})

-- Add Toggle
local AutoAttackToggle = CombatSection:AddToggle({
    Name = "Auto Attack",
    Default = false,
    Callback = function(Value)
        print("Auto Attack:", Value)
    end,
})

-- Add Slider
CombatSection:AddSlider({
    Name = "Hitbox Expander",
    Min = 1,
    Max = 100,
    Default = 5,
    Rounding = 1,
    Callback = function(Value)
        print("Hitbox size set to:", Value)
    end,
})

-- Create a Section in Settings Tab
local UIConfigSection = SettingsTab:AddSection({
    Name = "User Interface Configuration",
})

-- Add Dropdown
UIConfigSection:AddDropdown({
    Name = "Theme Selection",
    Options = {"Dark", "Light", "Amoled", "Custom"},
    Default = "Dark",
    Callback = function(Value)
        print("Theme changed to:", Value)
    end,
})

-- Add Color Picker
UIConfigSection:AddColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(120, 90, 255),
    Callback = function(Color)
        print("Accent color changed to R:", Color.R, "G:", Color.G, "B:", Color.B)
    end,
})

-- Add Text Input
UIConfigSection:AddTextInput({
    Name = "Webhook URL",
    Default = "",
    Callback = function(Text)
        print("Webhook saved:", Text)
    end,
})

-- Select the first tab automatically upon execution
Window:SelectTab(MainTab)

Window:Notify({
    Title = "Loaded",
    Content = "Kumpulan UI initialized successfully.",
})
