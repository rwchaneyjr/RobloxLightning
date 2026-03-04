-- Fireball ToolScript (LocalScript)
-- Put this LocalScript INSIDE the Tool
-- StarterPack > LightningShooter (Tool) > ToolScript (LocalScript)

print("Fireball tool running")

local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse

local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local equipped = false
local cooldown = false

-- fire rate limiter
local FIRE_RATE_SECONDS = 0.10


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
-- FIREBALL
-------------------------------------------------

local function spawnAndMoveFireball(origin, direction)

	local fireball = Instance.new("Part")
	fireball.Name = "Fireball"
	fireball.Shape = Enum.PartType.Ball
	fireball.Size = Vector3.new(2,2,2)
	fireball.Material = Enum.Material.Neon
	fireball.Color = Color3.fromRGB(255,120,0)
	fireball.Anchored = false
	fireball.CanCollide = false
	fireball.CFrame = CFrame.new(origin)
	fireball.Parent = workspace

	-- move forward
	fireball.AssemblyLinearVelocity = direction * 120

	-- remove fireball if it misses
	Debris:AddItem(fireball,5)

	-------------------------------------------------
	-- HIT DETECTION
	-------------------------------------------------

	local alreadyHit = false

	fireball.Touched:Connect(function(hit)

		if alreadyHit then return end
		alreadyHit = true

		-- ignore player
		if player.Character and hit:IsDescendantOf(player.Character) then
			return
		end

		if hit:IsA("BasePart") then

			print("Fireball hit:", hit.Name)

			-- change color
			hit.Color = Color3.fromRGB(255,60,0)
			hit.Material = Enum.Material.Neon

			-- add fire
			local fire = Instance.new("Fire")
			fire.Size = 12
			fire.Heat = 10
			fire.Parent = hit

			-- destroy object after 3 seconds
			task.delay(3,function()
				if hit and hit.Parent then
					hit:Destroy()
				end
			end)

		end

		fireball:Destroy()

	end)

end


-------------------------------------------------
-- SHOOT FIREBALL
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
-- RIGHT CLICK TO FIRE
-------------------------------------------------

UIS.InputBegan:Connect(function(input,gameProcessed)

	if gameProcessed then return end
	if not equipped then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		shootFireball()
	end

end)