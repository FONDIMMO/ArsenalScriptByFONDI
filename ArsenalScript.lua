-- FONDI ARSENAL | XENO ONLY
-- NO VERSION / NO AUTO UPDATE
-- Prevent GUI destroy before kick
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    CoreGui.ChildRemoved:Connect(function(child)
        if child.Name == "FONDI_ARSENAL" then
            task.wait()
            child.Parent = CoreGui
            warn("FONDI | GUI restore")
        end
    end)
end)
-- FONDI ARSENAL | XENO ONLY
-- NO VERSION / NO AUTO UPDATE

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    ESP = true,
    Aimbot = false,
    Rage = false,
    Fly = false,
    Noclip = false,
    FOV = 150,
    TeamCheck = true
}

-- ================= GUI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FONDI_ARSENAL"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.3,0.6)
main.Position = UDim2.fromScale(0.35,0.2)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.1)
title.BackgroundTransparency = 1
title.Text = "FONDI ARSENAL"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local content = Instance.new("Frame", main)
content.Position = UDim2.fromScale(0,0.1)
content.Size = UDim2.fromScale(1,0.9)
content.BackgroundTransparency = 1

local function button(text,y,cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.fromScale(0.9,0.08)
    b.Position = UDim2.fromScale(0.05,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
end

button("ESP",0.05,function() Settings.ESP = not Settings.ESP end)
button("AIMBOT",0.15,function() Settings.Aimbot = not Settings.Aimbot end)
button("RAGE MODE (KILL ALL)",0.25,function() Settings.Rage = not Settings.Rage end)
button("FLY",0.35,function() Settings.Fly = not Settings.Fly end)
button("NOCLIP",0.45,function() Settings.Noclip = not Settings.Noclip end)

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

for _,p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then ESP[p]:Remove() ESP[p]=nil end
end)

-- ================= AIM / RAGE =================
local function getClosest()
    local best,dist=nil,Settings.FOV
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local c=p.Character
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local pos,on=Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local d=(Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude
                    if d<dist then dist=d best=hrp end
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

    if Settings.Noclip and char then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- AIM / RAGE
    if Settings.Aimbot or Settings.Rage then
        local t = getClosest()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- ESP
    for p,box in pairs(ESP) do
        local c=p.Character
        local hrp=c and c:FindFirstChild("HumanoidRootPart")
        local hum=c and c:FindFirstChildOfClass("Humanoid")
        if Settings.ESP and hrp and hum and hum.Health>0 then
            local pos,on=Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local size=Vector2.new(2000/pos.Z,3000/pos.Z)
                box.Size=size
                box.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                box.Color=Color3.fromRGB(255,0,0)
                box.Visible=true
            else box.Visible=false end
        else box.Visible=false end
    end
end)

print("FONDI ARSENAL LOADED")
