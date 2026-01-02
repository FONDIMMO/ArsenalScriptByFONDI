-- FONDI ARSENAL | XENO
-- FULL FIXED SCRIPT

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ================= ANTI KICK =================
pcall(function()
    LocalPlayer.Kick = function()
        warn("FONDI | Kick blocked")
        return
    end
end)

-- ================= SETTINGS =================
local Settings = {
    ESP = true,
    Aimbot = false,
    Rage = false,
    Fly = false,
    Noclip = false,
    TeamCheck = true,
    FOV = 200
}

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "FONDI_ARSENAL"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.28,0.55)
frame.Position = UDim2.fromScale(0.36,0.22)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.1)
title.BackgroundTransparency = 1
title.Text = "FONDI ARSENAL V1.0"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local content = Instance.new("Frame", frame)
content.Position = UDim2.fromScale(0,0.1)
content.Size = UDim2.fromScale(1,0.9)
content.BackgroundTransparency = 1

local function makeButton(txt,y,cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.fromScale(0.9,0.085)
    b.Position = UDim2.fromScale(0.05,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.Text = txt
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
end

makeButton("ESP",0.05,function() Settings.ESP = not Settings.ESP end)
makeButton("AIMBOT",0.15,function() Settings.Aimbot = not Settings.Aimbot end)
makeButton("RAGE MODE",0.25,function() Settings.Rage = not Settings.Rage end)
makeButton("FLY",0.35,function() Settings.Fly = not Settings.Fly end)
makeButton("NOCLIP",0.45,function() Settings.Noclip = not Settings.Noclip end)

-- ================= TELEPORT =================
makeButton("TELEPORT",0.55,function()
    local tp = Instance.new("Frame", gui)
    tp.Size = UDim2.fromScale(0.22,0.4)
    tp.Position = UDim2.fromScale(0.05,0.3)
    tp.BackgroundColor3 = Color3.fromRGB(25,25,25)
    tp.Active = true
    tp.Draggable = true

    local close = Instance.new("TextButton", tp)
    close.Size = UDim2.fromScale(1,0.1)
    close.Text = "CLOSE"
    close.Font = Enum.Font.GothamBold
    close.TextScaled = true
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundColor3 = Color3.fromRGB(120,40,40)
    close.MouseButton1Click:Connect(function() tp:Destroy() end)

    local y = 0.12
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", tp)
            b.Size = UDim2.fromScale(0.9,0.1)
            b.Position = UDim2.fromScale(0.05,y)
            b.Text = p.Name
            b.Font = Enum.Font.Gotham
            b.TextScaled = true
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(35,35,35)
            b.MouseButton1Click:Connect(function()
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and lhrp then
                    lhrp.CFrame = hrp.CFrame * CFrame.new(0,0,3)
                end
            end)
            y = y + 0.12
        end
    end
end)

-- ================= ESP =================
local ESP = {}

local function addESP(p)
    if p == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    ESP[p] = box
end

for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then ESP[p]:Remove() ESP[p]=nil end
end)

-- ================= AIM =================
local function getClosest()
    local best,dist=nil,Settings.FOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local c = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos,on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local d = (Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude
                    if d < dist then
                        dist = d
                        best = hrp
                    end
                end
            end
        end
    end
    return best
end

-- ================= FLY / NOCLIP =================
local bv,bg

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- AIM / RAGE
    if (Settings.Aimbot or Settings.Rage) then
        local t = getClosest()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- FLY
    if Settings.Fly and hrp then
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        end
        bv.Velocity = Camera.CFrame.LookVector * 60
        bg.CFrame = Camera.CFrame
    else
        if bv then bv:Destroy() bv=nil end
        if bg then bg:Destroy() bg=nil end
    end

    -- NOCLIP
    if Settings.Noclip and char then
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    -- ESP DRAW
    for p,box in pairs(ESP) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if Settings.ESP and hrp and hum and hum.Health > 0 then
            local pos,on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local size = Vector2.new(2000/pos.Z,3000/pos.Z)
                box.Size = size
                box.Position = Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                box.Color = Color3.fromRGB(255,0,0)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

print("FONDI ARSENAL | LOADED")
