local UI = {}

local Utility = {}
local TweenService = game:GetService("TweenService")

local function enableDragging(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

            local userInputService = game:GetService("UserInputService")
            dragInput = userInputService.InputChanged:Connect(function(inputChanged)
                if dragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                    update(inputChanged)
                end
            end)
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if dragInput then
                dragInput:Disconnect()
                dragInput = nil
            end
        end
    end)
end

local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(
		function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPosition = object.Position

				input.Changed:Connect(
					function()
						if input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end
				)
			end
		end
	)

	topbarobject.InputChanged:Connect(
		function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement or
					input.UserInputType == Enum.UserInputType.Touch
			then
				DragInput = input
			end
		end
	)

	UserInputService.InputChanged:Connect(
		function(input)
			if input == DragInput and Dragging then
				Update(input)
			end
		end
	)
end


local SlimUI = {
    Theme = nil,
    Themes = nil,
    Objects = {},
}

function Utility:TweenObject(obj, properties, duration, ...)
    TweenService:Create(obj, TweenInfo.new(duration, ...), properties):Play() 
end

UITheme = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        SideBar = Color3.fromRGB(28, 28, 28),
        Text = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(42, 42, 42),
        Outline = Color3.fromRGB(62, 62, 62),
        Placeholder = Color3.fromRGB(20, 20, 20),
        IconColor = Color3.fromRGB(255, 255, 255),
    },
    Light = {
        Background = Color3.fromRGB(180, 180, 180),
        SideBar = Color3.fromRGB(215, 215, 215),
        Text = Color3.fromRGB(30, 30, 30),
        ElementColor = Color3.fromRGB(215, 215, 215),
        Outline = Color3.fromRGB(230, 230, 230),
        Placeholder = Color3.fromRGB(170, 170, 170),
        IconColor = Color3.fromRGB(30, 30, 30),
    },
    Amethyst = {
        Background = Color3.fromRGB(42, 16, 68),
        SideBar = Color3.fromRGB(50, 24, 76),
        Text = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(36, 10, 62),
        Outline = Color3.fromRGB(80, 22, 138),
        Placeholder = Color3.fromRGB(58, 28, 88),
        IconColor = Color3.fromRGB(255, 255, 255),
    },
    NeverloseTheme = {
       Background = Color3.fromRGB(14, 15, 20),      -- Dark background
       SideBar = Color3.fromRGB(43, 44, 52),         -- Sidebar dark
       Text = Color3.fromRGB(224, 255, 231),         -- White text
       ElementColor = Color3.fromRGB(22, 20, 31),    -- Element background
       Outline = Color3.fromRGB(114, 137, 218),         -- Dark outline
       Placeholder = Color3.fromRGB(129, 134, 143),     -- Placeholder
       IconColor = Color3.fromRGB(93, 101, 168),    -- Blue icons
    },
}

function SlimUI:Create(class, properties, children)
    local inst = Instance.new(class)
    
    for property, Value in next, properties or {} do
        if property ~= "ThemeID" then
            inst[property] = Value
        end
    end

    for _, Child in next, children or {} do
        Child.Parent = inst
    end

    if properties and properties.ThemeID then
        SlimUI:AddThemeObject(inst, properties.ThemeID)
    end

    return inst
end

function SlimUI:GetThemeProperty(property, theme)
    return theme[property] or UITheme["Dark"][property]
end

function SlimUI:AddThemeObject(object, properties)
    SlimUI.Objects[object] = { Object = object, Properties = properties }
    SlimUI:UpdateTheme(object, false)
    return object
end

function SlimUI:UpdateTheme(targetObject, isTween)
    local function ApplyTheme(objData)
        for property, colorKey in pairs(objData.Properties or {}) do
            local color = SlimUI:GetThemeProperty(colorKey, SlimUI.Theme)
            if color then
                if not isTween then
                    objData.Object[property] = color
                else
                    Utility:TweenObject(objData.Object, { [property] = color }, 0.08)
                end
            end
        end
    end

    if targetObject then
        local objData = SlimUI.Objects[targetObject]
        if objData then
            ApplyTheme(objData)
        end
    else
        for _, objData in pairs(SlimUI.Objects) do
            ApplyTheme(objData)
        end
    end
end

local Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
Icons.SetIconsType("lucide")

function UI:CreateWindow(Config)
    local Window = {
        Name = Config.Name or "UI Library",
        Icon = Config.Icon or nil,
        ToggleKey = Config.ToggleKey or Enum.KeyCode.F,
        Elements = Config.Elements or {},
        Transparent = Config.Transparent or false,
        Theme = Config.Theme or "Dark",
        --Icon = Config.Icon or "lucide",
        Default = Config.Default or "Default", --Default, Minimize
        Themes = UITheme,
        Size = Config.Size and UDim2.new(
            0, math.clamp(Config.Size.X.Offset, 420, 580),
            0, math.clamp(Config.Size.Y.Offset, 280, 450)
        ) or UDim2.new(0, 420, 0, 280),
        SideBarWidth = Config.SideBarWidth or 134,
        BackpackHotbar = Config.BackpackHotbar or game:GetService("CoreGui"):WaitForChild("RobloxGui"):WaitForChild("Backpack"):WaitForChild("Hotbar"),
    }

    --ElementIcons.SetIconsType(Window.Icon)

    --print(Window.Size.X.Offset, Window.Size.Y.Offset)
    Utility:TweenObject(Window.BackpackHotbar, {Position = UDim2.new(0.5, -100, 1, -70)}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    for _, v in next, game:GetService("CoreGui"):GetChildren() do
        if v.Name == Config.Name then
          v:Destroy()
        end
    end

    --local Themes = UITheme

    --[[function UI:AddTheme(LTheme)
        Themes[LTheme.Name] = LTheme
        return LTheme
    end--]]

    --[[function UI:SetTheme(Value)
        if Themes[Value] then
            UI.Theme = Themes[Value]
            SlimUI:SetTheme(Themes[Value])
            UI:UpdateTheme()
            
            return Themes[Value]
        end
        return nil
    end--]]

    function Window:SetTheme(themeName)
        Window.Theme = themeName
        local theme = UITheme[themeName]
        if not theme then
            warn("Theme '" .. tostring(themeName) .. "' not found.")
            return
        end
        
        SlimUI.Theme = theme
        SlimUI:UpdateTheme(nil, true)
    end

    Window:SetTheme('NeverloseTheme')

    function ElementAutoColor(Element)
        Element.BackgroundColor3 = Color3.fromRGB(Element.BackgroundColor3.R * 255+20,Element.BackgroundColor3.G * 255+20,Element.BackgroundColor3.B * 255+20)
        wait(0.05)
        Element.BackgroundColor3 = Color3.fromRGB(Element.BackgroundColor3.R * 255-20,Element.BackgroundColor3.G * 255-20,Element.BackgroundColor3.B * 255-20)
    end

    local UIScreen = SlimUI:Create("ScreenGui", {
        Name = Window.Name,
        Parent = game:GetService("CoreGui"),
        --ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local MainFrame = SlimUI:Create("Frame", {Parent = UIScreen,
        --AutomaticSize = "XY",
        Active = true,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Transparency = 1,
        --Transparency = Window.Transparent and 0.15 or 0,
        Position = UDim2.new(0.375444829, 0, 0.324120611, 0),
        Size = UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset),
        ThemeID = {
            BackgroundColor3 = "Background"
        }
    }, {
        SlimUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 15)
        })
    })

    local outline = Instance.new("UIStroke")
    outline.Parent = MainFrame
    outline.Color = Color3.new(1, 1, 1) -- White
    outline.Transparency = 0.7
    outline.Thickness = 2
    
    Utility:TweenObject(MainFrame, {Transparency = Window.Transparent and 0.15 or 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    enableDragging(MainFrame, MainFrame)

    local UIPaddingewewewewewe = Instance.new("UIPadding")

    local TabLib = SlimUI:Create("Frame", {Parent = MainFrame,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Transparency = 1,
        Size = UDim2.new(0, Window.SideBarWidth, 0, Window.Size.Y.Offset),
        ThemeID = {
            BackgroundColor3 = "Background"
        }
    }, {
        SlimUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 15)
        })
    })

    Utility:TweenObject(TabLib, {Transparency = Window.Transparent and 1 or 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local Corner = Instance.new("UICorner")
    Corner.Parent = TabLib
    Corner.CornerRadius = UDim.new(0, 12)
    
    local outline = Instance.new("UIStroke")
    outline.Parent = TabLib
    outline.Color = Color3.new(1, 1, 1) -- White
    outline.Transparency = 0.7
    outline.Thickness = 2

    local ScrollingFrame = SlimUI:Create("ScrollingFrame", {Parent = TabLib,
        Active = true,
        BackgroundColor3 = Color3.fromRGB(1,1,1,1),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.new(0, 0, 0),
        ClipsDescendants = true,
        ScrollBarThickness = 0,
        ElasticBehavior = "Never",
        CanvasSize = UDim2.new(0,0,0,0),
        --AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.0928571448, 0),
        Size = UDim2.new(0, Window.SideBarWidth, 0, Window.Size.Y.Offset - 20),
        ScrollBarThickness = 0.5,
    }, {
        SlimUI:Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    local UIPaddingS = Instance.new("UIPadding")
    UIPaddingS.Name = "UIPaddingS"
    UIPaddingS.Parent = ScrollingFrame
    UIPaddingS.PaddingLeft = UDim.new(0, 6)

    ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollingFrame.CanvasSize = UDim2.new(0, ScrollingFrame.UIListLayout.AbsoluteContentSize.X, 0, ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
    end)
    --UIPadding.Parent = ScrollingFrame
    --UIPadding.PaddingTop = UDim.new(0, 5)

    local Frame = SlimUI:Create("Frame", {Parent = TabLib,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        --AutomaticSize = "Y",
        Transparency = Window.Transparent and 1 or 0,
        Position = UDim2.new(0, TabLib.Size.X.Offset-8, 0, 0),
        Size = UDim2.new(0, 8, 0, Window.Size.Y.Offset),
        ThemeID = {
            BackgroundColor3 = "SideBar"
        }
    })

    local UIName = SlimUI:Create("TextLabel", {Parent = MainFrame,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        RichText = true,
        TextTransparency = 1,
        Position = UDim2.new(0.0166666675, 0, 0.0270000007, 0),
        Size = UDim2.new(0, 105, 0, 14),--]]
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = Window.Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeID = {
            TextColor3 = "Text"
        }
    })

    Utility:TweenObject(UIName, {TextTransparency = 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    --[[local UINameUG = SlimUI:Create("UIGradient", {
        Parent = UIName,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255 + 20)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255 + 20, UITheme[Window.Theme].ElementColor.G * 255 + 20, UITheme[Window.Theme].ElementColor.B * 255 + 20))
        },
    })--]]

    local MinimizedFrame = SlimUI:Create("Frame", {Parent = UIScreen,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Visible = false,
        --RichText = true,
        Size = UDim2.new(0, 149, 0, 29),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        ThemeID = {
            BackgroundColor3 = "Background"
        }
    }, {
        SlimUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 11)
        }),
        SlimUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round"
        })
    })


    local MinimizedTRG = SlimUI:Create("TextButton", {Parent = MinimizedFrame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1.000,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, -0.672413766, 0),
        Size = UDim2.new(0, 193, 0, 48),
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14.000,
        TextTransparency = 1.000,
    })

    local UIMinName = SlimUI:Create("TextLabel", {Parent = MinimizedFrame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1.000,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 148, 0, 29),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = Window.Name,
        TextSize = 14.000,
        TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeID = {
            TextColor3 = "Text"
        }
    },{
        SlimUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, Window.Icon and 35 or 5)
        })
    })

        if Window.Icon and Icons.Icon(Window.Icon) then
            local UIIcon = SlimUI:Create("ImageLabel", {Parent = MinimizedFrame,
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0399999991, 3, 0.206896558, 0),
                Size = UDim2.new(0, 17, 0, 17),
                Image = Icons.GetIcon(Window.Icon),
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
        elseif Window.Icon and string.find(Window.Icon, "rbxassetid://") then
            local UIIcon = SlimUI:Create("ImageLabel", {Parent = MinimizedFrame,
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0399999991, 3, 0.206896558, 0),
                Size = UDim2.new(0, 17, 0, 17),
                Image = Window.Icon,
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
        end

    local UIArrow = SlimUI:Create("ImageLabel", {Parent = MinimizedFrame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1.000,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.409395963, 0, -0.672413766, 0),
        Size = UDim2.new(0, 26, 0, 19),
        Image = Icons.GetIcon("chevron-up"),
        ThemeID = {
            ImageColor3 = "IconColor"
        }
    })

    --Wind ELEMENT's
    local WindElement = SlimUI:Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth + 53, 0.0285714287, 0),
        Size = UDim2.new(0, 78, 0, 12),
    }, {
        SlimUI:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        }),
        SlimUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
        }),
    })

    if Window.Elements.Minimize or true then
        local Minimize = SlimUI:Create("ImageButton", {Parent = WindElement,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(-1.11764705, 0, 1.125, 0),
            ImageTransparency = 1,
            Size = UDim2.new(0, 21, 0, 21),
            Image = "rbxassetid://97170161699384",
            ThemeID = {
                ImageColor3 = "ImageColor"
            }
        })

        Minimize.MouseButton1Click:Connect(function()
            MinimizedFrame.Visible = true
            Utility:TweenObject(Window.BackpackHotbar, {Position = UDim2.new(Window.BackpackHotbar.Position.X.Scale, Window.BackpackHotbar.Position.X.Offset-190, Window.BackpackHotbar.Position.Y.Scale, Window.BackpackHotbar.Position.Y.Offset)}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            MainFrame.Visible = false
        end)

        MinimizedTRG.MouseButton1Click:Connect(function()
            MinimizedFrame.Visible = false
            MainFrame.Visible = true
            Utility:TweenObject(Window.BackpackHotbar, {Position = UDim2.new(0.5, -100, 1, -70)}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end)
        Utility:TweenObject(Minimize, {ImageTransparency = 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    end

    --[[if Window.Elements.Maximize then
        Maximize.Name = "Maximize"
        Maximize.Parent = WindElement
        Maximize.BackgroundColor3 = Color3.new(1, 1, 1)
        Maximize.BackgroundTransparency = 1
        Maximize.BorderColor3 = Color3.new(0, 0, 0)
        Maximize.BorderSizePixel = 0
        Maximize.Position = UDim2.new(0.134328365, 0, -0.505928755, 0)
        Maximize.Size = UDim2.new(0, 21, 0, 21)
        Maximize.Image = "rbxassetid://104146031032977"
    end--]]

    if Window.Elements.Close or true  then
        local Destroy = SlimUI:Create("ImageButton", {Parent = WindElement,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.134328365, 0, -0.505928755, 0),
            Size = UDim2.new(0, 21, 0, 21),
            Image = "rbxassetid://126853728595543",
            ThemeID = {
                ImageColor3 = "ImageColor"
            }
        })
        
        Destroy.MouseButton1Click:Connect(function()
            Utility:TweenObject(Window.BackpackHotbar, {Position = UDim2.new(0.5, -100, 1, -70)}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            UIScreen:Destroy()
        end)
        Utility:TweenObject(Destroy, {ImageTransparency = 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    end

    local ElementFolder = SlimUI:Create("Folder", {Parent = MainFrame,
        Name = "ElementFolder"
    })

    local ElementFrame = SlimUI:Create("Frame", {Parent = ElementFolder,
        BackgroundColor3 = Color3.new(1, 1, 1),
        --AutomaticSize = "XY",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, Window.SideBarWidth, 0, 37),
        Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth, 0, Window.Size.Y.Offset - 37),
    })

    function UI:Close()
        UIScreen:Destroy()
    end

    function UI:SetToggleKey(Value)
        Window.ToggleKey = Value
    end

    function UI:SetTransparency(Value)
        MainFrame.Transparency = Value and 0.1 or 0
        TabLib.Transparency = Value and 1 or 0
        Frame.Transparency = Value and 1 or 0
    end


    function Window:Close()
        UIScreen:Destroy()
    end

    function Window:SetToggleKey(Value)
        Window.ToggleKey = Value
    end

    function Window:SetTransparency(Value)
        MainFrame.Transparency = Value and 0.1 or 0
        TabLib.Transparency = Value and 1 or 0
        Frame.Transparency = Value and 1 or 0
    end
    
    local TogValue = true

    game:GetService("UserInputService").InputBegan:Connect(function(input, i)
        if not i then
            if input.KeyCode == Window.ToggleKey then
                TogValue = not TogValue
                MainFrame.Visible = TogValue
            end
        end
    end)

    local TabModule = {}
    local TabCounter = 0
    local lelele = 0
    local Tabs = true

    function TabModule:Devider()
        local DVD = {}
        local Dividers = SlimUI:Create("Frame", {Parent = ScrollingFrame,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, 122, 0, 1),
            ThemeID = {
                BackgroundColor3 = "TextColor"
            }
        })

        return DVD
    end

    function TabModule:Tab(Config)
        TabCounter = TabCounter + 1
        local Tab = {
            Title = Config.Title or "Tab " .. TabCounter,
            Icon = Config.Icon or nil
        }

        local TabBackground = SlimUI:Create("Frame", {Parent = ScrollingFrame,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = "Y",
            Size = UDim2.new(0, Window.SideBarWidth - 5, 0, 25),
            Transparency = 1,
        })
       
       local outline = Instance.new("UIStroke")
       outline.Parent = TabBackground
       outline.Color = Color3.new(1, 1, 1) -- White
       outline.Transparency = 0.7
       outline.Thickness = 2

        local TabLabel = SlimUI:Create("TextLabel", {Parent = TabBackground,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.209999993, 0),
            Size = UDim2.new(0, Window.SideBarWidth - 5, 0, 14),
            AutomaticSize = "Y",
            RichText = true,
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Config.Title,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Text"
            },
            ZIndex = 3,
        },{
            SlimUI:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 28)
            })
        })

        local TabButton = SlimUI:Create("TextButton", {Parent = TabBackground,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(-2.72478388e-07, 0, 0, 0),
            Size = UDim2.new(0, Window.SideBarWidth - 5, 0, 25),
            Font = Enum.Font.SourceSans,
            Transparency = 1,
            TextTransparency = 1,
            AutomaticSize = "Y",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
            ZIndex = 4,
        })

        local TabImage = SlimUI:Create("ImageLabel", {Parent = TabBackground,
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 5, 0, 4),
            Size = UDim2.new(0, 17, 0, 17),
            ImageTransparency = 1,
            ThemeID = {
                ImageColor3 = "IconColor"
            },
            ZIndex = 3,
        })

        if Tab.Icon then
            if Icons.Icon(Tab.Icon) then
                TabImage.ImageTransparency = 0
                TabImage.Image = Icons.GetIcon(Tab.Icon)
            elseif Tab.Icon and string.find(Tab.Icon, "rbxassetid://") then
                TabImage.ImageTransparency = 0
                TabImage.Image = Tab.Icon
            end
        else
            TabLabel.UIPadding.PaddingLeft = UDim.new(0, 12)
        end

        wait(0.05)
        local ScrollElement = SlimUI:Create("ScrollingFrame", {Parent = ElementFrame,
            Active = false,
            BackgroundColor3 = Color3.new(1, 1, 1),
            ClipsDescendants = true,
            ScrollBarThickness = 0,
            ElasticBehavior = "Never",
            CanvasSize = UDim2.new(0,0,0,0),
            --AutomaticCanvasSize = "Y",
            --ScrollingDirection = "Y",
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth, 0, Window.Size.Y.Offset - 45),
            ScrollBarThickness = 2
        },{
            SlimUI:Create("UIListLayout", {Parent = ScrollElement,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            SlimUI:Create("UIPadding", {Parent = ScrollElement,
                PaddingLeft = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 3),
                PaddingBottom = UDim.new(0, 7),
            })
        })

        --table.insert(ElementList, ScrollElement)
        
        ScrollElement.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollElement.CanvasSize = UDim2.new(0, ScrollElement.UIListLayout.AbsoluteContentSize.X, 0, ScrollElement.UIListLayout.AbsoluteContentSize.Y)
        end)

            if Tabs then
                Utility:TweenObject(TabLabel, {TextTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(TabImage, {ImageTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                ScrollElement.Visible = true
                Tabs = false
            else
                Utility:TweenObject(TabLabel, {TextTransparency = 0.45}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(TabImage, {ImageTransparency = 0.45}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                ScrollElement.Visible = false
            end
        
            TabButton.MouseButton1Click:Connect(function()
                for _, v in next, ElementFrame:GetChildren() do
                    if v:IsA("GuiObject") then
                        v.Visible = false
                    end
                end
                ScrollElement.Visible = true
                for i,v in next, ScrollingFrame:GetChildren() do
                    if v:IsA("Frame") then
                        for i,v in next, v:GetChildren() do
                            if v:IsA("TextLabel") then
                                Utility:TweenObject(v, {TextTransparency = 0.45}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            end
                            if v:IsA("ImageLabel") then
                                Utility:TweenObject(v, {ImageTransparency = 0.45}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                --v.ImageTransparency = 0.45
                            end
                        end
                    end
                end
                    Utility:TweenObject(TabLabel, {TextTransparency = 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    Utility:TweenObject(TabImage, {ImageTransparency = 0}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end)

        local Elements = {}
        local ButtonCount = 0
        function Elements:Button(Config)
            ButtonCount = ButtonCount + 1
            local Button = {
                Title = Config.Title or "Button " .. ButtonCount,
                Icon = Config.Icon or "mouse-pointer-click",
                Desc = Config.Desc or nil,
                Locked = Config.Locked or false,
                Callback = Config.Callback or function() end
            }

            local ButtonModule = SlimUI:Create("Frame", {Parent = ScrollElement,
                Name = Button.Title,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 0.2,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth - 17, 0, 35), --0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 7)
                }),
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = ButtonModule,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local BTNLabel = SlimUI:Create("TextLabel", {Parent = ButtonModule,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                RichText = true,
                Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth - 17, 0, 35),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Button.Title,
                AutomaticSize = "Y",
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                },
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })

            local BTNImage = SlimUI:Create("ImageLabel", {Parent = ButtonModule,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, ButtonModule.Size.X.Offset - 25, 0.249, 0),
                Size = UDim2.new(0, 17, 0, 17),
                ImageColor3 = Color3.fromRGB(UITheme[Window.Theme].IconColor.R * 255, UITheme[Window.Theme].IconColor.G * 255, UITheme[Window.Theme].IconColor.B * 255),
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
            
            if Button.Icon and Icons.Icon(Button.Icon) then
                BTNImage.Image = Icons.GetIcon(Button.Icon)
            elseif Button.Icon and string.find(Button.Icon, "rbxassetid://") then
                BTNImage.Image = Button.Icon
            end

            local BTNTextButton = SlimUI:Create("TextButton", {Parent = ButtonModule,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth, 0, ButtonModule.Size.Y.Offset),
                ZIndex = 5,
                TextColor3 = Color3.new(0, 0, 0),
                TextSize = 14,
                TextTransparency = 1,
            })

        local DescLabel = SlimUI:Create("TextLabel", {Parent = ButtonModule,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            RichText = true,
            Position = UDim2.new(0, 0, 0, 27),
            Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth, 0, 0),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Pisun",
            TextSize = 12,
            Visible = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Text"
            }
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 3)
            })
        })

        local LockFrame = SlimUI:Create("Frame", {
            Parent = ButtonModule,
            Visible = false,
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
            ZIndex = 7,
        },{
            SlimUI:Create("ImageLabel", {
                BackgroundTransparency = 1.000,
                ImageTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0.285714298, 0),
                Size = UDim2.new(0, 15, 0, 15),
                ZIndex = 8,
                Image = "rbxassetid://101535132491169",
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
        })

        function Button:Lock()
            BTNLabel.UIPadding.PaddingLeft = UDim.new(0, 23)
            BTNTextButton.Visible = false
            LockFrame.Visible = true
            Utility:TweenObject(ButtonModule, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(BTNLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(BTNImage, {ImageTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(DescLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(UIStroke, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end

        function Button:UnLock()
            BTNTextButton.Visible = true
            Utility:TweenObject(ButtonModule, {Transparency = 0.2}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(BTNImage, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(BTNLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(DescLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 1}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            Utility:TweenObject(UIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            BTNLabel.UIPadding.PaddingLeft = UDim.new(0, 10)
            --wait(0.05)
            LockFrame.Visible = false
        end

        Button:UnLock()
        if Button.Locked then
            Button:Lock()
        end

        function Button:SetDesc(Value)
            DescLabel.Visible = true
            DescLabel.Text = Value
        end

        if Button.Desc then
            Button:SetDesc(Button.Desc)
        end

            --TouchElement(ButtonModule)

            BTNTextButton.MouseButton1Click:Connect(function()
                spawn(function()
                    pcall(Button.Callback)
                end)
                ElementAutoColor(ButtonModule)
            end)

            function Button:SetIcon(Icon)
                if Icon and Icons.Icon(Icon) then
                    BTNImage.Image = Icons.GetIcon(Icon)
                elseif Icon and string.find(Icon, "rbxassetid://") then
                    BTNImage.Image = Icon
                end
            end

            function Button:Close()
                ButtonModule:Destroy()
            end

            function Button:SetTitle(Value)
                BTNLabel.Text = Value
            end
            return Button
        end

        local ToggleCount = 0
        function Elements:Toggle(Config)
            ToggleCount = ToggleCount + 1
            local Toggle = {
                Title = Config.Title or "Toggle " .. ToggleCount,
                Desc = Config.Desc or nil,
                Locked = Config.Locked or false,
                Default = Config.Default or false,
                Alignment = Config.Alignment or "Right",
                Callback = Config.Callback or function() end
            }

            local ToggleModule = SlimUI:Create("Frame", {
                Name = Toggle.Title,
                Parent = ScrollElement,
                BackgroundTransparency = 0.2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth - 17, 0, 35),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = ToggleModule,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local ToggleModuleC = SlimUI:Create("UICorner", {
                Parent = ToggleModule,
                CornerRadius = UDim.new(0, 7),
            })

            local TRGLabel = SlimUI:Create("TextLabel", {
                Parent = ToggleModule,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 35),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Toggle.Title,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })

            local TRGLabelUP = SlimUI:Create("UIPadding", {
                Parent = TRGLabel,
                PaddingLeft = UDim.new(0, 10),
            })

            local ToggleTRG = SlimUI:Create("TextButton", {
                Parent = ToggleModule,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 35),
                ZIndex = 5,
                Font = Enum.Font.SourceSans,
                TextColor3 = Color3.new(0, 0, 0),
                TextSize = 14,
                TextTransparency = 1,
            })

            local ValFrame = SlimUI:Create("Frame", {
                Parent = ToggleModule,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, ToggleModule.Size.X.Offset - 35, 0, 8.5),
                Size = UDim2.new(0, 30, 0, 17),
                ThemeID = {
                    BackgroundColor3 = "Placeholder"
                }
            })

            local ValFrameC = SlimUI:Create("UICorner", {
                Parent = ValFrame,
            })

            local ToggleVal = SlimUI:Create("Frame", {
                Parent = ValFrame,
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(0, 13, 0, 13),
            })

            local ToggleValC = SlimUI:Create("UICorner", {
                Parent = ToggleVal,
            })

            local DescLabel = SlimUI:Create("TextLabel", {Parent = ToggleModule,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Position = UDim2.new(0, 0, 0, 27),
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 0),
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Toggle.Desc or "",
                TextSize = 12,
                Visible = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
                },{
                    SlimUI:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        PaddingBottom = UDim.new(0, 3)
                })
            })

            local LockFrame = SlimUI:Create("Frame", {
                Parent = ToggleModule,
                Visible = false,
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ZIndex = 7,
            },{
                SlimUI:Create("ImageLabel", {
                    BackgroundTransparency = 1.000,
                    ImageTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0.285714298, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    ZIndex = 8,
                    Image = "rbxassetid://101535132491169",
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                })
            })

            --[[if Toggle.Alignment == "Right" then
                TRGLabelUP.PaddingLeft = UDim.new(0, 10)
                ValFrame.Position = UDim2.new(0, ToggleModule.Size.X.Offset - 35, 0, 8.5)
            elseif Toggle.Alignment == "Left" then
                TRGLabelUP.PaddingLeft = UDim.new(0, 40)
                ValFrame.Position = UDim2.new(0, 5,0.24, 0)
            end--]]

            function Toggle:Lock()
                if Toggle.Alignment == "Right" then
                    TRGLabelUP.PaddingLeft = UDim.new(0, 23)
                    ValFrame.Position = UDim2.new(0, ToggleModule.Size.X.Offset - 35, 0, 8.5)
                elseif Toggle.Alignment == "Left" then
                    TRGLabelUP.PaddingLeft = UDim.new(0, 60)
                    ValFrame.Position = UDim2.new(0, 25,0.24, 0)
                end
                --TRGLabelUP.PaddingLeft = UDim.new(0, 23)
                ToggleTRG.Visible = false
                LockFrame.Visible = true
                Utility:TweenObject(ToggleModule, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(TRGLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(ToggleVal, {Transparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DescLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end

            function Toggle:UnLock()
                TRGLabelUP.PaddingLeft = UDim.new(0, (Toggle.Alignment == "Right" and 10 or 42))
                if Toggle.Alignment == "Right" then
                    TRGLabelUP.PaddingLeft = UDim.new(0, 10)
                    ValFrame.Position = UDim2.new(0, ToggleModule.Size.X.Offset - 35, 0, 8.5)
                elseif Toggle.Alignment == "Left" then
                    TRGLabelUP.PaddingLeft = UDim.new(0, 40)
                    ValFrame.Position = UDim2.new(0, 5,0.24, 0)
                end
                ToggleTRG.Visible = true
                Utility:TweenObject(ToggleModule, {Transparency = 0.2}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(ToggleVal, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(TRGLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DescLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 1}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                LockFrame.Visible = false
            end

            Toggle:UnLock()
            if Toggle.Locked then
                Toggle:Lock()
            end

            function Toggle:SetDesc(Value)
                DescLabel.Visible = true
                DescLabel.Text = Value
                return Toggle
            end
            
            if Toggle.Desc then
                Toggle:SetDesc(Toggle.Desc)
            end

            function Toggle:Close()
                ToggleModule:Destroy()
                return Toggle
            end

            function Toggle:SetTitle(Value)
                TRGLabel.Text = Value
                return Toggle
            end

            local Val = Toggle.Default

            function Toggle:SetValue(newValue)
                Val = newValue
                
                if newValue then
                    Utility:TweenObject(ToggleVal, {
                        Position = UDim2.new(0, 15, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255)
                    }, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                else
                    Utility:TweenObject(ToggleVal, {
                        Position = UDim2.new(0, 2, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(
                            UITheme[Window.Theme].Placeholder.R * 255 + 20,
                            UITheme[Window.Theme].Placeholder.G * 255 + 20,
                            UITheme[Window.Theme].Placeholder.B * 255 + 20
                        )
                    }, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                end
                
                spawn(function()
                    pcall(Toggle.Callback, Val)
                end)
                
                return Toggle
            end

            Toggle:SetValue(Val)

            ToggleTRG.MouseButton1Click:Connect(function()
                Val = not Val
                Toggle:SetValue(Val)
            end)

            return Toggle
        end

        local ParagraphCount = 0
        function Elements:Paragraph(Config)
            ParagraphCount = ParagraphCount + 1
            local Paragraph = {
                Title = Config.Title or "Paragraph" .. ParagraphCount,
                Icon = Config.Icon,
                Color = Config.Color or "Default",
                Type = Config.Type or "Large", --Large  or  Small
                Desc = Config.Desc or nil,
                Brightness = Config.Brightness or 28,
                TextSize = Config.TextSize or 13
            }

        local function createColor(r, g, b)
            return Color3.fromRGB(r + Paragraph.Brightness - 28, g + Paragraph.Brightness - 28, b + Paragraph.Brightness - 28)
        end

        local Colors = {
            Default = createColor(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
            Red = createColor(154, 0, 5),
            Green = createColor(41, 154, 0),
            Blue = createColor(0, 41, 154),
            Pink = createColor(154, 0, 154),
            Orange = createColor(154, 95, 0),
            Yellow = createColor(154, 141, 0),
            Ocyan = createColor(0, 133, 154),
            Purple = createColor(95, 0, 154),
        }
        local params = {
            Name = Paragraph.Title,
            Parent = ScrollElement,
            BackgroundTransparency = 0.2,
            BorderColor3 = Color3.new(0, 0, 0),
            AutomaticSize = "Y",
            BorderSizePixel = 0,
            Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
        }

        if Paragraph.Color ~= "Default" then
            params.BackgroundColor3 = Colors[Paragraph.Color] or Color3.fromRGB(
                UITheme[Window.Theme].ElementColor.R * 255,
                UITheme[Window.Theme].ElementColor.G * 255,
                UITheme[Window.Theme].ElementColor.B * 255
            )
        else
            params.ThemeID = {
                BackgroundColor3 = "ElementColor"
            }
        end

        local ParagraphElement = SlimUI:Create("Frame", params)

        local DescLabel = SlimUI:Create("TextLabel", {Parent = ParagraphElement,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            RichText = true,
            Position = UDim2.new(0, 0, 0, 27),
            Size = UDim2.new(0, 263, 0, 0),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Paragraph.Desc or "",
            TextSize = 12,
            Visible = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Text"
            }
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 3)
            })
        })

        function Paragraph:SetDesc(Value)
            DescLabel.Visible = true
            DescLabel.Text = Value
        end

        if Paragraph.Desc then
            Paragraph:SetDesc(Paragraph.Desc)
        end

        if Paragraph.Color ~= "Default" then
            local UIStroke = SlimUI:Create("UIStroke", {Parent = ParagraphElement,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                Color = Colors[Paragraph.Color] or Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255)
            })
        else
            local UIStroke = SlimUI:Create("UIStroke", {Parent = ParagraphElement,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })
        end

        local ParagraphElementC = SlimUI:Create("UICorner", {
            Parent = ParagraphElement,
            CornerRadius = UDim.new(0, 7),
        })

        local ParagraphLabel = SlimUI:Create("TextLabel", {
            Parent = ParagraphElement,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            RichText = true,
            Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 35),
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Paragraph.Title,
            AutomaticSize = "Y",
            TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
            TextSize = Paragraph.TextSize,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Text"
            }
        })

        local ParagraphLabelUP = SlimUI:Create("UIPadding", {
            Parent = ParagraphLabel,
            PaddingLeft = UDim.new(0, 10),
        })

        local ParagraphIcon = SlimUI:Create("ImageLabel", {
            Parent = ParagraphElement,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            ImageTransparency = 1,
            Position = UDim2.new(0.025, 0,0.249, 0),
            Size = UDim2.new(0, 17, 0, 17),
            ImageColor3 = Color3.fromRGB(UITheme[Window.Theme].IconColor.R * 255, UITheme[Window.Theme].IconColor.G * 255, UITheme[Window.Theme].IconColor.B * 255),
            ThemeID = {
                ImageColor3 = "IconColor"
            }
        })
            if Paragraph.Icon then
                ParagraphIcon.ImageTransparency = 0
                if Paragraph.Icon and Icons.Icon(Paragraph.Icon) then
                    ParagraphIcon.Image = Icons.GetIcon(Paragraph.Icon)
                elseif Paragraph.Icon and string.find(Paragraph.Icon, "rbxassetid://") then
                    ParagraphIcon.Image = Paragraph.Icon
                end
                ParagraphLabelUP.PaddingLeft = UDim.new(0, 33)
            end

                function Paragraph:SetIcon(Icon)
                    ParagraphLabelUP.PaddingLeft = UDim.new(0, 33)
                    ParagraphIcon.ImageTransparency = 0

                    if Icon and Icons.Icon(Icon) then
                        ParagraphIcon.Image = Icons.Icon(Icon)
                    elseif Icon and string.find(Icon, "rbxassetid://") then
                        ParagraphIcon.Image = Icon
                    end
                    --ParagraphLabelUP.PaddingLeft = UDim.new(0, 28)
                end

                function Paragraph:RemoveIcon(Icon)
                    ParagraphLabelUP.PaddingLeft = UDim.new(0, 10)
                    ParagraphIcon.ImageTransparency = 1
                end

                function Paragraph:Close()
                    ParagraphElement:Destroy()
                end

                function Paragraph:SetTitle(Value)
                    ParagraphLabel.Text = Value
                end
            return Paragraph
        end
        local SectionCount = 0
        function Elements:Section(Config)
            SectionCount = SectionCount + 1
            local Section = {
                Title = Config.Title or "Section" .. SectionCount,
                Icon = Config.Icon,
                TextSize = Config.TextSize or 18,
                UIPadding = Config.UIPadding or UDim.new(0, 0),
            }
            local SectionElement = SlimUI:Create("Frame", {
                Name = Section.Title,
                Parent = ScrollElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.3038, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 20),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            })

            local SectionLabel = SlimUI:Create("TextLabel", {
                Parent = SectionElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 20),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Section.Title,
                TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
                TextSize = Section.TextSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })

            local SectionLabelUP = SlimUI:Create("UIPadding", {
                Name = "SectionLabelUP",
                Parent = SectionLabel,
                PaddingLeft = UDim.new(0, 22),
            })

            local SectionIcon = Instance.new("ImageLabel")
            if Section.Icon then
                local SectionIcon = SlimUI:Create("ImageLabel", {
                    Parent = SectionElement,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 1),
                    Size = UDim2.new(0, 20, 0, 20),
                    ImageColor3 = Color3.fromRGB(UITheme[Window.Theme].IconColor.R * 255, UITheme[Window.Theme].IconColor.G * 255, UITheme[Window.Theme].IconColor.B * 255),
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                })
                if Section.Icon and Icons.Icon(Section.Icon) then
                    SectionIcon.Image = Icons.GetIcon(Section.Icon)
                elseif Paragraph.Icon and string.find(Section.Icon, "rbxassetid://") then
                    SectionIcon.Image = Section.Icon
                end
            end

            if Section.Icon then
                SectionLabelUP.PaddingLeft = Section.UIPadding + UDim.new(0, 22)
            else
                SectionLabelUP.PaddingLeft = Section.UIPadding
            end
            function Section:Close()
                SectionElement:Destroy()
            end

            function Section:SetTitle(Value)
                SectionLabel.Text = Value
            end
            return Section
        end

        local SmallParagraphcount = 0
        function Elements:SmallParagraph(Config)
            SmallParagraphcount = SmallParagraphcount + 1
            local SmallParagraph = {
                Title = Config.Title or "Paragraph" .. SmallParagraphcount,
                Icon = Config.Icon,
                Color = Config.Color or "Default",
                Brightness = Config.Brightness or 28,
                TextSize = Config.TextSize or 11,
                TextXAlignment = Config.TextXAlignment or "Center"
            }

            local function createColor(r, g, b)
                return Color3.fromRGB(r + SmallParagraph.Brightness - 28, g + SmallParagraph.Brightness - 28, b + SmallParagraph.Brightness - 28)
            end

            local Colors = {
                Default = createColor(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
                Red = createColor(154, 0, 5),
                Green = createColor(41, 154, 0),
                Blue = createColor(0, 41, 154),
                Pink = createColor(154, 0, 154),
                Orange = createColor(154, 95, 0),
                Yellow = createColor(154, 141, 0),
                Ocyan = createColor(0, 133, 154),
                Purple = createColor(95, 0, 154),
            }

            local params = {
                Name = SmallParagraph.Title,
                Parent = ScrollElement,
                BackgroundTransparency = 0.2,
                BorderColor3 = Color3.new(0, 0, 0),
                AutomaticSize = "Y",
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 20),
            }

            if SmallParagraph.Color ~= "Default" then
                params.BackgroundColor3 = Colors[SmallParagraph.Color] or Color3.fromRGB(
                    UITheme[Window.Theme].ElementColor.R * 255,
                    UITheme[Window.Theme].ElementColor.G * 255,
                    UITheme[Window.Theme].ElementColor.B * 255
                )
            else
                params.ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            end

            local SmallParagraphElement = SlimUI:Create("Frame", params)

            if SmallParagraph.Color ~= "Default" then
            local UIStroke = SlimUI:Create("UIStroke", {
                Parent = SmallParagraphElement,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                Color = Colors[SmallParagraph.Color] or Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255)
            })
            else
                local UIStroke = SlimUI:Create("UIStroke", {
                    Parent = SmallParagraphElement,
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.7,
                    ThemeID = {
                        Color = "Outline"
                    }
                })
            end

            local SmallParagraphElementC = SlimUI:Create("UICorner", {
                Parent = SmallParagraphElement,
                CornerRadius = UDim.new(0, 7),
            })

            local SmallParagraphLabel = SlimUI:Create("TextLabel", {
                Parent = SmallParagraphElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 20),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = SmallParagraph.Title,
                TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
                TextSize = SmallParagraph.TextSize,
                TextWrapped = true,
                TextXAlignment = SmallParagraph.TextXAlignment,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })

            local SmallParagraphLabelUP = SlimUI:Create("UIPadding", {
                Parent = SmallParagraphLabel,
                PaddingLeft = UDim.new(0, 10),
            })

            if SmallParagraph.Icon then
                local SmallParagraphIcon = SlimUI:Create("ImageLabel", {
                    Parent = SmallParagraphElement,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.024, 0,0.099, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    ImageColor3 = Color3.fromRGB(UITheme[Window.Theme].IconColor.R * 255, UITheme[Window.Theme].IconColor.G * 255, UITheme[Window.Theme].IconColor.B * 255),
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                })
                if SmallParagraph.Icon and Icons.Icon(SmallParagraph.Icon) then
                    SmallParagraphIcon.Image = Icons.GetIcon(SmallParagraph.Icon)
                    SmallParagraphLabelUP.PaddingLeft = UDim.new(0, 25)
                elseif SmallParagraph.Icon and string.find(SmallParagraph.Icon, "rbxassetid://") then
                    SmallParagraphIcon.Image = SmallParagraph.Icon
                end

                if SmallParagraph.TextXAlignment == "Left" then
                    SmallParagraphLabelUP.PaddingLeft = UDim.new(0, 25)
                    SmallParagraphIcon.Position = UDim2.new(0.024, 0,0.125, 0)
                elseif SmallParagraph.TextXAlignment == "Right" then
                    SmallParagraphLabelUP.PaddingRight = UDim.new(0, 25)
                    SmallParagraphIcon.Position = UDim2.new(0.922, 0,0.125, 0)
                elseif SmallParagraph.TextXAlignment == "Center" then
                    SmallParagraphLabelUP.PaddingRight = UDim.new(0, 0)
                    SmallParagraphLabelUP.PaddingLeft = UDim.new(0, 0)
                    SmallParagraphIcon.Visible = false
                end
            else
                if SmallParagraph.TextXAlignment == "Left" then
                    SmallParagraphLabelUP.PaddingLeft = UDim.new(0, 5)
                elseif SmallParagraph.TextXAlignment == "Right" then
                    SmallParagraphLabelUP.PaddingRight = UDim.new(0, 5)
                elseif SmallParagraph.TextXAlignment == "Center" then
                    SmallParagraphLabelUP.PaddingRight = UDim.new(0, 0)
                end
            end

            function SmallParagraph:Close()
                SmallParagraphElement:Destroy()
            end

            function SmallParagraph:SetTitle(Value)
                SmallParagraphLabel.Text = Value
            end
            return SmallParagraph
        end

        local SliderCount = 0
        local HoldingSlider = false

        function Elements:Slider(Config)
            SliderCount = SliderCount + 1
            local Slider = {
                Title = Config.Title or "Slider " .. SliderCount,
                Locked = Config.Locked or false,
                Step = Config.Step or 1,
                Value = Config.Value or {},
                Callback = Config.Callback or function() end
            }
                        
            local SliderElement = SlimUI:Create("Frame", {
                Name = Slider.Title,
                Parent = ScrollElement,
                --BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
                BackgroundTransparency = 0.2,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = SliderElement,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local SliderElementC = SlimUI:Create("UICorner", {
                Parent = SliderElement,
                CornerRadius = UDim.new(0, 7),
            })

            local ParagraphLabel = SlimUI:Create("TextLabel", {
                Parent = SliderElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Slider.Title,
                TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })

            local ParagraphLabelUP = SlimUI:Create("UIPadding", {
                Parent = ParagraphLabel,
                PaddingLeft = UDim.new(0, 10),
            })

            local SliderBar = SlimUI:Create("Frame", {
                Name = "SliderBar",
                Parent = SliderElement,
                BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].Placeholder.R * 255, UITheme[Window.Theme].Placeholder.G * 255, UITheme[Window.Theme].Placeholder.B * 255),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, SliderElement.Size.X.Offset - 149, 0, 10),
                Size = UDim2.new(0, 105, 0, 13),
                ThemeID = {
                    BackgroundColor3 = "Placeholder"
                }
            })

            local SliderBarC = SlimUI:Create("UICorner", {
                Parent = SliderBar,
            })

            local SliderBarPart = SlimUI:Create("Frame", {
                Name = "SliderBarPart",
                Parent = SliderBar,
                Active = true,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 40, 0, 13),
            })

            local SliderBarPartC = SlimUI:Create("UICorner", {
                Parent = SliderBarPart,
            })

            local SliderBarTRG = SlimUI:Create("TextButton", {
                Name = "SliderBarTRG",
                Parent = SliderBar,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, -3.5),
                Size = UDim2.new(0, 105, 0, 20),
                Font = Enum.Font.SourceSans,
                TextColor3 = Color3.new(0, 0, 0),
                TextSize = 14,
                TextTransparency = 1,
            })

            local SliderValBG = SlimUI:Create("TextButton", {
                Parent = SliderElement,
                BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].Placeholder.R * 255, UITheme[Window.Theme].Placeholder.G * 255, UITheme[Window.Theme].Placeholder.B * 255),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, SliderElement.Size.X.Offset - 35, 0, 8.5),
                Size = UDim2.new(0, 28, 0, 17),
                ZIndex = 3,
                AutoButtonColor = false,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = "",
                TextColor3 = Color3.new(0, 0, 0),
                TextSize = 10,
                ThemeID = {
                    TextColor3 = "Text",
                    BackgroundColor3 = "Placeholder"
                }
            })

            local SliderValBGC = SlimUI:Create("UICorner", {
                Parent = SliderValBG,
                CornerRadius = UDim.new(0, 6),
            })

            local SliderValBG_2 = SlimUI:Create("TextBox", {
                Parent = SliderValBG,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 28, 0, 17),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                PlaceholderColor3 = Color3.new(1, 1, 1),
                Text = "",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 10,
                ZIndex = 5,
                TextStrokeColor3 = Color3.new(1, 1, 1),
                TextWrapped = true,
                ThemeID = {
                    TextColor3 = "Text",
                    BackgroundColor3 = "Placeholder"
                }
            })

            local SliderBGTextLab = SlimUI:Create("TextLabel", {
                Visible = false,
                Parent = SliderValBG,
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 28, 0, 17),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Slider.Value.Default,
                TextTransparency = 0,
                TextSize = 10,
                ZIndex = 6,
                TextWrapped = true,
                ThemeID = {
                    TextColor3 = "Text",
                }
            })
            local LockFrame = SlimUI:Create("Frame", {
                Parent = SliderElement,
                Visible = false,
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ZIndex = 7,
            },{
                SlimUI:Create("ImageLabel", {
                    BackgroundTransparency = 1.000,
                    ImageTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0.285714298, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    ZIndex = 8,
                    Image = "rbxassetid://101535132491169",
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                })
            })

            function Slider:Lock()
                ParagraphLabelUP.PaddingLeft = UDim.new(0, 23)
                SliderBarTRG.Visible = false
                SliderValBG_2.Visible = false
                LockFrame.Visible = true
                SliderBGTextLab.Visible = true
                Utility:TweenObject(SliderElement, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(ParagraphLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Utility:TweenObject(SliderBar, {Transparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(SliderBarPart, {Transparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Utility:TweenObject(DescLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end

            function Slider:UnLock()
                SliderBarTRG.Visible = true
                SliderValBG_2.Visible = true
                SliderBGTextLab.Visible = false
                Utility:TweenObject(SliderElement, {Transparency = 0.2}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Utility:TweenObject(SliderBar, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(SliderBarPart, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(ParagraphLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Utility:TweenObject(DescLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 1}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                ParagraphLabelUP.PaddingLeft = UDim.new(0, 10)
                LockFrame.Visible = false
            end

            Slider:UnLock()
            if Slider.Locked then
                Slider:Lock()
            end

            local Value
			local moveconnection
			local releaseconnection
			local isTouch = false
			local isFocusing = false

			SliderValBG_2.Focused:Connect(function()
				isFocusing = true
			end)

            SliderValBG_2.FocusLost:Connect(function(enterPressed)
                isFocusing = false
                if tonumber(SliderValBG_2.Text) then
                    local inputValue = tonumber(SliderValBG_2.Text)
                    local clampedValue = math.clamp(inputValue, Slider.Value.Min, Slider.Value.Max)

                    local roundedValue = math.round(clampedValue / Slider.Step) * Slider.Step
                    Value = roundedValue
                    SliderBGTextLab.Text = Value
                    SliderValBG_2.Text = Value
                    SliderBarPart.Size = UDim2.new((roundedValue - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min),0,1,0)
                    task.spawn(Slider.Callback, roundedValue)
                end
            end)
			
			local clampedDefault = math.clamp(Slider.Value.Default, Slider.Value.Min, Slider.Value.Max)
			Value = clampedDefault
			SliderBarPart.Size = UDim2.new((clampedDefault - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min), 0, 1, 0)
            SliderBGTextLab.Text = tostring(clampedDefault)
			SliderValBG_2.Text = tostring(clampedDefault)
			task.spawn(Slider.Callback, clampedDefault)
			
			SliderValBG_2:GetPropertyChangedSignal("Text"):Connect(function()
				if tonumber(SliderValBG_2.Text) then
					local inputValue = tonumber(SliderValBG_2.Text)
					local clampedValue = math.clamp(inputValue, Slider.Value.Min, Slider.Value.Max)
					Value = clampedValue
                    Utility:TweenObject(SliderBarPart, {Size = UDim2.new((clampedValue - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min), 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
					--SliderBarPart.Size = UDim2.new((clampedValue - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min), 0, 1, 0)
					task.spawn(Slider.Callback, clampedValue)
				end
			end)

            local ScrollFrame = SlimUI:Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BackgroundTransparency = 0.050,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Visible = false,
                Transparency = 1,
                Size = UDim2.new(0, 30, 0, 18),
                ZIndex = 5,
                ThemeID = {
                    BackgroundColor3 = "Placeholder",
                }
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                }),
                SlimUI:Create("TextLabel", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1.000,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Size = UDim2.new(0, 30, 0, 18),
                    FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10.000,
                    ThemeID = {
                        TextColor3 = "Text",
                    }
                })
            })


            SliderBarTRG.InputBegan:Connect(function(input)
                if not isFocusing and not HoldingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    isTouch = (input.UserInputType == Enum.UserInputType.Touch)
                    HoldingSlider = true

                    if not ScrollFrame.Parent then
                        ScrollFrame.Parent = SliderBarPart
                    end
                    ScrollFrame.Visible = true

                    if moveconnection then
                        moveconnection:Disconnect()
                        moveconnection = nil
                    end
                    if releaseconnection then
                        releaseconnection:Disconnect()
                        releaseconnection = nil
                    end

                    Utility:TweenObject(ScrollFrame, {Transparency = 0.1}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    Utility:TweenObject(ScrollFrame.TextLabel, {TextTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                    moveconnection = game:GetService("RunService").RenderStepped:Connect(function()
                        local inputPosition
                        if isTouch then
                            inputPosition = input.Position.X
                        else
                            inputPosition = game:GetService("UserInputService"):GetMouseLocation().X
                        end
                        local delta = math.clamp((inputPosition - SliderBarPart.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Value = math.floor((Slider.Value.Min + delta * (Slider.Value.Max - Slider.Value.Min)) / Slider.Step + 0.5) * Slider.Step
                        Utility:TweenObject(SliderBarPart, {Size = UDim2.new(delta, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                        SliderValBG_2.Text = tostring(Value)
                        SliderBGTextLab.Text = tostring(Value)
                        ScrollFrame.TextLabel.Text = tostring(Value)

                        ScrollFrame.Position = UDim2.new(delta, 0, -1.5, -5)
                        task.spawn(Slider.Callback, Value)
                    end)

                    releaseconnection = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
                        if (endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch) and input == endInput then
                            if moveconnection then
                                moveconnection:Disconnect()
                                moveconnection = nil
                            end
                            if releaseconnection then
                                releaseconnection:Disconnect()
                                releaseconnection = nil
                            end
                            HoldingSlider = false

                            Utility:TweenObject(ScrollFrame, {Transparency = 1}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            Utility:TweenObject(ScrollFrame.TextLabel, {TextTransparency = 1}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            wait(0.1)
                            ScrollFrame.Visible = false
                        end
                    end)
                end
            end)

            function Slider:Close()
                SliderElement:Destroy()
            end

            function Slider:SetTitle(Value)
                ParagraphLabel.Text = Value
            end

            function Slider:SetValue(Value)
                SliderBGTextLab.Text = "" .. Value .. ""
				SliderValBG_2.Text = "" .. Value .. ""
                Utility:TweenObject(SliderBarPart, {Size = UDim2.new((Value - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min), 0, 1, 0)}, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				--SliderBarPart.Size = UDim2.new((Value - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min), 0, 1, 0)
				task.spawn(Slider.Callback, Value)
            end
            return Slider
        end

        local DropDownCount = 0
        function Elements:DropDown(Config)
            local Dropdown = {
                Title = Config.Title or "DropDown" .. DropDownCount,
                Value = Config.Value or "",
                Locked = Config.Locked or false,
                Multi = Config.Multi or false,
                Option = Config.Option or {},
                Options = Config.Options or {},
                Callback = Config.Callback or function() end
            }
            
            local DropDownElement = SlimUI:Create("Frame", {
                Name = Dropdown.Title,
                Parent = ScrollElement,
                BackgroundColor3 = Color3.fromRGB(0, 30, 53),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(-0.00719424477, 0, 0.527426183, 0),
                AutomaticSize = "Y",
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 25),
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 7),
                }),
                SlimUI:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                })
            })

            local DropFrame = SlimUI:Create("Frame", {
                Parent = DropDownElement,
                BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
                BackgroundTransparency = 0,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                },
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 7),
                })
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = DropFrame,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local DropDownLabel = SlimUI:Create("TextLabel", {Parent = DropFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 35),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Dropdown.Title,
                RichText = true,
                TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                },
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                })
            })

            local DropDownTRG = SlimUI:Create("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 35),
                TextSize = 1,
                TextTransparency = 1,
            })

            local DropElementFrame = SlimUI:Create("Frame", {
                Name = "DropElementFrame",
                Parent = DropDownElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                --AutomaticSize = "Y",
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 0),
            },{
                SlimUI:Create("UISizeConstraint", {
                    MinSize = Vector2.new(Window.Size.X.Offset - 17 - Window.SideBarWidth,0),
                    MaxSize = Vector2.new(Window.Size.X.Offset - 17 - Window.SideBarWidth,10000) -- X, Y
                })
            })

            local ScrollingFrame = SlimUI:Create("ScrollingFrame", {
                Name = "ScrollingFrame",
                Parent = DropElementFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                AutomaticCanvasSize = "Y",
                ScrollingDirection = "Y",
                ClipsDescendants = false,
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 0),
            },{
                SlimUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0,5),
                    PaddingLeft = UDim.new(0,2),
                    PaddingRight = UDim.new(0.6),
                    PaddingBottom = UDim.new(0,0),
                }),
            })

            local DropElementFrameULL = SlimUI:Create("UIListLayout", {
                Parent = ScrollingFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            })

            local DropDownOptionElm = SlimUI:Create("Frame", {Parent = DropFrame,
                BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, DropFrame.Size.X.Offset - 103, 0.22857143, 0),
                Size = UDim2.new(0, 96, 0, 18),
                ThemeID = {
                    BackgroundColor3 = "Placeholder",
                },
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 7),
                })
            })

            local OPTUIStroke = SlimUI:Create("UIStroke", {Parent = DropDownOptionElm,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })
            
            local DropIcon = SlimUI:Create("ImageLabel", {Parent = DropDownOptionElm,
                Parent = DropDownOptionElm,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, DropDownOptionElm.Size.X.Offset - 23, 0, 1),
                Size = UDim2.new(0, 17, 0, 17),
                Rotation = 180,
                ImageColor3 = Color3.fromRGB(UITheme[Window.Theme].IconColor.R * 255, UITheme[Window.Theme].IconColor.G * 255, UITheme[Window.Theme].IconColor.B * 255),
                Image = "rbxassetid://92757382869764",
                ZIndex = 6,
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })

            local DropOptionBox = SlimUI:Create("TextBox", {
                Parent = DropDownOptionElm,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0140501661, 0, 0.055555556, 0),
                Size = UDim2.new(0, 59, 0, 17),
                ZIndex = 5,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Dropdown.Value,
                TextColor3 = Color3.new(0.764706, 0.764706, 0.764706),
                TextSize = 10,
                TextStrokeColor3 = Color3.new(1, 1, 1),
                --TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                },
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 4),
                })
            })

            local DropOptionBoxLib = SlimUI:Create("TextLabel", {
                Parent = DropDownOptionElm,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0140501661, 0, 0.055555556, 0),
                Size = UDim2.new(0, 59, 0, 17),
                ZIndex = 5,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Dropdown.Value,
                TextColor3 = Color3.new(0.764706, 0.764706, 0.764706),
                TextSize = 10,
                TextTransparency = 0.6,
                TextStrokeColor3 = Color3.new(1, 1, 1),
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                },
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 4),
                })
            })

        local LockFrame = SlimUI:Create("Frame", {
            Parent = DropFrame,
            Visible = false,
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
            ZIndex = 7,
        },{
            SlimUI:Create("ImageLabel", {
                BackgroundTransparency = 1.000,
                ImageTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0.285714298, 0),
                Size = UDim2.new(0, 15, 0, 15),
                ZIndex = 8,
                Image = "rbxassetid://101535132491169",
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
        })

            function Dropdown:Lock()
                DropDownLabel.UIPadding.PaddingLeft = UDim.new(0, 23)
                DropDownTRG.Visible = false
                LockFrame.Visible = true
                DropOptionBox.Visible = false
                DropOptionBoxLib.Visible = true
                Utility:TweenObject(OPTUIStroke, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DropFrame, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DropDownLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DropIcon, {ImageTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Close Dropdown
                DropOption = false
                Utility:TweenObject(DropElementFrame, {Size = UDim2.new(0,DropElementFrameULL.AbsoluteContentSize.X,0,0)}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                Utility:TweenObject(ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0,0), PaddingBottom = UDim.new(0,0)}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                Utility:TweenObject(DropElementFrame, {Position = UDim2.new(0,0,0,35)}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                Utility:TweenObject(DropIcon, {Rotation = 180}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            end

            function Dropdown:UnLock()
                DropDownTRG.Visible = true
                DropOptionBox.Visible = true
                DropOptionBoxLib.Visible = false
                Utility:TweenObject(OPTUIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DropFrame, {Transparency = 0.2}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DropIcon, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DropDownLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 1}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                DropDownLabel.UIPadding.PaddingLeft = UDim.new(0, 10)
                --wait(0.05)
                LockFrame.Visible = false
            end

            Dropdown:UnLock()
            if Dropdown.Locked then
                Dropdown:Lock()
            end
            local DropOption = false
            local isUserTyping = false

            DropOptionBox.Focused:Connect(function()
                isUserTyping = true
            end)

            DropOptionBox.FocusLost:Connect(function()
                isUserTyping = false
                if DropOptionBox.Text == "" then
                    DropOptionBox.Text = ""
                    DropOptionBoxLib.Text = ""
                end
            end)

            function Dropdown.updateResults(query)
                local lowerQuery = string.lower(query)
                for _, v in next, ScrollingFrame:GetChildren() do
                    if v:IsA("Frame") then
                        local textLabel = v:FindFirstChildOfClass("TextLabel")
                        local textButton = v:FindFirstChildOfClass("TextButton")
                        
                        if textLabel and string.lower(textLabel.Text):find(lowerQuery) then
                            v.Visible = true
                        elseif textButton and string.lower(textButton.Text):find(lowerQuery) then
                            v.Visible = true
                        else
                            v.Visible = false
                            DropOption = true
                            Utility:TweenObject(DropElementFrame, {Size = UDim2.new(0,DropElementFrameULL.AbsoluteContentSize.X,0,DropElementFrameULL.AbsoluteContentSize.Y+12)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                            Utility:TweenObject(ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                            Utility:TweenObject(DropElementFrame, {Position = UDim2.new(0,0,0,0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                            Utility:TweenObject(DropIcon, {Rotation = 0}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                        end
                    end
                end
            end

            DropOptionBox:GetPropertyChangedSignal("Text"):Connect(function()
                local query = DropOptionBox.Text
                DropOptionBoxLib.Text = query
                if isUserTyping and query ~= "" then
                    DropOptionBox.TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255)
                    Dropdown.updateResults(query)
                else
                    DropOptionBox.TextColor3 = Color3.fromRGB(117, 117, 117)
                    for _, v in next, ScrollingFrame:GetChildren() do
                        if v:IsA("Frame") then
                            v.Visible = true
                        end
                    end
                end
            end)

            DropDownTRG.MouseButton1Click:Connect(function()
                if DropOption then
                    Utility:TweenObject(DropElementFrame, {Size = UDim2.new(0,DropElementFrameULL.AbsoluteContentSize.X,0,0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0,0), PaddingBottom = UDim.new(0,0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(DropElementFrame, {Position = UDim2.new(0,0,0,35)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(DropIcon, {Rotation = 180}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                else
                    Utility:TweenObject(DropElementFrame, {Size = UDim2.new(0,DropElementFrameULL.AbsoluteContentSize.X,0,DropElementFrameULL.AbsoluteContentSize.Y+12)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(DropElementFrame, {Position = UDim2.new(0,0,0,0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(DropIcon, {Rotation = 0}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                end
                DropOption = not DropOption
            end)

                function Dropdown:Refresh(Val)
                    for _, v in next, ScrollingFrame:GetChildren() do
                        if v:IsA("Frame") then
                            v:Destroy()
                        end
                    end

                    local Items = {}
                    for _, Item in ipairs(Dropdown.Option) do

                        local DropElement = SlimUI:Create("Frame", {
                            Name = Item,
                            Parent = ScrollingFrame,
                            BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
                            BorderColor3 = Color3.new(0, 0, 0),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.5,
                            AutomaticSize = "Y",
                            Size = UDim2.new(0, Window.Size.X.Offset - 23 - Window.SideBarWidth, 0, 20),
                            ThemeID = {
                                BackgroundColor3 = "ElementColor"
                            },
                            ZIndex = 1
                        },{
                            SlimUI:Create("UICorner", {
                                CornerRadius = UDim.new(0, 5),
                            }),
                            SlimUI:Create("UIStroke", {
                                Color = Color3.fromRGB(255, 255, 255),
                                LineJoinMode = "Round",
                                Thickness = 0.7,
                                ThemeID = {
                                    Color = "Outline",
                                }
                            })
                        })

                        local DropElementTRG = SlimUI:Create("TextButton", {
                            Parent = DropElement,
                            BackgroundColor3 = Color3.new(1, 1, 1),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.new(0, 0, 0),
                            BorderSizePixel = 0,
                            Text = Item,
                            AutomaticSize = "Y",
                            TextTransparency = 0.6,
                            TextWrapped = true,
                            Position = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0, Window.Size.X.Offset - 23 - Window.SideBarWidth, 0, 20),
                            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            TextColor3 = Color3.new(1, 1, 1),
                            TextSize = 11,
                            ThemeID = {
                                TextColor3 = "Text"
                            },
                            ZIndex = 2
                        })

                        MultiClick = false
                        DropElementTRG.MouseButton1Click:Connect(function()
                            DropOptionBox.Text = Item
                            DropOptionBoxLib.Text = Item
                            if not Dropdown.Multi then
                                for _, i in pairs(Items) do
                                    i.Selected = false
                                end
                                task.spawn(Dropdown.Callback, Item)
                                Utility:TweenObject(DropElementFrame, {Size = UDim2.new(0,DropElementFrameULL.AbsoluteContentSize.X,0,DropElementFrameULL.AbsoluteContentSize.Y+12)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                                for _, v in next, ScrollingFrame:GetChildren() do
                                    if v:IsA("Frame") then
                                        Utility:TweenObject(v, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                        if v == DropElement then
                                            Utility:TweenObject(DropElement, {BackgroundTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                        end
                                        if v:FindFirstChildOfClass("TextButton") then
                                            Utility:TweenObject(v.TextButton, {TextTransparency = 0.6}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                            if v == DropElement then
                                                Utility:TweenObject(DropElementTRG, {TextTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                            end
                                        end
                                    end
                                end
                            else
                                MultiClick = not MultiClick
                                if MultiClick then
                                    table.insert(Dropdown.Options, Item)
                                    Utility:TweenObject(DropElementTRG, {BackgroundTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                    Utility:TweenObject(DropElement, {BackgroundTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                else
                                    for i = #Dropdown.Options, 1, -1 do
                                        if Dropdown.Options[i] == Item then
                                            table.remove(Dropdown.Options, i)
                                            break
                                        end
                                    end
                                    Utility:TweenObject(DropElementTRG, {BackgroundTransparency = 0.6}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                    Utility:TweenObject(DropElement, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                end
                                spawn(function()
                                    pcall(Dropdown.Callback, table.concat(Dropdown.Options:map(function(o) return "\"".. o.. "\"" end), ", "))
                                end)
                            end
                        end)
                        Items[#Items + 1] = {DropElement = DropElement, Selected = false }
                    end
                    return Dropdown, Items
                end

                Dropdown:Refresh(Dropdown.Option)

                DropElementFrame.Size = UDim2.new(0,DropElementFrameULL.AbsoluteContentSize.X,0,0)
                    function Dropdown:Close()
                        DropDownElement:Destroy()
                    end

                    function Dropdown:SetTitle(Value)
                        DropDownLabel.Text = Value
                    end
            return Dropdown
        end
        local InputCount = 0
        function Elements:Input(Config)
            InputCount = InputCount + 1
            local Input = {
                Title = Config.Title or "Input " .. InputCount,
                Desc = Config.Desc or nil,
                Value = Config.Value or "",
                Locked = Config.Locked or false,
                MaxSymbols = Config.MaxSymbols or nil,
                Callback = Config.Callback or function() end
            }

            local InputElement = SlimUI:Create("Frame", {
                Name = Input.Title,
                Parent = ScrollElement,
                BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
                BorderColor3 = Color3.new(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                BackgroundTransparency = 0.2,
                Position = UDim2.new(0.0179856122, 0, 0.708860755, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 7),
                })
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = InputElement,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local InputLabel = SlimUI:Create("TextLabel", {
                Parent = InputElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17, 0, 35),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Input.Title,
                RichText = true,
                TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text",
                }
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })

            local Point = SlimUI:Create("Frame", {
                Parent = InputElement,
                BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].Placeholder.R * 255, UITheme[Window.Theme].Placeholder.G * 255, UITheme[Window.Theme].Placeholder.B * 255),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Position = UDim2.new(0, InputElement.Size.X.Offset - (Input.MaxSymbols and 130 or 100), 0, 8.5),
                Size = UDim2.new(0, 89, 0, 17),
                ThemeID = {
                    BackgroundColor3 = "Placeholder",
                }
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                })
            })

            local OPTUIStroke = SlimUI:Create("UIStroke", {Parent = Point,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })


            local InputBox = SlimUI:Create("TextBox", {
                Parent = Point,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ClearTextOnFocus = false,
                Size = UDim2.new(0, 85, 0, 17),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Input.Value,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 11,
                TextStrokeColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text",
                }
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                })
            })

            local InputBoxLib = SlimUI:Create("TextLabel", {
                Visible = false,
                Parent = Point,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                TextTransparency = 0.6,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2.new(0, 85, 0, 17),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Input.Value,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 11,
                TextStrokeColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text",
                }
            },{
                SlimUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                })
            })

            --PointUP.Name = "PointUP"
            --PointUP.Parent = Point

            if Input.MaxSymbols then
                InputBox.MaxVisibleGraphemes = Input.MaxSymbols

                local Max = SlimUI:Create("TextLabel", {
                    Parent = InputElement,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1.000,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Position = UDim2.new(0, InputElement.Size.X.Offset - 40, 0, 11), --UDim2.new(0.83773607, 0, 0, 0) 
                    Size = UDim2.new(0, 34, 0, 10),
                    Text = #InputBox.Text .. " / " .. Input.MaxSymbols, -- "99/0"
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    ThemeID = {
                        TextColor3 = "Text"
                    }
                })

                InputBox.Changed:Connect(function(property)
                    if property == "Text" then
                        local textLength = #InputBox.Text
                        if textLength > Input.MaxSymbols then
                            InputBox.Text = string.sub(InputBox.Text, 1, Input.MaxSymbols)
                            textLength = Input.MaxSymbols
                        end
                        Max.Text = textLength .." / " .. Input.MaxSymbols
                    end
                end)

                function Input:SetMaxSymbols(number)
                    Input.MaxSymbols = number
                    InputBox.MaxVisibleGraphemes = Input.MaxSymbols
                    Max.Text = #InputBox.Text .." / " .. Input.MaxSymbols
                end
            end

            local DescLabel = SlimUI:Create("TextLabel", {Parent = InputElement,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Position = UDim2.new(0, 0, 0, 27),
                Size = UDim2.new(0, 263, 0, 0),
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = "",
                TextSize = 12,
                Visible = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
                },{
                    SlimUI:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        PaddingBottom = UDim.new(0, 3)
                })
            })

            local LockFrame = SlimUI:Create("Frame", {
                Parent = InputElement,
                Visible = false,
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ZIndex = 7,
            },{
                SlimUI:Create("ImageLabel", {
                    BackgroundTransparency = 1.000,
                    ImageTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0.285714298, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    ZIndex = 8,
                    Image = "rbxassetid://101535132491169",
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                })
            })

            function Input:Lock()
                InputLabel.UIPadding.PaddingLeft = UDim.new(0, 23)
                --BTNTextButton.Visible = false
                LockFrame.Visible = true
                InputBoxLib.Visible = true
                InputBox.Visible = false
                Utility:TweenObject(InputElement, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(InputLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Utility:TweenObject(BTNImage, {ImageTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DescLabel, {TextTransparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0.7}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(OPTUIStroke, {Transparency = 0.6}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end

            function Input:UnLock()
                InputBoxLib.Visible = false
                InputBox.Visible = true
                --BTNTextButton.Visible = true
                Utility:TweenObject(InputElement, {Transparency = 0.2}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                --Utility:TweenObject(BTNImage, {ImageTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(InputLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(DescLabel, {TextTransparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(LockFrame.ImageLabel, {ImageTransparency = 1}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(OPTUIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                Utility:TweenObject(UIStroke, {Transparency = 0}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                InputLabel.UIPadding.PaddingLeft = UDim.new(0, 10)
                --wait(0.05)
                LockFrame.Visible = false
            end

            Input:UnLock()
            if Input.Locked then
                Input:Lock()
            end

            function Input:SetDesc(Value)
                DescLabel.Visible = true
                DescLabel.Text = Value
            end
            
            if Input.Desc then
                Input:SetDesc(Input.Desc)
            end

            local function PInput()
                if Input.MaxSymbols then
                    spawn(function()
                        pcall(Input.Callback, string.sub(InputBox.Text, 1, Input.MaxSymbols))
                    end)
                else
                    spawn(function()
                        pcall(Input.Callback, InputBox.Text)
                    end)
                end
            end

            PInput()
            InputBox.FocusLost:Connect(function(EnterPressed)
                if not EnterPressed then return end
                PInput()
                InputBoxLib.Text = InputBox.Text
            end)

                function Input:Close()
                    InputElement:Destroy()
                end

                function Input:SetValue(Val)
                    InputBox.Text = Val
                    task.spawn(Input.Callback, Val)
                end

                function Input:SetTitle(Value)
                    InputLabel.Text = Value
                end
            return Input
        end
        local KeybindCount = 0
        function Elements:Keybind(Config)
            KeybindCount = KeybindCount + 1
            local Keybind = {
                Title = Config.Title or "Keybind " .. KeybindCount,
                Desc = Config.Desc or nil,
                Locked = Config.Locked or false,
                Value = Config.Value or "F",
                Callback = Config.Callback or function() end
            }

            local oldKey = Keybind.Value

            local KeybindElement = SlimUI:Create("Frame", {
                Name = Keybind.Title,
                Parent = ScrollElement,
                --BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].ElementColor.R * 255, UITheme[Window.Theme].ElementColor.G * 255, UITheme[Window.Theme].ElementColor.B * 255),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.2,
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0.0179856122, 0, 0.708860755, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            })

            local ElementC = SlimUI:Create("UICorner", {
                Name = "ElementC",
                Parent = KeybindElement,
                CornerRadius = UDim.new(0, 7),
            })

            local KeybindLabel = SlimUI:Create("TextLabel", {
                Parent = KeybindElement,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 35),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Keybind.Title,
                RichText = true,
                --TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255),
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })

            local LabelUP = SlimUI:Create("UIPadding", {
                Parent = KeybindLabel,
                PaddingLeft = UDim.new(0, 10),
            })

            local Point = SlimUI:Create("TextButton", {
                Name = "Point",
                Parent = KeybindElement,
                BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].Placeholder.R * 255, UITheme[Window.Theme].Placeholder.G * 255, UITheme[Window.Theme].Placeholder.B * 255),
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(0, KeybindElement.Size.X.Offset - 35, 0, 8.5),
                TextSize = 11,
                Size = UDim2.new(0, 28, 0, 17),
                Text = Keybind.Value,
                ThemeID = {
                    BackgroundColor3 = "Placeholder",
                    TextColor3 = "Text"
                }
            })

            local PointC = SlimUI:Create("UICorner", {
                Name = "PointC",
                Parent = Point,
            })

            local PointUP = SlimUI:Create("UIPadding", {
                Name = "PointUP",
                Parent = Point,
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = KeybindElement,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local DescLabel = SlimUI:Create("TextLabel", {Parent = KeybindElement,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                RichText = true,
                Position = UDim2.new(0, 0, 0, 27),
                Size = UDim2.new(0, 263, 0, 0),
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Keybind.Desc or "",
                TextSize = 12,
                Visible = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
                },{
                    SlimUI:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        PaddingBottom = UDim.new(0, 3)
                })
            })

            function Keybind:SetDesc(Value)
                DescLabel.Visible = true
                DescLabel.Text = Value
            end
            
            if Keybind.Desc then
                Keybind:SetDesc(Keybind.Desc)
            end

            spawn(function()
                pcall(Keybind.Callback, Keybind.Value)
            end)
                Point.MouseButton1Click:connect(function(e) 
                    Point.Text = ". . ."
                    local a, b = game:GetService('UserInputService').InputBegan:wait();
                    if a.KeyCode.Name ~= "Unknown" then
                        --keybindFrame:TweenSize(UDim2.new(0, 365,0, 36), "InOut", "Quint", 0.18, true)
                        Point.Text = a.KeyCode.Name
                        oldKey = a.KeyCode.Name
                        spawn(function()
                            pcall(Keybind.Callback, a.KeyCode.Name)
                        end)
                    end
                end)

                function Keybind:Close()
                    KeybindElement:Destroy()
                end

                function Keybind:SetValue(Val)
                    Point.Text = Val
                    task.spawn(Keybind.Callback, Val)
                end

                function Keybind:SetTitle(Value)
                    KeybindLabel.Text = Value
                end
            return Keybind
        end

        function Elements:Traffic(Config)
            local trafic = {
                Title = Config.Title or "",
                Value = Config.Value or 0,
            }
            local Trafic = Instance.new("Frame")
            local TraficC = Instance.new("UICorner")
            local Down = Instance.new("Frame")
            local DownC = Instance.new("UICorner")
            local Top = Instance.new("Frame")
            local TopC = Instance.new("UICorner")
            local TopUP = Instance.new("UIPadding")
            local TopULL = Instance.new("UIListLayout")

            local Trafic = SlimUI:Create("Frame", {
                Parent = ScrollElement,
                BackgroundColor3 = Color3.fromRGB(42, 42, 42),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 116),
                ThemeID = {
                    BackgroundColor3 = "ElementColor"
                }
            })

            local UIStroke = SlimUI:Create("UIStroke", {Parent = Trafic,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local TraficC = SlimUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 10),
                Parent = Trafic,
            })

            local Down = SlimUI:Create("Frame", {
                Parent = Trafic,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0150943398, 0, 0.706421971, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 26 - Window.SideBarWidth, 0, 28),
                ThemeID = {
                    BackgroundColor3 = "Background"
                }
            })

            local UIStroke1 = SlimUI:Create("UIStroke", {Parent = Down,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local DLabel = SlimUI:Create("TextLabel", {
                Parent = Down,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(0, Down.Size.X.Offset - 70, 0, Down.Size.Y.Offset - 16),
                Size = UDim2.new(0, 67, 0, 16),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = "Max:  0",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 11.000,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local DTitle = Instance.new("TextLabel")
            local UIPadding = Instance.new("UIPadding")

            local DTitle = SlimUI:Create("TextLabel", {
                Parent = Down,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 183, 0, 28),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = trafic.Title,
                TextWrapped = true,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13.000,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })

            UIPadding.Parent = DTitle
            UIPadding.PaddingLeft = UDim.new(0, 10)

            local DownC = SlimUI:Create("UICorner", {
                Parent = Down,
            })

            local Top = SlimUI:Create("Frame", {
                Parent = Trafic,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Position = UDim2.new(0.0150943398, 0, 0.0733944923, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 26 - Window.SideBarWidth, 0, 69),
                ThemeID = {
                    BackgroundColor3 = "Background"
                }
            })

            local UIStroke2 = SlimUI:Create("UIStroke", {Parent = Top,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.7,
                ThemeID = {
                    Color = "Outline",
                }
            })

            local Framee = SlimUI:Create("Frame", {
                Parent = Top,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Transparency = 1,
                ClipsDescendants = true,
                Position = UDim2.new(0.03515625, 0, 0, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 42 - Window.SideBarWidth, 0, 69),
            })

            TopC.Name = "TopC"
            TopC.Parent = Top

            TopUP.Name = "TopUP"
            TopUP.Parent = Framee
            TopUP.PaddingLeft = UDim.new(0, Pisun)

            TopULL.Name = "TopULL"
            TopULL.Parent = Framee
            TopULL.SortOrder = Enum.SortOrder.LayoutOrder
            TopULL.VerticalAlignment = Enum.VerticalAlignment.Bottom
            TopULL.Padding = UDim.new(0, 3)
            TopULL.FillDirection = Enum.FillDirection.Horizontal

            local bars = {}
            local barWidth = 6
            local minHeight = 5
            local maxHeight = 60
            local midHeight = (minHeight + maxHeight) / 2
            local running = true

            local minHeight = 5
            local maxHeight = 60
            local maxHeightOverflow = 80

            local MaxVal = Config.MaxVal or 1

            function trafic:getBarHeight(val)
                if val <= MaxVal then
                    return minHeight + (maxHeight - minHeight) * (val / MaxVal)
                else
                    local overflowVal = val - MaxVal
                    local overflowMax = MaxVal
                    local overflowRatio = math.clamp(overflowVal / overflowMax, 0, 1)
                    return maxHeight + (maxHeightOverflow - maxHeight) * overflowRatio
                end
            end

            function trafic:CreateBar(Val)
                local TraficBarC = Instance.new("UICorner")

                local TraficBar = SlimUI:Create("Frame", {
                    Name = "TraficBar",
                    Parent = Framee,
                    BackgroundColor3 = Color3.fromRGB(255, 41, 41),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, barWidth, 0, 5),
                    ThemeID = {
                        BackgroundColor3 = "Text"
                    }
                })

                local height = trafic:getBarHeight(Val or 0)
                --TraficBar.Size = UDim2.new(0, barWidth, 0, height)

                TraficBarC.Name = "TraficBarC"
                TraficBarC.Parent = TraficBar

                local TraficBarFr = SlimUI:Create("Frame", {
                    Name = "TraficBarFr",
                    Parent = TraficBar,
                    BackgroundColor3 = Color3.fromRGB(255, 41, 41),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(0, barWidth, 0, -5),
                    ThemeID = {
                        BackgroundColor3 = "Text"
                    }
                })

                local StatBar = Instance.new("Frame")
                local StatBarC = Instance.new("UICorner")

                local StatBar = SlimUI:Create("Frame", {
                    Name = "StatBar",
                    Parent = TraficBar,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    AutomaticSize = "XY",
                    Transparency = 1,
                    Position = UDim2.new(1.66666663, 0, -0.0286694691, 0),
                    Size = UDim2.new(0, 37, 0, 15),
                    ThemeID = {
                        BackgroundColor3 = "Placeholder"
                    }
                })

                StatBarC.CornerRadius = UDim.new(0, 5)
                StatBarC.Name = "StatBarC"
                StatBarC.Parent = StatBar

                local StatBarLabel = SlimUI:Create("TextLabel", {
                    Name = "StatBarLabel",
                    Parent = StatBar,
                    TextTransparency = 1,
                    AutomaticSize = "XY",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1.000,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Position = UDim2.new(0, 0, 0.0649820939, 0),
                    Size = UDim2.new(0, 37, 0, 14),
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = Val,
                    TextSize = 10.000,
                    ThemeID = {
                        TextColor3 = "Text"
                    }
                })

                TraficBar.MouseEnter:Connect(function()
                    Utility:TweenObject(StatBar, {Transparency = 0}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    Utility:TweenObject(StatBarLabel, {TextTransparency = 0}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                end)

                TraficBar.MouseLeave:Connect(function()
                    Utility:TweenObject(StatBar, {Transparency = 1}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    Utility:TweenObject(StatBarLabel, {TextTransparency = 1}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                end)
                Utility:TweenObject(TraficBar, {Size = UDim2.new(0, barWidth, 0, height)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                table.insert(bars, TraficBar)
            end

            local Pisun = 0

            function trafic:SetValue(e)
                if MaxVal < e then 
                    MaxVal = e
                    DLabel.Text = "Max: " .. e
                end
                if running then
                    trafic:CreateBar(e)

                    if bars[#bars] then
                        if TopULL.AbsoluteContentSize.X + Pisun >= Framee.AbsoluteSize.X then
                            Pisun = Pisun - 9
                            TopUP.PaddingLeft = UDim.new(0, Pisun)
                        end
                    end

                    local firstBar = bars[1]
                    if firstBar then
                        if (firstBar.AbsolutePosition.X + firstBar.AbsoluteSize.X) < Framee.AbsolutePosition.X then
                            firstBar:Destroy()
                            table.remove(bars, 1)
                            Pisun = Pisun + (barWidth + 3)
                            TopUP.PaddingLeft = UDim.new(0, Pisun)
                        end
                    end
                end
            end

            trafic:SetValue(trafic.Value)

            function trafic:SetTitle(text)
                DTitle.Text = text
            end

            function trafic:Reset()
                MaxVal = 0
                DLabel.Text = "Max: " .. MaxVal
                trafic:CreateBar(e)
            end

            return trafic
        end

        function Elements:SmallElement(Config)
            local MiniElement = SlimUI:Create("Frame", {
                Name = "MiniElement",
                Parent = ScrollElement,
                BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = "Y",
                Position = UDim2.new(0, 0, 0.160337552, 0),
                Size = UDim2.new(0, Window.Size.X.Offset - 17 - Window.SideBarWidth, 0, 22),
            })

            local MiniElementC = SlimUI:Create("UICorner", {
                Name = "MiniElementC",
                Parent = MiniElement,
                CornerRadius = UDim.new(0, 5),
            })

            local UIListLayout = SlimUI:Create("UIListLayout", {
                Parent = MiniElement,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            })

            local totalLimit = 10
            local totalCount = 0

            local buttonCount = 0
            if Config.Button then
                for _ in pairs(Config.Button) do
                    buttonCount = buttonCount + 1
                    if buttonCount >= totalLimit then
                        buttonCount = totalLimit
                        break
                    end
                end
            else
                buttonCount = 0
            end

            local toggleCount = 0
            if Config.Toggle then
                for _ in pairs(Config.Toggle) do
                    toggleCount = toggleCount + 1
                    if (buttonCount + toggleCount) >= totalLimit then
                        toggleCount = totalLimit - buttonCount
                        break
                    end
                end
            else
                toggleCount = 0
            end

            local totalElements = buttonCount + toggleCount
            if totalElements > totalLimit then
                totalElements = totalLimit
            end

            local totalWidth = Window.Size.X.Offset - 17 - Window.SideBarWidth
            local padding = 5
            local totalPadding = (totalElements > 1) and (totalElements - 1) * padding or 0
            local elementWidth = 0

            if totalElements > 0 then
                elementWidth = (totalWidth - totalPadding) / totalElements
            else
                elementWidth = 0
            end

            if Config.Button then
                for _, ButtonElement in pairs(Config.Button) do
                    if totalCount >= totalLimit then break end

                    local MiniBTNElement = SlimUI:Create("Frame", {
                        Name = ButtonElement.Title,
                        Parent = MiniElement,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 0.2,
                        BorderSizePixel = 0,
                        AutomaticSize = "Y",
                        Size = UDim2.new(0, elementWidth, 0, 25),
                        ThemeID = {
                            BackgroundColor3 = "ElementColor",
                        }
                    })

                    local MiniBTNElementC = SlimUI:Create("UICorner", {
                        Parent = MiniBTNElement,
                    })

                    local MiniBTNLabel = SlimUI:Create("TextLabel", {
                        Parent = MiniBTNElement,
                        BackgroundColor3 = MiniBTNElement.BackgroundColor3,
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        RichText = true,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0, elementWidth - 30, 0, 25),
                        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = ButtonElement.Title,
                        TextSize = 11,
                        TextWrapped = true,
                        AutomaticSize = "Y",
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ThemeID = {
                            TextColor3 = "Text",
                        }
                    })

                    local BTNTrigger = SlimUI:Create("TextButton", {
                        Parent = MiniBTNElement,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, elementWidth, 0, 25),
                        Font = Enum.Font.SourceSans,
                        AutomaticSize = "Y",
                        TextColor3 = Color3.new(0, 0, 0),
                        TextSize = 14,
                        ZIndex = 4,
                        TextTransparency = 1,
                    })

                    local ButtonUP = SlimUI:Create("UIPadding", {
                        Parent = MiniBTNLabel,
                        PaddingLeft = UDim.new(0, 10),
                    })

                    local BTNIcon = SlimUI:Create("ImageLabel", {
                        Name = "BTNIcon",
                        Parent = MiniBTNElement,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, MiniBTNElement.Size.X.Offset - 20, 0, 7),
                        Size = UDim2.new(0, 11, 0, 11),
                        Image = "rbxassetid://105887588913897",
                        ThemeID = {
                            ImageColor3 = "IconColor",
                        }
                    })

                    local UIStroke = SlimUI:Create("UIStroke", {Parent = MiniBTNElement,
                        Color = Color3.fromRGB(255, 255, 255),
                        LineJoinMode = "Round",
                        Thickness = 0.7,
                        ThemeID = {
                            Color = "Outline",
                        }
                    })

                    BTNTrigger.MouseButton1Click:Connect(function()
                        spawn(function()
                            pcall(ButtonElement.Callback)
                        end)
                        ElementAutoColor(MiniBTNElement)
                    end)

                    totalCount = totalCount + 1
                end
            end

            if Config.Toggle then
                for _, ToggleElement in pairs(Config.Toggle) do
                    if totalCount >= totalLimit then break end

                    local MiniToggleFrame = SlimUI:Create("Frame", {
                        Name = ToggleElement.Title,
                        Parent = MiniElement,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 0.2,
                        AutomaticSize = "Y",
                        Size = UDim2.new(0, elementWidth, 0, 25),
                        ThemeID = {
                            BackgroundColor3 = "ElementColor"
                        }
                    })

                    local MiniToggleElementC = SlimUI:Create("UICorner", {
                        Parent = MiniToggleFrame,
                    })

                    local MiniToggleLabel = SlimUI:Create("TextLabel", {
                        Parent = MiniToggleFrame,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = "Y",
                        RichText = true,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0, elementWidth - 30, 0, 25),
                        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = ToggleElement.Title,
                        TextSize = 11,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ThemeID = {
                            TextColor3 = "Text"
                        }
                    })

                    local UIStroke = SlimUI:Create("UIStroke", {Parent = MiniToggleFrame,
                        Color = Color3.fromRGB(255, 255, 255),
                        LineJoinMode = "Round",
                        Thickness = 0.7,
                        ThemeID = {
                            Color = "Outline",
                        }
                    })

                    local ToggleVal = SlimUI:Create("Frame", {
                        Parent = MiniToggleFrame,
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, MiniToggleFrame.Size.X.Offset - 20, 0, 6.5),
                        Size = UDim2.new(0, 13, 0, 13),
                        ThemeID = {
                            BackgroundColor3 = "Text"
                        }
                    })

                    local ToggleValC = SlimUI:Create("UICorner", {
                        Parent = ToggleVal,
                        CornerRadius = UDim.new(0, 4),
                    })

                    local TGLTrigger = SlimUI:Create("TextButton", {
                        Parent = MiniToggleFrame,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.new(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, elementWidth, 0, 25),
                        Font = Enum.Font.SourceSans,
                        AutomaticSize = "Y",
                        TextColor3 = Color3.new(0, 0, 0),
                        TextSize = 14,
                        ZIndex = 4,
                        TextTransparency = 1,
                    })

                    local ToggleUP = SlimUI:Create("UIPadding", {
                        Parent = MiniToggleLabel,
                        PaddingLeft = UDim.new(0, 10),
                    })

                    local UIStroke = SlimUI:Create("UIStroke", {Parent = MiniToggleFrame,
                        Color = Color3.fromRGB(255, 255, 255),
                        LineJoinMode = "Round",
                        Thickness = 0.7,
                        ThemeID = {
                            Color = "Outline",
                        }
                    })


                    local ToggleValUS = SlimUI:Create("UIStroke", {Parent = ToggleVal,
                        Color = Color3.fromRGB(62, 62, 62),
                        Thickness = 1.5,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeID = {
                            Color = "Outline"
                        }
                    })

                    local Val = ToggleElement.Default
                    if Val then
                        TweenService:Create(ToggleVal, TweenInfo.new(0.2), {Transparency = 0}):Play()
                    else
                        TweenService:Create(ToggleVal, TweenInfo.new(0.2), {Transparency = 1}):Play()
                    end

                    spawn(function()
                        pcall(ToggleElement.Callback, Val)
                    end)

                    TGLTrigger.MouseButton1Click:Connect(function()
                        Val = not Val
                        spawn(function()
                            pcall(ToggleElement.Callback, Val)
                        end)
                        if Val then
                            TweenService:Create(ToggleVal, TweenInfo.new(0.2), {Transparency = 0}):Play()
                        else
                            TweenService:Create(ToggleVal, TweenInfo.new(0.2), {Transparency = 1}):Play()
                        end
                    end)

                    totalCount = totalCount + 1
                end
            end
            --return Button
        end
        return Elements
    end

    local FrameNotifiFrame = SlimUI:Create("Frame", {
        Parent = UIScreen,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1.000,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 284, 0, 600),
        AnchorPoint = Vector2.new(1, 0.5),
    })

    local FrameNotifiFrameULL = SlimUI:Create("UIListLayout", {
        Parent = FrameNotifiFrame,
        HorizontalAlignment = "Center",
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = "Bottom",
        Padding = UDim.new(0, 10),
    })

    local FrameNotifiFrameUP = SlimUI:Create("UIPadding", {
        Parent = FrameNotifiFrame,
        PaddingBottom = UDim.new(0, 0),
    })

    function UI:Notification(Config)
        Notification = {
            Title = Config.Title or "Hello World!",
            Desc = Config.Desc or "World: Hello!",
            Icon = Config.Icon or nil,
            Background = Config.Background or nil,
            Delay = Config.Delay or 3,
        }

        local NotifiElement = SlimUI:Create("Frame", {
            Parent = FrameNotifiFrame,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Transparency = 1,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(0, 300, 0.931200027, 0),
            Size = UDim2.new(0, 284, 0, 0),
            ThemeID = {
                BackgroundColor3 = "Background"
            }
        })

        local NotifiFrame = SlimUI:Create("Frame", {
            Parent = NotifiElement,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = (Notification.Background ~= nil and 1 or 0.2),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.new(0, 300, 0, 0),
            Size = UDim2.new(0, 284, 0, 57),
            ZIndex = 5,
            ThemeID = {
                BackgroundColor3 = "Background"
            }
        })

        if Notification.Background then
            local NotiImage = SlimUI:Create("ImageLabel", {
                Parent = NotifiFrame,
                BackgroundTransparency = 1.000,
                Size = UDim2.new(0, 284, 0, 57),
                ZIndex = 3,
                ScaleType = "Crop",
                Image = Notification.Background,
            },{
                SlimUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                })
            })
        end

        Utility:TweenObject(NotifiElement, {Size = UDim2.new(0, 284, 0, 57)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        Utility:TweenObject(NotifiFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

        local NotifiElementC = SlimUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
            Parent = NotifiFrame,
        })

        local Title = SlimUI:Create("TextLabel", {
            Parent = NotifiFrame,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.139534935, 0),
            Size = UDim2.new(0, 267,0, 15),
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Notification.Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16.000,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            ThemeID = {
                TextColor3 = "Text"
            }
        })
        local TitleUP = Instance.new("UIPadding", Title)
        TitleUP.PaddingLeft = UDim.new(0, 10) --47

        local DescLabel = SlimUI:Create("TextLabel", {
            Parent = NotifiFrame,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.402692825, 0),
            Size = UDim2.new(0, 267,0, 27),
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14.000,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = Notification.Desc,
            ZIndex = 5,
            ThemeID = {
                TextColor3 = "Text"
            }
        })
        local DescLabelUP = Instance.new("UIPadding", DescLabel)
        DescLabelUP.PaddingLeft = UDim.new(0, 10) --47

        if Notification.Icon then
            TitleUP.PaddingLeft = UDim.new(0, 47)
            DescLabelUP.PaddingLeft = UDim.new(0, 47)
            local NotifiIcon = SlimUI:Create("ImageLabel", {
                Parent = NotifiFrame,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0457746461, 0, 0.22807017, 0),
                Size = UDim2.new(0, 26, 0, 26),
                ZIndex = 5,
                --Image = "rbxassetid://84892336431975",
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
            if Notification.Icon and Icons.Icon(Notification.Icon) then
                NotifiIcon.Image = Icons.GetIcon(Notification.Icon)
            elseif Notification.Icon and string.find(Notification.Icon, "rbxassetid://") then
                NotifiIcon.Image = Notification.Icon
            end
        end

        local DelayFrame = SlimUI:Create("Frame", {
            Parent = NotifiFrame,
            BackgroundColor3 = Color3.fromRGB(
                math.clamp(NotifiFrame.BackgroundColor3.R * 255 + 40, 0, 255),
                math.clamp(NotifiFrame.BackgroundColor3.G * 255 + 40, 0, 255),
                math.clamp(NotifiFrame.BackgroundColor3.B * 255 + 40, 0, 255)
            ),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.new(0.0281690136, 0, 0.925000012, 0),
            Size = UDim2.new(0, 267, 0, 3),
            ZIndex = 5,
            -- ThemeID = {
                -- BackgroundColor3 = "Placeholder"
            -- }
        })

        local DelayFrameC = SlimUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 40),
            Parent = DelayFrame,
        })

        Utility:TweenObject(DelayFrame, {Size = UDim2.new(0, 0, 0, 3)}, Notification.Delay, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        wait(Notification.Delay)
        Utility:TweenObject(NotifiElement, {Size = UDim2.new(0, 284, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        Utility:TweenObject(NotifiFrame, {Position = UDim2.new(0, 300, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        wait(0.2)
        NotifiElement:Destroy()

        return Notification
    end

        --[[local SearchScroll = Instance.new("ScrollingFrame")
        local SearuiListLayout = Instance.new("UIListLayout")
        local UIPadding_5 = Instance.new("UIPadding")

        SearchScroll.Name = "SearchScroll"
        SearchScroll.Parent = ElementFrame
        SearchScroll.Active = true
        SearchScroll.BackgroundColor3 = Color3.new(1, 1, 1)
        SearchScroll.ClipsDescendants = true
        SearchScroll.BackgroundTransparency = 1
        SearchScroll.BorderColor3 = Color3.new(0, 0, 0)
        SearchScroll.BorderSizePixel = 0
        SearchScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        SearchScroll.Size = UDim2.new(0, Window.Size.X.Offset - Window.SideBarWidth, 0, Window.Size.Y.Offset - 30)
        SearchScroll.ScrollBarThickness = 2

        SearuiListLayout.Parent = SearchScroll
        SearuiListLayout.Padding = UDim.new(0, 5)
        SearuiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        UIPadding_5.Parent = SearchScroll
        UIPadding_5.PaddingLeft = UDim.new(0, 8)
        UIPadding_5.PaddingTop = UDim.new(0, 3)
        UIPadding_5.PaddingBottom = UDim.new(0, 7)

        function copyElements(source, destination)
            for _, child in pairs(source:GetChildren()) do
                if child:IsA("ScrollElement") then
                    for _, grandchild in pairs(child:GetChildren()) do
                        local clone = grandchild:Clone()
                        clone.Parent = destination
                    end
                end
            end
        end
        copyElements(ElementFrame, SearchScroll)
        SearchScroll.CanvasSize = UDim2.new(0, 0, 0, SearuiListLayout.AbsoluteContentSize.Y)--]]

        --[[local SearchBox = Instance.new("TextBox")
        local SearchLabel = Instance.new("ImageLabel")

        local SearchFrame = SlimUI:Create("Frame", {
            Parent = MainFrame,
            --BackgroundColor3 = Color3.fromRGB(UITheme[Window.Theme].Background.R * 255 + 10, UITheme[Window.Theme].Background.G * 255 + 10, UITheme[Window.Theme].Background.B * 255 + 10),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, TabLib.Size.X.Offset + 10, 0.0140000004, 0),
            Size = UDim2.new(0, 146,0, 25),
            ThemeID = {
                BackgroundColor3 = "SideBar"
            }
        })

        local SearchFrameUIStroke = SlimUI:Create("UIStroke", {
            Parent = SearchFrame,
            Color = Color3.fromRGB(UITheme[Window.Theme].Background.R * 255 + 20, UITheme[Window.Theme].Background.G * 255 + 20, UITheme[Window.Theme].Background.B * 255 + 20),
            LineJoinMode = "Round",
            Thickness = 0.7,
        })

        local SearchFrameC = Instance.new("UICorner")
        SearchFrameC.Parent = SearchFrame
        SearchFrameC.CornerRadius = UDim.new(0, 11)

        SearchBox.Parent = SearchFrame
        SearchBox.BackgroundColor3 = Color3.new(1, 1, 1)
        SearchBox.BackgroundTransparency = 1
        SearchBox.BorderColor3 = Color3.new(0, 0, 0)
        SearchBox.BorderSizePixel = 0
        SearchBox.Position = UDim2.new(0.217, 0,0.14, 0)
        SearchBox.Size = UDim2.new(0, 105,0, 17)--]]
        --SearchBox.FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        --[[SearchBox.Text = "Search . . ."
        SearchBox.TextColor3 = Color3.fromRGB(117, 117, 117)
        SearchBox.TextSize = 11
        SearchBox.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        SearchBox.TextWrapped = true
        SearchBox.TextXAlignment = Enum.TextXAlignment.Left

        SearchLabel.Parent = SearchFrame
        SearchLabel.BackgroundColor3 = Color3.new(1, 1, 1)
        SearchLabel.BackgroundTransparency = 1
        SearchLabel.BorderColor3 = Color3.new(0, 0, 0)
        SearchLabel.BorderSizePixel = 0
        SearchLabel.Position = UDim2.new(0.054, 0,0.22, 0)
        SearchLabel.Size = UDim2.new(0, 14, 0, 14)
        SearchLabel.Image = Icons.Icon("search")[1]
        SearchLabel.ImageRectSize = Icons.Icon("search")[2].ImageRectSize
        SearchLabel.ImageRectOffset = Icons.Icon("search")[2].ImageRectPosition--]]

        --[[SearchBox.FocusLost:Connect(function(enterPressed)
            if not enterPressed then
                SearchBox.Text = "Search . . ."
                SearchBox.TextColor3 = Color3.fromRGB(117, 117, 117)
                for _, v in pairs(ElementFolder.ElementFrame.ScrollingFrame:GetChildren()) do
                    if v:IsA("Frame") then
                        v.Visible = true
                    end
                end
            end
        end)

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = SearchBox.Text
            if query ~= "" and query ~= "Search . . ." then
                SearchBox.TextColor3 = Color3.fromRGB(UITheme[Window.Theme].Text.R * 255, UITheme[Window.Theme].Text.G * 255, UITheme[Window.Theme].Text.B * 255)
                updateResults(query)
            else
                SearchBox.TextColor3 = Color3.fromRGB(117, 117, 117)
                -- Показываем все ScrollElement при пустом или заглушечном запросе
                for _, v in pairs(MainFrame.ElementFolder.ElementFrame:GetChildren()) do
                    if v:IsA("Frame") or v:IsA("ScrollingFrame") then
                        v.Visible = true
                    end
                end
            end
        end)

        function updateResults(query)
            local lowerQuery = string.lower(query)

            -- Если пустой запрос или заглушка — показываем все ScrollElements и все их дочерние Frame
            if lowerQuery == "" or lowerQuery == "search . . ." then
                for _, scrollElement in pairs(MainFrame.ElementFolder.ElementFrame:GetChildren()) do
                    if scrollElement:IsA("ScrollingFrame") then
                        scrollElement.Visible = true
                        for _, child in pairs(scrollElement:GetChildren()) do
                            if child:IsA("Frame") then
                                child.Visible = true
                            end
                        end
                    end
                end
                return
            end

            local foundScrollElement = nil

            for _, scrollElement in pairs(MainFrame.ElementFolder.ElementFrame:GetChildren()) do
                if scrollElement:IsA("ScrollingFrame") then
                    local containsMatch = false

                    for _, child in pairs(scrollElement:GetChildren()) do
                        if child:IsA("Frame") then
                            if string.find(string.lower(child.Name), lowerQuery, 1, true) then
                                containsMatch = true
                                break
                            end
                        end
                    end

                    if containsMatch then
                        foundScrollElement = scrollElement
                        break
                    end
                end
            end

            for _, scrollElement in pairs(MainFrame.ElementFolder.ElementFrame:GetChildren()) do
                if scrollElement:IsA("ScrollingFrame") then
                    if scrollElement == foundScrollElement then
                        scrollElement.Visible = true
                        for _, child in pairs(scrollElement:GetChildren()) do
                            if child:IsA("Frame") then
                                local childNameLower = string.lower(child.Name)
                                child.Visible = (string.find(childNameLower, lowerQuery, 1, true) ~= nil)
                            end
                        end
                    else
                        scrollElement.Visible = false
                    end
                end
            end
        end

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            updateResults(SearchBox.Text)
        end)--]]

    return TabModule, Window
end
return UI


--[[function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end
    return result
end

local Window = UI:CreateWindow({
    Name = "Example",
    Icon = "hexagon",
    SideBarWidth = 136,
    ToggleKey = Enum.KeyCode.F,
    Size = UDim2.fromOffset(480, 320),
    Elements = {
        Minimized = true,
        Close = true
    },
})

local ParagraphTab = Window:Tab({Title = "Display Elements", Icon = "picture-in-picture"})
local ManagementTab = Window:Tab({Title = "Management", Icon = "chart-no-axes-gantt"})
local InputTab = Window:Tab({Title = "Input Elements", Icon = "file-input"})
local NotificationTab = Window:Tab({Title = "Notification", Icon = "message-square-dot"})
Window:Devider()
local SettingsTab = Window:Tab({Title = "Settings", Icon = "cog"})
Window:Devider()
local LockedElementsTab = Window:Tab({Title = "Locked Elements", Icon = "square-dashed-mouse-pointer"})
local OtherTab = Window:Tab({Title = "Other", Icon = "hash"})

ParagraphTab:Section({Title = "Traffic", Icon = "chart-no-axes-combined"})
local bebebe = ParagraphTab:Traffic({Title = "Traffic Title"})

ParagraphTab:Slider({
    Title = "Set Traffic",
	Step = 1,
	Value = {
		Min = 1,
		Max = 1000,
		Default = 5,
	},
	Callback = function(value)
        bebebe:SetValue(value)
	end
})

ParagraphTab:Traffic({Title = "Traffic Title", Value = 25})

ParagraphTab:SmallElement({
    Button = {
        {
            Title = "Reset Traffic",
            Callback = function()
                bebebe:Reset()
            end,
        },
    },
})

ParagraphTab:Section({Title = "Paragraph", Icon = "a-large-small"})
ParagraphTab:Paragraph({
    Title = "Paragraph Example",
    Desc = "Description Paragraph"
})

ParagraphTab:Paragraph({
    Title = "Paragraph Icon",
    Icon = "bird"
})

ParagraphTab:SmallParagraph({Title = "Paragraph"})
ParagraphTab:SmallParagraph({Title = "Paragraph",TextXAlignment = "Left"})
ParagraphTab:SmallParagraph({Title = "Paragraph",TextXAlignment = "Right"})

ParagraphTab:Section({Title = "Color Paragraph", Icon = "paintbrush"})

local Colors = {"Default","Red","Orange","Yellow","Green","Ocyan","Blue","Purple", "Pink"}
local ColorCount = 0
for i = 1, 9 do
    ColorCount = ColorCount + 1
    ParagraphTab:Paragraph({
        Title = Colors[ColorCount],
        Color = Colors[ColorCount]
    })

    ParagraphTab:SmallParagraph({
        Title = Colors[ColorCount],
        Color = Colors[ColorCount],
        TextXAlignment = "Left"
    })
end

ColorCount = 0
ParagraphTab:Section({Title = "Brightness Color", Icon = "sun"})
for i = 1, 9 do
    ColorCount = ColorCount + 1
    ParagraphTab:Paragraph({
        Title = Colors[ColorCount],
        Color = Colors[ColorCount],
        Brightness = 100
    })

    ParagraphTab:SmallParagraph({
        Title = Colors[ColorCount],
        Color = Colors[ColorCount],
        Brightness = 100,
        TextXAlignment = "Left"
    })
end

ManagementTab:Section({Title = "Button Element"})
ManagementTab:Button({
    Title = "Button Example",
    Desc = "Description Button",
    Callback = function()
        print('Click!')
end})

ManagementTab:Button({
    Title = "Button Icon",
    Icon = "bird",
    Callback = function()
        print('Click!')
end})

local DestroyButton = ManagementTab:Button({
    Title = "Destroy Button",
    Icon = "trash-2",
    Callback = function()
        DestroyButton:Close()
end})

ManagementTab:SmallElement({
    Button = {
        {
            Title = "Button",
            Callback = function()
                print('Click!')
            end,
        },
    },
    Toggle = {
        {
            Title = "Toggle",
            Default = false,
            Callback = function(Value)
                print(Value)
            end,
        },
        {
            Title = "Active Toggle",
            Default = true,
            Callback = function(Value)
                print(Value)
            end,
        },
    }
})

ManagementTab:SmallElement({
    Button = {
        {
            Title = "Click",
            Callback = function()
                print('Click!')
            end,
        },
        {
            Title = "Button",
            Callback = function()
                print('Click!')
            end,
        },
    },
})

ManagementTab:SmallElement({
    Toggle = {
        {
            Title = "Toggle",
            Default = false,
            Callback = function(Value)
                print(Value)
            end,
        },
    },
})

ManagementTab:Section({Title = "Toggle Element"})
ManagementTab:Toggle({
    Title = "Toggle Example",
    Callback = function(Value)
        print(Value)
end})

local Pisun = ManagementTab:Toggle({
    Title = "Active Toggle",
    Desc = "Desc",
    Default = true,
    Callback = function(Value)
        print(Value)
end})

ManagementTab:SmallElement({
    Button = {
        {
            Title = "Destroy Active Button",
            Callback = function()
                Pisun:Close()
            end,
        },
    },
    Toggle = {
        {
            Title = "Set Status",
            Default = true,
            Callback = function(Value)
                Pisun:SetValue(Value)
            end,
        },
    },
})

ManagementTab:Section({Title = "Slider"})
local Slider = ManagementTab:Slider({
	Title = "Walk Speed",
	Step = 1,
	Value = {
		Min = 16,
		Max = 220,
		Default = 16,
	},
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
	end
})
ManagementTab:Slider({
	Title = "Jump Power",
	Step = 1,
	Value = {
		Min = 50,
		Max = 220,
		Default = 50,
	},
	Callback = function(value)
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
	end
})

ManagementTab:Slider({
	Title = "FOV",
	Step = 1,
	Value = {
		Min = 1,
		Max = 120,
		Default = 70,
	},
	Callback = function(value)
		game:GetService'Workspace'.Camera.FieldOfView = value
	end
})

local ExampleSlider = ManagementTab:Slider({
	Title = "Slider Example",
	Step = 10,
	Value = {
		Min = 1,
		Max = 120,
		Default = 1,
	},
	Callback = function(value)
	end
})

ManagementTab:SmallElement({
    Button = {
        {
            Title = "Destroy Slider Example",
            Callback = function()
                ExampleSlider:Close()
            end,
        },
    },
})

ManagementTab:Section({Title = "DropDown"})
local DropDown = ManagementTab:DropDown({
    Title = "DropDown Example",
    Value = "Option A",
    Option = {'Option A', 'Option B', 'Option C'},
    Callback = function(option)
        print(option)
    end
})

ManagementTab:SmallElement({
    Button = {
        {
            Title = "Destroy DropDown Example",
            Callback = function()
                DropDown:Close()
            end,
        },
    },
})

ManagementTab:Section({Title = "Keybind"})
local Keybind = ManagementTab:Keybind({
    Title = "Keybind Element",
    Callback = function(key)
        print(key)
end})
ManagementTab:SmallElement({
    Button = {
        {
            Title = "Destroy Keybind Element",
            Callback = function()
                Keybind:Close()
            end,
        },
    },
})

InputTab:Section({Title = "Input"})
InputTab:Input({
    Title = "Input Element",
    Callback = function(input)
        print(input)
end})

local Input = InputTab:Input({
    Title = "Input Limit",
    Desc = "Desc",
    Value = "Input",
    MaxSymbols = 25,
    Callback = function(input)
        print(input)
end})

local InputSlider = InputTab:Slider({
	Title = "Set Limit",
	Step = 1,
	Value = {
		Min = 5,
		Max = 30,
		Default = 5,
	},
	Callback = function(value)
        Input:SetMaxSymbols(value)
	end
})

InputTab:SmallElement({
    Button = {
        {
            Title = "Destroy Input Limit",
            Callback = function()
                Input:Close()
                InputSlider:Close()
            end,
        },
    },
})

NotificationTab:Button({
    Title = "Get Notification",
    Callback = function()
        UI:Notification({
            Delay = 3
        })
    end
})

NotificationTab:Button({
    Title = "Get Icon Notification",
    Callback = function()
        UI:Notification({
            Icon = "bird",
            Delay = 3
        })
    end
})

NotificationTab:Button({
    Title = "Get Background Notification",
    Callback = function()
        UI:Notification({
            Icon = "bird",
            Background = "http://www.roblox.com/asset/?id=2878190399",
            Delay = 3
        })
    end
})

SettingsTab:Section({Title = "Window", Icon = "grid-2x2"})
SettingsTab:DropDown({
    Title = "Theme",
    Value = "--",
    Option = {'Dark', 'Light', 'Amethyst'},
    Callback = function(option)
        Window:SetTheme(option)
    end
})
SettingsTab:Toggle({
    Title = "Transparency",
    Default = true,
    Callback = function(state)
        Window:SetTransparency(state)
end})

SettingsTab:Section({Title = "Misc"})
SettingsTab:Keybind({
    Title = "Toggle Key Window",
    Callback = function(key)
        Window:SetToggleKey(Enum.KeyCode[key])
end})

SettingsTab:Button({
    Title = "Destroy Window",
    Icon = "trash-2",
    Callback = function()
        Window:Close()
end})

local SelectedIcon = 'bird'
OtherTab:Section({Title = "Set Icon"})
OtherTab:DropDown({
    Title = "Icon",
    Value = "bird",
    Option = {'bird', 'fish', 'folder', 'pen'},
    Callback = function(option)
        SelectedIcon = option
    end
})

local ParagraphIcon = OtherTab:Paragraph({
    Title = "Paragraph",
})

local RefreshIcon
RefreshIcon = OtherTab:Button({
    Title = "Refresh",
    Icon = "refresh-ccw",
    Callback = function()
        ParagraphIcon:SetIcon(SelectedIcon)
        ButtonIcon:SetIcon(SelectedIcon)
end})

local TrashIcon
TrashIcon = OtherTab:Button({
    Title = "Remove Icon",
    Icon = "trash-2",
    Callback = function()
        ParagraphIcon:RemoveIcon()
end})

OtherTab:Toggle({
    Title = "Left Alignment",
    Alignment = "Left",
    Default = false,
    Callback = function(Value)
        print(Value)
end})

local LockedButton = LockedElementsTab:Button({
    Title = "Button",
    Locked = true,
    Callback = function()
end})

local LockedToggle = LockedElementsTab:Toggle({
    Title = "Toggle",
    Locked = true,
    Callback = function(value)
end})

local LockedSlider = LockedElementsTab:Slider({
	Title = "Slider",
    Locked = true,
	Step = 1,
	Value = {
		Min = 5,
		Max = 30,
		Default = 5,
	},
	Callback = function(value)
        Input:SetMaxSymbols(value)
	end
})

local LockedDropdown = LockedElementsTab:DropDown({
    Title = "Dropdown",
    Locked = true,
    Value = "le",
    Option = {'le', 'lele', 'lelele'},
    Callback = function(option)
        SelectedIcon = option
    end
})

local LockedInput = LockedElementsTab:Input({
    Title = "Input",
    Locked = true,
    Value = "Input",
    Callback = function(input)
        print(input)
end})

LockedElementsTab:SmallElement({
    Toggle = {
        {
            Title = "Lock / Unlock",
            Default = true,
            Callback = function(Value)
                if Value then
                    LockedButton:Lock()
                    LockedToggle:Lock()
                    LockedSlider:Lock()
                    LockedDropdown:Lock()
                    LockedInput:Lock()
                else
                    LockedButton:UnLock()
                    LockedToggle:UnLock()
                    LockedSlider:UnLock()
                    LockedDropdown:UnLock()
                    LockedInput:UnLock()
                end
            end,
        },
    },
})--]]
