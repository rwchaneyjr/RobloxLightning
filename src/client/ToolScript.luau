local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local remote = tool:WaitForChild("LightningRemote")

tool.Activated:Connect(function()
	remote:FireServer(tool.Handle.Position, mouse.Hit.Position)
end)
