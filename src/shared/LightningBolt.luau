-- LightningBolt (ModuleScript) — place in ReplicatedStorage
-- Draws a jagged multi-segment lightning bolt between two points

local Debris = game:GetService("Debris")
local LightningBolt = {}

local SEGMENTS = 12       -- more = jaggier
local OFFSET_AMOUNT = 2.5 -- how far each segment can randomly deviate
local LIFETIME = 0.12     -- seconds before bolt disappears
local THICKNESS = 0.15    -- bolt width

local function makePart(a, b)
	local dist = (a - b).Magnitude
	if dist < 0.01 then return end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(180, 180, 255)
	part.Size = Vector3.new(THICKNESS, THICKNESS, dist)
	part.CFrame = CFrame.new(a, b) * CFrame.new(0, 0, -dist / 2)
	part.Parent = workspace
	Debris:AddItem(part, LIFETIME)

	-- bright white core
	local core = Instance.new("Part")
	core.Anchored = true
	core.CanCollide = false
	core.CanTouch = false
	core.CastShadow = false
	core.Material = Enum.Material.Neon
	core.Color = Color3.fromRGB(255, 255, 255)
	core.Size = Vector3.new(THICKNESS * 0.4, THICKNESS * 0.4, dist)
	core.CFrame = part.CFrame
	core.Parent = workspace
	Debris:AddItem(core, LIFETIME)
end

function LightningBolt.Draw(origin, target)
	-- Build a list of jagged points between origin and target
	local points = { origin }

	local direction = (target - origin)
	local length = direction.Magnitude
	local unitDir = direction.Unit

	-- Build a perpendicular vector for random offsets
	local perp1 = unitDir:Cross(Vector3.new(0, 1, 0))
	if perp1.Magnitude < 0.01 then
		perp1 = unitDir:Cross(Vector3.new(1, 0, 0))
	end
	perp1 = perp1.Unit
	local perp2 = unitDir:Cross(perp1).Unit

	for i = 1, SEGMENTS - 1 do
		local t = i / SEGMENTS
		local base = origin + direction * t

		local offset = OFFSET_AMOUNT * (1 - math.abs(t - 0.5) * 2) -- taper at ends
		local ox = (math.random() - 0.5) * 2 * offset
		local oy = (math.random() - 0.5) * 2 * offset

		table.insert(points, base + perp1 * ox + perp2 * oy)
	end

	table.insert(points, target)

	-- Draw segments between each consecutive point
	for i = 1, #points - 1 do
		makePart(points[i], points[i + 1])
	end

	-- Muzzle flash glow at origin
	local flash = Instance.new("Part")
	flash.Anchored = true
	flash.CanCollide = false
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(200, 200, 255)
	flash.Size = Vector3.new(1.5, 1.5, 1.5)
	flash.CFrame = CFrame.new(origin)
	flash.Parent = workspace
	Debris:AddItem(flash, LIFETIME)

	-- Impact glow at target
	local impact = Instance.new("Part")
	impact.Anchored = true
	impact.CanCollide = false
	impact.Shape = Enum.PartType.Ball
	impact.Material = Enum.Material.Neon
	impact.Color = Color3.fromRGB(255, 255, 180)
	impact.Size = Vector3.new(2, 2, 2)
	impact.CFrame = CFrame.new(target)
	impact.Parent = workspace
	Debris:AddItem(impact, LIFETIME * 1.5)
end

return LightningBolt
