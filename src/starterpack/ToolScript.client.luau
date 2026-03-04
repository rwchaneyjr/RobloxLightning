-- Fireball ToolScript (LocalScript)

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

-- how long the hit object "burns" before disappearing
local BURN_SECONDS = 3


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

	-------------------------------------------------
	-- FLAMES ON THE FIREBALL
	-------------------------------------------------
	local flame = Instance.new("Fire")
	flame.Size = 8
	flame.Heat = 8
	flame.Parent = fireball

	-------------------------------------------------
	-- STRONG FORCE
	-------------------------------------------------
	fireball.AssemblyLinearVelocity = direction * 250
	Debris:AddItem(fireball, 6)

	-------------------------------------------------
	-- HIT DETECTION
	-------------------------------------------------
	local alreadyHit = false

	fireball.Touched:Connect(function(hit)

		if alreadyHit then return end
		alreadyHit = true

		-- don't hit your own character
		if player.Character and hit:IsDescendantOf(player.Character) then
			return
		end

		-------------------------------------------------
		-- SMOKE PUFF AT IMPACT (quick cloud)
		-------------------------------------------------
		local puffPart = Instance.new("Part")
		puffPart.Anchored = true
		puffPart.CanCollide = false
		puffPart.Transparency = 1
		puffPart.Size = Vector3.new(0.2, 0.2, 0.2)
		puffPart.Position = fireball.Position
		puffPart.Parent = workspace

		local puffSmoke = Instance.new("Smoke")
		puffSmoke.Size = 10
		puffSmoke.RiseVelocity = 6
		puffSmoke.Opacity = 0.5
		puffSmoke.Parent = puffPart

		Debris:AddItem(puffPart, 2)

		-------------------------------------------------
		-- FLAMES + SMOKE ON THE OBJECT YOU HIT
		-------------------------------------------------
		if hit:IsA("BasePart") then

			-- make the hit part look like it's burning
			hit.Color = Color3.fromRGB(255, 60, 0)
			hit.Material = Enum.Material.Neon

			-- flames on object
			local hitFire = Instance.new("Fire")
			hitFire.Size = 18
			hitFire.Heat = 15
			hitFire.Parent = hit

			-- smoke on object
			local hitSmoke = Instance.new("Smoke")
			hitSmoke.Size = 14
			hitSmoke.RiseVelocity = 8
			hitSmoke.Opacity = 0.4
			hitSmoke.Parent = hit

			-- (optional) fade effects right before destroy
			task.delay(BURN_SECONDS - 0.3, function()
				if hitFire then hitFire.Enabled = false end
				if hitSmoke then hitSmoke.Enabled = false end
			end)

			-- destroy the hit object
			task.delay(BURN_SECONDS, function()
				if hit and hit.Parent then
					hit:Destroy()
				end
			end)

		end

		-- remove fireball right away on hit
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

	local origin = handle.Position + handle.CFrame.LookVector * 3
	local direction = handle.CFrame.LookVector

	task.spawn(spawnAndMoveFireball, origin, direction)

	task.delay(FIRE_RATE_SECONDS, function()
		cooldown = false
	end)

end


-------------------------------------------------
-- RIGHT CLICK TO FIRE
-------------------------------------------------

UIS.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then return end
	if not equipped then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		shootFireball()
	end

end)