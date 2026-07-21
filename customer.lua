
-- local Library = loadstring(game:HttpGet("your url/customer.lua"))()
--
-- local Window = Library:Window({
--     Name = "Ironite",
--     Logo = "rbxassetid://108488788823423"
-- })
--
-- local Main = Window:Page({
--     Name = "Main",
--     Icon = "rbxassetid://80869096876893"
-- })
--
-- local Combat = Main:SubTab({Name = "Combat"})

local Library do
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local CoreGui = game:GetService("CoreGui")

    local GetHui = gethui or function()
        return CoreGui
    end

    local FromRGB = Color3.fromRGB
    local InstanceNew = Instance.new
    local UDim2New = UDim2.new
    local Vector2New = Vector2.new
    local TableInsert = table.insert

    local ActiveTweens = setmetatable({}, {__mode = "k"})

    Library = {
        Theme = {
            Background = FromRGB(19, 20, 25),
            Outline = FromRGB(31, 31, 45),
            Inline = FromRGB(19, 20, 25),
            Element = FromRGB(31, 31, 45),
            Accent = FromRGB(255, 255, 255),
            Text = FromRGB(255, 255, 255),
            MutedText = FromRGB(69, 71, 90),
            TabSurface = FromRGB(247, 247, 247),
            TabGradientEnd = FromRGB(147, 147, 147)
        },

        MenuKeybind = tostring(Enum.KeyCode.RightControl),

        Connections = {},
        ThemeItems = {},
        ThemeMap = {},
        Windows = {},

        Holder = nil,
        Font = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.Medium,
            Enum.FontStyle.Normal
        ),
        BoldFont = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.Bold,
            Enum.FontStyle.Normal
        ),

        Pages = {},
        SubTabs = {}
    }

    Library.__index = Library
    Library.Pages.__index = Library.Pages
    Library.SubTabs.__index = Library.SubTabs

    local Tween = {}
    Tween.__index = Tween

    function Tween:Cancel(Item)
        if typeof(Item) ~= "Instance" then
            Item = Item.Instance
        end

        local CurrentTween = ActiveTweens[Item]
        if not CurrentTween then
            return
        end

        CurrentTween.Connection:Disconnect()
        CurrentTween.Tween:Cancel()
        ActiveTweens[Item] = nil
    end

    function Tween:Create(Item, Info, Goal, IsRawItem, Callback)
        Item = IsRawItem and Item or Item.Instance
        Info = Info or TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        Tween:Cancel(Item)

        local NewTween = {
            Tween = TweenService:Create(Item, Info, Goal),
            Connection = nil
        }

        NewTween.Connection = NewTween.Tween.Completed:Connect(function(State)
            NewTween.Connection:Disconnect()

            if ActiveTweens[Item] == NewTween then
                ActiveTweens[Item] = nil
            end

            if State == Enum.PlaybackState.Completed and Callback then
                Callback()
            end
        end)

        ActiveTweens[Item] = NewTween
        NewTween.Tween:Play()

        return NewTween
    end

    local Instances = {}
    Instances.__index = Instances

    function Instances:Create(Class, Properties)
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

    function Instances:Connect(Event, Callback)
        return Library:Connect(self.Instance[Event], Callback)
    end

    function Instances:Tween(Info, Goal, Callback)
        return Tween:Create(self, Info, Goal, false, Callback)
    end

    function Instances:Clean()
        Tween:Cancel(self)
        self.Instance:Destroy()
    end

    function Instances:AddToTheme(Properties)
        Library:AddToTheme(self, Properties)
        return self
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = GetHui(),
        Name = "ironite",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })

    function Library:Connect(Event, Callback)
        local Connection = Event:Connect(Callback)
        TableInsert(self.Connections, Connection)

        return Connection
    end

    function Library:AddToTheme(Item, Properties)
        Item = Item.Instance or Item

        local ThemeData = {
            Item = Item,
            Properties = Properties
        }

        for Property, Value in ThemeData.Properties do
            Item[Property] = type(Value) == "string" and self.Theme[Value] or Value()
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    function Library:ChangeTheme(Name, Color)
        self.Theme[Name] = Color

        for _, ThemeData in self.ThemeItems do
            for Property, Value in ThemeData.Properties do
                if Value == Name then
                    ThemeData.Item[Property] = Color
                elseif type(Value) == "function" then
                    ThemeData.Item[Property] = Value()
                end
            end
        end
    end

    function Library:Unload()
        for _, Connection in self.Connections do
            Connection:Disconnect()
        end

        for Item in ActiveTweens do
            Tween:Cancel(Item)
        end

        if self.Holder then
            self.Holder:Clean()
        end
    end

    local function CreateCorner(Parent, Radius)
        return Instances:Create("UICorner", {
            Parent = Parent,
            CornerRadius = UDim.new(0, Radius)
        })
    end

    local function CreateDivider(Parent, Position, Size)
        return Instances:Create("Frame", {
            Parent = Parent,
            BackgroundColor3 = Library.Theme.Outline,
            BorderSizePixel = 0,
            Position = Position,
            Size = Size
        }):AddToTheme({BackgroundColor3 = "Outline"})
    end

    local function CreateColumn(Parent, Position, Size)
        local Column = Instances:Create("ScrollingFrame", {
            Parent = Parent,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2New(0, 0, 0, 0),
            Position = Position,
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Size = Size
        })

        Instances:Create("UIPadding", {
            Parent = Column.Instance,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 16),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16)
        })

        Instances:Create("UIListLayout", {
            Parent = Column.Instance,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        return Column
    end

    local function GetGameName()
        local Success, ProductInfo = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)

        if Success and type(ProductInfo) == "table" and type(ProductInfo.Name) == "string" then
            return ProductInfo.Name
        end

        return "Unsupported game"
    end

    local function UpdatePageStyle(Page, Bool)
        local Items = Page.Items

        Items["Inactive"]:Tween(nil, {
            BackgroundTransparency = Bool and 0.9 or 1
        })

        Items["Icon"]:Tween(nil, {
            ImageColor3 = Bool and Library.Theme.Text or Library.Theme.MutedText
        })

        Items["Text"]:Tween(nil, {
            TextColor3 = Bool and Library.Theme.Text or Library.Theme.MutedText
        })

        Items["Indicator"]:Tween(
            TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = Bool and 0 or 1,
                Size = UDim2New(0, Bool and 25 or 0, 0, 6)
            }
        )
    end

    local function UpdateSubTabStyle(SubTab, Bool)
        local Items = SubTab.Items

        Items["Text"]:Tween(nil, {
            TextColor3 = Bool and Library.Theme.Text or Library.Theme.MutedText
        })

        Items["Indicator"]:Tween(nil, {
            BackgroundTransparency = Bool and 0 or 1,
            Size = UDim2New(0, Bool and 24 or 0, 0, 2)
        })
    end

    Library.Window = function(self, Data)
        Data = Data or {}

        local Window = {
            Name = Data.Name or Data.name or "Ironite",
            Logo = Data.Logo or Data.logo or "",

            Pages = {},
            Items = {},
            IsOpen = false,
            Destroyed = false
        }

        local Items = {} do
            Items["MainFrame"] = Instances:Create("CanvasGroup", {
                Parent = Library.Holder.Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                BackgroundColor3 = Library.Theme.Background,
                BorderSizePixel = 0,
                GroupTransparency = 1,
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 695, 0, 489),
                Visible = false
            }):AddToTheme({BackgroundColor3 = "Background"})

            CreateCorner(Items["MainFrame"].Instance, 11)

            Items["Header"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(1, 0, 0, 37)
            })

            CreateDivider(
                Items["Header"].Instance,
                UDim2New(0, 0, 1, -2),
                UDim2New(1, 1, 0, 2)
            )

            Items["Logo"] = Instances:Create("ImageLabel", {
                Parent = Items["Header"].Instance,
                AnchorPoint = Vector2New(0, 0.5),
                BackgroundTransparency = 1,
                Image = Window.Logo,
                Position = UDim2New(0, 12, 0.5, 0),
                ScaleType = Enum.ScaleType.Fit,
                Size = UDim2New(0, 20, 0, 20)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Header"].Instance,
                AnchorPoint = Vector2New(0, 0.5),
                BackgroundTransparency = 1,
                FontFace = Library.Font,
                Position = UDim2New(0, 42, 0.5, 0),
                Size = UDim2New(0, 42, 0, 18),
                Text = Window.Name,
                TextColor3 = Library.Theme.Text,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left
            }):AddToTheme({TextColor3 = "Text"})

            Items["GameName"] = Instances:Create("TextLabel", {
                Parent = Items["Header"].Instance,
                AnchorPoint = Vector2New(0, 0.5),
                BackgroundTransparency = 1,
                FontFace = Library.Font,
                Position = UDim2New(0, 88, 0.5, 0),
                Size = UDim2New(1, -100, 0, 18),
                Text = "Loading game",
                TextColor3 = Library.Theme.MutedText,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left
            }):AddToTheme({TextColor3 = "MutedText"})

            Items["Sidebar"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2New(0, 0, 0, 37),
                Size = UDim2New(0, 75, 1, -37)
            })

            CreateDivider(
                Items["Sidebar"].Instance,
                UDim2New(1, -2, 0, 0),
                UDim2New(0, 2, 1, 0)
            )

            Items["Pages"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Sidebar"].Instance,
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2New(1, 0, 1, 0)
            })

            Instances:Create("UIPadding", {
                Parent = Items["Pages"].Instance,
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Pages"].Instance,
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2New(0, 75, 0, 37),
                Size = UDim2New(1, -75, 1, -37)
            })

            Window.Items = Items
        end

        function Window:SetOpen(Bool)
            if Window.Destroyed or Window.IsOpen == Bool then
                return
            end

            Window.IsOpen = Bool

            if Bool then
                Items["MainFrame"].Instance.Visible = true
                Items["MainFrame"].Instance.GroupTransparency = 1
                Items["MainFrame"].Instance.Position = UDim2New(0.5, 0, 0.5, 8)

                Items["MainFrame"]:Tween(nil, {
                    GroupTransparency = 0,
                    Position = UDim2New(0.5, 0, 0.5, 0)
                })
            else
                Items["MainFrame"]:Tween(
                    TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {
                        GroupTransparency = 1,
                        Position = UDim2New(0.5, 0, 0.5, 8)
                    },
                    function()
                        if not Window.IsOpen and not Window.Destroyed then
                            Items["MainFrame"].Instance.Visible = false
                        end
                    end
                )
            end
        end

        function Window:SelectPage(Target, Immediate)
            if Window.Destroyed or Window.ActivePage == Target then
                return
            end

            for _, Value in Window.Pages do
                local IsTarget = Value == Target

                Value.Active = IsTarget
                UpdatePageStyle(Value, IsTarget)

                if not IsTarget then
                    Tween:Cancel(Value.Items["Page"])
                    Value.Items["Page"].Instance.Visible = false
                end
            end

            Window.ActivePage = Target

            local PageFrame = Target.Items["Page"].Instance
            PageFrame.Visible = true
            PageFrame.GroupTransparency = Immediate and 0 or 1
            PageFrame.Position = UDim2New(0, 0, 0, Immediate and 0 or 8)

            if not Immediate then
                Target.Items["Page"]:Tween(nil, {
                    GroupTransparency = 0,
                    Position = UDim2New(0, 0, 0, 0)
                })
            end
        end

        function Window:Destroy()
            if Window.Destroyed then
                return
            end

            Window.Destroyed = true
            Tween:Cancel(Items["MainFrame"])
            Items["MainFrame"]:Clean()
        end

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if Processed then
                return
            end

            if tostring(Input.KeyCode) == Library.MenuKeybind then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        task.spawn(function()
            local GameName = GetGameName()

            if not Window.Destroyed then
                Items["GameName"].Instance.Text = GameName
            end
        end)

        Window.CreateTab = Library.Page
        Window.CreatePage = Library.Page

        TableInsert(Library.Windows, Window)
        Window:SetOpen(true)

        return setmetatable(Window, Library)
    end

    Library.Page = function(self, Data)
        Data = Data or {}

        local Page = {
            Window = self,
            Name = Data.Name or Data.name or "Page",
            Icon = Data.Icon or Data.icon or "",

            Items = {},
            SubTabs = {},
            Active = false,
            ActiveSubTab = nil
        }

        local Items = {} do
            Items["Inactive"] = Instances:Create("TextButton", {
                Parent = Page.Window.Items["Pages"].Instance,
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2New(0, 55, 0, 60),
                Text = ""
            })

            CreateCorner(Items["Inactive"].Instance, 5)

            Instances:Create("UIGradient", {
                Parent = Items["Inactive"].Instance,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Library.Theme.TabSurface),
                    ColorSequenceKeypoint.new(1, Library.Theme.TabGradientEnd)
                })
            })

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["Inactive"].Instance,
                AnchorPoint = Vector2New(0.5, 1),
                BackgroundColor3 = Library.Theme.Text,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2New(0.5, 0, 1, 3),
                Size = UDim2New(0, 0, 0, 6)
            }):AddToTheme({BackgroundColor3 = "Text"})

            CreateCorner(Items["Indicator"].Instance, 12)

            Items["Icon"] = Instances:Create("ImageLabel", {
                Parent = Items["Inactive"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = Page.Icon,
                ImageColor3 = Library.Theme.MutedText,
                Position = UDim2New(0.5, 0, 0.5, -8),
                Size = UDim2New(0, 24, 0, 22)
            }):AddToTheme({ImageColor3 = "MutedText"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Inactive"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                FontFace = Library.BoldFont,
                Position = UDim2New(0.5, 0, 0.5, 20),
                Size = UDim2New(0, 1, 0, 1),
                Text = Page.Name,
                TextColor3 = Library.Theme.MutedText,
                TextSize = 12
            }):AddToTheme({TextColor3 = "MutedText"})

            Items["Page"] = Instances:Create("CanvasGroup", {
                Parent = Page.Window.Items["Content"].Instance,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                GroupTransparency = 1,
                Position = UDim2New(0, 0, 0, 8),
                Size = UDim2New(1, 0, 1, 0),
                Visible = false
            })

            Items["SubTabs"] = Instances:Create("Frame", {
                Parent = Items["Page"].Instance,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2New(0, 16, 0, 10),
                Size = UDim2New(1, -32, 0, 30)
            })

            CreateDivider(
                Items["SubTabs"].Instance,
                UDim2New(0, 0, 1, 0),
                UDim2New(1, 0, 0, 1)
            )

            Instances:Create("UIListLayout", {
                Parent = Items["SubTabs"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Column"] = CreateColumn(
                Items["Page"].Instance,
                UDim2New(0, 0, 0, 0),
                UDim2New(1, 0, 1, 0)
            )

            Page.Items = Items
        end

        function Page:Turn(Bool)
            if Bool then
                Page.Window:SelectPage(Page)
            elseif Page.Window.ActivePage == Page then
                Page.Active = false
                Page.Items["Page"].Instance.Visible = false
                UpdatePageStyle(Page, false)
            end
        end

        function Page:SelectSubTab(Target, Immediate)
            if Page.ActiveSubTab == Target then
                return
            end

            for _, Value in Page.SubTabs do
                local IsTarget = Value == Target

                Value.Active = IsTarget
                UpdateSubTabStyle(Value, IsTarget)

                if not IsTarget then
                    Tween:Cancel(Value.Items["Page"])
                    Value.Items["Page"].Instance.Visible = false
                end
            end

            Page.ActiveSubTab = Target

            local SubTabFrame = Target.Items["Page"].Instance
            SubTabFrame.Visible = true
            SubTabFrame.GroupTransparency = Immediate and 0 or 1
            SubTabFrame.Position = UDim2New(0, 0, 0, Immediate and 0 or 6)

            if not Immediate then
                Target.Items["Page"]:Tween(nil, {
                    GroupTransparency = 0,
                    Position = UDim2New(0, 0, 0, 0)
                })
            end
        end

        Items["Inactive"]:Connect("MouseButton1Click", function()
            Page.Window:SelectPage(Page)
        end)

        Items["Inactive"]:Connect("MouseEnter", function()
            if not Page.Active then
                Items["Inactive"]:Tween(
                    TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.95}
                )
            end
        end)

        Items["Inactive"]:Connect("MouseLeave", function()
            if not Page.Active then
                Items["Inactive"]:Tween(
                    TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 1}
                )
            end
        end)

        TableInsert(Page.Window.Pages, Page)

        if #Page.Window.Pages == 1 then
            Page.Window:SelectPage(Page, true)
        end

        return setmetatable(Page, Library.Pages)
    end

    Library.Pages.SubTab = function(self, Data)
        Data = Data or {}

        local SubTab = {
            Page = self,
            Name = Data.Name or Data.name or "SubTab",
            Items = {},
            Active = false
        }

        local Items = {} do
            Items["Button"] = Instances:Create("TextButton", {
                Parent = SubTab.Page.Items["SubTabs"].Instance,
                AutomaticSize = Enum.AutomaticSize.X,
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(0, 0, 1, 0),
                Text = ""
            })

            Instances:Create("UIPadding", {
                Parent = Items["Button"].Instance,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Button"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                FontFace = Library.BoldFont,
                Position = UDim2New(0.5, 0, 0.5, -1),
                Size = UDim2New(0, 1, 0, 1),
                Text = SubTab.Name,
                TextColor3 = Library.Theme.MutedText,
                TextSize = 12
            }):AddToTheme({TextColor3 = "MutedText"})

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["Button"].Instance,
                AnchorPoint = Vector2New(0.5, 1),
                BackgroundColor3 = Library.Theme.Text,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2New(0.5, 0, 1, 0),
                Size = UDim2New(0, 0, 0, 2)
            }):AddToTheme({BackgroundColor3 = "Text"})

            CreateCorner(Items["Indicator"].Instance, 2)

            Items["Page"] = Instances:Create("CanvasGroup", {
                Parent = SubTab.Page.Items["Page"].Instance,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                GroupTransparency = 1,
                Position = UDim2New(0, 0, 0, 6),
                Size = UDim2New(1, 0, 1, 0),
                Visible = false
            })

            Items["Column"] = CreateColumn(
                Items["Page"].Instance,
                UDim2New(0, 0, 0, 42),
                UDim2New(1, 0, 1, -42)
            )

            SubTab.Items = Items
        end

        function SubTab:Turn(Bool)
            if Bool then
                SubTab.Page:SelectSubTab(SubTab)
            elseif SubTab.Page.ActiveSubTab == SubTab then
                SubTab.Active = false
                SubTab.Items["Page"].Instance.Visible = false
                UpdateSubTabStyle(SubTab, false)
            end
        end

        Items["Button"]:Connect("MouseButton1Click", function()
            SubTab.Page:SelectSubTab(SubTab)
        end)

        Items["Button"]:Connect("MouseEnter", function()
            if not SubTab.Active then
                Items["Text"]:Tween(
                    TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {TextColor3 = Library.Theme.Text}
                )
            end
        end)

        Items["Button"]:Connect("MouseLeave", function()
            if not SubTab.Active then
                Items["Text"]:Tween(
                    TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {TextColor3 = Library.Theme.MutedText}
                )
            end
        end)

        TableInsert(SubTab.Page.SubTabs, SubTab)

        if #SubTab.Page.SubTabs == 1 then
            SubTab.Page.Items["Column"].Instance.Visible = false
            SubTab.Page:SelectSubTab(SubTab, true)
        end

        return setmetatable(SubTab, Library.SubTabs)
    end

    Library.Pages.CreateSubTab = Library.Pages.SubTab
    Library.CreateWindow = Library.Window
end

local Environment = getgenv and getgenv() or _G
Environment.CustomerLibrary = Library

return Library
