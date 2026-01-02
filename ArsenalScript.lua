--=====================================
-- FONDI ARSENAL SCRIPT (FIXED)
--=====================================

if getgenv().FONDI_LOADED then return end
getgenv().FONDI_LOADED = true

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--======================
-- ANTI KICK
--======================
hookfunction(LocalPlayer.Kick, function()
	warn("Kick blocked")
end)

--======================
-- SETTINGS
--======================
local Settings = {
	ESP = true,
	Rage = false,
	Fly = false,
	Noclip = false
}

--======================
-- GUI
--======================
local Gui = Instance.new("ScreenGui")
Gui.Name = "FONDI_GUI"
Gui.ResetOnSpawn = false
Gui.Parent = game.CoreGui

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromScale(0.25, 0.6)
Main.Position = UDim2.fromScale(0.02, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.fromScale(1,0.1)
Title.BackgroundTransparency = 1
Title.Text = "FONDI | ARSENAL V1.2"
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)

local UIList = Instance.new("UIListLayout", Main)
UIList.Padding = UDim.new(0,8)
UIList.VerticalAlignment = Enum.VerticalAlignment.Top
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Main.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y+20)
end)

local function Button(text, callback)
	local b = Instance.new("TextButton", Main)
	b.Size = UDim2.fromScale(0.9,0.08)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.MouseButton1Click:Connect(callback)
	return b
end

--======================
-- ESP
--======================
local ESP = {}

local function CreateESP(p)
	if p == LocalPlayer then return end
	local box = Drawing.new("Square")
	box.Color = Color3.new(1,0,0)
	box.Thickness = 2
	box.Filled = false

	ESP[p] = box
end

local function RemoveESP(p)
	if ESP[p] then
		ESP[p]:Remove()
		ESP[p] = nil
	end
end

for _,p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--======================
-- RAGE AIMBOT
--======================
local function GetClosestEnemy()
	local closest, dist = nil, math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team then
			local c = p.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local pos, on = Camera:WorldToViewportPoint(hrp.Position)
				if on then
					local d = (Vector2.new(pos.X,pos.Y) - UIS:GetMouseLocation()).Magnitude
					if d < dist then
						dist = d
						closest = hrp
					end
				end
			end
		end
	end
	return closest
end

--======================
-- FLY
--======================
local BV, BG

local function StartFly()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	BV = Instance.new("BodyVelocity", hrp)
	BV.MaxForce = Vector3.new(1e5,1e5,1e5)
	BV.Velocity = Vector3.zero

	BG = Instance.new("BodyGyro", hrp)
	BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
end

local function StopFly()
	if BV then BV:Destroy() BV=nil end
	if BG then BG:Destroy() BG=nil end
end

--======================
-- BUTTONS
--======================
Button("ESP", function()
	Settings.ESP = not Settings.ESP
end)

Button("RAGE AIM", function()
	Settings.Rage = not Settings.Rage
end)

Button("FLY", function()
	Settings.Fly = not Settings.Fly
	if Settings.Fly then StartFly() else StopFly() end
end)

Button("NOCLIP", function()
	Settings.Noclip = not Settings.Noclip
end)

Button("TELEPORT", function()
	local tp = Instance.new("Frame", Gui)
	tp.Size = UDim2.fromScale(0.2,0.4)
	tp.Position = UDim2.fromScale(0.3,0.3)
	tp.BackgroundColor3 = Color3.fromRGB(25,25,25)
	tp.Active = true
	tp.Draggable = true

	local close = Instance.new("TextButton", tp)
	close.Size = UDim2.fromScale(1,0.1)
	close.Text = "CLOSE"
	close.TextScaled = true
	close.MouseButton1Click:Connect(function() tp:Destroy() end)

	local list = Instance.new("UIListLayout", tp)

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local b = Instance.new("TextButton", tp)
			b.Size = UDim2.fromScale(1,0.1)
			b.Text = p.Name
			b.TextScaled = true
			b.MouseButton1Click:Connect(function()
				local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,3)
				end
			end)
		end
	end
end)

--======================
-- MAIN LOOP
--======================
RunService.RenderStepped:Connect(function()
	-- ESP
	for p,box in pairs(ESP) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if Settings.ESP and hrp and hum and hum.Health > 0 then
			local pos,on = Camera:WorldToViewportPoint(hrp.Position)
			if on then
				box.Size = Vector2.new(60,100)
				box.Position = Vector2.new(pos.X-30,pos.Y-50)
				box.Visible = true
			else
				box.Visible = false
			end
		else
			box.Visible = false
		end
	end

	-- RAGE
	if Settings.Rage then
		local target = GetClosestEnemy()
		if target then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
			mouse1press()
			task.wait()
			mouse1release()
		end
	end

	-- NOCLIP
	if Settings.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _,v in ipairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end

	-- FLY MOVE
	if Settings.Fly and BV and BG then
		BV.Velocity = Camera.CFrame.LookVector * 60
		BG.CFrame = Camera.CFrame
	end
end)

print("FONDI ARSENAL SCRIPT LOADED")
