local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
​if type(getgenv) ~= "function" then
getgenv = function() return _G end
end
​-- ==========================================
-- GLOBAL CONFIG BRIDGES
-- ==========================================
getgenv().SilentAimVeilSettings = getgenv().SilentAimVeilSettings or {}
local VeilSettings = getgenv().SilentAimVeilSettings
​local DefaultVeil = {
Enabled             = false,
EnableSilentVeil    = false,
TargetPart          = "HumanoidRootPart",
VeilTargetPart      = "HumanoidRootPart",
AutoPredict         = false,
FovRadius           = 300,
FOV                 = 300,
MaxTargetDistance   = 286,
MaxDist             = 286,
ShowTracker         = false,
Tracker             = false,
ShowFOV             = false,
CustomSpearSpeed    = 165,
SpearSpeed          = 165,
CustomSpearGravity  = 103,
Gravity             = 103,
LeadMultiplier      = 1.4,
AuraSpearSpeed      = 165,
AuraSpearGravity    = 96.5,
ESP                 = false,
Crosshair           = false,
ESP_Enable          = false,
ESP_ShowHP          = false,
ESP_ShowDistance    = false,
HideName            = false,
}
​for k, v in pairs(DefaultVeil) do
if VeilSettings[k] == nil then VeilSettings[k] = v end
end
​getgenv().SilentAimPistolSettings = getgenv().SilentAimPistolSettings or {}
local PistolSettings = getgenv().SilentAimPistolSettings
​local DefaultPistol = {
Enabled             = false,
SilentAimPistol     = false,
TargetPart          = "HumanoidRootPart",
PistolTargetPart    = "HumanoidRootPart",
ShowFOV             = false,
PistolShowFOV       = false,
FovRadius           = 300,
PistolFovRadius     = 300,
Laser               = false,
PistolShowLaser     = false,
StunESP             = false,
PistolESPStun       = false,
SafeShot            = false,
SafeShotEnabled     = false,
}
​for k, v in pairs(DefaultPistol) do
if PistolSettings[k] == nil then PistolSettings[k] = v end
end
​getgenv().ApplySetting286m = function()
local speedNormal_286m = 175
local speedAura_286m = 170
​VeilSettings.MaxTargetDistance = 286
VeilSettings.MaxDist = 286
VeilSettings.CustomSpearSpeed = speedNormal_286m
VeilSettings.SpearSpeed = speedNormal_286m
VeilSettings.AuraSpearSpeed = speedAura_286m
end
​getgenv().ResetDefaultSilentAim = function()
for k, v in pairs(DefaultVeil) do
VeilSettings[k] = v
end
for k, v in pairs(DefaultPistol) do
PistolSettings[k] = v
end
end
​local function GetVeilVal(key, altKey, defaultVal)
if VeilSettings[key] ~= nil then return VeilSettings[key] end
if altKey and VeilSettings[altKey] ~= nil then return VeilSettings[altKey] end
return defaultVal
end
​local function GetPistolVal(key, altKey, defaultVal)
if PistolSettings[key] ~= nil then return PistolSettings[key] end
if altKey and PistolSettings[altKey] ~= nil then return PistolSettings[altKey] end
return defaultVal
end
​-- ==========================================
-- SAFE UTILITY FUNCTIONS
-- ==========================================
local function SafeGet(parent, childName)
if parent and typeof(parent) == "Instance" then return parent:FindFirstChild(childName) end
return nil
end
​local function IsKiller(player) return player and player.Team and player.Team.Name == "Killer" end
local function IsSurvivor(player) return player and player.Team and player.Team.Name == "Survivors" end
​local function ResolveTargetPart(char, partName)
if not char or typeof(char) ~= "Instance" then return nil end
local hrp = SafeGet(char, "HumanoidRootPart") or SafeGet(char, "Torso") or SafeGet(char, "UpperTorso")
​if partName == "HumanoidRootPart" or partName == "Root" then return hrp
elseif partName == "Head" or partName == "Kepala" then return SafeGet(char, "Head") or hrp
elseif partName == "Left Shoulder" or partName == "Left Arm" then return SafeGet(char, "LeftUpperArm") or SafeGet(char, "Left Arm") or hrp
elseif partName == "Right Shoulder" or partName == "Right Arm" then return SafeGet(char, "RightUpperArm") or SafeGet(char, "Right Arm") or hrp
elseif partName == "Any Shoulder" then
local left = SafeGet(char, "LeftUpperArm") or SafeGet(char, "Left Arm")
local right = SafeGet(char, "RightUpperArm") or SafeGet(char, "Right Arm")
if left and right then
local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local lp, lOn = Camera:WorldToViewportPoint(left.Position)
local rp, rOn = Camera:WorldToViewportPoint(right.Position)
local lDist = lOn and (Vector2.new(lp.X, lp.Y) - center).Magnitude or math.huge
local rDist = rOn and (Vector2.new(rp.X, rp.Y) - center).Magnitude or math.huge
if lDist < rDist then return left else return right end
end
return left or right or hrp
elseif partName == "Torso" or partName == "Badan" then return SafeGet(char, "Torso") or SafeGet(char, "UpperTorso") or hrp end
return hrp
end
​-- ==========================================
-- SAFE GUI SETUP FOR ESP
-- ==========================================
local SafeGuiParent = nil
pcall(function() SafeGuiParent = gethui and gethui() end)
if not SafeGuiParent then pcall(function() SafeGuiParent = game:GetService("CoreGui") end) end
if not SafeGuiParent then SafeGuiParent = LocalPlayer:WaitForChild("PlayerGui") end
​local ESPFolder = SafeGet(SafeGuiParent, "ArexansTerrainESP_UI")
if not ESPFolder then ESPFolder = Instance.new("Folder") ESPFolder.Name = "ArexansTerrainESP_UI" ESPFolder.Parent = SafeGuiParent end
​local KillerESPFolder_Pistol = SafeGet(SafeGuiParent, "KillerESPFolder_Pistol")
if not KillerESPFolder_Pistol then KillerESPFolder_Pistol = Instance.new("Folder") KillerESPFolder_Pistol.Name = "KillerESPFolder_Pistol" KillerESPFolder_Pistol.Parent = SafeGuiParent end
​-- ==========================================
-- HIDENAME SYSTEM (STRICT DETECTION - FIXED)
-- ==========================================
local TARGET_NAME = "AREXANS"
local TARGET_IMAGE = "rbxassetid://111967366195505"
local OriginalUI = setmetatable({}, {__mode = "k"})
​-- Helper function: Only true if it's explicitly a Roblox avatar thumbnail
local function isAvatarThumbnail(urlStr)
if not urlStr or urlStr == "" then return false end
local lowerStr = string.lower(urlStr)
-- This is the strict pattern: Must contain rbxthumb AND type=Avatar
return string.find(lowerStr, "rbxthumb://") ~= nil and (string.find(lowerStr, "avatar") ~= nil or string.find(lowerStr, "headshot") ~= nil)
end
​-- Fallback for specific player list GUIs if they use a different ID system, BUT restricted by size
local function isSmallProfilePicture(instance)
if not instance or typeof(instance) ~= "Instance" then return false end
​local passSize = false
pcall(function()
-- Ensure it's small enough to be a profile picture (prevents huge backgrounds from changing)
if instance:IsA("GuiObject") and instance.AbsoluteSize.X <= 200 and instance.AbsoluteSize.Y <= 200 then
passSize = true
end
end)
​if not passSize then return false end
​local name = string.lower(instance.Name)
-- Common names for profile pictures in custom UIs
return name == "avatar" or name == "playericon" or name == "profile" or name == "headshot"
end
​local function processTextElement(instance)
if not instance or typeof(instance) ~= "Instance" then return end
pcall(function()
if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
local currentText = instance.Text
if currentText and currentText ~= "" and currentText ~= TARGET_NAME then
local lowerText = string.lower(currentText)
local shouldReplace = false
local newText = currentText
​for _, player in ipairs(Players:GetPlayers()) do
local pName = string.lower(player.Name)
local dName = string.lower(player.DisplayName)
​if (pName ~= "" and string.find(lowerText, pName, 1, true)) or
(dName ~= "" and string.find(lowerText, dName, 1, true)) then
​shouldReplace = true
-- Exact match replacements
if currentText == player.Name or currentText == player.DisplayName then
newText = TARGET_NAME
else
-- Partial string replacement (e.g. "Score: PlayerName")
if player.Name ~= "" then newText = string.gsub(newText, player.Name, TARGET_NAME) end
if player.DisplayName ~= "" then newText = string.gsub(newText, player.DisplayName, TARGET_NAME) end
end
break
end
end
​if shouldReplace then
if not OriginalUI[instance] then OriginalUI[instance] = {} end
OriginalUI[instance].Text = currentText
instance.Text = newText
end
end
end
end)
end
​local function processImageElement(instance)
if not instance or typeof(instance) ~= "Instance" then return end
pcall(function()
if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
local currentImage = instance.Image
if currentImage and currentImage ~= "" and currentImage ~= TARGET_IMAGE then
-- VERY STRICT CHECK: Only replace if it's a known Avatar thumbnail URL OR a confirmed small profile picture element
if isAvatarThumbnail(currentImage) or isSmallProfilePicture(instance) then
if not OriginalUI[instance] then OriginalUI[instance] = {} end
OriginalUI[instance].Image = currentImage
instance.Image = TARGET_IMAGE
end
end
end
end)
end
​local function sweepExistingUI()
task.spawn(function()
local function scanAndReplace(parentGui)
if not parentGui or typeof(parentGui) ~= "Instance" then return end
for _, instance in ipairs(parentGui:GetDescendants()) do
processTextElement(instance)
processImageElement(instance)
end
end
local playerGui = SafeGet(LocalPlayer, "PlayerGui")
if playerGui then scanAndReplace(playerGui) end
pcall(function() scanAndReplace(CoreGui) end)
end)
end
​local HideNameConnections = {}
local function SetupUIListeners()
for _, conn in ipairs(HideNameConnections) do pcall(function() conn:Disconnect() end) end
table.clear(HideNameConnections)
​local function attach(instance)
if not GetVeilVal("HideName", nil, false) then return end
processTextElement(instance)
processImageElement(instance)
​if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
table.insert(HideNameConnections, instance:GetPropertyChangedSignal("Text"):Connect(function()
if GetVeilVal("HideName", nil, false) and instance.Text ~= TARGET_NAME and instance.Text ~= "" then
processTextElement(instance)
end
end))
elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
table.insert(HideNameConnections, instance:GetPropertyChangedSignal("Image"):Connect(function()
if GetVeilVal("HideName", nil, false) and instance.Image ~= TARGET_IMAGE and instance.Image ~= "" then
processImageElement(instance)
end
end))
end
end
​local function listenGui(parentGui)
if not parentGui or typeof(parentGui) ~= "Instance" then return end
for _, descendant in ipairs(parentGui:GetDescendants()) do attach(descendant) end
table.insert(HideNameConnections, parentGui.DescendantAdded:Connect(function(descendant)
if GetVeilVal("HideName", nil, false) then
attach(descendant)
end
end))
end
​local pg = SafeGet(LocalPlayer, "PlayerGui")
if pg then listenGui(pg) end
pcall(function() listenGui(CoreGui) end)
end
​local function SetupNameHooks()
local mt = getrawmetatable(game)
if not mt then return end
local oldNewIndex = mt.__newindex
setreadonly(mt, false)
mt.__newindex = newcclosure(function(t, k, v)
if GetVeilVal("HideName", nil, false) and type(v) == "string" then
if k == "Text" and v ~= TARGET_NAME and v ~= "" then
local lowerText = string.lower(v)
local shouldReplace = false
local replacedText = v
for _, player in ipairs(Players:GetPlayers()) do
local pName = string.lower(player.Name)
local dName = string.lower(player.DisplayName)
​if (pName ~= "" and string.find(lowerText, pName, 1, true)) or
(dName ~= "" and string.find(lowerText, dName, 1, true)) then
​shouldReplace = true
if v == player.Name or v == player.DisplayName then
replacedText = TARGET_NAME
else
if player.Name ~= "" then replacedText = string.gsub(replacedText, player.Name, TARGET_NAME) end
if player.DisplayName ~= "" then replacedText = string.gsub(replacedText, player.DisplayName, TARGET_NAME) end
end
break
end
end
​if shouldReplace then
if not OriginalUI[t] then OriginalUI[t] = {} end
OriginalUI[t].Text = v
return oldNewIndex(t, k, replacedText)
end
​elseif k == "Image" and v ~= TARGET_IMAGE and v ~= "" then
-- STRICT CHECK IN METATABLE HOOK
if isAvatarThumbnail(v) or isSmallProfilePicture(t) then
if not OriginalUI[t] then OriginalUI[t] = {} end
OriginalUI[t].Image = v
return oldNewIndex(t, k, TARGET_IMAGE)
end
end
end
return oldNewIndex(t, k, v)
end)
setreadonly(mt, true)
end
pcall(SetupNameHooks)
​task.spawn(function()
SetupUIListeners()
while task.wait(0.25) do
if GetVeilVal("HideName", nil, false) then sweepExistingUI() end
end
end)
​-- ==========================================
-- SILENT AIM STATE & DRAWING API
-- ==========================================
local SpearState = { target = nil, lookVector = nil, velHistory = {} }
local defaultColor = Color3.fromRGB(0, 150, 255)
local lockedColor = Color3.fromRGB(0, 255, 120)
local blockedColor = Color3.fromRGB(255, 50, 50)
​local SpearVisuals = {}
pcall(function()
SpearVisuals.FOVCircle = Drawing.new("Circle") SpearVisuals.FOVCircle.Color = defaultColor SpearVisuals.FOVCircle.Thickness = 1.5 SpearVisuals.FOVCircle.Filled = false SpearVisuals.FOVCircle.Transparency = 1 SpearVisuals.FOVCircle.Visible = false
SpearVisuals.TrackerCircle = Drawing.new("Circle") SpearVisuals.TrackerCircle.Color = lockedColor SpearVisuals.TrackerCircle.Thickness = 2 SpearVisuals.TrackerCircle.Filled = true SpearVisuals.TrackerCircle.Transparency = 0.8 SpearVisuals.TrackerCircle.Visible = false
SpearVisuals.TrackerLine = Drawing.new("Line") SpearVisuals.TrackerLine.Color = lockedColor SpearVisuals.TrackerLine.Thickness = 1.5 SpearVisuals.TrackerLine.Transparency = 0.7 SpearVisuals.TrackerLine.Visible = false
end)
​-- ==========================================
-- SURVIVOR PISTOL STATE & VISUALS
-- ==========================================
local isShooting = false
local KILLER_MARKER_NAME = "Lookscriptkiller"
​local tracerStart = Instance.new("Part")
tracerStart.Size = Vector3.new(0.1, 0.1, 0.1) tracerStart.Transparency = 1 tracerStart.Anchored = true tracerStart.CanCollide = false tracerStart.Parent = workspace
local tracerEnd = tracerStart:Clone() tracerEnd.Parent = workspace
local att0 = Instance.new("Attachment", tracerStart) local att1 = Instance.new("Attachment", tracerEnd)
local tracerBeam = Instance.new("Beam") tracerBeam.Attachment0 = att0 tracerBeam.Attachment1 = att1 tracerBeam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)) tracerBeam.Width0 = 0.15 tracerBeam.Width1 = 0.15 tracerBeam.LightEmission = 1 tracerBeam.LightInfluence = 0 tracerBeam.FaceCamera = true tracerBeam.Enabled = false tracerBeam.Parent = tracerStart
​local PistolFOVCircle = Drawing.new("Circle") PistolFOVCircle.Color = Color3.fromRGB(255, 255, 255) PistolFOVCircle.Thickness = 1.5 PistolFOVCircle.Transparency = 0.8 PistolFOVCircle.Filled = false PistolFOVCircle.Visible = false
​local function GetEquippedGun(rightArm)
if not rightArm or typeof(rightArm) ~= "Instance" then return nil end
for _, child in ipairs(rightArm:GetChildren()) do
if (child:IsA("Model") or child:IsA("BasePart")) and not string.find(child.Name, "Weld") and not string.find(child.Name, "Grip") then
return child
end
end
return rightArm:FindFirstChildWhichIsA("Model")
end
​local function GetKillerTarget()
local myChar = LocalPlayer.Character
local myHRP = SafeGet(myChar, "HumanoidRootPart")
if not myHRP then return nil end
​local pistolFov = GetPistolVal("FovRadius", "PistolFovRadius", 300)
local pistolPart = GetPistolVal("TargetPart", "PistolTargetPart", "HumanoidRootPart")
local nearestBody = nil
local nearestScreenDistance = pistolFov
local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
​for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
local char = player.Character
if char and typeof(char) == "Instance" and (char:FindFirstChild(KILLER_MARKER_NAME, true) or IsKiller(player)) then
local body = ResolveTargetPart(char, pistolPart)
if body then
local sp, on = Camera:WorldToViewportPoint(body.Position)
if on and sp.Z > 0 then
local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
if screenDist <= nearestScreenDistance then
nearestScreenDistance = screenDist
nearestBody = body
end
end
end
end
end
end
return nearestBody
end
​-- ==========================================
-- SURVIVOR PISTOL (SAFE SHOT & INPUT)
-- ==========================================
local connectedShootButtons = {}
local function ConnectShootButton(button)
if not button or connectedShootButtons[button] then return end
connectedShootButtons[button] = true
button.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
isShooting = true
end
end)
button.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
isShooting = false
end
end)
end
​local function ScanForShootButton()
local playerGui = SafeGet(LocalPlayer, "PlayerGui")
if not playerGui then return end
local survivorMob = SafeGet(playerGui, "Survivor-mob") if not survivorMob then return end
for _, object in ipairs(survivorMob:GetDescendants()) do
if object:IsA("ImageButton") and object.Name == "Gui-mob" then ConnectShootButton(object) end
end
end
​UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = true end
end)
UserInputService.InputEnded:Connect(function(input, processed)
if input.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = false end
end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) ScanForShootButton() end)
​-- Anti Kopong & Self Damage Hook (OnClientEvent)
task.spawn(function()
local FireRemote = nil
pcall(function() FireRemote = ReplicatedStorage.Remotes.Items["Twist of Fate"].Fire end)
if FireRemote and getconnections then
for _, Connection in pairs(getconnections(FireRemote.OnClientEvent)) do
local oldFunc = Connection.Function
hookfunction(oldFunc, function(...)
if GetPistolVal("SafeShot", "SafeShotEnabled", false) then
-- Blokir balasan negatif dari server agar tidak mati sendiri/kopong
return
end
return oldFunc(...)
end)
end
end
end)
​-- ==========================================
-- ESP SYSTEM
-- ==========================================
local ESPObjects = {}
​local function createESP(player, folderToUse)
if ESPObjects[player] then return end
local highlight = Instance.new("Highlight") highlight.Name = player.Name .. "_Highlight" highlight.FillColor = defaultColor highlight.OutlineColor = defaultColor highlight.FillTransparency = 0.4 highlight.OutlineTransparency = 0 highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
local billboard = Instance.new("BillboardGui") billboard.Name = player.Name .. "_Billboard" billboard.Size = UDim2.new(0, 150, 0, 20) billboard.StudsOffset = Vector3.new(0, 3.5, 0) billboard.AlwaysOnTop = true billboard.Parent = folderToUse
local container = Instance.new("Frame") container.Name = "Container" container.Size = UDim2.new(1, 0, 1, 0) container.BackgroundTransparency = 1 container.Parent = billboard
local layout = Instance.new("UIListLayout") layout.FillDirection = Enum.FillDirection.Horizontal layout.HorizontalAlignment = Enum.HorizontalAlignment.Center layout.VerticalAlignment = Enum.VerticalAlignment.Center layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Padding = UDim.new(0, 4) layout.Parent = container
​local hpIcon = Instance.new("ImageLabel") hpIcon.Name = "HPIcon" hpIcon.Size = UDim2.new(0, 15, 0, 15) hpIcon.BackgroundTransparency = 1 hpIcon.Image = "rbxassetid://98303439166077" hpIcon.LayoutOrder = 1 hpIcon.Parent = container
local hpText = Instance.new("TextLabel") hpText.Name = "HPText" hpText.Size = UDim2.new(0, 0, 1, 0) hpText.AutomaticSize = Enum.AutomaticSize.X hpText.BackgroundTransparency = 1 hpText.Font = Enum.Font.GothamBold hpText.TextSize = 13 hpText.TextStrokeTransparency = 0 hpText.LayoutOrder = 2 hpText.Parent = container
local sep = Instance.new("TextLabel") sep.Name = "Separator" sep.Size = UDim2.new(0, 0, 1, 0) sep.AutomaticSize = Enum.AutomaticSize.X sep.BackgroundTransparency = 1 sep.Font = Enum.Font.GothamBold sep.TextSize = 13 sep.Text = "|" sep.TextColor3 = Color3.fromRGB(200, 200, 200) sep.TextStrokeTransparency = 0 sep.LayoutOrder = 3 sep.Parent = container
local distIcon = Instance.new("ImageLabel") distIcon.Name = "DistIcon" distIcon.Size = UDim2.new(0, 15, 0, 15) distIcon.BackgroundTransparency = 1 distIcon.Image = "rbxassetid://105157482942446" distIcon.LayoutOrder = 4 distIcon.Parent = container
local distText = Instance.new("TextLabel") distText.Name = "DistText" distText.Size = UDim2.new(0, 0, 1, 0) distText.AutomaticSize = Enum.AutomaticSize.X distText.BackgroundTransparency = 1 distText.Font = Enum.Font.GothamBold distText.TextSize = 13 distText.TextStrokeTransparency = 0 distText.LayoutOrder = 5 distText.Parent = container
​ESPObjects[player] = { Highlight = highlight, Billboard = billboard, Container = container }
end
​local function removeESP(player)
if ESPObjects[player] then
if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
if ESPObjects[player].Billboard then ESPObjects[player].Billboard:Destroy() end
ESPObjects[player] = nil
end
end
​-- ==========================================
-- MATH & UTILS (PARABOLA PHYSICS)
-- ==========================================
local function IsVisible(targetPart, originPart)
if not targetPart or not originPart then return false end
local origin = originPart.Position
local direction = (targetPart.Position - origin)
local raycastParams = RaycastParams.new()
local filterList = {targetPart.Parent}
if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
raycastParams.FilterDescendantsInstances = filterList
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
​local raycastResult = workspace:Raycast(origin, direction, raycastParams)
if raycastResult then return false end
return true
end
​local function solvePitch(p, d, dy)
d = math.max(d, 0.1)
local s2 = p.v0 * p.v0
local root = s2 * s2 - p.g * (p.g * d * d + 2 * dy * s2)
local outOfRange = false
if root < 0 then root = 0; outOfRange = true end
local tanTheta = (s2 - math.sqrt(root)) / (p.g * d)
local theta = math.atan(tanTheta)
local t = d / (p.v0 * math.cos(theta))
return theta, outOfRange, t
end
​local function getCharacterVelocity(char)
if not char or typeof(char) ~= "Instance" then return Vector3.zero end
local root = SafeGet(char, "HumanoidRootPart") or SafeGet(char, "Torso")
if not root or not root:IsA("BasePart") then return Vector3.zero end
​local now = os.clock()
local last = SpearState.velHistory[char]
local measured = Vector3.zero
if last and now - last.t > 0.02 then
measured = (root.Position - last.pos) / (now - last.t)
if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
end
local smooth = last and last.smooth or measured
smooth = smooth:Lerp(measured, 0.65)
SpearState.velHistory[char] = { pos = root.Position, t = now, smooth = smooth }
if smooth.Magnitude < 1 then return Vector3.zero end
return Vector3.new(smooth.X, 0, smooth.Z)
end
​Players.PlayerRemoving:Connect(function(player)
removeESP(player)
if player.Character then SpearState.velHistory[player.Character] = nil end
end)
​-- ==========================================
-- MAIN RENDER LOOP (KILLER & SURVIVOR)
-- ==========================================
RunService.RenderStepped:Connect(function()
local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local isPlayingKiller = IsKiller(LocalPlayer)
local isPlayingSurvivor = IsSurvivor(LocalPlayer)
local char = LocalPlayer.Character
local myRoot = SafeGet(char, "HumanoidRootPart")
​-- Fetch settings dynamically
local veilEnabled        = GetVeilVal("Enabled", "EnableSilentVeil", false)
local veilTargetPartName = GetVeilVal("TargetPart", "VeilTargetPart", "HumanoidRootPart")
local veilAutoPredict    = GetVeilVal("AutoPredict", nil, false)
local veilFovRadius      = GetVeilVal("FovRadius", "FOV", 300)
local veilMaxDist        = GetVeilVal("MaxTargetDistance", "MaxDist", 286)
local veilShowTracker    = GetVeilVal("ShowTracker", "Tracker", false)
local veilShowFOV        = GetVeilVal("ShowFOV", nil, false)
local veilSpearSpeed     = GetVeilVal("CustomSpearSpeed", "SpearSpeed", 165)
local veilSpearGravity   = GetVeilVal("CustomSpearGravity", "Gravity", 103)
local veilLeadMult       = GetVeilVal("LeadMultiplier", nil, 1.4)
local veilAuraSpeed      = GetVeilVal("AuraSpearSpeed", nil, 165)
local veilAuraGravity    = GetVeilVal("AuraSpearGravity", nil, 96.5)
​local pistolEnabled      = GetPistolVal("Enabled", "SilentAimPistol", false)
local pistolShowFOV      = GetPistolVal("ShowFOV", "PistolShowFOV", false)
local pistolFovRadius    = GetPistolVal("FovRadius", "PistolFovRadius", 300)
local pistolShowLaser    = GetPistolVal("Laser", "PistolShowLaser", false)
local pistolESPStun      = GetPistolVal("StunESP", "PistolESPStun", false)
​local espEnable          = GetVeilVal("ESP_Enable", "ESP", false)
local espShowHP          = GetVeilVal("ESP_ShowHP", nil, false)
local espShowDist        = GetVeilVal("ESP_ShowDistance", nil, false)
​-- ==========================================
-- KILLER SPEAR LOGIC
-- ==========================================
if isPlayingKiller and veilEnabled then
if veilShowFOV and SpearVisuals.FOVCircle then
SpearVisuals.FOVCircle.Position = center SpearVisuals.FOVCircle.Radius = veilFovRadius SpearVisuals.FOVCircle.Visible = true
elseif SpearVisuals.FOVCircle then SpearVisuals.FOVCircle.Visible = false end
​if myRoot then
local nearest = nil
local bestDist = veilFovRadius
local bestStudDist = veilMaxDist
​for _, p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer and IsSurvivor(p) then
local pc = p.Character
if pc and typeof(pc) == "Instance" then
local isDown = pc:GetAttribute("Knocked") == true or pc:GetAttribute("HookProgressDepleting") == true
if not isDown then
local hum = pc:FindFirstChildOfClass("Humanoid")
local targetPart = ResolveTargetPart(pc, veilTargetPartName)
if hum and hum.Health > 0 and targetPart then
local sp, on = Camera:WorldToViewportPoint(targetPart.Position)
if on and sp.Z > 0 then
local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
if sd < bestDist then
local studDist = (targetPart.Position - myRoot.Position).Magnitude
if studDist <= bestStudDist then
bestDist = sd
nearest = p
end
end
end
end
end
end
end
end
​if nearest then
local nChar = nearest.Character
if nChar and typeof(nChar) == "Instance" then
local tpPart = ResolveTargetPart(nChar, veilTargetPartName)
if tpPart then
local tp = tpPart.Position
local hand = SafeGet(char, "Right Arm") or SafeGet(char, "RightHand")
local origin = (hand and hand:IsA("BasePart")) and hand.Position or myRoot.Position
local dir = tp - origin
local dist = dir.Magnitude
​if dist > 0.1 and dist <= veilMaxDist then
local isAuraActive = char:GetAttribute("special") == true
local prof = isAuraActive and { v0 = veilAuraSpeed, g = veilAuraGravity, windup = 0.10, latency = 0.04, maxlead = 25, scale = veilLeadMult } or { v0 = veilSpearSpeed, g = veilSpearGravity, windup = 0.10, latency = 0.04, maxlead = 45, scale = veilLeadMult }
local aimPoint = tp
if veilAutoPredict then
local vel = getCharacterVelocity(nChar)
if vel.Magnitude > 0.5 then
local h0 = Vector3.new(dir.X, 0, dir.Z)
local _, _, tFlight = solvePitch(prof, h0.Magnitude, dir.Y)
local ping = 0.08 pcall(function() ping = math.clamp(LocalPlayer:GetNetworkPing(), 0, 0.35) end)
local delay = tFlight + prof.windup + ping + prof.latency
for i = 1, 2 do
local lead = vel * delay * prof.scale
local maxLead = math.clamp(dist * 0.6, 3, prof.maxlead)
if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
aimPoint = tp + lead
local ad = aimPoint - origin
local ah = Vector3.new(ad.X, 0, ad.Z)
local _, _, t2 = solvePitch(prof, math.max(ah.Magnitude, 0.1), ad.Y)
delay = t2 + prof.windup + ping + prof.latency
end
end
end
local adir = aimPoint - origin
local ah = Vector3.new(adir.X, 0, adir.Z)
local ahDist = ah.Magnitude
local pitch = solvePitch(prof, ahDist, adir.Y)
if ahDist > 0.001 then SpearState.lookVector = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0) else SpearState.lookVector = adir.Unit end
SpearState.target = nearest
else SpearState.target = nil SpearState.lookVector = nil end
else SpearState.target = nil SpearState.lookVector = nil end
else SpearState.target = nil SpearState.lookVector = nil end
else SpearState.target = nil SpearState.lookVector = nil end
else SpearState.target = nil SpearState.lookVector = nil end
else
SpearState.target = nil SpearState.lookVector = nil
if SpearVisuals.FOVCircle then SpearVisuals.FOVCircle.Visible = false end
end
​if isPlayingKiller and SpearState.target and veilShowTracker then
local targetChar = SpearState.target.Character
if targetChar and typeof(targetChar) == "Instance" then
local tpPart = ResolveTargetPart(targetChar, veilTargetPartName)
if tpPart then
local sp, vis = Camera:WorldToViewportPoint(tpPart.Position)
if vis and sp.Z > 0 then
local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
if screenDist <= veilFovRadius then
local isClear = IsVisible(tpPart, myRoot)
local tColor = isClear and lockedColor or blockedColor
​if SpearVisuals.TrackerLine then SpearVisuals.TrackerLine.From = center SpearVisuals.TrackerLine.To = Vector2.new(sp.X, sp.Y) SpearVisuals.TrackerLine.Color = tColor SpearVisuals.TrackerLine.Visible = true end
if SpearVisuals.TrackerCircle then local dist = myRoot and (myRoot.Position - tpPart.Position).Magnitude or 100 SpearVisuals.TrackerCircle.Position = Vector2.new(sp.X, sp.Y) SpearVisuals.TrackerCircle.Radius = math.clamp(1000 / dist, 10, 40) SpearVisuals.TrackerCircle.Color = tColor SpearVisuals.TrackerCircle.Visible = true end
else
if SpearVisuals.TrackerLine then SpearVisuals.TrackerLine.Visible = false end if SpearVisuals.TrackerCircle then SpearVisuals.TrackerCircle.Visible = false end
end
else
if SpearVisuals.TrackerLine then SpearVisuals.TrackerLine.Visible = false end if SpearVisuals.TrackerCircle then SpearVisuals.TrackerCircle.Visible = false end
end
else
if SpearVisuals.TrackerLine then SpearVisuals.TrackerLine.Visible = false end if SpearVisuals.TrackerCircle then SpearVisuals.TrackerCircle.Visible = false end
end
else
if SpearVisuals.TrackerLine then SpearVisuals.TrackerLine.Visible = false end if SpearVisuals.TrackerCircle then SpearVisuals.TrackerCircle.Visible = false end
end
else
if SpearVisuals.TrackerLine then SpearVisuals.TrackerLine.Visible = false end if SpearVisuals.TrackerCircle then SpearVisuals.TrackerCircle.Visible = false end
end
​-- ==========================================
-- SURVIVOR PISTOL LOGIC & VISUALS
-- ==========================================
if isPlayingSurvivor then
local targetBody = GetKillerTarget()
​if pistolEnabled and pistolShowFOV then
PistolFOVCircle.Position = center
PistolFOVCircle.Radius = pistolFovRadius
PistolFOVCircle.Visible = true
else PistolFOVCircle.Visible = false end
​if isShooting and pistolEnabled and pistolShowLaser and myRoot and targetBody then
local twist = SafeGet(char, "Twist of Fate")
local rightArm = twist and SafeGet(twist, "Right Arm")
local gun = rightArm and GetEquippedGun(rightArm)
tracerStart.Position = (gun and gun:GetPivot().Position) or (myRoot.Position + Vector3.new(0, 1, 0))
tracerEnd.Position = targetBody.Position
tracerBeam.Enabled = true
else tracerBeam.Enabled = false end
​-- Logika ESP Stun Killer yang ketat (Anti-False Positive)
if pistolESPStun then
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
local pChar = player.Character
if pChar and typeof(pChar) == "Instance" and (pChar:FindFirstChild(KILLER_MARKER_NAME, true) or IsKiller(player)) then
local head = SafeGet(pChar, "Head")
local hum = SafeGet(pChar, "Humanoid")
if head and hum and hum.Health > 0 then
local espUI = SafeGet(KillerESPFolder_Pistol, player.Name)
if not espUI then
espUI = Instance.new("BillboardGui") espUI.Name = player.Name espUI.Size = UDim2.new(0, 200, 0, 50) espUI.StudsOffset = Vector3.new(0, 2.5, 0) espUI.AlwaysOnTop = true espUI.Parent = KillerESPFolder_Pistol
local textLabel = Instance.new("TextLabel") textLabel.Name = "StatusText" textLabel.Size = UDim2.new(1, 0, 1, 0) textLabel.BackgroundTransparency = 1 textLabel.Font = Enum.Font.GothamBlack textLabel.TextStrokeTransparency = 0 textLabel.Parent = espUI
end
espUI.Adornee = head
​local isStunned = false
if hum.WalkSpeed < 6 then isStunned = true
elseif pChar:GetAttribute("Stunned") == true or pChar:GetAttribute("IsStunned") == true then isStunned = true
elseif SafeGet(pChar, "Stunned") ~= nil or SafeGet(pChar, "Stun") ~= nil then isStunned = true end
​local txt = espUI.StatusText
if isStunned then txt.Text = "⚡ STUNNED ⚡" txt.TextColor3 = Color3.fromRGB(255, 255, 0) txt.TextStrokeColor3 = Color3.fromRGB(200, 0, 0) txt.TextSize = 12
else txt.Text = "💀 KILLER 💀" txt.TextColor3 = Color3.fromRGB(255, 50, 50) txt.TextStrokeColor3 = Color3.fromRGB(150, 0, 0) txt.TextSize = 18 end
else
local espUI = SafeGet(KillerESPFolder_Pistol, player.Name) if espUI then espUI:Destroy() end
end
else
local espUI = SafeGet(KillerESPFolder_Pistol, player.Name) if espUI then espUI:Destroy() end
end
end
end
else
KillerESPFolder_Pistol:ClearAllChildren()
end
else
PistolFOVCircle.Visible = false
tracerBeam.Enabled = false
KillerESPFolder_Pistol:ClearAllChildren()
end
​-- ==========================================
-- KILLER ESP RENDERING
-- ==========================================
if isPlayingKiller then
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and IsSurvivor(player) then
local pChar = player.Character
if espEnable and pChar and typeof(pChar) == "Instance" then
local targetHRP = SafeGet(pChar, "HumanoidRootPart")
local hum = SafeGet(pChar, "Humanoid")
​if targetHRP and hum and hum.Health > 0 then
createESP(player, ESPFolder)
local esp = ESPObjects[player]
local container = esp.Container
​if esp.Highlight.Parent ~= pChar then esp.Highlight.Parent = pChar end
local head = SafeGet(pChar, "Head") if head then esp.Billboard.Adornee = head end
if esp.Billboard.Parent ~= ESPFolder then esp.Billboard.Parent = ESPFolder end
​local isClear = IsVisible(targetHRP, myRoot)
local isLocked = (player == SpearState.target)
local espHighlightColor = defaultColor
​if isLocked then espHighlightColor = isClear and lockedColor or blockedColor
else espHighlightColor = isClear and defaultColor or blockedColor end
​esp.Highlight.FillColor = espHighlightColor
esp.Highlight.OutlineColor = espHighlightColor
​local dist = myRoot and math.floor((myRoot.Position - targetHRP.Position).Magnitude) or 0
local hp = math.floor(hum.Health)
​local hpColor = Color3.fromRGB(0, 191, 255) if hp <= 20 then hpColor = Color3.fromRGB(255, 69, 0) elseif hp <= 60 then hpColor = Color3.fromRGB(255, 165, 0) end
local distColor = Color3.fromRGB(0, 191, 255) if dist > 210 then distColor = Color3.fromRGB(255, 69, 0) elseif dist >= 111 then distColor = Color3.fromRGB(255, 165, 0) end
​if espShowHP then
container.HPIcon.Visible = true container.HPText.Visible = true container.HPIcon.ImageColor3 = hpColor container.HPText.TextColor3 = hpColor container.HPText.Text = tostring(hp)
else container.HPIcon.Visible = false container.HPText.Visible = false end
​if espShowDist then
container.DistIcon.Visible = true container.DistText.Visible = true container.DistIcon.ImageColor3 = distColor container.DistText.TextColor3 = distColor container.DistText.Text = tostring(dist) .. "m"
else container.DistIcon.Visible = false container.DistText.Visible = false end
​container.Separator.Visible = (espShowHP and espShowDist)
else
removeESP(player)
end
else
removeESP(player)
end
else
removeESP(player)
end
end
else
for _, player in ipairs(Players:GetPlayers()) do removeESP(player) end
end
end)
​-- ==========================================
-- NAMECALL HOOK (SPEAR & PISTOL SILENT AIM)
-- ==========================================
local function SetupNamecallHook()
local mt = getrawmetatable(game)
if not mt then return end
local oldNamecall = mt.__namecall
​setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
local method = getnamecallmethod()
local args = {...}
​if method == "FireServer" and typeof(self) == "Instance" then
local selfName = string.lower(self.Name)
​-- KILLER SPEAR HOOK
if selfName == "spearthrow" and IsKiller(LocalPlayer) then
local veilEnabled = GetVeilVal("Enabled", "EnableSilentVeil", false)
if veilEnabled and SpearState.lookVector and typeof(SpearState.lookVector) == "Vector3" then
if SpearState.lookVector.X == SpearState.lookVector.X and SpearState.lookVector.Magnitude > 0 then
args[1] = SpearState.lookVector
end
end
return oldNamecall(self, unpack(args))
end
​-- SURVIVOR PISTOL HOOK
local pistolEnabled = GetPistolVal("Enabled", "SilentAimPistol", false)
if selfName == "fire" and pistolEnabled and self.Parent and self.Parent.Name == "Twist of Fate" then
local myChar = LocalPlayer.Character
local myHRP = SafeGet(myChar, "HumanoidRootPart")
local targetBody = GetKillerTarget()
if targetBody and myHRP then
local rawDirection = targetBody.Position - myHRP.Position
if rawDirection.Magnitude > 0.001 then
args[2] = rawDirection.Unit
return oldNamecall(self, unpack(args))
end
end
end
end
return oldNamecall(self, ...)
end)
setreadonly(mt, true)
end
pcall(SetupNamecallHook)