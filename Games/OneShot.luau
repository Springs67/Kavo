local GuiLibrary = shared.GuiLibrary

local inputService: UserInputService = cloneref(game:GetService('UserInputService'))
local runService: RunService = cloneref(game:GetService('RunService'))
local players: Players = cloneref(game:GetService('Players'))

local lplr: Player = players.LocalPlayer
local gameCamera = workspace.CurrentCamera

local isAlive = function(v)
    v = v or lplr

    return v.Character and v.Character.PrimaryPart and v.Character:FindFirstChild('Humanoid') and v.Character:FindFirstChild('Humanoid').Health > 0
end

local getNearestToMouse = function()
    local Nearest, Distance = nil, math.huge;

    for _, value in players:GetPlayers() do
        if not isAlive(value) then
            continue;
        end;

        local screenPos, onScreen = gameCamera:WorldToViewportPoint(value.Character.PrimaryPart.Position)

        if onScreen and screenPos.Z > 0 then
            local playerPos = Vector2.new(screenPos.X, screenPos.Y)

            local distance = (inputService:GetMouseLocation() - playerPos).Magnitude

            if distance < Distance then
                Distance = distance
                Nearest = value;
            end
        end
    end

    for _, value in workspace.bots:GetChildren() do
        local screenPos, onScreen = gameCamera:WorldToViewportPoint(value.PrimaryPart.Position)

        if onScreen and screenPos.Z > 0 then
            local playerPos = Vector2.new(screenPos.X, screenPos.Y)

            local distance = (inputService:GetMouseLocation() - playerPos).Magnitude

            if distance < Distance then
                Distance = distance
                Nearest = value;
            end
        end
    end

    return Nearest;
end

local OneShot = {
    WeaponController = require(game:GetService("ReplicatedStorage").client.controllers.WeaponController),
    WeaponConfig = require(game:GetService("ReplicatedStorage").shared.data.weapons.WeaponConfig),
    WeaponData = require(game:GetService("ReplicatedStorage").shared.data.weapons.WeaponData),

    CurrencyDropController = require(game:GetService("ReplicatedStorage").client.controllers.CurrencyDropController),

    FlyController = require(game:GetService("ReplicatedStorage").client.controllers.FlyController),

    GameStateController = require(game:GetService("ReplicatedStorage").client.controllers.GameStateController),

    zap = require(game:GetService("ReplicatedStorage").client.zap)
}

local silentAimEnabled = false
GuiLibrary.Tabs.Combat:NewToggle('Silent Aim', 'Hits the enemy when you arent aiming at them.', function(state)
    silentAimEnabled = state
end)

local triggerEnabled = false
local noCooldownEnabled = false
GuiLibrary.Tabs.Combat:NewToggle('Trigger Bot', 'Automatically shoots the enemies in your crosshair', function(state)
    triggerEnabled = state
    if state then
        OneShot.WeaponConfig.auto_shoot_max_range = 9e9

        repeat
            task.wait()
            if not OneShot.GameStateController.is_in_game then
                continue
            end

            if OneShot.WeaponController:has_target_in_crosshair() then
                OneShot.WeaponController:request_fire()
                task.wait(noCooldownEnabled and 0.85 or 1.1)
            end
        until not triggerEnabled
    else
        OneShot.WeaponConfig.auto_shoot_max_range = 120
    end
end)

local oldReloadDur = {}
GuiLibrary.Tabs.Combat:NewToggle('Fast Reload Cooldown', 'Removes the reload cooldown', function(state)
    noCooldownEnabled = state
    if state then
        for index, value in OneShot.WeaponData do
            oldReloadDur[index] = value.weapon_stats.reload_duration
            value.weapon_stats.reload_duration = 0.85
        end
    else
        for index, value in OneShot.WeaponData do
            value.weapon_stats.reload_duration = oldReloadDur[index]
        end
    end
end)

local autoCollectEnabled = false
GuiLibrary.Tabs.Player:NewToggle('Auto Collect Drops', 'Automatically collects the drops around the map', function(state)
    autoCollectEnabled = state

    if state then
        repeat
            task.wait(0.5)
            if not OneShot.GameStateController.is_in_game then
                continue
            end

            for index, value in OneShot.CurrencyDropController.active_drops do
                OneShot.CurrencyDropController:collect_drop(index, value)
            end
        until not autoCollectEnabled
    end
end)

local flyEnabled = false
GuiLibrary.Tabs.Movement:NewKeybind('Fly', 'Allows you to fly around the map, could end in detections.', Enum.KeyCode.R, function(state)
    flyEnabled = not flyEnabled

    OneShot.FlyController:set_fly(flyEnabled)
end)

local disablerEnabled = false
--[[GuiLibrary.Tabs.Misc:NewToggle('Disabler', 'Disables the movement checks.', function(state)
    disablerEnabled = state
end)]]

--[[local autoVoteEnabled = false
GuiLibrary.Tabs.Misc:NewToggle('Auto Vote', 'Automatically Votes for your map of choosing.', function(state)
    autoVoteEnabled = state

    if state then
        repeat
            task.wait(0.5)
            if not OneShot.GameStateController.is_in_game then
                continue
            end


        until not autoVoteEnabled
    end
end)]]

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {lplr.Character}

local isGrounded = function()
    local raycast: RaycastResult = workspace:Raycast(lplr.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), rayParams)

    if raycast and raycast.Instance then
        return true
    end

    return false
end

local canSee = function(model: Model)
    local rayParams2 = RaycastParams.new()
    rayParams2.FilterType = Enum.RaycastFilterType.Include
    rayParams2.FilterDescendantsInstances = {model, workspace.Lobby}

    local rayCast = workspace:Raycast(lplr.Character.PrimaryPart.CFrame.Position, (lplr.Character.PrimaryPart.CFrame.Position - model.PrimaryPart.CFrame.Position).Unit * 9e9, rayParams2)

    return not rayCast
end

local lastGrounded = tick()
runService:BindToRenderStep('Actions', 0, function(dt: number)
    if not isAlive() then
        return
    end

    if isGrounded() then
        lastGrounded = tick()
    end

    if disablerEnabled then
        if (tick() - lastGrounded) < 2 then
            return
        end

        lastGrounded = tick()

        local raycast: RaycastResult = workspace:Raycast(lplr.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -1000, 0), rayParams)

        if raycast and raycast.Instance and raycast.Instance.CanCollide then -- why is ts so AIDS;
            local oldY = lplr.Character.PrimaryPart.CFrame.Y
            lplr.Character.PrimaryPart.CFrame = CFrame.new(lplr.Character.PrimaryPart.CFrame.X, raycast.Position + Vector3.new(0, lplr.Character.Humanoid.HipHeight / 2, 0), lplr.Character.PrimaryPart.CFrame.Z)
            task.wait(0.3)
            lplr.Character.PrimaryPart.CFrame = CFrame.new(lplr.Character.PrimaryPart.CFrame.X, oldY, lplr.Character.PrimaryPart.CFrame.Z)
        end
    end
end)

lplr.CharacterAdded:Connect(function(character)
    character:WaitForChild('HumanoidRootPart')
    character:WaitForChild('Humanoid')

    rayParams.FilterDescendantsInstances = {character}

    OneShot.FlyController:set_fly(false)

    if flyEnabled then
        OneShot.FlyController:set_fly(true)
    end
end)

local old; old = hookfunction(OneShot.zap.shoot.fire, function(data)
    if silentAimEnabled and not data.target then
        local nearest = getNearestToMouse()

        if nearest then
            if nearest:IsA('Model') then
                return OneShot.zap.shoot_dummy.fire({
                    dummy = nearest,
                    direction = -(lplr.Character.PrimaryPart.CFrame.Position - nearest.PrimaryPart.CFrame.Position).Unit,
                    is_headshot = true,
                    is_airborne = true,
                    origin = data.origin,
                })
            end

            data.origin += Vector3.new(0, 9, 0)
            data.direction = -(lplr.Character.PrimaryPart.CFrame.Position - nearest.Character.PrimaryPart.CFrame.Position).Unit
            data.is_headshot = true
            data.is_airborne = true
            data.target = nearest
        end
    end
    return old(data)
end)

--[[local old; old = hookfunction(OneShot.zap.shoot_dummy.fire, function(data)
    if silentAimEnabled then
        for index, value in data do
            print(index, value, typeof(value), (typeof(value) == 'Instance' and value.ClassName or nil))
        end
    end
    return old(data)
end)]]