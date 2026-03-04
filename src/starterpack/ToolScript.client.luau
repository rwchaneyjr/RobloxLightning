-- Fireball ToolScript (LocalScript)
-- Put this LocalScript INSIDE the Tool
-- StarterPack > LightningShooter (Tool) > ToolScript (LocalScript)

print("Fireball tool running")

local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse

local UIS = game:GetService("UserInputService")

local equipped = false
local cooldown = false

-- fire rate limiter
local FIRE_RATE_SECONDS = 0.10


-------------------------------------------------
-- EQUIP / UNEQUIP
-------------------------------------------------

tool.Equipped:Connect(function()
	equipped = true
	mouse = player:GetMouse()
	print("Tool equipped")
end)

tool.Unequipped:Connect(function()
	equipped = false
	mouse = nil
	print("Tool unequipped")
end)


-------------------------------------------------
-- FIREBALL SPAWN + MOVE
-------------------------------------------------

local function spawnAndMoveFireball(origin, direction)

	local fireball = Instance.new("Part")
	fireball.Name = "Fireball"
	fireball.Shape = Enum.PartType.Ball
	fireball.Size = Vector3.new(2,2,2)
	fireball.Material = Enum.Material.Neon
	fireball.Color = Color3.fromRGB(255,120,0)
	fireball.Anchored = true
	fireball.CanCollide = false
	fireball.CFrame = CFrame.new(origin)
	fireball.Parent = workspace


	-------------------------------------------------
	-- HIT DETECTION
	-------------------------------------------------

	local alreadyHit = false

	fireball.Touched:Connect(function(hit)

		if alreadyHit then return end
		alreadyHit = true

		if player.Character and hit:IsDescendantOf(player.Character) then
			return
		end

		if hit:IsA("BasePart") then

			hit.Color = Color3.fromRGB(255,60,0)
			hit.Material = Enum.Material.Neon

			local fire = Instance.new("Fire")
			fire.Size = 12
			fire.Heat = 10
			fire.Parent = hit

			task.delay(3,function()
				if hit and hit.Parent then
					hit:Destroy()
				end
			end)

		end

		if fireball and fireball.Parent then
			fireball:Destroy()
		end

	end)


	-------------------------------------------------
	-- FIREBALL MOVEMENT
	-------------------------------------------------

	local speed = 140
	local step = 0.03
	local lifeSteps = 120

	for i = 1, lifeSteps do

		if not fireball.Parent then
			return
		end

		fireball.Position += direction * speed * step
		task.wait(step)

	end

	if fireball.Parent then
		fireball:Destroy()
	end

end


-------------------------------------------------
-- SHOOT FUNCTION
-------------------------------------------------

local function shootFireball()

	if cooldown then return end
	cooldown = true

	local handle = tool:FindFirstChild("Handle")

	if not handle then
		warn("No Handle found")
		cooldown = false
		return
	end

	local origin = handle.Position + handle.CFrame.LookVector * 2
	local direction = handle.CFrame.LookVector

	task.spawn(spawnAndMoveFireball, origin, direction)

	task.delay(FIRE_RATE_SECONDS,function()
		cooldown = false
	end)

end


-------------------------------------------------
-- RIGHT CLICK INPUT
-------------------------------------------------

UIS.InputBegan:Connect(function(input,gameProcessed)

	if gameProcessed then return end
	if not equipped then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		shootFireball()
	end

end)