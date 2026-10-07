--[[
    AREXANS UI Library
    GitHub: https://github.com/AREXANS/uiarexans
    Asset root: /asset/

    Compatible API used by vd_v2.lua:
      local Window = Library:Window({...})
      Window:SetToggleKey(Enum.KeyCode.K)
      local Tab = Window:AddTab({Name="...", Icon="..."})
      local Section = Tab:AddSection("...", true)
      Section:AddButton({...})
      Section:AddToggle({...})
      Section:AddDropdown({...})
      Section:AddSlider({...})
      Section:AddInput({...})
      Section:AddParagraph({...})
      Section:AddDivider()
      Library:MakeNotify({...})
      Library:Save(), ResetAll(), ExportConfig(), ImportConfig()
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local ROOT = "AREXANS_UI"
local GUI_NAME = "AREXANS_UI_LIBRARY"
local ASSET_BASE = "https://raw.githubusercontent.com/AREXANS/uiarexans/main/asset/"

local function safeCall(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    return ok, a, b, c
end

local function makeFolder(path)
    if type(makefolder) == "function" and type(isfolder) == "function" then
        local current = ""
        for part in string.gmatch(path, "[^/]+") do
            current = current == "" and part or current .. "/" .. part
            if not isfolder(current) then pcall(makefolder, current) end
        end
    end
end

local function assetFile(name, category)
    category = category or "icons"
    local safe = tostring(name):gsub("[^%w_%-]", "_")
    return ROOT .. "/" .. category .. "/" .. safe .. ".png"
end

local function assetCandidates(name)
    return {
        { url = ASSET_BASE .. "icons/" .. name .. ".png", path = assetFile(name, "icons") },
        { url = ASSET_BASE .. "components/" .. name .. ".png", path = assetFile(name, "components") },
        { url = ASSET_BASE .. name .. ".png", path = assetFile(name, "root") },
        { url = ASSET_BASE .. "foundation/branding/" .. name .. ".png", path = assetFile(name, "branding") },
    }
end

local iconAliases = {
    scroll = "scroll_star",
    web = "globe_ring",
    user = "user_group",
    player = "user_add",
    eyes = "visibility_eye",
    menu = "filter_sliders",
    settings = "settings",
    sword = "rocket",
    search = "search",
    close = "delete_energy",
    check = "file_check",
    warning = "warning",
    error = "warning",
    info = "notification_bell",
    success = "file_check",
    folder = "folder_energy",
    download = "download",
    upload = "upload",
}

local function resolveIcon(name)
    if not name then return nil end
    name = tostring(name)
    if name:match("^rbxassetid://") then return name end
    if name:match("^%d+$") then return "rbxassetid://" .. name end
    return iconAliases[name] or name
end

local function getAsset(name)
    if not name or name == "" then return nil end
    name = resolveIcon(name)
    if not name then return nil end
    if name:match("^rbxassetid://") then return name end

    if type(getsynasset) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" then
        return nil
    end

    for _, candidate in ipairs(assetCandidates(name)) do
        local path = candidate.path
        if not isfile(path) then
            local folder = path:match("^(.*)/[^/]+$")
            if folder then makeFolder(folder) end
            local ok, body = pcall(function() return game:HttpGet(candidate.url) end)
            if ok and type(body) == "string" and #body > 0 then
                pcall(writefile, path, body)
            end
        end
        if isfile(path) then
            local ok, result = pcall(getsynasset, path)
            if ok and result then return result end
        end
    end
    return nil
end

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(20, 150, 255)
    s.Transparency = transparency == nil and 0.35 or transparency
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function setText(label, text, size, color)
    label.Text = tostring(text or "")
    label.TextSize = size or 13
    label.TextColor3 = color or Color3.fromRGB(225, 240, 255)
    label.Font = Enum.Font.GothamMedium
end

local function newLabel(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, size and (size + 8) or 26)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    setText(l, text, size, color)
    l.Parent = parent
    return l
end

function Library:_register(key, value, callback)
    self.Config[key] = value
    self._defaults[key] = value
    self._callbacks[key] = callback
end

function Library:_fire(key, value)
    self.Config[key] = value
    local cb = self._callbacks[key]
    if cb then task.spawn(cb, value) end
end

function Library:Window(options)
    options = options or {}
    if self._window then
        pcall(function() self._window:Destroy() end)
    end

    local selfLib = self
    self.Config = self.Config or {}
    self._defaults = {}
    self._callbacks = {}
    self._tabs = {}

    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 9999

    local parent
    pcall(function()
        if type(gethui) == "function" then parent = gethui() end
    end)
    if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
    if not parent then parent = LocalPlayer:WaitForChild("PlayerGui") end
    gui.Parent = parent

    local root = Instance.new("Frame")
    root.Name = "Window"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.new(0, 760, 0, 520)
    root.BackgroundColor3 = Color3.fromRGB(5, 15, 28)
    root.BackgroundTransparency = 0.04
    root.BorderSizePixel = 0
    root.ClipsDescendants = true
    root.Parent = gui
    addCorner(root, 14)
    addStroke(root, options.Color or Color3.fromRGB(0, 170, 255), 0.18, 1.25)

    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = root

    local top = Instance.new("Frame")
    top.Name = "Header"
    top.Size = UDim2.new(1, 0, 0, 62)
    top.BackgroundColor3 = Color3.fromRGB(7, 24, 42)
    top.BorderSizePixel = 0
    top.Parent = root

    local logo = Instance.new("ImageLabel")
    logo.BackgroundTransparency = 1
    logo.Position = UDim2.new(0, 15, 0.5, -18)
    logo.Size = UDim2.fromOffset(36, 36)
    local logoAsset = getAsset("logo")
    if logoAsset then logo.Image = logoAsset else logo.Image = getAsset("settings") or "" end
    logo.Parent = top

    local title = newLabel(top, options.Title or "AREXANS UI", 16, Color3.fromRGB(235, 248, 255))
    title.Position = UDim2.new(0, 60, 0, 8)
    title.Size = UDim2.new(1, -180, 0, 24)
    title.Font = Enum.Font.GothamBold

    local footer = newLabel(top, options.Footer or "", 10, Color3.fromRGB(105, 175, 215))
    footer.Position = UDim2.new(0, 60, 0, 32)
    footer.Size = UDim2.new(1, -180, 0, 18)

    local version = newLabel(top, options.Version and ("v" .. tostring(options.Version)) or "", 10, Color3.fromRGB(110, 200, 255))
    version.AnchorPoint = Vector2.new(1, 0.5)
    version.Position = UDim2.new(1, -18, 0.5, 0)
    version.Size = UDim2.fromOffset(70, 20)
    version.TextXAlignment = Enum.TextXAlignment.Right

    local body = Instance.new("Frame")
    body.Position = UDim2.new(0, 0, 0, 62)
    body.Size = UDim2.new(1, 0, 1, -62)
    body.BackgroundTransparency = 1
    body.Parent = root

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, options["Tab Width"] or 120, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(4, 12, 23)
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollBarImageColor3 = options.Color or Color3.fromRGB(0, 170, 255)
    sidebar.CanvasSize = UDim2.new()
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.Parent = body

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop = UDim.new(0, 10)
    sidePad.PaddingLeft = UDim.new(0, 8)
    sidePad.PaddingRight = UDim.new(0, 8)
    sidePad.Parent = sidebar

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 5)
    sideLayout.Parent = sidebar

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.new(0, options["Tab Width"] or 120, 0, 0)
    content.Size = UDim2.new(1, -(options["Tab Width"] or 120), 1, 0)
    content.BackgroundColor3 = Color3.fromRGB(6, 18, 31)
    content.BorderSizePixel = 0
    content.Parent = body

    self._gui = gui
    self._root = root
    self._content = content
    self._sidebar = sidebar
    self._accent = options.Color or Color3.fromRGB(0, 170, 255)

    -- Dragging
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local function updateScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local factor = math.min((vp.X - 20) / 760, (vp.Y - 20) / 520, 1)
        scale.Scale = math.clamp(factor, 0.55, 1)
    end
    updateScale()
    if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end

    self._window = {
        Gui = gui,
        Root = root,
        Tabs = self._tabs,
    }

    function self._window:SetToggleKey(key)
        if selfLib._keyConnection then selfLib._keyConnection:Disconnect() end
        selfLib._toggleKey = key
        selfLib._keyConnection = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == selfLib._toggleKey then
                root.Visible = not root.Visible
            end
        end)
    end

    function self._window:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tostring(tabOptions.Name or "Tab")
        local tab = {
            Name = tabName,
            Sections = {},
            _window = self._window,
        }

        local button = Instance.new("TextButton")
        button.Name = tabName:gsub("%W", "_")
        button.Size = UDim2.new(1, 0, 0, 40)
        button.BackgroundColor3 = Color3.fromRGB(8, 28, 47)
        button.BackgroundTransparency = 0.55
        button.Text = ""
        button.AutoButtonColor = false
        button.Parent = sidebar
        addCorner(button, 8)

        local icon = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 8, 0.5, -10)
        icon.Size = UDim2.fromOffset(20, 20)
        local iconAsset = getAsset(tabOptions.Icon)
        if iconAsset then icon.Image = iconAsset end
        icon.Parent = button

        local txt = newLabel(button, tabName, 11, Color3.fromRGB(165, 205, 230))
        txt.Position = UDim2.new(0, 34, 0, 0)
        txt.Size = UDim2.new(1, -40, 1, 0)

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. tabName:gsub("%W", "_")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = selfLib._accent
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new()
        page.Visible = false
        page.Parent = content

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 18)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = page

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = page

        function tab:AddSection(titleText, expanded)
            local section = {
                Name = tostring(titleText or "Section"),
                _page = page,
                _window = self._window,
                _expanded = expanded ~= false,
            }

            local card = Instance.new("Frame")
            card.Name = section.Name:gsub("%W", "_")
            card.Size = UDim2.new(1, -2, 0, 0)
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.BackgroundColor3 = Color3.fromRGB(8, 25, 42)
            card.BackgroundTransparency = 0.18
            card.BorderSizePixel = 0
            card.Parent = page
            addCorner(card, 10)
            addStroke(card, selfLib._accent, 0.62, 1)

            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 38)
            header.BackgroundTransparency = 1
            header.Text = ""
            header.AutoButtonColor = false
            header.Parent = card

            local title = newLabel(header, section.Name, 12, Color3.fromRGB(225, 242, 255))
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Size = UDim2.new(1, -45, 1, 0)
            title.Font = Enum.Font.GothamBold

            local chevron = newLabel(header, section._expanded and "−" or "+", 16, selfLib._accent)
            chevron.Position = UDim2.new(1, -35, 0, 0)
            chevron.Size = UDim2.fromOffset(25, 38)
            chevron.TextXAlignment = Enum.TextXAlignment.Center

            local holder = Instance.new("Frame")
            holder.Name = "Content"
            holder.Position = UDim2.new(0, 10, 0, 38)
            holder.Size = UDim2.new(1, -20, 0, 0)
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.BackgroundTransparency = 1
            holder.Parent = card

            local hpad = Instance.new("UIPadding")
            hpad.PaddingBottom = UDim.new(0, 10)
            hpad.Parent = holder
            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 6)
            list.Parent = holder

            local function setExpanded(state)
                section._expanded = state
                holder.Visible = state
                chevron.Text = state and "−" or "+"
            end
            header.MouseButton1Click:Connect(function() setExpanded(not section._expanded) end)
            setExpanded(section._expanded)

            local function makeRow(height)
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, height or 42)
                row.BackgroundColor3 = Color3.fromRGB(11, 34, 55)
                row.BackgroundTransparency = 0.28
                row.BorderSizePixel = 0
                row.Parent = holder
                addCorner(row, 8)
                return row
            end

            function section:AddButton(cfg)
                cfg = cfg or {}
                local row = makeRow(42)
                local hit = Instance.new("TextButton")
                hit.Size = UDim2.fromScale(1,1)
                hit.BackgroundTransparency = 1
                hit.Text = ""
                hit.Parent = row

                local icon = Instance.new("ImageLabel")
                icon.BackgroundTransparency = 1
                icon.Position = UDim2.new(1, -38, 0.5, -10)
                icon.Size = UDim2.fromOffset(20,20)
                local ia = getAsset(cfg.Icon or "add_circle")
                if ia then icon.Image = ia end
                icon.Parent = row

                local label = newLabel(row, cfg.Title or "Button", 12, Color3.fromRGB(225,240,255))
                label.Position = UDim2.new(0,12,0,0)
                label.Size = UDim2.new(1,-55,1,0)
                label.Font = Enum.Font.GothamBold

                hit.MouseEnter:Connect(function() tween(row,{BackgroundColor3=Color3.fromRGB(12,54,82)},0.12) end)
                hit.MouseLeave:Connect(function() tween(row,{BackgroundColor3=Color3.fromRGB(11,34,55)},0.12) end)
                hit.MouseButton1Click:Connect(function()
                    if cfg.Callback then task.spawn(cfg.Callback) end
                end)
                return {Row=row, Button=hit}
            end

            function section:AddToggle(cfg)
                cfg = cfg or {}
                local key = "Toggle:" .. section.Name .. ":" .. tostring(cfg.Title or #selfLib._defaults + 1)
                local value = cfg.Default == true
                selfLib:_register(key, value, cfg.Callback)

                local row = makeRow(48)
                local label = newLabel(row, cfg.Title or "Toggle", 12, Color3.fromRGB(225,240,255))
                label.Position = UDim2.new(0,12,0,3)
                label.Size = UDim2.new(1,-75,0,22)
                label.Font = Enum.Font.GothamBold

                if cfg.Content then
                    local desc = newLabel(row, cfg.Content, 9, Color3.fromRGB(115,165,195))
                    desc.Position = UDim2.new(0,12,0,24)
                    desc.Size = UDim2.new(1,-75,0,17)
                end

                local hit = Instance.new("TextButton")
                hit.Size = UDim2.fromOffset(46,26)
                hit.Position = UDim2.new(1,-58,0.5,-13)
                hit.BackgroundTransparency = 1
                hit.Text = ""
                hit.Parent = row

                local img = Instance.new("ImageLabel")
                img.Size = UDim2.fromScale(1,1)
                img.BackgroundTransparency = 1
                img.Parent = hit

                local function render(state)
                    local a = getAsset(state and "on" or "off")
                    if a then img.Image = a else
                        img.Image = ""
                        hit.BackgroundColor3 = state and selfLib._accent or Color3.fromRGB(35,55,70)
                        addCorner(hit,13)
                    end
                end
                render(value)

                local handle = {}
                function handle:Set(state)
                    state = state == true
                    if value == state then return end
                    value = state
                    render(value)
                    selfLib:_fire(key, value)
                end
                function handle:Get() return value end
                hit.MouseButton1Click:Connect(function() handle:Set(not value) end)
                return handle
            end

            function section:AddDropdown(cfg)
                cfg = cfg or {}
                local options = cfg.Options or {}
                local key = "Dropdown:" .. section.Name .. ":" .. tostring(cfg.Title or #selfLib._defaults + 1)
                local selected = cfg.Default
                if selected == nil then selected = options[1] end
                selfLib:_register(key, selected, cfg.Callback)

                local row = makeRow(42)
                local label = newLabel(row, cfg.Title or "Dropdown", 11, Color3.fromRGB(205,230,245))
                label.Position = UDim2.new(0,12,0,0)
                label.Size = UDim2.new(0.42,0,1,0)

                local current = Instance.new("TextButton")
                current.Size = UDim2.new(0.55,0,0,30)
                current.Position = UDim2.new(0.43,0,0.5,-15)
                current.BackgroundColor3 = Color3.fromRGB(5,20,34)
                current.TextColor3 = Color3.fromRGB(225,245,255)
                current.Font = Enum.Font.GothamMedium
                current.TextSize = 10
                current.Text = tostring(selected or "")
                current.AutoButtonColor = false
                current.Parent = row
                addCorner(current,7)
                addStroke(current,selfLib._accent,0.7,1)

                local list = Instance.new("Frame")
                list.Visible = false
                list.ZIndex = 30
                list.Size = UDim2.new(0.55,0,0,0)
                list.Position = UDim2.new(0.43,0,1,3)
                list.BackgroundColor3 = Color3.fromRGB(5,18,31)
                list.BorderSizePixel = 0
                list.Parent = row
                addCorner(list,7)
                addStroke(list,selfLib._accent,0.5,1)
                local ll = Instance.new("UIListLayout"); ll.Parent=list

                for _, option in ipairs(options) do
                    local item = Instance.new("TextButton")
                    item.Size = UDim2.new(1,0,0,30)
                    item.BackgroundTransparency = 1
                    item.Text = tostring(option)
                    item.TextColor3 = Color3.fromRGB(205,230,245)
                    item.Font = Enum.Font.Gotham
                    item.TextSize = 10
                    item.ZIndex = 31
                    item.Parent = list
                    item.MouseButton1Click:Connect(function()
                        selected = option
                        current.Text = tostring(option)
                        list.Visible = false
                        selfLib:_fire(key, option)
                    end)
                end
                list.Size = UDim2.new(0.55,0,0,#options*30)

                current.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
                return {
                    Set = function(_,v)
                        selected=v; current.Text=tostring(v); selfLib:_fire(key,v)
                    end,
                    Get = function() return selected end
                }
            end

            function section:AddSlider(cfg)
                cfg = cfg or {}
                local min,max = tonumber(cfg.Min) or 0, tonumber(cfg.Max) or 100
                local value = math.clamp(tonumber(cfg.Default) or min,min,max)
                local key = "Slider:" .. section.Name .. ":" .. tostring(cfg.Title or #selfLib._defaults + 1)
                selfLib:_register(key,value,cfg.Callback)

                local row=makeRow(58)
                local label=newLabel(row,cfg.Title or "Slider",11,Color3.fromRGB(205,230,245))
                label.Position=UDim2.new(0,12,0,3); label.Size=UDim2.new(0.7,0,0,22)
                local valLabel=newLabel(row,tostring(value),10,selfLib._accent)
                valLabel.Position=UDim2.new(1,-70,0,3); valLabel.Size=UDim2.fromOffset(55,22); valLabel.TextXAlignment=Enum.TextXAlignment.Right

                local bar=Instance.new("Frame"); bar.Position=UDim2.new(0,12,0,34); bar.Size=UDim2.new(1,-24,0,8)
                bar.BackgroundColor3=Color3.fromRGB(18,48,68); bar.BorderSizePixel=0; bar.Parent=row; addCorner(bar,4)
                local fill=Instance.new("Frame"); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); fill.BackgroundColor3=selfLib._accent; fill.BorderSizePixel=0; fill.Parent=bar; addCorner(fill,4)
                local knob=Instance.new("Frame"); knob.AnchorPoint=Vector2.new(.5,.5); knob.Position=UDim2.new((value-min)/(max-min),0,.5,0); knob.Size=UDim2.fromOffset(14,14); knob.BackgroundColor3=Color3.fromRGB(235,250,255); knob.BorderSizePixel=0; knob.Parent=bar; addCorner(knob,7)

                local dragging=false
                local function setValue(v)
                    value=math.clamp(v,min,max)
                    local alpha=(value-min)/(max-min)
                    fill.Size=UDim2.new(alpha,0,1,0); knob.Position=UDim2.new(alpha,0,.5,0)
                    valLabel.Text=tostring(value)
                    selfLib:_fire(key,value)
                end
                local hit=Instance.new("TextButton"); hit.Size=UDim2.new(1,20,0,28); hit.Position=UDim2.new(0,-10,0,-10); hit.BackgroundTransparency=1; hit.Text=""; hit.Parent=bar
                hit.MouseButton1Down:Connect(function() dragging=true end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                        local a=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                        setValue(min+(max-min)*a)
                    end
                end)
                local handle={}
                function handle:Set(v) setValue(tonumber(v) or min) end
                function handle:Get() return value end
                return handle
            end

            function section:AddInput(cfg)
                cfg=cfg or {}
                local key="Input:"..section.Name..":"..tostring(cfg.Title or #selfLib._defaults+1)
                selfLib:_register(key,cfg.Default or "",cfg.Callback)
                local row=makeRow(66)
                local label=newLabel(row,cfg.Title or "Input",11,Color3.fromRGB(205,230,245))
                label.Position=UDim2.new(0,12,0,3); label.Size=UDim2.new(1,-24,0,20)
                if cfg.Content then
                    label.Text=cfg.Title.."  •  "..cfg.Content
                end
                local box=Instance.new("TextBox")
                box.Position=UDim2.new(0,12,0,29); box.Size=UDim2.new(1,-24,0,28)
                box.BackgroundColor3=Color3.fromRGB(5,20,34); box.BorderSizePixel=0
                box.TextColor3=Color3.fromRGB(225,245,255); box.PlaceholderColor3=Color3.fromRGB(90,130,155)
                box.Font=Enum.Font.Gotham; box.TextSize=10; box.TextXAlignment=Enum.TextXAlignment.Left
                box.ClearTextOnFocus=false; box.Text=tostring(cfg.Default or ""); box.Parent=row
                addCorner(box,7); addStroke(box,selfLib._accent,0.75,1)
                box.FocusLost:Connect(function()
                    selfLib:_fire(key,box.Text)
                end)
                return {Set=function(_,v) box.Text=tostring(v) end,Get=function() return box.Text end}
            end

            function section:AddParagraph(cfg)
                cfg=cfg or {}
                local row=makeRow(0)
                row.AutomaticSize=Enum.AutomaticSize.Y
                local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8); pad.Parent=row
                local t=newLabel(row,cfg.Title or "Info",12,Color3.fromRGB(225,242,255))
                t.Size=UDim2.new(1,0,0,22); t.Font=Enum.Font.GothamBold
                local c=newLabel(row,cfg.Content or "",9,Color3.fromRGB(145,185,210))
                c.Position=UDim2.new(0,0,0,24); c.Size=UDim2.new(1,0,0,0); c.AutomaticSize=Enum.AutomaticSize.Y; c.TextWrapped=true; c.TextYAlignment=Enum.TextYAlignment.Top
                return {Title=t,Content=c}
            end

            function section:AddDivider()
                local line=Instance.new("Frame")
                line.Size=UDim2.new(1,0,0,1)
                line.BackgroundColor3=selfLib._accent
                line.BackgroundTransparency=0.65
                line.BorderSizePixel=0
                line.Parent=holder
                return line
            end

            table.insert(tab.Sections, section)
            return section
        end

        function tab:_select()
            for _, t in ipairs(selfLib._tabs) do
                t.Page.Visible=false
                t.Button.BackgroundTransparency=0.55
                t.Label.TextColor3=Color3.fromRGB(165,205,230)
            end
            page.Visible=true
            button.BackgroundTransparency=0.05
            txt.TextColor3=Color3.fromRGB(235,250,255)
            selfLib._activeTab=tab
        end

        button.MouseEnter:Connect(function()
            if selfLib._activeTab ~= tab then tween(button,{BackgroundColor3=Color3.fromRGB(10,48,70)},0.12) end
        end)
        button.MouseLeave:Connect(function()
            if selfLib._activeTab ~= tab then tween(button,{BackgroundColor3=Color3.fromRGB(8,28,47)},0.12) end
        end)
        button.MouseButton1Click:Connect(function() tab:_select() end)

        tab.Page=page; tab.Button=button; tab.Label=txt
        table.insert(selfLib._tabs,tab)
        if #selfLib._tabs==1 then tab:_select() end
        return tab
    end

    function self._window:Destroy()
        if selfLib._keyConnection then selfLib._keyConnection:Disconnect(); selfLib._keyConnection=nil end
        if selfLib._gui then selfLib._gui:Destroy(); selfLib._gui=nil end
    end

    return self._window
end

function Library:MakeNotify(cfg)
    cfg=cfg or {}
    local gui=self._gui
    if not gui then return end
    local holder=gui:FindFirstChild("Notifications")
    if not holder then
        holder=Instance.new("Frame"); holder.Name="Notifications"; holder.AnchorPoint=Vector2.new(1,1)
        holder.Position=UDim2.new(1,-15,1,-15); holder.Size=UDim2.new(0,330,1,-30)
        holder.BackgroundTransparency=1; holder.Parent=gui
        local list=Instance.new("UIListLayout"); list.VerticalAlignment=Enum.VerticalAlignment.Bottom; list.Padding=UDim.new(0,8); list.Parent=holder
    end

    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,64); card.BackgroundColor3=Color3.fromRGB(6,23,39); card.BackgroundTransparency=0.05; card.BorderSizePixel=0; card.Parent=holder; addCorner(card,10); addStroke(card,self._accent,0.35,1)
    local icon=Instance.new("ImageLabel"); icon.BackgroundTransparency=1; icon.Position=UDim2.new(0,12,0,12); icon.Size=UDim2.fromOffset(38,38)
    local ia=getAsset(cfg.Icon or "notification_bell"); if ia then icon.Image=ia end; icon.Parent=card
    local title=newLabel(card,cfg.Title or "Notification",11,Color3.fromRGB(235,248,255)); title.Position=UDim2.new(0,58,0,8); title.Size=UDim2.new(1,-68,0,20); title.Font=Enum.Font.GothamBold
    local content=newLabel(card,cfg.Content or "",9,Color3.fromRGB(150,190,215)); content.Position=UDim2.new(0,58,0,28); content.Size=UDim2.new(1,-68,0,28); content.TextWrapped=true
    task.delay(tonumber(cfg.Time) or 3,function() if card and card.Parent then tween(card,{BackgroundTransparency=1},0.25); task.wait(.28); card:Destroy() end end)
end

function Library:Save()
    self.Config = self.Config or {}
    if type(writefile)=="function" and type(HttpService.JSONEncode)=="function" then
        makeFolder(ROOT)
        pcall(writefile,ROOT.."/config.json",HttpService:JSONEncode(self.Config))
    end
    return true
end

function Library:ExportConfig()
    return HttpService:JSONEncode(self.Config or {})
end

function Library:ImportConfig(json)
    local ok,data=pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or type(data)~="table" then return false end
    self.Config=data
    for key,value in pairs(data) do
        local cb=self._callbacks[key]
        if cb then task.spawn(cb,value) end
    end
    return true
end

function Library:ResetAll()
    for key,value in pairs(self._defaults or {}) do
        self.Config[key]=value
        local cb=self._callbacks[key]
        if cb then task.spawn(cb,value) end
    end
    return true
end

function Library:Destroy()
    if self._window and self._window.Destroy then self._window:Destroy() end
end

return setmetatable({
    Config={},
    _defaults={},
    _callbacks={},
}, Library)
