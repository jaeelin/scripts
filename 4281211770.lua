getgenv().Core = {}

local Core = getgenv().Core

Core.Version = "1.0.0"
Core.Loaded = true

Core.Services = {}
Core.Features = {}
Core.Connections = {}
Core.Keybinds = {}
Core.Hooks = {}

local Services = Core.Services

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.UserInputService = game:GetService("UserInputService")
Services.TeleportService = game:GetService("TeleportService")

local LocalPlayer = Services.Players.LocalPlayer

local Camera = workspace.CurrentCamera

local PlayerESPLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jaeelin/Ascendent-ESP/refs/heads/main/PlayerESP.lua"))()
local MacLib = loadstring(game:HttpGet("https://github.com/jaeelin/MacLib/releases/latest/download/MacLib.txt"))()

--[[ FEATURE SETUP ]]--

Core.Features.KillAll = {
	Enabled = false,
	FriendCheck = false
}

Core.Features.SilentAim = {
	Enabled = false,
	Range = 300,
	WallCheck = true,
	Priority = "Camera",
	Hook = nil
}

Core.Features.GunModifier = {
	Enabled = false,
	HookEnabled = true,
	Ammo = 999,
	FireRate = 0.001,
	ReloadTime = 0,
	Spread = 0,
	IsAuto = false,
	OriginalValues = {},
	Hook = nil
}

Core.Features.AntiRecoil = {
	Enabled = false,
	Hook = nil
}

Core.Features.Flight = {
	Enabled = false,
	VerticalSpeed = 50,
	HorizontalSpeed = 50
}

Core.Features.Walkspeed = {
	Enabled = false,
	Speed = 50
}

Core.Features.FOV = {
	Enabled = false,
	Value = 70
}

Core.Features.Gravity = {
	Enabled = false,
	Value = 196.2
}

Core.Features.JumpPower = {
	Enabled = false,
	Power = 50
}

Core.Features.Phase = {
	Enabled = false,
	OriginalCollision = {}
}

Core.Features.LongJump = {
	Enabled = false,
	Height = 50,
	Boost = 50
}

Core.Features.WallClimb = {
	Enabled = false,
	Speed = 50
}

Core.Features.SpinBot = {
	Enabled = false,
	Speed = 50
}

Core.Features.BunnyHop = {
	Enabled = false,
	Speed = 50
}

Core.Features.PlayerESP = {
	Enabled = false,
	Box = false,
	Chams = false,
	ChamsFill = false,
	Tracer = false,
	Skeleton = false,
	Arrow = false,
	Name = false,
	Rainbow = false,
	DefaultColor = Color3.fromRGB(255, 255, 255),
	ChamsColor = Color3.fromRGB(255, 255, 255),
	ChamsOutline = Color3.fromRGB(255, 255, 255),
	MaxDistance = 1000
}

Core.Config = {
	Selected = nil,
	NameInput = ""
}

--[[ FEATURES ]]--

local folder_name = "UDSploit/4281211770"

local window = MacLib:Window({
	Title = "UDSploit",
	Subtitle = "Premium Script – v" .. Core.Version,
	Size = UDim2.fromOffset(800, 600),
	DragStyle = 1,
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightAlt,
	AcrylicBlur = true,
})

MacLib:SetFolder(folder_name)

local main_group = window:TabGroup()

local tabs = {
	Combat = main_group:Tab({Name = "Combat", Image = "rbxassetid://129698054"}),
	Mobility = main_group:Tab({Name = "Mobility", Image = "rbxassetid://7992557358"}),
	Render = main_group:Tab({Name = "Render", Image = "rbxassetid://6523858394"}),
	Settings = main_group:Tab({Name = "Settings", Image = "rbxassetid://132848201849699"}),
}

local sections = {
	combat_left = tabs.Combat:Section({ Side = "Left" }),
	combat_left_bottom = tabs.Combat:Section({ Side = "Left" }),
	combat_right = tabs.Combat:Section({ Side = "Right" }),
	combat_right_bottom = tabs.Combat:Section({ Side = "Right" }),
	mobility_left = tabs.Mobility:Section({ Side = "Left" }),
	mobility_right = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right2 = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right3 = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right4 = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right5 = tabs.Mobility:Section({ Side = "Right" }),
	render_left = tabs.Render:Section({ Side = "Left" }),
	settings_left = tabs.Settings:Section({ Side = "Left" })
}

tabs.Combat:Select()

--[[ UTILITIES ]]--

function Core:GetCharacter(player)
	player = player or LocalPlayer

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not root or not humanoid then return end

	return character, humanoid, root
end

function Core:GetClosest(values)
	local closest_target = nil
	local shortest = math.huge

	local character = LocalPlayer.Character
	if not character then return end

	local humanoid_root_part = character.FindFirstChild(character, "HumanoidRootPart")
	if not humanoid_root_part then return end

	for _, target in next, Services.Players.GetPlayers(Services.Players) do
		if target == LocalPlayer then continue end

		local target_character = target.Character
		if not target_character then continue end

		local target_humanoid_root_part = target_character.FindFirstChild(target_character, "HumanoidRootPart")
		if not target_humanoid_root_part then continue end

		local target_humanoid = target_character.FindFirstChild(target_character, "Humanoid")
		if not target_humanoid then continue end

		if target_humanoid.Health <= 0 then continue end

		local world_distance = (humanoid_root_part.Position - target_humanoid_root_part.Position).Magnitude
		if world_distance > values.range then
			continue
		end

		if values.wall_check then
			local raycast_parameters = RaycastParams.new()
			raycast_parameters.FilterDescendantsInstances = {character}
			raycast_parameters.FilterType = Enum.RaycastFilterType.Exclude

			local direction = target_humanoid_root_part.Position - humanoid_root_part.Position
			local raycast_result = workspace.Raycast(workspace, humanoid_root_part.Position, direction, raycast_parameters)

			if raycast_result and raycast_result.Instance and not raycast_result.Instance.IsDescendantOf(raycast_result.Instance, target_character) then
				continue
			end
		end

		local distance
		if values.priority == "Camera" then
			local screen_position, on_screen = Camera.WorldToViewportPoint(Camera, target_humanoid_root_part.Position)
			if not on_screen then
				continue
			end

			distance = (Vector2.new(screen_position.X, screen_position.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
		else
			distance = world_distance
		end

		if distance < shortest then
			shortest = distance
			closest_target = target_character
		end
	end

	return closest_target
end

function Core:GetParts(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
	if not humanoid_root_part then return end

	return character, humanoid, humanoid_root_part
end

function Core:Error(description, duration)
	window:Notify({
		Title = "Error",
		Description = description,
		Lifetime = duration
	})

	setclipboard("https://discord.gg/uxd")
end

function Core:RefreshConfigs(dropdown)
	dropdown:ClearOptions()
	dropdown:InsertOptions(MacLib:RefreshConfigList() or {})
end

--[[ MODULES ]]--

local CameraHandler = require(Core.Services.ReplicatedStorage.ModuleScripts.GunModules.GunFramework.CameraHandler)

--[[ MOBILITY ]]--

KillAll = sections.combat_left:Toggle({
	Name = "Kill All",
	Default = Core.Features.KillAll.Enabled,
	Callback = function(state)
		Core.Features.KillAll.Enabled = state

		if state then
			Core.Connections.KillAll = Services.RunService.PreRender:Connect(function(delta)
				local character = LocalPlayer.Character
				if not character then return end
				
				local gun = character:FindFirstChildOfClass("Tool")
				if not gun then return end
				
				local remotes = gun:FindFirstChild("Remotes")
				if not remotes then return end
				
				local configuration = gun:FindFirstChild("Configuration")
				if not configuration then return end
				
				local check_shot = remotes:FindFirstChild("CheckShot")
				if not check_shot then return end
				
				for _, target in Services.Players:GetPlayers() do
					if target == LocalPlayer then continue end
					
					if Core.Features.KillAll.FriendCheck and LocalPlayer:IsFriendsWith(target.UserId) then continue end

					local target_character = target.Character
					if not target_character then continue end
					
					local hitbox = target_character:FindFirstChild("Crit")
					if not hitbox then continue end
					
					local origin = Camera.CFrame.Position
					local target_position = hitbox.Position
					
					local direction  = (target_position - origin).Unit
					local new_position = CFrame.new(origin, origin + direction * 10)
					
					character:PivotTo(target_character:GetPivot() + Vector3.new(0, 15, 0))
					
					check_shot:FireServer(
						Core.Features.GunModifier.OriginalValues.Ammo or configuration.Ammo.Value or 30,
						Core.Features.GunModifier.OriginalValues.Spread or configuration.spread.Value or 0,
						Core.Features.GunModifier.OriginalValues.Ammo or configuration.Ammo.Value or 30,
						Core.Features.GunModifier.OriginalValues.ReloadTime or configuration.reloadTime.Value or 2,
						new_position,
						hitbox.Position,
						hitbox,
						0,
						tick() + math.random()
					)
				end
			end)
		else
			if Core.Connections.KillAll then
				Core.Connections.KillAll:Disconnect()
				Core.Connections.KillAll = nil
			end
		end
	end,
}, "KillAll")

sections.combat_left:Toggle({
	Name = "Friend Check",
	Default = Core.Features.KillAll.FriendCheck,
	Callback = function(value)
		Core.Features.KillAll.FriendCheck = value
	end
}, "KillAllFriendCheck")

Core.Keybinds.KillAll = sections.combat_left:Keybind({
	Name = "Kill All Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.KillAll.Enabled = not Core.Features.KillAll.Enabled
			KillAll:UpdateState(Core.Features.KillAll.Enabled)
		end
	end,
}, "KillAllKeybind")

GunModifier = sections.combat_right:Toggle({
	Name = "Gun Modifier",
	Default = Core.Features.GunModifier.Enabled,
	Callback = function(state)
		if not hookmetamethod then
			Core.Error("Your executor does NOT support hookmetamethod.")
			return
		end
		
		Core.Features.GunModifier.Enabled = state

		if state then
			Core.Connections.GunModifier = Services.RunService.PreRender:Connect(function()
				local character = LocalPlayer.Character
				if not character then return end

				local gun = character:FindFirstChildOfClass("Tool")
				if not gun then return end

				local configuration = gun:FindFirstChild("Configuration")
				if not configuration then return end
				
				if gun ~= Core.Features.GunModifier.OriginalValues.CurrentGun then
					Core.Features.GunModifier.OriginalValues = {}
					Core.Features.GunModifier.OriginalValues.CurrentGun = gun
				end
				
				if not Core.Features.GunModifier.OriginalValues.Saved then
					for key, value in next, Core.Features.GunModifier do
						for _, config_value in next, configuration:GetChildren() do
							if string.lower(config_value.Name) == string.lower(key) then
								Core.Features.GunModifier.OriginalValues[key] = config_value.Value
							end
						end
					end
					
					Core.Features.GunModifier.OriginalValues.Saved = true
				end
				
				for key, value in next, Core.Features.GunModifier do
					for _, config_value in next, configuration:GetChildren() do
						if string.lower(config_value.Name) == string.lower(key) then
							config_value.Value = value
						end
					end
				end
			end)
		else
			if Core.Connections.GunModifier then
				Core.Connections.GunModifier:Disconnect()
				Core.Connections.GunModifier = nil
			end
			
			local character = LocalPlayer.Character
			if not character then return end

			local gun = character:FindFirstChildOfClass("Tool")
			if not gun then return end

			local configuration = gun:FindFirstChild("Configuration")
			if not configuration then return end
			
			for key, value in next, Core.Features.GunModifier.OriginalValues do
				if key ~= "Saved" and key ~= "CurrentGun" then
					for _, config_value in next, configuration:GetChildren() do
						if string.lower(config_value.Name) == string.lower(key) then
							config_value.Value = value
						end
					end
				end
			end
		end
	end,
}, "GunModifier")

sections.combat_right:Slider({
	Name = "Ammo",
	Default = Core.Features.GunModifier.Ammo,
	Minimum = 0,
	Maximum = 1000,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.GunModifier.Ammo = value
	end,
}, "GunModifierAmmo")

sections.combat_right:Slider({
	Name = "Fire Rate",
	Default = Core.Features.GunModifier.FireRate,
	Minimum = 0,
	Maximum = 10,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.GunModifier.FireRate = value
	end,
}, "GunModifierFireRate")

sections.combat_right:Slider({
	Name = "Reload Time",
	Default = Core.Features.GunModifier.ReloadTime,
	Minimum = 0,
	Maximum = 10,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.GunModifier.ReloadTime = value
	end,
}, "GunModifierReloadTime")

sections.combat_right:Slider({
	Name = "Spread",
	Default = Core.Features.GunModifier.Spread,
	Minimum = 0,
	Maximum = 10,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.GunModifier.Spread = value
	end,
}, "GunModifierSpread")

sections.combat_right:Toggle({
	Name = "Automatic",
	Default = Core.Features.GunModifier.IsAuto,
	Callback = function(value)
		Core.Features.GunModifier.IsAuto = value
	end
}, "GunModifierIsAuto")

Core.Keybinds.GunModifier = sections.combat_right:Keybind({
	Name = "Gun Modifier Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.GunModifier.Enabled = not Core.Features.GunModifier.Enabled
			GunModifier:UpdateState(Core.Features.GunModifier.Enabled)
		end
	end,
}, "GunModifierKeybind")

SilentAim = sections.combat_left_bottom:Toggle({
	Name = "Silent Aim",
	Default = Core.Features.SilentAim.Enabled,
	Callback = function(state)
		if not hookmetamethod then
			Core.Error("Your executor does NOT support hookmetamethod.")
			return
		end
		
		Core.Features.SilentAim.Enabled = state
	end
}, "SilentAim")

if hookmetamethod then
	local gun_modifier_hook; gun_modifier_hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local args = {...}
		local method = getnamecallmethod():lower()
		
		if not Core.Features.GunModifier.HookEnabled then
			return gun_modifier_hook(self, ...)
		end

		if not checkcaller() and method == "fireserver" and self.Name == "CheckShot" then
			if  Core.Features.GunModifier.OriginalValues then
				if  Core.Features.GunModifier.OriginalValues.Ammo then
					args[1] = Core.Features.GunModifier.OriginalValues.Ammo
				end

				if Core.Features.GunModifier.OriginalValues.Spread then
					args[2] = Core.Features.GunModifier.OriginalValues.Spread
				end

				if Core.Features.GunModifier.OriginalValues.Ammo then
					args[3] = Core.Features.GunModifier.OriginalValues.Ammo
				end

				if Core.Features.GunModifier.OriginalValues.ReloadTime then
					args[4] = Core.Features.GunModifier.OriginalValues.ReloadTime
				end
			end

			return gun_modifier_hook(self, unpack(args))
		end

		return gun_modifier_hook(self, ...)
	end))

	Core.Features.GunModifier.Hook = gun_modifier_hook
	
	local silent_aim_hook; silent_aim_hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local args = {...}
		local method = getnamecallmethod():lower()

		if not Core.Features.SilentAim.Enabled then
			return silent_aim_hook(self, ...)
		end

		if not checkcaller() and method == "fireserver" and self.Name == "CheckShot" then
			local closest = Core:GetClosest({
				range = Core.Features.SilentAim.Range,
				wall_check = Core.Features.SilentAim.WallCheck,
				priority = Core.Features.SilentAim.Priority
			})

			if closest then
				local crit = closest.FindFirstChild(closest, "Crit")
				if crit then
					args[5] = CFrame.lookAt(Camera.CFrame.Position, crit.Position)
					args[6] = crit.Position
					args[7] = crit
				end
			end

			return silent_aim_hook(self, unpack(args))
		end

		return silent_aim_hook(self, ...)
	end))
	
	Core.Features.SilentAim.Hook = silent_aim_hook
end

sections.combat_left_bottom:Slider({
	Name = "Silent Aim Range",
	Default = Core.Features.SilentAim.Range,
	Minimum = 1,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.SilentAim.Range = value
	end
}, "SilentAimRange")

sections.combat_left_bottom:Toggle({
	Name = "Silent Aim Wall Check",
	Default = Core.Features.SilentAim.WallCheck,
	Callback = function(value)
		Core.Features.SilentAim.WallCheck = value
	end
}, "SilentAimWallCheck")

sections.combat_left_bottom:Dropdown({
	Name = "Silent Aim Priority",
	Options = {"Camera", "Character"},
	Default = 1,
	Callback = function(value)
		Core.Features.SilentAim.Priority = value
	end
}, "SilentAimPriority")

Core.Keybinds.SilentAim = sections.combat_left_bottom:Keybind({
	Name = "Silent Aim Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.SilentAim.Enabled = not Core.Features.SilentAim.Enabled
			SilentAim:UpdateState(Core.Features.SilentAim.Enabled)
		end
	end
}, "SilentAimKeybind")

AntiRecoil = sections.combat_right_bottom:Toggle({
	Name = "Anti Recoil",
	Default = Core.Features.AntiRecoil.Enabled,
	Callback = function(state)
		if not hookfunction then
			Core.Error("Your executor does NOT support hookfunction.")
			return
		end

		Core.Features.AntiRecoil.Enabled = state
	end
}, "AntiRecoil")

if hookfunction then
	local old_accelerate; old_accelerate = hookfunction(CameraHandler.accelerate, function(...)
		if not Core.Features.AntiRecoil.Enabled then
			return old_accelerate(...)
		end
		
		return
	end)
	
	Core.Features.AntiRecoil.Hook = old_accelerate
end

Core.Keybinds.AntiRecoil = sections.combat_right_bottom:Keybind({
	Name = "Anti Recoil Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.AntiRecoil.Enabled = not Core.Features.AntiRecoil.Enabled
			AntiRecoil:UpdateState(Core.Features.AntiRecoil.Enabled)
		end
	end
}, "AntiRecoilKeybind")

Flight = sections.mobility_left:Toggle({
	Name = "Flight",
	Default = Core.Features.Flight.Enabled,
	Callback = function(state)
		Core.Features.Flight.Enabled = state

		if state then
			Core.Connections.Flight = Services.RunService.PreRender:Connect(function(delta)
				local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not humanoid_root_part then return end

				local move_direction = Vector3.zero

				if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(0, 0, 1)
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(0, 0, -1)
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(-1, 0, 0)
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(1, 0, 0)
				end

				local vertical = 0
				if (Services.UserInputService:IsKeyDown(Enum.KeyCode.E) or Services.UserInputService:IsKeyDown(Enum.KeyCode.Space))
					and not Services.UserInputService:GetFocusedTextBox() then
					vertical = Core.Features.Flight.VerticalSpeed
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.Q) and not Services.UserInputService:GetFocusedTextBox() then
					vertical = -Core.Features.Flight.VerticalSpeed
				end

				if move_direction.Magnitude > 0 then
					move_direction = move_direction.Unit * Core.Features.Flight.HorizontalSpeed
				end

				local forward = Camera.CFrame.LookVector
				local right = Camera.CFrame.RightVector

				local final_move = (forward * move_direction.Z) + (right * move_direction.X) + (Vector3.yAxis * vertical)

				humanoid_root_part.CFrame += final_move * delta

				local velocity = humanoid_root_part.Velocity
				humanoid_root_part.Velocity = Vector3.new(velocity.X, 0.5, velocity.Z)
			end)
		else
			if Core.Connections.Flight then
				Core.Connections.Flight:Disconnect()
				Core.Connections.Flight = nil
			end
		end
	end,
}, "Flight")

sections.mobility_left:Slider({
	Name = "Horizontal Speed",
	Default = Core.Features.Flight.HorizontalSpeed,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value) Core.Features.Flight.HorizontalSpeed = value end,
}, "FlightHorizontalSpeed")

sections.mobility_left:Slider({
	Name = "Vertical Speed",
	Default = Core.Features.Flight.VerticalSpeed,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value) Core.Features.Flight.VerticalSpeed = value end,
}, "FlightVerticalSpeed")

Core.Keybinds.Flight = sections.mobility_left:Keybind({
	Name = "Flight Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Flight.Enabled = not Core.Features.Flight.Enabled
			Flight:UpdateState(Core.Features.Flight.Enabled)
		end
	end,
}, "FlightKeybind")

Walkspeed = sections.mobility_left:Toggle({
	Name = "Walkspeed",
	Default = Core.Features.Walkspeed.Enabled,
	Callback = function(enabled)
		Core.Features.Walkspeed.Enabled = enabled

		if enabled then
			Core.Connections.Walkspeed = Services.RunService.PreRender:Connect(function()
				local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not humanoid_root_part then return end

				humanoid.WalkSpeed = Core.Features.Walkspeed.Speed
			end)
		else
			if Core.Connections.Walkspeed then
				Core.Connections.Walkspeed:Disconnect()
				Core.Connections.Walkspeed = nil
			end

			local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
			if not character or not humanoid or not humanoid_root_part then return end

			humanoid.WalkSpeed = 16
		end
	end,
}, "Walkspeed")

sections.mobility_left:Slider({
	Name = "Speed",
	Default = Core.Features.Walkspeed.Speed,
	Minimum = 0,
	Maximum = 250,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.Walkspeed.Speed = value
	end,
}, "WalkspeedSlider")

Core.Keybinds.Walkspeed = sections.mobility_left:Keybind({
	Name = "Walkspeed Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Walkspeed.Enabled = not Core.Features.Walkspeed.Enabled
			Walkspeed:UpdateState(Core.Features.Walkspeed.Enabled)
		end
	end,
}, "WalkspeedKeybind")

JumpPower = sections.mobility_left:Toggle({
	Name = "Jump Power",
	Default = Core.Features.JumpPower.Enabled,
	Callback = function(enabled)
		Core.Features.JumpPower.Enabled = enabled

		if enabled then
			Core.Connections.JumpPower = Services.RunService.PreRender:Connect(function()
				local character, humanoid = Core:GetParts(LocalPlayer)
				if not humanoid then return end

				if humanoid.UseJumpPower then
					humanoid.JumpPower = Core.Features.JumpPower.Power
				else
					humanoid.JumpHeight = Core.Features.JumpPower.Power
				end
			end)
		else
			if Core.Connections.JumpPower then
				Core.Connections.JumpPower:Disconnect()
				Core.Connections.JumpPower = nil
			end

			local character, humanoid = Core:GetParts(LocalPlayer)
			if not humanoid then return end
			
			if humanoid.UseJumpPower then
				humanoid.JumpPower = 50
			else
				humanoid.JumpHeight = 7.2
			end
		end
	end,
}, "JumpPower")

sections.mobility_left:Slider({
	Name = "Power",
	Default = Core.Features.JumpPower.Power,
	Minimum = 0,
	Maximum = 300,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.JumpPower.Power = value
	end,
}, "JumpPowerSlider")

Core.Keybinds.JumpPower = sections.mobility_left:Keybind({
	Name = "Jump Power Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.JumpPower.Enabled = not Core.Features.JumpPower.Enabled
			JumpPower:UpdateState(Core.Features.JumpPower.Enabled)
		end
	end,
}, "JumpPowerKeybind")

FOV = sections.mobility_left:Toggle({
	Name = "Field of View",
	Default = Core.Features.FOV.Enabled,
	Callback = function(enabled)
		Core.Features.FOV.Enabled = enabled

		if enabled then
			Core.Connections.FOV = Services.RunService.PreRender:Connect(function()
				Camera.FieldOfView = Core.Features.FOV.Value
			end)
		else
			if Core.Connections.FOV then
				Core.Connections.FOV:Disconnect()
				Core.Connections.FOV = nil
			end

			Camera.FieldOfView = 70
		end
	end,
}, "FOV")

sections.mobility_left:Slider({
	Name = "FOV",
	Default = Core.Features.FOV.Value,
	Minimum = 0,
	Maximum = 120,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.FOV.Value = value
	end,
}, "FOVSlider")

Core.Keybinds.FOV = sections.mobility_left:Keybind({
	Name = "FOV Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.FOV.Enabled = not Core.Features.FOV.Enabled
			FOV:UpdateState(Core.Features.FOV.Enabled)
		end
	end,
}, "FOVKeybind")

Gravity = sections.mobility_left:Toggle({
	Name = "Gravity",
	Default = Core.Features.Gravity.Enabled,
	Callback = function(enabled)
		Core.Features.Gravity.Enabled = enabled

		if enabled then
			Core.Connections.Gravity = Services.RunService.PreRender:Connect(function()
				workspace.Gravity = Core.Features.Gravity.Value
			end)
		else
			if Core.Connections.Gravity then
				Core.Connections.Gravity:Disconnect()
				Core.Connections.Gravity = nil
			end

			workspace.Gravity = 196.2
		end
	end,
}, "Gravity")

sections.mobility_left:Slider({
	Name = "Gravity",
	Default = Core.Features.Gravity.Value,
	Minimum = 0,
	Maximum = 300,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.Gravity.Value = value
	end,
}, "GravitySlider")

Core.Keybinds.Gravity = sections.mobility_left:Keybind({
	Name = "Gravity Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Gravity.Enabled = not Core.Features.Gravity.Enabled
			Gravity:UpdateState(Core.Features.Gravity.Enabled)
		end
	end,
}, "GravityKeybind")

Phase = sections.mobility_right:Toggle({
	Name = "Phase",
	Default = Core.Features.Phase.Enabled,
	Callback = function(enabled)
		Core.Features.Phase.Enabled = enabled

		if enabled then
			Core.Features.Phase.OriginalCollision = {}

			Core.Connections.Phase = Services.RunService.PreRender:Connect(function()
				local character = LocalPlayer.Character
				if not character then return end
				
				for _, part in next, character:GetDescendants() do
					if part:IsA("BasePart") and Core.Features.Phase.OriginalCollision[part] == nil then
						Core.Features.Phase.OriginalCollision[part] = part.CanCollide
					end
				end

				for part in next, Core.Features.Phase.OriginalCollision do
					if part and part.Parent then
						part.CanCollide = false
					end
				end
			end)
		else
			for part, canCollide in next, Core.Features.Phase.OriginalCollision do
				if part and part.Parent then
					part.CanCollide = canCollide
				end
			end

			Core.Features.Phase.OriginalCollision = {}

			if Core.Connections.Phase then
				Core.Connections.Phase:Disconnect()
				Core.Connections.Phase = nil
			end
		end
	end,
}, "Phase")

Core.Keybinds.Phase = sections.mobility_right:Keybind({
	Name = "Phase Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Phase.Enabled = not Core.Features.Phase.Enabled
			Phase:UpdateState(Core.Features.Phase.Enabled)
		end
	end,
}, "PhaseKeybind")

LongJump = sections.mobility_right2:Toggle({
	Name = "Long Jump",
	Default = Core.Features.LongJump.Enabled,
	Callback = function(enabled)
		Core.Features.LongJump.Enabled = enabled

		if enabled then
			local can_boost = true

			Core.Connections.LongJump = Services.RunService.PreRender:Connect(function()
				local character, humanoid, root = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not root then return end

				if humanoid:GetState() == Enum.HumanoidStateType.Jumping and can_boost then
					local direction = root.CFrame.LookVector * Core.Features.LongJump.Boost
					root.Velocity += Vector3.new(direction.X, Core.Features.LongJump.Height, direction.Z)
					can_boost = false
				elseif humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
					can_boost = true
				end
			end)
		else
			if Core.Connections.LongJump then
				Core.Connections.LongJump:Disconnect()
				Core.Connections.LongJump = nil
			end
		end
	end,
}, "LongJump")

sections.mobility_right2:Slider({
	Name = "Height",
	Default = Core.Features.LongJump.Height,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.LongJump.Height = value
	end,
}, "LongJumpHeight")

sections.mobility_right2:Slider({
	Name = "Boost",
	Default = Core.Features.LongJump.Boost,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.LongJump.Boost = value
	end,
}, "LongJumpBoost")

Core.Keybinds.LongJump = sections.mobility_right2:Keybind({
	Name = "Long Jump Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.LongJump.Enabled = not Core.Features.LongJump.Enabled
			LongJump:UpdateState(Core.Features.LongJump.Enabled)
		end
	end,
}, "LongJumpKeybind")

WallClimb = sections.mobility_right3:Toggle({
	Name = "Wall Climb",
	Default = Core.Features.WallClimb.Enabled,
	Callback = function(enabled)
		Core.Features.WallClimb.Enabled = enabled

		if enabled then
			Core.Connections.WallClimb = Services.RunService.PreRender:Connect(function()
				local character, humanoid, root = Core:GetParts(LocalPlayer)
				if not character or not root then return end

				local ray_origin = root.Position
				local ray_direction = root.CFrame.LookVector * 2

				local params = RaycastParams.new()
				params.FilterDescendantsInstances = { character }
				params.FilterType = Enum.RaycastFilterType.Exclude

				local hit = workspace:Raycast(ray_origin, ray_direction, params)
				if not hit then return end

				local upperOrigin = ray_origin + Vector3.new(0, 2.5, 0)
				local upperHit = workspace:Raycast(upperOrigin, ray_direction, params)

				if upperHit then
					root.Velocity = Vector3.new(
						root.Velocity.X,
						Core.Features.WallClimb.Speed,
						root.Velocity.Z
					)
				else
					root.CFrame += root.CFrame.LookVector * 1.2
					root.Velocity = Vector3.zero
				end
			end)
		else
			if Core.Connections.WallClimb then
				Core.Connections.WallClimb:Disconnect()
				Core.Connections.WallClimb = nil
			end
		end
	end,
}, "WallClimb")

sections.mobility_right3:Slider({
	Name = "Speed",
	Default = Core.Features.WallClimb.Speed,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.WallClimb.Speed = value
	end,
}, "WallClimbSpeed")

Core.Keybinds.WallClimb = sections.mobility_right3:Keybind({
	Name = "Wall Climb Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.WallClimb.Enabled = not Core.Features.WallClimb.Enabled
			WallClimb:UpdateState(Core.Features.WallClimb.Enabled)
		end
	end,
}, "WallClimbKeybind")

SpinBot = sections.mobility_right4:Toggle({
	Name = "Spin Bot",
	Default = Core.Features.SpinBot.Enabled,
	Callback = function(enabled)
		Core.Features.SpinBot.Enabled = enabled

		if enabled then
			Core.Connections.SpinBot = Services.RunService.PreRender:Connect(function(delta)
				local character, humanoid, root = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not root then return end

				humanoid.AutoRotate = false

				local rotation = math.rad(Core.Features.SpinBot.Speed) * delta * 60
				root.CFrame *= CFrame.Angles(0, rotation, 0)
			end)
		else
			if Core.Connections.SpinBot then
				Core.Connections.SpinBot:Disconnect()
				Core.Connections.SpinBot = nil
			end

			local character, humanoid = Core:GetParts(LocalPlayer)
			if humanoid then
				humanoid.AutoRotate = true
			end
		end
	end,
}, "SpinBot")

sections.mobility_right4:Slider({
	Name = "Speed",
	Default = Core.Features.SpinBot.Speed,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.SpinBot.Speed = value
	end,
}, "SpinBotSpeed")

Core.Keybinds.SpinBot = sections.mobility_right4:Keybind({
	Name = "Spin Bot Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.SpinBot.Enabled = not Core.Features.SpinBot.Enabled
			SpinBot:UpdateState(Core.Features.SpinBot.Enabled)
		end
	end,
}, "SpinBotKeybind")

BunnyHop = sections.mobility_right5:Toggle({
	Name = "Bunny Hop",
	Default = Core.Features.BunnyHop.Enabled,
	Callback = function(enabled)
		Core.Features.BunnyHop.Enabled = enabled

		if enabled then
			Core.Connections.BunnyHop = Services.RunService.PreRender:Connect(function(delta)
				local character = LocalPlayer.Character
				if not character then return end

				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid then return end

				if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		else
			if Core.Connections.BunnyHop then
				Core.Connections.BunnyHop:Disconnect()
				Core.Connections.BunnyHop = nil
			end
		end
	end,
}, "BunnyHop")

Core.Keybinds.BunnyHop = sections.mobility_right5:Keybind({
	Name = "Bunny Hop Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.BunnyHop.Enabled = not Core.Features.BunnyHop.Enabled
			BunnyHop:UpdateState(Core.Features.BunnyHop.Enabled)
		end
	end,
}, "BunnyHopKeybind")

--[[ RENDER ]]--

local EspInstance = nil
PlayerESP = sections.render_left:Toggle({
	Name = "Player ESP",
	Default = false,
	Callback = function(enabled)
		Core.Features.PlayerESP.Enabled = enabled

		if enabled then
			EspInstance = PlayerESPLib.new({
				Box = Core.Features.PlayerESP.Box,
				Chams = Core.Features.PlayerESP.Chams,
				ChamsFill = Core.Features.PlayerESP.ChamsFill,
				Tracer = Core.Features.PlayerESP.Tracer,
				Arrows = Core.Features.PlayerESP.Arrows,
				Skeleton = Core.Features.PlayerESP.Skeleton,
				Name = Core.Features.PlayerESP.Name,
				Rainbow = Core.Features.PlayerESP.Rainbow,
				DefaultColor = Core.Features.PlayerESP.DefaultColor,
				ChamsColor = Core.Features.PlayerESP.ChamsColor,
				ChamsOutline = Core.Features.PlayerESP.ChamsOutline,
				MaxDistance = Core.Features.PlayerESP.MaxDistance
			})
			
			EspInstance:Enable()
		else
			if EspInstance then
				EspInstance:Disable()
				EspInstance = nil
			end
		end
	end,
}, "PlayerESP")

sections.render_left:Toggle({
	Name = "Box",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Box = state
		
		if EspInstance then
			EspInstance.Box = state
		end
	end,
}, "PlayerESPBox")

sections.render_left:Toggle({
	Name = "Chams",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Chams = state

		if EspInstance then
			EspInstance.Chams = state
		end
	end,
}, "PlayerESPChams")

sections.render_left:Toggle({
	Name = "Chams Fill",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.ChamsFill = state

		if EspInstance then
			EspInstance.ChamsFill = state
		end
	end,
}, "PlayerESPChamsFill")

sections.render_left:Toggle({
	Name = "Tracer",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Tracer = state
		
		if EspInstance then
			EspInstance.Tracer = state
		end
	end,
}, "PlayerESPTracer")

sections.render_left:Toggle({
	Name = "Skeleton",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Skeleton = state
		
		if EspInstance then
			EspInstance.Skeleton = state
		end
	end,
}, "PlayerESPSkeleton")

sections.render_left:Toggle({
	Name = "Arrows",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Arrows = state
		
		if EspInstance then
			EspInstance.Arrows = state
		end
	end,
}, "PlayerESPArrows")

sections.render_left:Toggle({
	Name = "Name",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Name = state
		
		if EspInstance then
			EspInstance.Name = state
		end
	end,
}, "PlayerESPName")

sections.render_left:Toggle({
	Name = "Rainbow",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Rainbow = state
		
		if EspInstance then
			EspInstance.Rainbow = state
		end
	end,
}, "PlayerESPRainbow")

sections.render_left:Colorpicker({
	Name = "Player ESP Color",
	Default = Core.Features.PlayerESP.DefaultColor,
	Callback = function(color)
		Core.Features.PlayerESP.DefaultColor = color

		if EspInstance then
			EspInstance.DefaultColor = color

			for _, target_player in next, Services.Players:GetPlayers() do
				if target_player ~= LocalPlayer then
					EspInstance:SetColor(target_player, color)
				end
			end
		end
	end,
}, "PlayerESPColor")

sections.render_left:Colorpicker({
	Name = "Chams Color",
	Default = Core.Features.PlayerESP.ChamsColor,
	Callback = function(color)
		Core.Features.PlayerESP.ChamsColor = color

		if EspInstance then
			EspInstance.ChamsColor = color
		end
	end,
}, "ChamsColorColor")

sections.render_left:Colorpicker({
	Name = "Chams Outline Color",
	Default = Core.Features.PlayerESP.ChamsOutline,
	Callback = function(color)
		Core.Features.PlayerESP.ChamsOutline = color

		if EspInstance then
			EspInstance.ChamsOutline = color
		end
	end,
}, "ChamsOutlineColor")

Core.Keybinds.PlayerESP = sections.render_left:Keybind({
	Name = "Player ESP Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.PlayerESP.Enabled = not Core.Features.PlayerESP.Enabled
			PlayerESP:UpdateState(Core.Features.PlayerESP.Enabled)
		end
	end,
}, "PlayerESPKeybind")

--[[ CONFIG ]]--

ConfigDropdown = sections.settings_left:Dropdown({
	Name = "Configs",
	Callback = function(selected)
		Core.Config.Selected = selected
	end,
}, "ConfigDropdown")

Core:RefreshConfigs(ConfigDropdown)

sections.settings_left:Input({
	Name = "Config Name",
	Placeholder = "Enter name",
	Callback = function(text)
		Core.Config.NameInput = text
	end,
}, "ConfigNameInput")

sections.settings_left:Button({
	Name = "Save Config",
	Callback = function()
		if Core.Config.NameInput == "" then
			window:Notify({
				Title = "Config",
				Description = "Config name cannot be empty",
				Lifetime = 3
			})
			return
		end

		MacLib:SaveConfig(Core.Config.NameInput)
		Core:RefreshConfigs(ConfigDropdown)

		window:Notify({
			Title = "Config",
			Description = "Saved config: " .. Core.Config.NameInput,
			Lifetime = 3
		})
	end
})

sections.settings_left:Button({
	Name = "Load Config",
	Callback = function()
		if not Core.Config.Selected then return end

		MacLib:LoadConfig(Core.Config.Selected)
		Core:RefreshConfigs(ConfigDropdown)

		window:Notify({
			Title = "Config",
			Description = "Loaded config: " .. Core.Config.Selected,
			Lifetime = 3
		})
	end
})

sections.settings_left:Button({
	Name = "Delete Config",
	Callback = function()
		if not Core.Config.Selected then return end

		local path = folder_name .. "/settings/" .. Core.Config.Selected .. ".json"
		if isfile(path) then
			delfile(path)
		end

		Core.Config.Selected = nil
		Core:RefreshConfigs(ConfigDropdown)

		window:Notify({
			Title = "Config",
			Description = "Config deleted",
			Lifetime = 3
		})
	end
})

window:Dialog({
	Title = "Discord Server",
	Description = "Would you like to join our discord server? We offer premium scripts!",
	Buttons = {
		{
			Name = "Join",
			Callback = function()
				setclipboard("https://discord.com/invite/uxd")
			end,
		},
		{
			Name = "Decline"
		}
	}
})

window.onUnloaded(function()
	if EspInstance then
		EspInstance:Disable()
		EspInstance = nil
	end
	
	Core.Features.GunModifier.HookEnabled = false
	Core.Features.SilentAim.Enabled = false
	Core.Features.AntiRecoil.Enabled = false
	
	for _, keybind in next, Core.Keybinds do
		if keybind and keybind.Unbind then
			keybind:Unbind()
		end
	end

	Core.Keybinds = {}

	for _, connection in next, Core.Connections do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	
	Core.Connections = {}
end)
