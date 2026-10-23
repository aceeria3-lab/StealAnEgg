-- version 12
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


local silenced = {}
if type(getconnections) == "function" then
    local ok, conns = pcall(getconnections, LocalPlayer.Idled)
    if ok and type(conns) == "table" then
        for _, c in ipairs(conns) do
            pcall(function() c:Disable() end)
            silenced[#silenced + 1] = c
        end
    end
end


local dummy = setmetatable({}, { __index = function() return function() end end })
if type(getgc) == "function" and type(debug) == "table" then
    local ok, objects = pcall(getgc, false)
    if ok and type(objects) == "table" then
        for _, fn in ipairs(objects) do
            if type(fn) == "function" and islclosure(fn) then
                local ok2, src = pcall(debug.info, fn, "s")
                if ok2 and type(src) == "string" and string.find(src, "AntiAFK", 1, true) then
                    local ok3, ups = pcall(debug.getupvalues, fn)
                    if ok3 and type(ups) == "table" then
                        for k, v in pairs(ups) do
                            if typeof(v) == "Instance" and v.ClassName == "TeleportService" then
                                pcall(debug.setupvalue, fn, k, dummy)
                            end
                        end
                    end
                end
            end
        end
    end
end



print("Anti-AFK + Bypass ✅")






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

				loadstring(game:HttpGet("https://raw.githubusercontent.com/aceeria3-lab/WINDUIIOHUB/refs/heads/main/dist/main2.lua"))()

		end

	end

end







local Window = WindUI:CreateWindow({

    Title = "IOHUB",

    Folder = "IOHUB",

    Icon = "rbxassetid://139934599708171",

    IconSize = 35,

    

    NewElements = true,

    HideSearchBar = false,



    OpenButton = {

        Title = "IOHUB",

        CornerRadius = UDim.new(1, 0),

        StrokeThickness = 3,

        Enabled = true,

        Draggable = true,

        OnlyMobile = false,

        Scale = 0.8,

        Color = ColorSequence.new(

            Color3.fromHex("#30FF6A"),

            Color3.fromHex("#e7ff2f")

        ),

    },

    Topbar = {

        Height = 44,

        ButtonsType = "Mac",

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
	Flag = "AntiChase",
Value = false,
	Callback = function(state)
		isEnabled = state
	end,
})


Tabs.MainTab:Select()



-- ==================== UI LIBRARY TOGGLE ====================
local isEnabled = false

Tabs.MainTab:Toggle({
	Title = "Instant Prompt",
	Desc = "Make the Prompt Becomes One Tap",
	Flag = "InstantPrompt",
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
    Desc = "Prevents ragdoll and knockback",
   Flag = "AntiRagdoll",
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


  -- ====================================================================
-- ANTI TRAP TOGGLE (WITH WORKSPACE.TRANSIENT)
-- ====================================================================
local Workspace = game:GetService("Workspace")

local isAntiTrapActive = false
local antiTrapConnection = nil

Tabs.MainTab:Toggle({
    Title = "Anti Trap",
    Desc = "Automatically Remove Traps",
    Flag = "AntiTrap",
Value = false,
    Callback = function(state)
        isAntiTrapActive = state
        
        if state then
            -- ===== [TOGGLE ON] =====
            antiTrapConnection = task.spawn(function()
                while isAntiTrapActive do
                    pcall(function()
                        -- Burahin ang __DEBRIS folder kung nandyan
                        local debrisFolder = Workspace:FindFirstChild("__DEBRIS")
                        if debrisFolder then
                            debrisFolder:Destroy()
                        end
                        
                        -- Burahin ang Transient folder kung nandyan
                        local transientFolder = Workspace:FindFirstChild("Transient")
                        if transientFolder then
                            transientFolder:Destroy()
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




-- ====================================================================
local Tabs = {
	EventTab = Window:Tab({
		Title = "Event",
		Icon = "calendar",
	}),
}




-- ====== AUTO RACE TOGGLE (No filtergc, 100% Stable) ======
local isAutoRaceRunning = false 

Tabs.EventTab:Toggle({
    Title = "Auto Hollow Race",
    Desc = "Automatically Race Sequence Start when GO!",
    Default = false,
    Callback = function(isEnabled)
        isAutoRaceRunning = isEnabled

        if isEnabled then
            -- ============================================================
            -- 1. DEPENDENCIES
            -- ============================================================
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local RunService = game:GetService("RunService")
            local CollectionService = game:GetService("CollectionService")
            
            local LocalPlayer = Players.LocalPlayer
            local rs, cl = ReplicatedStorage, CollectionService
            
            local okRemotes, Remotes = pcall(function() return require(rs:WaitForChild("Shared"):WaitForChild("Remotes")) end)
            local okControls, PlayerControls = pcall(function() return require(LocalPlayer.PlayerScripts.PlayerModule):GetControls() end)
            
            local okBaseSpeed, baseTopSpeed = pcall(function() return require(rs.Shared.Flags.MountRaceFlags).TopSpeed:Get() end)
            baseTopSpeed = (okBaseSpeed and type(baseTopSpeed) == "number") and baseTopSpeed or 135

            -- ============================================================
            -- 2. HELPER FUNCTIONS
            -- ============================================================
            local function getCharacterParts()
                local char = LocalPlayer.Character
                return char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
            end

            local function disableAnimations(disabled)
                local char = LocalPlayer.Character
                local anim = char and char:FindFirstChild("Animate")
                if anim and anim:IsA("LocalScript") then anim.Enabled = not disabled end
                if not disabled then return end
                local _, hum = getCharacterParts()
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                for _, track in animator and animator:GetPlayingAnimationTracks() or {} do 
                    pcall(function() track:Stop(0) end) 
                end
            end

            local function getRaceTrack()
                local raceId = LocalPlayer:GetAttribute("RaceId")
                if type(raceId) ~= "string" then return nil end
                for _, track in cl:GetTagged("RaceTrack") do 
                    if track.Name == raceId then return track end 
                end
            end

            local function isCountdownGo()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local ui = pg and pg:FindFirstChild("MountRaceUI")
                local label = ui and ui:FindFirstChild("Countdown")
                if label and label:IsA("TextLabel") and label.Visible then
                    return string.find(string.upper(label.Text), "GO") ~= nil
                end
                return false
            end

            local function setMoveOverride(enabled)
                if not PlayerControls then return end
                if enabled then 
                    PlayerControls.GetMoveVector = function() return State.moveVector or Vector3.zero end
                else 
                    PlayerControls.GetMoveVector = nil 
                end
            end

            -- State table
            local State = {
                speedMultiplier = 3.0,
                moveVector = nil,
                racingActive = false,
                raceStarted = false,
                lastFinishTime = nil
            }

            -- ============================================================
            -- 3. MAIN RACE LOOP (Pure CFrame + Velocity)
            -- ============================================================
            task.spawn(function()
                local currentTrack, trackPath, distanceTraveled, heightOffset, lastUpdateTime = nil, nil, nil, nil, nil
                local lateralOffset, lastFramePosition, currentLap = 0, nil, 0
                local lastLoggedMessage = nil

                local function logOnce(msg) 
                    if msg ~= lastLoggedMessage then lastLoggedMessage = msg print("[AutoRace] " .. msg) end 
                end

                while isAutoRaceRunning do
                    local raceTrack = getRaceTrack()
                    local rootPart = getCharacterParts()
                    local isFinished = type(LocalPlayer:GetAttribute("RaceFinishTime")) == "number"

                    if raceTrack and rootPart and not isFinished then
                        if currentTrack ~= raceTrack then
                            currentTrack = raceTrack
                            State.raceStarted = false 
                            local okPath, pObj = pcall(function() return require(rs.Shared.Modules.RaceTrackPath).new(raceTrack:FindFirstChild("AttachmentTrack")) end)
                            trackPath = (okPath and type(pObj) == "table") and pObj or nil
                            
                            distanceTraveled, lastUpdateTime, lastFramePosition = nil, nil, nil
                            lateralOffset, currentLap = 0, 0
                            logOnce("Waiting for countdown...")
                        end

                        -- HINTAYIN ANG GO!
                        if not State.raceStarted then
                            if isCountdownGo() then
                                State.raceStarted = true
                                lastUpdateTime = os.clock() 
                                logOnce("GO! Starting sequence...")
                            else
                                lastUpdateTime = os.clock()
                                State.moveVector = Vector3.zero
                                RunService.Heartbeat:Wait()
                                continue 
                            end
                        end

                        -- RACE LOGIC
                        local targetSpeed = baseTopSpeed * State.speedMultiplier
                        if trackPath then
                            local now = os.clock()
                            local dt = lastUpdateTime and math.min(now - lastUpdateTime, 0.2) or 0
                            lastUpdateTime = now

                            local stunEndsAt = LocalPlayer:GetAttribute("RacePowerUpStunEndsAt")
                            local isStunned = type(stunEndsAt) == "number" and workspace:GetServerTimeNow() < stunEndsAt

                            local currentFrame
                            if distanceTraveled and not isStunned then
                                distanceTraveled = distanceTraveled + (targetSpeed * dt)
                                currentFrame = trackPath:FrameAt(distanceTraveled)

                                -- Lap 2 Knockback Fix
                                if lastFramePosition and (rootPart.Position - lastFramePosition).Magnitude > 60 then
                                    local lapOffset = math.floor(distanceTraveled / trackPath.Length)
                                    local okProj, newWrapped = pcall(function() return trackPath:Project(rootPart.Position, distanceTraveled % trackPath.Length, 0, trackPath.Length) end)
                                    if okProj and type(newWrapped) == "number" then
                                        distanceTraveled = (lapOffset * trackPath.Length) + newWrapped
                                    else
                                        distanceTraveled = trackPath:Project(rootPart.Position, distanceTraveled, 60, 200)
                                    end
                                    lateralOffset = 0
                                    currentFrame = trackPath:FrameAt(distanceTraveled)
                                end
                            end

                            if not distanceTraveled then
                                distanceTraveled = trackPath:Project(rootPart.Position, 0, 0, trackPath.Length)
                                lateralOffset = 0
                                currentFrame = trackPath:FrameAt(distanceTraveled)
                                heightOffset = (rootPart.Position - currentFrame.Position):Dot(currentFrame.UpVector)
                                if heightOffset < 2 or heightOffset > 30 then heightOffset = 6 end
                            end

                            if isStunned then
                                distanceTraveled = trackPath:Project(rootPart.Position, distanceTraveled, 60, 200)
                                lastFramePosition = nil
                                currentFrame = trackPath:FrameAt(distanceTraveled)
                            end

                            local newLap = math.floor(distanceTraveled / trackPath.Length) + 1
                            if newLap ~= currentLap then currentLap = newLap logOnce("Lap " .. currentLap) end

                            -- DERETSO SA GITNA
                            lateralOffset = lateralOffset + math.clamp(0 - lateralOffset, -100 * dt, 100 * dt)
                            
                            if currentFrame and heightOffset then
                                local targetPos = currentFrame.Position + currentFrame.UpVector * heightOffset + currentFrame.RightVector * lateralOffset
                                State.moveVector = isStunned and Vector3.zero or Vector3.new(0, 0, -1)

                                if not isStunned then
                                    lastFramePosition = targetPos
                                    -- Puro CFrame at Velocity na lang, walang motor
                                    rootPart.CFrame = CFrame.lookAt(targetPos, targetPos + currentFrame.LookVector, currentFrame.UpVector)
                                    rootPart.AssemblyLinearVelocity = currentFrame.LookVector * targetSpeed
                                    rootPart.AssemblyAngularVelocity = Vector3.zero
                                end
                            end

                            if not State.racingActive then 
                                State.racingActive = true 
                                setMoveOverride(true) 
                            end
                        end
                    else
                        -- Kapag wala sa race o tapos na
                        if State.racingActive then
                            State.racingActive = false
                            State.moveVector = nil
                            setMoveOverride(false)
                        end
                        State.raceStarted = false 

                        if raceTrack and isFinished then
                            local finishTime = LocalPlayer:GetAttribute("RaceFinishTime")
                            if State.lastFinishTime ~= finishTime then
                                State.lastFinishTime = finishTime
                                logOnce("Finished | Place " .. tostring(LocalPlayer:GetAttribute("RaceFinishPlace")))
                                task.wait(1.5)
                                local okLeave = pcall(function() Remotes.MountRace.AskLeave:FireServer() end)
                                logOnce(okLeave and "Returning Home" or "Leave Failed")
                            end
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
            end)

        else
            -- ============================================================
            -- 4. CLEANUP (Kapag pinatay ang Toggle)
            -- ============================================================
            print("[AutoRace] Stopped by user.")
            
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            -- Ibalik ang normal na galaw
            local ok, controls = pcall(function() return require(LocalPlayer.PlayerScripts.PlayerModule):GetControls() end)
            if ok and controls then controls.GetMoveVector = nil end
            
            -- Ibalik ang animations
            local char = LocalPlayer.Character
            local anim = char and char:FindFirstChild("Animate")
            if anim and anim:IsA("LocalScript") then anim.Enabled = true end
        end
    end
}) 





-- Automatically Section --

local Tabs = {
	AutomaticallyTab = Window:Tab({
		Title = "Automatically",
		Icon = "workflow",
	}),
}


--[[

-- ====================================================================
-- DISABLE TREADMILL (BLOCK ASGWEARSTILL) TOGGLE (MAIN TAB)
-- ====================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isDisableTreadmillActive = false
local originalNamecall = nil

-- Kunin ang tamang Remote Function para sa AskWearStill
local treadmillWearEvent = ReplicatedStorage:FindFirstChild("Packages")
    and ReplicatedStorage.Packages:FindFirstChild("Networking")
    and ReplicatedStorage.Packages.Networking:FindFirstChild("RF/Treadmill/AskWearStill")

Tabs.AutomaticallyTab:Toggle({
    Title = "Disable Treadmill",
    Desc = "Ignore ThreadMill Trigger Animation",
    Value = false,
    Callback = function(state)
        isDisableTreadmillActive = state

        if state then
            -- ===== [TOGGLE ON: I-block ang AskWearStill] =====
            if not originalNamecall and setmetatable and getrawmetatable then
                local mt = getrawmetatable(game)
                originalNamecall = mt.__namecall
                
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if isDisableTreadmillActive and self == treadmillWearEvent and (method == "InvokeServer" or method == "Invoke") then
                        -- Harangin ang pag-invoke para hindi magtuloy-tuloy ang treadmill state/animation
                        return nil
                    end
                    return originalNamecall(self, ...)
                end)
                setreadonly(mt, true)
            end
        else
            -- ===== [TOGGLE OFF: Ibalik sa dati] =====
            isDisableTreadmillActive = false
            if originalNamecall and setmetatable and getrawmetatable then
                local mt = getrawmetatable(game)
                setreadonly(mt, false)
                mt.__namecall = originalNamecall
                setreadonly(mt, true)
                originalNamecall = nil
            end
        end
    end,
})


-- ]]





local Tabs = {
	PredictorTab = Window:Tab({
		Title = "Egg Predict",
		Icon = "eye",
	}),
}



local TabsRef = (type(Tabs) == "table" and Tabs)
    or (type(_G.Tabs) == "table" and _G.Tabs)
    or (type(getgenv) == "function" and type(getgenv().Tabs) == "table" and getgenv().Tabs)
    or nil

local PredictorTab = TabsRef and (TabsRef.PredictorTab or TabsRef.PredicTab or TabsRef.EggPredict) or nil

if not PredictorTab then
    
    return
end

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer       = Players.LocalPlayer


local COLOR_NAME      = "#FFFFFF"   -- white
local COLOR_MONEY     = "#4DFF7A"   -- green (money/sec)
local COLOR_PLACED    = "#FFD34D"   -- gold (placed)
local COLOR_INVENTORY = "#7FD8FF"   -- cyan (inventory, clickable)


local function tryRequire(inst)
    if not inst then return nil end
    local ok, result = pcall(require, inst)
    return ok and result or nil
end
local function findRS(...)
    local node = ReplicatedStorage
    for i, name in ipairs({...}) do
        node = (i == 1) and node:WaitForChild(name, 10) or (node and node:FindFirstChild(name))
        if not node then return nil end
    end
    return node
end

local Assets     = tryRequire(findRS("Data", "Assets"))
local EggState   = tryRequire(findRS("Client", "EggState"))
local Mutations  = tryRequire(findRS("Shared", "Modules", "Mutations"))

local networking = ReplicatedStorage:FindFirstChild("Packages")
networking = networking and networking:FindFirstChild("Networking") or nil


local function formatMoney(n)
    n = tonumber(n) or 0
    if n >= 1e12 then return string.format("%.2fT", n/1e12) end
    if n >= 1e9  then return string.format("%.2fB", n/1e9)  end
    if n >= 1e6  then return string.format("%.2fM", n/1e6)  end
    if n >= 1000 then return string.format("%.1fK", n/1000) end
    return tostring(math.floor(n))
end
local function scaleFactor(s)
    s = tonumber(s) or 1
    if s > 5 then return (s/5)^1.2 * 19.637875755794113 end
    return s^1.85
end
local function mutationMult(muts)
    muts = type(muts) == "table" and muts or {}
    if Mutations and type(Mutations.EarningsFor) == "function" then
        local ok, r = pcall(Mutations.EarningsFor, muts)
        if ok and type(r) == "number" then return r end
    end
    return 1
end
local function getAssetInfo(category)
    category = tostring(category)
    local dir = Assets and Assets.Directory
    local entry = type(dir) == "table" and dir[category] or nil
    if type(entry) ~= "table" then
        return { Name = category, EarningRate = 0 }
    end
    return {
        Name        = tostring(entry.DisplayName or category),
        EarningRate = tonumber(entry.EarningRate) or 0,
    }
end
local function getIncome(asset, scale, muts)
    return asset.EarningRate * scaleFactor(scale) * mutationMult(muts)
end
local function readInventory()
    if not EggState or type(EggState.ReadOwnerEggs) ~= "function" then return {} end
    local ok, data = pcall(EggState.ReadOwnerEggs, localPlayer.UserId)
    if not ok or type(data) ~= "table" then return {} end
    local list = {}
    for uid, rec in pairs(data) do
        if type(rec) == "table" and rec.AssetCategory then
            local asset = getAssetInfo(rec.AssetCategory)
            local scale = tonumber(rec.AssetScale) or 1
            local muts  = type(rec.Mutations) == "table" and rec.Mutations or {}
            table.insert(list, {
                Uid    = tostring(uid),
                Asset  = asset,
                Scale  = scale,
                Income = getIncome(asset, scale, muts),
                Placed = rec.Placement ~= nil,
            })
        end
    end
    return list
end


local function wearEgg(uid)
    if type(uid) ~= "string" then return false end
    if EggState and type(EggState.WearEggTool) == "function" then
        local ok = pcall(EggState.WearEggTool, uid)
        if ok then return true end
    end
    if networking then
        local rf = networking:FindFirstChild("RF/EggWorld/AskWearTool")
        if rf and rf:IsA("RemoteFunction") then
            local ok = pcall(rf.InvokeServer, rf, uid)
            if ok then return true end
        end
    end
    return false
end


local function addParagraph(parent, opts)
    if type(parent.CreateParagraph) == "function" then return parent:CreateParagraph(opts) end
    if type(parent.Paragraph) == "function"       then return parent:Paragraph(opts)       end
    if type(parent.CreateText) == "function"      then return parent:CreateText(opts)      end
    if type(parent.Text) == "function"            then return parent:Text(opts)            end
    return nil
end
local function addButton(parent, opts)
    if type(parent.CreateButton) == "function" then return parent:CreateButton(opts) end
    if type(parent.Button) == "function"       then return parent:Button(opts)       end
    return nil
end
local function destroyHandle(handle)
    if not handle then return end
    for _, method in ipairs({ "Destroy", "Remove", "Delete" }) do
        if type(handle[method]) == "function" then
            pcall(handle[method], handle)
            return
        end
    end
end


local eggButtons = {}
local lastHash = ""
local MAX_EGGS = 60

local function computeHash(eggs)
    local sorted = {}
    for _, e in ipairs(eggs) do sorted[#sorted+1] = e end
    table.sort(sorted, function(a, b) return a.Uid < b.Uid end)
    local parts = {}
    for _, e in ipairs(sorted) do
        parts[#parts+1] = string.format("%s:%s:%s:%s",
            e.Uid, tostring(e.Scale), tostring(e.Income), tostring(e.Placed))
    end
    return table.concat(parts, "|")
end

local function clearButtons()
    for _, entry in ipairs(eggButtons) do
        destroyHandle(entry.Handle)
    end
    eggButtons = {}
end

local function render(force)
    local eggs = readInventory()
    table.sort(eggs, function(a, b) return a.Income > b.Income end)

    local shown = eggs
    if #eggs > MAX_EGGS then
        shown = {}
        for i = 1, MAX_EGGS do shown[i] = eggs[i] end
    end

    local h = computeHash(shown) .. "|" .. tostring(#eggs)
    if not force and h == lastHash then return end
    lastHash = h

    clearButtons()

    if #eggs == 0 then
        local p = addParagraph(PredictorTab, {
            Title = "No Eggs",
            Content = "Inventory Empty",
        })
        if p then eggButtons[1] = { Handle = p, Uid = nil } end
        return
    end

    for _, egg in ipairs(shown) do
        local state = egg.Placed and "Placed" or "Inventory"
        local stateColor = egg.Placed and COLOR_PLACED or COLOR_INVENTORY


        local title = string.format(
            '<font color="%s">%s</font>  <font color="%s">$%s/s</font>  <font color="%s">%s</font>',
            COLOR_NAME, egg.Asset.Name,
            COLOR_MONEY, formatMoney(egg.Income),
            stateColor, state
        )

        local eggUid   = egg.Uid
        local isPlaced = egg.Placed

        local btn = addButton(PredictorTab, {
            Title    = title,
            RichText = true,
            Callback = function()
                if isPlaced then return end
                wearEgg(eggUid)
            end,
        })

        if btn then

            pcall(function()
                if type(btn.Set) == "function" then
                    btn:Set({ RichText = true, Title = title })
                end
            end)
            eggButtons[#eggButtons + 1] = { Handle = btn, Uid = eggUid }
        end
    end
end


task.spawn(function()
    pcall(render, true)
    while true do
        task.wait(2)
        pcall(render, false)
    end
end)






-- Misc Section --

-- ====================================================================
-- MISC TAB SETUP
-- ====================================================================
local Tabs = {
	MiscTab = Window:Tab({
		Title = "Misc",
		Icon = "layout-grid",
	}),
}

-- ====================================================================
-- RARITY FILTER DROPDOWN
-- ====================================================================
local HARDCODED_RARITIES = {
	"Common", "Uncommon", "Rare", "Epic", "Legendary",
	"Mythic", "Cosmic", "Secret", "Eternal", "Divine",
}

local allowedRarities    = {}
local rarityFilterActive = false

Tabs.MiscTab:Dropdown({
	Title = "Filter by Rarity",
	Desc  = "Show only these rarities (empty = all)",
	Flag = "RarityEggChoose",
Values = HARDCODED_RARITIES,
	Value = {},
	AllowNone = true,
	Multi = true,
	Callback = function(selectedTable)
		allowedRarities = {}
		local any = false

		if type(selectedTable) == "table" then
			for key, value in pairs(selectedTable) do
				local label
				if type(key) == "number" and type(value) == "string" then
					label = value
				elseif type(key) == "string" and value == true then
					label = key
				end
				if label and #label > 0 then
					allowedRarities[label] = true
					any = true
				end
			end
		end

		rarityFilterActive = any
		print("[ESP] Filter active:", any)
	end,
})

-- ====================================================================
-- EGG ESP TOGGLE
-- ====================================================================
local eggEspThread = nil

Tabs.MiscTab:Toggle({
	Title = "ESP Egg",
	Desc  = "Highlights spawned eggs on the map",
	Flag = "EspEgg",
Value = false,
	Callback = function(state)
		local CoreGui           = game:GetService("CoreGui")
		local Players           = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local LocalPlayer       = Players.LocalPlayer

		local function clearAll()
			for _, parent in ipairs({ CoreGui, LocalPlayer:FindFirstChildOfClass("PlayerGui") }) do
				if parent then
					local old = parent:FindFirstChild("StealESP")
					if old then old:Destroy() end
				end
			end
		end

		if state then
			local success, err = pcall(function()
				local eggState   = require(ReplicatedStorage.Client.EggState)
				local assets     = require(ReplicatedStorage.Data.Assets)
				local eggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
				local mutations  = require(ReplicatedStorage.Shared.Modules.Mutations)

				clearAll()
				local ScreenGui = Instance.new("ScreenGui")
				ScreenGui.Name = "StealESP"
				ScreenGui.ResetOnSpawn = false
				ScreenGui.IgnoreGuiInset = true
				ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				ScreenGui.DisplayOrder = 100

				local ok = pcall(function() ScreenGui.Parent = CoreGui end)
				if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

				local ActiveESPs = {}

				-- ═══ RAINBOW (Secret / Eternal / Divine lang) ═══
				local SPECIAL_RARITY_NAMES = {
					["Secret"]  = true,
					["Eternal"] = true,
					["Divine"]  = true,
				}

				local function isSpecialRarity(rarityName)
					return SPECIAL_RARITY_NAMES[tostring(rarityName)] == true
				end

				local rainbowGradients = {}

				local function makeRainbowGradient(parent)
					local gradient = Instance.new("UIGradient")
					gradient.Name = "RainbowFX"
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.071, Color3.fromRGB(255, 128, 0)),
						ColorSequenceKeypoint.new(0.143, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.214, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.286, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.357, Color3.fromRGB(0, 100, 255)),
						ColorSequenceKeypoint.new(0.429, Color3.fromRGB(180, 0, 255)),
						ColorSequenceKeypoint.new(0.500, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.571, Color3.fromRGB(255, 128, 0)),
						ColorSequenceKeypoint.new(0.643, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.714, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.786, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.857, Color3.fromRGB(0, 100, 255)),
						ColorSequenceKeypoint.new(0.929, Color3.fromRGB(180, 0, 255)),
						ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0)),
					})
					gradient.Rotation = 0
					gradient.Offset = Vector2.new(0, 0)
					gradient.Parent = parent
					rainbowGradients[gradient] = { offset = 0 }
					return gradient
				end

				-- ═══ HELPERS ═══
				local function formatNumber(n)
					n = tonumber(n) or 0
					if n >= 1e12 then return string.format("%.2fT", n/1e12) end
					if n >= 1e9 then return string.format("%.2fB", n/1e9) end
					if n >= 1e6 then return string.format("%.2fM", n/1e6) end
					if n >= 1e3 then return string.format("%.1fK", n/1e3) end
					return tostring(math.floor(n))
				end

				-- ✅ FIXED: KG formatting
				--    < 1000      → "497 KG"
				--    < 1,000,000 → "1.8K KG"
				--    >= 1M       → "1.5M KG"
				local function formatWeight(n)
					n = tonumber(n) or 0
					if n >= 1e6 then
						return string.format("%.1fM KG", n / 1e6)
					end
					if n >= 1000 then
						return string.format("%.1fK KG", n / 1000)
					end
					return string.format("%d KG", math.floor(n + 0.5))
				end

				local function getPetInfo(petName)
					if not petName then return nil end
					return assets.Directory[petName]
				end

				local function getWeight(petName, scale)
					local ok, result = pcall(eggRecords.WeightKgForScale, petName, scale)
					if ok and tonumber(result) then return tonumber(result) end
					return 0
				end

				local function getValue(petInfo, scale, muts)
					if not petInfo then return 0 end
					local scaleFactor = scale > 5
						and (scale / 5) ^ 1.2 * 19.637875755794113
						or  scale ^ 1.85
					local mutMult = 1
					local ok, result = pcall(mutations.EarningsFor, muts or {})
					if ok and type(result) == "number" then mutMult = result end
					return (petInfo.EarningRate or 0) * scaleFactor * mutMult
				end

				local function getRarityColor(petInfo)
					if not petInfo or not petInfo.Rarity then
						return Color3.fromRGB(255, 255, 255)
					end
					if typeof(petInfo.Rarity.Color) == "Color3" then
						return petInfo.Rarity.Color
					end
					return Color3.fromRGB(255, 255, 255)
				end

				local function getRarityName(petInfo)
					if not petInfo or type(petInfo.Rarity) ~= "table" then return "?" end
					return petInfo.Rarity.DisplayName or petInfo.Rarity._id or "?"
				end

				-- ✅ Convert Color3 → hex string para sa RichText
				local function colorToHex(c)
					if typeof(c) ~= "Color3" then
						return "#FFD34D"
					end
					local r = math.floor(c.R * 255 + 0.5)
					local g = math.floor(c.G * 255 + 0.5)
					local b = math.floor(c.B * 255 + 0.5)
					return string.format("#%02X%02X%02X", r, g, b)
				end

				-- ═══ BILLBOARD ═══
				local function createBillboard()
					local bb = Instance.new("BillboardGui")
					bb.Name = "StealESP_BB"
					bb.Size = UDim2.new(0, 240, 0, 72)
					bb.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
					bb.AlwaysOnTop = true
					bb.MaxDistance = math.huge
					bb.LightInfluence = 0

					local l1 = Instance.new("TextLabel", bb)
					l1.Name = "L1"
					l1.Size = UDim2.new(1, 0, 0, 24)
					l1.Position = UDim2.new(0, 0, 0, 0)
					l1.BackgroundTransparency = 1
					l1.TextColor3 = Color3.fromRGB(3, 211, 252)
					l1.TextSize = 20
					l1.Font = Enum.Font.GothamBold
					l1.TextStrokeTransparency = 0
					l1.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					l1.Text = "..."

					-- Line 2: Rarity (colored) | KG (GOLD via RichText)
					local l2 = Instance.new("TextLabel", bb)
					l2.Name = "L2"
					l2.Size = UDim2.new(1, 0, 0, 22)
					l2.Position = UDim2.new(0, 0, 0, 24)
					l2.BackgroundTransparency = 1
					l2.TextColor3 = Color3.fromRGB(255, 215, 0)
					l2.TextSize = 17
					l2.Font = Enum.Font.GothamBold
					l2.TextStrokeTransparency = 0
					l2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					l2.RichText = true               -- ✅ Enable RichText
					l2.Text = ""

					local l3 = Instance.new("TextLabel", bb)
					l3.Name = "L3"
					l3.Size = UDim2.new(1, 0, 0, 24)
					l3.Position = UDim2.new(0, 0, 0, 46)
					l3.BackgroundTransparency = 1
					l3.TextColor3 = Color3.fromRGB(100, 255, 100)
					l3.TextSize = 20
					l3.Font = Enum.Font.GothamBold
					l3.TextStrokeTransparency = 0
					l3.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

					return bb
				end

				local function updateBillboard(bb, data)
					if not bb or not bb.Parent then return end

					local l1 = bb:FindFirstChild("L1")
					local l2 = bb:FindFirstChild("L2")
					local l3 = bb:FindFirstChild("L3")

					if l1 then
						l1.Text = data.PetName

						local g = l1:FindFirstChild("RainbowFX")
						if data.IsSpecial then
							if not g then
								makeRainbowGradient(l1)
							end
							l1.TextColor3 = Color3.new(1, 1, 1)
						else
							if g then
								rainbowGradients[g] = nil
								g:Destroy()
							end
							l1.TextColor3 = Color3.fromRGB(3, 211, 252)
						end
					end

					if l2 then
						-- ✅ Rarity color + KG gold (RichText)
						local rarityHex = colorToHex(data.Color or Color3.fromRGB(255, 215, 0))
						l2.Text = string.format(
							'<font color="%s">%s</font> <font color="#FFD34D">| %s</font>',
							rarityHex,
							string.upper(data.Rarity),
							formatWeight(data.Weight)
						)
					end

					if l3 then
						l3.Text = "$" .. formatNumber(data.Value) .. "/s"
					end
				end

				local function positionBillboard(entry, bottomCFrame)
					if not entry or not entry.Billboard then return end
					if not entry.Billboard.Parent then return end
					if typeof(bottomCFrame) ~= "CFrame" then return end

					local bb = entry.Billboard
					bb.Adornee = workspace.Terrain
					bb.StudsOffsetWorldSpace = bottomCFrame.Position - workspace.Terrain.Position + Vector3.new(0, 5, 0)
				end

				-- ═══ SCAN FIELD EGGS ═══
				local function scanFieldEggs()
					local ok, result = pcall(eggState.ReadFieldEggs)
					if not ok then return end
					if type(result) ~= "table" then return end

					local records = result.Records
					if type(records) ~= "table" then return end

					local seen = {}
					local count = 0

					for uid, record in pairs(records) do
						if type(record) == "table" and record.State ~= "Claimed" then
							local petName = record.AssetCategory
							local petInfo = getPetInfo(petName)

							if petInfo and typeof(record.BottomCFrame) == "CFrame" then
								local rarityName = getRarityName(petInfo)

								local passes = true
								if rarityFilterActive then
									passes = allowedRarities[rarityName] == true
								end

								if passes then
									seen[uid] = true
									count = count + 1

									if not ActiveESPs[uid] then
										local bb = createBillboard()
										bb.Parent = ScreenGui
										ActiveESPs[uid] = { Billboard = bb }
									end

									local entry = ActiveESPs[uid]
									local scale = tonumber(record.AssetScale) or 1

									updateBillboard(entry.Billboard, {
										PetName   = petInfo.DisplayName or petName,
										Rarity    = rarityName,
										Color     = getRarityColor(petInfo),
										Weight    = getWeight(petName, scale),
										Value     = getValue(petInfo, scale, record.Mutations),
										IsSpecial = isSpecialRarity(rarityName),
									})

									positionBillboard(entry, record.BottomCFrame)
								end
							end
						end
					end

					for uid, entry in pairs(ActiveESPs) do
						if not seen[uid] then
							if entry.Billboard and entry.Billboard.Parent then
								local l1 = entry.Billboard:FindFirstChild("L1")
								if l1 then
									local g = l1:FindFirstChild("RainbowFX")
									if g then rainbowGradients[g] = nil end
								end
								entry.Billboard:Destroy()
							end
							ActiveESPs[uid] = nil
						end
					end

					return count
				end

				-- ═══ RAINBOW ANIMATION ═══
				task.spawn(function()
					while true do
						task.wait(0.03)
						for gradient, config in pairs(rainbowGradients) do
							if gradient and gradient.Parent then
								config.offset = config.offset + 0.008
								if config.offset >= 0.5 then
									config.offset = 0
								end
								gradient.Offset = Vector2.new(config.offset, 0)
							else
								rainbowGradients[gradient] = nil
							end
						end
					end
				end)

				-- ═══ MAIN ESP LOOP ═══
				eggEspThread = task.spawn(function()
					while true do
						pcall(scanFieldEggs)
						task.wait(1)
					end
				end)

				
			end)

			if not success then
				
			end
		else
			if eggEspThread then
				pcall(task.cancel, eggEspThread)
				eggEspThread = nil
			end
			clearAll()
			
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
   Flag = "AntiLag",
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


Tabs.SettingTab:Space()

--------------------------------------------------

-- CONFIG MANAGER (Auto-load sa start)

--------------------------------------------------

local ConfigManager = Window.ConfigManager

local CONFIG_NAME = "IOHUB_StealAnEggV2"  -- ⬅️ fixed name



local function getConfig()

    return ConfigManager:CreateConfig(CONFIG_NAME)

end



-- ====== SAVE BUTTON ======

Tabs.SettingTab:Button({

    Title = "Save Config",

    Desc = "Save current settings",

    Callback = function()

        local cfg = getConfig()



        if cfg:Save() then

            WindUI:Notify({

                Title = "Config Saved",

                Content = "Settings saved as '" .. CONFIG_NAME .. "'",

                Icon = "solar:check-circle-bold",

                Duration = 3,

            })

        else

            WindUI:Notify({

                Title = "Save Failed",

                Content = "Failed to Save.",

                Icon = "solar:danger-bold",

                Duration = 3,

            })

        end

    end,

})



-- ====== DELETE BUTTON ======

Tabs.SettingTab:Button({

    Title = "Delete Config",

    Desc = "Delete the saved config",

    Callback = function()

        local cfg = getConfig()



        if cfg:Delete() then

            WindUI:Notify({

                Title = "Config Deleted",

                Content = "'" .. CONFIG_NAME .. "' has been deleted!",

                Icon = "solar:trash-bin-trash-bold",

                Duration = 3,

            })

        else

            WindUI:Notify({

                Title = "Delete Failed",

                Content = "Config Not Found '" .. CONFIG_NAME .. "'",

                Icon = "solar:danger-bold",

                Duration = 3,

            })

        end

    end,

})



-- ====== AUTO-LOAD SA START (system-level, walang toggle) ======

task.spawn(function()

    task.wait(0.5)

    pcall(function()

        local cfg = getConfig()

        cfg:Load()

    end)

end)





-- ====================================================================
-- SERVER TAB SETUP
-- ====================================================================
if not Window then return end

local Tabs = {
	ServerTab = Window:Tab({
		Title = "Servers",
		Icon  = "globe",
	}),
}

if not Tabs.ServerTab then return end

-- ═══ SHARED STATE (accessible sa both dropdown + toggle) ═══
local DISPLAY_COUNT  = 1         -- default
local forceRefresh   = false      -- para trigger re-render pag nag-change yung count

-- ====================================================================
-- ✅ COUNT DROPDOWN (nasa TAAS ng toggle)
-- ====================================================================
Tabs.ServerTab:Dropdown({
	Title = "Servers to Show",
	Desc  = "How many servers to display in the list",
	Values = { "1", "5", "10" },
	Value  = "1",                -- default
	Multi  = false,
	AllowNone = false,
	Callback = function(selected)
		local count
		if type(selected) == "table" then
			-- Pwedeng array o lookup table
			for k, v in pairs(selected) do
				if type(v) == "string" and tonumber(v) then
					count = tonumber(v)
					break
				elseif type(k) == "string" and v == true and tonumber(k) then
					count = tonumber(k)
					break
				end
			end
		elseif type(selected) == "string" then
			count = tonumber(selected)
		elseif type(selected) == "number" then
			count = selected
		end

		if count and count > 0 then
			DISPLAY_COUNT = count
			forceRefresh = true          -- ✅ trigger re-render agad
			
		end
	end,
})

-- ====================================================================
-- LIVE SERVER LIST TOGGLE
-- ====================================================================
local toggleHandle = nil
local fetchThread  = nil
local renderThread = nil

toggleHandle = Tabs.ServerTab:Toggle({
	Title = "Live Server List",
	Desc  = "Auto-Refresh every 1s Click to Hop.",
	Value = true,
	Callback = function(state)
		-- ═══ SERVICES ═══
		local HttpService     = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local Players         = game:GetService("Players")
		local LocalPlayer     = Players.LocalPlayer

		-- ═══ CONFIG ═══
		local COLOR_PLAYERS  = "#7FD8FF"
		local COLOR_ROOM     = "#4DFF7A"
		local COLOR_FULL     = "#FF6B6B"
		local COLOR_ID       = "#FFD34D"
		local FETCH_INTERVAL = 1         -- seconds
		local RENDER_TICK    = 0.5       -- seconds
		local EXCLUDE_FULL   = true

		-- ═══ HELPERS ═══
		local function formatId(id)
			if type(id) ~= "string" then return "?" end
			if #id <= 12 then return id end
			return id:sub(1, 8) .. "..." .. id:sub(-4)
		end

		local function formatRoom(n)
			n = tonumber(n) or 0
			if n >= 1000 then return string.format("%.1fK", n/1000) end
			return tostring(n)
		end

		local function destroyHandle(handle)
			if not handle then return end
			for _, m in ipairs({ "Destroy", "Remove", "Delete" }) do
				if type(handle[m]) == "function" then
					pcall(handle[m], handle)
					return
				end
			end
		end

		-- ═══ STATE (local to callback) ═══
		local serverList    = {}
		local serverButtons = {}
		local currentJobId  = tostring(game.JobId or "")
		local lastHash      = ""
		local isFetching    = false
		local stopSignal    = false
		local lastCount     = DISPLAY_COUNT

		-- ═══ FETCH ═══
		local function fetchServers()
			if isFetching then return end
			isFetching = true

			local url = string.format(
				"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100",
				game.PlaceId
			)

			local ok, body = pcall(function() return game:HttpGet(url) end)
			if not ok or type(body) ~= "string" or body == "" then
				isFetching = false
				return
			end

			local ok2, decoded = pcall(function() return HttpService:JSONDecode(body) end)
			if not ok2 or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
				isFetching = false
				return
			end

			local list = {}
			for _, s in ipairs(decoded.data) do
				local id      = tostring(s.id or "")
				local playing = tonumber(s.playing) or 0
				local maxP    = tonumber(s.maxPlayers) or 0
				local room    = maxP - playing
				local isFull  = playing >= maxP

				if id ~= "" and id ~= currentJobId then
					if not EXCLUDE_FULL or not isFull then
						table.insert(list, {
							Id = id,
							Playing = playing,
							MaxP = maxP,
							Room = room,
							IsFull = isFull,
						})
					end
				end
			end

			table.sort(list, function(a, b)
				if a.Playing ~= b.Playing then return a.Playing < b.Playing end
				return a.Room > b.Room
			end)

			serverList = list
			isFetching = false
		end

		-- ═══ HOP ═══
		local function hopTo(jobId)
			if type(jobId) ~= "string" or jobId == "" then return end
			print("[SRV] Hopping to:", jobId)
			pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
			end)
		end

		-- ═══ RENDER ═══
		local function computeHash(list)
			local parts = {}
			for _, s in ipairs(list) do
				parts[#parts+1] = string.format("%s:%d", s.Id, s.Playing)
			end
			return table.concat(parts, "|")
		end

		local function clearButtons()
			for _, entry in ipairs(serverButtons) do
				destroyHandle(entry.Handle)
			end
			serverButtons = {}
		end

		local function render(force)
			local list = serverList

			-- ✅ Use current DISPLAY_COUNT (dynamic)
			local shown = list
			if #list > DISPLAY_COUNT then
				shown = {}
				for i = 1, DISPLAY_COUNT do shown[i] = list[i] end
			end

			-- ✅ Hash includes DISPLAY_COUNT para mag-trigger ng rebuild pag nag-change
			local h = computeHash(shown) .. "|" .. tostring(#list) .. "|" .. tostring(DISPLAY_COUNT)
			if not force and h == lastHash then return end
			lastHash = h

			clearButtons()

			for i, s in ipairs(shown) do
				local roomText, roomColor
				if s.IsFull then
					roomText = "FULL"
					roomColor = COLOR_FULL
				else
					roomText = formatRoom(s.Room) .. " slots"
					roomColor = COLOR_ROOM
				end

				local title = string.format(
					'<font color="%s">👥 %d/%d</font>  <font color="%s">%s</font>  <font color="%s">%s</font>',
					COLOR_PLAYERS, s.Playing, s.MaxP,
					roomColor, roomText,
					COLOR_ID, formatId(s.Id)
				)

				local jobId = s.Id

				local btn = Tabs.ServerTab:Button({
					Title = title,
					Callback = function()
						hopTo(jobId)
					end,
				})

				if btn then
					pcall(function()
						if type(btn.Set) == "function" then
							btn:Set({ RichText = true, Title = title })
						end
					end)
					serverButtons[#serverButtons + 1] = { Handle = btn, Id = jobId }
				end
			end
		end

		-- ═══ TOGGLE ON ═══
		if state then
			stopSignal = false

			-- Initial fetch
			fetchServers()

			-- Fetch thread (every FETCH_INTERVAL seconds)
			fetchThread = task.spawn(function()
				while not stopSignal do
					pcall(fetchServers)

					local elapsed = 0
					while elapsed < FETCH_INTERVAL and not stopSignal do
						task.wait(0.25)
						elapsed = elapsed + 0.25
					end
				end
			end)

			-- Render thread (every RENDER_TICK seconds)
			renderThread = task.spawn(function()
				-- Initial render
				task.wait(1.5)
				pcall(render, true)

				while not stopSignal do
					-- ✅ Check kung may pending force refresh (from dropdown)
					if forceRefresh then
						forceRefresh = false
						pcall(render, true)
					else
						pcall(render, false)
					end

					task.wait(RENDER_TICK)
				end
			end)

		-- ═══ TOGGLE OFF ═══
		else
			stopSignal = true

			if fetchThread then
				pcall(task.cancel, fetchThread)
				fetchThread = nil
			end
			if renderThread then
				pcall(task.cancel, renderThread)
				renderThread = nil
			end

			clearButtons()
			serverList = {}
			lastHash = ""

			print("[SRV] Cleared")
		end
	end,
})

-- ═══ AUTO-START ═══
task.spawn(function()
	task.wait(0.3)
	if toggleHandle and type(toggleHandle.Set) == "function" then
		pcall(function() toggleHandle:Set(true) end)
	end
end)




 	
-- ====================================================================
-- WINDUI TABS SETUP
-- ====================================================================
local Tabs = {
	ChatTab = Window:Tab({
		Title = "Global Chat",
		Icon  = "message-square", 
	}),
}

if not Tabs.ChatTab then return end

--[[ GLOBAL CHAT SCRIPT (PROFILE POPUP WITH CLOSE) ]]
local P = game:GetService("Players")
local H = game:GetService("HttpService")
local TS = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local L = P.LocalPlayer

local GameName = "Unknown Game"
task.spawn(function()
	local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
	if ok and info and info.Name then GameName = info.Name end
end)

local I = { 	
	info="rbxassetid://124560466474914", 	
	reply="rbxassetid://109788633497028", 	
	send="rbxassetid://127751956873796", 	
	x="rbxassetid://110786993356448", 	
	minus="rbxassetid://118026365011536", 	
	hash="rbxassetid://82890331678520", 	
	shield="rbxassetid://110987169760162", 	
	["message-square"]="rbxassetid://83881670383280", 	
	user="rbxassetid://81589895647169", 
}

local C = { 	
	DB="https://global-chat-bb7ef-default-rtdb.asia-southeast1.firebasedatabase.app", 	
	Poll=1.5, 	
	Max=180, 	
	History=40, 	
	Cool=1.2, 	
	PresTTL=20, 
}

local S = { 	
	Main=nil, Input=nil, List=nil, Status=nil, ReplyBar=nil, ReplyLabel=nil, 	
	Msgs={}, Seen={}, LastCount=0, LastSend=0, Order=0, 	
	Alive=false, Mode="global", PrivTarget=nil, Online={}, DMList={}, ReplyTo=nil,
	OnlineCount = 1
}

local function Req() 	
	if type(request)=="function" then return request end 	
	if type(http_request)=="function" then return http_request end 	
	if type(syn)=="table" and type(syn.request)=="function" then return syn.request end 	
	if type(fluxus)=="table" and type(fluxus.request)=="function" then return fluxus.request end 	
	local ok,g=pcall(function() return type(getgenv)=="function" and getgenv() or nil end) 	
	if ok and type(g)=="table" then 		
		if type(g.request)=="function" then return g.request end 		
		if type(g.http_request)=="function" then return g.http_request end 	
	end 	
	return nil 
end 

local RQ = Req() 

local function Http(o) 	
	if not RQ then return nil, "no request" end 	
	local ok,r=pcall(RQ,o) 	
	if not ok or type(r)~="table" then return nil, tostring(r) end 	
	local s=tonumber(r.StatusCode or r.Status or r.status_code or r.status) 	
	local b=tostring(r.Body or r.body or r.Data or r.data or "") 	
	local suc=r.Success; if suc==nil then suc=r.success end 	
	if suc==false then return nil, "fail" end 	
	if s and s~=0 and (s<200 or s>=300) then return nil, "HTTP "..tostring(s) end 	
	return b 
end 

local function Enc(v) 	
	local ok,r=pcall(H.JSONEncode,H,v) 	
	return ok and r or "{}" 
end 

local function Dec(v) 	
	local ok,r=pcall(H.JSONDecode,H,v) 	
	return ok and r or nil 
end 

local function Url(v) return H:UrlEncode(tostring(v)) end 

local function Tw(o,t,p) 	
	return TS:Create(o,TweenInfo.new(t or 0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p) 
end 

local function AddBorder(obj,ic,oc,it,ot) 	
	local o=Instance.new("UIStroke") 	
	o.Name="OuterStroke" 	
	o.Color=oc or Color3.fromRGB(88,101,242) 	
	o.Thickness=ot or 1.5 	
	o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border 	
	o.Parent=obj 	
	local i=Instance.new("UIStroke") 	
	i.Name="InnerStroke" 	
	i.Color=ic or Color3.fromRGB(0,0,0) 	
	i.Thickness=it or 1 	
	i.ApplyStrokeMode=Enum.ApplyStrokeMode.Border 	
	i.Parent=obj 	
	return o 
end 

local function BindBorder(btn,baseT,hoverT,clickT) 	
	baseT=baseT or 1.5; hoverT=hoverT or 2.4; clickT=clickT or 3 	
	local outer=btn:FindFirstChild("OuterStroke") 	
	if not outer then return end 	
	btn.MouseEnter:Connect(function() Tw(outer,0.1,{Thickness=hoverT}):Play() end) 	
	btn.MouseLeave:Connect(function() Tw(outer,0.1,{Thickness=baseT}):Play() end) 	
	btn.MouseButton1Down:Connect(function() Tw(outer,0.08,{Thickness=clickT}):Play() end) 	
	btn.MouseButton1Up:Connect(function() Tw(outer,0.08,{Thickness=hoverT}):Play() end) 
end 

local function RelTime(ts) 	
	local t=tonumber(ts) or 0 	
	if t>1e12 then t=math.floor(t/1000) end 	
	local d=os.time()-t 	
	if d<60 then return "just now" 	
	elseif d<3600 then return math.floor(d/60).."m" 	
	elseif d<86400 then return math.floor(d/3600).."h" 	
	else return os.date("%m/%d",t) end 
end 

local function fmtName(dn,un) 	
	dn,un=tostring(dn or "?"),tostring(un or "?") 	
	if dn:lower()==un:lower() then return dn end 	
	return dn.." (@"..un..")" 
end 

function S:_base() return C.DB:gsub("/+$","") end 

function S:_o(t,p) 	
	local o=Instance.new(t[1]) 	
	for k,v in pairs(t[2] or {}) do o[k]=v end 	
	o.Parent=p 	
	return o 
end 

function S:_ico(name,size,col) 	
	local img=Instance.new("ImageLabel") 	
	img.BackgroundTransparency=1 	
	img.Size=UDim2.fromOffset(size or 14,size or 14) 	
	img.Image=I[name] or "" 	
	img.ImageColor3=col or Color3.new(1,1,1) 	
	img.ScaleType=Enum.ScaleType.Fit 	
	return img 
end 

function S:_notice(t,c) 	
	if not self.Status then return end 	
	self.Status.Text=t 	
	self.Status.TextColor3=c or Color3.fromRGB(160,165,175) 	
	local s=os.clock() 	
	self._ns=s 	
	task.delay(2,function() 		
		if self.Alive and self._ns==s and self.Status then 			
			self.Status.Text="● Active Now ("..(self.OnlineCount or 1)..")" 			
			self.Status.TextColor3=Color3.new(1,1,1) 		
		end 	
	end) 
end 

function S:_bottom() 	
	task.defer(function() 		
		if self.List then 			
			self.List.CanvasPosition=Vector2.new(0,math.max(0,self.List.AbsoluteCanvasSize.Y-self.List.AbsoluteWindowSize.Y)) 		
		end 	
	end) 
end 

function S:_isBottom() 	
	if not self.List then return true end 	
	local m=math.max(0,self.List.AbsoluteCanvasSize.Y-self.List.AbsoluteWindowSize.Y) 	
	return m-self.List.CanvasPosition.Y<70 
end 

function S:SetReply(d) 	
	self.ReplyTo=d 	
	if self.ReplyBar and self.ReplyLabel then 		
		if d then 			
			self.ReplyBar.Visible=true 			
			self.ReplyLabel.Text="Reply: @"..(d.Username or d.username or "?") 		
		else 			
			self.ReplyBar.Visible=false 		
		end 	
	end 
end 

function S:NewMessage(d) 	
	if not self.Alive or not self.List then return end 	
	if type(d)~="table" then return end 	
	local id=tostring(d.Id or d.id or d._key or "") 	
	local uid=tonumber(d.UserId or d.userId or d.userId or 0) or 0 	
	local un=tostring(d.Username or d.username or d.sender or "?") 	
	local raw=tostring(d.Text or d.text or d.msg or "") 	
	local ts=tonumber(d.timestamp or d.time or 0) or 0 	
	local gName=tostring(d.gameName or d.GameName or "Unknown Game")
	local msgPlaceId=d.PlaceId or d.placeId
	local msgJobId=d.JobId or d.jobId
	
	if #raw>C.Max then raw=raw:sub(1,C.Max).."…" end 	
	
	local fp=tostring(uid).."|"..tostring(ts).."|"..raw:sub(1,40) 	
	if (id~="" and self.Seen[id]) or self.Seen[fp] then 		
		if id~="" then self.Seen[id]=true end 		
		self.Seen[fp]=true 		
		return 	
	end 	
	if id~="" then self.Seen[id]=true end 	
	self.Seen[fp]=true 	
	local stick=self:_isBottom() 	
	self.Order=self.Order+1 	
	local mine=(uid==L.UserId) or (un:lower()==L.Name:lower()) 	
	
	local wrap=self:_o({"Frame",{ 		
		Size=UDim2.new(1,-2,0,0),AutomaticSize=Enum.AutomaticSize.Y, 		
		BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=self.Order 	
	}},self.List) 	
	
	local row=self:_o({"Frame",{ 		
		Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y, 		
		BackgroundColor3=mine and Color3.fromRGB(44,46,56) or Color3.fromRGB(40,42,47), 		
		BorderSizePixel=0 	
	}},wrap) 	
	self:_o({"UICorner",{CornerRadius=UDim.new(0,6)}},row) 	
	local stroke=Instance.new("UIStroke") 	
	stroke.Color=mine and Color3.fromRGB(88,101,242) or Color3.fromRGB(55,58,65) 	
	stroke.Thickness=1 	
	stroke.Transparency=mine and 0.55 or 0.4 	
	stroke.Parent=row 	
	self:_o({"UIPadding",{ 		
		PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6), 		
		PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6) 	
	}},row) 	
	self:_o({"UIListLayout",{ 		
		FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder 	
	}},row) 	
	
	local lo=0 	
	if d.replyUser or d.replyText then 		
		lo=lo+1 		
		local rq=self:_o({"Frame",{ 			
			Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y, 			
			BackgroundColor3=Color3.fromRGB(48,50,56),BorderSizePixel=0,LayoutOrder=lo 		
		}},row) 		
		self:_o({"UICorner",{CornerRadius=UDim.new(0,4)}},rq) 		
		self:_o({"UIPadding",{ 			
			PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,3), 			
			PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,4) 		
		}},rq) 		
		self:_o({"TextLabel",{ 			
			Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1, 			
			Text=tostring(d.replyUser or "?").."\n"..tostring(d.replyText or ""):sub(1,50), 			
			TextColor3=Color3.fromRGB(160,170,190),Font=Enum.Font.Gotham,TextSize=10, 			
			TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left 		
		}},rq) 	
	end 	
	
	lo=lo+1
	local mainContainer = self:_o({"Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=lo}},row)
	self:_o({"UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Top}},mainContainer)

	-- PLAYER ICON
	local av = self:_o({"ImageButton",{ 		
		Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(47,49,54),BorderSizePixel=0,Image="",LayoutOrder=1,
        AutoButtonColor=false
	}},mainContainer) 	
	self:_o({"UICorner",{CornerRadius=UDim.new(1,0)}},av) 	
	if uid>0 then 		
		task.spawn(function() 			
			local ok,url=pcall(P.GetUserThumbnailAsync,P,uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) 			
			if ok and url and av.Parent then av.Image=url end 		
		end) 	
	end

    -- ⚠️ PROFILE POPUP (MAY CLOSE BUTTON NA)
    local function OpenProfilePopup()
        local placeIdText = msgPlaceId and tostring(msgPlaceId) or "Not Available"
        local jobIdText = msgJobId and tostring(msgJobId) or "Not Available"
        
        local profileContent = string.format(
            "Name: @%s\nGame: %s\nPlace ID: %s\nJob ID: %s",
            un, gName, placeIdText, jobIdText
        )

        local dialog -- Declare muna natin para magamit sa loob ng Callback
        
        dialog = Window:Dialog({
            Title = "Player Profile",
            Content = profileContent,
            Icon = "user",
            Buttons = {
                {
                    Title = "Join Game",
                    Icon = "log-in",
                    Variant = "Primary",
                    Callback = function()
                        if msgPlaceId and msgJobId and jobIdText ~= "Not Available" then
                            local success, err = pcall(function()
                                TeleportService:TeleportToPlaceInstance(tonumber(msgPlaceId), tostring(msgJobId), L)
                            end)
                            if not success then
                                Window:Notify({Title = "Teleport Failed", Content = "Executor blocked the teleport.", Icon = "alert-triangle"})
                            end
                        elseif msgPlaceId then
                            local success, err = pcall(function()
                                TeleportService:Teleport(tonumber(msgPlaceId), L)
                            end)
                            if not success then
                                Window:Notify({Title = "Teleport Failed", Content = "Could not join the game.", Icon = "alert-triangle"})
                            end
                        else
                            Window:Notify({Title = "Cannot Join", Content = "This message is old.", Icon = "alert-triangle"})
                        end
                    end
                },
                {
                    Title = "Close",
                    Icon = "x",
                    Variant = "Secondary", -- Kulay gray/puti para pang-close
                    Callback = function()
                        dialog:Close() -- Ito yung magsasara sa popup
                    end
                }
            }
        })
    end

    -- Click listener sa avatar
    av.MouseButton1Click:Connect(OpenProfilePopup)

	-- CONTENT COLUMN
	local contentColumn = self:_o({"Frame",{Size=UDim2.new(1,-44,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2}},mainContainer)
	self:_o({"UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder}},contentColumn)

	-- HEADER ROW
	local headerRow = self:_o({"Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=1}},contentColumn)
	local leftHeader = self:_o({"Frame",{Size=UDim2.new(1,-50,1,0),BackgroundTransparency=1}},headerRow)
	self:_o({"UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center}},leftHeader)

	-- Username Gradient
	local userLabel = self:_o({"TextButton",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="@"..un,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,LayoutOrder=1}},leftHeader)
	local uGrad = Instance.new("UIGradient")
	uGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 100))} 
	uGrad.Parent = userLabel
	
    -- Click listener sa username
    userLabel.MouseButton1Click:Connect(OpenProfilePopup)

	-- Divider
	self:_o({"TextLabel",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="|",TextColor3=Color3.fromRGB(150,150,150),Font=Enum.Font.Gotham,TextSize=13,LayoutOrder=2}},leftHeader)

	-- Game Name Gradient
	local gameLabel = self:_o({"TextLabel",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=gName,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,LayoutOrder=3,TextTruncate=Enum.TextTruncate.AtEnd}},leftHeader)
	local gGrad = Instance.new("UIGradient")
	gGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))} 
	gGrad.Parent = gameLabel

	-- Right Header (Time & Reply)
	local rightHeader = self:_o({"Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(50,22),BackgroundTransparency=1}},headerRow)
	self:_o({"UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center}},rightHeader)

	-- Reply Button
	local replyBtn = self:_o({"ImageButton",{Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,Image=I.reply,ImageColor3=Color3.fromRGB(130,135,145),AutoButtonColor=false,LayoutOrder=1}},rightHeader)
	replyBtn.MouseButton1Click:Connect(function() self:SetReply({Id=id,Username=un,DisplayName=un,Text=raw,UserId=uid}) end)
	replyBtn.MouseEnter:Connect(function() replyBtn.ImageColor3=Color3.fromRGB(88,150,255) end)
	replyBtn.MouseLeave:Connect(function() replyBtn.ImageColor3=Color3.fromRGB(130,135,145) end)

	-- Time
	self:_o({"TextLabel",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=RelTime(ts),TextColor3=Color3.fromRGB(120,125,135),Font=Enum.Font.Gotham,TextSize=10,LayoutOrder=2}},rightHeader)

	-- MESSAGE TEXT (BOLD + STROKE)
	local txt=self:_o({"TextLabel",{ 		
		Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1, 		
		Text=raw,TextColor3=Color3.fromRGB(235,235,235),Font=Enum.Font.GothamBold,TextSize=14,
		TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2 	
	}},contentColumn) 	
	local chatStroke = Instance.new("UIStroke")
	chatStroke.Color = Color3.fromRGB(0, 0, 0)
	chatStroke.Thickness = 1.2
	chatStroke.Transparency = 0.3
	chatStroke.Parent = txt
	
	self.Msgs[#self.Msgs+1]=wrap 	
	while #self.Msgs>C.History+8 do 		
		local old=table.remove(self.Msgs,1) 		
		if old then pcall(function() old:Destroy() end) end 	
	end 	
	if stick then self:_bottom() end 
end 

function S:Clear() 	
	for i=#self.Msgs,1,-1 do 		
		local x=self.Msgs[i] 		
		if x then pcall(function() x:Destroy() end) end 		
		self.Msgs[i]=nil 	
	end 	
	for k in pairs(self.Seen) do self.Seen[k]=nil end 	
	self.LastCount=0 	
	self.Order=0 	
	self:SetReply(nil) 
end 

function S:_loadChat(full) 	
	local path=self:_base().."/public_chat.json"
	local body,err=Http({Url=path,Method="GET",Headers={["Content-Type"]="application/json"}}) 	
	if not body or body=="" or body=="null" then return end 	
	local data=Dec(body) 	
	if type(data)~="table" then return end 	
	local list={} 	
	for k,v in pairs(data) do 		
		if type(v)=="table" then 			
			v._key=tostring(k) 			
			v.Id=tostring(k) 			
			if not v.Text and v.msg then v.Text=v.msg end 			
			if not v.Username and v.sender then v.Username=v.sender end 			
			if not v.UserId and v.userId then v.UserId=v.userId end 			
			if not v.timestamp and v.time then v.timestamp=v.time end 			
			list[#list+1]=v 		
		end 	
	end 	
	table.sort(list,function(a,b) 		
		return (tonumber(a.timestamp or a.time) or 0)<(tonumber(b.timestamp or b.time) or 0) 	
	end) 	
	
	if #list>C.History then 		
		local sliced={} 		
		for i=#list-C.History+1,#list do sliced[#sliced+1]=list[i] end 		
		list=sliced 	
	end 	
	
	if full then 		
		for _,v in ipairs(list) do self:NewMessage(v) end 		
		self.LastCount=#list 		
		self:_bottom() 	
	else 		
		if #list>self.LastCount then 			
			for i=self.LastCount+1,#list do 				
				self:NewMessage(list[i]) 			
			end 			
			self.LastCount=#list 		
		elseif #list<self.LastCount then 			
			self:Clear() 			
			for _,v in ipairs(list) do self:NewMessage(v) end 			
			self.LastCount=#list 		
		end 	
	end 
end 

function S:Send(text) 	
	if os.clock()-self.LastSend<C.Cool then return false end 	
	text=tostring(text==nil and (self.Input and self.Input.Text or "") or text or "") 	
	text=text:gsub("\r",""):gsub("\0",""):gsub("^%s+",""):gsub("%s+$","") 	
	if text=="" then 		
		self:_notice("Type something",Color3.fromRGB(237,66,69)) 		
		return false 	
	end 	
	if #text>C.Max then 		
		text=text:sub(1,C.Max) 		
		self:_notice("Trimmed to "..C.Max,Color3.fromRGB(250,200,80)) 	
	end 	
	self.LastSend=os.clock() 	
	if self.Input then self.Input.Text="" end 	
	
	local body={ 		
		sender=L.Name, 		
		Username=L.Name, 		
		DisplayName=L.DisplayName, 		
		msg=text, 		
		Text=text, 		
		userId=L.UserId, 		
		UserId=L.UserId, 		
		time=os.time(), 		
		timestamp=os.time(),
		gameName=GameName,
		JobId=game.JobId,     
		PlaceId=game.PlaceId  
	} 	
	if self.ReplyTo then 		
		body.replyUser=fmtName(self.ReplyTo.DisplayName,self.ReplyTo.Username) 		
		body.replyText=tostring(self.ReplyTo.Text or ""):sub(1,40) 		
		body.replyTo=self.ReplyTo.Id 	
	end 	
	
	local path=self:_base().."/public_chat.json" 	
	local ok=false 	
	local res=select(1,Http({ 		
		Url=path, 		
		Method="POST", 		
		Headers={["Content-Type"]="application/json"}, 		
		Body=Enc(body), 	
	})) 	
	if res then ok=true end 	
	
	if not ok then 		
		local id=tostring(L.UserId).."_"..tostring(os.time()).."_"..tostring(math.random(10000,99999)) 		
		res=select(1,Http({ 			
			Url=path:gsub("%.json$","").."/"..Url(id)..".json", 			
			Method="PUT", 			
			Headers={["Content-Type"]="application/json"}, 			
			Body=Enc(body), 		
		})) 		
		ok=res~=nil 	
	end 	
	if not ok then 		
		self:_notice("Send failed",Color3.fromRGB(237,66,69)) 		
		return false 	
	end 	
	
	self:NewMessage(body) 	
	self.LastCount=self.LastCount+1 	
	self:SetReply(nil) 	
	return true 
end 

function S:_presence() 	
	pcall(function() 		
		Http({ 			
			Url=self:_base().."/presence/"..Url(tostring(L.UserId))..".json", 			
			Method="PUT", 			
			Headers={["Content-Type"]="application/json"}, 			
			Body=Enc({t=os.time(),n=L.Name,d=L.DisplayName}), 		
		}) 	
	end) 
end 

function S:_cleanIfAlone() 	
	local body=select(1,Http({Url=self:_base().."/presence.json",Method="GET",Headers={["Content-Type"]="application/json"}})) 	
	if not body or body=="" or body=="null" then 		
		pcall(function() Http({Url=self:_base().."/public_chat.json",Method="DELETE"}) end) 		
		self:Clear() 		
		return true 	
	end 	
	local d=Dec(body) 	
	if type(d)~="table" then return false end 	
	local now,any=os.time(),false 	
	self.Online={} 	
	local onlineCount = 1 
	
	for uid,v in pairs(d) do 		
		if type(v)=="table" and tonumber(v.t) and (now-tonumber(v.t))<=C.PresTTL then 			
			any=true 			
			if tostring(uid)~=tostring(L.UserId) then 				
				self.Online[tostring(uid)]={n=tostring(v.n or "?"),d=tostring(v.d or v.n or "?"),t=v.t} 			
				onlineCount = onlineCount + 1 
			end 		
		end 	
	end 	
	
	self.OnlineCount = onlineCount 
	
	if self.Status then
		self.Status.Text = "● Active Now ("..onlineCount..")"
		self.Status.TextColor3 = Color3.new(1,1,1)
	end
	
	if not any then 		
		pcall(function() Http({Url=self:_base().."/public_chat.json",Method="DELETE"}) end) 		
		self:Clear() 		
		return true 	
	end 	
	return false 
end 

function S:Destroy() 	
	self.Alive=false 	
	pcall(function() 		
		Http({Url=self:_base().."/presence/"..Url(tostring(L.UserId))..".json",Method="DELETE"}) 	
	end) 	
	task.wait(0.3) 	
	pcall(function() 		
		local body=select(1,Http({Url=self:_base().."/presence.json",Method="GET",Headers={["Content-Type"]="application/json"}})) 		
		local alone=true 		
		if body and body~="" and body~="null" then 			
			local d=Dec(body) 			
			if type(d)=="table" then 				
				local now=os.time() 				
				for uid,v in pairs(d) do 					
					if type(v)=="table" and tonumber(v.t) and (now-tonumber(v.t))<=C.PresTTL and tostring(uid)~=tostring(L.UserId) then 						
						alone=false 						
						break 					
					end 				
				end 			
			end 		
		end 		
		if alone then 			
			Http({Url=self:_base().."/public_chat.json",Method="DELETE"}) 		
		end 	
	end) 	
	if self.Main then pcall(function() self.Main:Destroy() end) end 	
	self.Main=nil 
end 

function S:Init() 	
	if self.Alive and self.Main then return self end 	
	self:Destroy() 	
	self.Alive=true 	
	
	local container = Tabs.ChatTab.ContainerFrame
	local old = container:FindFirstChild("GlobalChatEmbedded")
	if old then old:Destroy() end
	
	local main=self:_o({"Frame",{ 		
		Name="GlobalChatEmbedded",
		Size=UDim2.new(1,-10,1,-10), 
		Position=UDim2.new(0,5,0,5),
		BackgroundColor3=Color3.fromRGB(30,31,34),BorderSizePixel=0,ClipsDescendants=true 	
	}},container) 	
	self.Main=main 	
	self:_o({"UICorner",{CornerRadius=UDim.new(0,8)}},main) 	
	AddBorder(main,Color3.fromRGB(0,0,0),Color3.fromRGB(60,65,75),1,1.5) 	
	
	local top=self:_o({"Frame",{ 		
		Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,40), 		
		BackgroundColor3=Color3.fromRGB(40,42,48),BorderSizePixel=0 	
	}},main) 	
	self:_o({"Frame",{Position=UDim2.new(0,0,1,-6),Size=UDim2.new(1,0,0,6),BackgroundColor3=Color3.fromRGB(40,42,48),BorderSizePixel=0}},top) 	
	
	-- ACTIVE NOW LABEL (Gradient, Malaki)
	local state=self:_o({"TextLabel",{ 		
		Position=UDim2.fromOffset(12,10),Size=UDim2.new(1,-24,0,20),BackgroundTransparency=1, 		
		Text="● Active Now (1)",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left 	
	}},top) 	
	local statusGrad = Instance.new("UIGradient")
	statusGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),   
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)), 
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 255))  
	}
	statusGrad.Parent = state
	self.Status = state
	
	local list=self:_o({"ScrollingFrame",{ 		
		Position=UDim2.new(0,4,0,44),Size=UDim2.new(1,-8,1,-112), 		
		BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3, 		
		ScrollBarImageColor3=Color3.fromRGB(80,82,88),AutomaticCanvasSize=Enum.AutomaticSize.Y, 		
		CanvasSize=UDim2.fromScale(0,0),ScrollingDirection=Enum.ScrollingDirection.Y,ClipsDescendants=true 	
	}},main) 	
	self.List=list 	
	self:_o({"UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)}},list) 	
	self:_o({"UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder}},list) 	
	
	local replyBar=self:_o({"Frame",{ 		
		AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,-52),Size=UDim2.new(1,0,0,22), 		
		BackgroundColor3=Color3.fromRGB(42,45,55),BorderSizePixel=0,Visible=false 	
	}},main) 	
	self.ReplyBar=replyBar 	
	local rI=self:_ico("reply",11,Color3.fromRGB(88,150,255)) 	
	rI.Position=UDim2.fromOffset(6,5) 	
	rI.Parent=replyBar 	
	local rLab=self:_o({"TextLabel",{ 		
		Position=UDim2.fromOffset(22,2),Size=UDim2.new(1,-48,1,-4),BackgroundTransparency=1,Text="", 		
		TextColor3=Color3.fromRGB(170,180,200),Font=Enum.Font.Gotham,TextSize=10, 		
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd 	
	}},replyBar) 	
	self.ReplyLabel=rLab 	
	local rX=self:_o({"ImageButton",{ 		
		AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-4,0.5,0),Size=UDim2.fromOffset(16,16), 		
		BackgroundTransparency=1,Image=I.x,ImageColor3=Color3.fromRGB(180,90,90),AutoButtonColor=false 	
	}},replyBar) 	
	rX.MouseButton1Click:Connect(function() self:SetReply(nil) end) 	
	
	local bottom=self:_o({"Frame",{ 		
		AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,48), 		
		BackgroundColor3=Color3.fromRGB(40,42,48),BorderSizePixel=0 	
	}},main) 	
	self:_o({"Frame",{Size=UDim2.new(1,0,0,6),BackgroundColor3=Color3.fromRGB(40,42,48),BorderSizePixel=0}},bottom) 	
	local input=self:_o({"TextBox",{ 		
		Position=UDim2.fromOffset(6,8),Size=UDim2.new(1,-78,0,30),BackgroundColor3=Color3.fromRGB(50,53,60), 		
		BorderSizePixel=0,ClearTextOnFocus=false,MultiLine=false,Text="",PlaceholderText="Message...", 		
		PlaceholderColor3=Color3.fromRGB(120,125,135),TextColor3=Color3.fromRGB(230,232,235), 		
		Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center 	
	}},bottom) 	
	self.Input=input 	
	self:_o({"UICorner",{CornerRadius=UDim.new(0,6)}},input) 	
	self:_o({"UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,6)}},input) 	
	AddBorder(input,Color3.fromRGB(0,0,0),Color3.fromRGB(60,65,75),1,1.2) 	
	
	local send=self:_o({"ImageButton",{ 		
		AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,8),Size=UDim2.fromOffset(60,30), 		
		BackgroundColor3=Color3.fromRGB(88,101,242),BorderSizePixel=0,Image=I.send,ImageColor3=Color3.new(1,1,1), 		
		ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false 	
	}},bottom) 	
	self.SendBtn=send 	
	self:_o({"UICorner",{CornerRadius=UDim.new(0,6)}},send) 	
	AddBorder(send,Color3.fromRGB(0,0,0),Color3.fromRGB(120,140,255),1,1.4) 	
	BindBorder(send,1.4,2.2,2.8) 	
	send.MouseButton1Click:Connect(function() self:Send() end) 	
	input.FocusLost:Connect(function(e) if e then self:Send() end end) 	
	input.MouseEnter:Connect(function() self:_bottom() end)
	
	task.spawn(function() 		
		self:_presence() 		
		local alone=self:_cleanIfAlone() 		
		pcall(function() self:_loadChat(true) end) 		
		self:_notice(alone and "● Fresh" or "● Connected",Color3.fromRGB(87,242,135)) 		
		local tick=0 		
		while self.Alive and self.Main and self.Main.Parent do 			
			tick=tick+1 			
			if tick%3==0 then 				
				self:_presence() 				
				self:_cleanIfAlone() 			
			end 			
			pcall(function() self:_loadChat(false) end) 			
			task.wait(C.Poll) 		
		end 	
	end) 	
	return self 
end 

-- SERVER FULL HANDLER
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage, placeId, teleportOptions)
    if player == L then
        if teleportResult == Enum.TeleportResult.GameFull then
            Window:Notify({
                Title = "Server Is Full",
                Content = "Cannot join the server. Please try again later.",
                Icon = "alert-triangle",
                Duration = 5
            })
        elseif teleportResult == Enum.TeleportResult.Fail then
            Window:Notify({
                Title = "Teleport Failed",
                Content = tostring(errorMessage),
                Icon = "x-circle"
            })
        end
    end
end)

-- AUTO START
task.spawn(function()
	task.wait(0.5)
	S:Init()
end) 
