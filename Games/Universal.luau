local GuiLibrary = shared.GuiLibrary
local runService = game:GetService('RunService')

local lplr: Player = cloneref(game:GetService('Players')).LocalPlayer

local isAlive = function()
    return lplr.Character and lplr.Character.PrimaryPart and lplr.Character:FindFirstChild('Humanoid') and lplr.Character:FindFirstChild('Humanoid').Health > 0
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {lplr.Character}

local isGrounded = function()
    local raycast: RaycastResult = workspace:Raycast(lplr.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -9.1, 0), rayParams)

    if raycast and raycast.Instance then
        return true
    end

    return false
end

local speedMode, speedValue, speedEnabled, speedAutoHop = 'CFrame', 35, false, false
GuiLibrary.Tabs.Movement:NewToggle('Speed', 'Allows you to move faster.', function(state: boolean)
    speedEnabled = state
end)
GuiLibrary.Tabs.Movement:NewToggle('Speed Auto Hop', 'Allows you to move faster.', function(state: boolean)
    speedAutoHop = state
end)
GuiLibrary.Tabs.Movement:NewDropdown('Speed Mode', 'Allows you to move faster.', {'WalkSpeed', 'Velocity', 'CFrame'}, function(currentVal: string)
    speedMode = currentVal
end)
GuiLibrary.Tabs.Movement:NewSlider('Speed Value', 'Allows you to move faster.', 100, 0, function(currentVal: number)
    speedValue = currentVal
end)
GuiLibrary.Tabs.Movement:NewKeybind('Speed Value', 'Allows you to move faster.', Enum.KeyCode.K, function()
    speedEnabled = not speedEnabled
end)

local old = 16

if lplr.Character then
    old = lplr.Character:WaitForChild('Humanoid').WalkSpeed
end

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

    if speedAutoHop and isGrounded() then
        lplr.Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(lplr.Character.PrimaryPart.AssemblyLinearVelocity.X, 35, lplr.Character.PrimaryPart.AssemblyLinearVelocity.Z)
    end
end)

lplr.CharacterAdded:Connect(function(character)
    character:WaitForChild('HumanoidRootPart')
    character:WaitForChild('Humanoid')

    rayParams.FilterDescendantsInstances = {character}
end)