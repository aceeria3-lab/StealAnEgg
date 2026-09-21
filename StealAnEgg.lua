local RunService = game:GetService("RunService")

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if cloneref(game:GetService("RunService")):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI =
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end


function createPopup()
	return WindUI:Popup({
		Title = "Welcome to the WindUI!",
		Icon = "bird",
		Content = "Hello!",
		Buttons = {
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
		},
	})
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
	Title = "IOHUB",
	--Author = "by .ftgs â€¢ Footagesus",
	Folder = "ftgshub",
	Icon = "solar:folder-2-bold-duotone",
	--Theme = "Mellowsi",
	--IconSize = 22*2,
	NewElements = true,
	--Size = UDim2.fromOffset(700,700),

	HideSearchBar = false,

	OpenButton = {
		Title = "IOHUB", -- can be changed
		CornerRadius = UDim.new(1, 0), -- fully rounded
		StrokeThickness = 3, -- removing outline
		Enabled = true, -- enable or disable openbutton
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,

		Color = ColorSequence.new( -- gradient
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Mac", -- Default or Mac
	},
})



-- */  Tags  /* --
do
	Window:Tag({
		Title = "v" .. WindUI.Version,
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

-- */  Colors  /* --
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")



-- Main Section --

local Tabs = {
	MainTab = Window:Tab({
		Title = "Main",
		Icon = "bird",
	}),
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- Coordinates
local SPOT_1_SAFE   = CFrame.new(500.6, 70.3, -366.7)
local SPOT_2        = CFrame.new(546.8, 70.3, -364.4)

-- Speeds
local INSTANT_SPEED = 9999   
local SLIDE_SPEED   = 600    

local currentSavedCFrame = nil
local isEnabled = false
local isExecuting = false

local function updateCamera(character)
	if character and character:FindFirstChild("Humanoid") then
		camera.CameraSubject = character.Humanoid
	end
end

-- Improved move function
local function moveTo(targetCFrame, speed)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	updateCamera(char)
	humanoid.PlatformStand = true

	local startCFrame = hrp.CFrame
	local distance = (startCFrame.Position - targetCFrame.Position).Magnitude
	local duration = math.clamp(distance / speed, 0.01, 0.35)

	local elapsed = 0
	while elapsed < duration do
		local dt = RunService.Heartbeat:Wait()
		elapsed = elapsed + dt
		local alpha = math.clamp(elapsed / duration, 0, 1)

		if hrp and hrp.Parent then
			hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		else
			break
		end
	end

	if hrp and hrp.Parent then
		hrp.CFrame = targetCFrame
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end

	if humanoid and humanoid.Parent then
		humanoid.PlatformStand = false
	end
end

local function isGuiActive(gui)
	if not gui then return false end
	if gui:IsA("ScreenGui") or gui:IsA("LayerCollector") then
		return gui.Enabled
	elseif gui:IsA("GuiObject") then
		return gui.Visible
	end
	return false
end

-- Main Loop (Background Task)
task.spawn(function()
	while true do
		task.wait(0.15)
		if isEnabled and not isExecuting then
			local dropEggGui = playerGui:FindFirstChild("DropHeldEgg")

			if isGuiActive(dropEggGui) then
				isExecuting = true

				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")

				if hrp then
					currentSavedCFrame = hrp.CFrame
					moveTo(SPOT_1_SAFE, INSTANT_SPEED)
					moveTo(SPOT_2, SLIDE_SPEED)
					task.wait(0.9)
					moveTo(currentSavedCFrame, INSTANT_SPEED)
					updateCamera(char)
				end

				while isGuiActive(dropEggGui) do
					task.wait(0.4)
				end

				task.wait(0.8)
				isExecuting = false
			end
		end
	end
end)



-- ==================== UI LIBRARY TOGGLE ====================
Tabs.MainTab:Toggle({
	Title = "Anti Chase",
	Desc = "Bugged the Egg Guardian (Sometimes Not Work)",
	Value = false,
	Callback = function(state)
		isEnabled = state
	end,
})



-- ==================== UI LIBRARY TOGGLE ====================
local isEnabled = false

Tabs.MainTab:Toggle({
	Title = "Instant Prompt",
	Desc = "Make the Prompt Becomes One Tap",
	Value = false,
	Callback = function(state)
		isEnabled = state
		
		-- Function para baguhin ang hold duration ng mga prompt
		local function updatePrompts()
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					if isEnabled then
						-- Ginagawa itong 0 para ma-tap agad nang walang hintayan
						descendant.HoldDuration = 0
					else
						-- Pwede mong ibalik sa default (halimbawa ay 0.5 o kung ano man ang orig)
						-- O kaya ay hayaan na lang kung may sarili silang duration
					end
				end
			end
		end

		updatePrompts()
		
		-- Opsyonal: Para ma-detect din ang mga bagong mag-a-appear na prompt sa laro
		if isEnabled then
			workspace.DescendantAdded:Connect(function(descendant)
				if isEnabled and descendant:IsA("ProximityPrompt") then
					descendant.HoldDuration = 0
				end
			end)
		end
	end,
})








-- this is for auto select tab 
-- when script is loaded if not
-- the right panel is empty
task.defer(function()
	Tabs.MainTab:Select()
end)





-- Automatically Section --

local Tabs = {
	AutomaticallyTab = Window:Tab({
		Title = "Automatically",
		Icon = "bird",
	}),
}

-- ==================== ANTI TREADMILL TOGGLE ====================
Tabs.AutomaticallyTab:Toggle({
	Title = "Auto Leave Treadmill",
	Desc = "Automatically asks to doff treadmill",
	Value = false,
	Callback = function(state)
		if state then
			-- Pwedeng lagyan ng loop o kaya isang beses lang i-trigger depende sa gusto mo.
			-- Kung gusto mo na paulit-ulit habang naka-on:
			_G.AntiTreadmillActive = true
			task.spawn(function()
				while _G.AntiTreadmillActive do
					local success, err = pcall(function()
						local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Packages"):FindFirstChild("Networking"):FindFirstChild("RF/Treadmill/AskDoff")
						if Event then
							Event:InvokeServer()
						end
					end)
					task.wait(0.001) -- Pwedeng baguhin ang interval kung gaano kadalas i-invoke
				end
			end)
		else
			_G.AntiTreadmillActive = false
		end
	end,
})


-- Misc Section --

local Tabs = {
	MiscTab = Window:Tab({
		Title = "Soon",
		Icon = "bird",
	}),
}

Tabs.MiscTab:Toggle({
	Title = "Esp Eggs",
	Desc = "Show Highlights to Eggs",
	Value = false,
	Callback = function(state)

	featureEnabled = state
		
	end,
})

-- Shop Section --

local Tabs = {
	ShopTab = Window:Tab({
		Title = "Soon",
		Icon = "bird",
	}),
}

Tabs.ShopTab:Toggle({
	Title = "Auto Buy Carrot",
	Desc = "Automatically Buy Carrots",
	Value = false,
	Callback = function(state)

	featureEnabled = state
		
	end,
})


-- Player Section --

local Tabs = {
	PlayerTab = Window:Tab({
		Title = "Player",
		Icon = "bird",
	}),
}


-- ====================================================================
-- PLAYER ESP TOGGLE (UPDATED WITH DISTANCE & CLEAN UI)
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerEspConnection = nil
local renderConnection = nil
local activeBillboards = {}

Tabs.PlayerTab:Toggle({
	Title = "Player ESP",
	Desc = "Highlights other players with distance info",
	Value = false,
	Callback = function(state)
		-- Function para tanggalin ang lahat ng ESP
		local function clearESP()
			if playerEspConnection then
				playerEspConnection:Disconnect()
				playerEspConnection = nil
			end
			if renderConnection then
				renderConnection:Disconnect()
				renderConnection = nil
			end

			-- Linisin ang highlights at billboards
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character then
					local hl = p.Character:FindFirstChild("PlayerEspHighlight")
					if hl then hl:Destroy() end
				end
			end

			for _, gui in pairs(activeBillboards) do
				if gui then gui:Destroy() end
			end
			activeBillboards = {}
		end

		if state then
			-- ===== [TOGGLE ON] =====
			local function setupPlayerESP(targetPlayer)
				if targetPlayer == localPlayer then return end
				
				local function addESP(char)
					if not char then return end
					local tagIdentifier = "PlayerESP_" .. targetPlayer.Name
					
					-- Tanggalin kung meron na mang nakaraang instance
					if CoreGui:FindFirstChild(tagIdentifier) then
						CoreGui[tagIdentifier]:Destroy()
					end

					-- Highlight para sa buong katawan
					local highlight = char:FindFirstChild("PlayerEspHighlight")
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "PlayerEspHighlight"
						highlight.FillColor = Color3.fromRGB(255, 50, 50) -- Reddish tone
						highlight.FillTransparency = 0.5
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						highlight.OutlineTransparency = 0
						highlight.Parent = char
					end

					-- BillboardGui para sa Name + Studs sa ibabaw ng ulo
					local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
					if head then
						local billboard = Instance.new("BillboardGui")
						billboard.Name = tagIdentifier
						billboard.Size = UDim2.new(0, 200, 0, 40)
						billboard.AlwaysOnTop = true
						billboard.ExtentsOffset = Vector3.new(0, 2.8, 0)
						billboard.Adornee = head
						billboard.Parent = CoreGui
						
						local label = Instance.new("TextLabel")
						label.Name = "InfoLabel"
						label.Size = UDim2.new(1, 0, 1, 0)
						label.BackgroundTransparency = 1
						label.TextColor3 = Color3.fromRGB(255, 255, 255)
						label.TextSize = 13
						label.Font = Enum.Font.GothamBold
						label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						label.TextStrokeTransparency = 0.3
						label.Parent = billboard

						activeBillboards[targetPlayer.Name] = {Gui = billboard, Label = label, TargetChar = char}
					end
				end

				if targetPlayer.Character then
					addESP(targetPlayer.Character)
				end
				
				targetPlayer.CharacterAdded:Connect(function(char)
					if state then
						task.wait(1)
						addESP(char)
					end
				end)
			end

			for _, p in ipairs(Players:GetPlayers()) do
				setupPlayerESP(p)
			end

			playerEspConnection = Players.PlayerAdded:Connect(function(p)
				setupPlayerESP(p)
			end)

			-- Realtime update para sa Studs (Distance) at Smooth rendering
			renderConnection = RunService.RenderStepped:Connect(function()
				local localChar = localPlayer.Character
				local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

				for name, data in pairs(activeBillboards) do
					local char = data.TargetChar
					local label = data.Label
					local gui = data.Gui

					if char and char:FindFirstChild("HumanoidRootPart") and localHrp then
						local hrp = char.HumanoidRootPart
						local distance = math.floor((hrp.Position - localHrp.Position).Magnitude)
						label.Text = string.format("%s | %d studs", name, distance)
					else
						if gui then gui.Enabled = false end
					end
				end
			end)

		else
			-- ===== [TOGGLE OFF] =====
			clearESP()
		end
	end,
})







