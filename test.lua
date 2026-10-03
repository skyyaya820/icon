--==========================================================
--  ROLEX UI LIBRARY v1.1  |  Dark Card Theme
--  Fixed: Tween(...).Completed:Wait()  (was ":Completed")
--==========================================================
local Library = {}
Library.__index = Library

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

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

--========================== Helpers =======================
local function New(class, props, children)
    local inst, parent = Instance.new(class), nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    inst.Parent = parent
    return inst
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

local function Draggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
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
        Name = "RolexNotify", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Protect(gui)

    local f = New("Frame", {
        Parent = gui, BackgroundColor3 = T.Card, Size = UDim2.new(0, 290, 0, 70),
        Position = UDim2.new(1, 310, 1, -110), BorderSizePixel = 0
    })
    Corner(f, 10); Stroke(f)

    New("Frame", {
        Parent = f, BackgroundColor3 = cfg.Color or T.Accent, BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, -16), Position = UDim2.new(0, 0, 0, 8)
    })

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

    Tween(f, {Position = UDim2.new(1, -305, 1, -110)}, 0.3, Enum.EasingStyle.Back)
    task.delay(cfg.Duration or 4, function()
        Tween(f, {Position = UDim2.new(1, 310, 1, -110)}, 0.3)
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
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Protect(gui)

    local shade = New("Frame", {
        Parent = gui, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), BorderSizePixel = 0
    })
    Tween(shade, {BackgroundTransparency = 0.45}, 0.3)

    local main = New("Frame", {
        Parent = gui, BackgroundColor3 = T.Window, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(380, 0), ClipsDescendants = true
    })
    Corner(main, 14); Stroke(main)
    Tween(main, {Size = UDim2.fromOffset(380, 300)}, 0.35, Enum.EasingStyle.Back)

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
        Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, -38, 0, 4)
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

    local function mkBtn(text, x, w, color, cb)
        local b = New("TextButton", {
            Parent = body, BackgroundColor3 = color, BorderSizePixel = 0,
            Font = T.FontBold, TextSize = 13, TextColor3 = T.Text, Text = text,
            AutoButtonColor = false,
            Position = UDim2.new(0, x, 0, 140), Size = UDim2.new(0, w, 0, 38)
        })
        Corner(b, 10)
        b.MouseButton1Click:Connect(cb)
        b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.15}) end)
        b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 0}) end)
        return b
    end

    -- สั่นหน้าต่างเมื่อคีย์ผิด (แก้จาก :Completed เป็นลูปแบบ manual)
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

    mkBtn("Check Key", 0, 150, T.Accent, check)
    mkBtn("Get Key", 160, 85, T.Card, function()
        if setclipboard and cfg.GetKeyLink then
            setclipboard(cfg.GetKeyLink)
            Library:Notify({Title = "คัดลอกแล้ว", Content = "ลิงก์รับคีย์ถูกคัดลอกไปยังคลิปบอร์ด"})
        end
    end)
    mkBtn("Discord", 253, 87, T.Card, function()
        if setclipboard and cfg.DiscordLink then
            setclipboard(cfg.DiscordLink)
            Library:Notify({Title = "คัดลอกแล้ว", Content = "ลิงก์ Discord ถูกคัดลอกแล้ว"})
        end
    end)

    input.FocusLost:Connect(function(enter)
        if enter then check() end
    end)

    repeat task.wait() until result ~= nil

    Tween(main, {Size = UDim2.fromOffset(380, 0)}, 0.25)
    Tween(shade, {BackgroundTransparency = 1}, 0.25)
    task.wait(0.3)
    gui:Destroy()
    return result
end

--====================== CREATE WINDOW =====================
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local win = setmetatable({}, Library)
    win.Tabs, win.Minimized = {}, false

    local gui = New("ScreenGui", {
        Name = cfg.Name or "RolexHub", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Protect(gui)
    win.Gui = gui

    local fullSize = cfg.Size or UDim2.fromOffset(560, 400)

    local main = New("Frame", {
        Parent = gui, BackgroundColor3 = T.Window, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = fullSize, ClipsDescendants = true
    })
    Corner(main, 12); Stroke(main)
    win.Main = main

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
    Draggable(main, top)

    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 15,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 6), Size = UDim2.new(0.6, 0, 0, 20),
        Text = cfg.Title or "All Star Tower Defense"
    })
    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Font = T.Font, TextSize = 11,
        TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 24), Size = UDim2.new(0.6, 0, 0, 14),
        Text = cfg.SubTitle or "Rolex.gg"
    })

    local function ctrl(txt, x, cb)
        local b = New("TextButton", {
            Parent = top, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 16,
            TextColor3 = T.SubText, Text = txt, AutoButtonColor = false,
            Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, x, 0, 7)
        })
        b.MouseEnter:Connect(function() Tween(b, {TextColor3 = T.Text}) end)
        b.MouseLeave:Connect(function() Tween(b, {TextColor3 = T.SubText}) end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    ctrl("-", -104, function()
        win.Minimized = not win.Minimized
        Tween(main, {
            Size = win.Minimized and UDim2.fromOffset(fullSize.X.Offset, 44) or fullSize
        }, 0.25)
    end)

    local expanded = false
    ctrl("[ ]", -70, function()
        expanded = not expanded
        local big = UDim2.fromOffset(fullSize.X.Offset + 120, fullSize.Y.Offset + 90)
        Tween(main, {Size = expanded and big or fullSize}, 0.25)
    end)

    ctrl("X", -36, function()
        Tween(main, {Size = UDim2.fromOffset(fullSize.X.Offset, 0)}, 0.22)
        task.wait(0.25)
        gui:Destroy()
    end)

    ---------------- Sidebar ----------------
    local side = New("Frame", {
        Parent = main, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 44), Size = UDim2.new(0, 150, 1, -44)
    })
    local sideList = New("ScrollingFrame", {
        Parent = side, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Pad(sideList, 10, 10, 10, 10)
    New("UIListLayout", {
        Parent = sideList, Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    ---------------- Content ----------------
    local content = New("Frame", {
        Parent = main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 44), Size = UDim2.new(1, -150, 1, -44)
    })

    --------------------------------------------------------
    function win:Tab(name, icon)
        local tab = {}

        local btn = New("TextButton", {
            Parent = sideList, BackgroundColor3 = T.Card, BackgroundTransparency = 1,
            BorderSizePixel = 0, AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 34), Text = ""
        })
        Corner(btn, 8)

        local bar = New("Frame", {
            Parent = btn, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        })
        Corner(bar, 2)

        local lbl = New("TextLabel", {
            Parent = btn, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
            TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -16, 1, 0),
            Text = (icon and icon .. "  " or "") .. name
        })

        local page = New("ScrollingFrame", {
            Parent = content, BackgroundTransparency = 1, Visible = false,
            BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Stroke, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        Pad(page, 14, 14, 14, 14)
        New("UIListLayout", {
            Parent = page, Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
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
                Parent = holder, Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
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
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 1, 0), Text = text
            })
            return {Set = function(_, v) l.Text = v end}
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
                task.spawn(callback or function() end)
            end)
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
                Tween(knob, {
                    Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                })
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
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.55, 0, 0, 44), Text = text
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
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -28, 1, 0), Text = current
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
                Parent = list, Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder
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
                Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(0.6, 0, 0, 18), Text = text
            })
            local vLbl = New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.FontBold, TextSize = 12,
                TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -60, 0, 8), Size = UDim2.fromOffset(46, 18),
                Text = tostring(value)
            })

            local track = New("Frame", {
                Parent = f, BackgroundColor3 = Color3.fromRGB(55, 55, 70), BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 6)
            })
            Corner(track, 3)

            local fill = New("Frame", {
                Parent = track, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
                Size = UDim2.fromScale((value - min) / (max - min), 1)
            })
            Corner(fill, 3)

            local dragging = false
            local function set(x)
                local rel = math.clamp(
                    (x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
                )
                value = math.floor(min + (max - min) * rel + 0.5)
                fill.Size = UDim2.fromScale(rel, 1)
                vLbl.Text = tostring(value)
                if callback then task.spawn(callback, value) end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    set(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                    set(i.Position.X)
                end
            end)

            return {Get = function() return value end}
        end

        function tab:Input(text, placeholder, callback)
            local f = baseRow(44)
            New("TextLabel", {
                Parent = f, BackgroundTransparency = 1, Font = T.Font, TextSize = 13,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.42, 0, 1, 0), Text = text
            })

            local box = New("Frame", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(170, 28)
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
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Text = text
            })

            local b = New("TextButton", {
                Parent = f, BackgroundColor3 = T.Field, BorderSizePixel = 0,
                AutoButtonColor = false, Font = T.Font, TextSize = 12, TextColor3 = T.Text,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(100, 26),
                Text = key.Name
            })
            Corner(b, 7)

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

            return {Get = function() return key end}
        end

        return tab
    end

    function win:Destroy()
        gui:Destroy()
    end

    return win
end

return Library
