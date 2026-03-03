local LightningBolt = {}

function LightningBolt.Draw(origin, target)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 255, 120)

	local distance = (origin - target).Magnitude
	part.Size = Vector3.new(0.2, 0.2, distance)
	part.CFrame = CFrame.new(origin, target) * CFrame.new(0,0,-distance/2)

	part.Parent = workspace

	game:GetService("Debris"):AddItem(part, 0.15)
end

return LightningBolt