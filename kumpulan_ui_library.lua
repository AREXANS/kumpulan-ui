--[[
    AREXANS UI THEME
    Ready-to-use Roblox UI library.
    Inspired by the structure/style of uixansvd6.lua:
    - Dark compact interface
    - Left navigation / tabs
    - Header + search
    - Sections
    - Buttons, toggles, sliders, dropdowns, keybinds, text inputs, color picker
    - Notifications
    - Theme switching
    - Dragging / toggle key
    - No external icon dependency required

    Usage:
        local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

        local Window = UI:Window({
            Name = "AREXANS",
            Content = "Client",
            Size = UDim2.fromOffset(760, 500),
            Color = Color3.fromRGB(120, 90, 255),
            Keybind = Enum.KeyCode.RightControl,
            Search = true,
        })

        local Main = Window:AddTab({
            Name = "Main",
            Icon = "⌂",
        })

        local Section = Main:AddSection({
            Name = "General",
        })

        Section:AddButton({
            Name = "Test Button",
            Callback = function()
                Window:Notify({
                    Title = "AREXANS",
                    Content = "Button clicked.",
                })
            end,
        })
]]


local function GetImage(filename)
    local url = "https://raw.githubusercontent.com/AREXANS/kumpulan-ui/main/asset/" .. filename
    local folder = "KumpulanUI_Assets"
    if not isfolder(folder) then
        makefolder(folder)
    end
    local filepath = folder .. "/" .. filename
    if not isfile(filepath) then
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success and result then
            writefile(filepath, result)
        else
            warn("Failed to download " .. filename)
            return ""
        end
    end
    local getAsset = getcustomasset or getsynasset
    if getAsset then
        return getAsset(filepath)
    end
    return ""
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function getParent()
    local ok, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
    end)
    if ok and hui then
        return hui
    end
    return CoreGui
end

local Parent = getParent()

local old = Parent:FindFirstChild("AREXANS_CLIENT_UI")
if old then
    old:Destroy()
end

local UI = {}

-- =========================================================
-- THEME
-- =========================================================

UI.Themes = {}

UI.Theme = {
    Name = "AREXANS",
    Accent = Color3.fromRGB(132, 92, 255),
    Background = Color3.fromRGB(8, 8, 13),
    Surface = Color3.fromRGB(14, 16, 22),
    Surface2 = Color3.fromRGB(20, 22, 29),
    Hover = Color3.fromRGB(28, 30, 39),
    Stroke = Color3.fromRGB(45, 48, 58),
    Text = Color3.fromRGB(245, 245, 248),
    Muted = Color3.fromRGB(150, 151, 164),
    Placeholder = Color3.fromRGB(105, 107, 120),
    Success = Color3.fromRGB(90, 210, 125),
    Warning = Color3.fromRGB(245, 190, 80),
    Error = Color3.fromRGB(240, 90, 100),
}

UI.AccentColor = UI.Theme.Accent

function UI:AddTheme(config)
    config = config or {}
    local theme = {}

    for k, v in pairs(self.Theme) do
        theme[k] = v
    end

    for k, v in pairs(config) do
        if theme[k] ~= nil then
            theme[k] = v
        end
    end

    theme.Name = config.Name or "Custom"
    self.Themes[theme.Name] = theme
    self:SetTheme(theme)
    return theme
end

function UI:SetTheme(theme)
    if typeof(theme) == "string" then
        theme = self.Themes[theme]
    end
    if typeof(theme) ~= "table" then
        return self
    end

    for k, v in pairs(theme) do
        if self.Theme[k] ~= nil then
            self.Theme[k] = v
        end
    end

    self.AccentColor = self.Theme.Accent

    if self._themeCallbacks then
        for _, callback in ipairs(self._themeCallbacks) do
            pcall(callback, self.Theme)
        end
    end

    return self
end

UI._themeCallbacks = {}

function UI:_onThemeChanged(callback)
    table.insert(self._themeCallbacks, callback)
end

-- =========================================================
-- HELPERS
-- =========================================================

local function tween(object, duration, properties)
    if not object or not object.Parent then
        return
    end
    local t = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 7)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency == nil and 0.35 or transparency
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function padding(parent, left, top, right, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = parent
    return p
end

local function makeText(parent, text, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(text or "")
    label.TextColor3 = color or UI.Theme.Text
    label.TextSize = size or 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function inputButton(parent)
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Size = UDim2.fromScale(1, 1)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    return b
end

local function iconText(parent, text, size)
    local l = makeText(parent, text, size or 15, UI.Theme.Muted)
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.TextYAlignment = Enum.TextYAlignment.Center
    return l
end

local function normalizeKey(key)
    if typeof(key) == "EnumItem" then
        return key
    end
    if type(key) == "string" then
        local ok, result = pcall(function()
            return Enum.KeyCode[key]
        end)
        if ok and result then
            return result
        end
    end
    return Enum.KeyCode.RightControl
end

-- =========================================================
-- SCREEN GUI
-- =========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AREXANS_CLIENT_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = Parent

UI.ScreenGui = ScreenGui

-- =========================================================
-- NOTIFICATIONS
-- =========================================================

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "Notifications"
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.AnchorPoint = Vector2.new(1, 0)
NotificationHolder.Position = UDim2.new(1, -18, 0, 18)
NotificationHolder.Size = UDim2.fromOffset(340, 500)
NotificationHolder.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.Padding = UDim.new(0, 7)
NotificationLayout.Parent = NotificationHolder

function UI:Notify(config)
    config = config or {}
    local title = tostring(config.Title or "AREXANS")
    local content = tostring(config.Content or config.Text or "")
    local duration = tonumber(config.Duration) or 4

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Surface2
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.fromOffset(310, 58)
    frame.ClipsDescendants = true
    frame.Parent = NotificationHolder
    corner(frame, 9)
    local st = stroke(frame, self.Theme.Stroke, 1)

    local accent = Instance.new("Frame")
    accent.BackgroundColor3 = self.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.Parent = frame
    corner(accent, 9)

    local titleLabel = makeText(frame, title, 13, self.Theme.Text)
    titleLabel.Position = UDim2.fromOffset(17, 8)
    titleLabel.Size = UDim2.new(1, -28, 0, 17)

    local contentLabel = makeText(frame, content, 11, self.Theme.Muted)
    contentLabel.Position = UDim2.fromOffset(17, 28)
    contentLabel.Size = UDim2.new(1, -28, 0, 20)
    contentLabel.TextWrapped = true

    tween(frame, 0.18, {BackgroundTransparency = 0.04})
    tween(st, 0.18, {Transparency = 0.45})

    task.delay(duration, function()
        if not frame.Parent then
            return
        end
        tween(frame, 0.18, {BackgroundTransparency = 1})
        tween(st, 0.18, {Transparency = 1})
        task.wait(0.2)
        if frame.Parent then
            frame:Destroy()
        end
    end)

    return frame
end

-- =========================================================
-- WINDOW
-- =========================================================

function UI:CreateWindow(config)
    config = config or {}

    local Window = {
        Name = tostring(config.Name or config.Title or "AREXANS"),
        Content = tostring(config.Content or "Client"),
        Keybind = normalizeKey(config.Keybind or "RightControl"),
        Tabs = {},
        CurrentTab = nil,
        Destroyed = false,
    }

    local size = config.Size
    if typeof(size) ~= "UDim2" then
        size = UDim2.fromOffset(760, 500)
    end

    local accent = config.Color
    if typeof(accent) == "Color3" then
        self.Theme.Accent = accent
        self.AccentColor = accent
    end

    local root = Instance.new("ImageLabel")
    root.Name = "Window"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.fromOffset(0, 0)
    root.BackgroundTransparency = 1
    root.Image = GetImage("background_ui.png")
    root.ScaleType = Enum.ScaleType.Slice
    root.SliceCenter = Rect.new(12, 12, 12, 12)
    root.BackgroundColor3 = self.Theme.Background
    root.BorderSizePixel = 0
    root.ClipsDescendants = true
    root.Active = true
    root.Parent = ScreenGui
    Window.Root = root
    corner(root, 11)
    local rootStroke = stroke(root, self.Theme.Stroke, 0.15, 1)

    -- top accent line
    local topAccent = Instance.new("Frame")
    topAccent.BackgroundColor3 = self.Theme.Accent
    topAccent.BorderSizePixel = 0
    topAccent.Size = UDim2.new(1, 0, 0, 2)
    topAccent.Parent = root

    -- left navigation
    local sidebar = Instance.new("ImageLabel")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.Image = GetImage("frame_and_Background.png")
    sidebar.ScaleType = Enum.ScaleType.Slice
    sidebar.SliceCenter = Rect.new(12, 12, 12, 12)
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(0, 190, 1, 0)
    sidebar.Parent = root
    Window.Sidebar = sidebar

    local profileFrame = Instance.new("ImageLabel")
    profileFrame.BackgroundTransparency = 1
    profileFrame.Image = GetImage("frame_profile.png")
    profileFrame.ScaleType = Enum.ScaleType.Slice
    profileFrame.SliceCenter = Rect.new(12, 12, 12, 12)
    profileFrame.Size = UDim2.fromOffset(160, 45)
    profileFrame.Position = UDim2.new(0, 15, 1, -60)
    profileFrame.Parent = sidebar

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.BackgroundTransparency = 1
    profileIcon.Image = GetImage("humanoid.png")
    profileIcon.ScaleType = Enum.ScaleType.Slice
    profileIcon.SliceCenter = Rect.new(12, 12, 12, 12)
    profileIcon.Size = UDim2.fromOffset(30, 30)
    profileIcon.Position = UDim2.fromOffset(8, 7)
    profileIcon.Parent = profileFrame

    local profileName = makeText(profileFrame, LocalPlayer and LocalPlayer.Name or "User", 12, self.Theme.Text)
    profileName.Position = UDim2.fromOffset(45, 15)
    profileName.Size = UDim2.new(1, -55, 0, 15)
    profileName.TextXAlignment = Enum.TextXAlignment.Left



    -- logo / title
    local brand = Instance.new("Frame")
    brand.BackgroundTransparency = 1
    brand.Position = UDim2.fromOffset(12, 10)
    brand.Size = UDim2.new(1, -24, 0, 42)
    brand.Parent = sidebar

    local brandMark = Instance.new("ImageLabel")
    brandMark.BackgroundTransparency = 1
    brandMark.Image = GetImage("icon.png")
    brandMark.ScaleType = Enum.ScaleType.Slice
    brandMark.SliceCenter = Rect.new(12, 12, 12, 12)
    brandMark.Size = UDim2.fromOffset(32, 32)
    brandMark.Position = UDim2.fromOffset(0, 2)
    brandMark.Parent = brand
    corner(brandMark, 8)



    local brandTitle = makeText(brand, Window.Name, 14, self.Theme.Text)
    brandTitle.Position = UDim2.fromOffset(42, 2)
    brandTitle.Size = UDim2.new(1, -42, 0, 18)

    local brandContent = makeText(brand, Window.Content, 10, self.Theme.Muted)
    brandContent.Position = UDim2.fromOffset(42, 20)
    brandContent.Size = UDim2.new(1, -42, 0, 15)

    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = self.Theme.Stroke
    divider.BackgroundTransparency = 0.4
    divider.BorderSizePixel = 0
    divider.Position = UDim2.fromOffset(10, 57)
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Parent = sidebar

    -- search
    local searchFrame = Instance.new("Frame")
    searchFrame.BackgroundColor3 = self.Theme.Surface2
    searchFrame.Position = UDim2.fromOffset(9, 67)
    searchFrame.Size = UDim2.new(1, -18, 0, 29)
    searchFrame.Visible = config.Search ~= false
    searchFrame.Parent = sidebar
    corner(searchFrame, 6)
    stroke(searchFrame, self.Theme.Stroke, 0.55)

    local searchIcon = Instance.new("ImageLabel", searchFrame)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = GetImage("search.png")
    searchIcon.ScaleType = Enum.ScaleType.Slice
    searchIcon.SliceCenter = Rect.new(12, 12, 12, 12)
    searchIcon.Position = UDim2.fromOffset(5, 0)
    searchIcon.Size = UDim2.fromOffset(22, 29)

    local searchBox = Instance.new("TextBox")
    searchBox.BackgroundTransparency = 1
    searchBox.ClearTextOnFocus = false
    searchBox.Position = UDim2.fromOffset(28, 0)
    searchBox.Size = UDim2.new(1, -32, 1, 0)
    searchBox.Font = Enum.Font.GothamBold
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = self.Theme.Placeholder
    searchBox.TextColor3 = self.Theme.Text
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchFrame

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "Tabs"
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.Position = UDim2.fromOffset(7, config.Search == false and 67 or 103)
    tabScroll.Size = UDim2.new(1, -14, 1, -113)
    tabScroll.ScrollBarThickness = 2
    tabScroll.ScrollBarImageColor3 = self.Theme.Accent
    tabScroll.CanvasSize = UDim2.new()
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 3)
    tabLayout.Parent = tabScroll

    -- right side
    local contentRoot = Instance.new("Frame")
    contentRoot.Name = "Content"
    contentRoot.BackgroundTransparency = 1
    contentRoot.Position = UDim2.new(0, 190, 0, 0)
    contentRoot.Size = UDim2.new(1, -190, 1, 0)
    contentRoot.Parent = root

    local header = Instance.new("Frame")
    header.BackgroundColor3 = self.Theme.Surface
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Parent = contentRoot

    local headerTitle = makeText(header, Window.Name, 15, self.Theme.Text)
    headerTitle.Position = UDim2.fromOffset(15, 7)
    headerTitle.Size = UDim2.new(1, -75, 0, 20)

    local headerSub = makeText(header, Window.Content, 10, self.Theme.Muted)
    headerSub.Position = UDim2.fromOffset(15, 27)
    headerSub.Size = UDim2.new(1, -75, 0, 14)

    local close = Instance.new("TextButton")
    close.BackgroundTransparency = 1
    close.BorderSizePixel = 0
    close.Position = UDim2.new(1, -40, 0, 8)
    close.Size = UDim2.fromOffset(30, 30)
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextColor3 = self.Theme.Muted
    close.TextSize = 21
    close.AutoButtonColor = false
    close.Parent = header

    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "Pages"
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.Position = UDim2.fromOffset(0, 50)
    contentScroll.Size = UDim2.new(1, 0, 1, -50)
    contentScroll.ScrollBarThickness = 2
    contentScroll.ScrollBarImageColor3 = self.Theme.Accent
    contentScroll.Parent = contentRoot

    Window.Pages = contentScroll

    local pageLayout = Instance.new("UIPageLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.EasingStyle = Enum.EasingStyle.Quint
    pageLayout.EasingDirection = Enum.EasingDirection.Out
    pageLayout.TweenTime = 0.18
    pageLayout.Padding = UDim.new(0, 0)
    pageLayout.Parent = contentScroll
    Window.PageLayout = pageLayout

    -- dragging
    local dragging = false
    local dragStart
    local startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    close.MouseEnter:Connect(function()
        tween(close, 0.12, {TextColor3 = self.Theme.Error})
    end)
    close.MouseLeave:Connect(function()
        tween(close, 0.12, {TextColor3 = self.Theme.Muted})
    end)
    close.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    -- search tabs
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for _, tab in ipairs(Window.Tabs) do
            local visible = q == "" or string.find(string.lower(tab.Name), q, 1, true) ~= nil
            tab.Button.Visible = visible
        end
    end)

    -- theme refresh
    local function refreshTheme()
        root.BackgroundTransparency = 1
    root.Image = GetImage("background_ui.png")
    root.ScaleType = Enum.ScaleType.Slice
    root.SliceCenter = Rect.new(12, 12, 12, 12)
    root.BackgroundColor3 = self.Theme.Background
        -- sidebar uses image
        header.BackgroundColor3 = self.Theme.Surface
        topAccent.BackgroundColor3 = self.Theme.Accent
        rootStroke.Color = self.Theme.Stroke
        searchFrame.BackgroundColor3 = self.Theme.Surface2
        searchBox.TextColor3 = self.Theme.Text
        searchBox.PlaceholderColor3 = self.Theme.Placeholder
        tabScroll.ScrollBarImageColor3 = self.Theme.Accent
        contentScroll.ScrollBarImageColor3 = self.Theme.Accent
        brandMark.BackgroundTransparency = 1
        brandMark.Image = GetImage("icon.png")
        brandMark.ScaleType = Enum.ScaleType.Slice
        brandMark.SliceCenter = Rect.new(12, 12, 12, 12)
        headerTitle.TextColor3 = self.Theme.Text
        headerSub.TextColor3 = self.Theme.Muted
        brandTitle.TextColor3 = self.Theme.Text
        brandContent.TextColor3 = self.Theme.Muted
        close.TextColor3 = self.Theme.Muted
    end

    self:_onThemeChanged(refreshTheme)

    function Window:SelectTab(tab)
        if typeof(tab) == "number" then
            tab = self.Tabs[tab]
        end
        if not tab then return self end

        for _, t in ipairs(self.Tabs) do
            t:SetSelected(t == tab)
        end

        self.CurrentTab = tab
        pcall(function()
            pageLayout:JumpTo(tab.Page)
        end)

        return self
    end

    function Window:Toggle()
        if self.Destroyed then return self end
        local visible = root.Visible
        if visible then
            tween(root, 0.16, {
                Size = UDim2.fromOffset(math.max(1, size.X.Offset - 18), math.max(1, size.Y.Offset - 18)),
                BackgroundTransparency = 1,
            })
            task.delay(0.17, function()
                if root.Parent then root.Visible = false end
            end)
        else
            root.Visible = true
            root.BackgroundTransparency = 0
            tween(root, 0.18, {Size = size, BackgroundTransparency = 1})
        end
        return self
    end

    function Window:SetVisible(value)
        value = value == true
        root.Visible = value
        if value then
            root.Size = size
            root.BackgroundTransparency = 0
        else
            root.Visible = false
        end
        return self
    end

    function Window:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        if root.Parent then
            tween(root, 0.16, {
                Size = UDim2.fromOffset(math.max(1, size.X.Offset - 18), math.max(1, size.Y.Offset - 18)),
                BackgroundTransparency = 1,
            })
            task.delay(0.18, function()
                if root.Parent then
                    root:Destroy()
                end
            end)
        end
    end

    -- =====================================================
    -- TAB
    -- =====================================================

    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        if type(tabConfig) == "string" then
            tabConfig = {Name = tabConfig}
        end

        local Tab = {
            Name = tostring(tabConfig.Name or tabConfig.Title or ("Tab " .. (#self.Tabs + 1))),
            Icon = tostring(tabConfig.Icon or "•"),
            Sections = {},
        }

        local button = Instance.new("ImageLabel")
        button.BackgroundTransparency = 1
        button.Image = GetImage("button1.png")
        button.ScaleType = Enum.ScaleType.Slice
        button.SliceCenter = Rect.new(12, 12, 12, 12)
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, 0, 0, 35)
        button.Parent = tabScroll
        Tab.Button = button

        local icon = iconText(button, Tab.Icon, 15)
        icon.Position = UDim2.fromOffset(8, 0)
        icon.Size = UDim2.fromOffset(25, 35)
        Tab.IconLabel = icon

        local label = makeText(button, Tab.Name, 11, self.Theme.Muted)
        label.Position = UDim2.fromOffset(38, 0)
        label.Size = UDim2.new(1, -42, 1, 0)
        Tab.Label = label

        local selected = Instance.new("Frame")
        selected.BackgroundColor3 = self.Theme.Accent
        selected.BorderSizePixel = 0
        selected.Position = UDim2.fromOffset(0, 5)
        selected.Size = UDim2.fromOffset(3, 25)
        selected.Visible = false
        selected.Parent = button
        corner(selected, 3)
        Tab.SelectedBar = selected

        local click = inputButton(button)
        click.MouseEnter:Connect(function()
            if self.ActiveTab ~= Tab then
                button.Image = GetImage("button2.png")
                button.ScaleType = Enum.ScaleType.Slice
                button.SliceCenter = Rect.new(12, 12, 12, 12)
            end
        end)
        click.MouseLeave:Connect(function()
            if self.ActiveTab ~= Tab then
                button.Image = GetImage("button1.png")
                button.ScaleType = Enum.ScaleType.Slice
                button.SliceCenter = Rect.new(12, 12, 12, 12)
            end
        end)

        local page = Instance.new("Frame")
        page.Name = Tab.Name
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.LayoutOrder = #self.Tabs + 1
        page.Parent = contentScroll
        Tab.Page = page

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.Position = UDim2.fromOffset(12, 10)
        pageScroll.Size = UDim2.new(1, -24, 1, -20)
        pageScroll.ScrollBarThickness = 2
        pageScroll.ScrollBarImageColor3 = self.Theme.Accent
        pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pageScroll.CanvasSize = UDim2.new()
        pageScroll.Parent = page
        Tab.Scroll = pageScroll

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = pageScroll
        Tab.Layout = layout

        function Tab:SetSelected(value)
            value = value == true
            selected.Visible = value
            if value then
                tween(button, 0.12, {BackgroundTransparency = 0.35})
                tween(label, 0.12, {TextColor3 = UI.Theme.Text})
                tween(icon, 0.12, {TextColor3 = UI.Theme.Accent})
            else
                tween(button, 0.12, {BackgroundTransparency = 1})
                tween(label, 0.12, {TextColor3 = UI.Theme.Muted})
                tween(icon, 0.12, {TextColor3 = UI.Theme.Muted})
            end
        end

        click.MouseEnter:Connect(function()
            if self.CurrentTab ~= Tab then
                tween(button, 0.12, {BackgroundTransparency = 0.7})
            end
        end)

        click.MouseLeave:Connect(function()
            if self.CurrentTab ~= Tab then
                tween(button, 0.12, {BackgroundTransparency = 1})
            end
        end)

        click.MouseButton1Click:Connect(function()
            self:SelectTab(Tab)
        end)

        function Tab:AddSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            if type(sectionConfig) == "string" then
                sectionConfig = {Name = sectionConfig}
            end

            local Section = {
                Name = tostring(sectionConfig.Name or "SECTION"),
                Controls = {},
            }

            local frame = Instance.new("ImageLabel")
            frame.BackgroundTransparency = 1
            frame.Image = GetImage("frame_ui.png")
            frame.ScaleType = Enum.ScaleType.Slice
            frame.SliceCenter = Rect.new(12, 12, 12, 12)
            frame.BorderSizePixel = 0
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.Parent = pageScroll
            corner(frame, 9)
            local frameStroke = stroke(frame, UI.Theme.Stroke, 0.55)

            local title = makeText(frame, Section.Name, 11, UI.Theme.Text)
            title.Position = UDim2.fromOffset(12, 9)
            title.Size = UDim2.new(1, -24, 0, 18)

            local accentLine = Instance.new("Frame")
            accentLine.BackgroundColor3 = UI.Theme.Accent
            accentLine.BorderSizePixel = 0
            accentLine.Position = UDim2.fromOffset(12, 29)
            accentLine.Size = UDim2.fromOffset(26, 2)
            accentLine.Parent = frame
            corner(accentLine, 2)

            local holder = Instance.new("Frame")
            holder.BackgroundTransparency = 1
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.Position = UDim2.fromOffset(10, 38)
            holder.Size = UDim2.new(1, -20, 0, 0)
            holder.Parent = frame

            local holderLayout = Instance.new("UIListLayout")
            holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
            holderLayout.Padding = UDim.new(0, 5)
            holderLayout.Parent = holder

            padding(frame, 0, 0, 0, 10)

            Section.Root = frame
            Section.Holder = holder
            Section.Layout = holderLayout

            function Section:AddLabel(text)
                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 27)
                row.Parent = holder

                local lbl = makeText(row, tostring(text or ""), 11, UI.Theme.Muted)
                lbl.Position = UDim2.fromOffset(4, 0)
                lbl.Size = UDim2.new(1, -8, 1, 0)

                local item = {
                    Root = row,
                    Label = lbl,
                }

                function item:SetText(value)
                    lbl.Text = tostring(value or "")
                    return item
                end

                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddParagraph(config)
                config = config or {}
                local titleText = tostring(config.Title or config.Name or "")
                local bodyText = tostring(config.Content or config.Text or "")

                local row = Instance.new("Frame")
                row.BackgroundColor3 = UI.Theme.Surface2
                row.BackgroundTransparency = 0.2
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.Size = UDim2.new(1, 0, 0, 45)
                row.Parent = holder
                corner(row, 6)

                local t = makeText(row, titleText, 11, UI.Theme.Text)
                t.Position = UDim2.fromOffset(9, 7)
                t.Size = UDim2.new(1, -18, 0, 16)

                local b = makeText(row, bodyText, 10, UI.Theme.Muted)
                b.Position = UDim2.fromOffset(9, 25)
                b.Size = UDim2.new(1, -18, 0, 0)
                b.AutomaticSize = Enum.AutomaticSize.Y
                b.TextWrapped = true

                padding(row, 0, 0, 0, 7)

                local item = {Root = row, Title = t, Content = b}
                function item:SetTitle(value)
                    t.Text = tostring(value or "")
                    return item
                end
                function item:SetContent(value)
                    b.Text = tostring(value or "")
                    return item
                end
                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddButton(config)
                config = config or {}
                local name = tostring(config.Name or config.Title or "Button")
                local callback = config.Callback or config.Function or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.BorderSizePixel = 0
                row.Size = UDim2.new(1, 0, 0, 36)
                row.Parent = holder
                corner(row, 6)
                local rs = stroke(row, UI.Theme.Stroke, 0.6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 0)
                label.Size = UDim2.new(1, -42, 1, 0)

                local arrow = makeText(row, "›", 18, UI.Theme.Muted)
                arrow.Position = UDim2.new(1, -31, 0, 0)
                arrow.Size = UDim2.fromOffset(24, 36)
                arrow.TextXAlignment = Enum.TextXAlignment.Center

                local click = inputButton(row)
                click.MouseEnter:Connect(function()
                    row.Image = GetImage("button2.png")
                    row.ScaleType = Enum.ScaleType.Slice
                    row.SliceCenter = Rect.new(12, 12, 12, 12)
                    tween(rs, 0.12, {Transparency = 0.25})
                    tween(arrow, 0.12, {TextColor3 = UI.Theme.Accent})
                end)
                click.MouseLeave:Connect(function()
                    row.Image = GetImage("button1.png")
                    row.ScaleType = Enum.ScaleType.Slice
                    row.SliceCenter = Rect.new(12, 12, 12, 12)
                    tween(rs, 0.12, {Transparency = 0.6})
                    tween(arrow, 0.12, {TextColor3 = UI.Theme.Muted})
                end)
                click.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)

                local item = {Root = row, Label = label}
                function item:SetText(value)
                    label.Text = tostring(value or "")
                    return item
                end
                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddToggle(config)
                config = config or {}
                local name = tostring(config.Name or "Toggle")
                local value = config.Default == true
                local callback = config.Callback or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.Size = UDim2.new(1, 0, 0, 36)
                row.Parent = holder
                corner(row, 6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 0)
                label.Size = UDim2.new(1, -65, 1, 0)

                local switch = Instance.new("ImageLabel")
                switch.BackgroundTransparency = 1
                switch.AnchorPoint = Vector2.new(1, 0.5)
                switch.Position = UDim2.new(1, -10, 0.5, 0)
                switch.Size = UDim2.fromOffset(36, 20)
                switch.Image = value and GetImage("on.png") or GetImage("off.png")
                switch.BorderSizePixel = 0
                switch.Parent = row

                local click = inputButton(row)

                local item = {Root = row, Value = value}

                function item:SetValue(v, fire)
                    value = v == true
                    item.Value = value
                    switch.Image = value and GetImage("on.png") or GetImage("off.png")
                    if fire ~= false then
                        pcall(callback, value)
                    end
                    return item
                end

                function item:GetValue()
                    return value
                end

                click.MouseButton1Click:Connect(function()
                    item:SetValue(not value)
                end)

                item:SetValue(value, false)
                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddSlider(config)
                config = config or {}
                local name = tostring(config.Name or "Slider")
                local min = tonumber(config.Min) or 0
                local max = tonumber(config.Max) or 100
                local value = math.clamp(tonumber(config.Default) or min, min, max)
                local rounding = tonumber(config.Rounding)
                local callback = config.Callback or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.Size = UDim2.new(1, 0, 0, 54)
                row.Parent = holder
                corner(row, 6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 6)
                label.Size = UDim2.new(1, -80, 0, 17)

                local valueLabel = makeText(row, "", 10, UI.Theme.Muted)
                valueLabel.Position = UDim2.new(1, -65, 0, 6)
                valueLabel.Size = UDim2.fromOffset(54, 17)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right

                local bar = Instance.new("ImageLabel")
                bar.BackgroundTransparency = 1
                bar.Image = GetImage("shape_horizontal1.png")
                bar.ScaleType = Enum.ScaleType.Slice
                bar.SliceCenter = Rect.new(12, 12, 12, 12)
                bar.Position = UDim2.fromOffset(11, 34)
                bar.Size = UDim2.new(1, -22, 0, 6)
                bar.Parent = row
                corner(bar, 4)

                local fill = Instance.new("ImageLabel")
                fill.BackgroundTransparency = 1
                fill.Image = GetImage("shape_horizontal2.png")
                fill.ScaleType = Enum.ScaleType.Slice
                fill.SliceCenter = Rect.new(12, 12, 12, 12)
                fill.Size = UDim2.fromScale(0, 1)
                fill.Parent = bar
                corner(fill, 4)

                local knob = Instance.new("ImageLabel")
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.BackgroundTransparency = 1
                knob.Image = GetImage("shape_horizontal3.png")
                knob.ScaleType = Enum.ScaleType.Slice
                knob.SliceCenter = Rect.new(12, 12, 12, 12)
                knob.Size = UDim2.fromOffset(12, 12)
                knob.Parent = bar
                corner(knob, 8)

                local hit = inputButton(row)

                local item = {Root = row, Value = value}

                local function formatValue(v)
                    if rounding ~= nil then
                        local p = 10 ^ rounding
                        v = math.floor(v * p + 0.5) / p
                    end
                    return tostring(v)
                end

                local function setFromX(x, fire)
                    local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
                    value = min + ((max - min) * ratio)
                    item.Value = value

                    local r = math.clamp((value - min) / math.max(0.0001, max - min), 0, 1)
                    fill.Size = UDim2.fromScale(r, 1)
                    knob.Position = UDim2.new(r, 0, 0.5, 0)
                    valueLabel.Text = formatValue(value)

                    if fire ~= false then
                        pcall(callback, value)
                    end
                end

                function item:SetValue(v, fire)
                    v = tonumber(v) or min
                    value = math.clamp(v, min, max)
                    setFromX(bar.AbsolutePosition.X + ((value - min) / math.max(0.0001, max - min)) * bar.AbsoluteSize.X, fire)
                    return item
                end

                function item:GetValue()
                    return value
                end

                local slide = false
                hit.MouseButton1Down:Connect(function()
                    slide = true
                    setFromX(UIS:GetMouseLocation().X)
                end)
                UIS.InputChanged:Connect(function(input)
                    if slide and input.UserInputType == Enum.UserInputType.MouseMovement then
                        setFromX(input.Position.X)
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        slide = false
                    end
                end)

                item:SetValue(value, false)
                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddDropdown(config)
                config = config or {}
                local name = tostring(config.Name or "Dropdown")
                local options = config.Options or config.Values or {}
                local current = config.Default
                local callback = config.Callback or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.Size = UDim2.new(1, 0, 0, 54)
                row.Parent = holder
                corner(row, 6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 6)
                label.Size = UDim2.new(1, -22, 0, 16)

                local selectFrame = Instance.new("ImageLabel")
                selectFrame.BackgroundTransparency = 1
                selectFrame.Image = GetImage("dropdown_before.png")
                selectFrame.ScaleType = Enum.ScaleType.Slice
                selectFrame.SliceCenter = Rect.new(12, 12, 12, 12)
                selectFrame.Position = UDim2.fromOffset(9, 27)
                selectFrame.Size = UDim2.new(1, -18, 0, 21)
                selectFrame.Parent = row
                corner(selectFrame, 5)
                stroke(selectFrame, UI.Theme.Stroke, 0.55)

                local valueLabel = makeText(selectFrame, "", 10, UI.Theme.Muted)
                valueLabel.Position = UDim2.fromOffset(8, 0)
                valueLabel.Size = UDim2.new(1, -30, 1, 0)

                local arrow = makeText(selectFrame, "⌄", 13, UI.Theme.Muted)
                arrow.Position = UDim2.new(1, -25, 0, 0)
                arrow.Size = UDim2.fromOffset(20, 21)
                arrow.TextXAlignment = Enum.TextXAlignment.Center

                local popup = Instance.new("ImageLabel")
                popup.BackgroundTransparency = 1
                popup.Image = GetImage("dropdown_after.png")
                popup.ScaleType = Enum.ScaleType.Slice
                popup.SliceCenter = Rect.new(12, 12, 12, 12)
                popup.BorderSizePixel = 0
                popup.Visible = false
                popup.ZIndex = 100
                popup.Parent = ScreenGui
                corner(popup, 6)
                stroke(popup, UI.Theme.Stroke, 0.35)
                local popupLayout = Instance.new("UIListLayout")
                popupLayout.Padding = UDim.new(0, 2)
                popupLayout.Parent = popup

                local popupScroll = Instance.new("ScrollingFrame")
                popupScroll.BackgroundTransparency = 1
                popupScroll.BorderSizePixel = 0
                popupScroll.Size = UDim2.new(1, -6, 1, -6)
                popupScroll.Position = UDim2.fromOffset(3, 3)
                popupScroll.ScrollBarThickness = 2
                popupScroll.Parent = popup
                popupLayout.Parent = popupScroll

                local item = {Root = row, Value = current, Options = options}

                local function rebuild()
                    for _, child in ipairs(popupScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for _, option in ipairs(options) do
                        local btn = Instance.new("ImageButton")
                        btn.BackgroundTransparency = 1
                        btn.Image = ""
                        btn.BorderSizePixel = 0
                        btn.Size = UDim2.new(1, 0, 0, 28)
                        btn.Font = Enum.Font.GothamBold
                        btn.Text = tostring(option)
                        btn.TextColor3 = UI.Theme.Text
                        btn.TextSize = 10
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.AutoButtonColor = false
                        btn.ZIndex = 101
                        btn.Parent = popupScroll
                        padding(btn, 8, 0, 8, 0)
                        corner(btn, 5)

                        btn.MouseEnter:Connect(function()
                            btn.BackgroundTransparency = 1
                            btn.Image = GetImage("dropdown_selected_bg.png")
                            btn.ScaleType = Enum.ScaleType.Slice
                            btn.SliceCenter = Rect.new(12, 12, 12, 12)
                        end)
                        btn.MouseLeave:Connect(function()
                            btn.BackgroundTransparency = 1
                            btn.Image = ""

                        end)
                        btn.MouseButton1Click:Connect(function()
                            item:SetValue(option)
                            popup.Visible = false
                        end)
                    end
                    popupScroll.CanvasSize = UDim2.fromOffset(0, #options * 30)
                end

                function item:SetValue(v, fire)
                    current = v
                    item.Value = v
                    valueLabel.Text = tostring(v or "Select...")
                    if fire ~= false then
                        pcall(callback, v)
                    end
                    return item
                end

                function item:SetOptions(newOptions)
                    options = newOptions or {}
                    item.Options = options
                    rebuild()
                    return item
                end

                function item:GetValue()
                    return current
                end

                local open = inputButton(selectFrame)
                open.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    if popup.Visible then
                        local pos = selectFrame.AbsolutePosition
                        local s = selectFrame.AbsoluteSize
                        popup.Position = UDim2.fromOffset(pos.X, pos.Y + s.Y + 4)
                        popup.Size = UDim2.fromOffset(s.X, math.min(170, math.max(30, #options * 30 + 6)))
                    end
                end)

                UIS.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    if not popup.Visible then return end
                    local p = input.Position
                    local pos = popup.AbsolutePosition
                    local s = popup.AbsoluteSize
                    if p.X < pos.X or p.X > pos.X + s.X or p.Y < pos.Y or p.Y > pos.Y + s.Y then
                        popup.Visible = false
                    end
                end)

                rebuild()
                item:SetValue(current or options[1], false)
                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddKeybind(config)
                config = config or {}
                local name = tostring(config.Name or "Keybind")
                local key = normalizeKey(config.Default or config.Keybind or "RightControl")
                local callback = config.Callback or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.Size = UDim2.new(1, 0, 0, 36)
                row.Parent = holder
                corner(row, 6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 0)
                label.Size = UDim2.new(1, -115, 1, 0)

                local keyButton = Instance.new("TextButton")
                keyButton.AnchorPoint = Vector2.new(1, 0.5)
                keyButton.Position = UDim2.new(1, -9, 0.5, 0)
                keyButton.Size = UDim2.fromOffset(90, 24)
                keyButton.BackgroundColor3 = UI.Theme.Background
                keyButton.BorderSizePixel = 0
                keyButton.Font = Enum.Font.GothamBold
                keyButton.Text = key.Name
                keyButton.TextColor3 = UI.Theme.Muted
                keyButton.TextSize = 10
                keyButton.AutoButtonColor = false
                keyButton.Parent = row
                corner(keyButton, 5)
                stroke(keyButton, UI.Theme.Stroke, 0.55)

                local listening = false
                local item = {Root = row, Key = key}

                function item:SetKey(newKey)
                    key = normalizeKey(newKey)
                    item.Key = key
                    keyButton.Text = key.Name
                    return item
                end

                keyButton.MouseButton1Click:Connect(function()
                    listening = true
                    keyButton.Text = "PRESS KEY"
                end)

                UIS.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode
                            item.Key = key
                            keyButton.Text = key.Name
                            listening = false
                        end
                        return
                    end

                    if not processed and input.KeyCode == key then
                        pcall(callback, key)
                    end
                end)

                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddTextInput(config)
                config = config or {}
                local name = tostring(config.Name or "Text Input")
                local value = tostring(config.Default or "")
                local callback = config.Callback or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.Size = UDim2.new(1, 0, 0, 54)
                row.Parent = holder
                corner(row, 6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 5)
                label.Size = UDim2.new(1, -22, 0, 16)

                local box = Instance.new("TextBox")
                box.BackgroundColor3 = UI.Theme.Background
                box.BorderSizePixel = 0
                box.Position = UDim2.fromOffset(9, 26)
                box.Size = UDim2.new(1, -18, 0, 21)
                box.Font = Enum.Font.GothamBold
                box.Text = value
                box.PlaceholderText = tostring(config.Placeholder or "Enter text...")
                box.PlaceholderColor3 = UI.Theme.Placeholder
                box.TextColor3 = UI.Theme.Text
                box.TextSize = 10
                box.ClearTextOnFocus = false
                box.Parent = row
                corner(box, 5)
                stroke(box, UI.Theme.Stroke, 0.55)
                padding(box, 7, 0, 7, 0)

                box.FocusLost:Connect(function()
                    value = box.Text
                    pcall(callback, value)
                end)

                local item = {Root = row, Box = box}
                function item:SetValue(v)
                    value = tostring(v or "")
                    box.Text = value
                    return item
                end
                function item:GetValue()
                    return value
                end
                table.insert(Section.Controls, item)
                return item
            end

            function Section:AddColorPicker(config)
                config = config or {}
                local name = tostring(config.Name or "Color")
                local color = typeof(config.Default) == "Color3" and config.Default or UI.Theme.Accent
                local callback = config.Callback or function() end

                local row = Instance.new("ImageLabel")
                row.BackgroundTransparency = 1
                row.Image = GetImage("button1.png")
                row.ScaleType = Enum.ScaleType.Slice
                row.SliceCenter = Rect.new(12, 12, 12, 12)
                row.Size = UDim2.new(1, 0, 0, 36)
                row.Parent = holder
                corner(row, 6)

                local label = makeText(row, name, 11, UI.Theme.Text)
                label.Position = UDim2.fromOffset(11, 0)
                label.Size = UDim2.new(1, -70, 1, 0)

                local swatch = Instance.new("Frame")
                swatch.AnchorPoint = Vector2.new(1, 0.5)
                swatch.Position = UDim2.new(1, -11, 0.5, 0)
                swatch.Size = UDim2.fromOffset(38, 20)
                swatch.BackgroundColor3 = color
                swatch.Parent = row
                corner(swatch, 5)

                local item = {Root = row, Value = color}
                function item:SetValue(v, fire)
                    if typeof(v) ~= "Color3" then return item end
                    color = v
                    item.Value = v
                    swatch.BackgroundColor3 = v
                    if fire ~= false then
                        pcall(callback, v)
                    end
                    return item
                end
                function item:GetValue()
                    return color
                end

                -- A lightweight RGB popup instead of relying on external color-picker code.
                local popup = Instance.new("ImageLabel")
                popup.BackgroundTransparency = 1
                popup.Image = GetImage("dropdown_after.png")
                popup.ScaleType = Enum.ScaleType.Slice
                popup.SliceCenter = Rect.new(12, 12, 12, 12)
                popup.BorderSizePixel = 0
                popup.Visible = false
                popup.ZIndex = 120
                popup.Size = UDim2.fromOffset(220, 116)
                popup.Parent = ScreenGui
                corner(popup, 7)
                stroke(popup, UI.Theme.Stroke, 0.3)

                local function addChannel(channelName, y, getter, setter)
                    local l = makeText(popup, channelName, 10, UI.Theme.Muted)
                    l.Position = UDim2.fromOffset(9, y)
                    l.Size = UDim2.fromOffset(20, 20)

                    local box = Instance.new("TextBox")
                    box.BackgroundColor3 = UI.Theme.Background
                    box.BorderSizePixel = 0
                    box.Position = UDim2.fromOffset(35, y)
                    box.Size = UDim2.fromOffset(65, 20)
                    box.Font = Enum.Font.GothamBold
                    box.Text = tostring(math.floor(getter() * 255 + 0.5))
                    box.TextColor3 = UI.Theme.Text
                    box.TextSize = 10
                    box.ClearTextOnFocus = false
                    box.Parent = popup
                    corner(box, 4)
                    padding(box, 5, 0, 5, 0)

                    box.FocusLost:Connect(function()
                        local n = math.clamp(tonumber(box.Text) or 0, 0, 255) / 255
                        setter(n)
                    end)
                    return box
                end

                local r, g, b = color.R, color.G, color.B
                local rb = addChannel("R", 10, function() return r end, function(v)
                    r = v
                    item:SetValue(Color3.new(r, g, b))
                end)
                local gb = addChannel("G", 37, function() return g end, function(v)
                    g = v
                    item:SetValue(Color3.new(r, g, b))
                end)
                local bb = addChannel("B", 64, function() return b end, function(v)
                    b = v
                    item:SetValue(Color3.new(r, g, b))
                end)

                local click = inputButton(row)
                click.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    if popup.Visible then
                        local p = row.AbsolutePosition
                        popup.Position = UDim2.fromOffset(p.X + row.AbsoluteSize.X - 230, p.Y + row.AbsoluteSize.Y + 4)
                    end
                end)

                table.insert(Section.Controls, item)
                return item
            end

            -- aliases matching common library naming
            Section.AddTextBox = Section.AddTextInput
            Section.AddInput = Section.AddTextInput
            Section.AddColor = Section.AddColorPicker

            table.insert(Tab.Sections, Section)
            return Section
        end

        -- Convenience methods directly on tab.
        function Tab:AddLabel(text)
            local section = self.Sections[#self.Sections]
            if not section then
                section = self:AddSection({Name = "General"})
            end
            return section:AddLabel(text)
        end

        function Tab:AddButton(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddButton(config)
        end

        function Tab:AddToggle(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddToggle(config)
        end

        function Tab:AddSlider(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddSlider(config)
        end

        function Tab:AddDropdown(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddDropdown(config)
        end

        function Tab:AddKeybind(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddKeybind(config)
        end

        function Tab:AddTextInput(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddTextInput(config)
        end

        function Tab:AddColorPicker(config)
            local section = self.Sections[#self.Sections]
            if not section then section = self:AddSection({Name = "General"}) end
            return section:AddColorPicker(config)
        end

        table.insert(self.Tabs, Tab)
        if not self.CurrentTab then
            self.CurrentTab = Tab
            task.defer(function()
                self:SelectTab(Tab)
            end)
        end

        return Tab
    end

    -- Window aliases
    Window.AddCategory = Window.AddTab

    -- keybind toggle
    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Window.Keybind then
            Window:Toggle()
        end
    end)

    -- initial animation
    root.Visible = true
    task.defer(function()
        tween(root, 0.22, {Size = size, BackgroundTransparency = 1})
    end)

    return Window
end

UI.Window = function(self, config)
    return self:CreateWindow(config)
end

-- Keep both colon and dot styles usable.
UI.Create = UI.Window

function UI:Unload()
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

-- =========================================================
-- DEFAULT THEME PRESET
-- =========================================================

UI.Themes.AREXANS = {}
for k, v in pairs(UI.Theme) do
    UI.Themes.AREXANS[k] = v
end

return UI
