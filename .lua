-- Crosshair Dynamic V2.2 (Fixed Mobile Scope Button Bug)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
 
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TargetGui = nil
pcall(function() TargetGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui end)
if not TargetGui then TargetGui = PlayerGui end
 
if TargetGui:FindFirstChild("SleepyStaticCenterCrosshair") then
    TargetGui.SleepyStaticCenterCrosshair:Destroy()
end
 
-- ==========================================
-- ui setting
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SleepyStaticCenterCrosshair"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = TargetGui
 
local CenterContainer = Instance.new("Frame")
CenterContainer.Name = "Centro"
CenterContainer.Size = UDim2.new(0, 0, 0, 0)
CenterContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
CenterContainer.BackgroundTransparency = 1
CenterContainer.Parent = ScreenGui

local TextContainer = Instance.new("Frame")
TextContainer.Name = "TextoContenedor"
TextContainer.Size = UDim2.new(0, 0, 0, 0)
TextContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
TextContainer.BackgroundTransparency = 1
TextContainer.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "n1ghtamreText"
TextLabel.Size = UDim2.new(0, 400, 0, 30) 
TextLabel.Position = UDim2.new(0, -200, 0, 24) 
TextLabel.BackgroundTransparency = 1
TextLabel.RichText = true 
TextLabel.Text = '<font letter-spacing="2">n1ghtmare.win</font>' 
TextLabel.Font = Enum.Font.Arial 
TextLabel.TextSize = 18 
TextLabel.TextStrokeTransparency = 0 
TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.Parent = TextContainer

-- ==========================================
-- delete shift lock icon set (FIXED FOR MOBILE)
-- ==========================================
local HideOriginalMouse = true
local OriginalStates = {} 

local function RestoreGameCrosshair()
    UserInputService.MouseIconEnabled = true
    for obj, state in pairs(OriginalStates) do
        if obj and obj.Parent then
            pcall(function()
                if state.Visible ~= nil then obj.Visible = state.Visible end
                if state.Size ~= nil then obj.Size = state.Size end
                if state.Position ~= nil then obj.Position = state.Position end
                if state.BackgroundTransparency ~= nil then obj.BackgroundTransparency = state.BackgroundTransparency end
                if state.ImageTransparency ~= nil then obj.ImageTransparency = state.ImageTransparency end
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
            end)
        end
    end
    table.clear(OriginalStates) 
end

local function NukeGameCrosshair()
    if not HideOriginalMouse then return end
    
    pcall(function()
        UserInputService.MouseIconEnabled = false
        
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj == ScreenGui or obj:IsDescendantOf(ScreenGui) then continue end
            
            if obj:IsA("GuiObject") or obj:IsA("ScreenGui") then
                local name = string.lower(obj.Name)
                local isCrosshair = false
                
                -- 修正：防止誤殺按鈕與手持介面
                local isButton = obj:IsA("ImageButton") or obj:IsA("TextButton") or name:find("button") or name:find("btn") or name:find("touch") or name:find("mobile") or name:find("hud")
                
                if not isButton then
                    if name:find("crosshair") or name:find("reticle") or name:find("cursor") or name:find("pointer") or name:find("sight") then
                        isCrosshair = true
                    elseif name == "center" or name == "point" or name == "dot" then
                        isCrosshair = true
                    end
                end
                
                if isCrosshair then
                    if not OriginalStates[obj] then
                        OriginalStates[obj] = {}
                        if obj:IsA("GuiObject") then
                            OriginalStates[obj].Visible = obj.Visible
                            OriginalStates[obj].Size = obj.Size
                            OriginalStates[obj].Position = obj.Position
                            OriginalStates[obj].BackgroundTransparency = obj.BackgroundTransparency
                            if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                                OriginalStates[obj].ImageTransparency = obj.ImageTransparency
                            end
                        elseif obj:IsA("ScreenGui") then
                            OriginalStates[obj].Enabled = obj.Enabled
                        end
                    end

                    if obj:IsA("GuiObject") then
                        obj.Visible = false
                        obj.Size = UDim2.new(0, 0, 0, 0)
                        obj.Position = UDim2.new(99, 0, 99, 0)
                        obj.BackgroundTransparency = 1
                        
                        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                            obj.ImageTransparency = 1
                        end
                    elseif obj:IsA("ScreenGui") then
                        obj.Enabled = false
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- custom
-- ==========================================
local BaseLength_Def = 17 
local Thickness_Def = 1  
local CenterGap_Def = 8  

local CrosshairSize = 17 
local FontSize = 18      

local RotationSpeed = 150 
local PulseDistance = 5   
local RGBSpeed = 0.05 
local PulseSpeed = 3.5 
local CustomTextStr = "n1ghtmare.win"
local CustomTilt = 45 

local BreatheFrequency = 1.0   
local MinSpeedPercent = 30     

local CurrentRotation = 0
local CurrentFontIndex = 1
local FontList = {
    Enum.Font.Arial, Enum.Font.SourceSansBold, Enum.Font.GothamBlack, 
    Enum.Font.Jura, Enum.Font.Arcade, Enum.Font.Code
}

local IsVisible = true
local IsRotating = true
local ModoMenu = false 
local SpinMode = "Breathing"

-- ==========================================
-- crosshair
-- ==========================================
local Lines = {}
local Outlines = {}

for i = 1, 4 do
    local Outline = Instance.new("Frame")
    Outline.BorderSizePixel = 0
    Outline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Outline.BackgroundTransparency = 0.5 
    Outline.AnchorPoint = Vector2.new(0.5, 0.5) 
    Outline.Parent = CenterContainer
    Outlines[i] = Outline

    local Line = Instance.new("Frame")
    Line.BorderSizePixel = 0 
    Line.AnchorPoint = Vector2.new(0.5, 0.5) 
    Line.Parent = CenterContainer
    Lines[i] = Line
end
 
-- ==========================================
-- move
-- ==========================================
local function MakeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging, dragInput, dragStart, startPos
    local dragMoved = false

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragMoved = false
            dragStart = input.Position
            startPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 3 then dragMoved = true end 
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    return function() return dragMoved end 
end

-- ==========================================
-- ui
-- ==========================================
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleMenuBtn.Position = UDim2.new(1, -55, 1, -55)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleMenuBtn.Text = "⚙️"
ToggleMenuBtn.TextSize = 20
ToggleMenuBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleMenuBtn).CornerRadius = UDim.new(0, 8)

local checkBtnDrag = MakeDraggable(ToggleMenuBtn)

local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(0, 160, 0, 320)
SettingsPanel.Position = UDim2.new(0.5, -80, 0.5, -160)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
SettingsPanel.BackgroundTransparency = 0.1
SettingsPanel.Visible = false
SettingsPanel.Active = true
SettingsPanel.Parent = ScreenGui
Instance.new("UICorner", SettingsPanel).CornerRadius = UDim.new(0, 10)

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(60, 60, 75)
PanelStroke.Thickness = 1.5
PanelStroke.Parent = SettingsPanel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "🔧 Settings"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = SettingsPanel

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.9, 0, 0, 1)
Divider.Position = UDim2.new(0.05, 0, 0, 35)
Divider.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
Divider.BorderSizePixel = 0
Divider.Parent = SettingsPanel

MakeDraggable(SettingsPanel, Title)

ToggleMenuBtn.Activated:Connect(function()
    if checkBtnDrag() then return end 
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y 
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ScrollingFrame.Parent = SettingsPanel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.Parent = ScrollingFrame

local function CreateToggleButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = ScrollingFrame
    btn.AutoButtonColor = false 
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(70, 70, 85)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        stroke.Color = Color3.fromRGB(100, 100, 120)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        stroke.Color = Color3.fromRGB(70, 70, 85)
    end)

    btn.Activated:Connect(function() callback(btn) end)
    return btn
end

local function CreateInputBox(placeholder, defaultText, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.9, 0, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    box.PlaceholderText = placeholder
    box.Text = defaultText
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.Parent = ScrollingFrame
    box.ClearTextOnFocus = false
    
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Color3.fromRGB(50, 50, 65)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    box.Focused:Connect(function() stroke.Color = Color3.fromRGB(120, 120, 200) end)
    box.FocusLost:Connect(function() 
        stroke.Color = Color3.fromRGB(50, 50, 65)
        callback(box.Text, box) 
    end)
    return box
end

-- ==========================================
-- 按鈕排列
-- ==========================================
local btnMenu = CreateToggleButton("Mode: Center [M]", function(btn)
    ModoMenu = not ModoMenu
    btn.Text = ModoMenu and "Mode: Follow [M]" or "Mode: Center [M]"
end)

local btnVis = CreateToggleButton("Visible: ON [V]", function(btn)
    IsVisible = not IsVisible
    CenterContainer.Visible = IsVisible
    TextContainer.Visible = IsVisible
    btn.Text = IsVisible and "Visible: ON [V]" or "Visible: OFF [V]"
end)

local btnRot = CreateToggleButton("Rotation: ON [R]", function(btn)
    IsRotating = not IsRotating
    btn.Text = IsRotating and "Rotation: ON [R]" or "Rotation: OFF [R]"
    if IsRotating then CurrentRotation = CustomTilt end
end)

CreateToggleButton("Hide Game Mouse: ON", function(btn)
    HideOriginalMouse = not HideOriginalMouse
    if not HideOriginalMouse then RestoreGameCrosshair() end
    btn.Text = HideOriginalMouse and "Hide Game Mouse: ON" or "Hide Game Mouse: OFF"
end)

CreateInputBox("Custom Text", CustomTextStr, function(text, box)
    CustomTextStr = text
    TextLabel.Text = '<font letter-spacing="2">' .. CustomTextStr .. '</font>'
end)

CreateInputBox("Crosshair Size", "Cross: 17", function(text, box)
    local num = tonumber(text:match("%d+%.?%d*"))
    if num then CrosshairSize = num end
    box.Text = "Cross: " .. CrosshairSize
end)

CreateInputBox("Font Size", "Font: 18", function(text, box)
    local num = tonumber(text:match("%d+"))
    if num then FontSize = num TextLabel.TextSize = FontSize end
    box.Text = "Font: " .. FontSize
end)

CreateToggleButton("Font: Arial", function(btn)
    CurrentFontIndex = CurrentFontIndex + 1
    if CurrentFontIndex > #FontList then CurrentFontIndex = 1 end
    local newFont = FontList[CurrentFontIndex]
    TextLabel.Font = newFont
    btn.Text = "Font: " .. newFont.Name
end)

CreateToggleButton("Spin Mode: Breathing", function(btn)
    SpinMode = (SpinMode == "Breathing") and "Continuous" or "Breathing"
    btn.Text = "Spin: " .. SpinMode
end)

CreateInputBox("Rotation Speed", "Speed: 150", function(text, box)
    local num = tonumber(text:match("%-?%d+"))
    if num then RotationSpeed = num end
    box.Text = "Speed: " .. RotationSpeed
end)

CreateInputBox("Min Speed (%)", "Min %: 30", function(text, box)
    local num = tonumber(text:match("%d+"))
    if num then MinSpeedPercent = math.clamp(num, 1, 100) end
    box.Text = "Min %: " .. MinSpeedPercent
end)

CreateInputBox("Breathe Freq", "Freq: 1.0", function(text, box)
    local num = tonumber(text:match("%d+%.?%d*"))
    if num and num > 0 then BreatheFrequency = num end
    box.Text = "Freq: " .. BreatheFrequency
end)

CreateInputBox("Paused Angle", "Tilt: 45", function(text, box)
    local num = tonumber(text:match("%-?%d+"))
    if num then CustomTilt = num end
    box.Text = "Tilt: " .. CustomTilt
end)

CreateInputBox("Pulse Dist", "Pulse: 5", function(text, box)
    local num = tonumber(text:match("%d+%.?%d*"))
    if num then PulseDistance = num end
    box.Text = "Pulse: " .. PulseDistance
end)

-- ==========================================
-- lock
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.M then
        ModoMenu = not ModoMenu
        btnMenu.Text = ModoMenu and "Mode: Follow [M]" or "Mode: Center [M]"
    elseif input.KeyCode == Enum.KeyCode.V then
        IsVisible = not IsVisible
        CenterContainer.Visible = IsVisible
        TextContainer.Visible = IsVisible
        btnVis.Text = IsVisible and "Visible: ON [V]" or "Visible: OFF [V]"
    elseif input.KeyCode == Enum.KeyCode.R then
        IsRotating = not IsRotating
        btnRot.Text = IsRotating and "Rotation: ON [R]" or "Rotation: OFF [R]"
        if IsRotating then CurrentRotation = CustomTilt end
    end
end)

-- ==========================================
-- render
-- ==========================================
local ColorTick = 0
local MotionTick = 0
local NukeTimer = 0
local Connection

Connection = RunService.RenderStepped:Connect(function(deltaTime)
    if not CenterContainer or not CenterContainer.Parent then
        Connection:Disconnect()
        return
    end
 
    NukeTimer = NukeTimer + deltaTime
    if NukeTimer >= 0.1 then
        NukeTimer = 0
        task.spawn(NukeGameCrosshair)
    end

    ColorTick = ColorTick + deltaTime
 
    local CurrentPosition
    if not ModoMenu then
        CurrentPosition = UDim2.new(0.5, 0, 0.5, 0)
    else
        local CursorLocation
        if GuiService.SelectedObject then
            local AbsolutePosition = GuiService.SelectedObject.AbsolutePosition
            local AbsoluteSize = GuiService.SelectedObject.AbsoluteSize
            CursorLocation = Vector2.new(
                AbsolutePosition.X + (AbsoluteSize.X / 2),
                AbsolutePosition.Y + (AbsoluteSize.Y / 2)
            )
        else
            CursorLocation = UserInputService:GetMouseLocation()
        end
        CurrentPosition = UDim2.new(0, CursorLocation.X, 0, CursorLocation.Y)
    end
    
    CenterContainer.Position = CurrentPosition
    TextContainer.Position = CurrentPosition
 
    local CrossScale = CrosshairSize / 17 
    local ScaledBase = BaseLength_Def * CrossScale
    local ScaledThick = Thickness_Def * CrossScale
    local ScaledGap = CenterGap_Def * CrossScale
    local ScaledRange = PulseDistance * CrossScale  

    local TextOffsetY = (24 * CrossScale) + (FontSize / 5)
    TextLabel.Position = UDim2.new(0, -200, 0, TextOffsetY)
 
    local PulseFactor = 0
    if IsRotating then
        MotionTick = MotionTick + deltaTime
        
        if SpinMode == "Breathing" then
            local sineWave = (math.sin(MotionTick * math.pi * BreatheFrequency) + 1) / 2 
            local minMultiplier = MinSpeedPercent / 100 
            local smoothSpeedMultiplier = minMultiplier + (1 - minMultiplier) * sineWave
            
            CurrentRotation = (CurrentRotation + (RotationSpeed * smoothSpeedMultiplier * deltaTime)) % 360
            CenterContainer.Rotation = CurrentRotation
            PulseFactor = sineWave
            
        elseif SpinMode == "Continuous" then
            CurrentRotation = (CurrentRotation + (RotationSpeed * deltaTime)) % 360
            CenterContainer.Rotation = CurrentRotation
            PulseFactor = math.sin(MotionTick * PulseSpeed)
        end
    else
        CenterContainer.Rotation = CustomTilt
        PulseFactor = 0
    end
 
    local Hue = (ColorTick * RGBSpeed) % 1
    local CurrentColor = Color3.fromHSV(Hue, 1, 1)
    
    TextLabel.TextColor3 = CurrentColor
    Title.TextColor3 = CurrentColor
    ToggleMenuBtn.TextColor3 = CurrentColor
    PanelStroke.Color = CurrentColor 
 
    local DynamicLength = ScaledBase + (PulseFactor * ScaledRange)
    local BorderSpread = 1 * CrossScale 
 
    Lines[1].Size = UDim2.new(0, ScaledThick, 0, DynamicLength)
    Lines[1].Position = UDim2.new(0, 0, 0, -ScaledGap - (DynamicLength / 2))
    Lines[1].BackgroundColor3 = CurrentColor
    Outlines[1].Size = UDim2.new(0, ScaledThick + (BorderSpread * 2), 0, DynamicLength + (BorderSpread * 2))
    Outlines[1].Position = UDim2.new(0, 0, 0, -ScaledGap - (DynamicLength / 2))
 
    Lines[2].Size = UDim2.new(0, ScaledThick, 0, DynamicLength)
    Lines[2].Position = UDim2.new(0, 0, 0, ScaledGap + (DynamicLength / 2))
    Lines[2].BackgroundColor3 = CurrentColor
    Outlines[2].Size = UDim2.new(0, ScaledThick + (BorderSpread * 2), 0, DynamicLength + (BorderSpread * 2))
    Outlines[2].Position = UDim2.new(0, 0, 0, ScaledGap + (DynamicLength / 2))
 
    Lines[3].Size = UDim2.new(0, DynamicLength, 0, ScaledThick)
    Lines[3].Position = UDim2.new(0, -ScaledGap - (DynamicLength / 2), 0, 0)
    Lines[3].BackgroundColor3 = CurrentColor
    Outlines[3].Size = UDim2.new(0, DynamicLength + (BorderSpread * 2), 0, ScaledThick + (BorderSpread * 2))
    Outlines[3].Position = UDim2.new(0, -ScaledGap - (DynamicLength / 2), 0, 0)
 
    Lines[4].Size = UDim2.new(0, DynamicLength, 0, ScaledThick)
    Lines[4].Position = UDim2.new(0, ScaledGap + (DynamicLength / 2), 0, 0)
    Lines[4].BackgroundColor3 = CurrentColor
    Outlines[4].Size = UDim2.new(0, DynamicLength + (BorderSpread * 2), 0, ScaledThick + (BorderSpread * 2))
    Outlines[4].Position = UDim2.new(0, ScaledGap + (DynamicLength / 2), 0, 0)
end)
