--==========================================================
--  ROLEX UI LIBRARY  v2.0  "AURORA"
--  Resizable - Mobile ready - Themed - Animated
--==========================================================
local Library = {}
Library.__index = Library

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

Library.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
Library._Scale   = 1

local function Viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

--========================== THEME =========================
Library.Theme = {
    WindowTop  = Color3.fromRGB(26, 26, 34),
    WindowBot  = Color3.fromRGB(15, 15, 20),
    SidebarTop = Color3.fromRGB(23, 23, 30),
    SidebarBot = Color3.fromRGB(17, 17, 23),
    TopbarTop  = Color3.fromRGB(32, 32, 42),
    TopbarBot  = Color3.fromRGB(24, 24, 32),
    Card       = Color3.fromRGB(33, 33, 43),
    CardTop    = Color3.fromRGB(40, 40, 52),
    CardHover  = Color3.fromRGB(47, 47, 61),
    Field      = Color3.fromRGB(46, 46, 60),
    Stroke     = Color3.fromRGB(58, 58, 74),
    Accent     = Color3.fromRGB(120, 110, 255),
    Good       = Color3.fromRGB(52, 211, 153),
    Bad        = Color3.fromRGB(248, 113, 113),
    Text       = Color3.fromRGB(240, 240, 248),
    SubText    = Color3.fromRGB(148, 148, 170),
    Dim        = Color3.fromRGB(104, 104, 126),
    Font       = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
}
local T = Library.Theme

Library.AccentPresets = {
    Aurora   = Color3.fromRGB(120, 110, 255),
    Ocean    = Color3.fromRGB(56, 160, 253),
    Emerald  = Color3.fromRGB(52, 211, 153),
    Sunset   = Color3.fromRGB(251, 146, 60),
    Rose     = Color3.fromRGB(244, 114, 182),
    Crimson  = Color3.fromRGB(248, 113, 113),
    Cyan     = Color3.fromRGB(34, 211, 238),
    Amethyst = Color3.fromRGB(192, 132, 252),
}

--========================= EASING =========================
local EASE = {
    Fast   = TweenInfo.new(0.12, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.5,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

local function Tw(o, props, info)
    local t = TweenService:Create(o, info or EASE.Smooth, props)
    t:Play()
    return t
end

--========================= HELPERS ========================
local function New(class, props, children)
    local inst, parent = Instance.new(class), nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    inst.Parent = parent
    return inst
end

local function Lighten(c, a)
    return c:Lerp(Color3.new(1, 1, 1), a)
end
local function Darken(c, a)
    return c:Lerp(Color3.new(0, 0, 0), a)
end

local function Corner(p, r)
    return New("UICorner", {CornerRadius = UDim.new(0, r or 10), Parent = p})
end
local function Pill(p)
    return New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = p})
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

local function Grad(p, c1, c2, rot, transSeq)
    return New("UIGradient", {
        Parent = p, Rotation = rot or 90,
        Color = ColorSequence.new(c1, c2),
        Transparency = transSeq or NumberSequence.new(0),
    })
end

local function Shadow(parent, spread, transparency, color)
    return New("ImageLabel", {
        Parent = parent, BackgroundTransparency = 1, ZIndex = 0,
        Image = "rbxassetid://6014261993",
        ImageColor3 = color or Color3.new(0, 0, 0),
        ImageTransparency = transparency or 0.45,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Size = UDim2.new(1, spread * 2, 1, spread * 2),
        Position = UDim2.fromOffset(-spread, -spread),
    })
end

-- เส้นไฮไลต์แก้วด้านบน
local function GlassTop(parent)
    local l = New("Frame", {
        Parent = parent, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.88, ZIndex = 5,
        Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0, 0)
    })
    New("UIGradient", {
        Parent = l, Rotation = 0,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
    })
    return l
end

local function Ripple(parent, px, py)
    local s = Library._Scale
    local rel = (Vector2.new(px, py) - parent.AbsolutePosition)
    local maxSide = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) / s * 2.2

    local c = New("Frame", {
        Parent = parent, BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 9,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(rel.X / s, rel.Y / s),
        Size = UDim2.fromOffset(0, 0)
    })
    Pill(c)
    Tw(c, {Size = UDim2.fromOffset(maxSide, maxSide), BackgroundTransparency = 1},
        TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
    task.delay(0.6, function() c:Destroy() end)
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

--===================== ACCENT REGISTRY ====================
local AccentObjs = {}

local function Acc(obj, kind)
    table.insert(AccentObjs, {o = obj, k = kind or "bg"})
    return obj
end

local function AccentSeq(c)
    return ColorSequence.new(Lighten(c, 0.22), Darken(c, 0.18))
end

function Library:SetAccent(c)
    T.Accent = c
    for _, d in ipairs(AccentObjs) do
        local o = d.o
        if o and o.Parent then
            pcall(function()
                if d.k == "bg" then Tw(o, {BackgroundColor3 = c}, EASE.Fast)
                elseif d.k == "text" then Tw(o, {TextColor3 = c}, EASE.Fast)
                elseif d.k == "stroke" then Tw(o, {Color = c}, EASE.Fast)
                elseif d.k == "image" then Tw(o, {ImageColor3 = c}, EASE.Fast)
                elseif d.k == "grad" then o.Color = AccentSeq(c)
                end
            end)
        end
    end
end

--======================= PREFERENCES ======================
local PREF_FILE = "RolexUI_Prefs.json"

local function LoadPrefs()
    if not (isfile and readfile) then return {} end
    local ok, d = pcall(function()
        if isfile(PREF_FILE) then return HttpService:JSONDecode(readfile(PREF_FILE)) end
    end)
    return (ok and type(d) == "table") and d or {}
end

local function SavePrefs(t)
    if not writefile then return end
    pcall(function() writefile(PREF_FILE, HttpService:JSONEncode(t)) end)
end

--========================= DRAGGING =======================
local function Draggable(frame, handle, opts)
    opts = opts or {}
    local dragging, dStart, sPos
    handle.InputBegan:Connect(function(i)
        if not IsPress(i) then return end
        if opts.Locked and opts.Locked() then return end
        if opts.OnStart then opts.OnStart() end
        dragging, dStart, sPos = true, i.Position, frame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and IsMove(i) then
            local d = i.Position - dStart
            frame.Position = UDim2.new(
                sPos.X.Scale, sPos.X.Offset + d.X,
                sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)
end

--======================== NOTIFY ==========================
local NotifyGui, NotifyList = nil, {}

local function EnsureNotifyGui()
    if NotifyGui and NotifyGui.Parent then return NotifyGui end
    NotifyGui = New("ScreenGui", {
        Name = "RolexNotify", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999
    })
    Protect(NotifyGui)
    return NotifyGui
end

local function Restack()
    local y = -20
    for i = #NotifyList, 1, -1 do
        local f = NotifyList[i]
        if f and f.Parent then
            y -= f.Size.Y.Offset + 10
            Tw(f, {Position = UDim2.new(1, -(f.Size.X.Offset + 20), 1, y)}, EASE.Slow)
        end
    end
end

function Library:Notify(cfg)
    cfg = cfg or {}
    local gui = EnsureNotifyGui()
    local w = Library.IsMobile and 250 or 300
    local col = cfg.Color or T.Accent

    local holder = New("Frame", {
        Parent = gui, BackgroundTransparency = 1,
        Size = UDim2.fromOffset(w, 74), Position = UDim2.new(1, w + 40, 1, -110)
    })
    Shadow(holder, 22, 0.55)

    local f = New("Frame", {
        Parent = holder, BackgroundColor3 = T.CardTop, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ZIndex = 2, ClipsDescendants = true
    })
    Corner(f, 12)
    Grad(f, Lighten(T.CardTop, 0.04), T.Card, 90)
    Stroke(f, T.Stroke, 1, 0.3)
    GlassTop(f)

    local bar = New("Frame", {
        Parent = f, BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 3,
        Size = UDim2.new(0, 4, 1, -20), Position = UDim2.new(0, 8, 0, 10)
    })
    Pill(bar)
    if not cfg.Color then Acc(bar) end

    New("TextLabel", {
        Parent = f, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14, ZIndex = 3,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 22, 0, 11), Size = UDim2.new(1, -34, 0, 18),
        Text = cfg.Title or "Notification"
    })
    New("TextLabel", {
        Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 12, ZIndex = 3,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
        Position = UDim2.new(0, 22, 0, 31), Size = UDim2.new(1, -34, 0, 32),
        Text = cfg.Content or ""
    })

    local prog = New("Frame", {
        Parent = f, BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 4,
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2)
    })
    if not cfg.Color then Acc(prog) end

    table.insert(NotifyList, holder)
    Restack()

    local dur = cfg.Duration or 4
    Tw(prog, {Size = UDim2.new(0, 0, 0, 2)}, TweenInfo.new(dur, Enum.EasingStyle.Linear))

    task.delay(dur, function()
        Tw(holder, {Position = UDim2.new(1, w + 40, 1, holder.Position.Y.Offset)}, EASE.Smooth)
        task.wait(0.3)
        for i, v in ipairs(NotifyList) do
            if v == holder then table.remove(NotifyList, i) break end
        end
        holder:Destroy()
        Restack()
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
            local ok, r = pcall(cfg.Validate, k)
            return ok and r == true
        end
        for _, v in ipairs(keys) do if k == v then return true end end
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
        Parent = gui, BackgroundColor3 = Color3.fromRGB(6, 6, 10),
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), BorderSizePixel = 0
    })
    Tw(shade, {BackgroundTransparency = 0.35}, EASE.Slow)

    local blur
    if cfg.Blur ~= false then
        blur = New("BlurEffect", {Parent = Lighting, Size = 0, Name = "RolexKeyBlur"})
        Tw(blur, {Size = 14}, EASE.Slow)
    end

    local vp = Viewport()
    local kw = math.min(400, vp.X - 36)

    local holder = New("Frame", {
        Parent = gui, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46),
        Size = UDim2.fromOffset(kw, 0)
    })
    Shadow(holder, 40, 0.42)

    local main = New("Frame", {
        Parent = holder, BackgroundColor3 = T.WindowTop, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ZIndex = 2, ClipsDescendants = true
    })
    Corner(main, 16)
    Grad(main, T.WindowTop, T.WindowBot, 90)
    Stroke(main, T.Stroke, 1, 0.25)

    Tw(holder, {Size = UDim2.fromOffset(kw, 318), Position = UDim2.fromScale(0.5, 0.5)}, EASE.Spring)

    -- หัวหน้าต่าง
    local top = New("Frame", {
        Parent = main, BackgroundColor3 = T.TopbarTop, BorderSizePixel = 0, ZIndex = 3,
        Size = UDim2.new(1, 0, 0, 46)
    })
    Corner(top, 16)
    Grad(top, T.TopbarTop, T.TopbarBot, 90)
    New("Frame", {
        Parent = top, BackgroundColor3 = T.TopbarBot, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16)
    })
    GlassTop(top)
    Draggable(holder, top)

    local line = Acc(New("Frame", {
        Parent = top, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 4,
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2)
    }))
    local lg = Acc(New("UIGradient", {
        Parent = line, Color = AccentSeq(T.Accent),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        })
    }), "grad")
    TweenService:Create(lg, TweenInfo.new(3.5, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(0.55, 0)}):Play()

    local dot = Acc(New("Frame", {
        Parent = top, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 4,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(8, 8)
    }))
    Pill(dot)
    Acc(Stroke(dot, T.Accent, 4, 0.72), "stroke")

    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14, ZIndex = 4,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -74, 1, 0),
        Text = (cfg.Title or "Rolex.gg") .. "   Key System"
    })

    local close = New("TextButton", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 17, ZIndex = 4,
        TextColor3 = T.Dim, Text = "X", AutoButtonColor = false,
        Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -42, 0, 5)
    })
    close.MouseEnter:Connect(function() Tw(close, {TextColor3 = T.Bad}, EASE.Fast) end)
    close.MouseLeave:Connect(function() Tw(close, {TextColor3 = T.Dim}, EASE.Fast) end)
    close.MouseButton1Click:Connect(function() result = false end)

    local body = New("Frame", {
        Parent = main, BackgroundTransparency = 1, ZIndex = 3,
        Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 1, -46)
    })
    Pad(body, 22, 22, 18, 16)

    New("TextLabel", {
        Parent = body, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 19, ZIndex = 3,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 24), Text = cfg.SubTitle or "ยืนยันคีย์เพื่อเข้าใช้งาน"
    })
    New("TextLabel", {
        Parent = body, BackgroundTransparency = 1, Font = T.Font, TextSize = 12, ZIndex = 3,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
        Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 34),
        Text = cfg.Note or "กดปุ่ม Get Key เพื่อคัดลอกลิงก์ แล้วนำคีย์มาวางในช่องด้านล่าง"
    })

    local box = New("Frame", {
        Parent = body, BackgroundColor3 = T.Field, BorderSizePixel = 0, ZIndex = 3,
        Position = UDim2.new(0, 0, 0, 74), Size = UDim2.new(1, 0, 0, 42)
    })
    Corner(box, 11)
    Grad(box, Lighten(T.Field, 0.05), Darken(T.Field, 0.08), 90)
    local boxStroke = Stroke(box, T.Stroke, 1.4, 0.15)

    local input = New("TextBox", {
        Parent = box, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 4,
        TextColor3 = T.Text, PlaceholderText = "วางคีย์ของคุณที่นี่...",
        PlaceholderColor3 = T.Dim, Text = "", ClearTextOnFocus = false,
        Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 13, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    input.Focused:Connect(function() Tw(boxStroke, {Color = T.Accent, Transparency = 0}, EASE.Fast) end)

    local status = New("TextLabel", {
        Parent = body, BackgroundTransparency = 1, Font = T.Font, TextSize = 12, ZIndex = 3,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 2, 0, 120), Size = UDim2.new(1, 0, 0, 18), Text = ""
    })

    local bw = (kw - 44 - 16) / 3
    local function mkBtn(text, idx, isAccent, cb)
        local b = New("TextButton", {
            Parent = body, BackgroundColor3 = isAccent and T.Accent or T.Card,
            BorderSizePixel = 0, Font = T.FontBold, TextSize = 13, ZIndex = 3,
            TextColor3 = isAccent and Color3.new(1, 1, 1) or T.Text, Text = text,
            AutoButtonColor = false, ClipsDescendants = true,
            Position = UDim2.new(0, (bw + 8) * idx, 0, 146), Size = UDim2.fromOffset(bw, 40)
        })
        Corner(b, 11)
        if isAccent then
            Acc(b)
            Acc(Grad(b, Lighten(T.Accent, 0.22), Darken(T.Accent, 0.18), 90), "grad")
            Acc(Stroke(b, T.Accent, 3, 0.8), "stroke")
        else
            Grad(b, Lighten(T.Card, 0.06), T.Card, 90)
            Stroke(b, T.Stroke, 1, 0.35)
        end
        b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency = 0.12}, EASE.Fast) end)
        b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency = 0}, EASE.Fast) end)
        b.InputBegan:Connect(function(i)
            if IsPress(i) then Ripple(b, i.Position.X, i.Position.Y) end
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local function shake()
        local p = holder.Position
        for i = 1, 8 do
            holder.Position = p + UDim2.fromOffset((i % 2 == 0) and -8 or 8, 0)
            task.wait(0.028)
        end
        holder.Position = p
    end

    local function check()
        if validate(input.Text) then
            status.Text = "คีย์ถูกต้อง กำลังเข้าสู่สคริปต์..."
            status.TextColor3 = T.Good
            Tw(boxStroke, {Color = T.Good, Transparency = 0}, EASE.Fast)
            if canSave then pcall(writefile, saveFile, (input.Text:gsub("%s", ""))) end
            task.wait(0.65)
            result = true
        else
            status.Text = "คีย์ไม่ถูกต้องหรือหมดอายุ"
            status.TextColor3 = T.Bad
            Tw(boxStroke, {Color = T.Bad, Transparency = 0}, EASE.Fast)
            task.spawn(shake)
        end
    end

    mkBtn("Check Key", 0, true, check)
    mkBtn("Get Key", 1, false, function()
        if setclipboard and cfg.GetKeyLink then
            setclipboard(cfg.GetKeyLink)
            Library:Notify({Title = "คัดลอกแล้ว", Content = "ลิงก์รับคีย์ถูกคัดลอกไปยังคลิปบอร์ด"})
        end
    end)
    mkBtn("Discord", 2, false, function()
        if setclipboard and cfg.DiscordLink then
            setclipboard(cfg.DiscordLink)
            Library:Notify({Title = "คัดลอกแล้ว", Content = "ลิงก์ Discord ถูกคัดลอกแล้ว"})
        end
    end)

    input.FocusLost:Connect(function(enter) if enter then check() end end)

    repeat task.wait() until result ~= nil

    Tw(holder, {Size = UDim2.fromOffset(kw, 0)}, EASE.Smooth)
    Tw(shade, {BackgroundTransparency = 1}, EASE.Smooth)
    if blur then Tw(blur, {Size = 0}, EASE.Smooth) end
    task.wait(0.32)
    if blur then blur:Destroy() end
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

    local baseW = cfg.Width  or (isMobile and 500 or 600)
    local baseH = cfg.Height or (isMobile and 340 or 420)
    local startW = math.clamp(prefs.W or baseW, 380, math.max(380, vp.X - 30))
    local startH = math.clamp(prefs.H or baseH, 250, math.max(250, vp.Y - 40))

    local MIN = Vector2.new(380, 250)
    local sidebarW = isMobile and 126 or 156

    if prefs.Accent then
        T.Accent = Color3.fromRGB(prefs.Accent[1], prefs.Accent[2], prefs.Accent[3])
    end

    local gui = New("ScreenGui", {
        Name = cfg.Name or "RolexHub", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9000
    })
    Protect(gui)
    win.Gui = gui

    -- container (ไม่ clip) = ตัวจัดตำแหน่ง/ขนาด + เงา
    local holder = New("Frame", {
        Parent = gui, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(startW, 0)
    })
    win.Holder = holder

    local uiScale = New("UIScale", {Parent = holder, Scale = prefs.Scale or (isMobile and 0.92 or 1)})
    Library._Scale = uiScale.Scale
    win.UIScale = uiScale

    local shadow = Shadow(holder, 36, 0.48)

    local main = New("Frame", {
        Parent = holder, BackgroundColor3 = T.WindowTop, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ZIndex = 2, ClipsDescendants = true
    })
    Corner(main, 14)
    Grad(main, T.WindowTop, T.WindowBot, 90)
    Stroke(main, T.Stroke, 1, 0.25)
    win.Main = main

    Tw(holder, {Size = UDim2.fromOffset(startW, startH)}, EASE.Spring)

    local normalized = false
    local function Normalize()
        if normalized then return end
        normalized = true
        local abs = holder.AbsolutePosition
        holder.AnchorPoint = Vector2.new(0, 0)
        holder.Position = UDim2.fromOffset(abs.X, abs.Y)
    end

    local savedSize = UDim2.fromOffset(startW, startH)

    ---------------- Topbar ----------------
    local top = New("Frame", {
        Parent = main, BackgroundColor3 = T.TopbarTop, BorderSizePixel = 0, ZIndex = 4,
        Size = UDim2.new(1, 0, 0, 48)
    })
    Corner(top, 14)
    Grad(top, T.TopbarTop, T.TopbarBot, 90)
    New("Frame", {
        Parent = top, BackgroundColor3 = T.TopbarBot, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14)
    })
    GlassTop(top)
    Draggable(holder, top, {Locked = function() return win.Locked end, OnStart = Normalize})

    local hline = Acc(New("Frame", {
        Parent = top, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 6,
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2)
    }))
    local hg = Acc(New("UIGradient", {
        Parent = hline, Color = AccentSeq(T.Accent),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.05),
            NumberSequenceKeypoint.new(1, 1),
        })
    }), "grad")
    TweenService:Create(hg, TweenInfo.new(4, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(0.6, 0)}):Play()

    -- โลโก้วงกลมเรืองแสง
    local logo = Acc(New("Frame", {
        Parent = top, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 5,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(28, 28)
    }))
    Corner(logo, 9)
    Acc(Grad(logo, Lighten(T.Accent, 0.3), Darken(T.Accent, 0.2), 45), "grad")
    Acc(Stroke(logo, T.Accent, 4, 0.78), "stroke")
    New("TextLabel", {
        Parent = logo, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14, ZIndex = 6,
        TextColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1),
        Text = (cfg.Logo or "R")
    })

    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 15, ZIndex = 5,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 54, 0, 8), Size = UDim2.new(0.52, 0, 0, 18),
        Text = cfg.Title or "All Star Tower Defense"
    })
    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.Font, TextSize = 11, ZIndex = 5,
        TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 54, 0, 26), Size = UDim2.new(0.52, 0, 0, 14),
        Text = cfg.SubTitle or "Rolex.gg"
    })

    local function ctrl(txt, x, cb)
        local b = New("TextButton", {
            Parent = top, BackgroundColor3 = T.Card, BackgroundTransparency = 1,
            BorderSizePixel = 0, Font = T.FontBold, TextSize = 14, ZIndex = 5,
            TextColor3 = T.Dim, Text = txt, AutoButtonColor = false,
            Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, x, 0, 10)
        })
        Corner(b, 8)
        b.MouseEnter:Connect(function()
            Tw(b, {TextColor3 = T.Text, BackgroundTransparency = 0.5}, EASE.Fast)
        end)
        b.MouseLeave:Connect(function()
            Tw(b, {TextColor3 = T.Dim, BackgroundTransparency = 1}, EASE.Fast)
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local resizer

    ctrl("—", -102, function()
        win.Minimized = not win.Minimized
        if win.Minimized then
            savedSize = holder.Size
            Tw(holder, {Size = UDim2.fromOffset(holder.Size.X.Offset, 48)}, EASE.Smooth)
        else
            Tw(holder, {Size = savedSize}, EASE.Smooth)
        end
        if resizer then resizer.Visible = not win.Minimized end
    end)

    local expanded = false
    ctrl("□", -70, function()
        Normalize()
        local v = Viewport()
        if expanded then
            expanded = false
            Tw(holder, {Size = savedSize}, EASE.Smooth)
        else
            expanded = true
            savedSize = holder.Size
            Tw(holder, {Position = UDim2.fromOffset(20, 20),
                Size = UDim2.fromOffset(v.X - 40, v.Y - 40)}, EASE.Smooth)
        end
    end)

    local closeBtn = ctrl("✕", -38, function()
        Tw(holder, {Size = UDim2.fromOffset(holder.Size.X.Offset, 0)}, EASE.Smooth)
        Tw(shadow, {ImageTransparency = 1}, EASE.Smooth)
        task.wait(0.3)
        gui:Destroy()
        if win.FloatGui then win.FloatGui:Destroy() end
    end)
    closeBtn.MouseEnter:Connect(function()
        Tw(closeBtn, {TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = T.Bad,
            BackgroundTransparency = 0.15}, EASE.Fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tw(closeBtn, {TextColor3 = T.Dim, BackgroundColor3 = T.Card,
            BackgroundTransparency = 1}, EASE.Fast)
    end)

    ---------------- Sidebar ----------------
    local side = New("Frame", {
        Parent = main, BackgroundColor3 = T.SidebarTop, BorderSizePixel = 0, ZIndex = 3,
        Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(0, sidebarW, 1, -48)
    })
    Grad(side, T.SidebarTop, T.SidebarBot, 90)
    New("Frame", {
        Parent = side, BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.55,
        BorderSizePixel = 0, ZIndex = 4,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0)
    })

    local sideList = New("ScrollingFrame", {
        Parent = side, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4,
        Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    Pad(sideList, 10, 10, 12, 12)
    New("UIListLayout", {
        Parent = sideList, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder
    })

    ---------------- Content ----------------
    local content = New("Frame", {
        Parent = main, BackgroundTransparency = 1, ZIndex = 3,
        Position = UDim2.new(0, sidebarW, 0, 48), Size = UDim2.new(1, -sidebarW, 1, -48)
    })

    ---------------- Resize grips ----------------
    local gripSize = isMobile and 28 or 20

    local function MakeGrip(props, dx, dy)
        local h = New("Frame", {Parent = main, BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 50})
        for k, v in pairs(props) do h[k] = v end

        local active, sPos, sSize
        h.InputBegan:Connect(function(i)
            if not IsPress(i) then return end
            Normalize()
            active, sPos, sSize = true, i.Position, holder.Size
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    active = false
                    savedSize = holder.Size
                    expanded = false
                    prefs.W, prefs.H = holder.Size.X.Offset, holder.Size.Y.Offset
                    SavePrefs(prefs)
                end
            end)
        end)

        UserInputService.InputChanged:Connect(function(i)
            if not (active and IsMove(i)) then return end
            local v, s = Viewport(), uiScale.Scale
            local d = (i.Position - sPos) / s
            local w, hh = sSize.X.Offset, sSize.Y.Offset
            if dx ~= 0 then w = math.clamp(sSize.X.Offset + d.X * dx, MIN.X, math.floor(v.X / s) - 10) end
            if dy ~= 0 then hh = math.clamp(sSize.Y.Offset + d.Y * dy, MIN.Y, math.floor(v.Y / s) - 10) end
            holder.Size = UDim2.fromOffset(w, hh)
        end)
        return h
    end

    MakeGrip({Size = UDim2.new(0, 7, 1, -64), Position = UDim2.new(1, -7, 0, 54)}, 1, 0)
    MakeGrip({Size = UDim2.new(1, -64, 0, 7), Position = UDim2.new(0, 12, 1, -7)}, 0, 1)

    resizer = MakeGrip({
        Size = UDim2.fromOffset(gripSize, gripSize),
        Position = UDim2.new(1, -gripSize, 1, -gripSize)
    }, 1, 1)

    for i = 1, 3 do
        local d = New("Frame", {
            Parent = resizer, BackgroundColor3 = T.Dim, BackgroundTransparency = 0.35,
            BorderSizePixel = 0, Rotation = -45, ZIndex = 51,
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.fromOffset(2, 3 + i * 3.5),
            Position = UDim2.new(1, -4 - (i - 1) * 4.5, 1, -4)
        })
        Pill(d)
    end
    resizer.MouseEnter:Connect(function()
        for _, c in ipairs(resizer:GetChildren()) do
            if c:IsA("Frame") then Tw(c, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}, EASE.Fast) end
        end
    end)
    resizer.MouseLeave:Connect(function()
        for _, c in ipairs(resizer:GetChildren()) do
            if c:IsA("Frame") then Tw(c, {BackgroundColor3 = T.Dim, BackgroundTransparency = 0.35}, EASE.Fast) end
        end
    end)

    --==================== Window API ====================
    function win:SetVisible(v)
        if v then
            holder.Visible = true
            holder.Size = UDim2.fromOffset(savedSize.X.Offset, savedSize.Y.Offset)
            Tw(shadow, {ImageTransparency = 0.48}, EASE.Smooth)
        else
            Tw(shadow, {ImageTransparency = 1}, EASE.Fast)
            holder.Visible = false
        end
    end
    function win:ToggleUI() win:SetVisible(not holder.Visible) end

    function win:Center()
        local v, s = Viewport(), uiScale.Scale
        holder.Position = UDim2.fromOffset(
            (v.X - holder.Size.X.Offset * s) / 2,
            (v.Y - holder.Size.Y.Offset * s) / 2)
    end

    function win:ResetWindow()
        Normalize()
        holder.Size = UDim2.fromOffset(baseW, baseH)
        savedSize = holder.Size
        uiScale.Scale = isMobile and 0.92 or 1
        Library._Scale = uiScale.Scale
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

        local fh = New("Frame", {
            Parent = fgui, BackgroundTransparency = 1,
            Size = UDim2.fromOffset(52, 52), Position = UDim2.new(0, 16, 0.42, 0)
        })
        Shadow(fh, 18, 0.5)

        local fbtn = Acc(New("TextButton", {
            Parent = fh, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 2,
            AutoButtonColor = false, Font = T.FontBold, TextSize = 19,
            TextColor3 = Color3.new(1, 1, 1), Text = cfg.Logo or "R",
            Size = UDim2.fromScale(1, 1), ClipsDescendants = true
        }))
        Pill(fbtn)
        Acc(Grad(fbtn, Lighten(T.Accent, 0.28), Darken(T.Accent, 0.2), 60), "grad")
        local ring = Acc(Stroke(fbtn, T.Accent, 2, 0.4), "stroke")
        win.FloatButton = fh

        TweenService:Create(ring, TweenInfo.new(1.6, Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut, -1, true), {Thickness = 5, Transparency = 0.85}):Play()

        local startP, moved, dragging, dStart, sPos
        fbtn.InputBegan:Connect(function(i)
            if not IsPress(i) then return end
            startP, moved = i.Position, false
            dragging, dStart, sPos = true, i.Position, fh.Position
            Tw(fbtn, {Size = UDim2.fromScale(0.88, 0.88)}, EASE.Fast)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end)
        fbtn.InputEnded:Connect(function(i)
            if not IsPress(i) then return end
            Tw(fbtn, {Size = UDim2.fromScale(1, 1)}, EASE.Spring)
            if not moved then win:ToggleUI() end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and IsMove(i) then
                local d = i.Position - dStart
                if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
                fh.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X,
                    sPos.Y.Scale, sPos.Y.Offset + d.Y)
            end
        end)

        if prefs.FloatHidden then fh.Visible = false end
    end

    --========================= TAB =========================
    function win:Tab(name, icon)
        local tab = {}

        local btn = New("TextButton", {
            Parent = sideList, BackgroundColor3 = T.CardHover, BackgroundTransparency = 1,
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 5,
            Size = UDim2.new(1, 0, 0, isMobile and 38 or 36), Text = "",
            ClipsDescendants = true
        })
        Corner(btn, 9)

        local hl = Acc(New("Frame", {
            Parent = btn, BackgroundColor3 = T.Accent, BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 5, Size = UDim2.fromScale(1, 1)
        }))
        Corner(hl, 9)
        New("UIGradient", {
            Parent = hl, Rotation = 0,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.78),
                NumberSequenceKeypoint.new(1, 1),
            })
        })

        local bar = Acc(New("Frame", {
            Parent = btn, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 7,
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)
        }))
        Pill(bar)
        local barGlow = Acc(Stroke(bar, T.Accent, 4, 1), "stroke")

        local textX = 14
        local iconObj
        if icon and tostring(icon):match("^rbxassetid://") then
            iconObj = New("ImageLabel", {
                Parent = btn, BackgroundTransparency = 1, ZIndex = 7,
                Image = icon, ImageColor3 = T.SubText, AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 13, 0.5, 0), Size = UDim2.fromOffset(16, 16)
            })
            textX = 37
        elseif icon then
            textX = 14
            name = icon .. "  " .. name
        end

        local lbl = New("TextLabel", {
            Parent = btn, BackgroundTransparency = 1, Font = T.Font, ZIndex = 7,
            TextSize = isMobile and 12 or 13, TextColor3 = T.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.new(0, textX, 0, 0), Size = UDim2.new(1, -textX - 8, 1, 0),
            Text = name
        })

        local page = New("ScrollingFrame", {
            Parent = content, BackgroundTransparency = 1, Visible = false, ZIndex = 4,
            BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Stroke, ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y
        })
        Pad(page, 16, 16, 16, 18)
        New("UIListLayout", {
            Parent = page, Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder
        })

        tab._Btn, tab._Bar, tab._Lbl, tab._Page = btn, bar, lbl, page
        tab._Hl, tab._Icon, tab._Glow = hl, iconObj, barGlow
        table.insert(win.Tabs, tab)

        local function select()
            for _, t in ipairs(win.Tabs) do
                t._Page.Visible = false
                Tw(t._Btn, {BackgroundTransparency = 1}, EASE.Fast)
                Tw(t._Hl, {BackgroundTransparency = 1}, EASE.Fast)
                Tw(t._Bar, {Size = UDim2.new(0, 3, 0, 0)}, EASE.Fast)
                Tw(t._Glow, {Transparency = 1}, EASE.Fast)
                Tw(t._Lbl, {TextColor3 = T.SubText}, EASE.Fast)
                if t._Icon then Tw(t._Icon, {ImageColor3 = T.SubText}, EASE.Fast) end
            end
            page.Visible = true
            Tw(hl, {BackgroundTransparency = 0}, EASE.Smooth)
            Tw(bar, {Size = UDim2.new(0, 3, 0, 20)}, EASE.Spring)
            Tw(barGlow, {Transparency = 0.6}, EASE.Smooth)
            Tw(lbl, {TextColor3 = T.Text}, EASE.Smooth)
            if iconObj then Tw(iconObj, {ImageColor3 = T.Accent}, EASE.Smooth) end

            -- เนื้อหาเลื่อนเข้าแบบ fade + slide
            for _, c in ipairs(page:GetChildren()) do
                if c:IsA("GuiObject") then
                    local target = c.Position
                    c.Position = target + UDim2.fromOffset(0, 10)
                    Tw(c, {Position = target}, EASE.Slow)
                end
            end
        end

        btn.MouseButton1Click:Connect(select)
        btn.MouseEnter:Connect(function()
            if not page.Visible then Tw(btn, {BackgroundTransparency = 0.82}, EASE.Fast) end
        end)
        btn.MouseLeave:Connect(function()
            if not page.Visible then Tw(btn, {BackgroundTransparency = 1}, EASE.Fast) end
        end)

        if #win.Tabs == 1 then select() end
        tab.Select = select

        ---------------- Components ----------------
        local function baseRow(h, clip)
            local f = New("Frame", {
                Parent = page, BackgroundColor3 = T.CardTop, BorderSizePixel = 0, ZIndex = 5,
                Size = UDim2.new(1, 0, 0, h), ClipsDescendants = clip ~= false
            })
            Corner(f, 11)
            Grad(f, T.CardTop, T.Card, 90)
            local st = Stroke(f, T.Stroke, 1, 0.35)
            f:SetAttribute("Base", true)
            return f, st
        end

        local function hoverGlow(f, st)
            f.MouseEnter:Connect(function()
                Tw(f, {BackgroundColor3 = T.CardHover}, EASE.Fast)
                Tw(st, {Transparency = 0.05, Color = T.Accent}, EASE.Fast)
            end)
            f.MouseLeave:Connect(function()
                Tw(f, {BackgroundColor3 = T.CardTop}, EASE.Fast)
                Tw(st, {Transparency = 0.35, Color = T.Stroke}, EASE.Fast)
            end)
        end

        function tab:Section(text)
            local h = New("Frame", {
                Parent = page, BackgroundTransparency = 1, ZIndex = 5,
                Size = UDim2.new(1, 0, 0, 22)
            })
            local d = Acc(New("Frame", {
                Parent = h, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 6,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(3, 12)
            }))
            Pill(d)
            New("TextLabel", {
                Parent = h, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 11,
                ZIndex = 6, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 1, 0),
                Text = string.upper(text)
            })
            return h
        end

        function tab:Card(title, lines)
            local f = baseRow(0)
            f.AutomaticSize = Enum.AutomaticSize.Y
            f.ClipsDescendants = false
            GlassTop(f)

            local holder2 = New("Frame", {
                Parent = f, BackgroundTransparency = 1, ZIndex = 6,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            Pad(holder2, 15, 15, 13, 13)
            New("UIListLayout", {
                Parent = holder2, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder
            })

            local head = New("Frame", {
                Parent = holder2, BackgroundTransparency = 1, ZIndex = 6,
                Size = UDim2.new(1, 0, 0, 22)
            })
            local d = Acc(New("Frame", {
                Parent = head, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 7,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(7, 7)
            }))
            Pill(d)
            Acc(Stroke(d, T.Accent, 3, 0.75), "stroke")
            New("TextLabel", {
                Parent = head, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14,
                ZIndex = 7, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -16, 1, 0), Text = title
            })

            local api, rows = {}, {}
            for _, line in ipairs(lines or {}) do
                rows[#rows + 1] = New("TextLabel", {
                    Parent = holder2, BackgroundTransparency = 1, Font = T.Font, TextSize = 12,
                    ZIndex = 6, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Size = UDim2.new(1, 0, 0, 17), Text = line
                })
            end
            function api:Set(i, text) if rows[i] then rows[i].Text = text end end
            return api
        end

        function tab:Label(text)
            local f, st = baseRow(38)
            local l = New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -30, 1, 0), Text = text
            })
            return {Set = function(_, v) l.Text = tostring(v) end}
        end

        function tab:Button(text, callback)
            local f, st = baseRow(42)
            hoverGlow(f, st)

            local b = New("TextButton", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -30, 1, 0), Text = text
            })
            local arrow = New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 14,
                ZIndex = 6, TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -28, 0, 0), Size = UDim2.new(0, 14, 1, 0), Text = ">"
            })
            b.MouseEnter:Connect(function()
                Tw(arrow, {TextColor3 = T.Accent, Position = UDim2.new(1, -24, 0, 0)}, EASE.Fast)
            end)
            b.MouseLeave:Connect(function()
                Tw(arrow, {TextColor3 = T.Dim, Position = UDim2.new(1, -28, 0, 0)}, EASE.Fast)
            end)
            b.InputBegan:Connect(function(i)
                if IsPress(i) then Ripple(f, i.Position.X, i.Position.Y) end
            end)
            b.MouseButton1Click:Connect(function() task.spawn(callback or function() end) end)
            return f
        end

        function tab:Toggle(text, default, callback)
            local state = default or false
            local f, st = baseRow(44)
            hoverGlow(f, st)

            local dot = New("Frame", {
                Parent = f, BackgroundColor3 = T.Good, BorderSizePixel = 0, ZIndex = 6,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 15, 0.5, 0), Size = UDim2.fromOffset(7, 7)
            })
            Pill(dot)
            local dotGlow = Stroke(dot, T.Good, 3, 1)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -110, 1, 0), Text = text
            })

            local track = New("Frame", {
                Parent = f, BackgroundColor3 = Color3.fromRGB(62, 62, 80), BorderSizePixel = 0,
                ZIndex = 6, AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(46, 24)
            })
            Pill(track)
            local trackGlow = Stroke(track, T.Good, 3, 1)

            local knob = New("Frame", {
                Parent = track, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
                ZIndex = 7, AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(18, 18)
            })
            Pill(knob)
            Shadow(knob, 8, 0.6)

            local btn = New("TextButton", {
                Parent = f, BackgroundTransparency = 1, Text = "", ZIndex = 8,
                Size = UDim2.fromScale(1, 1), AutoButtonColor = false
            })

            local function render(fire)
                Tw(track, {BackgroundColor3 = state and T.Good or Color3.fromRGB(62, 62, 80)}, EASE.Smooth)
                Tw(trackGlow, {Transparency = state and 0.62 or 1}, EASE.Smooth)
                Tw(knob, {Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, EASE.Spring)
                Tw(dot, {BackgroundTransparency = state and 0 or 0.8}, EASE.Smooth)
                Tw(dotGlow, {Transparency = state and 0.6 or 1}, EASE.Smooth)
                if fire and callback then task.spawn(callback, state) end
            end

            btn.InputBegan:Connect(function(i)
                if IsPress(i) then Ripple(f, i.Position.X, i.Position.Y) end
            end)
            btn.MouseButton1Click:Connect(function() state = not state; render(true) end)
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

            local f, st = baseRow(46)
            hoverGlow(f, st)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.5, 0, 0, 46), Text = text
            })

            local vbox = New("Frame", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0, ZIndex = 6,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 9), Size = UDim2.fromOffset(128, 28)
            })
            Corner(vbox, 8)
            Grad(vbox, Lighten(T.Field, 0.06), Darken(T.Field, 0.06), 90)
            local vst = Stroke(vbox, T.Stroke, 1, 0.3)

            local vlbl = New("TextLabel", {
                Parent = vbox, BackgroundTransparency = 1, Font = T.Font, TextSize = 12, ZIndex = 7,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0),
                Text = tostring(current)
            })
            local arrow = New("TextLabel", {
                Parent = vbox, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 10,
                ZIndex = 7, TextColor3 = T.SubText, Position = UDim2.new(1, -20, 0, 0),
                Size = UDim2.fromOffset(14, 28), Text = "v"
            })

            local list = New("Frame", {
                Parent = f, BackgroundTransparency = 1, ZIndex = 6,
                Position = UDim2.new(0, 12, 0, 48), Size = UDim2.new(1, -24, 0, 0)
            })
            New("UIListLayout", {
                Parent = list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder
            })

            local build
            build = function()
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local sel = (opt == current)
                    local o = New("TextButton", {
                        Parent = list, BackgroundColor3 = sel and T.Accent or T.Field,
                        BackgroundTransparency = sel and 0.82 or 0, BorderSizePixel = 0,
                        AutoButtonColor = false, Font = T.Font, TextSize = 12, ZIndex = 7,
                        TextColor3 = sel and T.Accent or T.SubText,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Size = UDim2.new(1, 0, 0, 28), Text = "    " .. tostring(opt),
                        ClipsDescendants = true
                    })
                    Corner(o, 7)
                    if sel then
                        New("TextLabel", {
                            Parent = o, BackgroundTransparency = 1, Font = T.FontBold,
                            TextSize = 12, ZIndex = 8, TextColor3 = T.Accent,
                            Position = UDim2.new(1, -24, 0, 0), Size = UDim2.fromOffset(16, 28),
                            Text = "•"
                        })
                    end
                    o.MouseEnter:Connect(function()
                        if not sel then Tw(o, {TextColor3 = T.Text}, EASE.Fast) end
                    end)
                    o.MouseLeave:Connect(function()
                        if not sel then Tw(o, {TextColor3 = T.SubText}, EASE.Fast) end
                    end)
                    o.MouseButton1Click:Connect(function()
                        current = opt
                        vlbl.Text = tostring(opt)
                        if callback then task.spawn(callback, opt) end
                        open = false
                        Tw(arrow, {Rotation = 0}, EASE.Smooth)
                        Tw(f, {Size = UDim2.new(1, 0, 0, 46)}, EASE.Smooth)
                        Tw(vst, {Color = T.Stroke, Transparency = 0.3}, EASE.Fast)
                        build()
                    end)
                end
            end
            build()

            local hit = New("TextButton", {
                Parent = vbox, BackgroundTransparency = 1, Text = "", ZIndex = 8,
                Size = UDim2.fromScale(1, 1), AutoButtonColor = false
            })
            hit.MouseButton1Click:Connect(function()
                open = not open
                local h = 46 + (open and (#options * 32 + 10) or 0)
                Tw(arrow, {Rotation = open and 180 or 0}, EASE.Smooth)
                Tw(vst, {Color = open and T.Accent or T.Stroke,
                    Transparency = open and 0 or 0.3}, EASE.Fast)
                Tw(f, {Size = UDim2.new(1, 0, 0, h)}, EASE.Smooth)
            end)

            return {
                Set = function(_, v) current = v; vlbl.Text = tostring(v); build() end,
                Get = function() return current end,
                Refresh = function(_, n) options = n or {}; build() end,
            }
        end

        function tab:Slider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            local value = default or min
            local f, st = baseRow(58)
            hoverGlow(f, st)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 15, 0, 9), Size = UDim2.new(0.62, 0, 0, 18), Text = text
            })

            local vpill = New("Frame", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0, ZIndex = 6,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 8), Size = UDim2.fromOffset(52, 20)
            })
            Pill(vpill)
            local vlbl = Acc(New("TextLabel", {
                Parent = vpill, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 11,
                ZIndex = 7, TextColor3 = T.Accent, Size = UDim2.fromScale(1, 1),
                Text = tostring(value)
            }), "text")

            local hit = New("TextButton", {
                Parent = f, BackgroundTransparency = 1, Text = "", ZIndex = 8,
                AutoButtonColor = false,
                Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 26)
            })

            local track = New("Frame", {
                Parent = f, BackgroundColor3 = Color3.fromRGB(52, 52, 68), BorderSizePixel = 0,
                ZIndex = 6, Position = UDim2.new(0, 15, 0, 39), Size = UDim2.new(1, -30, 0, 6)
            })
            Pill(track)

            local fill = Acc(New("Frame", {
                Parent = track, BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 7,
                Size = UDim2.fromScale((value - min) / (max - min), 1)
            }))
            Pill(fill)
            Acc(Grad(fill, Lighten(T.Accent, 0.3), T.Accent, 0), "grad")

            local knob = New("Frame", {
                Parent = track, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
                ZIndex = 9, AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                Size = UDim2.fromOffset(14, 14)
            })
            Pill(knob)
            local kGlow = Acc(Stroke(knob, T.Accent, 3, 0.55), "stroke")

            local dragging = false
            local function set(x, fire)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * rel + 0.5)
                fill.Size = UDim2.fromScale(rel, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                vlbl.Text = tostring(value)
                if fire and callback then task.spawn(callback, value) end
            end

            local function grab(i)
                dragging = true
                Tw(knob, {Size = UDim2.fromOffset(18, 18)}, EASE.Fast)
                Tw(kGlow, {Transparency = 0.25, Thickness = 5}, EASE.Fast)
                set(i.Position.X, true)
            end

            hit.InputBegan:Connect(function(i) if IsPress(i) then grab(i) end end)
            track.InputBegan:Connect(function(i) if IsPress(i) then grab(i) end end)
            UserInputService.InputEnded:Connect(function(i)
                if IsPress(i) and dragging then
                    dragging = false
                    Tw(knob, {Size = UDim2.fromOffset(14, 14)}, EASE.Spring)
                    Tw(kGlow, {Transparency = 0.55, Thickness = 3}, EASE.Fast)
                end
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
            local f, st = baseRow(46)
            hoverGlow(f, st)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.38, 0, 1, 0), Text = text
            })

            local box = New("Frame", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0, ZIndex = 6,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0.5, 0, 0, 30)
            })
            Corner(box, 8)
            Grad(box, Lighten(T.Field, 0.06), Darken(T.Field, 0.06), 90)
            local bst = Stroke(box, T.Stroke, 1, 0.3)

            local tb = New("TextBox", {
                Parent = box, BackgroundTransparency = 1, Font = T.Font, TextSize = 12, ZIndex = 7,
                TextColor3 = T.Text, PlaceholderText = placeholder or "",
                PlaceholderColor3 = T.Dim, Text = "", ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(1, -20, 1, 0)
            })
            tb.Focused:Connect(function()
                Tw(bst, {Color = T.Accent, Transparency = 0}, EASE.Fast)
            end)
            tb.FocusLost:Connect(function(enter)
                Tw(bst, {Color = T.Stroke, Transparency = 0.3}, EASE.Fast)
                if callback then task.spawn(callback, tb.Text, enter) end
            end)

            return {
                Get = function() return tb.Text end,
                Set = function(_, v) tb.Text = tostring(v) end,
            }
        end

        function tab:Keybind(text, default, callback)
            local key, binding = default or Enum.KeyCode.RightShift, false
            local f, st = baseRow(44)
            hoverGlow(f, st)

            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13, ZIndex = 6,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.58, 0, 1, 0), Text = text
            })

            local b = New("TextButton", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0, ZIndex = 6,
                AutoButtonColor = false, Font = T.FontBold, TextSize = 11, TextColor3 = T.SubText,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(104, 28),
                Text = isMobile and "ไม่รองรับ" or key.Name
            })
            Corner(b, 8)
            Grad(b, Lighten(T.Field, 0.06), Darken(T.Field, 0.06), 90)
            local bst = Stroke(b, T.Stroke, 1, 0.3)

            if not isMobile then
                b.MouseButton1Click:Connect(function()
                    binding = true
                    b.Text = "กดปุ่ม..."
                    Tw(b, {TextColor3 = T.Accent}, EASE.Fast)
                    Tw(bst, {Color = T.Accent, Transparency = 0}, EASE.Fast)
                end)
                UserInputService.InputBegan:Connect(function(i, gpe)
                    if gpe then return end
                    if binding and i.UserInputType == Enum.UserInputType.Keyboard then
                        key, binding = i.KeyCode, false
                        b.Text = key.Name
                        Tw(b, {TextColor3 = T.SubText}, EASE.Fast)
                        Tw(bst, {Color = T.Stroke, Transparency = 0.3}, EASE.Fast)
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
    function win:SettingsTab(name, icon)
        local t = win:Tab(name or "UI Settings", icon)
        local blurFx

        t:Section("หน้าต่าง")

        t:Slider("ขนาด UI (%)", 65, 140, math.floor(uiScale.Scale * 100), function(v)
            uiScale.Scale = v / 100
            Library._Scale = v / 100
            prefs.Scale = v / 100
            SavePrefs(prefs)
        end)

        t:Slider("ความโปร่งใสพื้นหลัง (%)", 0, 60, 0, function(v)
            win:SetTransparency(v / 100)
        end)

        t:Slider("ความเข้มเงา (%)", 0, 100, 52, function(v)
            shadow.ImageTransparency = 1 - (v / 100)
        end)

        local names = {}
        for k in pairs(Library.AccentPresets) do table.insert(names, k) end
        table.sort(names)

        local curName = "Aurora"
        for k, v in pairs(Library.AccentPresets) do
            if v == T.Accent then curName = k end
        end

        t:Dropdown("สีธีม", names, curName, function(v)
            local c = Library.AccentPresets[v]
            Library:SetAccent(c)
            prefs.Accent = {math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)}
            SavePrefs(prefs)
        end)

        t:Toggle("เบลอฉากหลังของเกม", false, function(on)
            if on then
                if not blurFx then
                    blurFx = New("BlurEffect", {Parent = Lighting, Size = 0, Name = "RolexUIBlur"})
                end
                Tw(blurFx, {Size = 12}, EASE.Slow)
            elseif blurFx then
                Tw(blurFx, {Size = 0}, EASE.Slow)
            end
        end)

        t:Toggle("ล็อกตำแหน่งหน้าต่าง", false, function(on) win.Locked = on end)

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
            Library:Notify({Title = "รีเซ็ตแล้ว", Content = "คืนค่าขนาดหน้าต่างเริ่มต้นเรียบร้อย"})
        end)

        t:Button("ลบคีย์ที่บันทึกไว้", function()
            local file = cfg.SaveFile or "RolexKey.txt"
            if delfile and isfile and isfile(file) then
                pcall(delfile, file)
                Library:Notify({Title = "ลบแล้ว", Content = "ครั้งหน้าจะต้องกรอกคีย์ใหม่"})
            else
                Library:Notify({Title = "ไม่พบไฟล์",
                    Content = "ยังไม่มีคีย์ที่บันทึกไว้", Color = T.Bad})
            end
        end)

        t:Label("อุปกรณ์: " .. (isMobile and "มือถือ / แท็บเล็ต (Touch)" or "คอมพิวเตอร์"))

        return t
    end

    if not isMobile then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if i.KeyCode == (cfg.ToggleKey or Enum.KeyCode.RightControl) then win:ToggleUI() end
        end)
    end

    function win:Destroy()
        gui:Destroy()
        if win.FloatGui then win.FloatGui:Destroy() end
    end

    return win
end

return Library
