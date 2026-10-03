--==========================================================
--  ROLEX UI LIBRARY v1.2  |  Dark Card Theme
--  + Resizable window (corner / edge grips)
--  + Built-in "UI Settings" tab
--  + Full mobile / touch support + floating toggle button
--==========================================================
local Library = {}
Library.__index = Library

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

local function Viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

Library.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

Library.Theme = {
    Window    = Color3.fromRGB(18, 18, 23),
    Sidebar   = Color3.fromRGB(24, 24, 30),
    Topbar    = Color3.fromRGB(22, 22, 28),
    Card      = Color3.fromRGB(32, 32, 41),
    CardHover = Color3.fromRGB(42, 42, 54),
    Field     = Color3.fromRGB(44, 44, 56),
    Stroke    = Color3.fromRGB(50, 50, 63),
    Accent    = Color3.fromRGB(99, 102, 241),
    Good      = Color3.fromRGB(46, 204, 113),
    Bad       = Color3.fromRGB(231, 76, 60),
    Text      = Color3.fromRGB(236, 236, 241),
    SubText   = Color3.fromRGB(150, 150, 168),
    Font      = Enum.Font.GothamMedium,
    FontBold  = Enum.Font.GothamBold,
}
local T = Library.Theme

Library.AccentPresets = {
    Indigo = Color3.fromRGB(99, 102, 241),
    Blue   = Color3.fromRGB(56, 139, 253),
    Green  = Color3.fromRGB(46, 204, 113),
    Purple = Color3.fromRGB(168, 85, 247),
    Pink   = Color3.fromRGB(236, 72, 153),
    Orange = Color3.fromRGB(249, 115, 22),
    Red    = Color3.fromRGB(239, 68, 68),
    Cyan   = Color3.fromRGB(34, 211, 238),
}

--========================== Helpers =======================
local AccentObjects = {}

local function New(class, props, children)
    local inst, parent = Instance.new(class), nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    inst.Parent = parent
    return inst
end

local function Acc(obj, prop)
    table.insert(AccentObjects, {obj = obj, prop = prop or "BackgroundColor3"})
    return obj
end

local function Corner(p, r)
    return New("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p})
end

local function Stroke(p, c, th, tr)
    return New("UIStroke", {
        Color = c or T.Stroke, Thickness = th or 1, Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p
    })
end

local function Pad(p, l, r, t, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), Parent = p
    })
end

local function Tween(o, props, t, s)
    local tw = TweenService:Create(
        o,
        TweenInfo.new(t or 0.18, s or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function ScreenParent()
    if gethui then return gethui() end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Protect(gui)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    gui.Parent = ScreenParent()
end

local function IsPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch
end

function Library:SetAccent(color)
    T.Accent = color
    for _, d in ipairs(AccentObjects) do
        if d.obj and d.obj.Parent then
            pcall(function() Tween(d.obj, {[d.prop] = color}, 0.15) end)
        end
    end
end

--======================== Preferences =====================
local PREF_FILE = "RolexUI_Prefs.json"

local function LoadPrefs()
    if not (isfile and readfile) then return {} end
    local ok, data = pcall(function()
        if isfile(PREF_FILE) then return HttpService:JSONDecode(readfile(PREF_FILE)) end
    end)
    return (ok and type(data) == "table") and data or {}
end

local function SavePrefs(tbl)
    if not writefile then return end
    pcall(function() writefile(PREF_FILE, HttpService:JSONEncode(tbl)) end)
end

--========================= Dragging ========================
local function Draggable(frame, handle, opts)
    opts = opts or {}
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(i)
        if not IsPress(i) then return end
        if opts.Locked and opts.Locked() then return end
        if opts.OnStart then opts.OnStart() end
        dragging, dragStart, startPos = true, i.Position, frame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and IsMove(i) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

--========================= Notify =========================
function Library:Notify(cfg)
    cfg = cfg or {}
    local gui = New("ScreenGui", {
        Name = "RolexNotify", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999
    })
    Protect(gui)

    local w = Library.IsMobile and 250 or 290
    local f = New("Frame", {
        Parent = gui, BackgroundColor3 = T.Card, Size = UDim2.fromOffset(w, 70),
        Position = UDim2.new(1, w + 30, 1, -110), BorderSizePixel = 0
    })
    Corner(f, 10); Stroke(f)

    local bar = New("Frame", {
        Parent = f, BackgroundColor3 = cfg.Color or T.Accent, BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, -16), Position = UDim2.new(0, 0, 0, 8)
    })
    if not cfg.Color then Acc(bar) end

    New("TextLabel", {
        Parent = f, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 10), Size = UDim2.new(1, -26, 0, 20),
        Text = cfg.Title or "Notification"
    })
    New("TextLabel", {
        Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(1, -26, 0, 32),
        Text = cfg.Content or ""
    })

    Tween(f, {Position = UDim2.new(1, -(w + 15), 1, -110)}, 0.3, Enum.EasingStyle.Back)
    task.delay(cfg.Duration or 4, function()
        Tween(f, {Position = UDim2.new(1, w + 30, 1, -110)}, 0.3)
        task.wait(0.35)
        gui:Destroy()
    end)
end

--======================= KEY SYSTEM =======================
function Library:KeySystem(cfg)
    cfg = cfg or {}
    local keys     = cfg.Keys or {"rolex-free"}
    local saveFile = cfg.SaveFile or "RolexKey.txt"
    local canSave  = (writefile and readfile and isfile) and cfg.SaveKey ~= false
    local result   = nil

    local function validate(k)
        k = tostring(k):gsub("%s", "")
        if cfg.Validate then
            local ok, res = pcall(cfg.Validate, k)
            return ok and res == true
        end
        for _, v in ipairs(keys) do
            if k == v then return true end
        end
        return false
    end

    if canSave and isfile(saveFile) then
        local ok, saved = pcall(readfile, saveFile)
        if ok and validate(saved) then return true end
    end

    local gui = New("ScreenGui", {
        Name = "RolexKey", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9998
    })
    Protect(gui)

    local shade = New("Frame", {
        Parent = gui, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), BorderSizePixel = 0
    })
    Tween(shade, {BackgroundTransparency = 0.45}, 0.3)

    local vp = Viewport()
    local kw = math.min(380, vp.X - 40)

    local main = New("Frame", {
        Parent = gui, BackgroundColor3 = T.Window, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(kw, 0), ClipsDescendants = true
    })
    Corner(main, 14); Stroke(main)
    Tween(main, {Size = UDim2.fromOffset(kw, 300)}, 0.35, Enum.EasingStyle.Back)

    local top = New("Frame", {
        Parent = main, BackgroundColor3 = T.Topbar, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42)
    })
    Corner(top, 14)
    New("Frame", {
        Parent = top, BackgroundColor3 = T.Topbar, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14)
    })
    Draggable(main, top)

    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -60, 1, 0),
        Text = (cfg.Title or "Rolex.gg") .. "  |  Key System"
    })

    local close = New("TextButton", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 18,
        TextColor3 = T.SubText, Text = "X", AutoButtonColor = false,
        Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -40, 0, 3)
    })
    close.MouseEnter:Connect(function() Tween(close, {TextColor3 = T.Bad}) end)
    close.MouseLeave:Connect(function() Tween(close, {TextColor3 = T.SubText}) end)
    close.MouseButton1Click:Connect(function() result = false end)

    local body = New("Frame", {
        Parent = main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 1, -42)
    })
    Pad(body, 20, 20, 16, 16)

    New("TextLabel", {
        Parent = body, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 18,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 24), Text = cfg.SubTitle or "ยืนยันคีย์เพื่อเข้าใช้งาน"
    })
    New("TextLabel", {
        Parent = body, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 32),
        Text = cfg.Note or "กดปุ่ม Get Key เพื่อคัดลอกลิงก์ แล้วนำคีย์มาวางในช่องด้านล่าง"
    })

    local box = New("Frame", {
        Parent = body, BackgroundColor3 = T.Card, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 70), Size = UDim2.new(1, 0, 0, 40)
    })
    Corner(box, 10)
    local boxStroke = Stroke(box)

    local input = New("TextBox", {
        Parent = box, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
        TextColor3 = T.Text, PlaceholderText = "วางคีย์ของคุณที่นี่...",
        PlaceholderColor3 = Color3.fromRGB(110, 110, 125), Text = "", ClearTextOnFocus = false,
        Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local status = New("TextLabel", {
        Parent = body, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 2, 0, 114), Size = UDim2.new(1, 0, 0, 18), Text = ""
    })

    local btnW = (kw - 40 - 16) / 3
    local function mkBtn(text, idx, color, cb, isAccent)
        local b = New("TextButton", {
            Parent = body, BackgroundColor3 = color, BorderSizePixel = 0,
            Font = T.FontBold, TextSize = 13, TextColor3 = T.Text, Text = text,
            AutoButtonColor = false,
            Position = UDim2.new(0, (btnW + 8) * idx, 0, 140),
            Size = UDim2.fromOffset(btnW, 38)
        })
        Corner(b, 10)
        if isAccent then Acc(b) end
        b.MouseButton1Click:Connect(cb)
        b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.15}) end)
        b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 0}) end)
        return b
    end

    local function shake()
        local p = main.Position
        for i = 1, 8 do
            main.Position = p + UDim2.fromOffset((i % 2 == 0) and -7 or 7, 0)
            task.wait(0.03)
        end
        main.Position = p
    end

    local function check()
        if validate(input.Text) then
            status.Text = "คีย์ถูกต้อง กำลังเข้าสู่สคริปต์..."
            status.TextColor3 = T.Good
            Tween(boxStroke, {Color = T.Good})
            if canSave then pcall(writefile, saveFile, (input.Text:gsub("%s", ""))) end
            task.wait(0.6)
            result = true
        else
            status.Text = "คีย์ไม่ถูกต้องหรือหมดอายุ"
            status.TextColor3 = T.Bad
            Tween(boxStroke, {Color = T.Bad})
            task.spawn(shake)
        end
    end

    mkBtn("Check Key", 0, T.Accent, check, true)
    mkBtn("Get Key", 1, T.Card, function()
        if setclipboard and cfg.GetKeyLink then
            setclipboard(cfg.GetKeyLink)
            Library:Notify({Title = "คัดลอกแล้ว", Content = "ลิงก์รับคีย์ถูกคัดลอกไปยังคลิปบอร์ด"})
        end
    end)
    mkBtn("Discord", 2, T.Card, function()
        if setclipboard and cfg.DiscordLink then
            setclipboard(cfg.DiscordLink)
            Library:Notify({Title = "คัดลอกแล้ว", Content = "ลิงก์ Discord ถูกคัดลอกแล้ว"})
        end
    end)

    input.FocusLost:Connect(function(enter)
        if enter then check() end
    end)

    repeat task.wait() until result ~= nil

    Tween(main, {Size = UDim2.fromOffset(kw, 0)}, 0.25)
    Tween(shade, {BackgroundTransparency = 1}, 0.25)
    task.wait(0.3)
    gui:Destroy()
    return result
end

--====================== CREATE WINDOW =====================
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local prefs = LoadPrefs()
    local win = setmetatable({}, Library)
    win.Tabs, win.Minimized, win.Locked = {}, false, false

    local isMobile = Library.IsMobile
    local vp = Viewport()

    -- ขนาดเริ่มต้น (บีบให้พอดีจอเสมอ)
    local baseW = cfg.Width  or (isMobile and 480 or 580)
    local baseH = cfg.Height or (isMobile and 330 or 410)
    local startW = math.clamp(prefs.W or baseW, 360, math.max(360, vp.X - 30))
    local startH = math.clamp(prefs.H or baseH, 240, math.max(240, vp.Y - 40))

    local MIN = Vector2.new(360, 240)
    local sidebarW = isMobile and 120 or 150

    if prefs.Accent then
        T.Accent = Color3.fromRGB(prefs.Accent[1], prefs.Accent[2], prefs.Accent[3])
    end

    local gui = New("ScreenGui", {
        Name = cfg.Name or "RolexHub", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9000
    })
    Protect(gui)
    win.Gui = gui

    local main = New("Frame", {
        Parent = gui, BackgroundColor3 = T.Window, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(startW, startH), ClipsDescendants = true
    })
    Corner(main, 12); Stroke(main)
    win.Main = main

    local uiScale = New("UIScale", {
        Parent = main,
        Scale = prefs.Scale or (isMobile and 0.9 or 1)
    })
    win.UIScale = uiScale

    -- แปลง AnchorPoint เป็น (0,0) ครั้งแรกที่ลาก/ยืด เพื่อให้ขยายลงขวาอย่างเดียว
    local normalized = false
    local function Normalize()
        if normalized then return end
        normalized = true
        local abs = main.AbsolutePosition
        main.AnchorPoint = Vector2.new(0, 0)
        main.Position = UDim2.fromOffset(abs.X, abs.Y)
    end

    local savedSize = main.Size

    ---------------- Topbar ----------------
    local top = New("Frame", {
        Parent = main, BackgroundColor3 = T.Topbar, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44)
    })
    Corner(top, 12)
    New("Frame", {
        Parent = top, BackgroundColor3 = T.Topbar, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12)
    })
    Draggable(main, top, {
        Locked  = function() return win.Locked end,
        OnStart = Normalize,
    })

    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 15,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 6), Size = UDim2.new(0.55, 0, 0, 20),
        Text = cfg.Title or "All Star Tower Defense"
    })
    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.Font, TextSize = 11,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 24), Size = UDim2.new(0.55, 0, 0, 14),
        Text = cfg.SubTitle or "Rolex.gg"
    })

    local function ctrl(txt, x, cb)
        local b = New("TextButton", {
            Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 16,
            TextColor3 = T.SubText, Text = txt, AutoButtonColor = false,
            Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, x, 0, 6)
        })
        b.MouseEnter:Connect(function() Tween(b, {TextColor3 = T.Text}) end)
        b.MouseLeave:Connect(function() Tween(b, {TextColor3 = T.SubText}) end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local resizer -- forward declare

    ctrl("-", -108, function()
        win.Minimized = not win.Minimized
        if win.Minimized then
            savedSize = main.Size
            Tween(main, {Size = UDim2.fromOffset(main.Size.X.Offset, 44)}, 0.25)
        else
            Tween(main, {Size = savedSize}, 0.25)
        end
        if resizer then resizer.Visible = not win.Minimized end
    end)

    local expanded = false
    ctrl("[]", -72, function()
        Normalize()
        local v = Viewport()
        if expanded then
            expanded = false
            Tween(main, {Size = savedSize}, 0.25)
        else
            expanded = true
            savedSize = main.Size
            main.Position = UDim2.fromOffset(20, 20)
            Tween(main, {Size = UDim2.fromOffset(v.X - 40, v.Y - 40)}, 0.25)
        end
    end)

    ctrl("X", -36, function()
        Tween(main, {Size = UDim2.fromOffset(main.Size.X.Offset, 0)}, 0.22)
        task.wait(0.25)
        gui:Destroy()
        if win.FloatGui then win.FloatGui:Destroy() end
    end)

    ---------------- Sidebar ----------------
    local side = New("Frame", {
        Parent = main, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 44), Size = UDim2.new(0, sidebarW, 1, -44)
    })
    local sideList = New("ScrollingFrame", {
        Parent = side, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    Pad(sideList, 10, 10, 10, 10)
    New("UIListLayout", {
        Parent = sideList, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder
    })

    ---------------- Content ----------------
    local content = New("Frame", {
        Parent = main, BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarW, 0, 44), Size = UDim2.new(1, -sidebarW, 1, -44)
    })

    ---------------- Resize grips ----------------
    local gripSize = isMobile and 26 or 18

    local function MakeGrip(props, dirX, dirY)
        local h = New("Frame", {
            Parent = main, BackgroundTransparency = 1, BorderSizePixel = 0,
            ZIndex = 50
        })
        for k, v in pairs(props) do h[k] = v end

        local active, startPos, startSize
        h.InputBegan:Connect(function(i)
            if not IsPress(i) then return end
            Normalize()
            active, startPos, startSize = true, i.Position, main.Size
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    active = false
                    savedSize = main.Size
                    expanded = false
                    prefs.W, prefs.H = main.Size.X.Offset, main.Size.Y.Offset
                    SavePrefs(prefs)
                end
            end)
        end)

        UserInputService.InputChanged:Connect(function(i)
            if not (active and IsMove(i)) then return end
            local v = Viewport()
            local s = uiScale.Scale
            local d = (i.Position - startPos) / s
            local w = startSize.X.Offset
            local hh = startSize.Y.Offset
            if dirX ~= 0 then
                w = math.clamp(startSize.X.Offset + d.X * dirX, MIN.X, math.floor(v.X / s) - 10)
            end
            if dirY ~= 0 then
                hh = math.clamp(startSize.Y.Offset + d.Y * dirY, MIN.Y, math.floor(v.Y / s) - 10)
            end
            main.Size = UDim2.fromOffset(w, hh)
        end)
        return h
    end

    -- ขอบขวา / ขอบล่าง
    MakeGrip({
        Size = UDim2.new(0, 6, 1, -60),
        Position = UDim2.new(1, -6, 0, 50),
    }, 1, 0)
    MakeGrip({
        Size = UDim2.new(1, -60, 0, 6),
        Position = UDim2.new(0, 10, 1, -6),
    }, 0, 1)

    -- มุมขวาล่าง (มีไอคอนขีด)
    resizer = MakeGrip({
        Size = UDim2.fromOffset(gripSize, gripSize),
        Position = UDim2.new(1, -gripSize, 1, -gripSize),
    }, 1, 1)

    for i = 1, 3 do
        New("Frame", {
            Parent = resizer, BackgroundColor3 = T.SubText, BackgroundTransparency = 0.45,
            BorderSizePixel = 0, Rotation = -45, ZIndex = 51,
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.fromOffset(2, 4 + i * 3),
            Position = UDim2.new(1, -3 - (i - 1) * 4, 1, -3)
        })
    end

    --------------------------------------------------------
    function win:SetVisible(v)
        main.Visible = v
    end

    function win:ToggleUI()
        main.Visible = not main.Visible
    end

    function win:Center()
        local v = Viewport()
        local s = uiScale.Scale
        main.Position = UDim2.fromOffset(
            (v.X - main.Size.X.Offset * s) / 2,
            (v.Y - main.Size.Y.Offset * s) / 2
        )
    end

    function win:ResetWindow()
        Normalize()
        main.Size = UDim2.fromOffset(baseW, baseH)
        savedSize = main.Size
        uiScale.Scale = isMobile and 0.9 or 1
        win:Center()
        prefs.W, prefs.H, prefs.Scale = baseW, baseH, uiScale.Scale
        SavePrefs(prefs)
    end

    function win:SetTransparency(v)
        main.BackgroundTransparency = v
        side.BackgroundTransparency = v
        top.BackgroundTransparency  = v
    end

    --================= ปุ่มลอยสำหรับมือถือ =================
    if cfg.MobileButton ~= false then
        local fgui = New("ScreenGui", {
            Name = "RolexFloat", ResetOnSpawn = false, IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9500
        })
        Protect(fgui)
        win.FloatGui = fgui

        local fbtn = New("TextButton", {
            Parent = fgui, BackgroundColor3 = T.Card, BorderSizePixel = 0,
            AutoButtonColor = false, Font = T.FontBold, TextSize = 18,
            TextColor3 = T.Text, Text = "R",
            Size = UDim2.fromOffset(48, 48),
            Position = UDim2.new(0, 14, 0.42, 0)
        })
        Corner(fbtn, 24)
        Acc(Stroke(fbtn, T.Accent, 2), "Color")
        win.FloatButton = fbtn

        local startP, moved
        fbtn.InputBegan:Connect(function(i)
            if IsPress(i) then startP, moved = i.Position, false end
        end)
        fbtn.InputEnded:Connect(function(i)
            if IsPress(i) and not moved then win:ToggleUI() end
        end)

        local dragging, dStart, sPos
        fbtn.InputBegan:Connect(function(i)
            if not IsPress(i) then return end
            dragging, dStart, sPos = true, i.Position, fbtn.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and IsMove(i) then
                local d = i.Position - dStart
                if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
                fbtn.Position = UDim2.new(
                    sPos.X.Scale, sPos.X.Offset + d.X,
                    sPos.Y.Scale, sPos.Y.Offset + d.Y
                )
            end
        end)

        if prefs.FloatHidden then fbtn.Visible = false end
    end

    --========================= TAB =========================
    function win:Tab(name, icon)
        local tab = {}

        local btn = New("TextButton", {
            Parent = sideList, BackgroundColor3 = T.Card, BackgroundTransparency = 1,
            BorderSizePixel = 0, AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, isMobile and 36 or 34), Text = ""
        })
        Corner(btn, 8)

        local bar = Acc(New("Frame", {
            Parent = btn, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        }))
        Corner(bar, 2)

        local lbl = New("TextLabel", {
            Parent = btn, BackgroundTransparency = 1, Font = T.Font,
            TextSize = isMobile and 12 or 13,
            TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -16, 1, 0),
            Text = (icon and icon .. "  " or "") .. name
        })

        local page = New("ScrollingFrame", {
            Parent = content, BackgroundTransparency = 1, Visible = false,
            BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Stroke, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y
        })
        Pad(page, 14, 14, 14, 14)
        New("UIListLayout", {
            Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
        })

        tab._Btn, tab._Bar, tab._Lbl, tab._Page = btn, bar, lbl, page
        table.insert(win.Tabs, tab)

        local function select()
            for _, t in ipairs(win.Tabs) do
                t._Page.Visible = false
                Tween(t._Btn, {BackgroundTransparency = 1})
                Tween(t._Bar, {Size = UDim2.new(0, 3, 0, 0)})
                Tween(t._Lbl, {TextColor3 = T.SubText})
            end
            page.Visible = true
            Tween(btn, {BackgroundTransparency = 0})
            Tween(bar, {Size = UDim2.new(0, 3, 0, 18)})
            Tween(lbl, {TextColor3 = T.Text})
        end
        btn.MouseButton1Click:Connect(select)
        if #win.Tabs == 1 then select() end
        tab.Select = select

        ---------------- Components ----------------
        local function baseRow(h)
            local f = New("Frame", {
                Parent = page, BackgroundColor3 = T.Card, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, h)
            })
            Corner(f, 10); Stroke(f)
            return f
        end

        function tab:Section(text)
            New("TextLabel", {
                Parent = page, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 12,
                TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 20), Text = string.upper(text)
            })
        end

        function tab:Card(title, lines)
            local f = baseRow(0)
            f.AutomaticSize = Enum.AutomaticSize.Y

            local holder = New("Frame", {
                Parent = f, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            Pad(holder, 14, 14, 12, 12)
            New("UIListLayout", {
                Parent = holder, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder
            })

            New("TextLabel", {
                Parent = holder, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 20), Text = title
            })

            local api, rows = {}, {}
            for _, line in ipairs(lines or {}) do
                rows[#rows + 1] = New("TextLabel", {
                    Parent = holder, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
                    TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 16), Text = line
                })
            end
            function api:Set(i, text)
                if rows[i] then rows[i].Text = text end
            end
            return api
        end

        function tab:Label(text)
            local f = baseRow(36)
            local l = New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 1, 0), Text = text
            })
            return {Set = function(_, v) l.Text = tostring(v) end}
        end

        function tab:Button(text, callback)
            local f = baseRow(40)
            local b = New("TextButton", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 1, 0), Text = text
            })
            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14,
                TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -28, 0, 0), Size = UDim2.new(0, 14, 1, 0), Text = ">"
            })
            b.MouseEnter:Connect(function() Tween(f, {BackgroundColor3 = T.CardHover}) end)
            b.MouseLeave:Connect(function() Tween(f, {BackgroundColor3 = T.Card}) end)
            b.MouseButton1Click:Connect(function()
                Tween(f, {BackgroundColor3 = T.CardHover}, 0.08)
                task.delay(0.12, function() Tween(f, {BackgroundColor3 = T.Card}, 0.12) end)
                task.spawn(callback or function() end)
            end)
            return f
        end

        function tab:Toggle(text, default, callback)
            local state = default or false
            local f = baseRow(42)

            local dot = New("Frame", {
                Parent = f, BackgroundColor3 = T.Good, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(8, 8)
            })
            Corner(dot, 4)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -110, 1, 0), Text = text
            })

            local track = New("Frame", {
                Parent = f, BackgroundColor3 = Color3.fromRGB(60, 60, 75), BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(44, 22)
            })
            Corner(track, 11)

            local knob = New("Frame", {
                Parent = track, BackgroundColor3 = T.Text, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16)
            })
            Corner(knob, 8)

            local btn = New("TextButton", {
                Parent = f, BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1)
            })

            local function render(fire)
                Tween(track, {BackgroundColor3 = state and T.Good or Color3.fromRGB(60, 60, 75)})
                Tween(knob, {Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
                Tween(dot, {BackgroundTransparency = state and 0 or 0.75})
                if fire and callback then task.spawn(callback, state) end
            end

            btn.MouseButton1Click:Connect(function()
                state = not state
                render(true)
            end)
            render(false)

            return {
                Set = function(_, v) state = v and true or false; render(true) end,
                Get = function() return state end,
            }
        end

        function tab:Dropdown(text, options, default, callback)
            options = options or {}
            local open = false
            local current = default or options[1] or ""

            local f = baseRow(44)
            f.ClipsDescendants = true

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.52, 0, 0, 44), Text = text
            })

            local valueBox = New("Frame", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 8), Size = UDim2.fromOffset(120, 28)
            })
            Corner(valueBox, 7)

            local valueLbl = New("TextLabel", {
                Parent = valueBox, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -28, 1, 0),
                Text = tostring(current)
            })
            New("TextLabel", {
                Parent = valueBox, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 11,
                TextColor3 = T.SubText, Position = UDim2.new(1, -18, 0, 0),
                Size = UDim2.fromOffset(14, 28), Text = "v"
            })

            local list = New("Frame", {
                Parent = f, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 46), Size = UDim2.new(1, -20, 0, 0)
            })
            New("UIListLayout", {
                Parent = list, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder
            })

            local build
            build = function()
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local o = New("TextButton", {
                        Parent = list, BackgroundColor3 = T.Field, BorderSizePixel = 0,
                        AutoButtonColor = false, Font = T.Font, TextSize = 12,
                        TextColor3 = (opt == current) and T.Accent or T.SubText,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, 0, 0, 26), Text = "   " .. tostring(opt)
                    })
                    Corner(o, 6)
                    o.MouseButton1Click:Connect(function()
                        current = opt
                        valueLbl.Text = tostring(opt)
                        if callback then task.spawn(callback, opt) end
                        open = false
                        Tween(f, {Size = UDim2.new(1, 0, 0, 44)})
                        build()
                    end)
                end
            end
            build()

            local hit = New("TextButton", {
                Parent = valueBox, BackgroundTransparency = 1, Text = "",
                Size = UDim2.fromScale(1, 1)
            })
            hit.MouseButton1Click:Connect(function()
                open = not open
                local h = 44 + (open and (#options * 29 + 10) or 0)
                Tween(f, {Size = UDim2.new(1, 0, 0, h)}, 0.2)
            end)

            return {
                Set = function(_, v) current = v; valueLbl.Text = tostring(v); build() end,
                Get = function() return current end,
                Refresh = function(_, newOpts) options = newOpts or {}; build() end,
            }
        end

        function tab:Slider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            local value = default or min
            local f = baseRow(54)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(0.6, 0, 0, 18), Text = text
            })
            local vLbl = Acc(New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 12,
                TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -60, 0, 8), Size = UDim2.fromOffset(46, 18),
                Text = tostring(value)
            }), "TextColor3")

            -- พื้นที่กดใหญ่ขึ้น (นิ้วแตะง่ายบนมือถือ)
            local hit = New("TextButton", {
                Parent = f, BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
                Position = UDim2.new(0, 10, 0, 26), Size = UDim2.new(1, -20, 0, 24)
            })

            local track = New("Frame", {
                Parent = f, BackgroundColor3 = Color3.fromRGB(55, 55, 70), BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 35), Size = UDim2.new(1, -28, 0, 6)
            })
            Corner(track, 3)

            local fill = Acc(New("Frame", {
                Parent = track, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
                Size = UDim2.fromScale((value - min) / (max - min), 1)
            }))
            Corner(fill, 3)

            local knob = New("Frame", {
                Parent = track, BackgroundColor3 = T.Text, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                Size = UDim2.fromOffset(12, 12)
            })
            Corner(knob, 6)

            local dragging = false
            local function set(x, fire)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * rel + 0.5)
                fill.Size = UDim2.fromScale(rel, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                vLbl.Text = tostring(value)
                if fire and callback then task.spawn(callback, value) end
            end

            hit.InputBegan:Connect(function(i)
                if IsPress(i) then dragging = true; set(i.Position.X, true) end
            end)
            track.InputBegan:Connect(function(i)
                if IsPress(i) then dragging = true; set(i.Position.X, true) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if IsPress(i) then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and IsMove(i) then set(i.Position.X, true) end
            end)

            return {
                Get = function() return value end,
                Set = function(_, v)
                    local rel = math.clamp((v - min) / (max - min), 0, 1)
                    set(track.AbsolutePosition.X + track.AbsoluteSize.X * rel, false)
                end,
            }
        end

        function tab:Input(text, placeholder, callback)
            local f = baseRow(44)
            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.4, 0, 1, 0), Text = text
            })

            local box = New("Frame", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0.5, 0, 0, 28)
            })
            Corner(box, 7)

            local tb = New("TextBox", {
                Parent = box, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
                TextColor3 = T.Text, PlaceholderText = placeholder or "", Text = "",
                ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -18, 1, 0)
            })
            tb.FocusLost:Connect(function(enter)
                if callback then task.spawn(callback, tb.Text, enter) end
            end)

            return {
                Get = function() return tb.Text end,
                Set = function(_, v) tb.Text = tostring(v) end,
            }
        end

        function tab:Keybind(text, default, callback)
            local key = default or Enum.KeyCode.RightShift
            local binding = false

            local f = baseRow(42)
            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Text = text
            })

            local b = New("TextButton", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0,
                AutoButtonColor = false, Font = T.Font, TextSize = 12, TextColor3 = T.Text,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(100, 26),
                Text = isMobile and "ไม่รองรับ" or key.Name
            })
            Corner(b, 7)

            if not isMobile then
                b.MouseButton1Click:Connect(function()
                    binding = true
                    b.Text = "..."
                end)
                UserInputService.InputBegan:Connect(function(i, gpe)
                    if gpe then return end
                    if binding and i.UserInputType == Enum.UserInputType.Keyboard then
                        key, binding = i.KeyCode, false
                        b.Text = key.Name
                    elseif not binding and i.KeyCode == key then
                        if callback then task.spawn(callback) end
                    end
                end)
            end

            return {Get = function() return key end}
        end

        return tab
    end

    --=================== UI SETTINGS TAB ===================
    function win:SettingsTab(name)
        local t = win:Tab(name or "UI Settings")

        t:Section("หน้าต่าง")

        t:Slider("ขนาด UI (%)", 60, 140, math.floor(uiScale.Scale * 100), function(v)
            uiScale.Scale = v / 100
            prefs.Scale = v / 100
            SavePrefs(prefs)
        end)

        t:Slider("ความโปร่งใสพื้นหลัง (%)", 0, 60, 0, function(v)
            win:SetTransparency(v / 100)
        end)

        local names = {}
        for k in pairs(Library.AccentPresets) do table.insert(names, k) end
        table.sort(names)

        t:Dropdown("สีธีม (Accent)", names, "Indigo", function(v)
            local c = Library.AccentPresets[v]
            Library:SetAccent(c)
            prefs.Accent = {math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)}
            SavePrefs(prefs)
        end)

        t:Toggle("ล็อกตำแหน่งหน้าต่าง", false, function(on)
            win.Locked = on
        end)

        t:Section("ปุ่ม / คีย์ลัด")

        if win.FloatButton then
            t:Toggle("แสดงปุ่มลอย (มือถือ)", not prefs.FloatHidden, function(on)
                win.FloatButton.Visible = on
                prefs.FloatHidden = not on
                SavePrefs(prefs)
            end)
        end

        t:Keybind("ปุ่มเปิด-ปิดเมนู", cfg.ToggleKey or Enum.KeyCode.RightControl, function()
            win:ToggleUI()
        end)

        t:Section("จัดการ")

        t:Button("จัดหน้าต่างกลางจอ", function()
            Normalize()
            win:Center()
        end)

        t:Button("รีเซ็ตขนาดและตำแหน่ง", function()
            win:ResetWindow()
            Library:Notify({Title = "รีเซ็ตแล้ว", Content = "คืนค่าขนาดหน้าต่างเริ่มต้น"})
        end)

        t:Button("ลบคีย์ที่บันทึกไว้", function()
            if delfile and isfile and isfile(cfg.SaveFile or "RolexKey.txt") then
                pcall(delfile, cfg.SaveFile or "RolexKey.txt")
                Library:Notify({Title = "ลบแล้ว", Content = "ครั้งหน้าจะต้องกรอกคีย์ใหม่"})
            else
                Library:Notify({Title = "ไม่พบไฟล์", Content = "ยังไม่มีคีย์ที่บันทึกไว้", Color = T.Bad})
            end
        end)

        t:Label("อุปกรณ์: " .. (isMobile and "มือถือ / แท็บเล็ต (Touch)" or "คอมพิวเตอร์"))

        return t
    end

    -- คีย์ลัดเปิด-ปิดเมนู
    if not isMobile then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if i.KeyCode == (cfg.ToggleKey or Enum.KeyCode.RightControl) then
                win:ToggleUI()
            end
        end)
    end

    function win:Destroy()
        gui:Destroy()
        if win.FloatGui then win.FloatGui:Destroy() end
    end

    return win
end

return Library
