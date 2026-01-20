setclipboard("https://discord.gg/uxd")

local udsploit_version = "1.0.0"

local replicated_storage = game:GetService("ReplicatedStorage")
local run_service = game:GetService("RunService")
local player_service = game:GetService("Players")
local teleport_service = game:GetService("TeleportService")
local user_input_service = game:GetService("UserInputService")

local player = player_service.LocalPlayer

local camera = workspace.CurrentCamera

local player_esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/jaeelin/Ascendent-ESP/refs/heads/main/PlayerESP.lua"))()

local maclib = loadstring(game:HttpGet("https://github.com/jaeelin/Maclib/releases/latest/download/maclib.txt"))()

local folder_name = "UDSploit/98598036444121"

local window = maclib:Window({
	Title = "UDSploit",
	Subtitle = "premium script for premium users.",
	Size = UDim2.fromOffset(800, 600),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightAlt,
	AcrylicBlur = true,
})

maclib:SetFolder(folder_name)

window:Notify({
	Title = "Version",
	Description = string.format("udsploit on version %s uwu!", udsploit_version),
	Lifetime = 5
})

local global_settings = {
	ui_blur_toggle = window:GlobalSetting({
		Name = "UI Blur",
		Default = window:GetAcrylicBlurState(),
		Callback = function(enabled)
			window:SetAcrylicBlurState(enabled)
			window:Notify({
				Title = window.Settings.Title,
				Description = (enabled and "Enabled" or "Disabled") .. " UI Blur",
				Lifetime = 5
			})
		end,
	}),

	notifications_toggle = window:GlobalSetting({
		Name = "Notifications",
		Default = window:GetNotificationsState(),
		Callback = function(enabled)
			window:SetNotificationsState(enabled)
			window:Notify({
				Title = window.Settings.Title,
				Description = (enabled and "Enabled" or "Disabled") .. " Notifications",
				Lifetime = 5
			})
		end,
	}),

	show_user_info = window:GlobalSetting({
		Name = "Show User Info",
		Default = window:GetUserInfoState(),
		Callback = function(enabled)
			window:SetUserInfoState(enabled)
			window:Notify({
				Title = window.Settings.Title,
				Description = (enabled and "Showing" or "Redacted") .. " User Info",
				Lifetime = 5
			})
		end,
	})
}

local main_group = window:TabGroup()
local main_tab = main_group:Tab({Name = "Home", Image = "rbxassetid://4034483344"})
local mobility_tab = main_group:Tab({Name = "Player", Image = "rbxassetid://7992557358"})
local render_tab = main_group:Tab({Name = "Render", Image = "rbxassetid://6523858394"})
local settings_tab = main_group:Tab({Name = "Settings", Image = "rbxassetid://132848201849699"})

main_tab:Select()

local sections = {
	main_section_left_top = main_tab:Section({ Side = "Left" }),
	main_section_right_top = main_tab:Section({ Side = "Right" }),
	main_section_left_bottom = main_tab:Section({ Side = "Left" }),
	mobility_left_top = mobility_tab:Section({ Side = "Left" }),
	mobility_right_top = mobility_tab:Section({ Side = "Right" }),
	mobility_right_bottom = mobility_tab:Section({ Side = "Right" }),
	mobility_right_bottom_extra = mobility_tab:Section({ Side = "Right" }),
	mobility_right_bottom_extra2 = mobility_tab:Section({ Side = "Right" }),
	render_left_top = render_tab:Section({ Side = "Left" }),
	settings_left_top = settings_tab:Section({ Side = "Left" })
}

local feature_enabled = {
	kill_aura = false,
	velocity = false,
	anti_void = false,

	flight = false,
	walkspeed = false,
	jump_power = false,
	fov = false,
	gravity = false,
	phase = false,
	long_jump = false,
	wall_climb = false,
	spin_bot = false,

	player_esp = false,
	esp_box = false,
	esp_tracer = false,
	esp_skeleton = false,
	esp_arrows = false,
	esp_name = false,
	esp_rainbow = false,
}

local connections = {
	kill_aura = nil,
	velocity = nil,
	anti_void = nil,

	flight = nil,
	walkspeed = nil,
	jump_power = nil,
	fov = nil,
	gravity = nil,
	phase = nil,
	long_jump = nil,
	wall_climb = nil,
	spin_bot = nil,
}

local settings_values = {
	kill_aura_range = 30,
	kill_aura_priority = "Closest to camera",
	kill_aura_target = "",
	kill_aura_team_check = true,
	kill_aura_friend_check = true,
	kill_aura_wall_check = false,
	kill_aura_cam_lock = false,

	flight_horizontal_speed = 15,
	flight_vertical_speed = 150,
	walkspeed = 32,
	jump_power = 50,
	fov = 70,
	gravity = 196.2,
	original_collision = {},
	long_jump_height = 15,
	long_jump_boost = 25,
	wall_climb_speed = 20,
	spin_bot_speed = 50,

	esp_instance = nil,
	esp_default_color = Color3.fromRGB(255, 255, 255),
	selected_config = nil,
	config_name = "",
}

local keybinds = {}

--[[ FUNCTIONS ]]--

local function get_closest()
	local closest_target = nil
	local shortest = math.huge

	local character = player.Character
	if not character then return end

	local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
	if not humanoid_root_part then return end

	for _, target in next, player_service:GetPlayers() do
		if target ~= player and target.Character then
			if settings_values.kill_aura_friend_check and player:IsFriendsWith(target.UserId) then continue end

			local target_character = target.Character
			if not target_character then continue end

			if settings_values.kill_aura_team_check and workspace:GetAttribute("VotedGameMode") ~= "classic" and target.TeamColor == player.TeamColor then
				continue
			end

			local target_humanoid_root_part = target_character:FindFirstChild("HumanoidRootPart")
			if not target_humanoid_root_part then continue end

			local world_distance = (humanoid_root_part.Position - target_humanoid_root_part.Position).Magnitude

			if world_distance > settings_values.kill_aura_range then continue end

			local distance
			if settings_values.kill_aura_priority == "Closest to camera" then
				local screen_position, on_screen = camera:WorldToViewportPoint(target_humanoid_root_part.Position)
				if not on_screen then continue end

				distance = (Vector2.new(screen_position.X, screen_position.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
			else
				distance = world_distance
			end

			if distance < shortest then
				shortest = distance
				closest_target = target_character
			end
		end
	end

	return closest_target
end

local function get_parts(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
	if not humanoid_root_part then return end

	return character, humanoid, humanoid_root_part
end

local function error(description, duration)
	window:Notify({
		Title = "Error",
		Description = description,
		Lifetime = duration
	})

	setclipboard("https://discord.gg/rxpEc3pCMR")
end

local function refresh_config_list(dropdown)
	dropdown:ClearOptions()
	dropdown:InsertOptions(maclib:RefreshConfigList() or {})
end

--[[ SETUP ]]--

do
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			if humanoid.UseJumpPower then
				settings_values.jump_power = 50
			else
				settings_values.jump_power = 7.2
			end
		end
	end
end

--[[ FEATURES ]]--

kill_aura_toggle = sections.main_section_left_top:Toggle({
	Name = "Killaura",
	Default = feature_enabled.kill_aura,
	Callback = function(state)
		feature_enabled.kill_aura = state

		if state then
			connections.kill_aura = run_service.RenderStepped:Connect(function()
				if not feature_enabled.kill_aura then return end

				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				local target = get_closest()
				if not target then return end

				local target_humanoid_root_part = target:FindFirstChild("HumanoidRootPart")
				if not target_humanoid_root_part then return end

				local target_humanoid = target:FindFirstChild("Humanoid")
				if not target_humanoid or target_humanoid.Health <= 0 then return end

				if settings_values.kill_aura_wall_check then
					local origin = humanoid_root_part.Position
					local direction = (target_humanoid_root_part.Position - origin).Unit * (target_humanoid_root_part.Position - origin).Magnitude

					local raycast_parameters = RaycastParams.new()
					raycast_parameters.FilterDescendantsInstances = {character}
					raycast_parameters.FilterType = Enum.RaycastFilterType.Exclude

					local raycast_result = workspace:Raycast(origin, direction, raycast_parameters)

					if raycast_result and raycast_result.Instance and raycast_result.Instance ~= target_humanoid_root_part then return end
				end

				if settings_values.kill_aura_cam_lock then
					camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target_humanoid_root_part.Position)
				end

				replicated_storage:WaitForChild("RemoteEvents"):WaitForChild("PunchRE"):FireServer(target)
			end)
		else
			if connections.kill_aura then
				connections.kill_aura:Disconnect()
				connections.kill_aura = nil
			end
		end
	end,
}, "kill_aura_toggle")

sections.main_section_left_top:Toggle({
	Name = "Killaura Wall Check",
	Default = settings_values.kill_aura_wall_check,
	Callback = function(state)
		settings_values.kill_aura_wall_check = state
	end,
}, "kill_aura_wall_check_toggle")

sections.main_section_left_top:Toggle({
	Name = "Killaura Camlock",
	Default = settings_values.kill_aura_cam_lock,
	Callback = function(state)
		settings_values.kill_aura_cam_lock = state
	end,
}, "kill_aura_cam_lock_toggle")

sections.main_section_left_top:Toggle({
	Name = "Killaura Team Check",
	Default = settings_values.team_check,
	Callback = function(state)
		settings_values.team_check = state
	end,
}, "kill_aura_team_check")

sections.main_section_left_top:Toggle({
	Name = "Killaura Friend Check",
	Default = settings_values.kill_aura_friend_chec,
	Callback = function(state)
		settings_values.kill_aura_friend_check = state
	end,
}, "kill_aura_friend_check")

sections.main_section_left_top:Slider({
	Name = "Range",
	Default = settings_values.kill_aura_range,
	Minimum = 1,
	Maximum = 200,
	DisplayMethod = "Value",
	Precision = 1,

	Callback = function(value)
		settings_values.kill_aura_range = value
	end,

}, "kill_aura_range")

sections.main_section_left_top:Dropdown({
	Name = "Priority",
	Search = false,
	Multi = false,
	Required = true,
	Options = {"Closest to camera", "Closest to character"},
	Default = 1,
	Callback = function(selected_priority)
		settings_values.kill_aura_priority = selected_priority
	end,

}, "kill_aura_priority")

keybinds.kill_aura_keybind = sections.main_section_left_top:Keybind({
	Name = "Killaura Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.kill_aura = not feature_enabled.kill_aura
			kill_aura_toggle:UpdateState(feature_enabled.kill_aura)
		end
	end,
}, "kill_aura_keybind")

velocity_toggle = sections.main_section_right_top:Toggle({
	Name = "Velocity",
	Default = feature_enabled.velocity,
	Callback = function(state)
		feature_enabled.velocity = state

		if state then
			connections.velocity = run_service.RenderStepped:Connect(function()
				if not feature_enabled.velocity then return end

				local character, humanoid, humanoid_root_part = get_parts(player)
				if not humanoid_root_part then return end

				local body_velocity = humanoid_root_part:FindFirstChild("BodyVelocity")
				if not body_velocity then return end

				body_velocity:Destroy()
			end)
		else
			if connections.velocity then
				connections.velocity:Disconnect()
				connections.velocity = nil
			end
		end
	end,
}, "velocity_toggle")

keybinds.velocity_keybind = sections.main_section_right_top:Keybind({
	Name = "Velocity Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.velocity = not feature_enabled.velocity
			velocity_toggle:UpdateState(feature_enabled.velocity)
		end
	end,
}, "velocity_keybind")

anti_void_toggle = sections.main_section_left_bottom:Toggle({
	Name = "Anti Void",
	Default = feature_enabled.anti_void,
	Callback = function(state)
		feature_enabled.anti_void = state

		if state then
			local last_position = nil

			connections.anti_void = run_service.RenderStepped:Connect(function()
				if not feature_enabled.anti_void then return end

				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				local ray_parameters = RaycastParams.new()
				ray_parameters.FilterType = Enum.RaycastFilterType.Exclude
				ray_parameters.FilterDescendantsInstances = {character}
				ray_parameters.IgnoreWater = true

				local origin = humanoid_root_part.Position
				local direction = Vector3.new(0, -500, 0)
				local result = workspace:Raycast(origin, direction, ray_parameters)

				if result then
					last_position = CFrame.new(result.Position + Vector3.new(0, 3, 0))
				end

				if humanoid_root_part.Position.Y < -30 and last_position then
					humanoid_root_part.CFrame = last_position
				end
			end)
		else
			if connections.anti_void then
				connections.anti_void:Disconnect()
				connections.anti_void = nil
			end
		end
	end,
}, "anti_void_toggle")

keybinds.anti_void_keybind = sections.main_section_left_bottom:Keybind({
	Name = "Anti Void Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.anti_void = not feature_enabled.anti_void
			anti_void_toggle:UpdateState(feature_enabled.anti_void)
		end
	end,
}, "anti_void_keybind")

flight_toggle = sections.mobility_left_top:Toggle({
	Name = "Flight",
	Default = false,
	Callback = function(enabled)
		feature_enabled.flight = enabled

		if enabled then
			connections.flight = run_service.PreRender:Connect(function(delta)
				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				local move_direction = Vector3.zero

				if user_input_service:IsKeyDown(Enum.KeyCode.W) and not user_input_service:GetFocusedTextBox() then
					move_direction += Vector3.new(0, 0, 1)
				end
				if user_input_service:IsKeyDown(Enum.KeyCode.S) and not user_input_service:GetFocusedTextBox() then
					move_direction += Vector3.new(0, 0, -1)
				end
				if user_input_service:IsKeyDown(Enum.KeyCode.A) and not user_input_service:GetFocusedTextBox() then
					move_direction += Vector3.new(-1, 0, 0)
				end
				if user_input_service:IsKeyDown(Enum.KeyCode.D) and not user_input_service:GetFocusedTextBox() then
					move_direction += Vector3.new(1, 0, 0)
				end

				local vertical = 0
				if (user_input_service:IsKeyDown(Enum.KeyCode.E) or user_input_service:IsKeyDown(Enum.KeyCode.Space))
					and not user_input_service:GetFocusedTextBox() then
					vertical = settings_values.flight_vertical_speed
				end
				if user_input_service:IsKeyDown(Enum.KeyCode.Q) and not user_input_service:GetFocusedTextBox() then
					vertical = -settings_values.flight_vertical_speed
				end

				if move_direction.Magnitude > 0 then
					move_direction = move_direction.Unit * settings_values.flight_horizontal_speed
				end

				local forward = camera.CFrame.LookVector
				local right = camera.CFrame.RightVector

				local final_move = (forward * move_direction.Z) + (right * move_direction.X) + (Vector3.yAxis * vertical)

				humanoid_root_part.CFrame += final_move * delta

				local velocity = humanoid_root_part.Velocity
				humanoid_root_part.Velocity = Vector3.new(velocity.X, 0.5, velocity.Z)
			end)
		else
			if connections.flight then
				connections.flight:Disconnect()
				connections.flight = nil
			end
		end
	end,
}, "flight_toggle")

sections.mobility_left_top:Slider({
	Name = "Horizontal Speed",
	Default = settings_values.flight_horizontal_speed,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) settings_values.flight_horizontal_speed = v end,
}, "flight_horizontal_slider")

sections.mobility_left_top:Slider({
	Name = "Vertical Speed",
	Default = settings_values.flight_vertical_speed,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) settings_values.flight_vertical_speed = v end,
}, "flight_vertical_slider")

keybinds.flight_keybind = sections.mobility_left_top:Keybind({
	Name = "Flight Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.flight = not feature_enabled.flight
			flight_toggle:UpdateState(feature_enabled.flight)
		end
	end,
}, "flight_keybind")

walkspeed_toggle = sections.mobility_left_top:Toggle({
	Name = "Walkspeed",
	Default = false,
	Callback = function(enabled)
		feature_enabled.walkspeed = enabled

		if enabled then
			connections.walkspeed = run_service.PreRender:Connect(function()
				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				humanoid.WalkSpeed = settings_values.walkspeed
			end)
		else
			if connections.walkspeed then
				connections.walkspeed:Disconnect()
				connections.walkspeed = nil
			end

			local character, humanoid, humanoid_root_part = get_parts(player)
			if not character or not humanoid or not humanoid_root_part then return end

			humanoid.WalkSpeed = 32
		end
	end,
}, "walkspeed_toggle")

sections.mobility_left_top:Slider({
	Name = "Speed",
	Default = settings_values.walkspeed,
	Minimum = 0,
	Maximum = 250,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v)
		settings_values.walkspeed = v
	end,
}, "walkspeed_slider")

keybinds.walkspeed_keybind = sections.mobility_left_top:Keybind({
	Name = "Walkspeed Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.walkspeed = not feature_enabled.walkspeed
			walkspeed_toggle:UpdateState(feature_enabled.walkspeed)
		end
	end,
}, "walkspeed_keybind")

jump_power_toggle = sections.mobility_left_top:Toggle({
	Name = "Jump Power",
	Default = false,
	Callback = function(enabled)
		feature_enabled.jump_power = enabled

		if enabled then
			connections.jump_power = run_service.PreRender:Connect(function()
				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				if humanoid.UseJumpPower then
					humanoid.JumpPower = settings_values.jump_power
				else
					humanoid.JumpHeight = settings_values.jump_power
				end
			end)
		else
			if connections.jump_power then
				connections.jump_power:Disconnect()
				connections.jump_power = nil
			end

			local character, humanoid, humanoid_root_part = get_parts(player)
			if not character or not humanoid or not humanoid_root_part then return end

			if humanoid.UseJumpPower then
				humanoid.JumpPower = 50
			else
				humanoid.JumpHeight = 7.2
			end
		end
	end,
}, "jump_power_toggle")

sections.mobility_left_top:Slider({
	Name = "Power",
	Default = settings_values.jump_power,
	Minimum = 0,
	Maximum = 300,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v)
		settings_values.jump_power = v
	end,
}, "jump_power_slider")

keybinds.jump_power_keybind = sections.mobility_left_top:Keybind({
	Name = "Jump Power Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.jump_power = not feature_enabled.jump_power
			jump_power_toggle:UpdateState(feature_enabled.jump_power)
		end
	end,
}, "jump_power_keybind")

fov_toggle = sections.mobility_left_top:Toggle({
	Name = "Field of View",
	Default = false,
	Callback = function(enabled)
		feature_enabled.fov = enabled

		if enabled then
			connections.fov = run_service.PreRender:Connect(function()
				camera.FieldOfView = settings_values.fov
			end)
		else
			if connections.fov then
				connections.fov:Disconnect()
				connections.fov = nil
			end

			camera.FieldOfView = 70
		end
	end,
}, "fov_toggle")

sections.mobility_left_top:Slider({
	Name = "FOV",
	Default = settings_values.fov,
	Minimum = 0,
	Maximum = 120,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v)
		settings_values.fov = v
	end,
}, "fov_slider")

keybinds.fov_keybind = sections.mobility_left_top:Keybind({
	Name = "FOV Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.fov = not feature_enabled.fov
			fov_toggle:UpdateState(feature_enabled.fov)
		end
	end,
}, "fov_keybind")

gravity_toggle = sections.mobility_left_top:Toggle({
	Name = "Gravity",
	Default = false,
	Callback = function(enabled)
		feature_enabled.gravity = enabled

		if enabled then
			connections.gravity = run_service.PreRender:Connect(function()
				workspace.Gravity = settings_values.gravity
			end)
		else
			if connections.gravity then
				connections.gravity:Disconnect()
				connections.gravity = nil
			end
			workspace.Gravity = 196.2
		end
	end,
}, "gravity_toggle")

sections.mobility_left_top:Slider({
	Name = "Gravity",
	Default = settings_values.gravity,
	Minimum = 0,
	Maximum = 300,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v)
		settings_values.gravity = v
	end,
}, "gravity_slider")

keybinds.gravity_keybind = sections.mobility_left_top:Keybind({
	Name = "Gravity Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.gravity = not feature_enabled.gravity
			gravity_toggle:UpdateState(feature_enabled.gravity)
		end
	end,
}, "gravity_keybind")

phase_toggle = sections.mobility_right_top:Toggle({
	Name = "Phase",
	Default = false,
	Callback = function(state)
		feature_enabled.phase = state

		if state then
			settings_values.original_collision = {}

			connections.phase = run_service.PreRender:Connect(function()
				local character = player.Character
				if not character then return end

				for _, part in next, character:GetDescendants() do
					if part:IsA("BasePart") and part.Name ~= "Cape" and settings_values.original_collision[part] == nil then
						settings_values.original_collision[part] = part.CanCollide
					end
				end

				for part, _ in next, settings_values.original_collision do
					if part and part.Parent then
						part.CanCollide = false
					end
				end
			end)
		else
			for part, can_collide in next, settings_values.original_collision or {} do
				if part and part.Parent then
					part.CanCollide = can_collide
				end
			end

			settings_values.original_collision = {}

			connections.phase:Disconnect()
			connections.phase = nil
		end
	end,
}, "PhaseToggle")

keybinds.phase = sections.mobility_right_top:Keybind({
	Name = "Phase Keybind",
	Blacklist = false,
	onBindHeld = function(held, bind)
		if held then
			feature_enabled.phase = not feature_enabled.phase
			phase_toggle:UpdateState(feature_enabled.phase)
		end
	end,

}, "phase_keybind")

long_jump_toggle = sections.mobility_right_bottom:Toggle({
	Name = "Long Jump",
	Default = false,
	Callback = function(enabled)
		feature_enabled.long_jump = enabled

		if enabled then
			local can_boost = true

			connections.long_jump = run_service.PreRender:Connect(function()
				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				if humanoid:GetState() == Enum.HumanoidStateType.Jumping and can_boost then
					local direction = humanoid_root_part.CFrame.LookVector * settings_values.long_jump_boost
					humanoid_root_part.Velocity += Vector3.new(direction.X, settings_values.long_jump_height, direction.Z)
					can_boost = false
				elseif humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
					can_boost = true
				end
			end)
		else
			if connections.long_jump then
				connections.long_jump:Disconnect()
				connections.long_jump = nil
			end
		end
	end,
}, "long_jump_toggle")

sections.mobility_right_bottom:Slider({
	Name = "Height",
	Default = settings_values.long_jump_height,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) settings_values.long_jump_height = v end,
}, "long_jump_height_slider")

sections.mobility_right_bottom:Slider({
	Name = "Boost",
	Default = settings_values.long_jump_boost,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) settings_values.long_jump_boost = v end,
}, "long_jump_boost_slider")

keybinds.long_jump_keybind = sections.mobility_right_bottom:Keybind({
	Name = "Long Jump Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.long_jump = not feature_enabled.long_jump
			long_jump_toggle:UpdateState(feature_enabled.long_jump)
		end
	end,
}, "long_jump_keybind")

wall_climb_toggle = sections.mobility_right_bottom_extra:Toggle({
	Name = "Wall Climb",
	Default = false,
	Callback = function(enabled)
		feature_enabled.wall_climb = enabled

		if enabled then
			connections.wall_climb = run_service.PreRender:Connect(function()
				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid_root_part then return end

				local ray_origin = humanoid_root_part.Position
				local ray_direction = humanoid_root_part.CFrame.LookVector * 2

				local parameters = RaycastParams.new()
				parameters.FilterDescendantsInstances = {character}
				parameters.FilterType = Enum.RaycastFilterType.Exclude

				local wall_hit = workspace:Raycast(ray_origin, ray_direction, parameters)
				if not wall_hit then return end

				local upper_origin = ray_origin + Vector3.new(0, 2.5, 0)
				local upper_hit = workspace:Raycast(upper_origin, ray_direction, parameters)

				if upper_hit then
					humanoid_root_part.Velocity = Vector3.new(
						humanoid_root_part.Velocity.X,
						settings_values.wall_climb_speed,
						humanoid_root_part.Velocity.Z
					)
				else
					humanoid_root_part.CFrame += humanoid_root_part.CFrame.LookVector * 1.2
					humanoid_root_part.Velocity = Vector3.zero
				end
			end)
		else
			if connections.wall_climb then
				connections.wall_climb:Disconnect()
				connections.wall_climb = nil
			end
		end
	end,
}, "wall_climb_toggle")

sections.mobility_right_bottom_extra:Slider({
	Name = "Speed",
	Default = settings_values.wall_climb_speed,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) settings_values.wall_climb_speed = v end,
}, "wall_climb_speed_slider")

keybinds.wall_climb_keybind = sections.mobility_right_bottom_extra:Keybind({
	Name = "Wall Climb Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.wall_climb = not feature_enabled.wall_climb
			wall_climb_toggle:UpdateState(feature_enabled.wall_climb)
		end
	end,
}, "wall_climb_keybind")

spin_bot_toggle = sections.mobility_right_bottom_extra2:Toggle({
	Name = "Spin Bot",
	Default = false,
	Callback = function(enabled)
		feature_enabled.spin_bot = enabled

		if enabled then
			connections.spin_bot = run_service.PreRender:Connect(function(delta)
				local character, humanoid, humanoid_root_part = get_parts(player)
				if not character or not humanoid or not humanoid_root_part then return end

				humanoid.AutoRotate = false

				local rotation = math.rad(settings_values.spin_bot_speed) * delta * 60
				humanoid_root_part.CFrame *= CFrame.Angles(0, rotation, 0)
			end)
		else
			if connections.spin_bot then
				connections.spin_bot:Disconnect()
				connections.spin_bot = nil
			end

			local character, humanoid, humanoid_root_part = get_parts(player)
			if not character or not humanoid_root_part then return end

			humanoid.AutoRotate = true
		end
	end,
}, "spin_bot_toggle")

sections.mobility_right_bottom_extra2:Slider({
	Name = "Speed",
	Default = settings_values.spin_bot_speed,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		settings_values.spin_bot_speed = value
	end,
}, "spin_bot_speed_slider")

keybinds.spin_bot_keybind = sections.mobility_right_bottom_extra2:Keybind({
	Name = "Spin Bot Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.spin_bot = not feature_enabled.spin_bot
			spin_bot_toggle:UpdateState(feature_enabled.spin_bot)
		end
	end,
}, "spin_bot_keybind")

player_esp_toggle = sections.render_left_top:Toggle({
	Name = "Player ESP",
	Default = false,
	Callback = function(enabled)
		feature_enabled.player_esp = enabled

		if enabled then
			settings_values.esp_instance = player_esp.new({
				Box = feature_enabled.esp_box,
				Tracer = feature_enabled.esp_tracer,
				Arrows = feature_enabled.esp_arrows,
				Skeleton = feature_enabled.esp_skeleton,
				Name = feature_enabled.esp_name,
				Rainbow = feature_enabled.esp_rainbow,
				DefaultColor = settings_values.esp_default_color,
				MaxDistance = 1000
			})
			settings_values.esp_instance:Enable()
		else
			if settings_values.esp_instance then
				settings_values.esp_instance:Disable()
				settings_values.esp_instance = nil
			end
		end
	end,
}, "player_esp_toggle")

sections.render_left_top:Toggle({
	Name = "Box",
	Default = false,
	Callback = function(enabled)
		feature_enabled.esp_box = enabled
		if settings_values.esp_instance then
			settings_values.esp_instance.Box = enabled
		end
	end,
}, "esp_box_toggle")

sections.render_left_top:Toggle({
	Name = "Tracer",
	Default = false,
	Callback = function(enabled)
		feature_enabled.esp_tracer = enabled
		if settings_values.esp_instance then
			settings_values.esp_instance.Tracer = enabled
		end
	end,
}, "esp_tracer_toggle")

sections.render_left_top:Toggle({
	Name = "Skeleton",
	Default = false,
	Callback = function(enabled)
		feature_enabled.esp_skeleton = enabled
		if settings_values.esp_instance then
			settings_values.esp_instance.Skeleton = enabled
		end
	end,
}, "esp_skeleton_toggle")

sections.render_left_top:Toggle({
	Name = "Arrows",
	Default = false,
	Callback = function(enabled)
		feature_enabled.esp_arrows = enabled
		if settings_values.esp_instance then
			settings_values.esp_instance.Arrows = enabled
		end
	end,
}, "esp_arrows_toggle")

sections.render_left_top:Toggle({
	Name = "Name",
	Default = false,
	Callback = function(enabled)
		feature_enabled.esp_name = enabled
		if settings_values.esp_instance then
			settings_values.esp_instance.Name = enabled
		end
	end,
}, "esp_name_toggle")

sections.render_left_top:Toggle({
	Name = "Rainbow",
	Default = false,
	Callback = function(enabled)
		feature_enabled.esp_rainbow = enabled
		if settings_values.esp_instance then
			settings_values.esp_instance.Rainbow = enabled
		end
	end,
}, "esp_rainbow_toggle")


sections.render_left_top:Colorpicker({
	Name = "Player ESP Color",
	Default = settings_values.esp_default_color,
	Callback = function(color)
		settings_values.esp_default_color = color

		if settings_values.esp_instance then
			settings_values.esp_instance.DefaultColor = color

			for _, target_player in next, player_service:GetPlayers() do
				if target_player ~= player then
					settings_values.esp_instance:SetColor(target_player, color)
				end
			end
		end
	end,
}, "esp_color_picker")

keybinds.player_esp_keybind = sections.render_left_top:Keybind({
	Name = "ESP Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			feature_enabled.player_esp = not feature_enabled.player_esp
			player_esp_toggle:UpdateState(feature_enabled.player_esp)
		end
	end,
}, "player_esp_keybind")

config_dropdown = sections.settings_left_top:Dropdown({
	Name = "Configs",
	Callback = function(selected)
		settings_values.selected_config = selected
	end,
})

refresh_config_list(config_dropdown)

sections.settings_left_top:Input({
	Name = "Config Name",
	Placeholder = "Enter name",
	Callback = function(text)
		settings_values.config_name = text
	end,
})

sections.settings_left_top:Button({
	Name = "Save Config",
	Callback = function()
		if settings_values.config_name == "" then
			window:Notify({
				Title = "Config",
				Description = "Config name cannot be empty",
				Lifetime = 3
			})
			return
		end

		maclib:SaveConfig(settings_values.config_name)
		refresh_config_list(config_dropdown)

		window:Notify({
			Title = "Config",
			Description = "Saved config: " .. settings_values.config_name,
			Lifetime = 3
		})
	end
})

sections.settings_left_top:Button({
	Name = "Load Config",
	Callback = function()
		if not settings_values.selected_config then return end

		maclib:LoadConfig(settings_values.selected_config)
		refresh_config_list(config_dropdown)

		window:Notify({
			Title = "Config",
			Description = "Loaded config: " .. settings_values.selected_config,
			Lifetime = 3
		})
	end
})

sections.settings_left_top:Button({
	Name = "Delete Config",
	Callback = function()
		if not settings_values.selected_config then return end

		local path = folder_name .. "/settings/" .. settings_values.selected_config .. ".json"

		if isfile(path) then
			delfile(path)
		end

		settings_values.selected_config = nil
		refresh_config_list(config_dropdown)

		window:Notify({
			Title = "Config",
			Description = "Config deleted",
			Lifetime = 3
		})
	end
})

window.onUnloaded(function()
	for _, keybind in next, keybinds do
		if keybind and keybind.Unbind then
			keybind:Unbind()
		end
	end

	keybinds = {}

	for _, connection in next, connections do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	connections = {}

	if settings_values.esp_instance then
		settings_values.esp_instance:Disable()
		settings_values.esp_instance = nil
	end
end)
