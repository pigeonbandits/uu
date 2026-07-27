if getgenv().Library then
    getgenv().Library:Unload()
end

local Library do
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHex = Color3.fromHex

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local UDim2FromScale = UDim2.fromScale
    local Vector2New = Vector2.new

    local MathClamp = math.clamp
    local MathFloor = math.floor

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove

    local StringFormat = string.format

    local InstanceNew = Instance.new
    local RectNew = Rect.new

    Library = {
        Theme = {},

        MenuKeybind = tostring(Enum.KeyCode.RightControl),

        Flags = {},

        Tween = {
            Time = 0.2,
            Style = Enum.EasingStyle.Circular,
            Direction = Enum.EasingDirection.Out
        },

        FadeSpeed = 0.15,

        Pages = {},
        Sections = {},

        Connections = {},
        Threads = {},

        ThemeMap = {},
        ThemeItems = {},

        OpenFrames = {},

        SetFlags = {},

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        UnusedHolder = nil,

        Font = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.Medium,
            Enum.FontStyle.Normal
        ),

        FontBold = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.Bold,
            Enum.FontStyle.Normal
        ),

        FontRegular = Font.new("rbxassetid://12187365364"),

        FontSemiBold = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Themes = {
        ["Ironite"] = {
            ["Background"] = FromRGB(19, 20, 25),
            ["PageBackground"] = FromRGB(16, 17, 21),
            ["SectionBackground"] = FromRGB(17, 18, 22),
            ["SectionHeader"] = FromRGB(19, 20, 25),
            ["Separator"] = FromRGB(31, 31, 45),
            ["InactiveText"] = FromRGB(69, 71, 90),
            ["ActiveText"] = FromRGB(254, 254, 254),
            ["ElementBackground"] = FromRGB(24, 25, 32),
            ["Stroke"] = FromRGB(28, 30, 38),
            ["Accent"] = FromRGB(254, 254, 254),
            ["AccentDim"] = FromRGB(147, 147, 147)
        }
    }

    Library.Theme = Themes["Ironite"]

    local Tween = {} do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info,
                Goal = Goal,
                Item = Item
            }

            NewTween.Tween:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item

            if Item:IsA("Frame") then
                return {"BackgroundTransparency"}
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return {"TextTransparency", "BackgroundTransparency"}
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return {"BackgroundTransparency", "ImageTransparency"}
            elseif Item:IsA("ScrollingFrame") then
                return {"BackgroundTransparency", "ScrollBarImageTransparency"}
            elseif Item:IsA("TextBox") then
                return {"TextTransparency", "BackgroundTransparency"}
            elseif Item:IsA("UIStroke") then
                return {"Transparency"}
            end
        end

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then
                    task.wait()
                    Item[Property] = OldTransparency
                end
            end)

            return NewTween
        end
    end

    local Instances = {} do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end

            return NewItem
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then
                return
            end

            Library:AddToTheme(self, Properties)
            return self
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then
                return
            end

            if not self.Instance[Event] then
                return
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then
                return
            end

            return Tween:Create(self, Info, Goal)
        end

        Instances.Clean = function(self)
            if not self.Instance then
                return
            end

            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then
                return
            end

            local Gui = self.Instance
            local Dragging = false
            local DragStart
            local StartPosition

            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y

                local ScreenSize = Gui.Parent.AbsoluteSize
                local GuiSize = Gui.AbsoluteSize

                NewX = MathClamp(NewX, 0, ScreenSize.X - GuiSize.X)
                NewY = MathClamp(NewY, 0, ScreenSize.Y - GuiSize.Y)

                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, NewX, 0, NewY)})
            end

            local InputChanged

            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position

                    if InputChanged then
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Set(Input)
                    end
                end
            end)

            return Dragging
        end
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.Unload = function(self)
        for _, Value in self.Connections do
            if Value.Connection then
                Value.Connection:Disconnect()
            end
        end

        for _, Value in self.Threads do
            coroutine.close(Value)
        end

        if self.Holder then
            self.Holder:Clean()
        end

        if self.UnusedHolder then
            self.UnusedHolder:Clean()
        end

        Library = nil
        getgenv().Library = nil
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)

        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()

        TableInsert(self.Threads, NewThread)
        return NewThread
    end

    Library.SafeCall = function(self, Function, ...)
        local Arguments = {...}
        local Success, Result = pcall(Function, table.unpack(Arguments))

        if not Success then
            warn(Result)
            return false
        end

        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        self.UnnamedConnections = self.UnnamedConnections + 1

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)

        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in self.Connections do
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        self.UnnamedFlags = FlagNumber
        return StringFormat("flag_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                if self.Theme[Value] then
                    Item[Property] = self.Theme[Value]
                end
            elseif type(Value) == "function" then
                Item[Property] = Value()
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color

        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance or Frame

        local MousePosition = Vector2New(Mouse.X, Mouse.Y)

        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    do
        Library.Window = function(self, Data)
            Data = Data or {}

            local Window = {
                Name = Data.Name or "Ironite",
                GameName = Data.GameName or "",
                Logo = Data.Logo or "rbxassetid://108488788823423",
                UpdateDate = Data.UpdateDate or "",
                UpdateMonth = Data.UpdateMonth or "",

                Pages = {},
                Items = {},
                IsOpen = false
            }

            local Items = {} do
                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2FromScale(0.5, 0.5),
                    Size = UDim2FromOffset(695, 489),
                    BackgroundColor3 = Library.Theme["Background"],
                    ClipsDescendants = true,
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "Background"})

                Instances:Create("UICorner", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 11)
                })

                Items["Header"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0),
                    Position = UDim2FromScale(0.5, 0),
                    Size = UDim2FromOffset(695, 37),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Items["Header"]:MakeDraggable()

                Instances:Create("Frame", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2FromScale(0, 1),
                    Size = UDim2New(1, 1, 0, 2),
                    BackgroundColor3 = Library.Theme["Separator"],
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "Separator"})

                Items["LibraryIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    Image = Window.Logo,
                    Position = UDim2New(0, 12, 0.5, 0),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2FromOffset(20, 20),
                    BorderSizePixel = 0
                })

                Items["LibraryName"] = Instances:Create("TextLabel", {
                    Parent = Items["LibraryIcon"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.Font,
                    Position = UDim2New(0, 24, 0.5, 0),
                    RichText = true,
                    Size = UDim2FromOffset(1, 1),
                    Text = Window.Name .. (Window.GameName ~= "" and (' <font color="#45475a">' .. Window.GameName .. "</font>") or ""),
                    TextColor3 = Library.Theme["ActiveText"],
                    TextSize = 14,
                    BorderSizePixel = 0
                })

                if Window.UpdateDate ~= "" then
                    Items["UpdateLabel"] = Instances:Create("TextLabel", {
                        Parent = Items["Header"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        FontFace = Library.FontRegular,
                        Position = UDim2New(1, -12, 0.5, 0),
                        RichText = true,
                        Size = UDim2FromOffset(1, 1),
                        Text = 'Updated Last <font color="#45475a">' .. Window.UpdateDate .. '</font> <font color="#ffffff">' .. Window.UpdateMonth .. "</font>",
                        TextColor3 = Library.Theme["ActiveText"],
                        TextSize = 12,
                        BorderSizePixel = 0
                    })

                    Items["UpdateIcon"] = Instances:Create("ImageLabel", {
                        Parent = Items["UpdateLabel"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0, 0.5),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://84304363968016",
                        Position = UDim2New(0, -22, 0.5, 0),
                        Size = UDim2FromOffset(15, 15),
                        BorderSizePixel = 0
                    })
                end

                Items["Sidebar"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2FromScale(0, 1),
                    Size = UDim2FromOffset(75, 453),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Instances:Create("Frame", {
                    Parent = Items["Sidebar"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2FromScale(1, 0.5),
                    Size = UDim2New(0, 2, 1, 0),
                    BackgroundColor3 = Library.Theme["Separator"],
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "Separator"})

                Items["TabHolder"] = Instances:Create("Frame", {
                    Parent = Items["Sidebar"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2FromScale(0.5, 0.5),
                    Size = UDim2FromOffset(75, 453),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["TabHolder"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center
                })

                Instances:Create("UIPadding", {
                    Parent = Items["TabHolder"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 9),
                    PaddingTop = UDimNew(0, 10)
                })

                Items["SubHeader"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0, 75 + 310, 0, 37 + 25),
                    Size = UDim2FromOffset(621, 51),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubHeader"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["SubHeader"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 25),
                    PaddingTop = UDimNew(0, 4)
                })

                Items["PageArea"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 1),
                    Position = UDim2FromScale(1, 1),
                    Size = UDim2FromOffset(620, 401),
                    BackgroundColor3 = Library.Theme["PageBackground"],
                    ClipsDescendants = true,
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "PageBackground"})

                Instances:Create("UICorner", {
                    Parent = Items["PageArea"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 11)
                })

                Window.Items = Items
            end

            local Debounce = false

            function Window:SetCenter()
                local CenterPosition = Items["MainFrame"].Instance.AbsolutePosition
                task.wait()
                Items["MainFrame"].Instance.AnchorPoint = Vector2New(0, 0)
                Items["MainFrame"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            function Window:SetOpen(Bool)
                if Debounce then
                    return
                end

                Window.IsOpen = Bool
                Debounce = true

                if Window.IsOpen then
                    Items["MainFrame"].Instance.Visible = true
                end

                local Descendants = Items["MainFrame"].Instance:GetDescendants()
                TableInsert(Descendants, Items["MainFrame"].Instance)

                local NewTween

                for _, Value in Descendants do
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue
                    end

                    if type(TransparencyProperty) == "table" then
                        for _, Property in TransparencyProperty do
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end

                if NewTween then
                    NewTween.Tween.Completed:Connect(function()
                        Debounce = false
                        Items["MainFrame"].Instance.Visible = Window.IsOpen
                    end)
                else
                    Debounce = false
                end
            end

            Library:Connect(UserInputService.InputBegan, function(Input)
                if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                    Window:SetOpen(not Window.IsOpen)
                end
            end)

            Window:SetCenter()
            task.wait()
            Window:SetOpen(true)
            return setmetatable(Window, Library)
        end

        Library.Page = function(self, Data)
            Data = Data or {}

            local Page = {
                Window = self,

                Name = Data.Name or "Page",
                Icon = Data.Icon or "rbxassetid://72196061405823",

                SubTabs = {},
                Items = {},
                Active = false
            }

            local Items = {} do
                Items["TabButton"] = Instances:Create("TextButton", {
                    Parent = Page.Window.Items["TabHolder"].Instance,
                    Name = "\0",
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = FromRGB(247, 247, 247),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Size = UDim2FromOffset(55, 60),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["TabButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })

                Items["TabGradient"] = Instances:Create("UIGradient", {
                    Parent = Items["TabButton"].Instance,
                    Name = "\0",
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, FromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, FromRGB(147, 147, 147)),
                    })
                })

                Items["TabIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["TabButton"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = Page.Icon,
                    ImageColor3 = Library.Theme["InactiveText"],
                    Position = UDim2New(0.5, 0, 0.5, -8),
                    Size = UDim2FromOffset(24, 22),
                    BorderSizePixel = 0
                })

                Items["TabText"] = Instances:Create("TextLabel", {
                    Parent = Items["TabIcon"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.FontBold,
                    Position = UDim2New(0.5, 0, 0.5, 20),
                    Size = UDim2New(1, 1, 1, 1),
                    Text = Page.Name,
                    TextColor3 = Library.Theme["InactiveText"],
                    TextSize = 12,
                    BorderSizePixel = 0
                })

                Items["TabPill"] = Instances:Create("Frame", {
                    Parent = Items["TabButton"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 1),
                    BackgroundColor3 = FromRGB(254, 254, 254),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 1, 3),
                    Size = UDim2FromOffset(25, 6),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["TabPill"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 12)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["TabPill"].Instance,
                    Name = "\0",
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, FromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, FromRGB(147, 147, 147)),
                    })
                })

                Items["Divider"] = Instances:Create("Frame", {
                    Parent = Page.Window.Items["TabHolder"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Size = UDim2FromOffset(55, 5),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["Divider"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })

                local DividerLine = Instances:Create("Frame", {
                    Parent = Items["Divider"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 1),
                    BackgroundColor3 = Library.Theme["Separator"],
                    Position = UDim2New(0.5, 0, 1, 3),
                    Size = UDim2FromOffset(25, 6),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "Separator"})

                Instances:Create("UICorner", {
                    Parent = DividerLine.Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 12)
                })

                Items["SubTabHolder"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    Visible = false,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubTabHolder"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Items["PageContent"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0
                })

                Page.Items = Items
            end

            local PageDebounce = false

            function Page:Turn(Bool)
                if PageDebounce then
                    return
                end

                Page.Active = Bool
                PageDebounce = true

                Items["SubTabHolder"].Instance.Visible = Bool
                Items["SubTabHolder"].Instance.Parent = Bool and Page.Window.Items["SubHeader"].Instance or Library.UnusedHolder.Instance

                Items["PageContent"].Instance.Visible = Bool
                Items["PageContent"].Instance.Parent = Bool and Page.Window.Items["PageArea"].Instance or Library.UnusedHolder.Instance

                if Page.Active then
                    Items["TabButton"].Instance.BackgroundTransparency = 0.9
                    Items["TabIcon"].Instance.ImageColor3 = Library.Theme["ActiveText"]
                    Items["TabText"].Instance.TextColor3 = Library.Theme["ActiveText"]
                    Items["TabPill"].Instance.BackgroundTransparency = 0

                    for _, SubTab in Page.SubTabs do
                        if SubTab.Active then
                            SubTab:Show(true)
                        end
                    end
                else
                    Items["TabButton"].Instance.BackgroundTransparency = 1
                    Items["TabIcon"].Instance.ImageColor3 = Library.Theme["InactiveText"]
                    Items["TabText"].Instance.TextColor3 = Library.Theme["InactiveText"]
                    Items["TabPill"].Instance.BackgroundTransparency = 1

                    for _, SubTab in Page.SubTabs do
                        SubTab:Show(false)
                    end
                end

                PageDebounce = false
            end

            Items["TabButton"]:Connect("MouseButton1Down", function()
                for _, Value in Page.Window.Pages do
                    if Value == Page and Page.Active then
                        return
                    end

                    Value:Turn(Value == Page)
                end
            end)

            if #Page.Window.Pages == 0 then
                Page:Turn(true)
            end

            TableInsert(Page.Window.Pages, Page)
            return setmetatable(Page, Library.Pages)
        end

        Library.Pages.SubTab = function(self, Data)
            Data = Data or {}

            local SubTab = {
                Window = self.Window,
                Page = self,

                Name = Data.Name or "SubTab",

                Items = {},
                Active = false
            }

            local Items = {} do
                Items["SubTabButton"] = Instances:Create("TextButton", {
                    Parent = SubTab.Page.Items["SubTabHolder"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2FromOffset(80, 49),
                    BorderSizePixel = 0
                })

                Items["TabName"] = Instances:Create("TextLabel", {
                    Parent = Items["SubTabButton"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.FontRegular,
                    Position = UDim2New(0.5, 0, 0.5, -3),
                    Size = UDim2FromOffset(1, 1),
                    Text = SubTab.Name,
                    TextColor3 = Library.Theme["InactiveText"],
                    TextSize = 13,
                    TextTransparency = 0.15,
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["TabName"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["TabName"].Instance,
                    Name = "\0",
                    PaddingBottom = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingTop = UDimNew(0, 10)
                })

                Items["SubTabPill"] = Instances:Create("Frame", {
                    Parent = Items["SubTabButton"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 1),
                    BackgroundColor3 = FromRGB(254, 254, 254),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 1, 2),
                    Size = UDim2FromOffset(34, 6),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["SubTabPill"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 12)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["SubTabPill"].Instance,
                    Name = "\0",
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, FromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, FromRGB(147, 147, 147)),
                    })
                })

                Items["Content"] = Instances:Create("ScrollingFrame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Active = true,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2FromScale(0.5, 0.5),
                    ScrollBarImageColor3 = FromRGB(0, 0, 0),
                    ScrollBarThickness = 1,
                    Size = UDim2FromOffset(620, 401),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    Visible = false,
                    BorderSizePixel = 0
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 10),
                    PaddingBottom = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 15),
                    PaddingRight = UDimNew(0, 15)
                })

                Items["ColumnLayout"] = Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 15),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill
                })

                Items["LeftColumn"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0.5, -8, 0, 0),
                    LayoutOrder = 1,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["LeftColumn"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Items["RightColumn"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0.5, -8, 0, 0),
                    LayoutOrder = 2,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["RightColumn"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                SubTab.Items = Items
            end

            function SubTab:Show(Bool)
                Items["Content"].Instance.Visible = Bool
                Items["Content"].Instance.Parent = Bool and SubTab.Page.Items["PageContent"].Instance or Library.UnusedHolder.Instance

                if Bool then
                    Items["TabName"].Instance.BackgroundTransparency = 0.8
                    Items["TabName"].Instance.TextColor3 = Library.Theme["ActiveText"]
                    Items["TabName"].Instance.TextTransparency = 0
                    Items["TabName"].Instance.FontFace = Library.Font
                    Items["SubTabPill"].Instance.BackgroundTransparency = 0

                    local TabNameGradient = Items["TabName"].Instance:FindFirstChildOfClass("UIGradient")
                    if not TabNameGradient then
                        Instances:Create("UIGradient", {
                            Parent = Items["TabName"].Instance,
                            Name = "\0",
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, FromRGB(254, 254, 254)),
                                ColorSequenceKeypoint.new(1, FromRGB(147, 147, 147)),
                            })
                        })
                    end
                else
                    Items["TabName"].Instance.BackgroundTransparency = 1
                    Items["TabName"].Instance.TextColor3 = Library.Theme["InactiveText"]
                    Items["TabName"].Instance.TextTransparency = 0.15
                    Items["TabName"].Instance.FontFace = Library.FontRegular
                    Items["SubTabPill"].Instance.BackgroundTransparency = 1

                    local TabNameGradient = Items["TabName"].Instance:FindFirstChildOfClass("UIGradient")
                    if TabNameGradient then
                        TabNameGradient:Destroy()
                    end
                end
            end

            function SubTab:Activate()
                for _, Value in SubTab.Page.SubTabs do
                    Value.Active = (Value == SubTab)
                    Value:Show(Value == SubTab)
                end
            end

            Items["SubTabButton"]:Connect("MouseButton1Down", function()
                if SubTab.Active then
                    return
                end
                SubTab:Activate()
            end)

            if #SubTab.Page.SubTabs == 0 then
                SubTab.Active = true
                if SubTab.Page.Active then
                    SubTab:Show(true)
                end
            end

            TableInsert(SubTab.Page.SubTabs, SubTab)
            return SubTab
        end

        Library.Pages.Section = function(self, Data)
            Data = Data or {}

            local SubTab = Data.SubTab
            if not SubTab then
                if #self.SubTabs > 0 then
                    SubTab = self.SubTabs[1]
                end
            end

            if not SubTab then
                return warn("Section requires a SubTab. Create a SubTab first.")
            end

            local Section = {
                Window = self.Window,
                Page = self,
                SubTab = SubTab,

                Name = Data.Name or "Section",
                Side = Data.Side or "Left",
                Icon = Data.Icon or "",

                Items = {}
            }

            local ColumnParent
            if Section.Side == "Right" then
                ColumnParent = SubTab.Items["RightColumn"].Instance
            else
                ColumnParent = SubTab.Items["LeftColumn"].Instance
            end

            local Items = {} do
                Items["SectionFrame"] = Instances:Create("Frame", {
                    Parent = ColumnParent,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Library.Theme["SectionBackground"],
                    ClipsDescendants = true,
                    Size = UDim2New(1, 0, 0, 60),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "SectionBackground"})

                Instances:Create("UICorner", {
                    Parent = Items["SectionFrame"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })

                Items["Header"] = Instances:Create("Frame", {
                    Parent = Items["SectionFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0),
                    Position = UDim2FromScale(0.5, 0),
                    BackgroundColor3 = Library.Theme["SectionHeader"],
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "SectionHeader"})

                Instances:Create("UICorner", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })

                if Section.Icon ~= "" then
                    Items["SectionIcon"] = Instances:Create("ImageLabel", {
                        Parent = Items["Header"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0, 0.5),
                        BackgroundTransparency = 1,
                        Image = Section.Icon,
                        ImageColor3 = Library.Theme["ActiveText"],
                        Position = UDim2New(0, 10, 0.5, 0),
                        Size = UDim2FromOffset(14, 14),
                        BorderSizePixel = 0
                    })
                end

                Items["SectionText"] = Instances:Create("TextLabel", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.Font,
                    Position = UDim2New(0, Section.Icon ~= "" and 30 or 12, 0.5, 0),
                    Size = UDim2FromOffset(1, 1),
                    Text = Section.Name,
                    TextColor3 = Library.Theme["ActiveText"],
                    TextSize = 12,
                    BorderSizePixel = 0
                })

                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["SectionFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0),
                    Position = UDim2New(0.5, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 5),
                    PaddingBottom = UDimNew(0, 10)
                })

                Section.Items = Items
            end

            return setmetatable(Section, Library.Sections)
        end
    end
end

getgenv().Library = Library
return Library
