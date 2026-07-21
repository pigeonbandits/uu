if getgenv().IroniteLibrary then
    getgenv().IroniteLibrary:Unload()
end

local Library do

    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local CoreGui = (cloneref and cloneref(game:GetService("CoreGui"))) or game:GetService("CoreGui")

    local GetHui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local Camera = Workspace.CurrentCamera

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local ColorSequenceNew = ColorSequence.new
    local ColorSequenceKeypointNew = ColorSequenceKeypoint.new
    local NumberSequenceNew = NumberSequence.new
    local NumberSequenceKeypointNew = NumberSequenceKeypoint.new

    local UDimNew = UDim.new
    local UDim2New = UDim2.new
    local UDim2FromOffset = UDim2.fromOffset
    local UDim2FromScale = UDim2.fromScale

    local Vector2New = Vector2.new
    local Vector3New = Vector3.new
    local RectNew = Rect.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathRound = math.round
    local MathAbs = math.abs
    local MathSin = math.sin
    local MathCos = math.cos
    local MathMin = math.min
    local MathMax = math.max

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringSub = string.sub
    local StringFind = string.find

    local TaskSpawn = task.spawn
    local TaskWait = task.wait
    local TaskDelay = task.delay
    local CoroutineCreate = coroutine.create
    local CoroutineResume = coroutine.resume
    local CoroutineWrap = coroutine.wrap
    local CoroutineClose = coroutine.close

    local InstanceNew = Instance.new
    local EnumEasingStyle = Enum.EasingStyle
    local EnumEasingDirection = Enum.EasingDirection
    local EnumPlaybackState = Enum.PlaybackState
    local EnumUserInputType = Enum.UserInputType
    local EnumUserInputState = Enum.UserInputState

    Library = {
        MenuKeybind = Enum.KeyCode.RightControl,
        FadeSpeed = 0.18,

        Theme = {},

        Metrics = {},

        Font = nil,
        Fonts = {},

        Flags = {},
        SetFlags = {},
        Connections = {},
        Threads = {},
        ThemeItems = {},
        ThemeMap = {},

        Holder = nil,
        UnusedHolder = nil,
        NotifHolder = nil,

        Pages = {},
        Sections = {},
        Elements = {},

        Windows = {},

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Tween = {
            Time = 0.2,
            Style = EnumEasingStyle.Circular,
            Direction = EnumEasingDirection.Out,
        },
    }

    Library.__index = Library
    Library.Pages.__index = Library.Pages
    Library.Sections.__index = Library.Sections
    Library.Elements.__index = Library.Elements

    local AccentTop = FromRGB(254, 254, 254)
    local AccentBottom = FromRGB(147, 147, 147)

    Library.Theme = {
        Background = FromRGB(19, 20, 25),
        Page = FromRGB(16, 17, 21),
        Section = FromRGB(17, 18, 22),
        Element = FromRGB(24, 25, 32),
        Stroke = FromRGB(28, 30, 38),
        Divider = FromRGB(31, 31, 45),
        DividerSoft = FromRGB(26, 26, 37),
        TabSurface = FromRGB(247, 247, 247),
        Accent = AccentTop,
        AccentEnd = AccentBottom,
        Text = FromRGB(255, 255, 255),
        Muted = FromRGB(69, 71, 90),
        MutedSoft = FromRGB(204, 204, 209),
        Custom = FromRGB(230, 255, 2),
    }

    local function BuildAccentSequence()
        return ColorSequenceNew({
            ColorSequenceKeypointNew(0, Library.Theme.Accent),
            ColorSequenceKeypointNew(1, Library.Theme.AccentEnd),
        })
    end

    Library.Metrics = {
        Window = { Width = 695, Height = 489, Corner = 11 },
        Header = { Height = 37, LinerThickness = 2 },
        Sidebar = {
            Width = 75,
            PaddingLeft = 9,
            PaddingTop = 10,
            TabGap = 5,
            LinerThickness = 2,
        },
        Tab = {
            Width = 55,
            Height = 60,
            Corner = 5,
            IconWidth = 24,
            IconHeight = 22,
            IndicatorWidth = 25,
            IndicatorHeight = 6,
            IndicatorCorner = 12,
        },
        SubHeader = {
            Height = 51,
            PaddingLeft = 25,
            PaddingTop = 4,
            Gap = 8,
        },
        SubTab = {
            PaddingH = 8,
            PaddingV = 10,
            Corner = 4,
            IndicatorWidth = 34,
            IndicatorHeight = 6,
            IndicatorCorner = 12,
        },
        Page = { Corner = 11 },
        Container = { Gap = 20, PaddingLeft = 12, PaddingTop = 12 },
        Section = {
            Width = 281,
            HeaderHeight = 30,
            Corner = 6,
            LinerThickness = 1,
            IconSize = 15,
            ActiveLineWidth = 6,
            ActiveLineHeight = 20,
            ActiveLineCorner = 30,
            ElementGap = 4,
            ElementPaddingTop = 5,
            ElementPaddingBottom = 45,
        },
        Element = {
            RowWidth = 312,
            ToggleRow = 30,
            SliderRow = 40,
            KeybindRow = 50,
            DropdownRow = 55,
            ButtonRow = 40,
            AccentRow = 43,
            ToggleBox = 14,
            ToggleCorner = 3,
            SliderTrackWidth = 266,
            SliderTrackHeight = 4,
            SliderFillHeight = 7,
            SliderKnob = 6,
            SliderHalo = 14,
            DropdownChipWidth = 264,
            DropdownChipHeight = 22,
            DropdownCorner = 2,
            ButtonWidth = 251,
            ButtonHeight = 30,
            ButtonCorner = 3,
            CheckIconWidth = 8,
            CheckIconHeight = 7,
            ColorSwatch = 15,
            PillCapWidth = 6,
            PillCapHeight = 13,
            PillCapCorner = 30,
        },
        Notification = {
            Width = 320,
            Gap = 12,
            Corner = 8,
            Icon = 20,
            IconHolder = 30,
            CloseIcon = 18,
            ButtonPaddingV = 6,
            ButtonPaddingH = 8,
            ButtonCorner = 6,
            ProgressHeight = 5,
            ProgressFillScale = 0.871795,
            HeaderPaddingH = 24,
            HeaderPaddingTop = 4,
            HeaderPaddingRight = 4,
            HeaderPaddingLeft = 6,
            BodyPaddingLeft = 12,
            BodyPaddingBottom = 12,
            MaxVisible = 5,
        },
        Watermark = {
            Height = 28,
            PaddingH = 10,
            Gap = 8,
            Corner = 6,
        },
        FontSize = {
            Tab = 12,
            SubTab = 13,
            Section = 12,
            Element = 12,
            ElementValue = 14,
            Slider = 14,
            DropdownLabel = 12,
            DropdownOption = 13,
            Button = 13,
            KeybindValue = 10,
            Header = 14,
            HeaderSecondary = 12,
            Watermark = 13,
            NotificationTitle = 14,
            NotificationBody = 14,
        },
    }

    local FontAsset = "rbxassetid://12187365364"

    Library.Fonts = {
        Regular = Font.new(FontAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Medium = Font.new(FontAsset, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        SemiBold = Font.new(FontAsset, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Bold = Font.new(FontAsset, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
    }
    Library.Font = Library.Fonts.Medium

    local function RoundTo(Number, Step)
        if not Step or Step == 0 then
            return Number
        end
        local Multiplier = 1 / Step
        return MathFloor(Number * Multiplier) / Multiplier
    end
    Library.Round = RoundTo

    local function Lerp(Start, Finish, Alpha)
        return Start + (Finish - Start) * Alpha
    end
    Library.Lerp = Lerp

    local function Clamp(Value, Min, Max)
        return MathClamp(Value, Min, Max)
    end
    Library.Clamp = Clamp

    function Library.SafeCall(Function, ...)
        local Success, Result = pcall(Function, ...)
        if not Success then
            warn(("[Ironite] callback error: %s"):format(tostring(Result)))
            return false, Result
        end
        return true, Result
    end

    function Library.Thread(Function)
        local NewThread = CoroutineCreate(Function)
        CoroutineWrap(function()
            CoroutineResume(NewThread)
        end)()
        TableInsert(Library.Threads, NewThread)
        return NewThread
    end

    function Library.NextFlag()
        Library.UnnamedFlags = Library.UnnamedFlags + 1
        return StringFormat("flag_%d_%s", Library.UnnamedFlags, HttpService:GenerateGUID(false))
    end

    function Library.IsMouseOverFrame(Frame)
        if typeof(Frame) == "table" and Frame.Instance then
            Frame = Frame.Instance
        end
        local Position = Frame.AbsolutePosition
        local Size = Frame.AbsoluteSize
        local Point = Vector2New(Mouse.X, Mouse.Y)
        return Point.X >= Position.X and Point.X <= Position.X + Size.X
           and Point.Y >= Position.Y and Point.Y <= Position.Y + Size.Y
    end

    function Library.IsClipped(Object, Column)
        local ColumnTop = Column.AbsolutePosition
        local ColumnBottom = ColumnTop + Column.AbsoluteSize
        local Top = Object.AbsolutePosition
        local Bottom = Top + Object.AbsoluteSize
        return Top.X < ColumnTop.X or Top.Y < ColumnTop.Y
            or Bottom.X > ColumnBottom.X or Bottom.Y > ColumnBottom.Y
    end

    function Library.ToRich(Text, Color)
        return StringFormat(
            '<font color="rgb(%d,%d,%d)">%s</font>',
            MathFloor(Color.R * 255), MathFloor(Color.G * 255), MathFloor(Color.B * 255), Text
        )
    end

    local function FormatClock()
        local Now = DateTime.now()
        return StringFormat("%02d:%02d:%02d", Now.Hour, Now.Minute, Now.Second)
    end
    Library.FormatClock = FormatClock

    function Library.Connect(Event, Callback, Name)
        Name = Name or StringFormat("conn_%d_%s", Library.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        Library.UnnamedConnections = Library.UnnamedConnections + 1

        local Entry = {
            Name = Name,
            Callback = Callback,
            Event = Event,
            Connection = Event:Connect(Callback),
        }
        TableInsert(Library.Connections, Entry)
        return Entry
    end

    function Library.Disconnect(Name)
        for Index, Entry in pairs(Library.Connections) do
            if Entry.Name == Name then
                Entry.Connection:Disconnect()
                TableRemove(Library.Connections, Index)
                return
            end
        end
    end

    function Library.AddToTheme(Item, Properties)
        local Instance = Item.Instance or Item
        local ThemeData = {
            Item = Instance,
            Properties = Properties,
        }

        for Property, Value in pairs(Properties) do
            if type(Value) == "string" then
                Instance[Property] = Library.Theme[Value]
            elseif type(Value) == "function" then
                Instance[Property] = Value()
            else
                Instance[Property] = Value
            end
        end

        TableInsert(Library.ThemeItems, ThemeData)
        Library.ThemeMap[Instance] = ThemeData
        return ThemeData
    end

    function Library.ChangeItemTheme(Item, Properties)
        local Instance = Item.Instance or Item
        local ThemeData = Library.ThemeMap[Instance]
        if not ThemeData then
            return Library.AddToTheme(Item, Properties)
        end
        ThemeData.Properties = Properties
        for Property, Value in pairs(Properties) do
            if type(Value) == "string" then
                Instance[Property] = Library.Theme[Value]
            elseif type(Value) == "function" then
                Instance[Property] = Value()
            else
                Instance[Property] = Value
            end
        end
        return ThemeData
    end

    function Library.ChangeTheme(Key, Color)
        Library.Theme[Key] = Color
        for _, ThemeData in pairs(Library.ThemeItems) do
            for Property, Value in pairs(ThemeData.Properties) do
                if type(Value) == "string" and Value == Key then
                    ThemeData.Item[Property] = Color
                elseif type(Value) == "function" then
                    ThemeData.Item[Property] = Value()
                end
            end
        end
    end

    function Library.SetFlag(Name, Value)
        Library.Flags[Name] = Value
    end

    function Library.GetFlag(Name)
        return Library.Flags[Name]
    end

    function Library.RegisterSetter(Name, Setter)
        Library.SetFlags[Name] = Setter
    end

    local ConfigFolder = "ironite/Configs"

    local function ExecutorFsAvailable()
        return type(makefolder) == "function" and type(isfolder) == "function"
    end

    local function EnsureConfigFolder()
        if ExecutorFsAvailable() and not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end
    Library.EnsureConfigFolder = EnsureConfigFolder

    function Library.GetConfig()
        local Config = {}
        for Name, Value in pairs(Library.Flags) do
            if type(Value) == "table" then
                if Value.Key then

                    Config[Name] = { Key = tostring(Value.Key), Mode = Value.Mode }
                elseif Value.Color then

                    Config[Name] = { Color = "#" .. (Value.HexValue or "ffffff"), Alpha = Value.Alpha or 1 }
                else
                    Config[Name] = Value
                end
            else
                Config[Name] = Value
            end
        end
        return HttpService:JSONEncode(Config)
    end

    function Library.LoadConfig(RawConfig)
        local Decoded
        local Ok, Err = pcall(HttpService.JSONDecode, HttpService, RawConfig)
        if not Ok then
            return false, Err
        end
        Decoded = Err

        for Name, Value in pairs(Decoded) do
            local Setter = Library.SetFlags[Name]
            if Setter then
                if type(Value) == "table" and Value.Key then
                    Library.SafeCall(Setter, Value)
                elseif type(Value) == "table" and Value.Color then
                    Library.SafeCall(Setter, Value.Color, Value.Alpha)
                else
                    Library.SafeCall(Setter, Value)
                end
            end
        end
        return true
    end

    function Library.SaveConfig(Name)
        EnsureConfigFolder()
        if not writefile then
            return false, "writefile unavailable"
        end
        writefile(ConfigFolder .. "/" .. Name .. ".json", Library:GetConfig())
        return true
    end

    function Library.DeleteConfig(Name)
        if delfile and isfile and isfile(ConfigFolder .. "/" .. Name .. ".json") then
            delfile(ConfigFolder .. "/" .. Name .. ".json")
            return true
        end
        return false
    end

    function Library.ListConfigs()
        if not ExecutorFsAvailable() or not isfolder(ConfigFolder) or type(listfiles) ~= "function" then
            return {}
        end
        local Result = {}
        for _, Path in ipairs(listfiles(ConfigFolder)) do
            if StringSub(Path, -5) == ".json" then

                local BaseStart = #Path - 5
                while BaseStart > 0 do
                    local Ch = StringSub(Path, BaseStart, BaseStart)
                    if Ch == "/" or Ch == "\\" then
                        break
                    end
                    BaseStart = BaseStart - 1
                end
                TableInsert(Result, StringSub(Path, BaseStart + 1, #Path - 5))
            end
        end
        return Result
    end

    local Tween = {}
    Tween.__index = Tween

    local ActiveTweens = setmetatable({}, { __mode = "k" })

    local DefaultTweenInfo = TweenInfo.new(
        Library.Tween.Time,
        Library.Tween.Style,
        Library.Tween.Direction
    )

    local function ResolveInfo(Info)
        if not Info then
            return DefaultTweenInfo
        end
        return Info
    end

    function Tween.Cancel(Instance)
        local Record = ActiveTweens[Instance]
        if not Record then
            return
        end
        ActiveTweens[Instance] = nil
        if Record.Connection and Record.Connection.Connected then
            Record.Connection:Disconnect()
        end
        Record.Tween:Cancel()
    end

    function Tween.Create(Item, Info, Goal, IsRawInstance, OnComplete)
        local Instance = IsRawInstance and Item or Item.Instance
        Info = ResolveInfo(Info)

        Tween.Cancel(Instance)

        local Record = {
            Tween = TweenService:Create(Instance, Info, Goal),
            Info = Info,
            Goal = Goal,
            Item = Instance,
            Connection = nil,
        }

        Record.Connection = Record.Tween.Completed:Connect(function(State)
            if Record.Connection then
                Record.Connection:Disconnect()
            end
            if ActiveTweens[Instance] == Record then
                ActiveTweens[Instance] = nil
            end
            if State == EnumPlaybackState.Completed and OnComplete then
                Library.SafeCall(OnComplete)
            end
        end)

        ActiveTweens[Instance] = Record
        Record.Tween:Play()
        setmetatable(Record, Tween)
        return Record
    end

    function Tween.GetProperty(Item)
        if Item:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
            return { "ImageTransparency", "BackgroundTransparency" }
        elseif Item:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Item:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("UIStroke") then
            return { "Transparency" }
        elseif Item:IsA("UIGradient") then
            return nil
        end
        return nil
    end

    local TransparencyMemory = setmetatable({}, { __mode = "k" })

    function Tween.FadeItem(Item, Property, Visible, Speed)
        local Memory = TransparencyMemory[Item]
        if not Memory then
            Memory = {}
            TransparencyMemory[Item] = Memory
        end
        if Memory[Property] == nil then
            Memory[Property] = Item[Property]
        end
        local Original = Memory[Property]

        if not Visible then

            return Tween.Create(Item, TweenInfo.new(Speed or Library.FadeSpeed, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = 1,
            }, true)
        else

            return Tween.Create(Item, TweenInfo.new(Speed or Library.FadeSpeed, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Original,
            }, true)
        end
    end

    function Tween.FadeTree(Root, Visible, Speed, OnComplete)
        local Descendants = Root:GetDescendants()
        TableInsert(Descendants, Root)
        local LastRecord
        for _, Descendant in ipairs(Descendants) do
            local Properties = Tween.GetProperty(Descendant)
            if Properties then
                for _, Property in ipairs(Properties) do
                    LastRecord = Tween.FadeItem(Descendant, Property, Visible, Speed)
                end
            end
        end
        if LastRecord and OnComplete then
            Library.Connect(LastRecord.Tween.Completed, function()
                Library.SafeCall(OnComplete)
            end)
        elseif OnComplete then
            Library.SafeCall(OnComplete)
        end
        return LastRecord
    end

    Library.TweenModule = Tween

    local Animation = {}

    local function Seconds(Time)
        return Time
    end

    Animation.Presets = {

        Hover = TweenInfo.new(Seconds(0.12), EnumEasingStyle.Quad, EnumEasingDirection.Out),

        Press = TweenInfo.new(Seconds(0.10), EnumEasingStyle.Quad, EnumEasingDirection.In),

        Fade = TweenInfo.new(Seconds(0.18), EnumEasingStyle.Circular, EnumEasingDirection.Out),

        Slide = TweenInfo.new(Seconds(0.30), EnumEasingStyle.Quart, EnumEasingDirection.Out),

        Scale = TweenInfo.new(Seconds(0.18), EnumEasingStyle.Back, EnumEasingDirection.Out),

        Glow = TweenInfo.new(Seconds(0.22), EnumEasingStyle.Quint, EnumEasingDirection.Out),

        Window = TweenInfo.new(Seconds(0.28), EnumEasingStyle.Quint, EnumEasingDirection.Out),
    }

    function Animation.Resolve(Preset)
        if typeof(Preset) == "EnumItem" or typeof(Preset) == "TweenInfo" then
            return Preset
        end
        return Animation.Presets[Preset] or DefaultTweenInfo
    end

    function Animation.Play(Item, Preset, Goal, OnComplete)
        local Info = Animation.Resolve(Preset)
        return Tween.Create(Item, Info, Goal, false, OnComplete)
    end

    function Animation.Stop(Instance)
        if typeof(Instance) == "table" and Instance.Instance then
            Instance = Instance.Instance
        end
        Tween.Cancel(Instance)
    end

    Library.Animation = Animation

    local Instances = {}
    Instances.__index = Instances

    function Instances.Create(Class, Properties)
        local Instance = InstanceNew(Class)
        local Wrapper = {
            Instance = Instance,
            Properties = Properties,
            Class = Class,
        }
        setmetatable(Wrapper, Instances)

        if Properties then
            for Property, Value in pairs(Properties) do
                if Property ~= "Parent" then
                    Instance[Property] = Value
                end
            end

            if Properties.Parent ~= nil then
                if typeof(Properties.Parent) == "table" and Properties.Parent.Instance then
                    Instance.Parent = Properties.Parent.Instance
                else
                    Instance.Parent = Properties.Parent
                end
            end
        end
        return Wrapper
    end

    function Instances.Connect(Wrapper, Event, Callback, Name)
        if not Wrapper.Instance or not Wrapper.Instance[Event] then
            return
        end
        return Library.Connect(Wrapper.Instance[Event], Callback, Name)
    end

    function Instances.Tween(Wrapper, Info, Goal, OnComplete)
        return Tween.Create(Wrapper, Info, Goal, false, OnComplete)
    end

    function Instances.AddToTheme(Wrapper, Properties)
        Library.AddToTheme(Wrapper, Properties)
        return Wrapper
    end

    function Instances.ChangeItemTheme(Wrapper, Properties)
        Library.ChangeItemTheme(Wrapper, Properties)
        return Wrapper
    end

    function Instances.Clean(Wrapper)
        if not Wrapper.Instance then
            return
        end
        Tween.Cancel(Wrapper.Instance)

        local Instance = Wrapper.Instance
        
        -- Helper to remove theme records to prevent memory leaks/errors
        local function RemoveFromTheme(Obj)
            local ThemeData = Library.ThemeMap[Obj]
            if ThemeData then
                for Index, T in ipairs(Library.ThemeItems) do
                    if T == ThemeData then
                        TableRemove(Library.ThemeItems, Index)
                        break
                    end
                end
                Library.ThemeMap[Obj] = nil
            end
            TransparencyMemory[Obj] = nil
        end

        RemoveFromTheme(Instance)
        for _, Descendant in ipairs(Instance:GetDescendants()) do
            RemoveFromTheme(Descendant)
        end

        Instance:Destroy()
        Wrapper.Instance = nil
    end

    function Instances.OnHover(Wrapper, OnEnter, OnLeave)
        if not Wrapper.Instance then
            return
        end
        if OnEnter then
            Library.Connect(Wrapper.Instance.MouseEnter, OnEnter)
        end
        if OnLeave then
            Library.Connect(Wrapper.Instance.MouseLeave, OnLeave)
        end
        return Wrapper
    end

    Library.Instances = Instances

    Library.Holder = Instances:Create("ScreenGui", {
        Name = "Ironite",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 10,
        IgnoreGuiInset = true,
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Name = "IroniteUnused",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        IgnoreGuiInset = true,
    })

    Library.NotifHolder = Instances:Create("ScreenGui", {
        Name = "IroniteNotifications",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 20,
        IgnoreGuiInset = true,
    })

    local DragController = {}
    DragController.__index = DragController

    local ActiveDrag = nil

    local function ClampToBounds(Frame, X, Y, BoundsRect)
        local Parent = Frame.Parent
        local ParentSize
        if BoundsRect then
            ParentSize = BoundsRect
        elseif Parent and Parent:IsA("GuiObject") then
            ParentSize = Parent.AbsoluteSize
        else
            ParentSize = Camera.ViewportSize
        end
        local FrameSize = Frame.AbsoluteSize
        local MinX = 0
        local MinY = 0
        local MaxX = MathMax(0, ParentSize.X - FrameSize.X)
        local MaxY = MathMax(0, ParentSize.Y - FrameSize.Y)
        return MathClamp(X, MinX, MaxX), MathClamp(Y, MinY, MaxY)
    end

    function DragController.New(Frame, Options)
        Options = Options or {}
        local Instance = Frame.Instance or Frame

        local Controller = {
            Frame = Instance,
            Handle = nil,
            Bounds = Options.Bounds or "Parent",
            InertiaEnabled = Options.Inertia ~= false,
            Smoothing = Options.Smoothing or 0.22,
            InertiaDecay = Options.InertiaDecay or 0.86,
            Dragging = false,
            Enabled = true,

            DragStart = Vector2New.zero,
            StartPosition = UDim2New(0, 0, 0, 0),
            LastInput = Vector2New.zero,
            LastTime = 0,
            Velocity = Vector2New.zero,

            CurrentOffset = Vector2New.zero,
            TargetOffset = Vector2New.zero,

            Connections = {},
        }

        local HandleWrapper = Options.Handle or Frame
        Controller.Handle = HandleWrapper.Instance or HandleWrapper

        setmetatable(Controller, DragController)

        Controller:_Wire()
        return Controller
    end

    function DragController:_Wire()
        local Frame = self.Frame
        local Handle = self.Handle

        local BeginConnection = Handle.InputBegan:Connect(function(Input)
            if not self.Enabled then
                return
            end
            if Input.UserInputType == EnumUserInputType.MouseButton1
            or Input.UserInputType == EnumUserInputType.Touch then
                self.Dragging = true
                ActiveDrag = self
                self.DragStart = Input.Position
                self.StartPosition = Frame.Position
                self.LastInput = Input.Position
                self.LastTime = os.clock()
                self.Velocity = Vector2New.zero

                self.CurrentOffset = Vector2New.new(self.StartPosition.X.Offset, self.StartPosition.Y.Offset)
                self.TargetOffset = self.CurrentOffset
            end
        end)
        TableInsert(self.Connections, BeginConnection)

        local EndConnection = Library.Connect(UserInputService.InputEnded, function(Input)
            if not self.Dragging then
                return
            end
            if Input.UserInputType == EnumUserInputType.MouseButton1
            or Input.UserInputType == EnumUserInputType.Touch then
                self.Dragging = false
                if ActiveDrag == self then
                    ActiveDrag = nil
                end
            end
        end, "drag_end_" .. tostring(self))
        TableInsert(self.Connections, EndConnection.Connection)
    end

    function DragController:_UpdateTarget(InputPosition)
        if not self.Dragging then
            return
        end
        local Delta = InputPosition - self.DragStart
        local NewX = self.StartPosition.X.Offset + Delta.X
        local NewY = self.StartPosition.Y.Offset + Delta.Y
        NewX, NewY = ClampToBounds(self.Frame, NewX, NewY, self.Bounds == "Screen" and Camera.ViewportSize or nil)
        self.TargetOffset = Vector2New.new(NewX, NewY)

        local Now = os.clock()
        local Dt = Now - self.LastTime
        if Dt > 0 then
            local InputDelta = InputPosition - self.LastInput
            self.Velocity = InputDelta / Dt
        end
        self.LastInput = InputPosition
        self.LastTime = Now
    end

    function DragController:_Step(Dt)
        local Frame = self.Frame
        if not Frame or not Frame.Parent then
            return
        end

        if self.Dragging then

            local Alpha = 1 - (1 - self.Smoothing) ^ (Dt * 60)
            self.CurrentOffset = self.CurrentOffset:Lerp(self.TargetOffset, Alpha)
        elseif self.InertiaEnabled and (MathAbs(self.Velocity.X) > 1 or MathAbs(self.Velocity.Y) > 1) then

            local Drift = self.Velocity * Dt
            local NewX = self.TargetOffset.X + Drift.X
            local NewY = self.TargetOffset.Y + Drift.Y
            NewX, NewY = ClampToBounds(Frame, NewX, NewY, self.Bounds == "Screen" and Camera.ViewportSize or nil)
            self.TargetOffset = Vector2New.new(NewX, NewY)
            self.CurrentOffset = self.CurrentOffset:Lerp(self.TargetOffset, 1 - (1 - self.Smoothing) ^ (Dt * 60))
            self.Velocity = self.Velocity * (self.InertiaDecay ^ (Dt * 60))
        else
            self.Velocity = Vector2New.zero
            return
        end

        Frame.Position = UDim2New(
            self.StartPosition.X.Scale, self.CurrentOffset.X,
            self.StartPosition.Y.Scale, self.CurrentOffset.Y
        )
    end

    function DragController:SetEnabled(Enabled)
        self.Enabled = Enabled
        if not Enabled then
            self.Dragging = false
            self.Velocity = Vector2New.zero
        end
    end

    function DragController:Destroy()
        for _, Connection in ipairs(self.Connections) do
            pcall(function()
                if Connection.Connected then
                    Connection:Disconnect()
                end
            end)
        end
        self.Connections = {}
        if ActiveDrag == self then
            ActiveDrag = nil
        end
        self.Frame = nil
        self.Handle = nil
    end

    Library.DragController = DragController

    Library.Connect(UserInputService.InputChanged, function(Input)
        if not ActiveDrag then
            return
        end
        if Input.UserInputType == EnumUserInputType.MouseMovement
        or Input.UserInputType == EnumUserInputType.Touch then
            ActiveDrag:_UpdateTarget(Input.Position)
        end
    end, "drag_global_input")

    Library.Connect(RunService.Heartbeat, function(Dt)
        if ActiveDrag then
            ActiveDrag:_Step(Dt)
        end
    end, "drag_global_step")

    local Input = {}

    Input.BeganListeners = {}
    Input.EndedList = {}

    function Input.OnBegan(Callback)
        TableInsert(Input.BeganListeners, Callback)
    end

    local ClickOutside = {}

    local function FrameDestroyed(Frame)
        if not Frame then
            return true
        end
        local Ok, Result = pcall(function()
            return Frame.Parent
        end)
        return (not Ok) or Result == nil
    end

    function Input.RegisterClickOutside(Frame, Callback)
        local Instance = Frame.Instance or Frame
        TableInsert(ClickOutside, { Frame = Instance, Callback = Callback })
    end
    function Input.UnregisterClickOutside(Frame)
        local Instance = Frame.Instance or Frame
        for Index = #ClickOutside, 1, -1 do
            if ClickOutside[Index].Frame == Instance then
                TableRemove(ClickOutside, Index)
            end
        end
    end
    Input.ClickOutside = ClickOutside

    Library.Connect(UserInputService.InputBegan, function(Input2, Processed)
        if Processed then
            return
        end

        if typeof(Library.MenuKeybind) == "EnumItem" and Input2.KeyCode == Library.MenuKeybind then
            for _, Window in pairs(Library.Windows or {}) do
                if Window.ToggleByMenu then
                    Window:ToggleByMenu()
                end
            end
        end

        for _, Callback in ipairs(Input.BeganListeners) do
            Library.SafeCall(Callback, Input2)
        end

        if Input2.UserInputType == EnumUserInputType.MouseButton1
        or Input2.UserInputType == EnumUserInputType.Touch then
            local Point = Input2.Position

            for Index = #ClickOutside, 1, -1 do
                local Entry = ClickOutside[Index]
                local Frame = Entry.Frame
                if FrameDestroyed(Frame) then
                    TableRemove(ClickOutside, Index)
                else
                    local Pos = Frame.AbsolutePosition
                    local Size = Frame.AbsoluteSize
                    local Inside = Point.X >= Pos.X and Point.X <= Pos.X + Size.X
                                and Point.Y >= Pos.Y and Point.Y <= Pos.Y + Size.Y
                    if not Inside then
                        TableRemove(ClickOutside, Index)
                        Library.SafeCall(Entry.Callback)
                    end
                end
            end
        end
    end, "input_global_began")

    Library.Input = Input

    local Mobile = {}

    function Mobile.IsTouch()
        return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    end

    function Mobile.IsTablet()
        if not UserInputService.TouchEnabled then
            return false
        end
        local Viewport = Camera.ViewportSize

        local ShortEdge = MathMin(Viewport.X, Viewport.Y)
        return ShortEdge >= 720
    end

    function Mobile.ComputeScale(Viewport)
        Viewport = Viewport or Camera.ViewportSize
        local DesignWidth = Library.Metrics.Window.Width
        local DesignHeight = Library.Metrics.Window.Height
        local Padding = 32
        local ScaleW = (Viewport.X - Padding) / DesignWidth
        local ScaleH = (Viewport.Y - Padding) / DesignHeight
        local Scale = MathMin(ScaleW, ScaleH)
        if not Mobile.IsTouch() then
            return 1
        end
        return MathClamp(Scale, 0.55, 1.15)
    end

    function Mobile.AttachScale(GuiWrapper)
        local Scale = Instances:Create("UIScale", {
            Parent = GuiWrapper.Instance,
            Scale = Mobile.ComputeScale(),
        })

        local Connection = Library.Connect(Camera:GetPropertyChangedSignal("ViewportSize"), function()
            Scale.Instance.Scale = Mobile.ComputeScale()
        end, "mobile_viewport_" .. tostring(GuiWrapper.Instance))
        return Scale, Connection
    end

    function Mobile.ApplySafeArea(FrameWrapper, Margins)
        Margins = Margins or {}
        local Top = Margins.Top or 0
        local Bottom = Margins.Bottom or 0
        local Left = Margins.Left or 0
        local Right = Margins.Right or 0

        local function Refresh()
            local Insets = GuiService:GetSafeZoneInset()
            local Instance = FrameWrapper.Instance
            Instance.Position = UDim2New(0, Insets.Left + Left, 0, Insets.Top + Top)
            Instance.Size = UDim2New(
                1, -(Insets.Left + Insets.Right + Left + Right),
                1, -(Insets.Top + Insets.Bottom + Top + Bottom)
            )
        end
        Refresh()
        Library.Connect(GuiService:GetPropertyChangedSignal("SafeZoneInset"), Refresh, "safearea_" .. tostring(FrameWrapper.Instance))
    end

    function Mobile.IsPortrait()
        local Viewport = Camera.ViewportSize
        return Viewport.Y > Viewport.X
    end

    function Mobile.UseSingleColumn()
        if not Mobile.IsTouch() then
            return false
        end
        local Viewport = Camera.ViewportSize
        return Viewport.X < 720 or Mobile.IsPortrait()
    end

    Library.Mobile = Mobile

    local NotificationManager = {
        Active = {},
        Queue = {},
        MaxVisible = Library.Metrics.Notification.MaxVisible,
        Width = Library.Metrics.Notification.Width,
        Gap = Library.Metrics.Notification.Gap,
        RightMargin = 16,
        TopMargin = 16,
        Holder = nil,
    }

    NotificationManager.Holder = Instances:Create("Frame", {
        Parent = Library.NotifHolder.Instance,
        Name = "NotificationStack",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2New(1, 0),
        Position = UDim2New(1, -NotificationManager.RightMargin, 0, NotificationManager.TopMargin),
        Size = UDim2FromOffset(NotificationManager.Width, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 50,
    })
    Instances:Create("UIListLayout", {
        Parent = NotificationManager.Holder.Instance,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDimNew(0, NotificationManager.Gap),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    })

    local function ReflowStack(Immediate)
        for Index, Notification in ipairs(NotificationManager.Active) do
            local YOffset = 0
            for I = 1, Index - 1 do
                local Prior = NotificationManager.Active[I]
                if Prior and Prior.Frame.Instance then
                    YOffset = YOffset + Prior.Frame.Instance.AbsoluteSize.Y + NotificationManager.Gap
                end
            end
            local Target = UDim2New(0, 0, 0, YOffset)
            if Immediate then
                Notification.Frame.Instance.Position = Target
            else
                Animation.Play(Notification.Frame, "Slide", { Position = Target })
            end
        end
    end

    local function PumpQueue()
        while #NotificationManager.Active < NotificationManager.MaxVisible and #NotificationManager.Queue > 0 do
            local Next = TableRemove(NotificationManager.Queue, 1)
            TableInsert(NotificationManager.Active, Next)
            Next:Show()
        end
        ReflowStack(false)
    end

    local NotificationProto = {}
    NotificationProto.__index = NotificationProto

    function NotificationProto:TargetYOffset()
        local Index = TableFind(NotificationManager.Active, self) or 1
        local YOffset = 0
        for I = 1, Index - 1 do
            local Prior = NotificationManager.Active[I]
            if Prior and Prior.Frame.Instance then
                YOffset = YOffset + Prior.Frame.Instance.AbsoluteSize.Y + NotificationManager.Gap
            end
        end
        return YOffset
    end

    function NotificationProto:Show()
        local Frame = self.Frame.Instance
        local TargetY = self:TargetYOffset()
        Frame.Position = UDim2New(1, NotificationManager.Width + 8, 0, TargetY)
        Frame.Visible = true
        Tween.FadeTree(Frame, true, Library.FadeSpeed)
        Animation.Play(self.Frame, "Slide", { Position = UDim2New(0, 0, 0, TargetY) })

        if self.Duration > 0 then
            self.TimerThread = Library.Thread(function()
                local Remaining = self.Duration
                while Remaining > 0 and not self.Dismissing do
                    if not self.Paused then
                        Remaining = Remaining - 0.1
                        if self.ProgressFill then
                            local Alpha = 1 - (Remaining / self.Duration)
                            self.ProgressFill.Instance.Size = UDim2New(Alpha, 0, 1, 0)
                        end
                    end
                    TaskWait(0.1)
                end
                if not self.Dismissing then
                    self:Dismiss()
                end
            end)
        end
    end

    function NotificationProto:Dismiss()
        if self.Dismissing then
            return
        end
        self.Dismissing = true
        self.Paused = true

        local Frame = self.Frame.Instance
        Animation.Play(self.Frame, "Slide", {
            Position = UDim2New(1, NotificationManager.Width + 8, Frame.Position.Y.Scale, Frame.Position.Y.Offset),
        })
        Tween.FadeTree(Frame, false, Library.FadeSpeed, function()
            local Index = TableFind(NotificationManager.Active, self)
            if Index then
                TableRemove(NotificationManager.Active, Index)
            end
            for _, Conn in ipairs(self.Connections) do
                pcall(function()
                    if Conn.Connection and Conn.Connection.Connected then
                        Conn.Connection:Disconnect()
                    end
                end)
            end
            self.Frame:Clean()
            ReflowStack(false)
            PumpQueue()
        end)
    end

    function NotificationProto:CollapsibleToggle()
        if self.Collapsing then
            return
        end
        self.Collapsed = not self.Collapsed
        self.Collapsing = true
        if self.Collapsed then
            self.LastSize = self.Description.Instance.Size
            self.Description.Instance.Visible = false
            if self.ProgressHolder then
                self.ProgressHolder.Instance.Visible = false
            end
        else
            self.Description.Instance.Visible = true
            if self.ProgressHolder then
                self.ProgressHolder.Instance.Visible = true
            end
        end
        Animation.Play(self.Frame, "Scale", { Size = UDim2FromOffset(NotificationManager.Width, 0) }, function()
            self.Collapsing = false
        end)
        self.CollapseIcon.Instance.Rotation = self.Collapsed and -90 or 0
    end

    local function MakeIconHover(Button, Icon)
        Library.Connect(Button.Instance.MouseEnter, function()
            Animation.Play(Icon, "Hover", { ImageTransparency = 0.1 })
        end)
        Library.Connect(Button.Instance.MouseLeave, function()
            Animation.Play(Icon, "Hover", { ImageTransparency = 0 })
        end)
    end

    local function MakeAction(Notification, Spec)
        local Metrics = Library.Metrics.Notification
        local Button = Instances:Create("Frame", {
            Parent = Notification.ButtonHolder.Instance,
            Name = "Button",
            BackgroundColor3 = Spec.Color,
            BackgroundTransparency = Spec.Style == "outline" and 1 or 0.95,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 1),
        })
        Instances:Create("UICorner", {
            Parent = Button.Instance,
            CornerRadius = UDimNew(0, Metrics.ButtonCorner),
        })
        local Text = Instances:Create("TextLabel", {
            Parent = Button.Instance,
            Name = "ButtonText",
            BackgroundTransparency = 1,
            FontFace = Library.Fonts.Medium,
            TextColor3 = Spec.Color,
            TextSize = Library.Metrics.FontSize.NotificationBody,
            Text = Spec.Text or "Button",
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 1),
            RichText = true,
        })
        Instances:Create("UIPadding", {
            Parent = Text.Instance,
            PaddingTop = UDimNew(0, Metrics.ButtonPaddingV),
            PaddingBottom = UDimNew(0, Metrics.ButtonPaddingV),
            PaddingLeft = UDimNew(0, Metrics.ButtonPaddingH),
            PaddingRight = UDimNew(0, Metrics.ButtonPaddingH),
        })
        Instances:Create("UIListLayout", {
            Parent = Button.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
        if Spec.Style == "outline" then
            Instances:Create("UIStroke", {
                Parent = Button.Instance,
                Color = Spec.Color,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
        end

        local Hit = Instances:Create("TextButton", {
            Parent = Button.Instance,
            Name = "Hit",
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Size = UDim2New(1, 0, 1, 0),
            ZIndex = Button.Instance.ZIndex + 1,
        })
        Library.Connect(Hit.Instance.MouseEnter, function()
            Animation.Play(Button, "Hover", { BackgroundTransparency = Spec.Style == "outline" and 0.85 or 0.88 })
        end)
        Library.Connect(Hit.Instance.MouseLeave, function()
            Animation.Play(Button, "Hover", { BackgroundTransparency = Spec.Style == "outline" and 1 or 0.95 })
        end)
        Library.Connect(Hit.Instance.InputBegan, function(Input)
            if Input.UserInputType == EnumUserInputType.MouseButton1
            or Input.UserInputType == EnumUserInputType.Touch then
                Animation.Play(Button, "Press", { BackgroundTransparency = Spec.Style == "outline" and 0.7 or 0.8 })
                if Spec.Callback then
                    Library.SafeCall(Spec.Callback)
                end
            end
        end)
        Library.Connect(Hit.Instance.InputEnded, function(Input)
            if Input.UserInputType == EnumUserInputType.MouseButton1
            or Input.UserInputType == EnumUserInputType.Touch then
                Animation.Play(Button, "Hover", { BackgroundTransparency = Spec.Style == "outline" and 0.85 or 0.88 })
            end
        end)

        return Button
    end

    function Library.Alert(Data)
        Data = Data or {}
        local Metrics = Library.Metrics.Notification
        local Color = Data.Color or Library.Theme.Accent

        local Notification = setmetatable({
            Title = Data.Title or "Notification",
            Content = Data.Content or "",
            Duration = Data.Duration == nil and 5 or Data.Duration,
            Icon = Data.Icon,
            Color = Color,
            HasProgress = Data.Progress ~= nil,
            Buttons = Data.Buttons or {},
            Frame = nil,
            Connections = {},
            Paused = false,
            Dismissing = false,
            Collapsing = false,
            Collapsed = false,
            TimerThread = nil,
            ProgressFill = nil,
            ProgressHolder = nil,
            Description = nil,
            ButtonHolder = nil,
            CollapseIcon = nil,
        }, NotificationProto)

        local Items = {}

        Items.Root = Instances:Create("Frame", {
            Parent = NotificationManager.Holder.Instance,
            Name = "Notification",
            BackgroundColor3 = Library.Theme.Section,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2FromOffset(NotificationManager.Width, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 51,
        }):AddToTheme({ BackgroundColor3 = "Section" })
        Instances:Create("UICorner", {
            Parent = Items.Root.Instance,
            CornerRadius = UDimNew(0, Metrics.Corner),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.Root.Instance,
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        Items.Header = Instances:Create("Frame", {
            Parent = Items.Root.Instance,
            Name = "Header",
            BackgroundColor3 = Library.Theme.Section,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2New(1, 0, 0, 30),
        }):AddToTheme({ BackgroundColor3 = "Section" })
        Instances:Create("UICorner", {
            Parent = Items.Header.Instance,
            CornerRadius = UDimNew(0, Metrics.Corner),
        })
        Instances:Create("UIPadding", {
            Parent = Items.Header.Instance,
            PaddingLeft = UDimNew(0, Metrics.HeaderPaddingLeft),
            PaddingRight = UDimNew(0, Metrics.HeaderPaddingRight),
            PaddingTop = UDimNew(0, Metrics.HeaderPaddingTop),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.Header.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDimNew(0, Metrics.HeaderPaddingH),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        Items.Holder = Instances:Create("Frame", {
            Parent = Items.Header.Instance,
            Name = "Holder",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 30),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.Holder.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDimNew(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        if Notification.Icon then
            Items.IconHolder = Instances:Create("Frame", {
                Parent = Items.Holder.Instance,
                Name = "IconHolder",
                BackgroundTransparency = 1,
                Size = UDim2FromOffset(Metrics.IconHolder, Metrics.IconHolder),
            })
            Items.Icon = Instances:Create("ImageLabel", {
                Parent = Items.IconHolder.Instance,
                Name = "ImageLabel",
                BackgroundTransparency = 1,
                Image = Notification.Icon,
                ImageColor3 = Color,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2FromScale(0.5, 0.5),
                Size = UDim2FromOffset(Metrics.Icon, Metrics.Icon),
            })
        end

        Items.TitleHolder = Instances:Create("Frame", {
            Parent = Items.Holder.Instance,
            Name = "TitleHolder",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 30),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.TitleHolder.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
        Items.Title = Instances:Create("TextLabel", {
            Parent = Items.TitleHolder.Instance,
            Name = "Title",
            BackgroundTransparency = 1,
            FontFace = Library.Fonts.Medium,
            TextColor3 = Library.Theme.Text,
            TextSize = Library.Metrics.FontSize.NotificationTitle,
            Text = Notification.Title,
            RichText = true,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 1),
        }):AddToTheme({ TextColor3 = "Text" })

        Items.ControlHolder = Instances:Create("Frame", {
            Parent = Items.Header.Instance,
            Name = "ControlHolder",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 30),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.ControlHolder.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDimNew(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        if Data.Collapsible ~= false then
            Items.CollapseButton = Instances:Create("TextButton", {
                Parent = Items.ControlHolder.Instance,
                Name = "CollapseButton",
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                Size = UDim2FromOffset(Metrics.IconHolder, Metrics.IconHolder),
            })
            Items.CollapseIcon = Instances:Create("ImageLabel", {
                Parent = Items.CollapseButton.Instance,
                Name = "CollapseIcon",
                BackgroundTransparency = 1,
                Image = "rbxassetid://118645616697622",
                ImageColor3 = Library.Theme.Muted,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2FromScale(0.5, 0.5),
                Size = UDim2FromOffset(Metrics.Icon, Metrics.Icon),
            }):AddToTheme({ ImageColor3 = "Muted" })
            Notification.CollapseIcon = Items.CollapseIcon
            MakeIconHover(Items.CollapseButton, Items.CollapseIcon)
            Library.Connect(Items.CollapseButton.Instance.InputBegan, function(Input)
                if Input.UserInputType == EnumUserInputType.MouseButton1
                or Input.UserInputType == EnumUserInputType.Touch then
                    Notification:CollapsibleToggle()
                end
            end)
        end

        Items.CloseButton = Instances:Create("TextButton", {
            Parent = Items.ControlHolder.Instance,
            Name = "CloseButton",
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            Size = UDim2FromOffset(Metrics.IconHolder, Metrics.IconHolder),
        })
        Items.CloseIcon = Instances:Create("ImageLabel", {
            Parent = Items.CloseButton.Instance,
            Name = "CloseIcon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://124971904960139",
            ImageColor3 = Library.Theme.Muted,
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2FromScale(0.5, 0.5),
            Size = UDim2FromOffset(Metrics.CloseIcon, Metrics.CloseIcon),
        }):AddToTheme({ ImageColor3 = "Muted" })
        MakeIconHover(Items.CloseButton, Items.CloseIcon)
        Library.Connect(Items.CloseButton.Instance.InputBegan, function(Input)
            if Input.UserInputType == EnumUserInputType.MouseButton1
            or Input.UserInputType == EnumUserInputType.Touch then
                Notification:Dismiss()
            end
        end)

        Items.Description = Instances:Create("Frame", {
            Parent = Items.Root.Instance,
            Name = "DescriptionHolder",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2New(1, 0, 0, 0),
        })
        Notification.Description = Items.Description
        Instances:Create("UIPadding", {
            Parent = Items.Description.Instance,
            PaddingLeft = UDimNew(0, Metrics.BodyPaddingLeft),
            PaddingBottom = UDimNew(0, Metrics.BodyPaddingBottom),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.Description.Instance,
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDimNew(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        Items.TextHolder = Instances:Create("Frame", {
            Parent = Items.Description.Instance,
            Name = "TextHolder",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2New(1, 0, 0, 0),
        })
        Instances:Create("UIPadding", {
            Parent = Items.TextHolder.Instance,
            PaddingLeft = UDimNew(0, 14),
        })
        Items.Body = Instances:Create("TextLabel", {
            Parent = Items.TextHolder.Instance,
            Name = "Body",
            BackgroundTransparency = 1,
            FontFace = Library.Fonts.Regular,
            TextColor3 = Library.Theme.Muted,
            TextSize = Library.Metrics.FontSize.NotificationBody,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = Notification.Content,
            RichText = true,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2FromOffset(1, 1),
        }):AddToTheme({ TextColor3 = "Muted" })

        if #Notification.Buttons > 0 then
            Items.ButtonHolder = Instances:Create("Frame", {
                Parent = Items.Description.Instance,
                Name = "ButtonHolder",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                Size = UDim2New(1, 0, 0, 0),
            })
            Notification.ButtonHolder = Items.ButtonHolder
            Instances:Create("UIPadding", {
                Parent = Items.ButtonHolder.Instance,
                PaddingLeft = UDimNew(0, 14),
            })
            Instances:Create("UIListLayout", {
                Parent = Items.ButtonHolder.Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            for _, Spec in ipairs(Notification.Buttons) do
                MakeAction(Notification, {
                    Text = Spec.Text or Spec[1],
                    Color = Spec.Color or Spec[2] or Library.Theme.Muted,
                    Style = Spec.Style or "outline",
                    Callback = Spec.Callback or Spec[3],
                })
            end
        end

        if Notification.HasProgress then
            Items.ProgressHolder = Instances:Create("Frame", {
                Parent = Items.Root.Instance,
                Name = "ProgressHolder",
                BackgroundColor3 = Library.Theme.Background,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2New(1, 0, 0, 0),
            }):AddToTheme({ BackgroundColor3 = "Background" })
            Notification.ProgressHolder = Items.ProgressHolder
            Instances:Create("UICorner", {
                Parent = Items.ProgressHolder.Instance,
                CornerRadius = UDimNew(0, Metrics.Corner),
            })
            Instances:Create("UIPadding", {
                Parent = Items.ProgressHolder.Instance,
                PaddingRight = UDimNew(0, Metrics.BodyPaddingLeft),
            })
            Instances:Create("UIListLayout", {
                Parent = Items.ProgressHolder.Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            Items.ProgressInner = Instances:Create("Frame", {
                Parent = Items.ProgressHolder.Instance,
                Name = "Holder",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                Size = UDim2FromOffset(1, 1),
            })
            Instances:Create("UIListLayout", {
                Parent = Items.ProgressInner.Instance,
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            Items.ProgressBar = Instances:Create("Frame", {
                Parent = Items.ProgressInner.Instance,
                Name = "Progressbar",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2New(1, 0, 0, Metrics.ProgressHeight),
            })
            Instances:Create("UIListLayout", {
                Parent = Items.ProgressBar.Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDimNew(0, Metrics.BodyPaddingLeft),
            })
            Items.ProgressFill = Instances:Create("Frame", {
                Parent = Items.ProgressBar.Instance,
                Name = "Frame",
                BackgroundColor3 = Color,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2New(Metrics.ProgressFillScale, 0, 0, Metrics.ProgressHeight),
            })
            Instances:Create("UICorner", {
                Parent = Items.ProgressFill.Instance,
            })
            Notification.ProgressFill = Items.ProgressFill
        end

        Notification.Frame = Items.Root

        TableInsert(Notification.Connections, Library.Connect(Items.Root.Instance.MouseEnter, function()
            Notification.Paused = true
        end))
        TableInsert(Notification.Connections, Library.Connect(Items.Root.Instance.MouseLeave, function()
            Notification.Paused = false
        end))

        if #NotificationManager.Active < NotificationManager.MaxVisible then
            TableInsert(NotificationManager.Active, Notification)
            Notification:Show()
            ReflowStack(false)
        else
            TableInsert(NotificationManager.Queue, Notification)
        end

        return Notification
    end
    Library.NotificationManager = NotificationManager

    local WatermarkProto = {}
    WatermarkProto.__index = WatermarkProto

    function Library.Watermark(Data)
        Data = Data or {}
        local Watermark = setmetatable({
            Name = Data.Name or "Ironite",
            Logo = Data.Logo,
            Enabled = Data.Enabled ~= false,
            ShowFps = Data.FPS ~= false,
            ShowPing = Data.Ping ~= false,
            ShowTime = Data.Time ~= false,
            ShowUser = Data.User ~= false,
            Executor = identifyexecutor and ({ identifyexecutor() })[1] or nil,
            Items = {},
            LastFps = 0,
            FrameAccumulator = 0,
            LastFrameTime = os.clock(),
            LastUpdate = 0,
        }, WatermarkProto)

        local Items = Watermark.Items
        local Metrics = Library.Metrics.Watermark

        Items.Root = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            Name = "Watermark",
            BackgroundColor3 = Library.Theme.Section,
            AnchorPoint = Vector2New(0, 0),
            Position = UDim2New(0, 16, 0, 16),
            Size = UDim2FromOffset(0, Metrics.Height),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 40,
        }):AddToTheme({ BackgroundColor3 = "Section" })
        Instances:Create("UICorner", {
            Parent = Items.Root.Instance,
            CornerRadius = UDimNew(0, Metrics.Corner),
        })
        Instances:Create("UIStroke", {
            Parent = Items.Root.Instance,
            Color = Library.Theme.Stroke,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }):AddToTheme({ Color = "Stroke" })
        Instances:Create("UIPadding", {
            Parent = Items.Root.Instance,
            PaddingLeft = UDimNew(0, Metrics.PaddingH),
            PaddingRight = UDimNew(0, Metrics.PaddingH),
        })
        Instances:Create("UIListLayout", {
            Parent = Items.Root.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDimNew(0, Metrics.Gap),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        local Order = 0
        local function AddSegment(Text, IsIcon)
            Order = Order + 1
            if IsIcon then
                return Instances:Create("ImageLabel", {
                    Parent = Items.Root.Instance,
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Image = Text,
                    Size = UDim2FromOffset(16, 16),
                    LayoutOrder = Order,
                })
            end
            return Instances:Create("TextLabel", {
                Parent = Items.Root.Instance,
                BackgroundTransparency = 1,
                FontFace = Library.Fonts.Medium,
                TextColor3 = Library.Theme.Text,
                TextSize = Library.Metrics.FontSize.Watermark,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = Text,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2FromOffset(0, 16),
                LayoutOrder = Order,
            }):AddToTheme({ TextColor3 = "Text" })
        end

        if Watermark.Logo then
            Items.Logo = AddSegment(Watermark.Logo, true)
        end
        Items.Name = AddSegment(Watermark.Name)
        if Watermark.ShowFps then
            Items.Fps = AddSegment("0 fps")
        end
        if Watermark.ShowPing then
            Items.Ping = AddSegment("0 ms")
        end
        if Watermark.ShowTime then
            Items.Time = AddSegment("--:--:--")
        end
        if Watermark.ShowUser then
            Items.User = AddSegment(LocalPlayer.Name)
        end
        if Watermark.Executor then
            Items.Executor = AddSegment(Watermark.Executor)
        end

        function Watermark:SetText(Text)
            if Items.Name and Items.Name.Instance then
                Items.Name.Instance.Text = tostring(Text)
            end
        end

        function Watermark:SetVisibility(Visible)
            Items.Root.Instance.Visible = Visible
        end

        Items.Root.Instance.Visible = Watermark.Enabled

        Library.Connect(RunService.Heartbeat, function()
            if not Watermark.Enabled then
                return
            end

            local Now = os.clock()
            Watermark.FrameAccumulator = Watermark.FrameAccumulator + 1
            if Now - Watermark.LastFrameTime >= 1 then
                Watermark.LastFps = Watermark.FrameAccumulator
                Watermark.FrameAccumulator = 0
                Watermark.LastFrameTime = Now
            end

            if Now - Watermark.LastUpdate < 0.25 then
                return
            end
            Watermark.LastUpdate = Now

            if Watermark.ShowFps and Items.Fps then
                Items.Fps.Instance.Text = Watermark.LastFps .. " fps"
            end
            if Watermark.ShowPing and Items.Ping then
                local Ping = MathFloor(LocalPlayer:GetNetworkPing() * 1000)
                Items.Ping.Instance.Text = Ping .. " ms"
            end
            if Watermark.ShowTime and Items.Time then
                Items.Time.Instance.Text = FormatClock()
            end
        end, "watermark_heartbeat")

        Library._Watermark = Watermark
        return Watermark
    end

    local KeybindListProto = {}
    KeybindListProto.__index = KeybindListProto

    function Library.KeybindList(Data)
        Data = Data or {}
        local List = setmetatable({
            Enabled = Data.Enabled ~= false,
            Position = Data.Position or "BottomRight",
            Items = {},
            Entries = {},
            Frame = nil,
        }, KeybindListProto)

        local Metrics = Library.Metrics.Watermark
        local Position = List.Position
        local Anchor
        local Pos
        if Position == "BottomRight" then
            Anchor = Vector2New(1, 1)
            Pos = UDim2New(1, -16, 1, -16)
        elseif Position == "BottomLeft" then
            Anchor = Vector2New(0, 1)
            Pos = UDim2New(0, 16, 1, -16)
        elseif Position == "TopRight" then
            Anchor = Vector2New(1, 0)
            Pos = UDim2New(1, -16, 0, 16 + Metrics.Height + 8)
        else
            Anchor = Vector2New(0, 0)
            Pos = UDim2New(0, 16, 0, 16 + Metrics.Height + 8)
        end

        List.Frame = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            Name = "KeybindList",
            BackgroundColor3 = Library.Theme.Section,
            AnchorPoint = Anchor,
            Position = Pos,
            Size = UDim2FromOffset(220, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = List.Enabled,
            ZIndex = 45,
        }):AddToTheme({ BackgroundColor3 = "Section" })
        Instances:Create("UICorner", {
            Parent = List.Frame.Instance,
            CornerRadius = UDimNew(0, Metrics.Corner),
        })
        Instances:Create("UIStroke", {
            Parent = List.Frame.Instance,
            Color = Library.Theme.Stroke,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }):AddToTheme({ Color = "Stroke" })
        Instances:Create("UIPadding", {
            Parent = List.Frame.Instance,
            PaddingTop = UDimNew(0, 8),
            PaddingBottom = UDimNew(0, 8),
            PaddingLeft = UDimNew(0, 10),
            PaddingRight = UDimNew(0, 10),
        })
        Instances:Create("UIListLayout", {
            Parent = List.Frame.Instance,
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDimNew(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        function List:Add(Keybind, DisplayName, DisplayKey)

            for _, Entry in ipairs(self.Entries) do
                if Entry.Keybind == Keybind then
                    return
                end
            end

            local EntryItems = {}
            EntryItems.Keybind = Keybind
            EntryItems.Order = #self.Entries + 1

            EntryItems.Row = Instances:Create("Frame", {
                Parent = self.Frame.Instance,
                Name = "KeybindEntry",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, 18),
                LayoutOrder = EntryItems.Order,
            })
            Instances:Create("UIListLayout", {
                Parent = EntryItems.Row.Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDimNew(0, 8),
            })

            EntryItems.Name = Instances:Create("TextLabel", {
                Parent = EntryItems.Row.Instance,
                BackgroundTransparency = 1,
                FontFace = Library.Fonts.Regular,
                TextColor3 = Library.Theme.Muted,
                TextSize = Library.Metrics.FontSize.NotificationBody,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = DisplayName or "",
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2FromOffset(0, 16),
            }):AddToTheme({ TextColor3 = "Muted" })

            EntryItems.Key = Instances:Create("TextLabel", {
                Parent = EntryItems.Row.Instance,
                BackgroundTransparency = 1,
                FontFace = Library.Fonts.SemiBold,
                TextColor3 = Library.Theme.Text,
                TextSize = Library.Metrics.FontSize.NotificationBody,
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = DisplayKey or "",
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2FromOffset(0, 16),
                LayoutOrder = 2,
            }):AddToTheme({ TextColor3 = "Text" })

            EntryItems.Row.Instance.BackgroundTransparency = 1
            Tween.FadeTree(EntryItems.Row.Instance, true, Library.FadeSpeed)

            local OriginalCallback = Keybind.Callback
            local function UpdateActiveState()
                local Active = Keybind:GetActive and Keybind:GetActive() or false
                if Active then
                    Animation.Play(EntryItems.Name, "Fade", { TextColor3 = Library.Theme.Accent })
                else
                    Animation.Play(EntryItems.Name, "Fade", { TextColor3 = Library.Theme.Muted })
                end
            end
            EntryItems.Update = UpdateActiveState

            local function WrappedCallback(...)
                UpdateActiveState()
                if OriginalCallback then
                    Library.SafeCall(OriginalCallback, ...)
                end
            end
            Keybind.Callback = WrappedCallback

            TableInsert(self.Entries, EntryItems)
            UpdateActiveState()
        end

        function List:Remove(Keybind)
            for Index, Entry in ipairs(self.Entries) do
                if Entry.Keybind == Keybind then
                    Tween.FadeTree(Entry.Row.Instance, false, Library.FadeSpeed, function()
                        Entry.Row:Clean()
                    end)
                    TableRemove(self.Entries, Index)
                    return
                end
            end
        end

        function List:SetVisibility(Visible)
            self.Enabled = Visible
            self.Frame.Instance.Visible = Visible
        end

        Library._KeybindList = List
        return List
    end

    function Library.Unload()

        for _, Entry in pairs(Library.Connections) do
            local Ok = pcall(function()
                if Entry.Connection and Entry.Connection.Connected then
                    Entry.Connection:Disconnect()
                end
            end)
        end
        Library.Connections = {}

        for Instance in pairs(ActiveTweens) do
            pcall(Tween.Cancel, Instance)
        end

        for _, Thread in pairs(Library.Threads) do
            pcall(CoroutineClose, Thread)
        end
        Library.Threads = {}

        for _, Holder in ipairs({ Library.Holder, Library.UnusedHolder, Library.NotifHolder }) do
            if Holder and Holder.Instance then
                pcall(function()
                    Holder:Clean()
                end)
            end
        end

        Library.Flags = {}
        Library.SetFlags = {}
        Library.ThemeItems = {}
        Library.ThemeMap = {}
        getgenv().IroniteLibrary = nil
    end

end

getgenv().IroniteLibrary = Library
return Library
