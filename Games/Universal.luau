local GuiLibrary = shared.GuiLibrary
local runService = game:GetService('RunService')

local lplr: Player = cloneref(game:GetService('Players')).LocalPlayer

local isAlive = function()
    return lplr.Character and lplr.Character.PrimaryPart and lplr.Character:FindFirstChild('Humanoid') and lplr.Character:FindFirstChild('Humanoid').Health > 0
end

local speedMode, speedValue, speedEnabled = 'WalkSpeed', 50, false
GuiLibrary.Tabs.Movement:NewToggle('Speed', 'Allows you to move faster.', function(state: boolean)
    speedEnabled = state
end)
GuiLibrary.Tabs.Movement:NewDropdown('Speed', 'Allows you to move faster.', {'WalkSpeed', 'Velocity', 'CFrame'}, function(currentVal: string)
    speedMode = currentVal
end)
GuiLibrary.Tabs.Movement:NewSlider('Speed', 'Allows you to move faster.', 100, 0, function(currentVal: number)
    speedValue = currentVal
end)

local old = (lplr.Character or lplr.CharacterAdded:Wait()):WaitForChild('Humanoid').WalkSpeed
runService:BindToRenderStep('UniversalActions', Enum.RenderPriority.First.Value + 1, function(dt: number)
    if not isAlive() or not speedEnabled then
        return
    end

    local moveDir = lplr.Character.Humanoid.MoveDirection
    lplr.Character.Humanoid.WalkSpeed = old

    if speedMode == 'WalkSpeed' then
        lplr.Character.Humanoid.WalkSpeed = speedValue
    elseif speedMode == 'Velocity' then
        lplr.Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(moveDir.X * speedValue, lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y, moveDir.Z * speedValue)
    elseif speedMode == 'CFrame' then
        lplr.Character.PrimaryPart.CFrame += (moveDir * dt * (speedValue - lplr.Character.Humanoid.WalkSpeed))
    end
end)