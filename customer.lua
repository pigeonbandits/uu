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
            ["AccentDim"] = FromRGB(147, 147, 147),
            ["NotifSuccess"] = FromRGB(47, 255, 0),
            ["NotifWarning"] = FromRGB(255, 214, 10)
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

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then
                return
            end

            Library:ChangeItemTheme(self, Properties)
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

        Instances.MakeDraggable = function(self, DragTarget)
            if not self.Instance then
                return
            end

            local TargetItem = DragTarget or self
            local Gui = TargetItem.Instance
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

                TargetItem:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, NewX, 0, NewY)})
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

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        if not self.ThemeMap[Item] then
            return
        end

        self.ThemeMap[Item].Properties = Properties
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
        Library.Watermark = function(self, Name, Logo)
            local Watermark = {}

            local Items = {} do
                Items["Watermark"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0),
                    Position = UDim2New(0.5, 0, 0, 20),
                    Size = UDim2New(0, 0, 0, 35),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = "Background"})

                Items["Watermark"]:MakeDraggable()

                Instances:Create("UICorner", {
                    Parent = Items["Watermark"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Watermark"].Instance,
                    Name = "\0",
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })

                Items["Logo"] = Instances:Create("ImageLabel", {
                    Parent = Items["Watermark"].Instance,
                    Name = "\0",
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 25, 0, 25),
                    BorderSizePixel = 0
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Watermark"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["ActiveText"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 34, 0.5, -1),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 18
                })
            end

            function Watermark:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Watermark:SetVisibility(Bool)
                Items["Watermark"].Instance.Visible = Bool
            end

            function Watermark:SetCenter()
                local CenterPosition = Items["Watermark"].Instance.AbsolutePosition
                task.wait()
                Items["Watermark"].Instance.AnchorPoint = Vector2New(0, 0)
                Items["Watermark"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            Watermark:SetText(Name)
            Watermark:SetCenter()

            return Watermark
        end

        Library.Notify = function(self, Data)
            Data = Data or {}

            local Title = Data.Title or "Notification"
            local Description = Data.Description or ""
            local Duration = Data.Duration or 5
            local Type = Data.Type or "Success"
            local Buttons = Data.Buttons or {}
            local Callback = Data.Callback or function() end

            local NotifColor = Type == "Warning" and Library.Theme["NotifWarning"] or Library.Theme["NotifSuccess"]
            local NotifIcon = Type == "Warning" and "rbxassetid://70479764730792" or "rbxassetid://92431556586885"

            if not Library.NotifHolder then
                Library.NotifHolder = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(1, 1),
                    Position = UDim2New(0, 20, 0, 20)
                })

                Instances:Create("UIListLayout", {
                    Parent = Library.NotifHolder.Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Library.NotifHolder.Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 12),
                    PaddingTop = UDimNew(0, 12)
                })
            end

            local Notif = {}
            local Collapsed = false
            local Closed = false

            local Items = {} do
                Items["Notification"] = Instances:Create("Frame", {
                    Parent = Library.NotifHolder.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Library.Theme["PageBackground"],
                    ClipsDescendants = true,
                    Size = UDim2FromOffset(330, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UICorner", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 8)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0"
                })

                Items["Header"] = Instances:Create("Frame", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Library.Theme["PageBackground"],
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 8)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 6),
                    PaddingRight = UDimNew(0, 4),
                    PaddingTop = UDimNew(0, 4)
                })

                local Holder = Instances:Create("Frame", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2FromScale(0, 0.5),
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(64, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Holder.Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                local IconHolder = Instances:Create("Frame", {
                    Parent = Holder.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(30, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("ImageLabel", {
                    Parent = IconHolder.Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = NotifIcon,
                    ImageColor3 = NotifColor,
                    Position = UDim2FromScale(0.5, 0.5),
                    Size = UDim2FromOffset(20, 20),
                    BorderSizePixel = 0
                })

                local TitleHolder = Instances:Create("Frame", {
                    Parent = Holder.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(1, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = TitleHolder.Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })

                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = TitleHolder.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.Font,
                    RichText = true,
                    Size = UDim2FromOffset(1, 1),
                    Text = Title,
                    TextColor3 = Library.Theme["ActiveText"],
                    TextSize = 14,
                    BorderSizePixel = 0
                })

                local ControlHolder = Instances:Create("Frame", {
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2FromScale(1, 0.5),
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(1, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = ControlHolder.Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Items["CollapseButton"] = Instances:Create("TextButton", {
                    Parent = ControlHolder.Instance,
                    Name = "\0",
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(30, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("ImageLabel", {
                    Parent = Items["CollapseButton"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://118645616697622",
                    ImageColor3 = FromRGB(66, 68, 86),
                    Position = UDim2FromScale(0.5, 0.5),
                    Size = UDim2FromOffset(20, 20),
                    BorderSizePixel = 0
                })

                Items["CloseButton"] = Instances:Create("TextButton", {
                    Parent = ControlHolder.Instance,
                    Name = "\0",
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(30, 30),
                    BorderSizePixel = 0
                })

                Instances:Create("ImageLabel", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://124971904960139",
                    ImageColor3 = FromRGB(66, 68, 86),
                    Position = UDim2FromScale(0.5, 0.5),
                    Size = UDim2FromOffset(18, 18),
                    BorderSizePixel = 0
                })

                Items["DescriptionHolder"] = Instances:Create("Frame", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(1, 10),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["DescriptionHolder"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Wraps = true
                })

                Instances:Create("UIPadding", {
                    Parent = Items["DescriptionHolder"].Instance,
                    Name = "\0",
                    PaddingBottom = UDimNew(0, 12),
                    PaddingLeft = UDimNew(0, 12)
                })

                local TextHolder = Instances:Create("Frame", {
                    Parent = Items["DescriptionHolder"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 1, 0, 10),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = TextHolder.Instance,
                    Name = "\0",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Wraps = true
                })

                Instances:Create("UIPadding", {
                    Parent = TextHolder.Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 26)
                })

                Items["DescText"] = Instances:Create("TextLabel", {
                    Parent = TextHolder.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.FontRegular,
                    RichText = true,
                    Size = UDim2FromOffset(1, 1),
                    Text = Description,
                    TextColor3 = FromRGB(69, 71, 90),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0
                })

                if #Buttons > 0 then
                    local ButtonHolder = Instances:Create("Frame", {
                        Parent = Items["DescriptionHolder"].Instance,
                        Name = "\0",
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        Size = UDim2FromOffset(1, 10),
                        BorderSizePixel = 0
                    })

                    Instances:Create("UIListLayout", {
                        Parent = ButtonHolder.Instance,
                        Name = "\0",
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDimNew(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Wraps = true
                    })

                    Instances:Create("UIPadding", {
                        Parent = ButtonHolder.Instance,
                        Name = "\0",
                        PaddingLeft = UDimNew(0, 26)
                    })

                    for i, BtnData in Buttons do
                        local IsPrimary = (i == 1)

                        local Btn = Instances:Create("TextButton", {
                            Parent = ButtonHolder.Instance,
                            Name = "\0",
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundColor3 = IsPrimary and NotifColor or FromRGB(0, 0, 0),
                            BackgroundTransparency = IsPrimary and 0.95 or 1,
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2FromOffset(1, 1),
                            BorderSizePixel = 0
                        })

                        Instances:Create("UICorner", {
                            Parent = Btn.Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 6)
                        })

                        if not IsPrimary then
                            Instances:Create("UIStroke", {
                                Parent = Btn.Instance,
                                Name = "\0",
                                Color = FromRGB(66, 68, 86)
                            })
                        end

                        local BtnText = Instances:Create("TextLabel", {
                            Parent = Btn.Instance,
                            Name = "\0",
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundTransparency = 1,
                            FontFace = Library.Font,
                            Size = UDim2FromOffset(1, 1),
                            Text = BtnData.Name or "Button",
                            TextColor3 = IsPrimary and NotifColor or FromRGB(66, 68, 86),
                            TextSize = 14,
                            BorderSizePixel = 0
                        })

                        Instances:Create("UIPadding", {
                            Parent = BtnText.Instance,
                            Name = "\0",
                            PaddingBottom = UDimNew(0, 6),
                            PaddingLeft = UDimNew(0, 8),
                            PaddingRight = UDimNew(0, 8),
                            PaddingTop = UDimNew(0, 6)
                        })

                        Instances:Create("UIListLayout", {
                            Parent = Btn.Instance,
                            Name = "\0",
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            VerticalAlignment = Enum.VerticalAlignment.Center
                        })

                        Btn:Connect("MouseButton1Down", function()
                            if BtnData.Callback then
                                Library:SafeCall(BtnData.Callback)
                            end
                            Notif:Close()
                        end)
                    end
                end

                Items["ProgressHolder"] = Instances:Create("Frame", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundColor3 = Library.Theme["Background"],
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0
                })
                
                local Holder3 = Instances:Create("Frame", {
                    Parent = Items["ProgressHolder"].Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(1, 1),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Holder3.Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                local TextHolder3 = Instances:Create("Frame", {
                    Parent = Holder3.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2FromOffset(1, 10),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = TextHolder3.Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = TextHolder3.Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 12),
                    PaddingTop = UDimNew(0, 6)
                })

                local ProgressInner = Instances:Create("Frame", {
                    Parent = Holder3.Instance,
                    Name = "\0",
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 1, 0, 5),
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = ProgressInner.Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = ProgressInner.Instance,
                    Name = "\0",
                })

                Items["ProgressBar"] = Instances:Create("Frame", {
                    Parent = ProgressInner.Instance,
                    Name = "\0",
                    BackgroundColor3 = NotifColor,
                    Size = UDim2New(0.871795, 1, 0, 5),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["ProgressBar"].Instance,
                    Name = "\0"
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["ProgressHolder"].Instance,
                    Name = "\0"
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["ProgressHolder"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["ProgressHolder"].Instance,
                    Name = "\0",
                    PaddingRight = UDimNew(0, 12)
                })
                
                -- Pop In Animation
                Items["Notification"].Instance.BackgroundTransparency = 1
                Items["Header"].Instance.BackgroundTransparency = 1
                Items["Title"].Instance.TextTransparency = 1
                
                Items["Notification"]:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
                Items["Header"]:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
                TweenService:Create(Items["Title"].Instance, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                
                if Items["DescText"] then
                    Items["DescText"].Instance.TextTransparency = 1
                    TweenService:Create(Items["DescText"].Instance, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                end
            end

            function Notif:Close()
                if Closed then
                    return
                end
                Closed = true

                Items["ProgressBar"]:Tween(nil, {Size = UDim2New(0, 0, 0, 5)})
                Items["Notification"]:Tween(
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Size = UDim2FromOffset(Items["Notification"].Instance.AbsoluteSize.X, 0)}
                )

                task.delay(0.35, function()
                    Items["Notification"]:Clean()
                end)
            end

            function Notif:Collapse()
                Collapsed = not Collapsed
                Items["DescriptionHolder"].Instance.Visible = not Collapsed
            end

            Items["CloseButton"]:Connect("MouseButton1Down", function()
                Notif:Close()
            end)

            Items["CollapseButton"]:Connect("MouseButton1Down", function()
                Notif:Collapse()
            end)

            if Duration > 0 then
                Items["ProgressBar"]:Tween(
                    TweenInfo.new(Duration, Enum.EasingStyle.Linear),
                    {Size = UDim2New(0, 0, 0, 5)}
                )

                task.delay(Duration, function()
                    Notif:Close()
                end)
            end

            return Notif
        end

        Library.Window = function(self, Data)
            Data = Data or {}

            local Window = {
                Name = Data.Name or "Ironite",
                GameName = Data.GameName or "",
                Logo = Data.Logo or "rbxassetid://108488788823423",

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

                Items["Header"]:MakeDraggable(Items["MainFrame"])

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
                    Parent = Items["Header"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Library.FontSemiBold,
                    Position = UDim2New(0, 36, 0.5, 0),
                    RichText = true,
                    Size = UDim2FromOffset(1, 1),
                    Text = Window.Name .. (Window.GameName ~= "" and (' <font color="#45475a">' .. Window.GameName .. "</font>") or ""),
                    TextColor3 = Library.Theme["ActiveText"],
                    TextSize = 14,
                    BorderSizePixel = 0
                })

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
                    AnchorPoint = Vector2New(0.5, 0),
                    Position = UDim2FromScale(0.5, 0),
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
                    PaddingTop = UDimNew(0, 10)
                })

                Items["SubHeader"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0),
                    Position = UDim2New(0, 75, 0, 37),
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
                    Position = UDim2New(0.5, 0, 1, -2),
                    Size = UDim2FromOffset(25, 2),
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
                    Tween:Create(Items["TabButton"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.9})
                    Tween:Create(Items["TabIcon"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {ImageColor3 = Library.Theme["ActiveText"]})
                    Tween:Create(Items["TabText"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {TextColor3 = Library.Theme["ActiveText"]})
                    Tween:Create(Items["TabPill"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})

                    for _, SubTab in Page.SubTabs do
                        if SubTab.Active then
                            SubTab:Show(true)
                        end
                    end
                else
                    Tween:Create(Items["TabButton"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
                    Tween:Create(Items["TabIcon"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {ImageColor3 = Library.Theme["InactiveText"]})
                    Tween:Create(Items["TabText"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {TextColor3 = Library.Theme["InactiveText"]})
                    Tween:Create(Items["TabPill"], TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})

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
                    Position = UDim2New(0.5, 0, 1, -2),
                    Size = UDim2FromOffset(34, 2),
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
                    Tween:Create(Items["TabName"], TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.8, TextTransparency = 0})
                    Items["TabName"].Instance.TextColor3 = Library.Theme["ActiveText"]
                    Items["TabName"].Instance.FontFace = Library.Font
                    Tween:Create(Items["SubTabPill"], TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})

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
                    Tween:Create(Items["TabName"], TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, TextTransparency = 0.15})
                    Items["TabName"].Instance.TextColor3 = Library.Theme["InactiveText"]
                    Items["TabName"].Instance.FontFace = Library.FontRegular
                    Tween:Create(Items["SubTabPill"], TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})

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

            function SubTab:Section(SectionData)
                SectionData = SectionData or {}

                local Section = {
                    Window = SubTab.Window,
                    Page = SubTab.Page,
                    SubTab = SubTab,

                    Name = SectionData.Name or "Section",
                    Side = SectionData.Side or "Left",
                    Icon = SectionData.Icon or "",

                    Items = {}
                }

                local ColumnParent
                if Section.Side == "Right" then
                    ColumnParent = SubTab.Items["RightColumn"].Instance
                else
                    ColumnParent = SubTab.Items["LeftColumn"].Instance
                end

                local SItems = {} do
                    SItems["SectionFrame"] = Instances:Create("Frame", {
                        Parent = ColumnParent,
                        Name = "\0",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Library.Theme["SectionBackground"],
                        ClipsDescendants = true,
                        Size = UDim2New(1, 0, 0, 60),
                        BorderSizePixel = 0
                    }):AddToTheme({BackgroundColor3 = "SectionBackground"})

                    Instances:Create("UICorner", {
                        Parent = SItems["SectionFrame"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 6)
                    })

                    SItems["Header"] = Instances:Create("Frame", {
                        Parent = SItems["SectionFrame"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0.5, 0),
                        Position = UDim2FromScale(0.5, 0),
                        BackgroundColor3 = Library.Theme["SectionHeader"],
                        Size = UDim2New(1, 0, 0, 30),
                        BorderSizePixel = 0
                    }):AddToTheme({BackgroundColor3 = "SectionHeader"})

                    Instances:Create("UICorner", {
                        Parent = SItems["Header"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 6)
                    })

                    if Section.Icon ~= "" then
                        SItems["SectionIcon"] = Instances:Create("ImageLabel", {
                            Parent = SItems["Header"].Instance,
                            Name = "\0",
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            Image = Section.Icon,
                            ImageColor3 = Library.Theme["ActiveText"],
                            Position = UDim2New(0, 10, 0.5, 0),
                            Size = UDim2FromOffset(14, 14),
                            ScaleType = Enum.ScaleType.Fit,
                            ResampleMode = Enum.ResamplerMode.Default,
                            BorderSizePixel = 0
                        })
                    end

                    SItems["SectionText"] = Instances:Create("TextLabel", {
                        Parent = SItems["Header"].Instance,
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

                    SItems["Content"] = Instances:Create("Frame", {
                        Parent = SItems["SectionFrame"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0.5, 0),
                        Position = UDim2New(0.5, 0, 0, 30),
                        BackgroundTransparency = 1,
                        Size = UDim2New(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BorderSizePixel = 0
                    })

                    Instances:Create("UIListLayout", {
                        Parent = SItems["Content"].Instance,
                        Name = "\0",
                        Padding = UDimNew(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Instances:Create("UIPadding", {
                        Parent = SItems["Content"].Instance,
                        Name = "\0",
                        PaddingTop = UDimNew(0, 6),
                        PaddingBottom = UDimNew(0, 10),
                        PaddingRight = UDimNew(0, 10),
                        PaddingLeft = UDimNew(0, 10)
                    })

                    Section.Items = SItems
                end

                return setmetatable(Section, Library.Sections)
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

        Library.Sections.Toggle = function(self, Data)
            Data = Data or {}

            local Toggle = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Toggle",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or false,
                Callback = Data.Callback or Data.callback or function() end,

                Value = false
            }

            local Items = {} do
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Toggle.Section.Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["ActiveText"],
                    TextTransparency = 0.5,
                    Text = Toggle.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                })

                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 35, 0, 18),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["ElementBackground"]
                }):AddToTheme({BackgroundColor3 = "ElementBackground"})

                Instances:Create("UICorner", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0"
                })

                Instances:Create("UIStroke", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    Color = Library.Theme["Stroke"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Stroke"})

                Items["Circle"] = Instances:Create("Frame", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 0.5,
                    Position = UDim2New(0, 4, 0.5, 0),
                    Size = UDim2New(0, 10, 0, 10),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = function() return FromRGB(255, 255, 255) end})

                Instances:Create("UICorner", {
                    Parent = Items["Circle"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })

                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["Circle"].Instance,
                    Name = "\0",
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 25, 1, 25),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = "Accent"})
            end

            function Toggle:Get()
                return Toggle.Value
            end

            function Toggle:Set(Value)
                Toggle.Value = Value
                Library.Flags[Toggle.Flag] = Value

                if Toggle.Value then
                    Items["Glow"]:Tween(nil, {ImageTransparency = 0.7})

                    Items["Circle"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    Items["Circle"]:Tween(nil, {
                        AnchorPoint = Vector2New(1, 0.5),
                        Position = UDim2New(1, -3, 0.5, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Library.Theme.Accent
                    })

                    Items["Text"]:Tween(nil, {TextTransparency = 0})
                else
                    Items["Glow"]:Tween(nil, {ImageTransparency = 1})

                    Items["Circle"]:ChangeItemTheme({BackgroundColor3 = function() return FromRGB(255, 255, 255) end})
                    Items["Circle"]:Tween(nil, {
                        AnchorPoint = Vector2New(0, 0.5),
                        Position = UDim2New(0, 4, 0.5, 0),
                        BackgroundTransparency = 0.5,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    Items["Text"]:Tween(nil, {TextTransparency = 0.5})
                end

                Library:SafeCall(Toggle.Callback, Toggle.Value)
            end

            Items["Toggle"].Instance.MouseButton1Down:Connect(function()
                Toggle:Set(not Toggle.Value)
            end)

            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end

            Toggle:Set(Toggle.Default)
            TableInsert(Toggle.Section.Items, Toggle)
            return Toggle
        end

        Library.Sections.Button = function(self, Data)
            Data = Data or {}

            local Button = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Button",
                Callback = Data.Callback or Data.callback or function() end,
            }

            local Items = {} do
                Items["Button"] = Instances:Create("TextButton", {
                    Parent = Button.Section.Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["ActiveText"],
                    Text = Button.Name,
                    AutoButtonColor = false,
                    BackgroundColor3 = Library.Theme["ElementBackground"],
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0,
                    TextSize = 14
                }):AddToTheme({BackgroundColor3 = "ElementBackground", TextColor3 = "ActiveText"})

                Instances:Create("UICorner", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })

                Items["Stroke"] = Instances:Create("UIStroke", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    Color = Library.Theme["Stroke"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Stroke"})

                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 10, 1, 10),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = "Accent"})
            end

            Items["Button"].Instance.MouseEnter:Connect(function()
                Items["Button"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Library.Theme["Hover"]})
                Items["Glow"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 0.8})
            end)

            Items["Button"].Instance.MouseLeave:Connect(function()
                Items["Button"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Library.Theme["ElementBackground"]})
                Items["Glow"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 1})
            end)

            Items["Button"].Instance.MouseButton1Down:Connect(function()
                Items["Button"]:Tween(TweenInfo.new(0.1, Enum.EasingStyle.Quart), {BackgroundColor3 = Library.Theme["Accent"]}, true)
                task.wait(0.1)
                Items["Button"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Library.Theme["Hover"]})
                Library:SafeCall(Button.Callback)
            end)

            TableInsert(Button.Section.Items, Button)
            return Button
        end

        Library.Sections.Slider = function(self, Data)
            Data = Data or {}

            local Slider = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Slider",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Min = Data.Min or Data.min or 0,
                Max = Data.Max or Data.max or 100,
                Default = Data.Default or Data.default or Data.Min or 0,
                Callback = Data.Callback or Data.callback or function() end,

                Value = Data.Default or Data.default or Data.Min or 0,
                Dragging = false
            }

            local Items = {} do
                Items["Slider"] = Instances:Create("TextButton", {
                    Parent = Slider.Section.Items["Content"].Instance,
                    Name = "\0",
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 38),
                    BorderSizePixel = 0
                })

                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["ActiveText"],
                    Text = Slider.Name,
                    Size = UDim2New(1, -50, 0, 15),
                    AnchorPoint = Vector2New(0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 14
                }):AddToTheme({TextColor3 = "ActiveText"})

                Items["ValueText"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["InactiveText"],
                    Text = tostring(Slider.Default) .. "%",
                    Size = UDim2New(0, 50, 0, 15),
                    AnchorPoint = Vector2New(1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextSize = 14
                }):AddToTheme({TextColor3 = "InactiveText"})

                Items["Track"] = Instances:Create("Frame", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, -4),
                    Size = UDim2New(1, 0, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["ElementBackground"]
                }):AddToTheme({BackgroundColor3 = "ElementBackground"})

                Instances:Create("UICorner", {
                    Parent = Items["Track"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["Track"].Instance,
                    Name = "\0",
                    Color = Library.Theme["Stroke"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Stroke"})

                Items["Fill"] = Instances:Create("Frame", {
                    Parent = Items["Track"].Instance,
                    Name = "\0",
                    BackgroundColor3 = Library.Theme["Accent"],
                    Size = UDim2New(0.5, 0, 1, 0),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = Items["Fill"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["Fill"].Instance,
                    Name = "\0",
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 1,
                    Size = UDim2New(1, 14, 1, 14),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = "Accent"})

                Items["Circle"] = Instances:Create("Frame", {
                    Parent = Items["Fill"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    BackgroundColor3 = FromRGB(0, 0, 0),
                    Position = UDim2New(1, -2, 0.5, 0),
                    Size = UDim2New(0, 8, 0, 8),
                    BorderSizePixel = 0
                })

                Instances:Create("UICorner", {
                    Parent = Items["Circle"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
            end

            function Slider:Set(Value)
                Slider.Value = math.clamp(math.round(Value), Slider.Min, Slider.Max)
                Library.Flags[Slider.Flag] = Slider.Value
                
                local Percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                Items["ValueText"].Instance.Text = tostring(Slider.Value) .. "%"
                Items["Fill"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New(Percent, 0, 1, 0)})
                
                Library:SafeCall(Slider.Callback, Slider.Value)
            end

            local function Update(Input)
                local Percent = math.clamp((Input.Position.X - Items["Track"].Instance.AbsolutePosition.X) / Items["Track"].Instance.AbsoluteSize.X, 0, 1)
                local Value = Slider.Min + (Slider.Max - Slider.Min) * Percent
                Slider:Set(Value)
            end

            Items["Slider"].Instance.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Dragging = true
                    Items["Glow"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 0.8})
                    Update(Input)
                end
            end)

            Items["Slider"].Instance.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Dragging = false
                    Items["Glow"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 1})
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Slider.Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Update(Input)
                end
            end)
            
            Items["Slider"].Instance.MouseEnter:Connect(function()
                if not Slider.Dragging then
                    Items["Glow"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 0.9})
                end
            end)
            
            Items["Slider"].Instance.MouseLeave:Connect(function()
                if not Slider.Dragging then
                    Items["Glow"]:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 1})
                end
            end)

            Slider:Set(Slider.Default)
            TableInsert(Slider.Section.Items, Slider)
            return Slider
        end
    end
end

getgenv().Library = Library
return Library
