local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightningBolt = require(ReplicatedStorage:WaitForChild("LightningBolt"))

local function hookTool(tool)
	if tool.Name ~= "LightningShooter" then
		return
	end
	local remote = tool:FindFirstChild("LightningRemote")
	if not remote then
		return
	end

	remote.OnServerEvent:Connect(function(shooter, origin, target, hitInstance)
		LightningBolt.Draw(origin, target)

		if hitInstance and hitInstance:IsA("BasePart") then
			local model = hitInstance:FindFirstAncestorOfClass("Model")
			local hitPlayer = Players:GetPlayerFromCharacter(model)

			if hitPlayer then
				local hum = model:FindFirstChild("Humanoid")
				if hum then
					hum:TakeDamage(35)
				end
				return
			end

			task.spawn(function()
				local parts = model and model:GetDescendants() or { hitInstance }

				for _, p in parts do
					if p:IsA("BasePart") then
						p.Color = Color3.fromRGB(255, 255, 100)
						p.Material = Enum.Material.Neon
					end
				end

				task.wait(0.1)

				for _, p in parts do
					if p:IsA("BasePart") then
						p.Color = Color3.fromRGB(255, 80, 0)
					end
				end

				task.wait(0.15)

				local explosion = Instance.new("Explosion")
				explosion.Position = hitInstance.Position
				explosion.BlastRadius = 4
				explosion.BlastPressure = 0
				explosion.ExplosionType = Enum.ExplosionType.NoCraters
				explosion.DestroyJointRadiusPercent = 0
				explosion.Parent = workspace

				for _, p in parts do
					if p:IsA("BasePart") then
						p.Anchored = true
					end
				end

				for i = 1, 8 do
					task.wait(0.04)
					for _, p in parts do
						if p:IsA("BasePart") and p.Parent then
							p.Size = p.Size * 0.75
						end
					end
				end

				if model and model.Parent then
					model:Destroy()
				elseif hitInstance and hitInstance.Parent then
					hitInstance:Destroy()
				end
			end)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		for _, tool in char:GetChildren() do
			hookTool(tool)
		end
		char.ChildAdded:Connect(hookTool)

		local bp = player:WaitForChild("Backpack")
		for _, tool in bp:GetChildren() do
			hookTool(tool)
		end
		bp.ChildAdded:Connect(hookTool)
	end)
end)
