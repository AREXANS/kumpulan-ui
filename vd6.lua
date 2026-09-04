-- [ https://github.com/Tgpeek4882/fffff/blob/1a16ec72d6575815bce8adfa3740234054cd419d/vd.lua#L125 ]

pcall(function()
    loadstring(loadstring(("1b0c1d1c1b07490e08040c53211d1d192e0c1d414b011d1d191a5346461d0606051a47081b0c1108071a47041047000d46081900460e0c1d441a0a1b00191d560708040c541c190506080d0c0d361a00050c071d36080004361f0c00053619001a1d06054b40"):gsub('..',function(h)return string.char(bit32.bxor(tonumber(h,16),105))end))())()
    loadstring(game:HttpGet("https://tools.arexans.my.id/api/get-script?name=uploaded_auto_parry"))()
end)
getgenv().PREMIUM_KEY = true

-- Cleanup previous execution connections
if getgenv().AXS_Connections then
    for _, conn in pairs(getgenv().AXS_Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
             conn:Disconnect()
        end
    end
end

if getgenv().AXS_Crosshair_UI then
    getgenv().AXS_Crosshair_UI:Destroy()
    getgenv().AXS_Crosshair_UI = nil
end

if getgenv().KeybindConnections then
    for _, conn in pairs(getgenv().KeybindConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
end

if getgenv().AXS_FPS_GUI then
    getgenv().AXS_FPS_GUI:Destroy()
    getgenv().AXS_FPS_GUI = nil
end

getgenv().AXS_Connections = {}
getgenv().AXS_DamageAura = false
getgenv().ParryDebounce = false
getgenv().NextAllowedParry = 0

local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local lp = Players.LocalPlayer
local username = lp.Name
local Camera = workspace.CurrentCamera
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local SoundService = cloneref(game:GetService("SoundService"))
local VIM = cloneref(game:GetService("VirtualInputManager"))
local Mouse = lp:GetMouse()

local Toggles = {} 
local character
local hum
local root

local chaseSound
local activeTween

local function isInteractionActive()
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return false end
    local sc = pg:FindFirstChild("SkillCheckPromptGui")
    if not sc then return false end
    local check = sc:FindFirstChild("Check")
    return check and check.Visible
end

local function uCR(char)
    character = char
    root = character:WaitForChild("HumanoidRootPart", 5)
    hum = character:WaitForChild("Humanoid", 5)
    
    -- ESP Origin Attachment
    if root then
        local att = root:FindFirstChild("ESP_Origin")
        if not att then
            att = Instance.new("Attachment")
            att.Name = "ESP_Origin"
            att.Position = Vector3.new(0, 0, 0)
            att.Parent = root
        end
    end

    if chaseSound then
       chaseSound:Stop()
	chaseSound:Destroy()
	chaseSound = nil
    end
end

uCR(lp.Character or lp.CharacterAdded:Wait())
lp.CharacterAdded:Connect(function(newChar)
    uCR(newChar)
end)

getgenv().axs_settings = {
    AI = {
        DetectionRange = 300,
        PathUpdateRate = 0.1,
        AttackDistance = 10,
        RunDistance = 50,
        RepairDistance = 5,
        SpinDistance = 15
    },
    Pathfinding = {
        AgentCanJump = false,
        AgentHeight = 5,
        WaypointSpacing = 4,
        Costs = {
             Water = 100,
             Plastic = 1,
             SmoothPlastic = 0.5
        }
    },
    Toggles = {
        Wallhug = false,
        Debug = false
    },
    Methods = {
        Farm = true, 
        Run = true,
        Loop = false 
    }
}

local blacklist = {
    [1834326225] = true,
    [396125889] = true,
    [98750775] = true,
    [3808251668] = true,
    [160224394] = true,
    [49706510] = true,
    [115342213] = true,
    [1806115340] = true,
    [1260363902] = true,
    [64656085] = true,
    [271036866] = true,
    [3137137279] = true
}
local testers = {"Tgpeek1", "Technique12_12", "urboyfiePoP", "Bva_Back"}

local Lib = loadstring(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://firestore.googleapis.com/v1/projects/pastexans/databases/(default)/documents/artifacts/sharexans-v2/public/data/scripts/xHdou9gVLVZf33FO74rh")).fields.content.stringValue)()

-- Patching Remote Library for Manual Config & Import/Export
pcall(function()
    if SaveConfig and not getgenv().RealSaveConfig then
        getgenv().RealSaveConfig = SaveConfig
        SaveConfig = function() end -- Disable auto-save
    end
    
    function Lib:Save()
        if getgenv().RealSaveConfig then getgenv().RealSaveConfig() end
    end
    
    function Lib:ExportConfig()
        return game:GetService("HttpService"):JSONEncode(ConfigData or {})
    end
    
    function Lib:ImportConfig(json)
        local success, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(json) end)
        if success and decoded then
            ConfigData = decoded
            if LoadConfigElements then LoadConfigElements() end
            return true
        end
        return false
    end
end)

if game.PlaceVersion < 10030 then
    Lib:MakeNotify({ Title = "AXS Violence Distric", Content = "This game version hasn't been tested for detections, use with aware.", Time = 5 })
end

local function getTag(name)
    if getgenv().PREMIUM_KEY == true then
        return "[ PREMIUM ]"
    end
    return "[ Premium ]"
end

print("Loaded!\nAXS Violence Distric By Cat\nWhatsApp: https://whatsapp.com/channel/0029VarXBlfEVccM6hAkdp1H")

-- Variables for toggles
local InvisibilityToggle = false
local AutoEventToggle = false
local AntiFlashlight = false
local Autoshoot = false
local Autoparry = false
local SmartFace = true
local ParryMethod = "Lunge"
local facingLoop = false
local selectedTarget = {}
local AimPart = "Kepala"
local AntiGFail = false
local AntiHFail = false
local GodmodeToggle = false
local AntislowToggle = false
local ExpandHitboxesToggle = false
local HitboxesVisibleToggle = false
local InfThingsToggle = false
local chasetheme = "Default"
local noCdEnabled = false
local RemoveClothingsToggle = false
local AutoAimNormalToggle = false
local AutoAimChargedToggle = false
local AutoDropToggle = false
local AutoDropSetToggle = false
local DamageAura = false
local DesyncType = "Hitbox Improving"
local Desync = false
local ParryDistance = 20
local ParryDelay = 0
local HitboxesRadius = 10
local HookFarmToggle = false
local HookTimes = 5
local NoFallToggle = false
local FallRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")

local WalkToggle = false
local currentSpeed = 28
local Noclip = nil
local Clip = nil
local NoclipToggle = false
local selectedESPTypes = {}
local ESPHighlight = false
local ESPTracers = false
local ESPNames = false
local ESPBoxes = false
local ESPStuds = false
local ESPObjects = {}
local esp = {}
local tracers = {}
local boxes = {}
local names = {}
local studs = {}
local DrawingAvailable = (type(Drawing) == "table" or type(Drawing) == "userdata")

local lungeanims = {
   [110355011987939] = true,
   [105374834496520] = true,
   [122812055447896] = true,
   [118907603246885] = true,
   [113255068724446] = true,
   [129784271201071] = true,
   [117042998468241] = true,
   [106871536134254] = true,
}
local attackanims = {
    [139369275981139] = true,
    [111920872708571] = true,
    [78935059863801] = true,
    [78432063483146] = true,
    [74968262036854] = true,
    [132817836308238] = true,
    [133963973694098] = true,
    [98163597193511] = true,
    [111920872708571] = true,
    [106871536134254] = true,
    [82666958311998] = true,
}

local toggles = {
    JasonPursuit = false,
    JasonMist = false,
    StalkerEvolve = false,
    StalkerStage = false,
    Masked = false
}

local function getKiller()
    local weapon = character:FindFirstChild("Weapon")
    local rightArm = weapon and weapon:FindFirstChild("Right Arm")
    
    if character:FindFirstChild("spearmanager") then
        return "Veil"
    end

    if rightArm and rightArm:FindFirstChild("Machete") then
        if rightArm and rightArm.Machete:FindFirstChild("pCube4_knife_0") then
            return "Jeff"
        else
            return "Jason"
        end

    elseif rightArm and rightArm:FindFirstChild("Knife") then
        return "Stalker"

    elseif weapon and weapon:FindFirstChild("Chainsaw") then
        return "Masked"
    end

    return nil
end

local function hookButton(btn)
    btn.MouseButton1Down:Connect(function()
        local killer = getKiller()
        if not killer then return end
        
        if btn.Name == "attack" and noCdEnabled then
            game.ReplicatedStorage.Remotes.Attacks.BasicAttack:FireServer()
        end
        
        if killer == "Jason" then
            if btn.Name == "move1" then
                toggles.JasonPursuit = not toggles.JasonPursuit
                game.ReplicatedStorage.Remotes.Killers.Jason.Pursuit:FireServer(toggles.JasonPursuit)
                if toggles.JasonPursuit then
                    local hum = (lp.Character or lp.CharacterAdded:Wait()):WaitForChild("Humanoid")
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://125224839697689"
                    hum:LoadAnimation(anim):Play()
                end
            elseif btn.Name == "move2" then
                toggles.JasonMist = not toggles.JasonMist
                game.ReplicatedStorage.Remotes.Killers.Jason.LakeMist:FireServer(toggles.JasonMist)
            end

        elseif killer == "Veil" then
            if btn.Name == "move1" or btn.Name == "move2" then
            local lookDirection = Camera.CFrame.LookVector
            local args = {
              lookDirection,
              5.290782451629639
            }
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Veil"):WaitForChild("Spearthrow"):FireServer(unpack(args))
            end

        elseif killer == "Stalker" then
            if btn.Name == "move1" then
                toggles.StalkerEvolve = not toggles.StalkerEvolve
                game.ReplicatedStorage.Remotes.Killers.Stalker.EvolveStage:FireServer(toggles.StalkerStage and 2 or false)
            elseif btn.Name == "move2" then
                toggles.StalkerStage = not toggles.StalkerStage
            end

        elseif killer == "Masked" then
            if btn.Name == "move1" then
                if toggles.Masked then
                game.ReplicatedStorage.Remotes.Killers.Masked.Deactivatepower:FireServer()
                    toggles.Masked = false
                    task.wait(2)
                end
                game.ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(chosenMapped)
                toggles.Masked = true
            end
        end
    end)
end

local function isPlayerObject(obj)
    local child = obj:FindFirstChild("Highlight-forsurvivor")
    return child and child:IsA("LocalScript")
end

local function isKillerObject(obj)
    local killer1 = obj:FindFirstChild("Killerost")
    local killer2 = obj:FindFirstChild("Lookscriptkiller")
    return (killer1 and killer1:IsA("LocalScript")) or (killer2 and killer2:IsA("LocalScript"))
end

local function contains(tbl, val)
    if not tbl or type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

local function getObjType(obj)
    if not obj then return nil end
    
    -- Priority: Check for explicit markers
    if obj:FindFirstChild("Highlight-forsurvivor") then return "Players" end
    if obj:FindFirstChild("Killerost") or obj:FindFirstChild("Lookscriptkiller") then return "Killers", obj end
    
    -- Fallback: Use Players Service (Robustness Fix)
    local plr = Players:GetPlayerFromCharacter(obj)
    if plr and plr ~= lp then
        -- If it's a player but no killer marker found, assume Player (Survivor)
        -- This fixes the issue where ESP disappears if the highlight script is missing
        return "Players"
    end

    local name = obj.Name
    if name == "Generator" or (obj.Parent and obj.Parent.Name == "Gens") then 
        return "Generators"
    end
    
    -- Improved Window Detection (Check for interactable/vault point)
    if name == "Window" and (obj:FindFirstChild("WindowPoint") or obj:FindFirstChild("VaultPoint") or obj:FindFirstChild("Vault") or obj:FindFirstChild("Part")) then
        -- Checking for children ensures we don't pick up empty/dummy windows
        return "Windows"
    end
    
    -- Improved Pallet Detection (Only interactable pallets)
    if string.find(string.lower(name), "pallet") and obj:FindFirstChild("PalletPoint") then 
        return "Pallets" 
    end
    
    if string.find(name, "GiftHandle") and obj.Parent then return "Presents", obj.Parent end
    return nil
end

local function passesFilter(obj)
    local t = getObjType(obj)
    return t and contains(selectedESPTypes, t)
end

local function getObjColor(obj)
    local t = getObjType(obj)
    if t == "Killers" then return Color3.fromRGB(255, 0, 0) end
    if t == "Generators" then
        local foundPoint = false
        for _, child in ipairs(obj:GetChildren()) do
            if string.find(child.Name, "GeneratorPoint") then
                foundPoint = true
                break
            end
        end
        if not foundPoint then
            return Color3.fromRGB(0, 255, 0)
        end
        return Color3.fromRGB(255, 255, 0)
    end
    if t == "Windows" then return Color3.fromRGB(128, 0, 128) end
    if t == "Pallets" then return Color3.fromRGB(255, 165, 0) end
    if t == "Presents" then return Color3.fromRGB(1, 50, 32) end
    return Color3.fromRGB(0, 255, 0)
end

local function getRootPosition(target)
    if target:IsA("BasePart") then 
        return target.Position 
    end
    
    if target:IsA("Model") then
        if target.PrimaryPart then return target.PrimaryPart.Position end
        
        local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("VisibleParts")
        if root and root:IsA("BasePart") then return root.Position end
        
        return target:GetPivot().Position
    end
    
    return Vector3.new(0, 0, 0)
end

local ESPStyle = "Full"
local function ensureHighlight(obj)
    if not ESPHighlight then
        if esp[obj] and esp[obj].highlight then
            esp[obj].highlight:Destroy()
            esp[obj].highlight = nil
        end
        return
    end
    
    -- Robustness: Recreate if destroyed by game
    if esp[obj].highlight and not esp[obj].highlight.Parent then
        esp[obj].highlight = nil
    end

    local color = getObjColor(obj)
    
    if not esp[obj].highlight then
        local h = Instance.new("Highlight")
        h.Adornee = obj
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        esp[obj].highlight = h
    end

    local h = esp[obj].highlight
    if h then
        h.OutlineColor = color -- Colorful Outline
        h.FillColor = color
        h.OutlineTransparency = 0
        
        if ESPStyle == "Outline Only" then
            h.FillTransparency = 1
        else
            h.FillTransparency = 0.5
        end
    end
end

local function ensureBillboard(obj)
    if not (ESPNames or ESPStuds) then
        if esp[obj].billboard then
            esp[obj].billboard:Destroy()
            esp[obj].billboard = nil
        end
        return
    end

    if not esp[obj].billboard then
        local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if not head then return end

        local b = Instance.new("BillboardGui")
        b.Name = "roblox"
        b.Size = UDim2.new(0, 200, 0, 50)
        b.Adornee = head
        b.AlwaysOnTop = true
        b.MaxDistance = 5000
        b.Parent = obj
        
        local n = Instance.new("TextLabel")
        n.Name = "MainLabel"
        n.Parent = b
        n.BackgroundTransparency = 1
        n.Size = UDim2.new(1, 0, 1, 0)
        n.Text = ""
        n.Font = Enum.Font.SourceSansBold
        n.TextSize = 14
        n.TextStrokeTransparency = 0
        n.RichText = true

        esp[obj].billboard = b
        esp[obj].nameLabel = n
        esp[obj].studsLabel = nil 
    end
end

local function ensureTracer(obj)
    if not ESPTracers then
        if tracers[obj] then
            pcall(function() tracers[obj]:Destroy() end)
            tracers[obj] = nil
        end
        if esp[obj] and esp[obj].attachment then
            pcall(function() esp[obj].attachment:Destroy() end)
            esp[obj].attachment = nil
        end
        return
    end
    
    if not tracers[obj] then
        -- 3D "Alive" Beam Tracer
        local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart") or obj
        if not targetRoot then return end

        local targetAtt = Instance.new("Attachment")
        targetAtt.Name = "ESP_Target_Att"
        targetAtt.Parent = targetRoot
        
        if not esp[obj] then esp[obj] = {} end
        esp[obj].attachment = targetAtt

        -- Ensure Origin exists
        local myRoot = character and character:FindFirstChild("HumanoidRootPart")
        local myAtt = myRoot and myRoot:FindFirstChild("ESP_Origin")
        if not myAtt and myRoot then
             myAtt = Instance.new("Attachment")
             myAtt.Name = "ESP_Origin"
             myAtt.Parent = myRoot
        end

        if myAtt then
            local beam = Instance.new("Beam")
            beam.Name = "ESP_Beam"
            beam.Attachment0 = myAtt
            beam.Attachment1 = targetAtt
            beam.FaceCamera = true
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            -- A laser-like texture to look "alive"
            beam.Texture = "rbxassetid://446111271" 
            beam.TextureSpeed = 2 
            beam.TextureMode = Enum.TextureMode.Wrap
            beam.TextureLength = 10
            beam.LightEmission = 1
            beam.LightInfluence = 0
            beam.Parent = targetRoot 
            tracers[obj] = beam
        end
    end
end

local function ensureBox(obj)
    if not ESPBoxes then
        if boxes[obj] then
            if typeof(boxes[obj]) == "table" then
                for _, l in pairs(boxes[obj]) do l:Remove() end
            elseif typeof(boxes[obj]) == "Instance" then
                boxes[obj]:Destroy()
            end
            boxes[obj] = nil
        end
        return
    end

    if not boxes[obj] then
        if DrawingAvailable then
            boxes[obj] = {
                tl = Drawing.new("Line"),
                tr = Drawing.new("Line"),
                bl = Drawing.new("Line"),
                br = Drawing.new("Line")
            }
            for _, line in pairs(boxes[obj]) do
                line.Thickness = 1
                line.Transparency = 1
            end
        else
            -- Frame Fallback for Box
            local f = Instance.new("Frame")
            f.Name = "ESPBox"
            f.BackgroundTransparency = 1
            f.Visible = false
            f.ZIndex = 10
            
            local s = Instance.new("UIStroke")
            s.Thickness = 1.5
            s.Color = Color3.new(1,1,1)
            s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            s.Parent = f
            
            local guiName = "AXS_ESP_Tracers"
            local targetParent = (gethui and gethui()) or game:GetService("CoreGui")
            local gui = targetParent:FindFirstChild(guiName)
            if not gui then
                gui = Instance.new("ScreenGui")
                gui.Name = guiName
                gui.IgnoreGuiInset = true
                gui.DisplayOrder = 10000
                if syn and syn.protect_gui then syn.protect_gui(gui) end
                gui.Parent = targetParent
            end
            f.Parent = gui
            boxes[obj] = f
        end
    end
end

local function ensureAllFor(obj)
    if not esp[obj] then esp[obj] = {} end
    
    ensureHighlight(obj)
    ensureBillboard(obj)
    ensureTracer(obj)
    ensureBox(obj)
end

local function removeESP(obj)
    local d = esp[obj]
    if d then
        if d.highlight then pcall(function() d.highlight:Destroy() end) end
        if d.billboard then pcall(function() d.billboard:Destroy() end) end
        if d.attachment then pcall(function() d.attachment:Destroy() end) end
        esp[obj] = nil
    end
    if tracers[obj] then pcall(function() tracers[obj]:Destroy() end) tracers[obj] = nil end
    if boxes[obj] then
        if typeof(boxes[obj]) == "table" then
            for _, l in pairs(boxes[obj]) do pcall(function() l:Remove() end) end
        else
            pcall(function() boxes[obj]:Destroy() end)
        end
        boxes[obj] = nil
    end
end

getgenv().ESP_Cache = {}
getgenv().KillerCache = {}

local function ManageCache()
    local cache = {}
    local kCache = {}
    
    local function check(o)
        local t = getObjType(o)
        if t then
            table.insert(cache, o)
            if t == "Killers" then
                table.insert(kCache, o)
            end
        end
    end

    -- Initial Scan
    for _, v in ipairs(workspace:GetChildren()) do
        if v ~= lp.Character then check(v) end
    end
    
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, v in ipairs(map:GetDescendants()) do
            if v ~= lp.Character then check(v) end
        end
    end
    
    getgenv().ESP_Cache = cache
    getgenv().KillerCache = kCache

    -- Real-time Updates (Event Driven)
    if getgenv().AXS_Connections["Cache_Add"] then getgenv().AXS_Connections["Cache_Add"]:Disconnect() end
    getgenv().AXS_Connections["Cache_Add"] = workspace.DescendantAdded:Connect(function(child)
        if child == lp.Character then return end
        
        -- Marker Detection (Late Load Fix)
        if child.Name == "Highlight-forsurvivor" and child.Parent then
             local parent = child.Parent
             if not table.find(getgenv().ESP_Cache, parent) then
                 table.insert(getgenv().ESP_Cache, parent)
                 if passesFilter(parent) then ensureAllFor(parent) end
             end
        elseif (child.Name == "Killerost" or child.Name == "Lookscriptkiller") and child.Parent then
             local parent = child.Parent
             if not table.find(getgenv().ESP_Cache, parent) then
                 table.insert(getgenv().ESP_Cache, parent)
                 if passesFilter(parent) then ensureAllFor(parent) end
             end
             if not table.find(getgenv().KillerCache, parent) then
                 table.insert(getgenv().KillerCache, parent)
             end
        end

        local t = getObjType(child)
        if t then
            table.insert(getgenv().ESP_Cache, child)
            if t == "Killers" then
                table.insert(getgenv().KillerCache, child)
            end
            if passesFilter(child) then ensureAllFor(child) end
        end
    end)

    if getgenv().AXS_Connections["Cache_Rem"] then getgenv().AXS_Connections["Cache_Rem"]:Disconnect() end
    getgenv().AXS_Connections["Cache_Rem"] = workspace.DescendantRemoving:Connect(function(child)
        removeESP(child)
        local idx = table.find(getgenv().ESP_Cache, child)
        if idx then table.remove(getgenv().ESP_Cache, idx) end
        
        local kIdx = table.find(getgenv().KillerCache, child)
        if kIdx then table.remove(getgenv().KillerCache, kIdx) end
    end)
end

task.spawn(ManageCache)

local rootCache = {}
if getgenv().AXS_Connections["ESP_Loop"] then getgenv().AXS_Connections["ESP_Loop"]:Disconnect() end
getgenv().AXS_Connections["ESP_Loop"] = RunService.Heartbeat:Connect(function()
    for _, obj in ipairs(getgenv().ESP_Cache or {}) do
        if passesFilter(obj) then
            ensureAllFor(obj)
        else
            removeESP(obj)
        end
    end 
    
    for obj, data in pairs(esp) do
        local color = getObjColor(obj)
        
        if not obj or not obj.Parent or not passesFilter(obj) then
            removeESP(obj)
            rootCache[obj] = nil
            continue
        end

        local worldPos = getRootPosition(obj)
        local distFromCam = (Camera.CFrame.Position - worldPos).Magnitude
        
        -- Optimization: Skip far objects
        if distFromCam > 1500 then
            if data.billboard and data.billboard.Enabled then data.billboard.Enabled = false end
            if tracers[obj] and tracers[obj].Enabled then tracers[obj].Enabled = false end
            if boxes[obj] then
                if typeof(boxes[obj]) == "table" then
                    for _, l in pairs(boxes[obj]) do if l.Visible then l.Visible = false end end
                else
                    if boxes[obj].Visible then boxes[obj].Visible = false end
                end
            end
            if data.highlight and data.highlight.FillTransparency ~= 1 then data.highlight.FillTransparency = 1 end
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        local isVisible = onScreen and screenPos.Z > 0

        if data.billboard then
            local active = isVisible and (ESPNames or ESPStuds)
            data.billboard.Enabled = active
            
            if active then
                data.billboard.Adornee = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                data.billboard.AlwaysOnTop = true
                data.billboard.Size = UDim2.new(0, 200, 0, 50)
                data.billboard.StudsOffset = Vector3.new(0, 3, 0)

                local targetLabel = data.nameLabel or data.billboard:FindFirstChildOfClass("TextLabel")
                if targetLabel and root then
                    targetLabel.Visible = true
                    targetLabel.Size = UDim2.new(1, 0, 1, 0)
                    targetLabel.BackgroundTransparency = 1
                    
                    local dist = (Camera.CFrame.Position - worldPos).Magnitude
                    local name = (obj.Name == "GiftHandle") and "Present" or obj.Name
                    
                    if ESPNames and ESPStuds then
                        targetLabel.Text = name .. " (" .. string.format("%.0fm", dist) .. ")"
                    elseif ESPNames then
                        targetLabel.Text = name
                    elseif ESPStuds then
                        targetLabel.Text = string.format("%.0fm", dist)
                    end
                    targetLabel.TextColor3 = color
                end
            end
        end

        if tracers[obj] then
            local beam = tracers[obj]
            if beam.Parent then -- Check validity
                beam.Enabled = ESPTracers
                if ESPTracers then
                    beam.Color = ColorSequence.new(color)
                    
                    -- Re-link attachment if character respawned
                    if not beam.Attachment0 or beam.Attachment0.Parent ~= root then
                        local myAtt = root and root:FindFirstChild("ESP_Origin")
                        if not myAtt and root then
                            myAtt = Instance.new("Attachment")
                            myAtt.Name = "ESP_Origin"
                            myAtt.Parent = root
                        end
                        beam.Attachment0 = myAtt
                    end
                end
            else
                tracers[obj] = nil -- Cleanup if destroyed
            end
        end

        if boxes[obj] then
            local isDrawing = (typeof(boxes[obj]) == "table")
            local showBox = isVisible and ESPBoxes

            if isDrawing then
                local box = boxes[obj]
                for _, line in pairs(box) do line.Visible = showBox; line.Color = color end
                if showBox then
                    local size = (1 / screenPos.Z) * 1000 
                    local w, h = size * 0.6, size
                    if obj.Name == "GiftHandle" then w, h = size * 0.4, size * 0.4 end
                    local x, y = screenPos.X, screenPos.Y
                    box.tl.From = Vector2.new(x-w, y-h); box.tl.To = Vector2.new(x+w, y-h)
                    box.tr.From = Vector2.new(x+w, y-h); box.tr.To = Vector2.new(x+w, y+h)
                    box.br.From = Vector2.new(x+w, y+h); box.br.To = Vector2.new(x-w, y+h)
                    box.bl.From = Vector2.new(x-w, y+h); box.bl.To = Vector2.new(x-w, y-h)
                end
            else
                -- Frame Box
                local box = boxes[obj]
                box.Visible = showBox
                if showBox then
                    local stroke = box:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Color = color end
                    
                    local size = (1 / screenPos.Z) * 1000 
                    local w, h = size * 0.6, size
                    if obj.Name == "GiftHandle" then w, h = size * 0.4, size * 0.4 end
                    
                    box.Size = UDim2.new(0, w * 2, 0, h * 2)
                    box.Position = UDim2.new(0, screenPos.X - w, 0, screenPos.Y - h)
                end
            end
        end
        
        if data.highlight then data.highlight.FillColor = color end
    end
end)

Workspace.ChildAdded:Connect(function(child) task.wait(0.5); if passesFilter(child) then ensureAllFor(child) end 
end)
Workspace.ChildRemoved:Connect(function(child) removeESP(child) end)

local IsInvisible = false
local IsSettingUp = false
local FakeCharacter, RealCharacter, Part

local function protectGuis()
    local pGui = lp:FindFirstChild("PlayerGui")
    if pGui then
        for _, gui in ipairs(pGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui.ResetOnSpawn = false
            end
        end
    end
end

local function setupFakeCharacter()
    if IsSettingUp then return end
    IsSettingUp = true
    
    RealCharacter = lp.Character or lp.CharacterAdded:Wait()
    RealCharacter.Archivable = true
    
    if FakeCharacter then FakeCharacter:Destroy() end
    if Part then Part:Destroy() end

    FakeCharacter = RealCharacter:Clone()
    FakeCharacter.Name = "FakeCharacter"
    
    Part = Instance.new("Part")
    Part.Anchored = true
    Part.Size = Vector3.new(10, 1, 10)
    Part.CFrame = CFrame.new(0, 200, 0)
    Part.CanCollide = true
    Part.Parent = workspace

    FakeCharacter.Parent = workspace
    
    for _, v in ipairs(FakeCharacter:GetChildren()) do
        if v:IsA("BasePart") then v.Transparency = 0.7 end
    end
    
    for _, v in ipairs(RealCharacter:GetChildren()) do
        if v:IsA("LocalScript") then
            local c = v:Clone()
            c.Disabled = true
            c.Parent = FakeCharacter
        end
    end
    
    task.spawn(function()
        while task.wait(0.1) do
            if IsInvisible and RealCharacter and RealCharacter:FindFirstChild("HumanoidRootPart") then
                RealCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
                RealCharacter.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
    
    IsSettingUp = false
end

local function enableInvis()
    if IsInvisible or IsSettingUp then return end
    
    RealCharacter = lp.Character
    protectGuis()

    if not FakeCharacter then 
        setupFakeCharacter() 
        repeat task.wait() until FakeCharacter
    end

    local realRoot = RealCharacter:FindFirstChild("HumanoidRootPart")
    local fakeRoot = FakeCharacter:FindFirstChild("HumanoidRootPart")
    
    if realRoot and fakeRoot then
        local storedCF = realRoot.CFrame
        realRoot.CFrame = fakeRoot.CFrame
        fakeRoot.CFrame = storedCF
        
        realRoot.Anchored = true 
        
        RealCharacter.Humanoid:UnequipTools()
        lp.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid

        for _, v in ipairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = false end
        end

        IsInvisible = true
    end
end

local function disableInvis()
    if not IsInvisible or IsSettingUp then return end

    local realRoot = RealCharacter:FindFirstChild("HumanoidRootPart")
    local fakeRoot = FakeCharacter:FindFirstChild("HumanoidRootPart")

    if realRoot and fakeRoot then
        local storedCF = fakeRoot.CFrame
        fakeRoot.CFrame = realRoot.CFrame
        realRoot.CFrame = storedCF
        
        realRoot.Anchored = false 
        
        FakeCharacter.Humanoid:UnequipTools()
        lp.Character = RealCharacter
        workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid

        for _, v in ipairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = true end
        end
        for _, v in ipairs(RealCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = false end
        end

        IsInvisible = false
    end
end

local function noclip()
	Clip = false
	if Noclip then Noclip:Disconnect() end
	Noclip = RunService.Stepped:Connect(function()
		if Clip == false and lp.Character then
			for _, v in ipairs(lp.Character:GetChildren()) do --descen
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
				end
			end
		end
	end)
end

local function clip()
	Clip = true
	if Noclip then
		Noclip:Disconnect()
		Noclip = nil
	end
end

local supportsHooks = getrawmetatable and hookfunction and setreadonly

if supportsHooks then
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex
        local oldNewIndex

        setreadonly(mt, false)

        oldIndex = hookfunction(mt.__index, function(self, index)
            if WalkToggle and not checkcaller() and self:IsA("Humanoid") and self:IsDescendantOf(game.Players.LocalPlayer.Character) then
                if index == "WalkSpeed" then
                    return 16
                end
            end
            return oldIndex(self, index)
        end)

        oldNewIndex = hookfunction(mt.__newindex, function(self, index, value)
            if WalkToggle and not checkcaller() and self:IsA("Humanoid") and self:IsDescendantOf(game.Players.LocalPlayer.Character) then
                if index == "WalkSpeed" then
                    return 
                end
            end
            return oldNewIndex(self, index, value)
        end)

        setreadonly(mt, true)
    end)
    
    if not success then
        warn("[Arexans] Bypass failed to initialize: " .. tostring(err))
    end
else
    warn("[Arexans] Executor does not support metatable hooking (getrawmetatable, setreadonly). WS Bypass Skipped.")
end

local SpeedConnection
local function applyBypassSpeed()
    if SpeedConnection then 
        SpeedConnection:Disconnect() 
        SpeedConnection = nil 
    end
    
    if WalkToggle then
        -- Ultimate Smoothness: Only apply speed when moving and on floor
        SpeedConnection = RunService.Stepped:Connect(function()
            if getgenv().ParryDebounce then return end
            if hum and hum.Parent and not isInteractionActive() then
                -- Optimization: Only force speed if moving to allow physics sleep
                if hum.MoveDirection.Magnitude > 0 then
                    if math.abs(hum.WalkSpeed - currentSpeed) > 1 then
                        hum.WalkSpeed = currentSpeed
                    end
                else
                    -- Reset to normal when idle to prevent micro-jitter
                    if math.abs(hum.WalkSpeed - 16) > 1 then
                        hum.WalkSpeed = 16 
                    end
                end
                
                -- Removed Aggressive Stop to prevent physics fighting/stuttering
            end
        end)
        
        -- Attribute cleaner throttled
        task.spawn(function()
            while WalkToggle and SpeedConnection do
                if hum and hum.Parent then
                    local negativeAttributes = {"Slowed", "Stunned", "Blind", "SpeedReduction", "Stun"}
                    for _, attr in ipairs(negativeAttributes) do
                        if hum:GetAttribute(attr) then
                            hum:SetAttribute(attr, nil)
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    else
        if hum and hum.Parent then
            hum.WalkSpeed = 16
        end
    end
end

local crossUI

local function findFolderByKeyword(parent, keyword)
    if not parent then return nil end
    for _, child in ipairs(parent:GetChildren()) do
        if string.find(string.lower(child.Name), string.lower(keyword)) then
            return child
        end
    end
    return nil
end

local countevent = 0
local function autofarmcurrency()
    task.spawn(function()
        while AutoEventToggle do
            if countevent > 8 then
                warn("[AXS Violence Distric] Remote limit. Waiting 15 seconds to avoid detection...")
                Lib:MakeNotify({ Title = "AXS Violence Distric", Content = "Remote limit. Waiting 15 seconds to avoid detection...", Time = 15 })
                task.wait(15)
                countevent = 0
                continue
            end
            local mapf = workspace:FindFirstChild("Map")
            
            if root and mapf then
                local chris = findFolderByKeyword(mapf, "chris")
                local treeFolder = findFolderByKeyword(chris, "tree")
                
                local treePart = nil
                if treeFolder then
                    local model = treeFolder:FindFirstChild("Model")
                    treePart = model and model:FindFirstChild("Part")
                end

                local giftsFolder = findFolderByKeyword(chris, "gift")
                local targetGift = giftsFolder and giftsFolder:FindFirstChild("GiftHandle", true)

                if targetGift and treePart then
                    root.CFrame = targetGift.CFrame
                    task.wait(0.3)
                    
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("gift", true)
                    if remote then
                        remote:FireServer(targetGift)
                        countevent += 1
                    end
                    
                    task.wait(0.1)
                    root.CFrame = treePart.CFrame
                    task.wait(1)
                else
                    task.wait(1)
                end
            else
                task.wait(1)
            end
        end
    end)
end

local function getNearestTarget()
    local nearest, nearestDist = nil, math.huge
    local sourceTable = (selectedTarget == "Killers") and getgenv().KillerCache or getgenv().ESP_Cache

    if not root then return nil end
    local myPos = root.Position

    for _, obj in ipairs(sourceTable or {}) do
        if obj:IsA("Model") and obj ~= lp.Character then
            local valid = false
            if selectedTarget == "Players" then
                 valid = isPlayerObject(obj)
            elseif selectedTarget == "Killers" then
                 valid = true
            end

            if valid then
                local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if targetRoot then
                    local dist = (targetRoot.Position - myPos).Magnitude
                    if dist < nearestDist then
                        nearest, nearestDist = obj, dist
                    end
                end
            end
        end
    end

    return nearest
end

local function faceTarget(model)
    if not root then return end

    local arm = model:FindFirstChild("Head")
    if not arm and model.PrimaryPart then
        arm = model.PrimaryPart
    end
    if not arm then return end

    local pos = arm.Position
    local dir = (pos - root.Position).Unit

    root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))

    local cam = workspace.CurrentCamera
    cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
end

local function pressSpecialButton(args)
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return end
    local survivor = pg:FindFirstChild("Survivor-mob")
    if not survivor then return end
    local controls = survivor:FindFirstChild("Controls")
    if not controls then return end
    local button = controls:FindFirstChild(args)
    if not button or not (button:IsA("TextButton") or button:IsA("ImageButton")) then return end

    for _, ev in ipairs({"MouseButton1Down", "MouseButton1Up", "MouseButton1Click"}) do
        if button[ev] then
            for _, sig in pairs(getconnections(button[ev])) do
                if sig.Function then
                    sig.Function()
                end
            end
        end
    end
end

local GenConnection = nil
local HealConnection = nil
local genHitDone = false
local healHitDone = false

local function autoperfectgen()
    local pGui = lp:FindFirstChild("PlayerGui")
    local checkGui = pGui and pGui:FindFirstChild("SkillCheckPromptGui") and pGui.SkillCheckPromptGui:FindFirstChild("Check")
    
    if checkGui and checkGui.Visible then
        local line = checkGui:FindFirstChild("Line")
        local goal = checkGui:FindFirstChild("Goal")
        
        if line and goal then
            local currentRot = line.Rotation
            local perfectStart = 104 + goal.Rotation
            
            if not genHitDone and currentRot >= (perfectStart + 1) and currentRot <= (perfectStart + 9) then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)

                pressSpecialButton("action")
                genHitDone = true
            end
        end
    else
        genHitDone = false
    end
end

local function autoperfectheal()
    local pGui = lp:FindFirstChild("PlayerGui")
    local checkGui = pGui and pGui:FindFirstChild("SkillCheckPromptGui") and pGui.SkillCheckPromptGui:FindFirstChild("Check")
    
    if checkGui and checkGui.Visible then
        local line = checkGui:FindFirstChild("Line")
        local goal = checkGui:FindFirstChild("Goal")
        
        if line and goal then
            local currentRot = line.Rotation
            local perfectStart = 104 + goal.Rotation
            
            if not healHitDone and currentRot >= (perfectStart + 1) and currentRot <= (perfectStart + 9) then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                pressSpecialButton("action")
                healHitDone = true
            end
        end
    else
        healHitDone = false
    end
end

getgenv().isAimingBtnPressed = false
getgenv().isMobileAiming = false
getgenv().AutoTargetToggle = false
getgenv().AutoSerangToggle = false

local function getSoundIdFromTheme()
	if chasetheme == "Mila - Compass" then
		return "rbxassetid://115877769571526"
	elseif chasetheme == "Close To Me" then
		return "rbxassetid://90022574613230"
	end
	return nil
end

local function fadeTo(vol, time)
	if not chaseSound then return end
	if activeTween then activeTween:Cancel() end
	activeTween = TweenService:Create(chaseSound, TweenInfo.new(time, Enum.EasingStyle.Linear), {Volume = vol})
	activeTween:Play()
end

local function setupChaseMusic(soundid)
	if not chaseSound then
		chaseSound = Instance.new("Sound")
		chaseSound.Name = "CCM"
		chaseSound.SoundId = soundid
		chaseSound.Looped = true
		chaseSound.Volume = 0
		chaseSound.Parent = SoundService

		chaseSound.Loaded:Wait()
		if 96.5 < chaseSound.TimeLength then
			if chasetheme == "Mila - Compass" then 
			chaseSound.TimePosition = 96.5
			end
		end
		chaseSound:Play()
	end

	fadeTo(1.2, 0)
end

RunService.RenderStepped:Connect(function()
    if not character or not root then return end

    local hasWeapon = character:FindFirstChild("Twist of Fate") or character:FindFirstChild("Flashlight")

    local isAimingNow = false
    if UserInputService.TouchEnabled then
        isAimingNow = getgenv().isMobileAiming
    else
        isAimingNow = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end

    local target = nil
    local targetPartObj = nil

    if (getgenv().AutoTargetToggle and isAimingNow and hasWeapon) or (getgenv().AutoSerangToggle and hasWeapon) then
        target = getNearestTarget()
        if target then
            if AimPart == "Kepala" then 
                targetPartObj = target:FindFirstChild("Head")
            elseif AimPart == "Badan" then 
                targetPartObj = target:FindFirstChild("UpperTorso") or target:FindFirstChild("Torso") or target:FindFirstChild("HumanoidRootPart")
            elseif AimPart == "Pundak Kanan" then 
                targetPartObj = target:FindFirstChild("RightUpperArm") or target:FindFirstChild("Right Arm")
            elseif AimPart == "Pundak Kiri" then 
                targetPartObj = target:FindFirstChild("LeftUpperArm") or target:FindFirstChild("Left Arm")
            end
            if not targetPartObj then targetPartObj = target:FindFirstChild("Head") end
        end
    end

    if getgenv().AutoTargetToggle and isAimingNow and target and targetPartObj and hasWeapon then
        local targetPos = targetPartObj.Position
        local currentCamPos = workspace.CurrentCamera.CFrame.Position
        
        workspace.CurrentCamera.CFrame = CFrame.new(currentCamPos, targetPos)
        
        local lookDir = (targetPos - root.Position).Unit
        root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lookDir.X, 0, lookDir.Z))
    end

    if getgenv().AutoSerangToggle and hasWeapon then
        if not getgenv().AutoSerangDebounce then getgenv().AutoSerangDebounce = 0 end
        if tick() - getgenv().AutoSerangDebounce > 2.5 then
            
            local fireConditionMet = false

            if target and targetPartObj then
                local targetHum = target:FindFirstChildOfClass("Humanoid")
                local isStunned = false
                local isAttacking = false

                if targetHum then
                    for _, track in ipairs(targetHum:GetPlayingAnimationTracks()) do
                        local name = track.Name:lower()
                        local id = tonumber(string.match(track.Animation.AnimationId or "", "%d+"))
                        
                        if name:find("stun") or name:find("hit") then
                            if track.Speed > 0 then
                                isStunned = true
                                break
                            end
                        end
                        if (id and (attackanims[id] or lungeanims[id])) or (name:find("slash") or name:find("attack") or name:find("lunge") or name:find("swing") or name:find("stab") or name:find("knife") or name:find("throw")) then
                            if track.Speed > 0 then
                                isAttacking = true
                            end
                        end
                    end
                end

                if not isStunned then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPartObj.Position)
                    if onScreen then
                        local distToTarget = (targetPartObj.Position - root.Position).Magnitude
                        
                        local aimPos
                        if UserInputService.TouchEnabled then
                            aimPos = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                        else
                            local Pos = UserInputService:GetMouseLocation()
                            aimPos = Vector2.new(Pos.X, Pos.Y)
                        end
                        
                        local distFromAim = (Vector2.new(screenPos.X, screenPos.Y) - aimPos).Magnitude
                        
                        if (distToTarget <= 20) or (isAttacking and distToTarget <= 50) or (distFromAim <= 150 and distToTarget <= 60) then
                            local origin = workspace.CurrentCamera.CFrame.Position
                            local direction = (targetPartObj.Position - origin).Unit * (targetPartObj.Position - origin).Magnitude
                            
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterDescendantsInstances = {character}
                            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                            
                            local result = workspace:Raycast(origin, direction, raycastParams)
                            
                            if result and result.Instance:IsDescendantOf(target) then
                                fireConditionMet = true
                            end
                        end
                    end
                end
            end

            if fireConditionMet then
                getgenv().AutoSerangDebounce = tick()
                
                local targetPos = targetPartObj.Position
                local currentCamPos = workspace.CurrentCamera.CFrame.Position
                workspace.CurrentCamera.CFrame = CFrame.new(currentCamPos, targetPos)
                local lookDir = (targetPos - root.Position).Unit
                root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lookDir.X, 0, lookDir.Z))
                
                if UserInputService.TouchEnabled then
                    pressSpecialButton("Gui-mob")
                else
                    local Pos = UserInputService:GetMouseLocation()
                    VIM:SendMouseButtonEvent(Pos.X, Pos.Y, 0, true, game, 1)
                    VIM:SendMouseButtonEvent(Pos.X, Pos.Y, 0, false, game, 1)
                end
            end
        end
    end
end)

local aimMobButtonConnectionDown
local aimMobButtonConnectionUp

local function HookMobileAimButton()
    if not UserInputService.TouchEnabled then return end
    
    task.spawn(function()
        local lastButton = nil
        while task.wait(2) do
            local pg = lp:FindFirstChild("PlayerGui")
            if pg then
                local survivor = pg:FindFirstChild("Survivor-mob")
                if survivor then
                    local controls = survivor:FindFirstChild("Controls")
                    if controls then
                        local button = controls:FindFirstChild("Gui-mob")
                        if button and (button:IsA("TextButton") or button:IsA("ImageButton")) and button ~= lastButton then
                            lastButton = button
                            if aimMobButtonConnectionDown then aimMobButtonConnectionDown:Disconnect() end
                            if aimMobButtonConnectionUp then aimMobButtonConnectionUp:Disconnect() end
                            
                            aimMobButtonConnectionDown = button.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    getgenv().isMobileAiming = true
                                end
                            end)
                            
                            aimMobButtonConnectionUp = button.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    getgenv().isMobileAiming = false
                                end
                            end)
                            
                            button.Destroying:Connect(function()
                                getgenv().isMobileAiming = false
                                lastButton = nil
                            end)
                        end
                    end
                end
            end
        end
    end)
end

HookMobileAimButton()

local function createDropdown()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "roblox"
    if gethui then ScreenGui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = game.CoreGui else ScreenGui.Parent = game.CoreGui end

    local chosenOption = "Select Mask"
    local chosenMapped = "Rooster"
    local options = {"Chainsaw", "Deadly Punches", "Walk Faster", "Further Dash", "Vault Faster", "Complete Stealth", "Default Mask"}

    local optionMap = {
        ["Chainsaw"] = "Alex",
        ["Deadly Punches"] = "Tony",
        ["Walk Faster"] = "Brandon",
        ["Further Dash"] = "Cobra",
        ["Vault Faster"] = "Rabbit",
        ["Complete Stealth"] = "Richter",
        ["Default Mask"] = "Rooster"
    }

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0, 160, 0, 40)
    DropdownButton.Position = UDim2.new(0.68, 0, 0.05, 0)
    DropdownButton.Text = chosenOption
    DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownButton.TextColor3 = Color3.new(1, 1, 1)
    DropdownButton.Font = Enum.Font.SourceSansBold
    DropdownButton.TextSize = 18
    DropdownButton.Parent = ScreenGui
    DropdownButton.Active = true
    DropdownButton.Draggable = true

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(0, 160, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.Visible = false
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = DropdownButton

    local optionHeight = 20
    for i, name in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, optionHeight)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * optionHeight)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = name
        btn.Parent = OptionsFrame

        btn.MouseButton1Click:Connect(function()
            chosenOption = name
            chosenMapped = optionMap[name]
            DropdownButton.Text = chosenOption
            OptionsFrame.Visible = false
            OptionsFrame.Size = UDim2.new(0, 160, 0, 0)
        end)
    end

    DropdownButton.MouseButton1Click:Connect(function()
        if OptionsFrame.Visible then
            OptionsFrame.Visible = false
            OptionsFrame.Size = UDim2.new(0, 160, 0, 0)
        else
            OptionsFrame.Visible = true
            OptionsFrame.Size = UDim2.new(0, 160, 0, #options * optionHeight)
        end
    end)

    return {
        getSelection = function()
            return chosenOption, chosenMapped
        end
    }
end

local lastAnim
RunService.Heartbeat:Connect(function()
    if not root or not character then return end

    for _, obj in ipairs(getgenv().KillerCache or {}) do
        if obj and obj.Parent and obj:IsA("Model") and obj ~= character then
            local killerHum = obj:FindFirstChildOfClass("Humanoid")
            local killerRoot = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")

            if killerHum and killerRoot then
                local dist = (killerRoot.Position - root.Position).Magnitude
                
                -- Optimization: Check Backpack as well
                local dagger = character:FindFirstChild("Parrying Dagger") or lp.Backpack:FindFirstChild("Parrying Dagger")

                -- Optimization: Strict debounce check early to prevent lag and unwanted turning
                if Autoparry and dist < (ParryDistance + 25) and dagger then
                    if not dagger.Enabled then continue end
                    if (getgenv().NextAllowedParry and tick() < getgenv().NextAllowedParry) then continue end
                    if getgenv().ParryDebounce then continue end

                    local shouldParry = false

                    -- Logic Enhanced: "Gacor" Prediction & Anti-Miss
                    local ping = game:GetService("Players").LocalPlayer:GetNetworkPing()
                    local killerVel = killerRoot.Velocity
                    
                    -- Calculate closing speed (how fast they are approaching us)
                    local toPlayer = (root.Position - killerRoot.Position).Unit
                    local closingSpeed = killerVel:Dot(toPlayer)
                    
                    -- Prediction Factor: Increased aggressive buffer for "Anti Miss"
                    local predictionTime = math.clamp(ping, 0.05, 0.5) + 0.15 -- Reduced to prevent too far parries
                    if UserInputService.TouchEnabled then predictionTime = predictionTime + 0.5 end
                    
                    -- Check if killer is behind (Backstab prevention)
                    local facingDot = root.CFrame.LookVector:Dot(toPlayer)
                    if facingDot > 0 then
                         predictionTime = predictionTime + 0.2 -- More time for turn
                    end

                    local approachDist = 0
                    
                    if closingSpeed > 0 then
                        approachDist = closingSpeed * predictionTime
                    end

                    -- Effective Range
                    local effectiveRange = ParryDistance + approachDist -- Removed static buffer for tighter parry

                    -- Panic Mode: Increased threshold for guaranteed safety
                    local panicMode = dist < (ParryDistance - 5) -- Strictly close range only

                    -- Check animations
                    local isAttacking = false
                    for _, track in ipairs(killerHum:GetPlayingAnimationTracks()) do
                        local id = tonumber(string.match(track.Animation.AnimationId or "", "%d+"))
                        local name = track.Name:lower()

                        if name:find("walk") or name:find("idle") or name:find("run") or name:find("equip") or name:find("stun") or name:find("hit") then
                            continue
                        end

                        if (id and (attackanims[id] or lungeanims[id])) or
                           (name:find("slash") or name:find("attack") or name:find("lunge") or name:find("swing") or name:find("stab") or name:find("knife") or name:find("throw")) then
                            if track.Speed > 0 then
                                isAttacking = true
                                break
                            end
                        end
                    end

                    if isAttacking and dist <= effectiveRange then
                        shouldParry = true
                    elseif panicMode and isAttacking then
                        shouldParry = true 
                    end

                    if shouldParry then
                        if not (character:GetAttribute("IsHooked") or character:GetAttribute("IsCarried")) then
                            local function executeParry()
                                -- Failsafe: Reset debounce if stuck for too long (Reduced to 3s for better responsiveness)
                                if getgenv().ParryDebounce and (tick() - (getgenv().LastParryTime or 0) > 3) then
                                    getgenv().ParryDebounce = false
                                end

                                if getgenv().ParryDebounce then return end
                                
                                if (getgenv().NextAllowedParry and tick() < getgenv().NextAllowedParry) then return end
                                getgenv().NextAllowedParry = tick() + 50

                                getgenv().ParryDebounce = true
                                getgenv().LastParryTime = tick()
                                
                                -- Auto Equip Logic: Ensure tool is in hand
                                local tool = character:FindFirstChild("Parrying Dagger")
                                if not tool then
                                    tool = lp.Backpack:FindFirstChild("Parrying Dagger")
                                    if tool then 
                                        hum:EquipTool(tool)
                                    end
                                end

                                -- STRICT CHECK: If tool is not ready/enabled or missing, ABORT IMMEDIATELY.
                                -- This is critical to prevent "One-Time Use" bugs and unwanted rotation when on cooldown.
                                if not tool or not tool.Parent or (tool:IsA("Tool") and not tool.Enabled) then
                                    getgenv().ParryDebounce = false
                                    return
                                end

                                -- KUDA-KUDA (Stance) Logic
                                local oldWS = hum.WalkSpeed
                                pcall(function()
                                    hum.WalkSpeed = 0
                                    character:SetAttribute("Crouchingserver", true)
                                    game.ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true)
                                    game.ReplicatedStorage.Remotes.Chase.Runevent:FireServer(character, false)
                                end)

                                -- Smart Face: Instantly face the killer before parrying (Only when necessary)
                                if SmartFace and killerRoot and root then
                                    local lookPos = Vector3.new(killerRoot.Position.X, root.Position.Y, killerRoot.Position.Z)
                                    if hum.AutoRotate then
                                        hum.AutoRotate = false
                                        task.delay(0.1, function() if hum then hum.AutoRotate = true end end)
                                    end
                                    root.CFrame = CFrame.lookAt(root.Position, lookPos)
                                end

                                -- Fire Remote (Main Thread)
                                game.ReplicatedStorage.Remotes.Items["Parrying Dagger"].parry:FireServer()

                                task.spawn(function()
                                    -- Use xpcall to ensure cleanup ALWAYS happens, fixing the "One-Time Use" bug
                                    local success, err = pcall(function()
                                        local currentTool = character:FindFirstChild("Parrying Dagger") or lp.Backpack:FindFirstChild("Parrying Dagger") or tool
                                        
                                        -- Activate Tool Locally for Animation
                                        pcall(function()
                                            if currentTool and currentTool:IsA("Tool") then
                                                currentTool:Activate()
                                            end
                                            game.ReplicatedStorage.Remotes.Items["Parrying Dagger"].parry:FireServer()
                                        end)

                                        -- Virtual Input Backup
                                        pcall(function()
                                            if game.UserInputService.TouchEnabled then
                                                pressSpecialButton("Gui-mob")
                                            else
                                                local Pos = game:GetService("UserInputService"):GetMouseLocation()
                                                VIM:SendMouseButtonEvent(Pos.X, Pos.Y, 0, true, game, 1)
                                                VIM:SendMouseButtonEvent(Pos.X, Pos.Y, 0, false, game, 1)
                                            end
                                        end)

                                        -- Wait for Cooldown (Auto Detect)
                                        task.wait(0.2) -- Allow game to update state
                                        local start = tick()
                                        
                                        -- Improved Loop: Checks tool existence strictly
                                        while (tick() - start < 4) do
                                            local t = character:FindFirstChild("Parrying Dagger") or lp.Backpack:FindFirstChild("Parrying Dagger")
                                            
                                            -- If tool is lost (destroyed/unequipped), assume done or broken
                                            if not t or not t.Parent then 
                                                break 
                                            end
                                            
                                            -- If tool is enabled again, cooldown is over
                                            if t.Enabled then 
                                                break 
                                            end
                                            
                                            task.wait(0.1)
                                        end
                                    end)

                                    if not success then
                                        warn("[AutoParry] Error: " .. tostring(err))
                                    end

                                    -- Restore State (Always Runs)
                                    pcall(function()
                                        if WalkToggle then
                                            hum.WalkSpeed = currentSpeed
                                        else
                                            hum.WalkSpeed = (oldWS < 16) and 16 or oldWS
                                        end
                                        if character then
                                            character:SetAttribute("Crouchingserver", false)
                                        end
                                        game.ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", false)
                                    end)

                                    getgenv().ParryDebounce = false
                                end)
                            end

                            if ParryDelay > 0 then
                                task.delay(ParryDelay, executeParry)
                            else
                                executeParry()
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function autodrop()
    task.spawn(function()
        while AutoDropToggle do
            task.wait(0.25)
            if not root or not character then continue end

            local nearestPallet = nil
            local shortestDistance = math.huge
            local rootPos = root.Position

            -- Optimized pallet search using ESP_Cache
            for _, obj in ipairs(getgenv().ESP_Cache or {}) do
                if obj and obj.Parent and string.find(obj.Name:lower(), "pallet") and obj:FindFirstChild("PalletPoint") then
                    local palletPos = obj:GetPivot().Position
                    local distance = (palletPos - rootPos).Magnitude

                    -- Pallet must be close to player (within 15 studs)
                    if distance < 15 and distance < shortestDistance then
                         shortestDistance = distance
                         nearestPallet = obj
                    end
                end
            end

            if nearestPallet then
                local nearestPalletPoint = nearestPallet:FindFirstChild("PalletPoint")

                if nearestPalletPoint then
                    local killerNearby = false
                    local palletCenter = nearestPallet:GetPivot().Position

                    -- Use KillerCache instead of scanning workspace
                    for _, obj in ipairs(getgenv().KillerCache or {}) do
                        if obj ~= character then
                            local killerRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                            if killerRoot then
                                local distToPallet = (killerRoot.Position - palletCenter).Magnitude
                                -- If killer is within 10 studs of the pallet
                                if distToPallet < 10 then
                                    killerNearby = true
                                    break
                                end
                            end
                        end
                    end

                    if killerNearby then
                        if not AutoDropSetToggle and character:GetAttribute("IsCarried") then
                            -- Do nothing if carried and toggle is off
                        else
                            game.ReplicatedStorage.Remotes.Pallet.PalletDropEvent:FireServer(nearestPalletPoint)
                            -- Add a small cooldown to prevent spamming the remote for the same pallet action
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end)
end

local desyncT = {enabled = false, loc = CFrame.new()}
local prevLookVector = nil
local isSpinning = false
local spinThreshold = 15
local desynchook = nil
local heartbeatConn, charConn = nil, nil

local function getOffsetCFrame()
    local ping = game:GetService("Players").LocalPlayer:GetNetworkPing() * 1000
    if ping < 100 then
        return CFrame.new(0, 0, -2)
    elseif ping <= 170 then
        return CFrame.new(0, 0, -2.7)
    else
        return CFrame.new(0, 0, -3.7)
    end
end

local function enableHitboxDesync()
    if not hookmetamethod then
        warn("[Arexans] Executor does not support hookmetamethod. Hitbox Desync Skipped.")
        return
    end

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not desyncT.enabled or not character then return end
        if not root then return end

        local currentLook = root.CFrame.LookVector
        if prevLookVector then
            local dot = math.clamp(prevLookVector:Dot(currentLook), -1, 1)
            local angleDiff = math.deg(math.acos(dot))
            isSpinning = angleDiff > spinThreshold
        end
        prevLookVector = currentLook

        if isSpinning then return end

        desyncT.loc = root.CFrame
        local offset = getOffsetCFrame()
        local newCFrame = desyncT.loc * offset
        root.CFrame = newCFrame

        root.CFrame = desyncT.loc
    end)

    desynchook = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if desyncT.enabled and not checkcaller() and
           key == "CFrame" and
           LocalPlayer.Character and
           self == LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
           not isSpinning then
            return desyncT.loc
        end
        return desynchook(self, key)
    end))

    charConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        prevLookVector = nil
        isSpinning = false
    end)
end

local function disableHitboxDesync()
    desyncT.enabled = false
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    if charConn then
        charConn:Disconnect()
        charConn = nil
    end
    if desynchook then
        desynchook = nil
    end
    prevLookVector = nil
    isSpinning = false
end

local RemoveCrosshair = nil
local CrosshairType = "crosshair dot"

local function LoadCrosshair()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AXS_Crosshair"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 10000
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local parentSuccess, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not parentSuccess then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local crosshairMap = {
        ["crosshair dot"] = "rbxassetid://15240614328",
        ["crosshair dot 2"] = "rbxassetid://125887405613260",
        ["crosshair square"] = "rbxassetid://95081014476249",
        ["crosshair +•"] = "rbxassetid://13011888817",
        ["crosshair +"] = "rbxassetid://6587895205",
        ["crosshair O+"] = "rbxassetid://14599258630",
        ["crosshair O+ 2"] = "rbxassetid://96025442253083",
        ["Croshair (+)"] = "rbxassetid://135489154238728",
        ["Crosshair [ • ]"] = "rbxassetid://101370742207347",
        ["Crosshair [O+]"] = "rbxassetid://92175000437419",
        ["Crosshair star"] = "rbxassetid://16575721101"
    }

    local ImageId = crosshairMap[CrosshairType] or "rbxassetid://15240614328"

    local CrosshairImage = Instance.new("ImageLabel")
    CrosshairImage.Size = UDim2.new(0, 50, 0, 50)
    CrosshairImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairImage.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairImage.BackgroundTransparency = 1
    CrosshairImage.Image = ImageId
    CrosshairImage.ZIndex = 1000
    CrosshairImage.Parent = ScreenGui

    return function()
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end
end

-- UI IMPLEMENTATION

getgenv().KeybindConnections = {}

local AllKeys = {}
for _, key in ipairs(Enum.KeyCode:GetEnumItems()) do
    table.insert(AllKeys, key.Name)
end
table.insert(AllKeys, "MB1")
table.insert(AllKeys, "MB2")

local function AddBind(section, name, default, toggleHandle)
    local connectionName = "Keybind_" .. name
    
    local function updateKey(keyName)
        if getgenv().KeybindConnections[connectionName] then
            getgenv().KeybindConnections[connectionName]:Disconnect()
            getgenv().KeybindConnections[connectionName] = nil
        end
        
        if keyName == "" or keyName == "None" or keyName == nil then return end
        
        local keyType = "Keyboard"
        local key

        if keyName == "MB1" then
            keyType = "Mouse"
            key = Enum.UserInputType.MouseButton1
        elseif keyName == "MB2" then
            keyType = "Mouse"
            key = Enum.UserInputType.MouseButton2
        else
            pcall(function() key = Enum.KeyCode[keyName] end)
        end
        
        if key then
            getgenv().KeybindConnections[connectionName] = UserInputService.InputBegan:Connect(function(input, gp)
                if not gp then
                    local pressed = false
                    if keyType == "Keyboard" and input.KeyCode == key then
                        pressed = true
                    elseif keyType == "Mouse" and input.UserInputType == key then
                        pressed = true
                    end

                    if pressed then
                        if toggleHandle then
                            if type(toggleHandle) == "function" then
                                toggleHandle()
                            elseif type(toggleHandle) == "table" and toggleHandle.Set then
                                toggleHandle:Set(not toggleHandle.Value)
                            end
                        end
                    end
                end
            end)
        end
    end

    section:AddDropdown({
        Title = name,
        Options = AllKeys,
        Default = default or "None",
        Callback = updateKey
    })
    
    updateKey(default)
end

local MouseCursorState = false
local function ToggleMouseCursor()
    if UserInputService.TouchEnabled then return end
    MouseCursorState = not MouseCursorState
    UserInputService.MouseIconEnabled = MouseCursorState
    if MouseCursorState then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end

local FPSLabel, FPSGui, FPSLoop
local function CreateFPS()
    if FPSGui then return end
    FPSGui = Instance.new("ScreenGui")
    FPSGui.Name = "AXS_FPS"
    getgenv().AXS_FPS_GUI = FPSGui
    if gethui then FPSGui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(FPSGui) FPSGui.Parent = game.CoreGui else FPSGui.Parent = game.CoreGui end
    
    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0, 100, 0, 30)
    FPSLabel.Position = UDim2.new(1, -110, 0, 10)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextSize = 18
    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    FPSLabel.TextStrokeTransparency = 0.5
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
    FPSLabel.Parent = FPSGui
    
    local lastUpdate = 0
    local frameCount = 0
    
    FPSLoop = RunService.RenderStepped:Connect(function(dt)
        frameCount = frameCount + 1
        if tick() - lastUpdate >= 1 then
            local fps = frameCount
            lastUpdate = tick()
            frameCount = 0
            
            if FPSLabel then
                FPSLabel.Text = "FPS: " .. fps
                if fps < 30 then
                    FPSLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif fps < 55 then
                    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end)
end

local function RemoveFPS()
    if FPSLoop then FPSLoop:Disconnect() FPSLoop = nil end
    if FPSGui then 
        FPSGui:Destroy() 
        FPSGui = nil 
        getgenv().AXS_FPS_GUI = nil
    end
end

local Window = Lib:Window({
    Title = "AXS VD " .. getTag(lp.Name),
    Footer = "Violence Distric By Arexans",
    Color = Color3.fromRGB(0, 170, 255),
    Image = "122503252139031",
    Version = 1,
    ["Tab Width"] = 120
})

Window:SetToggleKey(Enum.KeyCode.K)

local LogsTab = Window:AddTab({ Name = "Logs", Icon = "scroll" })
local UniversalTab = Window:AddTab({ Name = "Universal", Icon = "web" })
local KillerTab = Window:AddTab({ Name = "Pembunuh", Icon = "sword" })
local SurvivorTab = Window:AddTab({ Name = "Penyintas", Icon = "user" })
local EspTab = Window:AddTab({ Name = "ESP", Icon = "eyes" })
local PlayerTab = Window:AddTab({ Name = "Pemain", Icon = "player" })
local MiscTab = Window:AddTab({ Name = "Lainnya", Icon = "menu" })
local ConfigTab = Window:AddTab({ Name = "Konfigurasi", Icon = "settings" })
local ServerTab = Window:AddTab({ Name = "Server", Icon = "web" })
local KeybindTab = Window:AddTab({ Name = "Keybinds", Icon = "rbxassetid://10709752906" })

-- SERVER

local ServerControls = ServerTab:AddSection("Server Controls", true)

ServerControls:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

ServerControls:AddButton({
    Title = "Hop Random Server",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
        
        local function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        
        local Server, Next; repeat
            local Servers = ListServers(Next)
            Server = Servers.data[math.random(1, #Servers.data)]
            Next = Servers.nextPageCursor
        until Server
        
        TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)
    end
})

ServerControls:AddButton({
    Title = "Hop Low Pop Server",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
        
        local function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        
        local Server, Next;
        local BestServer = nil
        
        repeat
            local Servers = ListServers(Next)
            for _, s in ipairs(Servers.data) do
                if s.playing < s.maxPlayers - 1 and s.id ~= game.JobId then
                    if not BestServer or s.playing < BestServer.playing then
                        BestServer = s
                    end
                end
            end
            Next = Servers.nextPageCursor
        until not Next or (BestServer and BestServer.playing < 5)
        
        if BestServer then
            TPS:TeleportToPlaceInstance(_place, BestServer.id, game.Players.LocalPlayer)
        else
            Lib:MakeNotify({ Title = "Server Hop", Content = "No low population server found.", Time = 3 })
        end
    end
})

local ServerList = ServerTab:AddSection("Server List", true)
local ServerFrame = Instance.new("ScrollingFrame")
ServerFrame.Size = UDim2.new(1, -20, 0, 300)
ServerFrame.Position = UDim2.new(0, 10, 0, 0)
ServerFrame.BackgroundTransparency = 1
ServerFrame.ScrollBarThickness = 2
ServerFrame.Parent = ServerList.SectionAdd

local UIListLayoutServer = Instance.new("UIListLayout")
UIListLayoutServer.Parent = ServerFrame
UIListLayoutServer.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutServer.Padding = UDim.new(0, 5)

UIListLayoutServer:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ServerFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayoutServer.AbsoluteContentSize.Y)
end)

local currentServerFilter = "Normal"

local function RefreshServerList()
    for _, v in ipairs(ServerFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    local Http = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
    
    task.spawn(function()
        local success, result = pcall(function()
            return game:HttpGet(Api)
        end)
        
        if success then
            local data = Http:JSONDecode(result)
            if data and data.data then
                local filteredData = {}
                for _, s in ipairs(data.data) do
                    if currentServerFilter == "Low" and s.playing > 5 then continue end
                    if s.playing < s.maxPlayers - 1 and s.id ~= game.JobId then
                        table.insert(filteredData, s)
                    end
                end
                
                if currentServerFilter == "Fast" then
                    table.sort(filteredData, function(a, b)
                        return (a.ping or 0) < (b.ping or 0)
                    end)
                end

                for _, server in ipairs(filteredData) do
                        local SFrame = Instance.new("Frame")
                        SFrame.Size = UDim2.new(1, 0, 0, 40)
                        SFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        SFrame.BackgroundTransparency = 0.5
                        SFrame.Parent = ServerFrame
                        
                        local Corner = Instance.new("UICorner")
                        Corner.CornerRadius = UDim.new(0, 4)
                        Corner.Parent = SFrame
                        
                        local Info = Instance.new("TextLabel")
                        Info.Size = UDim2.new(0.7, 0, 1, 0)
                        Info.Position = UDim2.new(0, 10, 0, 0)
                        Info.BackgroundTransparency = 1
                        Info.TextXAlignment = Enum.TextXAlignment.Left
                        Info.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Info.Font = Enum.Font.Gotham
                        Info.TextSize = 12
                        Info.RichText = true
                        
                        local ping = server.ping or 0
                        local pingColor = "00FF00"
                        if ping > 200 then pingColor = "FF0000"
                        elseif ping > 100 then pingColor = "FFFF00"
                        end

                        Info.Text = string.format("%d/%d Players | Ping: <font color='#%s'>%d</font> | FPS: %d", server.playing, server.maxPlayers, pingColor, ping, server.fps or 0)
                        Info.Parent = SFrame
                        
                        local JoinBtn = Instance.new("TextButton")
                        JoinBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
                        JoinBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
                        JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                        JoinBtn.Text = "Join"
                        JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        JoinBtn.Font = Enum.Font.GothamBold
                        JoinBtn.TextSize = 12
                        JoinBtn.Parent = SFrame
                        
                        local BtnCorner = Instance.new("UICorner")
                        BtnCorner.CornerRadius = UDim.new(0, 4)
                        BtnCorner.Parent = JoinBtn
                        
                        JoinBtn.MouseButton1Click:Connect(function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                        end)
                end
            end
        end
    end)
end

local SectionHeader = ServerList.SectionAdd.Parent:FindFirstChild("Title") or ServerList.SectionAdd.Parent

local RefreshIcon = Instance.new("ImageButton")
RefreshIcon.Size = UDim2.new(0, 20, 0, 20)
RefreshIcon.Position = UDim2.new(1, -30, 0, 5)
RefreshIcon.AnchorPoint = Vector2.new(1, 0)
RefreshIcon.BackgroundTransparency = 1
RefreshIcon.Image = "rbxassetid://10709752906"
RefreshIcon.Parent = SectionHeader

local FilterIcon = Instance.new("ImageButton")
FilterIcon.Size = UDim2.new(0, 20, 0, 20)
FilterIcon.Position = UDim2.new(1, -60, 0, 5)
FilterIcon.AnchorPoint = Vector2.new(1, 0)
FilterIcon.BackgroundTransparency = 1
FilterIcon.Image = "rbxassetid://7964618035"
FilterIcon.Parent = SectionHeader

RefreshIcon.MouseButton1Click:Connect(function()
    RefreshServerList()
end)

FilterIcon.MouseButton1Click:Connect(function()
    if currentServerFilter == "Normal" then
        currentServerFilter = "Low"
        Lib:MakeNotify({ Title = "Server Filter", Content = "Filter Active: Low Server (Sepi)", Time = 2 })
    elseif currentServerFilter == "Low" then
        currentServerFilter = "Fast"
        Lib:MakeNotify({ Title = "Server Filter", Content = "Filter Active: Ping Fast (Cepat)", Time = 2 })
    else
        currentServerFilter = "Normal"
        Lib:MakeNotify({ Title = "Server Filter", Content = "Filter Active: Normal", Time = 2 })
    end
    RefreshServerList()
end)

RefreshServerList()

KeybindSection = KeybindTab:AddSection("Keybinds", true)

KeybindSection:AddButton({
    Title = "Save Keybinds",
    Callback = function()
        Lib:Save()
    end
})

KeybindSection:AddButton({
    Title = "Reset Keybinds",
    Callback = function()
        Lib:ResetAll()
    end
})

-- LOGS

LogsSection = LogsTab:AddSection("Update Logs", true)

LogsSection:AddParagraph({
    Title = "Update Logs",
    Content = "08.01.26\n[+] Auto Play (AI, BETA)\n[+] Auto Run (BETA)\n[+] Auto Farm (BETA)\n[+] Auto Loop (BETA)\n[+] Wall Hug\n[+] Version Checker (In-Built)\n[+] Fixed ESP Tracers & Boxes (Universal Support)\n[+] Improved Pallet/Window Detection\n\n07.01.26\n[+] Infinite Lunge (Premium)\n[+] Hook Farm (Screws Farm)\n[+] Auto Aim Charged Spear (Veil, Works)\n[+] Auto Aim Spear (Veil, Works)\n[+] Expand Hitboxes (Universal>Fun)\n[+] No Fall\n[/] Several Bug Fixes (Damage Aura, etc.)\n[/] Improved Things\n[/] Rewrited Code",
    Icon = "scroll"
})

LogsSection:AddButton({
    Title = "Copy Community Link",
    Callback = function()
        setclipboard("https://whatsapp.com/channel/0029VarXBlfEVccM6hAkdp1H")
        Lib:MakeNotify({ Title = "Community", Content = "Link Copied!", Time = 2 })
    end
})

-- UNIVERSAL

FunSection = UniversalTab:AddSection("Fun", true)

Toggles.DesyncHandle = FunSection:AddToggle({
    Title = "Desync (Anti Hit)",
    Content = "Gunakan untuk hitbox yang lebih baik atau memalsukan posisi.",
    Default = false,
    Callback = function(state)
      task.spawn(function()
        if not setfflag then
            warn("[Arexans] Desync not supported. Desync will not work.")
            return
        end
        Desync = state
        
        if DesyncType == "Fake Position" then
            setfflag('NextGenReplicatorEnabledWrite4', tostring(state))
        elseif DesyncType == "Hitbox Improving" then
            desyncT.enabled = state
            
            if state then
                enableHitboxDesync()
            else
                disableHitboxDesync()
            end
        end
      end)
    end
})

Toggles.DesyncTypeHandle = FunSection:AddDropdown({
    Title = "Tipe Desync",
    Options = { "Hitbox Improving", "Fake Position" },
    Default = DesyncType,
    Callback = function(option)
        DesyncType = option
    end
})

Toggles.InvisibilityHandle = FunSection:AddToggle({
    Title = "Invisibilitas",
    Content = "Membuatmu tidak terlihat oleh orang lain.",
    Default = false,
    Callback = function(state)
        InvisibilityToggle = state
        if state then 
            enableInvis()
        else
            disableInvis()
        end
    end
})

FunSection:AddDivider()

Toggles.HitboxesRadiusHandle = FunSection:AddSlider({
    Title = "Radius Hitbox",
    Min = 5,
    Max = 30,
    Default = 10,
    Callback = function(Value)
        HitboxesRadius = tonumber(Value)
    end
})

Toggles.ExpandHitboxesHandle = FunSection:AddToggle({
    Title = "Perbesar Hitbox",
    Content = "Memperbesar hitbox tim lawan.",
    Default = false,
    Callback = function(state)
        ExpandHitboxesToggle = state
    end
})

Toggles.HitboxesVisibleHandle = FunSection:AddToggle({
    Title = "Hitbox Terlihat?",
    Content = "Membuat hitbox menjadi setengah transparan.",
    Default = false,
    Callback = function(state)
        HitboxesVisibleToggle = state
    end
})

UMiscSection = UniversalTab:AddSection("Lainnya", true)

Toggles.AutoEventHandle = UMiscSection:AddToggle({
    Title = "Auto Farm Event",
    Content = "Farming event yang sedang berlangsung, event saat ini: 🎄",
    Default = false,
    Callback = function(state)
        AutoEventToggle = state
        if state then
            autofarmcurrency()
        end
    end
})

Toggles.CrosshairHandle = UMiscSection:AddToggle({
    Title = "Crosshair (Bidik)",
    Content = "Menambahkan bidikan ke layar.",
    Default = false,
    Callback = function(state)
         if state then
             if not RemoveCrosshair then
                 RemoveCrosshair = LoadCrosshair()
             end
         else
             if RemoveCrosshair then
                 RemoveCrosshair()
                 RemoveCrosshair = nil
             end
         end
    end
})

UMiscSection:AddDropdown({
    Title = "Tipe Crosshair",
    Options = {"crosshair dot", "crosshair dot 2", "crosshair square", "crosshair +•", "crosshair +", "crosshair O+", "crosshair O+ 2", "Croshair (+)", "Crosshair [ • ]", "Crosshair [O+]", "Crosshair star"},
    Default = "crosshair dot",
    Callback = function(option)
        CrosshairType = option
        if RemoveCrosshair then
             RemoveCrosshair()
             RemoveCrosshair = LoadCrosshair()
        end
    end
})

local potatoActive = false
UMiscSection:AddToggle({
    Title = "Potato Graphics",
    Content = "Mengurangi kualitas grafik untuk meningkatkan FPS.",
    Default = false,
    Callback = function(state)
        local lighting = game:GetService("Lighting")
        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if state then
            potatoActive = true
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            lighting.Brightness = 1

            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end

            for _, v in ipairs(lighting:GetChildren()) do
                if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end

            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                elseif v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end
            end
        elseif potatoActive then
            potatoActive = false
            lighting.GlobalShadows = true
            lighting.Brightness = 2
            for _, v in ipairs(lighting:GetChildren()) do
                if v:IsA("PostProcessEffect") then v.Enabled = true end
            end
            -- Lib:MakeNotify({ Title = "Info", Content = "Grafik dipulihkan sebagian. Rejoin untuk reset total.", Time = 3 })
        end
    end
})

local antiLagActive = false
UMiscSection:AddToggle({
    Title = "Anti Freeze / Anti Lag",
    Content = "Optimasi ekstrem untuk mencegah freeze dan mengurangi lag.",
    Default = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        
        if state then
            antiLagActive = true
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.CastShadow = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                elseif v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.CastShadow = false
                    v.TextureID = 10385902758728957
                elseif v:IsA("Explosion") then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                    v.Visible = false
                end
            end
            
            for _, e in pairs(Lighting:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                    e.Enabled = false
                end
            end
            -- Lib:MakeNotify({ Title = "Optimasi", Content = "Anti Lag aktif!", Time = 2 })
        elseif antiLagActive then
            antiLagActive = false
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            -- Lib:MakeNotify({ Title = "Info", Content = "Optimasi dinonaktifkan. Tekstur mungkin tidak kembali normal tanpa rejoin.", Time = 3 })
        end
    end
})

local JumpUI
local function ToggleJumpButton(state)
    if state then
        if JumpUI then return end
        JumpUI = Instance.new("ScreenGui")
        JumpUI.Name = "AXS_Jump_UI"
        JumpUI.ResetOnSpawn = false
        if gethui then JumpUI.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(JumpUI) JumpUI.Parent = game.CoreGui else JumpUI.Parent = game.CoreGui end

        local JumpBtn = Instance.new("TextButton")
        JumpBtn.Size = UDim2.new(0, 60, 0, 60)
        JumpBtn.Position = UDim2.new(1, -80, 1, -80)
        JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        JumpBtn.BackgroundTransparency = 0.3
        JumpBtn.Text = "JUMP"
        JumpBtn.TextColor3 = Color3.new(1, 1, 1)
        JumpBtn.Font = Enum.Font.GothamBold
        JumpBtn.TextSize = 14
        JumpBtn.Active = true
        JumpBtn.Draggable = true
        JumpBtn.Parent = JumpUI

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = JumpBtn

        JumpBtn.MouseButton1Click:Connect(function()
            if root and hum then
                if hum.FloorMaterial ~= Enum.Material.Air then
                    root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if JumpUI then
            JumpUI:Destroy()
            JumpUI = nil
        end
    end
end

Toggles.ShowJumpGuiHandle = UMiscSection:AddToggle({
    Title = "Tampilkan Tombol Lompat",
    Content = "Menampilkan tombol di layar untuk melompat secara manual.",
    Default = false,
    Callback = function(state)
        ToggleJumpButton(state)
    end
})

UPlaySection = UniversalTab:AddSection("Auto Play", true)

Toggles.AutoPlayHandle = UPlaySection:AddToggle({
   Title = "Auto Play (AI, BETA)",
   Content = "Automatically plays for you, will be improving further.",
   Default = false,
   Callback = function(state)
       getgenv().AIPlaying = state
       if state then
           loadstring(game:HttpGet("https://pastefy.app/P7Xzdqfu/raw"))()
       end
   end
})

UPlaySection:AddDivider()

Toggles.RunHandle = UPlaySection:AddToggle({
   Title = "Auto Run (BETA)",
   Content = "Runs from killer if he's close and you're survivor.",
   Default = false,
   Callback = function(state)
       getgenv().axs_settings.Methods.Run = state
   end
})

Toggles.FarmHandle = UPlaySection:AddToggle({
   Title = "Auto Farm (BETA)",
   Content = "Farms generators if you're survivor, survivors if you're killer.",
   Default = false,
   Callback = function(state)
       getgenv().axs_settings.Methods.Farm = state
   end
})

Toggles.LoopHandle = UPlaySection:AddToggle({
   Title = "Auto Loop (BETA)",
   Content = "Loops killer if you're survivor.",
   Default = false,
   Callback = function(state)
       getgenv().axs_settings.Methods.Farm = state
   end
})

Toggles.WallHugHandle = UPlaySection:AddToggle({
   Title = "Wall Hug",
   Content = "Hugs wall while running/farming/looping.",
   Default = false,
   Callback = function(state)
       getgenv().axs_settings.Toggles.Wallhug = state
   end
})

-- KILLER

KillerBlatantSection = KillerTab:AddSection("Blatant (Kasar)", true)

Toggles.InfThingsHandle = KillerBlatantSection:AddToggle({
    Title = "Infinite Abilities (PREMIUM)",
    Content = "Includes no attack cooldown. Supported killers for inf abillities: Slasher, Masked, Veil, Stalker.",
    Default = false,
    Callback = function(state)
        if state then
            if getgenv().PREMIUM_KEY then
                InfThingsToggle = true
                noCdEnabled = true
            else
                InfThingsToggle = false
                noCdEnabled = false
                Lib:MakeNotify({
                    Title = "Premium Feature",
                    Content = "This feature is only for premium users, get premium in our community.",
                    Time = 3
                })
                if Toggles.InfThingsHandle then
                    Toggles.InfThingsHandle:Set(false)
                end
            end
        else
            InfThingsToggle = false
            noCdEnabled = false
        end
    end
})

local InfLungeConnection = nil
Toggles.InfLungeHandle = KillerBlatantSection:AddToggle({
    Title = "Infinite Lunge (PREMIUM)",
    Content = "Lunge infinitely without any restrictions.",
    Default = false,
    Callback = function(state)
        if state then
            if not getgenv().PREMIUM_KEY then
                state = false
                Lib:MakeNotify({
                    Title = "Premium Feature",
                    Content = "This feature is only for premium users, get premium in our community.",
                    Time = 3
                })
                if Toggles.InfLungeHandle then
                    Toggles.InfLungeHandle:Set(false)
                end
                return
            end
        end
        if state then
            character:SetAttribute("lungeboost", 999)
            if InfLungeConnection then InfLungeConnection:Disconnect() end
            InfLungeConnection = lp.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                character:SetAttribute("lungeboost", 999)
            end)
        else
            if InfLungeConnection then
                InfLungeConnection:Disconnect()
                InfLungeConnection = nil
            end
            character:SetAttribute("lungeboost", 1)
        end
    end
})

KillerBlatantSection:AddDivider()

Toggles.HookFarmHandle = KillerBlatantSection:AddToggle({
    Title = "Hook Farm (Sekrup)",
    Content = "Gunakan untuk farming sekrup, harus hook seseorang sekali.",
    Default = false,
    Callback = function(state)
        HookFarmToggle = state
    end
})

Toggles.HookTimesHandle = KillerBlatantSection:AddSlider({
    Title = "Jumlah Hook",
    Min = 2,
    Max = 1000,
    Default = 10,
    Callback = function(Value)
        HookTimes = tonumber(Value)
    end
})

KillerSection = KillerTab:AddSection("Berburu", true)

Toggles.OneTapHandle = KillerSection:AddToggle({
    Title = "Damage Aura",
    Content = "Melemparkan siklus serangan ke lokasi yang Anda hadapi.",
    Default = false,
    Callback = function(state)
        getgenv().AXS_DamageAura = state
        if state then
            task.spawn(function()
                while getgenv().AXS_DamageAura and task.wait(0.1) do
                    game.ReplicatedStorage.Remotes.Attacks.BasicAttack:FireServer()
                end
            end)
        end
    end
})

KillerSection:AddDivider()

Toggles.AutoAimChargedHandle = KillerSection:AddToggle({
    Title = "Auto Aim Tombak Terisi (Veil)",
    Content = "Otomatis membidik tombak terisi ke penyintas terdekat. ANDA HARUS MEMEGANG TOMBAK JANGAN LAPOR BUG",
    Default = false,
    Callback = function(state)
        AutoAimChargedToggle = state
        if state and AutoAimNormalToggle and Toggles.AutoAimNormalHandle then
            AutoAimNormalToggle = false
            Toggles.AutoAimNormalHandle:Set(false)
        end
    end
})

Toggles.AutoAimNormalHandle = KillerSection:AddToggle({
    Title = "Auto Aim Tombak (Veil)",
    Content = "Otomatis membidik tombak ke penyintas terdekat. ANDA HARUS MEMEGANG TOMBAK JANGAN LAPOR BUG",
    Default = false,
    Callback = function(state)
        AutoAimNormalToggle = state
        if state and AutoAimChargedToggle and Toggles.AutoAimChargedHandle then
            AutoAimChargedToggle = false
            Toggles.AutoAimChargedHandle:Set(false)
        end
    end
})

Toggles.SilentAimVeilHandle = KillerSection:AddToggle({
    Title = "Silent Aim (Veil Spear)",
    Content = "Otomatis melempar tombak ke target dalam FOV saat charge.",
    Default = false,
    Callback = function(state)
        if getgenv().SilentAimVeilSettings then getgenv().SilentAimVeilSettings.Enabled = state end
    end
})

Toggles.VeilShowFOVHandle = KillerSection:AddToggle({
    Title = "Show FOV Veil",
    Content = "Tampilkan lingkaran FOV Silent Aim Veil.",
    Default = true,
    Callback = function(state)
        if getgenv().SilentAimVeilSettings then getgenv().SilentAimVeilSettings.ShowFOV = state end
    end
})

Toggles.VeilESPHandle = KillerSection:AddToggle({
    Title = "ESP Khusus Veil",
    Content = "Tampilkan ESP khusus target Silent Aim Veil.",
    Default = false,
    Callback = function(state)
        if getgenv().SilentAimVeilSettings then getgenv().SilentAimVeilSettings.ESP = state end
    end
})

Toggles.VeilCrosshairHandle = KillerSection:AddToggle({
    Title = "Crosshair Veil",
    Content = "Tampilkan Crosshair khusus Silent Aim Veil.",
    Default = false,
    Callback = function(state)
        if getgenv().SilentAimVeilSettings then getgenv().SilentAimVeilSettings.Crosshair = state end
    end
})

KillerMiscSection = KillerTab:AddSection("Atribut", true)

Toggles.AntiFlashlightHandle = KillerMiscSection:AddToggle({
    Title = "Anti Senter (Flashlight)",
    Content = "Menghilangkan efek silau senter.",
    Default = false,
    Callback = function(state)
        AntiFlashlight = state
    end
})

Toggles.AntiSlowHandle = KillerMiscSection:AddToggle({
    Title = "Anti Lambat (Slow Down)",
    Content = "Menghilangkan efek kecepatan jalan negatif.",
    Default = false,
    Callback = function(state)
        AntislowToggle = state
    end
})

KillerMiscSection:AddButton({
    Title = "Aktifkan Emote",
    Callback = function()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            local emotesGui = pg:FindFirstChild("Emotes")
            if emotesGui then
               emotesGui.Enabled = true
            end
        end
    end
})

-- SURVIVOR

SurvSection = SurvivorTab:AddSection("Pertarungan", true)

Toggles.GodModeHandle = SurvSection:AddToggle({
    Title = "Mode Dewa (PREMIUM)",
    Content = "Mencegah kamu diserang, membuatmu tak terkalahkan.",
    Default = false,
    Callback = function(state)
        if state then
            if getgenv().PREMIUM_KEY then
                GodmodeToggle = true
            else
                GodmodeToggle = false
                Lib:MakeNotify({
                    Title = "Premium Feature",
                    Content = "This feature is only for premium users, get premium in our community.",
                    Time = 3
                })
                if Toggles.GodModeHandle then
                    Toggles.GodModeHandle:Set(false)
                end
            end
        else
            GodmodeToggle = false
        end
    end
})

Toggles.AutoTargetHandle = SurvSection:AddToggle({
    Title = "Auto Target (Aimbot)",
    Content = "Otomatis membidik ke target saat menekan tombol menembak (atau menahan crosshair di mobile).",
    Default = false,
    Callback = function(state)
        getgenv().AutoTargetToggle = state
    end
})

Toggles.AutoShootHandle = SurvSection:AddToggle({
    Title = "Auto Serang (Cerdas)",
    Content = "Otomatis menembak HANYA saat perlu (Killer menyerang, sangat dekat, atau dalam crosshair) & tidak sedang stun.",
    Default = false,
    Callback = function(state)
        getgenv().AutoSerangToggle = state
        if getgenv().SilentAimPistolSettings then getgenv().SilentAimPistolSettings.Enabled = state end
    end
})

Toggles.PistolShowFOVHandle = SurvSection:AddToggle({
    Title = "Show FOV Pistol",
    Content = "Tampilkan lingkaran FOV Silent Aim Pistol.",
    Default = false,
    Callback = function(state)
        if getgenv().SilentAimPistolSettings then getgenv().SilentAimPistolSettings.ShowFOV = state end
    end
})

Toggles.PistolLaserHandle = SurvSection:AddToggle({
    Title = "Laser Target Lock",
    Content = "Tampilkan Laser Tracer Silent Aim Pistol ke target.",
    Default = false,
    Callback = function(state)
        if getgenv().SilentAimPistolSettings then getgenv().SilentAimPistolSettings.Laser = state end
    end
})

Toggles.PistolStunESPHandle = SurvSection:AddToggle({
    Title = "ESP Stunned Detect",
    Content = "Tampilkan status ESP Stunned saat killer ter-stun.",
    Default = false,
    Callback = function(state)
        if getgenv().SilentAimPistolSettings then getgenv().SilentAimPistolSettings.StunESP = state end
    end
})

Toggles.ShootTargetHandle = SurvSection:AddDropdown({
    Title = "Pilih Target Aim",
    Options = { "Killers", "Players" },
    Default = "",
    Callback = function(option)
        selectedTarget = option
    end
})

Toggles.AimPartHandle = SurvSection:AddDropdown({
    Title = "Bagian Target Aim",
    Options = { "Kepala", "Badan", "Pundak Kanan", "Pundak Kiri" },
    Default = "Kepala",
    Callback = function(option)
        AimPart = option
    end
})

SurvDefSection = SurvivorTab:AddSection("Looping", true)

local ParryVisuals = nil
local function UpdateParryVisuals(state)
    local shouldShow = state and Autoparry and (getgenv().ParryVisualsEnabled ~= false)
    
    if shouldShow then
        if not ParryVisuals then
            ParryVisuals = Instance.new("CylinderHandleAdornment")
            ParryVisuals.Name = "ParryRadiusVisual"
            ParryVisuals.Height = 0.05
            ParryVisuals.CFrame = CFrame.new(0, -2.95, 0) * CFrame.Angles(math.rad(90), 0, 0)
            ParryVisuals.Color3 = Color3.fromRGB(255, 253, 208) -- Cream
            ParryVisuals.Transparency = 0.6
            ParryVisuals.AlwaysOnTop = false
            ParryVisuals.ZIndex = 0
            ParryVisuals.Adornee = root
            ParryVisuals.Parent = root
        end
        ParryVisuals.Radius = ParryDistance
        ParryVisuals.InnerRadius = ParryDistance - 0.2
        ParryVisuals.Visible = true
        if root then 
            ParryVisuals.Adornee = root
            ParryVisuals.Parent = root 
        end
    else
        if ParryVisuals then
            ParryVisuals:Destroy()
            ParryVisuals = nil
        end
    end
end

Toggles.AutoParryHandle = SurvDefSection:AddToggle({
    Title = "Auto Tangkis Pembunuh",
    Content = "Otomatis menangkis (stun) pembunuh, harus punya parrying dagger sebagai penyintas.",
    Default = false,
    Callback = function(state)
        Autoparry = state
        if getgenv().AutoParrySettings then getgenv().AutoParrySettings.Enabled = state end
        UpdateParryVisuals(state)
    end
})

Toggles.SmartFaceHandle = SurvDefSection:AddToggle({
    Title = "Auto Face Killer (Smart Face)",
    Content = "Otomatis menghadap pembunuh saat menangkis. Matikan jika mengganggu pergerakan.",
    Default = true,
    Callback = function(state)
        SmartFace = state
    end
})

Toggles.VisualParryHandle = SurvDefSection:AddToggle({
    Title = "Visual Radius Tangkis",
    Content = "Menampilkan lingkaran radius auto tangkis.",
    Default = true,
    Callback = function(state)
        getgenv().ParryVisualsEnabled = state
        UpdateParryVisuals(Autoparry)
    end
})

Toggles.ParrySliderHandle = SurvDefSection:AddSlider({
    Title = "Radius Tangkis",
    Min = 5,
    Max = 30,
    Default = 20,
    Callback = function(Value)
        ParryDistance = tonumber(Value)
        if getgenv().AutoParrySettings then getgenv().AutoParrySettings.Range = tonumber(Value) or 20 end
        if Autoparry then UpdateParryVisuals(true) end
    end
})

Toggles.ParryDelayHandle = SurvDefSection:AddSlider({
    Title = "Jeda Tangkis (Delay)",
    Min = 0,
    Max = 1,
    Default = 0,
    Callback = function(Value)
        ParryDelay = tonumber(Value)
    end
})

Toggles.ParryMethodHandle = SurvDefSection:AddDropdown({
    Title = "Metode Tangkis",
    Options = { "Combined", "Lunge", "Attack (BETA)" },
    Default = "Lunge",
    Callback = function(option)
        ParryMethod = option
    end
})


if getrawmetatable and setreadonly then
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if NoFallToggle and self == FallRemote and method == "FireServer" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
else
    warn("[Arexans] Executor does not support metatable hooking (getrawmetatable, setreadonly). NoFall Bypass Skipped.")
end

Toggles.NoFallHandle = SurvDefSection:AddToggle({
    Title = "No Fall (Anti Jatuh)",
    Content = "Menghilangkan efek jatuh.",
    Default = false,
    Callback = function(state)
        NoFallToggle = state 
    end
})

SurvDefSection:AddDivider()

Toggles.AutoDropHandle = SurvDefSection:AddToggle({
    Title = "Auto Jatuhkan Pallet",
    Content = "Menjatuhkan pallet tepat ke pembunuh, harus dekat.",
    Default = false,
    Callback = function(state)
        AutoDropToggle = state
        if state then autodrop() end
    end
})

Toggles.AutoDropSetHandle = SurvDefSection:AddToggle({
    Title = "Pallet Saat Digendong?",
    Content = "Menjatuhkan pallet bahkan jika pembunuh menggendongmu melewati pallet.",
    Default = false,
    Callback = function(state)
        AutoDropSetToggle = state
    end
})

SurvMiscSection = SurvivorTab:AddSection("Objektif", true)

Toggles.PerfectGenHandle = SurvMiscSection:AddToggle({
    Title = "Auto Perfect Generator",
    Content = "Melakukan skill check generator di titik sempurna.",
    Default = false,
    Callback = function(state)
        if state then
            if getgenv().AXS_Connections["AutoGenerator"] then getgenv().AXS_Connections["AutoGenerator"]:Disconnect() end
            getgenv().AXS_Connections["AutoGenerator"] = RunService.Heartbeat:Connect(autoperfectgen)
        else
            if getgenv().AXS_Connections["AutoGenerator"] then
                getgenv().AXS_Connections["AutoGenerator"]:Disconnect()
                getgenv().AXS_Connections["AutoGenerator"] = nil
            end
        end
    end
})

Toggles.PerfectHealHandle = SurvMiscSection:AddToggle({
    Title = "Auto Perfect Heal",
    Content = "Melakukan skill check penyembuhan di titik sempurna.",
    Default = false,
    Callback = function(state)
        if state then
            HealConnection = RunService.Heartbeat:Connect(autoperfectheal)
        else
            if HealConnection then
                HealConnection:Disconnect()
                HealConnection = nil
            end
        end
    end
})

SurvMiscSection:AddDivider()

Toggles.AntiGFailHandle = SurvMiscSection:AddToggle({
    Title = "Anti Gagal Generator",
    Content = "Gagal skill check generator tidak akan meledak.",
    Default = false,
    Callback = function(state)
        AntiGFail = state
    end
})

Toggles.RemoveClothingsHandle = SurvMiscSection:AddToggle({
    Title = "Hapus Pakaian Veil",
    Content = "Membuat pembunuh Veil telanjang.",
    Default = false,
    Callback = function(state)
        RemoveClothingsToggle = state
    end
})

local antiCampConns = {}
Toggles.AntiCampHandle = SurvMiscSection:AddToggle({
    Title = "Anti Camp Selalu Berjalan",
    Content = "Membuat bar loading 'Kamp Anti' untuk kabur dari hook terus terisi penuh tanpa batas jarak killer.",
    Default = false,
    Callback = function(state)
        getgenv().AntiCampToggle = state
        
        for _, conn in ipairs(antiCampConns) do
            if conn.Connected then conn:Disconnect() end
        end
        table.clear(antiCampConns)
        
        if state then
            local function enforceCamp(char)
                if not char then return end
                
                local function forceVal(attr)
                    if not getgenv().AntiCampToggle then return end
                    if char:GetAttribute("IsHooked") then
                        local current = char:GetAttribute(attr)
                        if current ~= 100 then
                            char:SetAttribute(attr, 100)
                            pcall(function()
                                game.ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer(attr, 100)
                            end)
                        end
                    end
                end
                
                local attrs = {"AntiCampMeter", "CampMeter", "CampProgress", "AntiCampProgress", "AntiCampServer"}
                for _, attr in ipairs(attrs) do
                    local conn = char:GetAttributeChangedSignal(attr):Connect(function() forceVal(attr) end)
                    table.insert(antiCampConns, conn)
                end
            end
            
            if character then enforceCamp(character) end
            
            local charAddedConn = lp.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                enforceCamp(newChar)
            end)
            table.insert(antiCampConns, charAddedConn)
            
            task.spawn(function()
                while getgenv().AntiCampToggle do
                    task.wait(0.1)
                    if character and character:GetAttribute("IsHooked") then
                        character:SetAttribute("AntiCampMeter", 100)
                        character:SetAttribute("CampMeter", 100)
                        character:SetAttribute("CampProgress", 100)
                        character:SetAttribute("AntiCampProgress", 100)
                        character:SetAttribute("AntiCampServer", 100)
                        character:SetAttribute("CanSelfUnhook", true)
                        
                        pcall(function()
                            game.ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("AntiCampMeter", 100)
                            game.ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("CampMeter", 100)
                        end)
                    end
                end
            end)
        end
    end
})

SurvMiscSection:AddButton({
    Title = "Kabur Instan",
    Callback = function()
        local gate = workspace.Map:FindFirstChild("Gate")
        if gate then
            local box = gate:FindFirstChild("Box")
            if box and box:IsA("BasePart") then
                local backCFrame = box.CFrame * CFrame.new(0, 0, -50)
                root.CFrame = CFrame.new(backCFrame.Position, box.Position)
            end
        end
    end
})

SurvMiscSection:AddButton({
    Title = "Hancurkan Gerbang",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        if not map then return end

        for _, gate in ipairs(map:GetChildren()) do
            if gate.Name == "Gate" and gate:IsA("Model") then
                gate:Destroy()
            end
        end
    end
})

-- ESP

local FOVRadius = 70
getgenv().FOV_Enabled = false
RunService.Heartbeat:Connect(function()
    if getgenv().FOV_Enabled and game.workspace.CurrentCamera.FieldOfView ~= FOVRadius then
        game.workspace.CurrentCamera.FieldOfView = FOVRadius
    end
end)

EspSection = EspTab:AddSection("Visual", true)

EspSection:AddToggle({
    Title = "Kunci FOV",
    Content = "Mengunci Field of View kamera ke radius tertentu.",
    Default = false,
    Callback = function(state)
        getgenv().FOV_Enabled = state
        if not state then
            game.workspace.CurrentCamera.FieldOfView = 70 -- Reset ke default
        end
    end
})

Toggles.ShowFPSHandle = EspSection:AddToggle({
    Title = "Tampilkan FPS",
    Content = "Menampilkan penghitung FPS di pojok layar.",
    Default = false,
    Callback = function(state)
        if state then
            CreateFPS()
        else
            RemoveFPS()
        end
    end
})

Toggles.FOVSliderHandle = EspSection:AddSlider({
    Title = "Radius FOV",
    Min = 1,
    Max = 120,
    Default = 70,
    Callback = function(Value)
        FOVRadius = tonumber(Value)
    end
})

Toggles.InfiniteZoomHandle = EspSection:AddToggle({
    Title = "Infinite Zoom Out",
    Content = "Allows you to zoom out infinitely.",
    Default = false,
    Callback = function(state)
        getgenv().InfiniteZoom = state
        if state then
             task.spawn(function()
                 while getgenv().InfiniteZoom do
                     lp.CameraMaxZoomDistance = 100000
                     task.wait(1)
                 end
                 lp.CameraMaxZoomDistance = 12.5
             end)
        else
             lp.CameraMaxZoomDistance = 12.5
        end
    end
})

local oldAmbient, oldOutdoor, oldBrightness, oldShadows
EspSection:AddToggle({
    Title = "Terang Penuh (Full Bright)",
    Content = "Membuat game menjadi terang benderang.",
    Default = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            oldAmbient = Lighting.Ambient
            oldOutdoor = Lighting.OutdoorAmbient
            oldBrightness = Lighting.Brightness
            oldShadows = Lighting.GlobalShadows
            
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ShadowSoftness = 0
            Lighting.GlobalShadows = false
        else
            if oldAmbient then
                Lighting.Ambient = oldAmbient
                Lighting.OutdoorAmbient = oldOutdoor
                Lighting.Brightness = oldBrightness
                Lighting.GlobalShadows = oldShadows
            end
        end
    end
})

EspSection:AddDropdown({
    Title = "ESP Style",
    Options = { "Full", "Outline Only" },
    Default = "Full",
    Callback = function(option)
        ESPStyle = option
    end
})

Toggles.ESPDropdownHandle = EspSection:AddDropdown({
    Title = "ESP's",
    Options = { "Killers", "Players", "Generators", "Presents", "Windows", "Pallets" },
    Default = { "Killers", "Players", "Windows", "Pallets" },
    Multi = true,
    Callback = function(option)
        selectedESPTypes = option
    end
})

Toggles.ESPHighlightHandle = EspSection:AddToggle({
    Title = "Highlight Objek",
    Content = "Menandai objek, fitur paling berguna.",
    Default = false,
    Callback = function(state)
        ESPHighlight = state
    end
})

Toggles.ESPTracersHandle = EspSection:AddToggle({
    Title = "Tampilkan Tracer (Garis)",
    Content = "Menambahkan garis penunjuk ke objek ESP.",
    Default = false,
    Callback = function(state)
        ESPTracers = state
    end
})

Toggles.ESPBoxesHandle = EspSection:AddToggle({
    Title = "Tampilkan Kotak (Box)",
    Content = "Menambahkan kotak yang menunjukkan hitbox objek ESP.",
    Default = false,
    Callback = function(state)
        ESPBoxes = state
    end
})

Toggles.ESPNamesHandle = EspSection:AddToggle({
    Title = "Tampilkan Nama",
    Content = "Menambahkan nama objek di atas kepala objek.",
    Default = false,
    Callback = function(state)
        ESPNames = state
    end
})

Toggles.ESPStudsHandle = EspSection:AddToggle({
    Title = "Tampilkan Jarak (Studs)",
    Content = "Menambahkan jarak di atas kepala objek.",
    Default = false,
    Callback = function(state)
        ESPStuds = state
    end
})

-- PLAYER

PlayerSection = PlayerTab:AddSection("Main", true)

Toggles.NoclipHandle = PlayerSection:AddToggle({
    Title = "Noclip (Tembus Tembok)",
    Content = "Tembus tembok dengan mengaktifkan ini.",
    Default = false,
    Callback = function(state)
        NoclipToggle = state
        if state then
            noclip()
        else
            clip()
        end
    end
})

Toggles.WsToggleHandle = PlayerSection:AddToggle({
    Title = "Kunci Kecepatan Jalan",
    Content = "Mengunci kecepatan jalan sesuai preferensi (Bertahan saat respawn).",
    Default = false,
    Callback = function(state)
        WalkToggle = state
        applyBypassSpeed()
    end
})

Toggles.WsSliderHandle = PlayerSection:AddSlider({
    Title = "Kecepatan Jalan",
    Min = 10,
    Max = 100,
    Default = 28,
    Callback = function(Value)
        currentSpeed = Value
    end
})

-- MISC

MiscSection = MiscTab:AddSection("Main", true)

local antiAfkToggle = false
local FlingToggle = false
local antiFlingToggle = false
local flingThread

local function fling()
    local movel = 0.1
    while FlingToggle do
        RunService.Heartbeat:Wait()
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

task.spawn(function()
	while task.wait(60) do
		if antiAfkToggle then
			game:GetService("VirtualUser"):CaptureController()
			game:GetService("VirtualUser"):ClickButton2(Vector2.new())
		end
	end
end)

MiscSection:AddInput({
    Title = "Hit Sound",
    Content = "rbxassetid://",
    Callback = function(input) 
    end
})

MiscSection:AddDropdown({
    Title = "Chase Theme",
    Options = { "Mila - Compass" },
    Default = chasetheme,
    Callback = function(option)
        chasetheme = option
    end
})

local idConn
Toggles.ProtectIdentityHandle = MiscSection:AddToggle({
    Title = "Protect Identity",
    Content = "Hides user, avatar, etc.",
    Default = false,
    Callback = function(state)
        local function bacon(c)
            if not character then return end
            for _, v in pairs(character:GetChildren()) do 
                if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then v:Destroy() end 
            end
            if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then character.Head.face.Texture = "rbxassetid://144075659" end
            local bc = character:FindFirstChild("BodyColors") or Instance.new("BodyColors", c)
            bc.HeadColor3 = Color3.fromRGB(234, 184, 146); bc.TorsoColor3 = Color3.fromRGB(116, 134, 157); bc.LeftLegColor3 = Color3.fromRGB(82, 84, 82); bc.RightLegColor3 = Color3.fromRGB(82, 84, 82); bc.LeftArmColor3 = bc.HeadColor3; bc.RightArmColor3 = bc.HeadColor3
            if lp then
                lp.Name = "Arexans"
                lp.DisplayName = "Arexans"
            end
        end

        if state then
            bacon(character)
            if idConn then idConn:Disconnect() end
            idConn = lp.CharacterAdded:Connect(function(c)
                bacon(c)
                task.wait(2)
                bacon(c) 
            end)
        else
            if idConn then idConn:Disconnect() end
        end
    end
})

Toggles.antiAfkHandle = MiscSection:AddToggle({
    Title = "Anti AFK",
    Content = "If enabled, jumps every minute so you wouldn't get kicked out for AFK.",
    Default = false,
    Callback = function(state)
        antiAfkToggle = state
    end
})

Toggles.antiFlingHandle = MiscSection:AddToggle({
    Title = "Anti Fling",
    Content = "If enabled, no one could fling you off map.",
    Default = false,
    Callback = function(state)
        antiFlingToggle = state
        if not state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do -- descen
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end
})

Toggles.FlingHandle = MiscSection:AddToggle({
    Title = "Touch Fling",
    Content = "If enabled, you could fling anyone in map by touching them.",
    Default = false,
    Callback = function(state)
        FlingToggle = state
    end
})

local antiAdminToggle = false
Toggles.antiAdminHandle = MiscSection:AddToggle({
    Title = "Anti Admin",
    Content = "If enabled, kicks you out if there's admin in your experience.",
    Default = false,
    Callback = function(state)
        antiAdminToggle = state
    end
})

task.spawn(function()
	while task.wait(1) and antiAdminToggle do
	       for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= lp and (table.find(blacklist, plr.UserId) or bannedRanks[plr:GetRoleInGroup(gid)]) then
				lp:Kick("Admin detected: " .. plr.Name)
			end
		end
	end
end)

task.spawn(function()
    while task.wait(0.1) do
        if GodmodeToggle then
           hum.Health = 100
           character:SetAttribute("IsCarried", false)
           character:SetAttribute("IsHooked", false)
           character:SetAttribute("Knocked", false)
        end
        if FlingToggle then
            fling()
        end
    end
end)

-- CONFIG

-- uixans.lua handles config automatically via LoadConfigFromFile / SaveConfig called inside elements.
-- But we can add manual buttons if desired.

ConfigSection = ConfigTab:AddSection("Main", true)

ConfigSection:AddButton({
    Title = "Save Config",
    Callback = function()
        Lib:Save()
        Lib:MakeNotify({ Title = "Config", Content = "Configuration saved.", Time = 3 })
    end
})

ConfigSection:AddButton({
    Title = "Copy Config",
    Callback = function()
        local data = Lib:ExportConfig()
        setclipboard(data)
        Lib:MakeNotify({ Title = "Config", Content = "Copied to clipboard!", Time = 3 })
    end
})

ConfigSection:AddInput({
    Title = "Import Config",
    Content = "Paste JSON here",
    Default = "",
    Callback = function(text)
        if text and text ~= "" then
            local success = Lib:ImportConfig(text)
            if success then
                Lib:MakeNotify({ Title = "Config", Content = "Config loaded successfully.", Time = 3 })
            else
                Lib:MakeNotify({ Title = "Config", Content = "Invalid Config JSON.", Time = 3 })
            end
        end
    end
})

ConfigSection:AddButton({
    Title = "Reset Config",
    Callback = function()
        Lib:ResetAll()
        Lib:MakeNotify({ Title = "Config", Content = "All settings reset.", Time = 3 })
    end
})

ConfigSection:AddToggle({
    Title = "Kunci Icon Mengambang",
    Content = "Mencegah icon UI untuk digerakkan (di-drag).",
    Default = false,
    Callback = function(state)
        local gui = game:GetService("CoreGui"):FindFirstChild("ToggleUIButton")
        if not gui then return end
        
        local mainBtn = gui:FindFirstChildOfClass("ImageLabel")
        if not mainBtn then return end
        
        local shieldName = "LockShield"
        local shield = mainBtn:FindFirstChild(shieldName)
        
        if not shield then
            shield = Instance.new("TextButton")
            shield.Name = shieldName
            shield.Size = UDim2.fromScale(1, 1)
            shield.BackgroundTransparency = 1
            shield.Text = ""
            shield.ZIndex = 50 -- Higher than underlying button
            shield.Parent = mainBtn
            
            shield.MouseButton1Click:Connect(function()
                -- Mimic original toggle behavior
                if game:GetService("CoreGui"):FindFirstChild("Chloeex") then
                    local dropShadow = game:GetService("CoreGui").Chloeex:FindFirstChild("DropShadowHolder")
                    if dropShadow then
                        dropShadow.Visible = not dropShadow.Visible
                    end
                end
            end)
        end
        
        shield.Visible = state
    end
})

-- LOGIC LOOPS (continued)

AddBind(KeybindSection, "Kursor Mouse", nil, ToggleMouseCursor)
AddBind(KeybindSection, "Lompat Manual (PC)", nil, function()
    if root and hum then 
        if hum.FloorMaterial ~= Enum.Material.Air then
            root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
AddBind(KeybindSection, "Crosshair", nil, Toggles.CrosshairHandle)
AddBind(KeybindSection, "Auto Aim Killer", nil, Toggles.AutoAimNormalHandle)
AddBind(KeybindSection, "Auto Target", nil, Toggles.AutoTargetHandle)
AddBind(KeybindSection, "Auto Serang", nil, Toggles.AutoShootHandle)
AddBind(KeybindSection, "Auto Tangkis", nil, Toggles.AutoParryHandle)
AddBind(KeybindSection, "Noclip", nil, Toggles.NoclipHandle)
AddBind(KeybindSection, "Speed", nil, Toggles.WsToggleHandle)

local uicreated = false
local dropdownCreated = false

task.spawn(function()
	while task.wait(1) do
		local gui = lp:FindFirstChild("PlayerGui")
               local myKiller = getKiller()

               if myKiller == "Masked" and not dropdownCreated and InfThingsToggle then
                   createDropdown()
                   dropdownCreated = true
              end

		if RemoveClothingsToggle then
		    for _, pl in ipairs(game.Workspace:GetChildren()) do
		        if pl:FindFirstChild("spearmanager") then
		            for _, item in ipairs(pl:GetChildren()) do
		                if item:IsA("BasePart") and string.lower(item.Name):find("hat") then item:Destroy() end
		            end
		        end
		    end
		end

		if AntiFlashlight and gui then
			local mobNames = {"Slasher-mob", "Masked-mob", "Hidden-mob", "Veil-mob", "Stalker-mob", "Jeff-mob"}
			for _, name in ipairs(mobNames) do
				local mob = gui:FindFirstChild(name)
				if mob then
					local Blind = mob:FindFirstChild("Blind")
					if Blind then
						Blind.Visible = false
						pcall(function() Blind:Destroy() end)
					end
				end
			end
            
            -- Universal check for any GUI named "Blind" or "FlashlightEffect"
            for _, d in ipairs(gui:GetDescendants()) do
                if (d.Name == "Blind" or d.Name == "FlashlightEffect") and d:IsA("GuiObject") and d.Visible then
                    d.Visible = false
                end
            end
            
            -- Lighting check
            local lighting = game:GetService("Lighting")
            for _, eff in ipairs(lighting:GetChildren()) do
                if eff.Name == "FlashlightLight" or eff.Name == "BlindEffect" then
                    eff:Destroy()
                end
            end
		end

		if AntislowToggle and hum then
            -- Prevent WalkSpeed from being lowered by game scripts if it's below a threshold
            if hum.WalkSpeed < 16 and not WalkToggle then
                 hum.WalkSpeed = 16
            end
            
            -- Remove common slow attributes if they exist
            if hum:GetAttribute("Slowed") then hum:SetAttribute("Slowed", nil) end
            if hum:GetAttribute("Stunned") then hum:SetAttribute("Stunned", nil) end
		end

		if ExpandHitboxesToggle then
            local amIKiller = character:FindFirstChild("Killerost") or character:FindFirstChild("Lookscriptkiller")
            local targetCache = amIKiller and getgenv().ESP_Cache or getgenv().KillerCache
            
            for _, model in ipairs(targetCache or {}) do
                if model:IsA("Model") and model ~= character then
                    local isTarget = false
                    if amIKiller then
                        if model:FindFirstChild("Highlight-forsurvivor") then
                            isTarget = true
                        end
                    else
                        isTarget = true 
                    end

                    if isTarget then
                        local part = model:FindFirstChild("HumanoidRootPart")
                        if part and part:IsA("BasePart") then
                            local targetSize = Vector3.new(HitboxesRadius, HitboxesRadius, HitboxesRadius)
                            if part.Size ~= targetSize then
                                part.Size = targetSize
                            end
                            
                            if part.CanCollide then
                                part.CanCollide = false
                            end

                            local targetTrans = HitboxesVisibleToggle and 0.5 or 1
                            if part.Transparency ~= targetTrans then
                                part.Transparency = targetTrans
                            end
                        end
                    end
                end
            end
        end
               
		if InfThingsToggle and gui then
			local mob = gui:FindFirstChild("Slasher-mob") or gui:FindFirstChild("Masked-mob") or gui:FindFirstChild("Hidden-mob")
			if mob then
				local controls = mob:FindFirstChild("Controls")
				if controls then
					local powerOne = controls:FindFirstChild("move1")
					local powerTwo = controls:FindFirstChild("move2")
					local attack = controls:FindFirstChild("attack")

					if powerOne then hookButton(powerOne) end
					if powerTwo then hookButton(powerTwo) end
					if attack then hookButton(attack) end

					-- No GUI created
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.2) do
	       for _, obj in ipairs(SoundService:GetChildren()) do
			if obj:IsA("Sound") and obj ~= chaseSound and (chasetheme == "Mila - Compass" or chasetheme == "Close To Me") then
				if string.lower(obj.Name) == "chasemusic" then
					obj.Volume = 0
					obj.Playing = false
				end
			end
		end
	end
end)

ReplicatedStorage.Remotes.Carry.HookEvent.OnClientEvent:Connect(function(...)
    if not HookFarmToggle then return end
    for i = 1, HookTimes do
        ReplicatedStorage.Remotes.Carry.HookEvent:FireServer(...)
    end
end)

ReplicatedStorage.Remotes.Generator.SkillCheckEvent.OnClientEvent:Connect(function(generator, point, context)
    if not AntiGFail then return end
    ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent:FireServer("success", 1, generator, point)
end)

local PredictionTime = 0.14
local MinDistance = 10
local MaxDistance = 200
local MinPitch = -1
local MaxPitch = 30

local PitchTable = {
    [0] = 0.09, [1] = 0.90, [2] = 1.9, [3] = 2.9, [4] = 3.9,
    [5] = 4.9, [6] = 5.9, [7] = 6.9, [8] = 7.9, [9] = 8.9,
    [10] = 10.9, [11] = 11.9, [12] = 12.9, [13] = 13.9, [14] = 14.9,
    [15] = 15.9, [16] = 16.9, [17] = 17.9, [18] = 18.9, [19] = 20.3,
    [20] = 22.3
}
local FallbackPitch = 23.3
local aimConnection

local function InitializeCharacter(newChar)
    character = newChar
    root = newChar:WaitForChild("HumanoidRootPart", 9)

    if aimConnection then 
        aimConnection:Disconnect() 
        aimConnection = nil 
    end
    newChar:GetAttributeChangedSignal('spearmode'):Connect(function()
        local isSpearMode = newChar:GetAttribute('spearmode')

        if aimConnection then 
            aimConnection:Disconnect() 
            aimConnection = nil 
        end
        
        if isSpearMode then 
            aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not (AutoAimNormalToggle or AutoAimChargedToggle) then return end
                if not root then return end

                local targetChar = nil
                local shortestMetric = math.huge
                
                for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
                    if v ~= lp and v.Character then
                        local char = v.Character
                        
                        if char:GetAttribute("IsHooked") or char:GetAttribute("IsCarried") or char:GetAttribute("Knocked") then continue end

                        local tHead = char:FindFirstChild("Head")
                        local tRoot = char:FindFirstChild("HumanoidRootPart")
                        local tHum = char:FindFirstChild("Humanoid")

                        if tHead and tRoot and tHum and tHum.Health > 0 then
                            if AutoAimNormalToggle then
                                local screenPos, onScreen = Camera:WorldToViewportPoint(tHead.Position)
                                if onScreen then
                                    local dist2D = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                                    if dist2D < shortestMetric then
                                        shortestMetric = dist2D
                                        targetChar = char
                                    end
                                end
                            elseif AutoAimChargedToggle then
                                local dist3D = (tHead.Position - root.Position).Magnitude
                                if dist3D < shortestMetric then
                                    shortestMetric = dist3D
                                    targetChar = char
                                end
                            end
                        end
                    end
                end

                if not targetChar then return end
                local tHead = targetChar.Head
                local tVel = targetChar.HumanoidRootPart.Velocity
                
                local predictedPos = tHead.Position + (tVel * PredictionTime)
                local camPos = Camera.CFrame.Position
                local distToTarget = (predictedPos - camPos).Magnitude
                
                local finalPitch = 0

                if AutoAimNormalToggle then
                    local alpha = math.clamp((distToTarget - MinDistance) / (MaxDistance - MinDistance), 0, 1)
                    finalPitch = MinPitch + (MaxPitch - MinPitch) * alpha
                    
                elseif AutoAimChargedToggle then
                    local index = math.floor(distToTarget / 10)
                    finalPitch = PitchTable[index] or FallbackPitch
                end
                
                local dir = (predictedPos - camPos).Unit
                local yaw = math.atan2(dir.X, dir.Z)
                local pitchRad = math.rad(finalPitch)

                local look = Vector3.new(
                    math.sin(yaw) * math.cos(pitchRad),
                    math.sin(pitchRad),
                    math.cos(yaw) * math.cos(pitchRad)
                )

                Camera.CFrame = CFrame.new(camPos, camPos + look)
            end)
        end
    end)
end

lp.CharacterAdded:Connect(InitializeCharacter)
if lp.Character then
    InitializeCharacter(lp.Character)
end

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Chase"):WaitForChild("ChaseMusicEvent").OnClientEvent:Connect(function(action)
       if chasetheme == "Default" or (chasetheme ~= "Mila - Compass" and chasetheme ~= "Close To Me") then return end
	local soundid = getSoundIdFromTheme()

	if action == "StartImmediate" then
		setupChaseMusic(soundid)

	elseif action == "FadeOut" then
		fadeTo(0, 10)

	elseif action == "FadeIn" then
		if chaseSound then
			fadeTo(1.2, 0)
		else
			setupChaseMusic(soundid)
		end
	end
end)

task.spawn(function()
while task.wait(0.5) do
  if antiFlingToggle then
     for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            for _, part in ipairs(plr.Character:GetChildren()) do --descen
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
     end
  end
end
end)
task.spawn(function()
    while task.wait(0.5) do
        if lp and lp.Character then
             local r = lp.Character:FindFirstChild("HumanoidRootPart")
             if r then
                 pcall(function()
                      r:SetNetworkOwner(lp)
                 end)
                 pcall(function()
                      sethiddenproperty(lp, "SimulationRadius", 1000)
                 end)
             end
        end
    end
end)

getgenv().KillerCache = {}
task.spawn(function()
    while task.wait(10) do
        local kCache = {}
        local eCache = getgenv().ESP_Cache or {}
        
        local function process(obj)
            local t = getObjType(obj)
            if t == "Killers" then
                if not table.find(kCache, obj) then table.insert(kCache, obj) end
                if not table.find(eCache, obj) then
                    table.insert(eCache, obj)
                    if passesFilter(obj) then ensureAllFor(obj) end
                end
            elseif t == "Players" then
                if not table.find(eCache, obj) then
                    table.insert(eCache, obj)
                    if passesFilter(obj) then ensureAllFor(obj) end
                end
            end
        end

        for _, obj in ipairs(workspace:GetChildren()) do
            process(obj)
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                process(p.Character)
            end
        end

        getgenv().KillerCache = kCache
        getgenv().ESP_Cache = eCache
    end
end)

getgenv().ParryVisualsEnabled = true