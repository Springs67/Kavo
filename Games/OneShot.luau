local GuiLibrary = shared.GuiLibrary

local runService: RunService = cloneref(game:GetService('RunService'))

local lplr: Player = cloneref(game:GetService('Players')).LocalPlayer

local isAlive = function()
    return lplr.Character and lplr.Character.PrimaryPart and lplr.Character:FindFirstChild('Humanoid') and lplr.Character:FindFirstChild('Humanoid').Health > 0
end

local OneShot = {
    WeaponController = require(game:GetService("ReplicatedStorage").client.controllers.WeaponController),
    WeaponConfig = require(game:GetService("ReplicatedStorage").shared.data.weapons.WeaponConfig),
    WeaponData = require(game:GetService("ReplicatedStorage").shared.data.weapons.WeaponData),

    CurrencyDropController = require(game:GetService("ReplicatedStorage").client.controllers.CurrencyDropController),

    FlyController = require(game:GetService("ReplicatedStorage").client.controllers.FlyController),

    GameStateController = require(game:GetService("ReplicatedStorage").client.controllers.GameStateController),
}

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

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {lplr.Character or lplr.CharacterAdded:Wait()}

local isGrounded = function()
    local raycast: RaycastResult = workspace:Raycast(lplr.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), rayParams)

    if raycast and raycast.Instance then
        return true
    end

    return false
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