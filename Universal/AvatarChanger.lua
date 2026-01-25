-- join https://discord.com/invite/uxd
--thx

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
	Accent = Color3.fromRGB(255, 100, 110),
	Dark = Color3.fromRGB(35, 35, 35),
	Darker = Color3.fromRGB(26, 26, 26),
	Input = Color3.fromRGB(30, 30, 30),
	Stroke = Color3.fromRGB(80, 80, 80),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(170, 170, 170)
}

local AvatarChanger = {}
AvatarChanger.__index = AvatarChanger

function AvatarChanger.new()
	local self = setmetatable({}, AvatarChanger)
	
	self.Version = "1.0.0"
	self.FavoritesFile = "Favorites.json"
	self.Gui = nil
	
	self.Favorites = self:_load_favorites()
	self.StoredNames = {}
	
	self:_create_ui()
	
	return self
end

function AvatarChanger:_create_ui()
	local avatar_changer = Instance.new("ScreenGui")
	avatar_changer.Name = "AvatarChanger"
	avatar_changer.Parent = game.Players.LocalPlayer.PlayerGui
	avatar_changer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	avatar_changer.ResetOnSpawn = false

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Parent = avatar_changer
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.new(0.360000014, 0, 0.419999987, 0)
	
	self:_dragify(main, 0.15)

	local ui_aspect_ratio_constraint = Instance.new("UIAspectRatioConstraint")
	ui_aspect_ratio_constraint.Parent = main
	ui_aspect_ratio_constraint.AspectRatio = 1.040

	local ui_size_constraint = Instance.new("UISizeConstraint")
	ui_size_constraint.Parent = main
	ui_size_constraint.MaxSize = Vector2.new(480, 680)
	ui_size_constraint.MinSize = Vector2.new(240, 340)

	local ui_corner = Instance.new("UICorner")
	ui_corner.CornerRadius = UDim.new(0, 14)
	ui_corner.Parent = main

	local ui_stroke = Instance.new("UIStroke")
	ui_stroke.Parent = main
	ui_stroke.Color = Color3.fromRGB(255, 90, 100)
	ui_stroke.Transparency = 0.400
	ui_stroke.Thickness = 1.800
	ui_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	local top_bar = Instance.new("Frame")
	top_bar.Name = "TopBar"
	top_bar.Parent = main
	top_bar.BackgroundColor3 = Theme.Darker
	top_bar.BorderSizePixel = 0
	top_bar.Size = UDim2.new(1, 0, 0.158823535, 0)
	top_bar.ZIndex = 2

	local ui_corner_2 = Instance.new("UICorner")
	ui_corner_2.CornerRadius = UDim.new(0, 14)
	ui_corner_2.Parent = top_bar

	local ui_padding = Instance.new("UIPadding")
	ui_padding.Parent = top_bar
	ui_padding.PaddingLeft = UDim.new(0, 16)
	ui_padding.PaddingTop = UDim.new(0, 10)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Parent = top_bar
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 0, -0.0318180434, 0)
	title.Size = UDim2.new(0.598340809, 0, 0.375, 0)
	title.Font = Enum.Font.GothamBold
	title.Text = "AVATAR CHANGER"
	title.TextColor3 = Theme.Text
	title.TextScaled = true
	title.TextSize = 22
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Parent = top_bar
	description.BackgroundTransparency = 1
	description.Position = UDim2.new(0, 0, 0.318181813, 0)
	description.Size = UDim2.new(0.598340809, 0, 0.404545516, 0)
	description.ZIndex = 2
	description.Font = Enum.Font.Gotham
	description.Text = "by returnreturnfunction"
	description.TextColor3 = Theme.SubText
	description.TextScaled = true
	description.TextSize = 15
	description.TextWrapped = true
	description.TextXAlignment = Enum.TextXAlignment.Left
	
	local ui_text_size_constraint = Instance.new("UITextSizeConstraint")
	ui_text_size_constraint.MaxTextSize = 15
	ui_text_size_constraint.Parent = description

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Parent = top_bar
	bar.BackgroundColor3 = Theme.Accent
	bar.BorderSizePixel = 0
	bar.Position = UDim2.new(0, 0, 0.812963009, 0)
	bar.Size = UDim2.new(0.200000003, 0, 0.0370370373, 0)
	bar.ZIndex = 4

	local bottom_bar = Instance.new("Frame")
	bottom_bar.Name = "BottomBar"
	bottom_bar.Parent = top_bar
	bottom_bar.BackgroundColor3 = Theme.Darker
	bottom_bar.BorderSizePixel = 0
	bottom_bar.Position = UDim2.new(-0.0657665059, 0, 0.688417137, 0)
	bottom_bar.Size = UDim2.new(1.06576705, 0, 0.311582536, 0)

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.Parent = top_bar
	close.AnchorPoint = Vector2.new(1, 0)
	close.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	close.BorderSizePixel = 0
	close.Position = UDim2.new(0.954751194, 0, -3.46790671e-07, 0)
	close.Size = UDim2.new(0.0668010935, 0, 0.51262635, 0)
	close.AutoButtonColor = false
	close.Font = Enum.Font.GothamBold
	close.Text = "×"
	close.TextColor3 = Theme.SubText
	close.TextSize = 28

	local ui_corner_3 = Instance.new("UICorner")
	ui_corner_3.CornerRadius = UDim.new(0.25, 0)
	ui_corner_3.Parent = close

	local ui_stroke_2 = Instance.new("UIStroke")
	ui_stroke_2.Parent = close
	ui_stroke_2.Color = Color3.fromRGB(90, 90, 90)
	ui_stroke_2.Transparency = 0.400
	ui_stroke_2.Thickness = 1.200
	
	local tab_container = Instance.new("Frame")
	tab_container.Name = "TabContainer"
	tab_container.Parent = main
	tab_container.BackgroundTransparency = 1
	tab_container.Position = UDim2.new(0, 0, 0.158823535, 0)
	tab_container.Size = UDim2.new(1, 0, 0.117647059, 0)

	local ui_padding_2 = Instance.new("UIPadding")
	ui_padding_2.Parent = tab_container
	ui_padding_2.PaddingLeft = UDim.new(0, 16)
	ui_padding_2.PaddingRight = UDim.new(0, 16)

	local changer_tab = Instance.new("TextButton")
	changer_tab.Name = "ChangerTab"
	changer_tab.Parent = tab_container
	changer_tab.BackgroundColor3 = Theme.Accent
	changer_tab.BorderSizePixel = 0
	changer_tab.Position = UDim2.new(0, 0, 0.125, 0)
	changer_tab.Size = UDim2.new(0.330000013, 0, 0.75, 0)
	changer_tab.AutoButtonColor = false
	changer_tab.Font = Enum.Font.GothamBold
	changer_tab.Text = "CHANGER"
	changer_tab.TextColor3 = Theme.Text
	changer_tab.TextSize = 14

	local ui_corner_4 = Instance.new("UICorner")
	ui_corner_4.CornerRadius = UDim.new(0.25, 0)
	ui_corner_4.Parent = changer_tab

	local favorited_tab = Instance.new("TextButton")
	favorited_tab.Name = "FavoritedTab"
	favorited_tab.Parent = tab_container
	favorited_tab.BackgroundColor3 = Theme.Dark
	favorited_tab.BorderSizePixel = 0
	favorited_tab.Position = UDim2.new(0.699577034, 0, 0.125, 0)
	favorited_tab.Size = UDim2.new(0.330000013, 0, 0.75, 0)
	favorited_tab.AutoButtonColor = false
	favorited_tab.Font = Enum.Font.GothamBold
	favorited_tab.Text = "FAVORITED"
	favorited_tab.TextColor3 = Theme.SubText
	favorited_tab.TextSize = 14

	local ui_corner_5 = Instance.new("UICorner")
	ui_corner_5.CornerRadius = UDim.new(0.25, 0)
	ui_corner_5.Parent = favorited_tab
	
	local customizer_tab = Instance.new("TextButton")
	customizer_tab.Name = "CustomizerTab"
	customizer_tab.Parent = tab_container
	customizer_tab.BackgroundColor3 = Theme.Dark
	customizer_tab.BorderSizePixel = 0
	customizer_tab.Position = UDim2.new(0.348905534, 0, 0.125, 0)
	customizer_tab.Size = UDim2.new(0.330000013, 0, 0.75, 0)
	customizer_tab.AutoButtonColor = false
	customizer_tab.Font = Enum.Font.GothamBold
	customizer_tab.Text = "CUSTOMIZER"
	customizer_tab.TextColor3 = Theme.SubText
	customizer_tab.TextSize = 14.000
	
	local ui_corner_6 = Instance.new("UICorner")
	ui_corner_6.CornerRadius = UDim.new(0.25, 0)
	ui_corner_6.Parent = customizer_tab
	
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Parent = main
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 0, 0.276470602, 0)
	content.Size = UDim2.new(1, 0, 0.723529398, 0)

	local ui_padding_3 = Instance.new("UIPadding")
	ui_padding_3.Parent = content
	ui_padding_3.PaddingBottom = UDim.new(0, 16)
	ui_padding_3.PaddingLeft = UDim.new(0, 16)
	ui_padding_3.PaddingRight = UDim.new(0, 16)
	ui_padding_3.PaddingTop = UDim.new(0, 16)

	local changer = Instance.new("Frame")
	changer.Name = "ChangerPage"
	changer.Parent = content
	changer.BackgroundTransparency = 1
	changer.Size = UDim2.new(1, 0, 1, 0)

	local id = Instance.new("TextBox")
	id.Name = "Id"
	id.Parent = changer
	id.BackgroundColor3 = Theme.Input
	id.BorderSizePixel = 0
	id.Size = UDim2.new(1, 0, 0.154363111, 0)
	id.ClearTextOnFocus = false
	id.Font = Enum.Font.Gotham
	id.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	id.PlaceholderText = "Enter User ID..."
	id.Text = ""
	id.TextColor3 = Theme.Text
	id.TextSize = 14

	local ui_corner_7 = Instance.new("UICorner")
	ui_corner_7.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_7.Parent = id

	local ui_stroke_3 = Instance.new("UIStroke")
	ui_stroke_3.Parent = id
	ui_stroke_3.Color = Theme.Stroke
	ui_stroke_3.Transparency = 0.500

	local apply = Instance.new("TextButton")
	apply.Name = "Apply"
	apply.Parent = changer
	apply.BackgroundColor3 = Theme.Accent
	apply.BorderSizePixel = 0
	apply.Position = UDim2.new(0, 0, 0.19295381, 0)
	apply.Size = UDim2.new(0.479999989, 0, 0.138926789, 0)
	apply.AutoButtonColor = false
	apply.Font = Enum.Font.GothamBold
	apply.Text = "✅ APPLY"
	apply.TextColor3 = Theme.Text
	apply.TextSize = 14

	local ui_corner_8 = Instance.new("UICorner")
	ui_corner_8.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_8.Parent = apply

	local random = Instance.new("TextButton")
	random.Name = "Random"
	random.Parent = changer
	random.BackgroundColor3 = Theme.Accent
	random.BorderSizePixel = 0
	random.Position = UDim2.new(0.520000219, 0, 0.19295381, 0)
	random.Size = UDim2.new(0.47999993, 0, 0.138926789, 0)
	random.AutoButtonColor = false
	random.Font = Enum.Font.GothamBold
	random.Text = "🎲 RANDOM"
	random.TextColor3 = Theme.Text
	random.TextSize = 14

	local ui_corner_9 = Instance.new("UICorner")
	ui_corner_9.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_9.Parent = random

	local favorite = Instance.new("TextButton")
	favorite.Name = "Favorite"
	favorite.Parent = changer
	favorite.BackgroundColor3 = Theme.Accent
	favorite.BorderSizePixel = 0
	favorite.Position = UDim2.new(0, 0, 0.370471418, 0)
	favorite.Size = UDim2.new(1, 0, 0.138926789, 0)
	favorite.AutoButtonColor = false
	favorite.Font = Enum.Font.GothamBold
	favorite.Text = "⭐ ADD TO FAVORITES"
	favorite.TextColor3 = Theme.Text
	favorite.TextSize = 14

	local ui_corner_10 = Instance.new("UICorner")
	ui_corner_10.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_10.Parent = favorite

	local reset = Instance.new("TextButton")
	reset.Name = "Reset"
	reset.Parent = changer
	reset.BackgroundColor3 = Theme.Accent
	reset.BorderSizePixel = 0
	reset.Position = UDim2.new(0, 0, 0.547989011, 0)
	reset.Size = UDim2.new(1, 0, 0.138926849, 0)
	reset.AutoButtonColor = false
	reset.Font = Enum.Font.GothamBold
	reset.Text = "♻️ RESET TO ORIGINAL"
	reset.TextColor3 = Theme.Text
	reset.TextSize = 14

	local ui_corner_11 = Instance.new("UICorner")
	ui_corner_11.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_11.Parent = reset

	local area = Instance.new("Frame")
	area.Name = "Area"
	area.Parent = changer
	area.BackgroundTransparency = 1
	area.Position = UDim2.new(0, 0, 0.724299192, 0)
	area.Size = UDim2.new(1, 0, 0.350467324, 0)

	local title_2 = Instance.new("TextLabel")
	title_2.Name = "Title"
	title_2.Parent = area
	title_2.BackgroundTransparency = 1
	title_2.Position = UDim2.new(0, 0, 0.0707722902, 0)
	title_2.Size = UDim2.new(1, 0, 0.221537679, 0)
	title_2.Font = Enum.Font.GothamBold
	title_2.Text = "Join our Discord!"
	title_2.TextColor3 = Color3.fromRGB(220, 220, 220)
	title_2.TextSize = 15

	local description_2 = Instance.new("TextLabel")
	description_2.Name = "Description"
	description_2.Parent = area
	description_2.BackgroundTransparency = 1
	description_2.Position = UDim2.new(0, 0, 0.292309135, 0)
	description_2.Size = UDim2.new(1, 0, 0.20307605, 0)
	description_2.Font = Enum.Font.Gotham
	description_2.Text = "https://discord.com/invite/uxd"
	description_2.TextColor3 = Color3.fromRGB(255, 80, 80)
	description_2.TextSize = 14
	description_2.TextWrapped = true

	local copy = Instance.new("TextButton")
	copy.Name = "Copy"
	copy.Parent = area
	copy.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	copy.BorderSizePixel = 0
	copy.Position = UDim2.new(0, 0, 0.587693214, 0)
	copy.Size = UDim2.new(1, 0, 0.332306385, 0)
	copy.AutoButtonColor = false
	copy.Font = Enum.Font.GothamBold
	copy.Text = "Copy Link"
	copy.TextColor3 = Theme.Text
	copy.TextSize = 14

	local ui_corner_12 = Instance.new("UICorner")
	ui_corner_12.CornerRadius = UDim.new(0.25, 0)
	ui_corner_12.Parent = copy
	
	local customizer_page = Instance.new("Frame")
	customizer_page.Name = "CustomizerPage"
	customizer_page.Parent = content
	customizer_page.BackgroundTransparency = 1.000
	customizer_page.Size = UDim2.new(1, 0, 1, 0)
	customizer_page.Visible = false
	
	local shirt_id_input = Instance.new("TextBox")
	shirt_id_input.Name = "shirt_id_input"
	shirt_id_input.Parent = customizer_page
	shirt_id_input.BackgroundColor3 = Theme.Input
	shirt_id_input.BorderSizePixel = 0
	shirt_id_input.Size = UDim2.new(1, 0, 0.154363111, 0)
	shirt_id_input.ClearTextOnFocus = false
	shirt_id_input.Font = Enum.Font.Gotham
	shirt_id_input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	shirt_id_input.PlaceholderText = "Enter Shirt ID..."
	shirt_id_input.Text = ""
	shirt_id_input.TextColor3 = Theme.Text
	shirt_id_input.TextSize = 14.000
	
	local ui_corner_13 = Instance.new("UICorner")
	ui_corner_13.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_13.Parent = shirt_id_input
	
	local ui_stroke_4 = Instance.new("UIStroke")
	ui_stroke_4.Parent = shirt_id_input
	ui_stroke_4.Color = Theme.Stroke
	ui_stroke_4.Transparency = 0.500
	
	local pants_id_input = Instance.new("TextBox")
	pants_id_input.Name = "PantsId"
	pants_id_input.Parent = customizer_page
	pants_id_input.BackgroundColor3 = Theme.Input
	pants_id_input.BorderSizePixel = 0
	pants_id_input.Position = UDim2.new(0, 0, 0.180000007, 0)
	pants_id_input.Size = UDim2.new(1, 0, 0.154363111, 0)
	pants_id_input.ClearTextOnFocus = false
	pants_id_input.Font = Enum.Font.Gotham
	pants_id_input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	pants_id_input.PlaceholderText = "Enter Pants ID..."
	pants_id_input.Text = ""
	pants_id_input.TextColor3 = Theme.Text
	pants_id_input.TextSize = 14.000
	
	local ui_corner_14 = Instance.new("UICorner")
	ui_corner_14.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_14.Parent = pants_id_input
	
	local ui_stroke_5 = Instance.new("UIStroke")
	ui_stroke_5.Parent = pants_id_input
	ui_stroke_5.Color = Theme.Stroke
	ui_stroke_5.Transparency = 0.500
	
	local customizer_apply = Instance.new("TextButton")
	customizer_apply.Name = "Apply"
	customizer_apply.Parent = customizer_page
	customizer_apply.BackgroundColor3 = Theme.Accent
	customizer_apply.BorderSizePixel = 0
	customizer_apply.Position = UDim2.new(0, 0, 0.379999995, 0)
	customizer_apply.Size = UDim2.new(1, 0, 0.138926849, 0)
	customizer_apply.AutoButtonColor = false
	customizer_apply.Font = Enum.Font.GothamBold
	customizer_apply.Text = "✅ APPLY"
	customizer_apply.TextColor3 = Theme.Text
	customizer_apply.TextSize = 14
	
	local ui_corner_15 = Instance.new("UICorner")
	ui_corner_15.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_15.Parent = customizer_apply
	
	local customizer_reset = Instance.new("TextButton")
	customizer_reset.Name = "Reset"
	customizer_reset.Parent = customizer_page
	customizer_reset.BackgroundColor3 = Theme.Accent
	customizer_reset.BorderSizePixel = 0
	customizer_reset.Position = UDim2.new(0, 0, 0.547989011, 0)
	customizer_reset.Size = UDim2.new(1, 0, 0.138926849, 0)
	customizer_reset.AutoButtonColor = false
	customizer_reset.Font = Enum.Font.GothamBold
	customizer_reset.Text = "♻️ RESET TO ORIGINAL"
	customizer_reset.TextColor3 = Theme.Text
	customizer_reset.TextSize = 14.000
	
	local ui_corner_16 = Instance.new("UICorner")
	ui_corner_16.CornerRadius = UDim.new(0.150000006, 0)
	ui_corner_16.Parent = customizer_reset
	
	local customier_area = Instance.new("Frame")
	customier_area.Name = "Area"
	customier_area.Parent = customizer_page
	customier_area.BackgroundTransparency = 1.000
	customier_area.Position = UDim2.new(0, 0, 0.724299192, 0)
	customier_area.Size = UDim2.new(1, 0, 0.350467324, 0)
	
	local customizer_area_title = Instance.new("TextLabel")
	customizer_area_title.Name = "Title"
	customizer_area_title.Parent = customier_area
	customizer_area_title.BackgroundTransparency = 1.000
	customizer_area_title.Position = UDim2.new(0, 0, 0.0707722902, 0)
	customizer_area_title.Size = UDim2.new(1, 0, 0.221537679, 0)
	customizer_area_title.Font = Enum.Font.GothamBold
	customizer_area_title.Text = "Join our Discord!"
	customizer_area_title.TextColor3 = Color3.fromRGB(220, 220, 220)
	customizer_area_title.TextSize = 15.000
	
	local customizer_area_description = Instance.new("TextLabel")
	customizer_area_description.Name = "Description"
	customizer_area_description.Parent = customier_area
	customizer_area_description.BackgroundTransparency = 1.000
	customizer_area_description.Position = UDim2.new(0, 0, 0.292309135, 0)
	customizer_area_description.Size = UDim2.new(1, 0, 0.20307605, 0)
	customizer_area_description.Font = Enum.Font.Gotham
	customizer_area_description.Text = "https://discord.com/invite/uxd"
	customizer_area_description.TextColor3 = Color3.fromRGB(255, 80, 80)
	customizer_area_description.TextSize = 14.000
	customizer_area_description.TextWrapped = true
	
	local customizer_area_copy = Instance.new("TextButton")
	customizer_area_copy.Name = "Copy"
	customizer_area_copy.Parent = customier_area
	customizer_area_copy.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	customizer_area_copy.BorderSizePixel = 0
	customizer_area_copy.Position = UDim2.new(0, 0, 0.587693214, 0)
	customizer_area_copy.Size = UDim2.new(1, 0, 0.332306385, 0)
	customizer_area_copy.AutoButtonColor = false
	customizer_area_copy.Font = Enum.Font.GothamBold
	customizer_area_copy.Text = "Copy Link"
	customizer_area_copy.TextColor3 = Theme.Text
	customizer_area_copy.TextSize = 14.000
	
	local ui_corner_17 = Instance.new("UICorner")
	ui_corner_17.CornerRadius = UDim.new(0.25, 0)
	ui_corner_17.Parent = customizer_area_copy

	local favorited = Instance.new("Frame")
	favorited.Name = "FavoritedPage"
	favorited.Parent = content
	favorited.BackgroundTransparency = 1
	favorited.Size = UDim2.new(1, 0, 1, 0)
	favorited.Visible = false
	
	local function Refresh()
		for _, child in next, favorited:GetChildren() do
			if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
				child:Destroy()
			end
		end

		local scrolling = Instance.new("ScrollingFrame")
		scrolling.Name = "Scroll"
		scrolling.Parent = favorited
		scrolling.BackgroundTransparency = 1
		scrolling.BorderSizePixel = 0
		scrolling.Position = UDim2.new(0, 0, 0, 0)
		scrolling.Size = UDim2.new(1, 0, 1, 0)
		scrolling.ScrollBarThickness = 6
		scrolling.ScrollBarImageColor3 = Theme.Stroke
		scrolling.ScrollingDirection = Enum.ScrollingDirection.Y
		scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)

		local list_layout = Instance.new("UIListLayout")
		list_layout.Padding = UDim.new(0, 8)
		list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		list_layout.SortOrder = Enum.SortOrder.LayoutOrder
		list_layout.Parent = scrolling

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 4)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 8)
		padding.PaddingRight = UDim.new(0, 8)
		padding.Parent = scrolling

		if #self.Favorites == 0 then
			local empty_label = Instance.new("TextLabel")
			empty_label.BackgroundTransparency = 1
			empty_label.Size = UDim2.new(1, 0, 0, 40)
			empty_label.Font = Enum.Font.Gotham
			empty_label.Text = "No favorites yet"
			empty_label.TextColor3 = Color3.fromRGB(150, 150, 150)
			empty_label.TextSize = 14
			empty_label.Parent = scrolling
			return
		end
		
		for i = 1, #self.Favorites do
			local user_id = self.Favorites[i]
			
			local username = self:_get_username(user_id)
			local display_name = username or "User"

			local favorite_button = Instance.new("TextButton")
			favorite_button.Name = user_id
			favorite_button.Size = UDim2.new(1, 0, 0, 48)
			favorite_button.BackgroundColor3 = Theme.Dark
			favorite_button.BorderSizePixel = 0
			favorite_button.Text = ""
			favorite_button.AutoButtonColor = false
			favorite_button.Parent = scrolling

			local ui_corner_18 = Instance.new("UICorner")
			ui_corner_18.CornerRadius = UDim.new(0, 6)
			ui_corner_18.Parent = favorite_button

			local name_label = Instance.new("TextLabel")
			name_label.BackgroundTransparency = 1
			name_label.Position = UDim2.new(0, 12, 0, 6)
			name_label.Size = UDim2.new(1, -50, 0, 20)
			name_label.Font = Enum.Font.GothamBold
			name_label.Text = "👤 " .. display_name
			name_label.TextColor3 = Theme.Text
			name_label.TextSize = 15
			name_label.TextXAlignment = Enum.TextXAlignment.Left
			name_label.TextTruncate = Enum.TextTruncate.SplitWord
			name_label.Parent = favorite_button

			local id_label = Instance.new("TextLabel")
			id_label.BackgroundTransparency = 1
			id_label.Position = UDim2.new(0, 12, 0, 26)
			id_label.Size = UDim2.new(1, -50, 0, 16)
			id_label.Font = Enum.Font.Gotham
			id_label.Text = "ID: " .. user_id
			id_label.TextColor3 = Theme.SubText
			id_label.TextSize = 13
			id_label.TextXAlignment = Enum.TextXAlignment.Left
			id_label.Parent = favorite_button

			local delete_button = Instance.new("TextButton")
			delete_button.Name = "DeleteButton"
			delete_button.AnchorPoint = Vector2.new(1, 0.5)
			delete_button.Position = UDim2.new(1, -8, 0.5, 0)
			delete_button.Size = UDim2.new(0, 28, 0, 28)
			delete_button.BackgroundColor3 = Theme.Accent
			delete_button.BorderSizePixel = 0
			delete_button.Text = "×"
			delete_button.Font = Enum.Font.GothamBold
			delete_button.TextSize = 20
			delete_button.TextColor3 = Theme.Text
			delete_button.AutoButtonColor = false
			delete_button.ZIndex = 2
			delete_button.Parent = favorite_button

			local ui_corner_19 = Instance.new("UICorner")
			ui_corner_19.CornerRadius = UDim.new(0, 6)
			ui_corner_19.Parent = delete_button

			favorite_button.MouseEnter:Connect(function()
				favorite_button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			end)

			favorite_button.MouseLeave:Connect(function()
				favorite_button.BackgroundColor3 = Theme.Dark
				delete_button.BackgroundColor3 = Theme.Accent
			end)

			delete_button.MouseEnter:Connect(function()
				delete_button.BackgroundColor3 = Color3.fromRGB(255, 120, 130)
			end)

			delete_button.MouseLeave:Connect(function()
				delete_button.BackgroundColor3 = Theme.Accent
			end)

			favorite_button.MouseButton1Click:Connect(function()
				self:_apply_avatar(user_id)
			end)

			delete_button.MouseButton1Click:Connect(function()
				self:_remove_favorite(user_id)
				Refresh()
			end)
		end

		scrolling.CanvasSize = UDim2.new(0, 0, 0, list_layout.AbsoluteContentSize.Y + 16)

		list_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scrolling.CanvasSize = UDim2.new(0, 0, 0, list_layout.AbsoluteContentSize.Y + 16)
		end)
	end
	
	local function SwitchTab(Name: string)
		if Name == "Changer" then
			changer_tab.BackgroundColor3 = Theme.Accent
			changer_tab.TextColor3 = Theme.Text
			favorited_tab.BackgroundColor3 = Theme.Dark
			favorited_tab.TextColor3 = Theme.SubText
			customizer_tab.BackgroundColor3 = Theme.Dark
			customizer_tab.TextColor3 = Theme.SubText
			changer.Visible = true
			favorited.Visible = false
			customizer_page.Visible = false
		elseif Name == "Customizer" then
			customizer_tab.BackgroundColor3 = Theme.Accent
			customizer_tab.TextColor3 = Theme.Text
			changer_tab.BackgroundColor3 = Theme.Dark
			changer_tab.TextColor3 = Theme.SubText
			favorited_tab.BackgroundColor3 = Theme.Dark
			favorited_tab.TextColor3 = Theme.SubText
			customizer_page.Visible = true
			favorited.Visible = false
			changer.Visible = false
		else
			favorited_tab.BackgroundColor3 = Theme.Accent
			favorited_tab.TextColor3 = Theme.Text
			changer_tab.BackgroundColor3 = Theme.Dark
			changer_tab.TextColor3 = Theme.SubText
			customizer_tab.BackgroundColor3 = Theme.Dark
			customizer_tab.TextColor3 = Theme.SubText
			favorited.Visible = true
			changer.Visible = false
			customizer_page.Visible = false
			Refresh()
		end
		
		self.current_page = Name
	end
	
	close.MouseEnter:Connect(function()
		close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		close.TextColor3 = Color3.fromRGB(220, 220, 220)
	end)

	close.MouseLeave:Connect(function()
		close.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		close.TextColor3 = Theme.SubText
	end)

	close.MouseButton1Click:Connect(function()
		self:_destroy_ui()
	end)
	
	apply.MouseButton1Click:Connect(function()
		local user_id = tonumber(id.Text)
		if not user_id then return end
		
		self:_apply_avatar(user_id)
	end)
	
	customizer_apply.MouseButton1Click:Connect(function()
		local shirt_id = tonumber(shirt_id_input.Text)
		local pants_id = tonumber(pants_id_input.Text)

		local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		local description = humanoid:GetAppliedDescription()

		if shirt_id and shirt_id > 0 then
			description.Shirt = shirt_id
		end

		if pants_id and pants_id > 0 then
			description.Pants = pants_id
		end

		humanoid:ApplyDescriptionClientServer(description)
	end)

	random.MouseButton1Click:Connect(function()
		local random_id = math.random(10000000, 500000000)
		
		id.Text = tostring(random_id)
		
		self:_apply_avatar(random_id)
	end)

	favorite.MouseButton1Click:Connect(function()
		local user_id = tonumber(id.Text)
		if user_id then
			self:_add_favorite(user_id)
		end
	end)

	reset.MouseButton1Click:Connect(function()
		self:_reset_avatar()
	end)
	
	customizer_reset.MouseButton1Click:Connect(function()
		self:_reset_avatar()
	end)
	
	changer_tab.MouseButton1Click:Connect(function()
		SwitchTab("Changer")
	end)
	
	customizer_tab.MouseButton1Click:Connect(function()
		SwitchTab("Customizer")
	end)

	favorited_tab.MouseButton1Click:Connect(function()
		SwitchTab("Favorited")
	end)
	
	copy.MouseEnter:Connect(function()
		copy.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)

	copy.MouseLeave:Connect(function()
		copy.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end)

	copy.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard("https://discord.com/uxd")
			copy.Text = "Copied!"
			
			task.wait(2)
			
			copy.Text = "Join our Discord!"
		end
	end)
	
	self.Gui = avatar_changer
end

function AvatarChanger:_apply_avatar(UserId: IntValue)
	local character = LocalPlayer.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local success, result = pcall(function()
		local description = Players:GetHumanoidDescriptionFromUserIdAsync(UserId)
		humanoid:ApplyDescriptionClientServer(description)

		task.wait(0.1)

		local animate = character:FindFirstChild("Animate")
		if animate then
			local animate_clone = animate:Clone()
			animate:Destroy()
			animate_clone.Parent = character
		end

		return true
	end)

	if success then
		return true
	else
		return false
	end
end

function AvatarChanger:_reset_avatar()
	return self:_apply_avatar(LocalPlayer.UserId)
end

function AvatarChanger:_add_favorite(UserId: IntValue)
	for i = 1, #self.Favorites do
		if self.Favorites[i] == UserId then
			return false
		end
	end

	table.insert(self.Favorites, UserId)

	self:_save_favorites(self.Favorites)

	return true
end

function AvatarChanger:_remove_favorite(UserId: IntValue)
	for i = 1, #self.Favorites do
		if self.Favorites[i] == UserId then
			table.remove(self.Favorites, i)
			self:_save_favorites(self.Favorites)
			return true
		end
	end

	return false
end

function AvatarChanger:_load_favorites()
	if not isfile(self.FavoritesFile) then return end
	
	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(self.FavoritesFile))
	end)

	if success then
		return data
	end

	return {}
end

function AvatarChanger:_save_favorites(Data: {IntValue})
	writefile(self.FavoritesFile, HttpService:JSONEncode(Data))
end

function AvatarChanger:_dragify(Frame: Instance, Speed: NumberValue)
	local toggle = false
	local start = nil
	local position = nil

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
			toggle = true
			start = input.Position
			position = Frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					toggle = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if not toggle then return end
			
			local delta = input.Position - start
			local new_position = UDim2.new(position.X.Scale, position.X.Offset + delta.X,position.Y.Scale, position.Y.Offset + delta.Y)
			TweenService:Create(Frame, TweenInfo.new(Speed), {Position = new_position}):Play()
		end
	end)
end

function AvatarChanger:_get_username(UserId: IntValue)
	if self.StoredNames[UserId] then
		return self.StoredNames[UserId]
	end

	local success, name = pcall(function()
		return Players:GetNameFromUserIdAsync(UserId)
	end)

	if success and name and name ~= "" then
		self.StoredNames[UserId] = name
		return name
	else
		self.StoredNames[UserId] = nil
		return nil
	end
end

function AvatarChanger:_destroy_ui()
	if not self.Gui then return end

	self.Gui:Destroy()
	self.Gui = nil
end

AvatarChanger.new()

return AvatarChanger
