-- LightningShooter > ToolScript (LocalScript)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent
local remote = tool:WaitForChild("LightningRemote")
local LightningBolt = require(ReplicatedStorage:WaitForChild("LightningBolt"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local COOLDOWN = 0.3
local lastShot = 0
local equipped = false

tool.Equipped:Connect(function()
	equipped = true
	mouse.Icon = "rbxasset://textures/GunCursor.png"
end)

tool.Unequipped:Connect(function()
	equipped = false
	mouse.Icon = ""
end)

-- Shoot on click
tool.Activated:Connect(function()
	local now = tick()
	if now - lastShot < COOLDOWN then
		return
	end
	lastShot = now

	local char = player.Character
	if not char then
		return
	end

	local handle = tool:FindFirstChild("Handle")
	if not handle then
		return
	end

	local origin = handle.Position
	local target = mouse.Hit.Position

	-- Draw lightning bolt locally for instant feedback
	LightningBolt.Draw(origin, target)

	-- Tell server about the hit
	local hitInstance = mouse.Target
	remote:FireServer(origin, target, hitInstance)
end)
