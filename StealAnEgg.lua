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
		Icon = "align-vertical-distribute-center",
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



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- ANTI-RAGDOLL SYSTEM (Nasa labas na, walang 'do' at 'end')
local antiRagdollConnections = {}
local antiRagdollCharacter, antiRagdollHumanoid, antiRagdollRootPart, antiRagdollAnimator
local lastVelocity = Vector3.new(0, 0, 0)
local velocityChangeThreshold = 40
local velocityMagnitudeThreshold = 25
local maxVelocity = 15

local function isFlyingCarpetActive()
    if not antiRagdollCharacter then return false end
    local tool = antiRagdollCharacter:FindFirstChildWhichIsA("Tool")
    if not tool then return false end
    local hrp = antiRagdollCharacter:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                return true
            end
        end
    end
    return false
end

local function isRagdolled()
    if not antiRagdollHumanoid then return false end
    local state = antiRagdollHumanoid:GetState()
    return state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.GettingUp
end

local function enableAntiRagdollControls()
    pcall(function()
        local PlayerModule = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
        require(PlayerModule):GetControls():Enable()
    end)
end

local function cleanupRagdoll()
    if not antiRagdollCharacter then return end
    local carpetEquipped = isFlyingCarpetActive()

    local function processChildren(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")
                or (obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B")) then
                obj:Destroy()
            elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                if not carpetEquipped then obj:Destroy() end
            elseif obj:IsA("Motor6D") then
                obj.Enabled = true
            elseif obj:IsA("BasePart") then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BallSocketConstraint") or child:IsA("NoCollisionConstraint") or child:IsA("HingeConstraint") or child:IsA("Motor6D") then
                        if child:IsA("Motor6D") then
                            child.Enabled = true
                        else
                            child:Destroy()
                        end
                    elseif child:IsA("Attachment") and (child.Name == "A" or child.Name == "B") then
                        child:Destroy()
                    end
                end
            end
        end
    end

    pcall(function() processChildren(antiRagdollCharacter) end)

    if antiRagdollAnimator then
        for _, track in pairs(antiRagdollAnimator:GetPlayingAnimationTracks()) do
            local animName = track.Animation and track.Animation.Name:lower() or ""
            if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") then
                track:Stop(0)
            end
        end
    end
end

local function setupAntiRagdollCharacter(char)
    antiRagdollCharacter = char
    antiRagdollHumanoid = char:WaitForChild("Humanoid", 10)
    antiRagdollRootPart = char:WaitForChild("HumanoidRootPart", 10)
    antiRagdollAnimator = antiRagdollHumanoid and antiRagdollHumanoid:WaitForChild("Animator", 10)
    lastVelocity = Vector3.new(0, 0, 0)
end

local function clearAntiRagdollConnections()
    for _, c in pairs(antiRagdollConnections) do
        pcall(function() c:Disconnect() end)
    end
    antiRagdollConnections = {}
end

local function setupAntiRagdollConnections()
    clearAntiRagdollConnections()
    if not antiRagdollHumanoid or not antiRagdollRootPart then return end

    table.insert(antiRagdollConnections, antiRagdollHumanoid.StateChanged:Connect(function()
        if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
            if not isFlyingCarpetActive() then
                antiRagdollHumanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            cleanupRagdoll()
            workspace.CurrentCamera.CameraSubject = antiRagdollHumanoid
            enableAntiRagdollControls()
        end
    end))

    pcall(function()
        local impulsePath = ReplicatedStorage:FindFirstChild("Packages")
        if impulsePath then
            impulsePath = impulsePath:FindFirstChild("Net")
            if impulsePath then
                impulsePath = impulsePath:FindFirstChild("RE/CombatService/ApplyImpulse")
                if impulsePath then
                    table.insert(antiRagdollConnections, impulsePath.OnClientEvent:Connect(function()
                        if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
                            antiRagdollRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                    end))
                end
            end
        end
    end)

    table.insert(antiRagdollConnections, antiRagdollCharacter.DescendantAdded:Connect(function()
        if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
            cleanupRagdoll()
        end
    end))

    table.insert(antiRagdollConnections, RunService.Heartbeat:Connect(function()
        if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
            cleanupRagdoll()
            local velocity = antiRagdollRootPart.AssemblyLinearVelocity
            if (velocity - lastVelocity).Magnitude > velocityChangeThreshold
                and velocity.Magnitude > velocityMagnitudeThreshold then
                antiRagdollRootPart.AssemblyLinearVelocity = velocity.Unit * math.min(velocity.Magnitude, maxVelocity)
            end
            lastVelocity = velocity
        end
    end))

    enableAntiRagdollControls()
    cleanupRagdoll()
end

local function startAntiRagdoll()
    _G.AntiRagdollEnabled = true
    _G.antiKnockbackEnabled = true
end

local function stopAntiRagdoll()
    _G.AntiRagdollEnabled = false
    _G.antiKnockbackEnabled = false
    clearAntiRagdollConnections()
end

localPlayer.CharacterAdded:Connect(function(char)
    clearAntiRagdollConnections()
    antiRagdollCharacter = nil; antiRagdollHumanoid = nil; antiRagdollRootPart = nil; antiRagdollAnimator = nil
    local humanoid = char:WaitForChild("Humanoid", 10)
    local rootPart = char:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not rootPart then return end
    task.wait(0.2)
    setupAntiRagdollCharacter(char)
    if _G.AntiRagdollEnabled or _G.antiKnockbackEnabled then
        setupAntiRagdollConnections()
    end
end)

if localPlayer.Character then
    setupAntiRagdollCharacter(localPlayer.Character)
    if _G.AntiRagdollEnabled or _G.antiKnockbackEnabled then
        setupAntiRagdollConnections()
    end
end

-- UI Toggle para sa Anti-Ragdoll (Nasa labas na at handa na para sa Tab mo)
Tabs.MainTab:Toggle({
    Title = "Anti Ragdoll & KnockBack",
    Desc = "Prevents ragdoll and KnockBack",
    Value = false,
    Callback = function(state)
        if state then
            startAntiRagdoll()
            if localPlayer.Character then
                setupAntiRagdollCharacter(localPlayer.Character)
                setupAntiRagdollConnections()
            end
        else
            stopAntiRagdoll()
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
		Icon = "workflow",
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


-- ====================================================================
-- ANTI TRAP TOGGLE
-- ====================================================================
local Workspace = game:GetService("Workspace")

local isAntiTrapActive = false
local antiTrapConnection = nil

Tabs.AutomaticallyTab:Toggle({
    Title = "Anti Trap",
    Desc = "Automatically Remove the Trap",
    Value = false,
    Callback = function(state)
        isAntiTrapActive = state
        
        if state then
            -- ===== [TOGGLE ON] =====
            antiTrapConnection = task.spawn(function()
                while isAntiTrapActive do
                    pcall(function()
                        local debrisFolder = Workspace:FindFirstChild("__DEBRIS")
                        if debrisFolder then
                            debrisFolder:Destroy()
                        end
                    end)
                    -- Maghintay ng kaunting segundo bago mag-scan ulit para maiwasan ang lag
                    task.wait(0.5) 
                end
            end)
        else
            -- ===== [TOGGLE OFF] =====
            isAntiTrapActive = false
            if antiTrapConnection then
                task.cancel(antiTrapConnection)
                antiTrapConnection = nil
            end
        end
    end,
})













-- Misc Section --

local Tabs = {
	MiscTab = Window:Tab({
		Title = "Soon",
		Icon = "eye",
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
		Icon = "shopping-cart",
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
		Icon = "user-round-cog",
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


-- ====================================================================
-- NOCLIP TOGGLE (PLAYER TAB)
-- ====================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local noclipConnection = nil

Tabs.PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls and obstacles",
    Value = false,
    Callback = function(state)
        if state then
            -- ===== [TOGGLE ON] =====
            if noclipConnection then
                noclipConnection:Disconnect()
            end

            noclipConnection = RunService.Stepped:Connect(function()
                local character = player.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- ===== [TOGGLE OFF] =====
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end

            local character = player.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})









-- Settings Section --

local Tabs = {
	SettingTab = Window:Tab({
		Title = "Setting",
		Icon = "cog",
	}),
}

local Keybind = Tabs.SettingTab:Keybind({
    Title = "UI Keybind",
    Desc = "Keybind to open ui",
    Value = "Z", -- Pinalitaning Z ang default key[span_1](start_span)[span_1](end_span)
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])[span_2](start_span)[span_2](end_span)
    end,
})

-- I-lock ito para hindi na mabago ng user
Keybind:Lock()


-- ====================================================================
-- DAYTIME / MORNING TOGGLE (SETTING TAB)
-- ====================================================================
local Lighting = game:GetService("Lighting")

Tabs.SettingTab:Toggle({
    Title = "DayTime/Morning",
    Desc = "Leave to the Darkness",
    Value = false,
    Callback = function(state)
        pcall(function()
            if state then
                -- ===== [TOGGLE ON: Gawing Tanghali] =====
                Lighting.ClockTime = 14
                Lighting.Brightness = 3
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
                Lighting.Ambient = Color3.fromRGB(150, 150, 150)
                Lighting.GlobalShadows = false
                
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("Atmosphere") then
                        child.Density = 0
                        child.Haze = 0
                        child.Color = Color3.fromRGB(255, 255, 255)
                        child.Decay = Color3.fromRGB(255, 255, 255)
                    elseif child:IsA("ColorCorrectionEffect") then
                        child.TintColor = Color3.fromRGB(255, 255, 255)
                        child.Saturation = 0.1
                        child.Contrast = 0.1
                    elseif child:IsA("Sky") then
                        child.StarCount = 0
                    end
                end
            else
                -- ===== [TOGGLE OFF: Ibalik sa Normal/Gabi] =====
                Lighting.ClockTime = 0
                Lighting.Brightness = 1
                Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
                Lighting.Ambient = Color3.fromRGB(70, 70, 70)
                Lighting.GlobalShadows = true
                
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("Atmosphere") then
                        child.Density = 0.35 -- O i-adjust ayon sa default ng laro
                        child.Haze = 0
                        child.Color = Color3.fromRGB(199, 199, 199)
                        child.Decay = Color3.fromRGB(106, 112, 125)
                    elseif child:IsA("ColorCorrectionEffect") then
                        child.TintColor = Color3.fromRGB(255, 255, 255)
                        child.Saturation = 0
                        child.Contrast = 0
                    elseif child:IsA("Sky") then
                        child.StarCount = 3000
                    end
                end
            end
        end)
    end,
})


-- ====================================================================
-- ANTI-LAG / LOW GRAPHICS TOGGLE (WINDUI VERSION)
-- ====================================================================
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local antilagConnection = nil
local originalSettings = {}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end)
end

Tabs.SettingTab:Toggle({
    Title = "Anti-Lag / Low Graphics",
    Desc = "Boosts FPS by disabling shadows, particles, and heavy textures",
    Value = false,
    Callback = function(state)
        if state then
            -- ===== [TOGGLE ON] =====
            

            local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
            if Terrain then
                originalSettings.WaterWaveSize = Terrain.WaterWaveSize
                originalSettings.WaterWaveSpeed = Terrain.WaterWaveSpeed
                originalSettings.WaterReflectance = Terrain.WaterReflectance
                originalSettings.WaterTransparency = Terrain.WaterTransparency
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end

            originalSettings.GlobalShadows = Lighting.GlobalShadows
            originalSettings.FogEnd = Lighting.FogEnd
            originalSettings.FogStart = Lighting.FogStart
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9

            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    originalSettings[v] = {CastShadow = v.CastShadow, Material = v.Material, Reflectance = v.Reflectance}
                    v.CastShadow = false
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") then
                    if originalSettings[v] == nil then originalSettings[v] = v.Transparency end
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    if originalSettings[v] == nil then originalSettings[v] = v.Lifetime end
                    v.Lifetime = NumberRange.new(0)
                end
            end

            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("PostEffect") then
                    originalSettings[v] = v.Enabled
                    v.Enabled = false
                end
            end

            antilagConnection = Workspace.DescendantAdded:Connect(function(child)
                task.spawn(function()
                    if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                        RunService.Heartbeat:Wait()
                        child:Destroy()
                    elseif child:IsA("BasePart") then
                        child.CastShadow = false
                    end
                end)
            end)

            
        else
            -- ===== [TOGGLE OFF] =====
            if antilagConnection then
                antilagConnection:Disconnect()
                antilagConnection = nil
            end

            local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
            if Terrain and originalSettings.WaterTransparency then
                Terrain.WaterWaveSize = originalSettings.WaterWaveSize
                Terrain.WaterWaveSpeed = originalSettings.WaterWaveSpeed
                Terrain.WaterReflectance = originalSettings.WaterReflectance
                Terrain.WaterTransparency = originalSettings.WaterTransparency
            end

            Lighting.GlobalShadows = originalSettings.GlobalShadows ~= nil and originalSettings.GlobalShadows or true
            Lighting.FogEnd = originalSettings.FogEnd ~= nil and originalSettings.FogEnd or 100000
            Lighting.FogStart = originalSettings.FogStart ~= nil and originalSettings.FogStart or 0

            for _, v in pairs(game:GetDescendants()) do
                if originalSettings[v] then
                    if v:IsA("BasePart") then
                        v.CastShadow = originalSettings[v].CastShadow
                        v.Material = originalSettings[v].Material
                        v.Reflectance = originalSettings[v].Reflectance
                    elseif v:IsA("Decal") then
                        v.Transparency = originalSettings[v]
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = originalSettings[v]
                    end
                end
            end

            for _, v in pairs(Lighting:GetDescendants()) do
                if originalSettings[v] ~= nil and v:IsA("PostEffect") then
                    v.Enabled = originalSettings[v]
                end
            end

            originalSettings = {}
            
        end
    end,
})


