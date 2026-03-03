local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightningBolt = require(ReplicatedStorage:WaitForChild("LightningBolt"))
local remote = ReplicatedStorage:WaitForChild("LightningRemote")

remote.OnServerEvent:Connect(function(player, origin, target)

	print("SERVER RECEIVED")

	local direction = (target - origin).Unit * 500

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin, direction, rayParams)

	if not result then return end

	local hitPart = result.Instance
	local hitPosition = result.Position

	LightningBolt.Draw(origin, hitPosition)

	if hitPart and hitPart:IsA("BasePart") then
		
		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 10
		fire.Parent = hitPart

		task.delay(2, function()
			if hitPart and hitPart.Parent then
				hitPart:Destroy()
			end
		end)
	end
end)