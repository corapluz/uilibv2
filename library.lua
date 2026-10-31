--========================================================================--
--  NEXO UI v3
--
--  - Sidebar'li kompakt pencere (varsayilan 640x420)
--  - Tek font ailesi, duz renkler, 1px border, sade hover (bounce/pop yok)
--  - Yan yana iki kolon, kartlar otomatik boyutlanir (tween yarisi yok)
--  - Tema: preset + canli accent + ozel renkler + import/export
--  - Config: Flag destekli save/load/import/export
--========================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local Nexo = {}
Nexo.__index = Nexo
Nexo.Version = "3.0.0"

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Category = {}
Category.__index = Category

--========================================================================--
-- THEME
--========================================================================--

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local THEME_KEYS = {
    "Accent", "Background", "Sidebar", "Surface", "SurfaceHover", "Elevated",
    "Border", "BorderHover", "Text", "TextDim", "TextMuted", "Danger",
}

-- Katman merdiveni: Background (icerik) < Sidebar (cerceve) < Surface (kart) < SurfaceHover
-- Elevated = kartlarin icine oyulmus input alanlari
local Presets = {
    Default = {
        Accent = rgb(45, 176, 158),
        Background = rgb(15, 17, 19),
        Sidebar = rgb(20, 22, 25),
        Surface = rgb(25, 28, 32),
        SurfaceHover = rgb(33, 37, 42),
        Elevated = rgb(18, 20, 23),
        Border = rgb(41, 46, 52),
        BorderHover = rgb(64, 71, 80),
        Text = rgb(229, 232, 236),
        TextDim = rgb(148, 155, 164),
        TextMuted = rgb(98, 105, 114),
        Danger = rgb(224, 90, 90),
    },
    Dark = {
        Accent = rgb(99, 120, 214),
        Background = rgb(21, 21, 24),
        Sidebar = rgb(26, 26, 30),
        Surface = rgb(32, 32, 37),
        SurfaceHover = rgb(41, 41, 47),
        Elevated = rgb(24, 24, 28),
        Border = rgb(50, 50, 57),
        BorderHover = rgb(74, 74, 84),
        Text = rgb(232, 232, 238),
        TextDim = rgb(156, 156, 168),
        TextMuted = rgb(104, 104, 116),
        Danger = rgb(224, 90, 90),
    },
    Light = {
        Accent = rgb(30, 140, 125),
        Background = rgb(244, 245, 247),
        Sidebar = rgb(234, 236, 240),
        Surface = rgb(255, 255, 255),
        SurfaceHover = rgb(240, 242, 245),
        Elevated = rgb(241, 243, 246),
        Border = rgb(216, 220, 227),
        BorderHover = rgb(188, 194, 204),
        Text = rgb(24, 28, 33),
        TextDim = rgb(92, 99, 110),
        TextMuted = rgb(140, 147, 157),
        Danger = rgb(205, 62, 62),
    },
    Midnight = {
        Accent = rgb(124, 108, 255),
        Background = rgb(12, 14, 25),
        Sidebar = rgb(17, 19, 32),
        Surface = rgb(23, 26, 43),
        SurfaceHover = rgb(32, 36, 58),
        Elevated = rgb(15, 17, 29),
        Border = rgb(40, 44, 70),
        BorderHover = rgb(62, 67, 102),
        Text = rgb(230, 230, 250),
        TextDim = rgb(150, 153, 190),
        TextMuted = rgb(98, 102, 138),
        Danger = rgb(224, 90, 90),
    },
    Amoled = {
        Accent = rgb(0, 208, 142),
        Background = rgb(0, 0, 0),
        Sidebar = rgb(8, 8, 8),
        Surface = rgb(16, 16, 16),
        SurfaceHover = rgb(26, 26, 26),
        Elevated = rgb(9, 9, 9),
        Border = rgb(36, 36, 36),
        BorderHover = rgb(62, 62, 62),
        Text = rgb(240, 240, 240),
        TextDim = rgb(150, 150, 150),
        TextMuted = rgb(96, 96, 96),
        Danger = rgb(224, 90, 90),
    },
    Ocean = {
        Accent = rgb(66, 153, 225),
        Background = rgb(10, 16, 24),
        Sidebar = rgb(14, 22, 32),
        Surface = rgb(20, 30, 43),
        SurfaceHover = rgb(28, 41, 58),
        Elevated = rgb(13, 20, 29),
        Border = rgb(36, 52, 72),
        BorderHover = rgb(56, 80, 108),
        Text = rgb(224, 236, 247),
        TextDim = rgb(138, 158, 180),
        TextMuted = rgb(92, 110, 130),
        Danger = rgb(224, 90, 90),
    },
}

local PRESET_ORDER = { "Default", "Dark", "Light", "Midnight", "Amoled", "Ocean" }

-- eski tema anahtarlari (v2) -> yeni anahtarlar
local LegacyKeys = {
    WindowBackground = "Sidebar",
    TabBackground = "Background",
    CategoryBackground = "Surface",
    PrimaryText = "Text",
    SecondaryText = "TextDim",
    TitleText = "Text",
    ToggleActive = "Accent",
}

local function AccentTextFor(color)
    local lum = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
    if lum > 0.5 then
        return rgb(10, 13, 15)
    end
    return rgb(255, 255, 255)
end

--========================================================================--
-- CONSTANTS
--========================================================================--

local F = {
    Regular = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Semi = Enum.Font.GothamSemibold,
    Mono = Enum.Font.RobotoMono,
}

local T_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_MED = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_SLOW = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local KeyNames = {
    [Enum.KeyCode.LeftControl] = "LCtrl",
    [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftShift] = "LShift",
    [Enum.KeyCode.RightShift] = "RShift",
    [Enum.KeyCode.LeftAlt] = "LAlt",
    [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.KeyCode.Space] = "Space",
    [Enum.KeyCode.Return] = "Enter",
    [Enum.KeyCode.Backspace] = "Bksp",
}

local CONFIG_FOLDER = "NexoUI"

--========================================================================--
-- HELPERS
--========================================================================--

local function setProp(instance, key, value)
    instance[key] = value
end

-- Property uygulayip en son Parent'i atar. Desteklenmeyen property sessizce uyarir.
local function Create(className, props)
    local instance = Instance.new(className)
    local parent = nil

    if props then
        for key, value in pairs(props) do
            if key == "Parent" then
                parent = value
            else
                local ok, err = pcall(setProp, instance, key, value)
                if not ok then
                    warn("[Nexo] " .. className .. "." .. tostring(key) .. ": " .. tostring(err))
                end
            end
        end
    end

    if instance:IsA("GuiButton") then
        instance.AutoButtonColor = false
        instance.Selectable = false
    end

    if parent ~= nil then
        instance.Parent = parent
    end

    return instance
end

local function Corner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

-- Pad(parent, hepsi) | Pad(parent, dikey, yatay) | Pad(parent, ust, sag, alt, sol)
local function Pad(parent, top, right, bottom, left)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0),
        Parent = parent,
    })
end

local function Stroke(parent, thickness)
    return Create("UIStroke", {
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.new(1, 1, 1),
        Parent = parent,
    })
end

local function Label(props)
    local merged = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = F.Regular,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }
    for key, value in pairs(props) do
        merged[key] = value
    end
    return Create("TextLabel", merged)
end

local function Tween(instance, props, animate, info)
    if animate == false then
        for key, value in pairs(props) do
            instance[key] = value
        end
        return
    end
    TweenService:Create(instance, info or T_FAST, props):Play()
end

local function removeValue(list, value)
    for index, item in ipairs(list) do
        if item == value then
            table.remove(list, index)
            return
        end
    end
end

local function colorToHex(c)
    return string.format("#%02x%02x%02x",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end

local function hexToColor(hex)
    hex = string.gsub(tostring(hex), "#", "")
    if #hex ~= 6 then
        return nil
    end
    local r = tonumber(string.sub(hex, 1, 2), 16)
    local g = tonumber(string.sub(hex, 3, 4), 16)
    local b = tonumber(string.sub(hex, 5, 6), 16)
    if r and g and b then
        return Color3.fromRGB(r, g, b)
    end
    return nil
end

local function normalize(value)
    return string.lower(tostring(value or ""))
end

--========================================================================--
-- ICONS
--========================================================================--

local Lucide = nil

local function LoadLucide()
    if Lucide ~= nil then
        return Lucide
    end

    if RunService:IsStudio() then
        local module = Workspace:FindFirstChild("LucideRoblox")
        if module then
            local ok, result = pcall(require, module)
            if ok and type(result) == "table" then
                Lucide = result
                return Lucide
            end
        end
    else
        local ok, chunk = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/corapluz/uilibv2/refs/heads/main/lucide.lua"))
        end)
        if ok and chunk then
            local ok2, result = pcall(chunk)
            if ok2 and type(result) == "table" then
                Lucide = result
                return Lucide
            end
        end
    end

    Lucide = false
    return Lucide
end

-- isim (lucide) / sayi / rbxassetid -> image, rectOffset, rectSize
local function ResolveIcon(icon)
    if icon == nil or icon == "" then
        return ""
    end

    if type(icon) == "number" then
        return "rbxassetid://" .. tostring(icon)
    end

    if type(icon) == "string" then
        if string.match(icon, "^rbxassetid://") then
            return icon
        end
        if string.match(icon, "^%d+$") then
            return "rbxassetid://" .. icon
        end

        local lib = LoadLucide()
        if lib then
            local ok, asset = pcall(function()
                return lib.GetAsset(icon, 256)
            end)
            if ok and type(asset) == "table" and asset.Url then
                return asset.Url, asset.ImageRectOffset, asset.ImageRectSize
            end
        end
    end

    return ""
end

local function ApplyIcon(imageLabel, icon)
    local image, offset, size = ResolveIcon(icon)
    imageLabel.Image = image
    if typeof(offset) == "Vector2" and typeof(size) == "Vector2" then
        imageLabel.ImageRectOffset = offset
        imageLabel.ImageRectSize = size
    else
        imageLabel.ImageRectOffset = Vector2.new(0, 0)
        imageLabel.ImageRectSize = Vector2.new(0, 0)
    end
    return image ~= ""
end

local function GetGuiParent()
    local ok, hui = pcall(function()
        return gethui()
    end)
    if ok and typeof(hui) == "Instance" then
        return hui
    end

    local player = Players.LocalPlayer
    if player then
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if pg then
            return pg
        end
        return player:WaitForChild("PlayerGui")
    end

    return game:GetService("CoreGui")
end

--========================================================================--
-- GLYPHS (asset'e bagimli olmayan cizilmis ikonlar)
--========================================================================--

local function Bar(parent, w, h, x, y, rotation)
    return Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(w, h),
        Rotation = rotation or 0,
        Parent = parent,
    })
end

local function GlyphBox(parent, s)
    return Create("Frame", {
        Name = "Glyph",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(s, s),
        Parent = parent,
    })
end

local Glyph = {}

function Glyph.close(parent, s)
    local box = GlyphBox(parent, s)
    local a = Bar(box, s * 1.3, 1.5, s / 2, s / 2, 45)
    local b = Bar(box, s * 1.3, 1.5, s / 2, s / 2, -45)
    return box, function(color)
        a.BackgroundColor3 = color
        b.BackgroundColor3 = color
    end
end

function Glyph.minimize(parent, s)
    local box = GlyphBox(parent, s)
    local a = Bar(box, s, 1.5, s / 2, s / 2, 0)
    return box, function(color)
        a.BackgroundColor3 = color
    end
end

function Glyph.maximize(parent, s)
    local box = GlyphBox(parent, s)
    local square = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = box,
    })
    Corner(square, 2)
    local stroke = Stroke(square, 1.5)
    return box, function(color)
        stroke.Color = color
    end
end

function Glyph.chevron(parent, s)
    local box = GlyphBox(parent, s)
    local length = s * 0.72
    local extent = length * 0.7071
    local baseY = s * 0.75
    local a = Bar(box, length, 1.5, s / 2 - extent / 2, baseY - extent / 2, 45)
    local b = Bar(box, length, 1.5, s / 2 + extent / 2, baseY - extent / 2, -45)
    return box, function(color)
        a.BackgroundColor3 = color
        b.BackgroundColor3 = color
    end
end

function Glyph.search(parent, s)
    local box = GlyphBox(parent, s)
    local ring = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(s * 0.7, s * 0.7),
        Parent = box,
    })
    Corner(ring, 999)
    local stroke = Stroke(ring, 1.5)
    local handle = Bar(box, s * 0.4, 1.5, s * 0.84, s * 0.84, 45)
    return box, function(color)
        stroke.Color = color
        handle.BackgroundColor3 = color
    end
end

function Glyph.grip(parent, s)
    local box = GlyphBox(parent, s)
    local a = Bar(box, s * 0.9, 1.5, s / 2, s / 2, -45)
    local b = Bar(box, s * 0.45, 1.5, s * 0.72, s * 0.72, -45)
    return box, function(color)
        a.BackgroundColor3 = color
        b.BackgroundColor3 = color
    end
end

--========================================================================--
-- WINDOW: STATE / THEME
--========================================================================--

function Window:_connect(signal, fn, bucket)
    local connection = signal:Connect(fn)
    table.insert(self._conns, connection)
    if bucket then
        table.insert(bucket, connection)
    end
    return connection
end

-- Instance'a tema fonksiyonu bagla. fn(theme) hem simdi hem her tema degisiminde calisir.
function Window:_style(instance, fn)
    table.insert(self._styles, { inst = instance, fn = fn })
    fn(self._theme)
    return instance
end

function Window:_paint(instance, property, key)
    return self:_style(instance, function(theme)
        instance[property] = theme[key]
    end)
end

function Window:ApplyTheme()
    self._theme.AccentText = AccentTextFor(self._theme.Accent)

    local alive = {}
    for _, entry in ipairs(self._styles) do
        local inst = entry.inst
        if inst == self.ScreenGui or inst:IsDescendantOf(self.ScreenGui) then
            local ok, err = pcall(entry.fn, self._theme)
            if not ok then
                warn("[Nexo] theme: " .. tostring(err))
            end
            table.insert(alive, entry)
        end
    end
    self._styles = alive
end

function Window:_syncPickers()
    for key, picker in pairs(self._themePickers or {}) do
        local value = self._theme[key]
        if typeof(value) == "Color3" then
            picker:Set(value, true)
        end
    end
end

function Window:SetAccent(color)
    self._theme.Accent = color
    self:ApplyTheme()
end

function Window:SetThemeColor(key, color)
    key = LegacyKeys[key] or key
    self._theme[key] = color
    self:ApplyTheme()
end

function Window:SetThemePreset(name)
    local preset = Presets[name]
    if not preset then
        warn("[Nexo] bilinmeyen tema: " .. tostring(name))
        return
    end
    for key, value in pairs(preset) do
        self._theme[key] = value
    end
    self:ApplyTheme()
    self:_syncPickers()
end

function Window:ExportTheme()
    local out = {}
    for _, key in ipairs(THEME_KEYS) do
        out[key] = colorToHex(self._theme[key])
    end
    return HttpService:JSONEncode(out)
end

function Window:ImportTheme(json)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    if not ok or type(data) ~= "table" then
        self:Notify({ Title = "Theme", Content = "Invalid theme JSON.", Duration = 4 })
        return false
    end

    for _, key in ipairs(THEME_KEYS) do
        if type(data[key]) == "string" then
            local color = hexToColor(data[key])
            if color then
                self._theme[key] = color
            end
        end
    end

    self:ApplyTheme()
    self:_syncPickers()
    self:Notify({ Title = "Theme", Content = "Theme imported.", Duration = 3 })
    return true
end

--========================================================================--
-- WINDOW: SEARCH
--========================================================================--

function Window:_currentTab()
    if self._settingsOpen then
        return self._settingsTab
    end
    return self._activeTab
end

function Window:_runSearch()
    if not self._searchInput then
        return
    end

    local tab = self:_currentTab()
    if not tab then
        return
    end

    local query = normalize(self._searchInput.Text)
    local searching = query ~= ""
    local anyShown = false

    self._searchClear.Visible = searching

    for _, category in ipairs(tab._categories) do
        local categoryMatch = (not searching) or string.find(normalize(category._title), query, 1, true) ~= nil
        local anyComponent = false

        for _, component in ipairs(category._components) do
            local holder = component._holder
            if holder and holder.Parent then
                local match = categoryMatch
                    or string.find(normalize(component._searchTitle), query, 1, true) ~= nil
                    or string.find(normalize(component._searchDescription), query, 1, true) ~= nil
                local show = component._userVisible ~= false and match
                holder.Visible = show
                if show then
                    anyComponent = true
                end
            end
        end

        local showCategory = category._visible and (categoryMatch or anyComponent)
        category.Root.Visible = showCategory
        category:_refreshBody(searching, false)

        if showCategory then
            anyShown = true
        end
    end

    self._noResults.Visible = searching and not anyShown
end

--========================================================================--
-- WINDOW: NAV / PAGES
--========================================================================--

function Window:_makeNavItem(parent, title, icon)
    local item = { hover = false, active = false }

    local frame = Create("Frame", {
        Name = "NavItem",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = parent,
    })
    Corner(frame, 6)

    local bar = Create("Frame", {
        Name = "Indicator",
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 14),
        Visible = false,
        Parent = frame,
    })
    Corner(bar, 2)

    local iconLabel = Create("ImageLabel", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = frame,
    })

    local label = Label({
        Name = "Title",
        Font = F.Medium,
        Text = title,
        Parent = frame,
    })

    local button = Create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = frame,
    })

    local function layout(hasIcon)
        iconLabel.Visible = hasIcon
        label.Position = UDim2.fromOffset(hasIcon and 36 or 14, 0)
        label.Size = UDim2.new(1, -(hasIcon and 44 or 22), 1, 0)
    end

    layout(icon ~= nil and ApplyIcon(iconLabel, icon))

    local function render(animate)
        local theme = self._theme
        Tween(frame, { BackgroundTransparency = item.active and 0 or (item.hover and 0.55 or 1) }, animate)
        local color = (item.active or item.hover) and theme.Text or theme.TextDim
        label.TextColor3 = color
        iconLabel.ImageColor3 = color
        bar.Visible = item.active
    end

    self:_style(frame, function(theme)
        frame.BackgroundColor3 = theme.SurfaceHover
        bar.BackgroundColor3 = theme.Accent
        render(false)
    end)

    button.MouseEnter:Connect(function()
        item.hover = true
        render(true)
    end)
    button.MouseLeave:Connect(function()
        item.hover = false
        render(true)
    end)

    item.frame = frame
    item.button = button

    function item.SetActive(value)
        item.active = value
        render(true)
    end
    function item.SetTitle(text)
        label.Text = text
    end
    function item.SetIcon(newIcon)
        layout(ApplyIcon(iconLabel, newIcon))
    end

    return item
end

function Window:_newPage()
    local tab = setmetatable({}, Tab)
    tab._window = self
    tab._categories = {}
    tab._order = 0

    local page = Create("ScrollingFrame", {
        Name = "Page",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        Parent = self._content,
    })
    Pad(page, 12, 14, 12, 12)
    self:_style(page, function(theme)
        page.ScrollBarImageColor3 = theme.BorderHover
    end)

    local columns = Create("Frame", {
        Name = "Columns",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = page,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = columns,
    })

    local function makeColumn(order)
        local column = Create("Frame", {
            Name = "Column",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(0.5, -5, 0, 0),
            LayoutOrder = order,
            Parent = columns,
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = column,
        })
        return column
    end

    tab.Root = page
    tab._left = makeColumn(1)
    tab._right = makeColumn(2)

    return tab
end

function Window:_refreshPages()
    for _, tab in ipairs(self._tabs) do
        local on = (not self._settingsOpen) and tab == self._activeTab
        tab.Root.Visible = on
        tab._nav.SetActive(on)
    end
    self._settingsTab.Root.Visible = self._settingsOpen
    self._settingsNav.SetActive(self._settingsOpen)
    self:_runSearch()
end

function Window:SelectTab(tab)
    self._settingsOpen = false
    self._activeTab = tab
    self:_refreshPages()
end

function Window:AddTab(config)
    config = config or {}
    if type(config) == "string" then
        config = { Title = config }
    end

    local tab = self:_newPage()
    tab._nav = self:_makeNavItem(self._navList, config.Title or "Tab", config.Icon)
    tab._nav.frame.LayoutOrder = #self._tabs + 1
    tab._nav.button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self._tabs, tab)
    if not self._activeTab then
        self._activeTab = tab
    end
    self:_refreshPages()

    return tab
end

function Window:SetTitle(text)
    self.TitleLabel.Text = text
end

--========================================================================--
-- TAB
--========================================================================--

function Tab:_relayout()
    local left, right = 0, 0
    for _, category in ipairs(self._categories) do
        if category._side == "Right" then
            right += 1
        else
            left += 1
        end
    end

    if right == 0 then
        self._left.Visible = true
        self._right.Visible = false
        self._left.Size = UDim2.new(1, 0, 0, 0)
    elseif left == 0 then
        self._left.Visible = false
        self._right.Visible = true
        self._right.Size = UDim2.new(1, 0, 0, 0)
    else
        self._left.Visible = true
        self._right.Visible = true
        self._left.Size = UDim2.new(0.5, -5, 0, 0)
        self._right.Size = UDim2.new(0.5, -5, 0, 0)
    end
end

function Tab:SetTitle(text)
    if self._nav then
        self._nav.SetTitle(text)
    end
end

function Tab:SetIcon(icon)
    if self._nav then
        self._nav.SetIcon(icon)
    end
end

function Tab:AddCategory(config)
    config = config or {}
    if type(config) == "string" then
        config = { Title = config }
    end

    local window = self._window
    local side = config.Side == "Right" and "Right" or "Left"
    local column = side == "Right" and self._right or self._left

    local category = setmetatable({}, Category)
    category._window = window
    category._tab = self
    category._side = side
    category._title = config.Title or "Category"
    category._collapsed = config.Collapsed == true
    category._visible = true
    category._components = {}
    category._order = 0

    self._order += 1

    local root = Create("Frame", {
        Name = "Category",
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = self._order,
        Parent = column,
    })
    Corner(root, 6)
    local rootStroke = Stroke(root)
    window:_style(root, function(theme)
        root.BackgroundColor3 = theme.Surface
        rootStroke.Color = theme.Border
    end)
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = root })

    local header = Create("TextButton", {
        Name = "Header",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 0, 32),
        LayoutOrder = 1,
        Parent = root,
    })

    local iconLabel = Create("ImageLabel", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Visible = false,
        Parent = header,
    })
    window:_paint(iconLabel, "ImageColor3", "TextDim")

    local titleLabel = Label({
        Name = "Title",
        Font = F.Semi,
        Text = category._title,
        Parent = header,
    })
    window:_paint(titleLabel, "TextColor3", "Text")

    local chevron, paintChevron = Glyph.chevron(header, 10)
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, -14, 0.5, 0)
    window:_style(chevron, function(theme)
        paintChevron(theme.TextMuted)
    end)

    local function layoutHeader(hasIcon)
        iconLabel.Visible = hasIcon
        titleLabel.Position = UDim2.fromOffset(hasIcon and 34 or 12, 0)
        titleLabel.Size = UDim2.new(1, -((hasIcon and 34 or 12) + 34), 1, 0)
    end
    layoutHeader(config.Icon ~= nil and ApplyIcon(iconLabel, config.Icon))

    local divider = Create("Frame", {
        Name = "Divider",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        LayoutOrder = 2,
        Parent = root,
    })
    window:_paint(divider, "BackgroundColor3", "Border")

    local body = Create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 3,
        Parent = root,
    })
    Pad(body, 6)
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })

    category.Root = root
    category.Header = header
    category.Body = body
    category._divider = divider
    category._chevron = chevron
    category._titleLabel = titleLabel
    category._iconLabel = iconLabel
    category._layoutHeader = layoutHeader

    header.MouseButton1Click:Connect(function()
        category:SetCollapsed(not category._collapsed)
    end)

    table.insert(self._categories, category)
    self:_relayout()
    category:_refreshBody(false, false)

    return category
end

--========================================================================--
-- CATEGORY
--========================================================================--

function Category:_nextOrder()
    self._order += 1
    return self._order
end

function Category:_refreshBody(forceOpen, animate)
    local open = (not self._collapsed) or forceOpen
    self.Body.Visible = open
    self._divider.Visible = open
    Tween(self._chevron, { Rotation = open and 0 or -90 }, animate)
end

function Category:SetCollapsed(collapsed)
    self._collapsed = collapsed == true
    local searching = self._window._searchInput and self._window._searchInput.Text ~= ""
    self:_refreshBody(searching, true)
end

function Category:SetTitle(text)
    self._title = text
    self._titleLabel.Text = text
end

function Category:SetIcon(icon)
    self._layoutHeader(ApplyIcon(self._iconLabel, icon))
end

function Category:SetVisible(visible)
    self._visible = visible ~= false
    self._window:_runSearch()
end

-- v2 uyumlulugu: kilit ozelligi kaldirildi, cagrilar hata vermesin diye bos birakildi
function Category:SetLocked() end

function Category:Destroy()
    removeValue(self._tab._categories, self)
    self.Root:Destroy()
    self._tab:_relayout()
end

function Category:_register(api, info)
    local window = self._window
    local category = self

    api._holder = info.holder
    api._searchTitle = info.title or ""
    api._searchDescription = info.description or ""
    api._flag = info.flag
    api._configKind = info.kind
    api._userVisible = true
    api._category = category
    api._window = window
    info.holder.LayoutOrder = category:_nextOrder()

    if info.flag then
        if window._flags[info.flag] then
            warn("[Nexo] ayni Flag iki kez kullanildi: " .. tostring(info.flag))
        end
        window._flags[info.flag] = api
    end

    function api:SetVisible(visible)
        api._userVisible = visible ~= false
        window:_runSearch()
    end

    local inner = api.Destroy
    function api:Destroy()
        if api._destroyed then
            return
        end
        api._destroyed = true
        removeValue(category._components, api)
        if info.flag and window._flags[info.flag] == api then
            window._flags[info.flag] = nil
        end
        if inner then
            inner(api)
        end
        info.holder:Destroy()
        window:_runSearch()
    end

    table.insert(category._components, api)

    if window._searchInput and window._searchInput.Text ~= "" then
        window:_runSearch()
    end

    return api
end

--========================================================================--
-- ROW BUILDER (toggle / slider / input / keybind / dropdown / colorpicker ortak)
--========================================================================--

local function BuildRow(window, parent, title, description, reserve, extra)
    extra = extra or 0

    local row = Create("Frame", {
        Name = "Row",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = parent,
    })
    Corner(row, 5)
    window:_paint(row, "BackgroundColor3", "SurfaceHover")

    local titleLabel = Label({
        Name = "Title",
        Font = F.Medium,
        Text = title,
        Size = UDim2.new(1, -(reserve + 16), 0, 16),
        Parent = row,
    })
    window:_paint(titleLabel, "TextColor3", "Text")

    local descLabel = Label({
        Name = "Description",
        Text = description or "",
        TextSize = 11,
        Size = UDim2.new(1, -(reserve + 16), 0, 14),
        Parent = row,
    })
    window:_paint(descLabel, "TextColor3", "TextDim")

    local obj = { Row = row, Title = titleLabel, Desc = descLabel }
    local hoverCount = 0

    function obj.layout()
        local hasDesc = descLabel.Text ~= ""
        row.Size = UDim2.new(1, 0, 0, (hasDesc and 42 or 30) + extra)

        if hasDesc or extra > 0 then
            titleLabel.AnchorPoint = Vector2.new(0, 0)
            titleLabel.Position = UDim2.fromOffset(8, hasDesc and 6 or 7)
        else
            titleLabel.AnchorPoint = Vector2.new(0, 0.5)
            titleLabel.Position = UDim2.new(0, 8, 0.5, 0)
        end

        descLabel.Visible = hasDesc
        descLabel.Position = UDim2.fromOffset(8, 22)

        if obj.onLayout then
            obj.onLayout(hasDesc)
        end
    end
    obj.layout()

    -- Hover sayaci: ust uste binen overlay'lerde flicker olmasin
    function obj.watch(guiObject)
        guiObject.MouseEnter:Connect(function()
            hoverCount += 1
            Tween(row, { BackgroundTransparency = 0 })
        end)
        guiObject.MouseLeave:Connect(function()
            hoverCount = math.max(0, hoverCount - 1)
            if hoverCount == 0 then
                Tween(row, { BackgroundTransparency = 1 })
            end
        end)
    end
    obj.watch(row)

    function obj.setTitle(text)
        titleLabel.Text = text
    end
    function obj.setDescription(text)
        descLabel.Text = text or ""
        obj.layout()
    end

    return obj
end

local function Tip(window, instance, text)
    if text and text ~= "" then
        window:AttachTooltip(instance, text)
    end
end

--========================================================================--
-- COMPONENT: BUTTON
--========================================================================--

function Category:AddButton(config)
    config = config or {}
    local window = self._window
    local style = config.Style
    local hasDesc = config.Description ~= nil and config.Description ~= ""

    local button = Create("TextButton", {
        Name = "Button",
        BorderSizePixel = 0,
        Text = "",
        Size = UDim2.new(1, 0, 0, hasDesc and 42 or 30),
        Parent = self.Body,
    })
    Corner(button, 5)
    local stroke = Stroke(button)

    local titleLabel = Label({
        Name = "Title",
        Font = F.Medium,
        Text = config.Title or "Button",
        Parent = button,
    })
    local descLabel = Label({
        Name = "Description",
        Text = config.Description or "",
        TextSize = 11,
        Position = UDim2.fromOffset(10, 22),
        Size = UDim2.new(1, -20, 0, 14),
        Visible = hasDesc,
        Parent = button,
    })

    local function layout()
        local desc = descLabel.Text ~= ""
        button.Size = UDim2.new(1, 0, 0, desc and 42 or 30)
        descLabel.Visible = desc
        if desc then
            titleLabel.AnchorPoint = Vector2.new(0, 0)
            titleLabel.Position = UDim2.fromOffset(10, 6)
            titleLabel.Size = UDim2.new(1, -20, 0, 16)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        else
            titleLabel.AnchorPoint = Vector2.new(0, 0.5)
            titleLabel.Position = UDim2.new(0, 10, 0.5, 0)
            titleLabel.Size = UDim2.new(1, -20, 0, 16)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        end
    end
    layout()

    local hover, down = false, false

    local function render(animate)
        local theme = window._theme
        local bg, border, text
        if style == "Primary" then
            bg = theme.Accent
            border = theme.Accent
            text = theme.AccentText
            if hover then bg = bg:Lerp(Color3.new(1, 1, 1), 0.12) end
            if down then bg = bg:Lerp(Color3.new(0, 0, 0), 0.15) end
        else
            bg = theme.Elevated
            border = theme.Border
            text = style == "Danger" and theme.Danger or theme.Text
            if hover then bg = theme.SurfaceHover; border = theme.BorderHover end
            if down then bg = theme.Background end
        end
        Tween(button, { BackgroundColor3 = bg }, animate)
        Tween(stroke, { Color = border }, animate)
        titleLabel.TextColor3 = text
        descLabel.TextColor3 = style == "Primary" and text or theme.TextDim
    end
    window:_style(button, function()
        render(false)
    end)

    button.MouseEnter:Connect(function() hover = true; render(true) end)
    button.MouseLeave:Connect(function() hover = false; down = false; render(true) end)
    button.MouseButton1Down:Connect(function() down = true; render(true) end)
    button.MouseButton1Up:Connect(function() down = false; render(true) end)
    button.MouseButton1Click:Connect(function()
        if config.Callback then
            task.spawn(config.Callback)
        end
    end)

    Tip(window, button, config.Tooltip)

    local api = {}
    function api:SetTitle(text)
        titleLabel.Text = text
        api._searchTitle = text
    end
    function api:SetDescription(text)
        descLabel.Text = text or ""
        api._searchDescription = text or ""
        layout()
    end

    return self:_register(api, {
        holder = button,
        title = config.Title or "Button",
        description = config.Description,
    })
end

--========================================================================--
-- COMPONENT: TOGGLE
--========================================================================--

function Window:_toggleGroup(name)
    self._toggleGroups[name] = self._toggleGroups[name] or {}
    return self._toggleGroups[name]
end

function Category:AddToggle(config)
    config = config or {}
    local window = self._window

    local row = BuildRow(window, self.Body, config.Title or "Toggle", config.Description, 44)

    local track = Create("Frame", {
        Name = "Switch",
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(30, 16),
        Parent = row.Row,
    })
    Corner(track, 8)
    local trackStroke = Stroke(track)

    local knob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        Parent = track,
    })
    Corner(knob, 6)

    local hit = Create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = row.Row,
    })
    row.watch(hit)

    local state = false

    local function render(animate)
        local theme = window._theme
        Tween(track, { BackgroundColor3 = state and theme.Accent or theme.Elevated }, animate)
        Tween(trackStroke, { Color = state and theme.Accent or theme.BorderHover }, animate)
        Tween(knob, {
            Position = state and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BackgroundColor3 = state and Color3.new(1, 1, 1) or theme.TextDim,
        }, animate)
    end
    window:_style(track, function()
        render(false)
    end)

    local api = {}

    function api:Get()
        return state
    end

    function api:Set(value, silent)
        value = value == true
        if state == value then
            return
        end
        state = value
        render(true)

        if value and config.Group then
            for _, other in ipairs(window:_toggleGroup(config.Group)) do
                if other ~= api and other:Get() then
                    other:Set(false)
                end
            end
        end

        if not silent and config.Callback then
            task.spawn(config.Callback, state)
        end
    end

    function api:SetTitle(text)
        row.setTitle(text)
        api._searchTitle = text
    end
    function api:SetDescription(text)
        row.setDescription(text)
        api._searchDescription = text or ""
    end
    function api:Destroy()
        if config.Group then
            removeValue(window:_toggleGroup(config.Group), api)
        end
    end

    hit.MouseButton1Click:Connect(function()
        api:Set(not state)
    end)

    if config.Group then
        table.insert(window:_toggleGroup(config.Group), api)
    end

    if config.Default then
        state = true
        render(false)
    end

    Tip(window, row.Row, config.Tooltip)

    return self:_register(api, {
        holder = row.Row,
        title = config.Title or "Toggle",
        description = config.Description,
        flag = config.Flag,
        kind = "toggle",
    })
end

--========================================================================--
-- COMPONENT: SLIDER
--========================================================================--

function Category:AddSlider(config)
    config = config or {}
    local window = self._window

    local minValue = config.Min or 0
    local maxValue = config.Max or 100
    if maxValue < minValue then
        minValue, maxValue = maxValue, minValue
    end
    if maxValue == minValue then
        maxValue = minValue + 1
    end

    local increment = math.abs(config.Increment or 1)
    if increment <= 0 then
        increment = 1
    end
    local suffix = config.Suffix or ""

    local decimals = string.match(tostring(increment), "%.(%d+)")
    local precision = decimals and math.min(#decimals, 6) or 0

    local row = BuildRow(window, self.Body, config.Title or "Slider", config.Description, 72, 16)

    local valueLabel = Label({
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = F.Mono,
        Size = UDim2.fromOffset(0, 16),
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row.Row,
    })
    window:_paint(valueLabel, "TextColor3", "TextDim")

    row.onLayout = function(hasDesc)
        valueLabel.Position = UDim2.new(1, -8, 0, hasDesc and 6 or 7)
    end
    row.layout()

    local track = Create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 1, -10),
        Size = UDim2.new(1, -16, 0, 4),
        Parent = row.Row,
    })
    Corner(track, 2)
    local fill = Create("Frame", {
        Name = "Fill",
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    Corner(fill, 2)
    local knob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        ZIndex = 2,
        Parent = track,
    })
    Corner(knob, 5)
    window:_style(track, function(theme)
        track.BackgroundColor3 = theme.Border
        fill.BackgroundColor3 = theme.Accent
    end)

    local hit = Create("TextButton", {
        Name = "Hit",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Text = "",
        Position = UDim2.new(0, 4, 1, -2),
        Size = UDim2.new(1, -8, 0, 20),
        ZIndex = 3,
        Parent = row.Row,
    })
    row.watch(hit)

    local value = minValue

    local function snap(raw)
        local clamped = math.clamp(raw, minValue, maxValue)
        local steps = math.floor((clamped - minValue) / increment + 0.5)
        local stepped = minValue + steps * increment
        local multiplier = 10 ^ precision
        stepped = math.floor(stepped * multiplier + 0.5) / multiplier
        return math.clamp(stepped, minValue, maxValue)
    end

    local function format(number)
        if precision > 0 then
            return string.format("%." .. tostring(precision) .. "f", number)
        end
        return tostring(math.floor(number + 0.5))
    end

    local function render(animate)
        local alpha = (value - minValue) / (maxValue - minValue)
        Tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, animate)
        Tween(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, animate)
        valueLabel.Text = format(value) .. suffix
    end

    local function setValue(newValue, silent, animate)
        local snapped = snap(newValue)
        local changed = snapped ~= value
        value = snapped
        render(animate)
        if changed and not silent and config.Callback then
            task.spawn(config.Callback, value)
        end
    end

    local conns = {}
    local dragging = false
    local activeTouch = nil

    local function fromX(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return
        end
        local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        setValue(minValue + alpha * (maxValue - minValue), false, false)
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeTouch = nil
            fromX(input.Position.X)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeTouch = input
            fromX(input.Position.X)
        end
    end)

    window:_connect(UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement and activeTouch == nil then
            fromX(input.Position.X)
        elseif input.UserInputType == Enum.UserInputType.Touch and input == activeTouch then
            fromX(input.Position.X)
        end
    end, conns)

    window:_connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and activeTouch == nil then
            dragging = false
        elseif input.UserInputType == Enum.UserInputType.Touch and input == activeTouch then
            dragging = false
            activeTouch = nil
        end
    end, conns)

    local api = {}

    function api:Get()
        return value
    end
    function api:Set(newValue, silent)
        setValue(newValue, silent, true)
    end
    function api:SetTitle(text)
        row.setTitle(text)
        api._searchTitle = text
    end
    function api:SetDescription(text)
        row.setDescription(text)
        api._searchDescription = text or ""
    end
    function api:Destroy()
        for _, connection in ipairs(conns) do
            connection:Disconnect()
        end
    end

    setValue(config.Default or minValue, true, false)

    if config.Watch then
        window:_connect(RunService.Heartbeat, function()
            if dragging then
                return
            end
            local ok, current = pcall(config.Watch)
            if ok and type(current) == "number" then
                local snapped = snap(current)
                if snapped ~= value then
                    value = snapped
                    render(false)
                end
            end
        end, conns)
    end

    Tip(window, row.Row, config.Tooltip)

    return self:_register(api, {
        holder = row.Row,
        title = config.Title or "Slider",
        description = config.Description,
        flag = config.Flag,
        kind = "slider",
    })
end

--========================================================================--
-- COMPONENT: INPUT
--========================================================================--

function Category:AddInput(config)
    config = config or {}
    local window = self._window
    local boxWidth = config.Width or 120

    local row = BuildRow(window, self.Body, config.Title or "Input", config.Description, boxWidth + 8)

    local box = Create("Frame", {
        Name = "Box",
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(boxWidth, 22),
        Parent = row.Row,
    })
    Corner(box, 5)
    local boxStroke = Stroke(box)

    local textBox = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        ClearTextOnFocus = config.ClearOnFocus == true,
        Font = F.Regular,
        PlaceholderText = config.Placeholder or "",
        Position = UDim2.fromOffset(6, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Text = config.Default or "",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })

    window:_style(box, function(theme)
        box.BackgroundColor3 = theme.Elevated
        boxStroke.Color = textBox:IsFocused() and theme.Accent or theme.Border
        textBox.TextColor3 = theme.Text
        textBox.PlaceholderColor3 = theme.TextMuted
    end)

    textBox.Focused:Connect(function()
        Tween(boxStroke, { Color = window._theme.Accent })
    end)
    textBox.FocusLost:Connect(function()
        Tween(boxStroke, { Color = window._theme.Border })
        if config.Callback then
            task.spawn(config.Callback, textBox.Text)
        end
    end)

    local api = {}
    function api:Get()
        return textBox.Text
    end
    function api:Set(text, silent)
        textBox.Text = tostring(text)
        if not silent and config.Callback then
            task.spawn(config.Callback, textBox.Text)
        end
    end
    function api:SetTitle(text)
        row.setTitle(text)
        api._searchTitle = text
    end
    function api:SetDescription(text)
        row.setDescription(text)
        api._searchDescription = text or ""
    end

    Tip(window, row.Row, config.Tooltip)

    return self:_register(api, {
        holder = row.Row,
        title = config.Title or "Input",
        description = config.Description,
        flag = config.Flag,
        kind = "input",
    })
end

--========================================================================--
-- COMPONENT: KEYBIND
--========================================================================--

function Category:AddKeybind(config)
    config = config or {}
    local window = self._window

    local row = BuildRow(window, self.Body, config.Title or "Keybind", config.Description, 72)

    local chip = Create("TextButton", {
        Name = "Key",
        AnchorPoint = Vector2.new(1, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        Font = F.Mono,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(0, 22),
        Text = "",
        TextSize = 11,
        Parent = row.Row,
    })
    Corner(chip, 5)
    Pad(chip, 0, 8)
    Create("UISizeConstraint", { MinSize = Vector2.new(36, 22), Parent = chip })
    local chipStroke = Stroke(chip)

    local currentKey = config.Default or Enum.KeyCode.K
    local listening = false

    local function keyLabel(key)
        return KeyNames[key] or key.Name
    end

    local function render()
        local theme = window._theme
        chip.Text = listening and "..." or keyLabel(currentKey)
        chip.TextColor3 = listening and theme.Accent or theme.TextDim
        chip.BackgroundColor3 = theme.Elevated
        chipStroke.Color = listening and theme.Accent or theme.Border
    end
    window:_style(chip, render)

    local entry = window:_registerKeybindEntry(config.Title or "Keybind", function()
        return keyLabel(currentKey)
    end)

    local api = {}
    local conns = {}

    function api:Get()
        return currentKey
    end
    function api:Set(key, silent)
        if typeof(key) ~= "EnumItem" then
            return
        end
        currentKey = key
        render()
        window:_refreshKeybindList()
        if not silent and config.ChangedCallback then
            task.spawn(config.ChangedCallback, key)
        end
    end
    function api:SetTitle(text)
        row.setTitle(text)
        entry.title = text
        api._searchTitle = text
        window:_refreshKeybindList()
    end
    function api:SetDescription(text)
        row.setDescription(text)
        api._searchDescription = text or ""
    end
    function api:Destroy()
        for _, connection in ipairs(conns) do
            connection:Disconnect()
        end
        if listening then
            window._keybindListening = false
        end
        removeValue(window._keybindEntries, entry)
        window:_refreshKeybindList()
    end

    chip.MouseButton1Click:Connect(function()
        if listening then
            return
        end
        listening = true
        window._keybindListening = true
        render()
    end)

    window:_connect(UserInputService.InputBegan, function(input, processed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                window._keybindListening = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    render()
                else
                    api:Set(input.KeyCode)
                end
            end
            return
        end

        if processed or window._keybindListening then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            if config.Callback then
                task.spawn(config.Callback, currentKey)
            end
        end
    end, conns)

    Tip(window, row.Row, config.Tooltip)

    return self:_register(api, {
        holder = row.Row,
        title = config.Title or "Keybind",
        description = config.Description,
        flag = config.Flag,
        kind = "keybind",
    })
end

--========================================================================--
-- COMPONENT: DROPDOWN
--========================================================================--

function Category:AddDropdown(config)
    config = config or {}
    local window = self._window
    local multi = config.Multi == true

    local values = {}
    for _, value in ipairs(config.Values or {}) do
        table.insert(values, tostring(value))
    end

    local searchable = config.Searchable
    if searchable == nil then
        searchable = #values > 7
    end

    local selected = {}
    local options = {}
    local expanded = false

    local holder = Create("Frame", {
        Name = "Dropdown",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Body,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    local row = BuildRow(window, holder, config.Title or "Dropdown", config.Description, 138)
    row.Row.LayoutOrder = 1

    local box = Create("Frame", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(122, 22),
        Parent = row.Row,
    })
    Corner(box, 5)
    local boxStroke = Stroke(box)

    local valueLabel = Label({
        Name = "Text",
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -26, 1, 0),
        TextSize = 12,
        Parent = box,
    })

    local chevron, paintChevron = Glyph.chevron(box, 8)
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, -8, 0.5, 0)

    local hit = Create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = row.Row,
    })
    row.watch(hit)

    local panel = Create("Frame", {
        Name = "Panel",
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, -16, 0, 40),
        Visible = false,
        Parent = holder,
    })
    Corner(panel, 5)
    local panelStroke = Stroke(panel)
    Pad(panel, 4)
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = panel,
    })

    local searchBox = nil
    if searchable then
        searchBox = Create("TextBox", {
            Name = "Search",
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Font = F.Regular,
            LayoutOrder = 1,
            PlaceholderText = "Search...",
            Size = UDim2.new(1, 0, 0, 24),
            Text = "",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = panel,
        })
        Corner(searchBox, 4)
        Pad(searchBox, 0, 8)
    end

    local scroller = Create("ScrollingFrame", {
        Name = "Options",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        LayoutOrder = 2,
        ScrollBarThickness = 2,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = panel,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scroller,
    })

    local emptyLabel = Label({
        Name = "Empty",
        LayoutOrder = 0,
        Size = UDim2.new(1, 0, 0, 24),
        Text = "No results",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = scroller,
    })

    window:_style(holder, function(theme)
        box.BackgroundColor3 = theme.Elevated
        boxStroke.Color = expanded and theme.Accent or theme.Border
        paintChevron(theme.TextDim)
        panel.BackgroundColor3 = theme.Elevated
        panelStroke.Color = theme.Border
        scroller.ScrollBarImageColor3 = theme.BorderHover
        emptyLabel.TextColor3 = theme.TextMuted
        if searchBox then
            searchBox.BackgroundColor3 = theme.Surface
            searchBox.TextColor3 = theme.Text
            searchBox.PlaceholderColor3 = theme.TextMuted
        end
    end)

    local function selectedList()
        local list = {}
        for _, value in ipairs(values) do
            if selected[value] then
                table.insert(list, value)
            end
        end
        return list
    end

    local function renderHeader()
        local theme = window._theme
        local list = selectedList()
        if #list == 0 then
            valueLabel.Text = config.Placeholder or "None"
            valueLabel.TextColor3 = theme.TextMuted
        else
            valueLabel.Text = multi and table.concat(list, ", ") or list[1]
            valueLabel.TextColor3 = theme.Text
        end
    end
    window:_style(valueLabel, renderHeader)

    local function resize()
        local count = 0
        for _, option in ipairs(options) do
            if option.button.Visible then
                count += 1
            end
        end
        local height = count == 0 and 24 or math.min(count * 25 - 1, 125)
        scroller.Size = UDim2.new(1, 0, 0, height)
        panel.Size = UDim2.new(1, -16, 0, 8 + (searchBox and 28 or 0) + height)
        emptyLabel.Visible = count == 0
    end

    local function applyFilter()
        local query = searchBox and string.lower(searchBox.Text) or ""
        for _, option in ipairs(options) do
            option.button.Visible = query == "" or string.find(string.lower(option.value), query, 1, true) ~= nil
        end
        resize()
    end

    local function styleOption(option, animate)
        local theme = window._theme
        local isSelected = selected[option.value] == true
        option.button.BackgroundColor3 = theme.SurfaceHover
        Tween(option.button, { BackgroundTransparency = option.hover and 0 or 1 }, animate)
        option.label.TextColor3 = (isSelected or option.hover) and theme.Text or theme.TextDim
        option.dot.Visible = isSelected
        option.dot.BackgroundColor3 = theme.Accent
    end

    local function fire()
        if not config.Callback then
            return
        end
        if multi then
            task.spawn(config.Callback, selectedList())
        else
            task.spawn(config.Callback, selectedList()[1])
        end
    end

    local setExpanded

    local function choose(value)
        if multi then
            selected[value] = (not selected[value]) or nil
        else
            selected = { [value] = true }
        end
        for _, option in ipairs(options) do
            styleOption(option, true)
        end
        renderHeader()
        fire()
        if not multi then
            setExpanded(false)
        end
    end

    local function rebuild()
        for _, option in ipairs(options) do
            option.button:Destroy()
        end
        options = {}

        for index, value in ipairs(values) do
            local button = Create("TextButton", {
                Name = "Option",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = index,
                Size = UDim2.new(1, 0, 0, 24),
                Text = "",
                Parent = scroller,
            })
            Corner(button, 4)
            local label = Label({
                Position = UDim2.fromOffset(8, 0),
                Size = UDim2.new(1, -28, 1, 0),
                Text = value,
                TextSize = 12,
                Parent = button,
            })
            local dot = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(6, 6),
                Visible = false,
                Parent = button,
            })
            Corner(dot, 3)

            local option = { value = value, button = button, label = label, dot = dot, hover = false }
            table.insert(options, option)

            window:_style(button, function()
                styleOption(option, false)
            end)

            button.MouseEnter:Connect(function()
                option.hover = true
                styleOption(option, true)
            end)
            button.MouseLeave:Connect(function()
                option.hover = false
                styleOption(option, true)
            end)
            button.MouseButton1Click:Connect(function()
                choose(value)
            end)
        end

        applyFilter()
    end

    setExpanded = function(state)
        if state and config.OnOpen then
            pcall(config.OnOpen)
        end
        expanded = state
        if searchBox and state then
            searchBox.Text = ""
        end
        panel.Visible = state
        if state then
            resize()
        end
        Tween(chevron, { Rotation = state and 180 or 0 })
        Tween(boxStroke, { Color = state and window._theme.Accent or window._theme.Border })
    end

    hit.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)
    end

    local api = {}

    function api:Get()
        local list = selectedList()
        if multi then
            return list
        end
        return list[1]
    end

    function api:Set(value, silent)
        selected = {}
        if type(value) == "table" then
            for _, item in ipairs(value) do
                selected[tostring(item)] = true
            end
        elseif value ~= nil then
            selected[tostring(value)] = true
        end
        for _, option in ipairs(options) do
            styleOption(option, false)
        end
        renderHeader()
        if not silent then
            fire()
        end
    end

    function api:SetValues(newValues)
        values = {}
        for _, value in ipairs(newValues or {}) do
            table.insert(values, tostring(value))
        end
        local known = {}
        for _, value in ipairs(values) do
            known[value] = true
        end
        for value in pairs(selected) do
            if not known[value] then
                selected[value] = nil
            end
        end
        rebuild()
        renderHeader()
    end

    function api:SetTitle(text)
        row.setTitle(text)
        api._searchTitle = text
    end
    function api:SetDescription(text)
        row.setDescription(text)
        api._searchDescription = text or ""
    end

    rebuild()

    if config.Default ~= nil then
        api:Set(config.Default, true)
    else
        renderHeader()
    end

    Tip(window, row.Row, config.Tooltip)

    return self:_register(api, {
        holder = holder,
        title = config.Title or "Dropdown",
        description = config.Description,
        flag = config.Flag,
        kind = "dropdown",
    })
end

--========================================================================--
-- COMPONENT: COLOR PICKER
--========================================================================--

function Category:AddColorPicker(config)
    config = config or {}
    local window = self._window

    local initial = config.Default or window._theme.Accent
    local hue, sat, val = initial:ToHSV()
    local expanded = false

    local holder = Create("Frame", {
        Name = "ColorPicker",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Body,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    local row = BuildRow(window, holder, config.Title or "Color", config.Description, 44)
    row.Row.LayoutOrder = 1

    local swatch = Create("Frame", {
        Name = "Swatch",
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(28, 16),
        Parent = row.Row,
    })
    Corner(swatch, 4)
    local swatchStroke = Stroke(swatch)
    window:_paint(swatchStroke, "Color", "BorderHover")

    local hit = Create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = row.Row,
    })
    row.watch(hit)

    local panel = Create("Frame", {
        Name = "Panel",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, -16, 0, 170),
        Visible = false,
        Parent = holder,
    })

    -- saturation / value alani
    local sv = Create("TextButton", {
        Name = "SV",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 110),
        Text = "",
        Parent = panel,
    })
    Corner(sv, 5)
    local whiteOverlay = Create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = sv,
    })
    Corner(whiteOverlay, 5)
    Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = whiteOverlay,
    })
    local blackOverlay = Create("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = sv,
    })
    Corner(blackOverlay, 5)
    Create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = blackOverlay,
    })
    local svKnob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(10, 10),
        ZIndex = 3,
        Parent = sv,
    })
    Corner(svKnob, 5)
    Create("UIStroke", {
        Color = Color3.new(0, 0, 0),
        Transparency = 0.35,
        Thickness = 1,
        Parent = svKnob,
    })

    -- hue cubugu
    local hueBar = Create("TextButton", {
        Name = "Hue",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 120),
        Size = UDim2.new(1, 0, 0, 10),
        Text = "",
        Parent = panel,
    })
    Corner(hueBar, 5)
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueBar,
    })
    local hueKnob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(12, 12),
        ZIndex = 3,
        Parent = hueBar,
    })
    Corner(hueKnob, 6)
    Create("UIStroke", {
        Color = Color3.new(0, 0, 0),
        Transparency = 0.35,
        Thickness = 1,
        Parent = hueKnob,
    })

    -- hex
    local hexBox = Create("Frame", {
        Name = "HexBox",
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(0, 142),
        Size = UDim2.fromOffset(100, 22),
        Parent = panel,
    })
    Corner(hexBox, 5)
    local hexStroke = Stroke(hexBox)
    local hexInput = Create("TextBox", {
        Name = "Hex",
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = F.Mono,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Text = "",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = hexBox,
    })

    window:_style(panel, function(theme)
        hexBox.BackgroundColor3 = theme.Elevated
        hexStroke.Color = theme.Border
        hexInput.TextColor3 = theme.Text
    end)

    local function current()
        return Color3.fromHSV(hue, sat, val)
    end

    local function render()
        local color = current()
        sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svKnob.Position = UDim2.fromScale(sat, 1 - val)
        hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
        swatch.BackgroundColor3 = color
        hexInput.Text = colorToHex(color)
    end

    local function commit()
        render()
        if config.Callback then
            task.spawn(config.Callback, current())
        end
    end

    local conns = {}
    local draggingSV, draggingHue = false, false

    local function setSV(position)
        local abs, size = sv.AbsolutePosition, sv.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then
            return
        end
        sat = math.clamp((position.X - abs.X) / size.X, 0, 1)
        val = 1 - math.clamp((position.Y - abs.Y) / size.Y, 0, 1)
        commit()
    end

    local function setHue(x)
        local abs, size = hueBar.AbsolutePosition, hueBar.AbsoluteSize
        if size.X <= 0 then
            return
        end
        hue = math.clamp((x - abs.X) / size.X, 0, 1)
        commit()
    end

    sv.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            setSV(input.Position)
        end
    end)
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            setHue(input.Position.X)
        end
    end)

    window:_connect(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if draggingSV then
                setSV(input.Position)
            elseif draggingHue then
                setHue(input.Position.X)
            end
        end
    end, conns)
    window:_connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = false
            draggingHue = false
        end
    end, conns)

    hexInput.FocusLost:Connect(function()
        local color = hexToColor(hexInput.Text)
        if color then
            hue, sat, val = color:ToHSV()
            commit()
        else
            render()
        end
    end)

    hit.MouseButton1Click:Connect(function()
        expanded = not expanded
        panel.Visible = expanded
    end)

    local api = {}

    function api:Get()
        return current()
    end
    function api:Set(color, silent)
        hue, sat, val = color:ToHSV()
        render()
        if not silent and config.Callback then
            task.spawn(config.Callback, current())
        end
    end
    function api:SetTitle(text)
        row.setTitle(text)
        api._searchTitle = text
    end
    function api:SetDescription(text)
        row.setDescription(text)
        api._searchDescription = text or ""
    end
    function api:Destroy()
        for _, connection in ipairs(conns) do
            connection:Disconnect()
        end
    end

    render()

    Tip(window, row.Row, config.Tooltip)

    return self:_register(api, {
        holder = holder,
        title = config.Title or "Color",
        description = config.Description,
        flag = config.Flag,
        kind = "colorpicker",
    })
end

--========================================================================--
-- COMPONENT: SEPARATOR / LABEL
--========================================================================--

function Category:AddSeparator(config)
    if type(config) == "string" then
        config = { Text = config }
    end
    config = config or {}
    local window = self._window
    local text = config.Text or ""

    local holder = Create("Frame", {
        Name = "Separator",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, text ~= "" and 22 or 9),
        Parent = self.Body,
    })

    local line = Create("Frame", {
        Name = "Line",
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(1, -16, 0, 1),
        Parent = holder,
    })
    window:_paint(line, "BackgroundColor3", "Border")

    local label = Label({
        Name = "Text",
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = F.Semi,
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.fromOffset(0, 14),
        Text = string.upper(text),
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.None,
        Visible = text ~= "",
        Parent = holder,
    })
    window:_paint(label, "TextColor3", "TextMuted")

    local function relayout()
        if label.Visible then
            local width = label.AbsoluteSize.X
            line.Position = UDim2.new(0, 16 + width, 0.5, 0)
            line.Size = UDim2.new(1, -(24 + width), 0, 1)
        else
            line.Position = UDim2.new(0, 8, 0.5, 0)
            line.Size = UDim2.new(1, -16, 0, 1)
        end
    end
    label:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
    relayout()

    local api = {}
    function api:SetText(newText)
        label.Text = string.upper(newText)
        label.Visible = newText ~= ""
        holder.Size = UDim2.new(1, 0, 0, newText ~= "" and 22 or 9)
        api._searchTitle = newText
        relayout()
    end

    return self:_register(api, { holder = holder, title = text })
end

Category.AddSeperator = Category.AddSeparator

function Category:AddLabel(config)
    if type(config) == "string" then
        config = { Text = config }
    end
    config = config or {}
    local window = self._window

    local label = Label({
        Name = "Label",
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Text = config.Text or "",
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.None,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = self.Body,
    })
    Pad(label, 6, 8)
    window:_paint(label, "TextColor3", "TextDim")

    local api = {}
    function api:SetText(text)
        label.Text = text
        api._searchTitle = text
    end
    function api:Get()
        return label.Text
    end

    return self:_register(api, { holder = label, title = config.Text or "" })
end

--========================================================================--
-- TOOLTIP
--========================================================================--

function Window:_ensureTooltip()
    if self._tooltip then
        return self._tooltip
    end

    local tip = Create("TextLabel", {
        Name = "Tooltip",
        AutomaticSize = Enum.AutomaticSize.XY,
        BorderSizePixel = 0,
        Font = F.Regular,
        Size = UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 12,
        Visible = false,
        ZIndex = 100,
        Parent = self.ScreenGui,
    })
    Corner(tip, 5)
    Pad(tip, 5, 8)
    local tipStroke = Stroke(tip)
    self:_style(tip, function(theme)
        tip.BackgroundColor3 = theme.Elevated
        tip.TextColor3 = theme.Text
        tipStroke.Color = theme.BorderHover
    end)

    self._tooltip = tip
    return tip
end

function Window:AttachTooltip(guiObject, text)
    local tip = self:_ensureTooltip()
    local lastX, lastY = 0, 0

    local function place(x, y)
        local viewport = self.ScreenGui.AbsoluteSize
        local width = tip.AbsoluteSize.X
        tip.Position = UDim2.fromOffset(
            math.max(4, math.min(x + 14, viewport.X - width - 8)),
            y + 18
        )
    end

    guiObject.MouseEnter:Connect(function(x, y)
        lastX, lastY = x, y
        self._tipToken += 1
        local token = self._tipToken
        task.delay(0.45, function()
            if token ~= self._tipToken or self._unloaded then
                return
            end
            tip.Text = text
            tip.Visible = true
            place(lastX, lastY)
        end)
    end)
    guiObject.MouseMoved:Connect(function(x, y)
        lastX, lastY = x, y
        if tip.Visible then
            place(x, y)
        end
    end)
    guiObject.MouseLeave:Connect(function()
        self._tipToken += 1
        tip.Visible = false
    end)
end

--========================================================================--
-- KEYBIND LIST
--========================================================================--

function Window:_registerKeybindEntry(title, get)
    local entry = { title = title, get = get }
    table.insert(self._keybindEntries, entry)
    self:_refreshKeybindList()
    return entry
end

function Window:_ensureKeybindList()
    if self._kbFrame then
        return self._kbFrame
    end

    local frame = Create("Frame", {
        Name = "KeybindList",
        AutomaticSize = Enum.AutomaticSize.XY,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        ZIndex = 50,
        Parent = self.ScreenGui,
    })
    Corner(frame, 6)
    Pad(frame, 8, 10)
    local frameStroke = Stroke(frame)
    self:_style(frame, function(theme)
        frame.BackgroundColor3 = theme.Sidebar
        frameStroke.Color = theme.Border
    end)
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame,
    })

    local header = Label({
        Name = "Header",
        AutomaticSize = Enum.AutomaticSize.X,
        Font = F.Semi,
        LayoutOrder = 0,
        Size = UDim2.fromOffset(0, 16),
        Text = "Keybinds",
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.None,
        Parent = frame,
    })
    self:_paint(header, "TextColor3", "Text")

    self._kbFrame = frame
    return frame
end

function Window:_refreshKeybindList()
    if not self._kbFrame then
        return
    end

    for _, child in ipairs(self._kbFrame:GetChildren()) do
        if child.Name == "Row" then
            child:Destroy()
        end
    end

    for index, entry in ipairs(self._keybindEntries) do
        local row = Create("Frame", {
            Name = "Row",
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Size = UDim2.fromOffset(0, 0),
            Parent = self._kbFrame,
        })
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = row,
        })
        local name = Label({
            AutomaticSize = Enum.AutomaticSize.XY,
            LayoutOrder = 1,
            Size = UDim2.fromOffset(0, 14),
            Text = entry.title,
            TextSize = 12,
            TextTruncate = Enum.TextTruncate.None,
            Parent = row,
        })
        self:_paint(name, "TextColor3", "TextDim")
        local key = Label({
            AutomaticSize = Enum.AutomaticSize.XY,
            Font = F.Mono,
            LayoutOrder = 2,
            Size = UDim2.fromOffset(0, 14),
            Text = entry.get(),
            TextSize = 11,
            TextTruncate = Enum.TextTruncate.None,
            Parent = row,
        })
        self:_paint(key, "TextColor3", "Accent")
    end
end

function Window:SetKeybindListVisible(visible)
    local frame = self:_ensureKeybindList()
    self:_refreshKeybindList()
    frame.Visible = visible == true
end

--========================================================================--
-- NOTIFICATIONS
--========================================================================--

function Window:Notify(config)
    if self._unloaded then
        return
    end
    if type(config) == "string" then
        config = { Content = config }
    end
    config = config or {}

    local theme = self._theme
    local duration = config.Duration or 4
    self._notifyOrder += 1

    local wrap = Create("Frame", {
        Name = "Notification",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = self._notifyOrder,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self._notifyHolder,
    })

    local card = Create("Frame", {
        Name = "Card",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, 40, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = wrap,
    })
    Corner(card, 6)
    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = theme.BorderHover,
        Parent = card,
    })

    local body = Create("Frame", {
        Name = "Body",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card,
    })

    local hasIcon = false
    if config.Icon then
        local iconLabel = Create("ImageLabel", {
            BackgroundTransparency = 1,
            ImageColor3 = theme.Accent,
            Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(16, 16),
            Parent = body,
        })
        hasIcon = ApplyIcon(iconLabel, config.Icon)
        iconLabel.Visible = hasIcon
    end

    Pad(body, 10, 12, 14, hasIcon and 36 or 12)
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })

    local title = Label({
        Name = "Title",
        Font = F.Semi,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Text = config.Title or "Notification",
        TextColor3 = theme.Text,
        Parent = body,
    })
    local content = Label({
        Name = "Content",
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 0),
        Text = config.Content or "",
        TextColor3 = theme.TextDim,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.None,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Visible = (config.Content or "") ~= "",
        Parent = body,
    })

    local timer = Create("Frame", {
        Name = "Timer",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -4),
        Size = UDim2.new(1, -20, 0, 2),
        Parent = card,
    })
    Corner(timer, 1)

    local clickArea = Create("TextButton", {
        Name = "Click",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5,
        Parent = card,
    })

    local dismissed = false
    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        Tween(card, { Position = UDim2.new(1, 40, 0, 0) }, true, T_FAST)
        task.delay(0.16, function()
            wrap:Destroy()
        end)
    end

    clickArea.MouseButton1Click:Connect(function()
        if config.Callback then
            task.spawn(config.Callback)
        end
        dismiss()
    end)

    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, true, T_MED)
    Tween(timer, { Size = UDim2.new(0, 0, 0, 2) }, true, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    task.delay(duration, dismiss)

    local api = {}
    function api:Close()
        dismiss()
    end
    function api:SetTitle(text)
        title.Text = text
    end
    function api:SetContent(text)
        content.Text = text
        content.Visible = text ~= ""
    end
    return api
end

--========================================================================--
-- WINDOW STATE
--========================================================================--

function Window:Show()
    self.ScreenGui.Enabled = true
    self.Main.Visible = true
end

function Window:Hide()
    self.Main.Visible = false
end

function Window:ToggleVisibility()
    if self.Main.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function Window:SetMinimized(state)
    state = state == true
    if self._minimized == state or self._maximized then
        return
    end
    self._minimized = state

    local main = self.Main
    if state then
        self._restoreSize = main.Size
        Tween(main, { Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, 36) }, true, T_MED)
    else
        Tween(main, { Size = self._restoreSize or main.Size }, true, T_MED)
    end
    self._resizeGrip.Visible = not state
end

function Window:SetMaximized(state)
    state = state == true
    if self._maximized == state or self._minimized then
        return
    end
    self._maximized = state

    local main = self.Main
    if state then
        self._restorePosition = main.Position
        self._restoreMaxSize = main.Size
        local viewport = self.ScreenGui.AbsoluteSize
        Tween(main, { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(viewport.X, viewport.Y) }, true, T_SLOW)
        self._mainCorner.CornerRadius = UDim.new(0, 0)
    else
        Tween(main, {
            Position = self._restorePosition or main.Position,
            Size = self._restoreMaxSize or main.Size,
        }, true, T_SLOW)
        self._mainCorner.CornerRadius = UDim.new(0, 8)
    end
    self._resizeGrip.Visible = not state
end

function Window:UnloadGui()
    if self._unloaded then
        return
    end
    self._unloaded = true

    for _, connection in ipairs(self._conns) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self._conns = {}

    self.ScreenGui:Destroy()
    self._notifyGui:Destroy()
end

Window.Destroy = Window.UnloadGui

--========================================================================--
-- CONFIG SYSTEM
--========================================================================--

local function canUseFiles()
    return typeof(writefile) == "function"
        and typeof(readfile) == "function"
        and typeof(isfile) == "function"
        and typeof(isfolder) == "function"
        and typeof(makefolder) == "function"
        and typeof(listfiles) == "function"
end

local function ensureFolder()
    if canUseFiles() and not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
end

function Window:_serializeFlags()
    local data = {}
    for flag, api in pairs(self._flags) do
        local ok, value = pcall(function()
            return api:Get()
        end)
        if ok and value ~= nil then
            local kind = api._configKind
            if typeof(value) == "EnumItem" then
                value = value.Name
            elseif typeof(value) == "Color3" then
                value = colorToHex(value)
            end
            data[flag] = { kind = kind, value = value }
        end
    end
    return data
end

function Window:ExportConfig()
    return HttpService:JSONEncode(self:_serializeFlags())
end

function Window:_applyConfigData(data)
    for flag, entry in pairs(data) do
        local api = self._flags[flag]
        if api and type(entry) == "table" then
            local value = entry.value
            if entry.kind == "keybind" and type(value) == "string" then
                local ok, key = pcall(function()
                    return Enum.KeyCode[value]
                end)
                value = ok and key or nil
            elseif entry.kind == "colorpicker" and type(value) == "string" then
                value = hexToColor(value)
            end
            if value ~= nil then
                pcall(function()
                    api:Set(value)
                end)
            end
        end
    end
end

function Window:ImportConfig(json)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    if not ok or type(data) ~= "table" then
        self:Notify({ Title = "Config", Content = "Invalid JSON.", Duration = 4 })
        return false
    end
    self:_applyConfigData(data)
    self:Notify({ Title = "Config", Content = "Config imported.", Duration = 3 })
    return true
end

function Window:SaveConfig(name)
    if not name or name == "" then
        self:Notify({ Title = "Config", Content = "Enter a config name first.", Duration = 4 })
        return false
    end

    local json = self:ExportConfig()

    if canUseFiles() then
        ensureFolder()
        local ok = pcall(writefile, CONFIG_FOLDER .. "/" .. name .. ".json", json)
        if not ok then
            self:Notify({ Title = "Config", Content = "Could not write the file.", Duration = 4 })
            return false
        end
    else
        self._memoryConfigs[name] = json
    end

    self:Notify({ Title = "Config", Content = 'Saved "' .. name .. '".', Duration = 3 })
    return true
end

function Window:LoadConfig(name)
    if not name or name == "" then
        self:Notify({ Title = "Config", Content = "Enter a config name first.", Duration = 4 })
        return false
    end

    local json = nil
    if canUseFiles() then
        local path = CONFIG_FOLDER .. "/" .. name .. ".json"
        if isfile(path) then
            local ok, result = pcall(readfile, path)
            if ok then
                json = result
            end
        end
    else
        json = self._memoryConfigs[name]
    end

    if not json then
        self:Notify({ Title = "Config", Content = 'Config "' .. name .. '" not found.', Duration = 4 })
        return false
    end

    return self:ImportConfig(json)
end

function Window:GetConfigs()
    local names = {}
    if canUseFiles() then
        ensureFolder()
        local ok, files = pcall(listfiles, CONFIG_FOLDER)
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = string.match(path, "([^/\\]+)%.json$")
                if name then
                    table.insert(names, name)
                end
            end
        end
    else
        for name in pairs(self._memoryConfigs) do
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

function Window:_copy(text, fallbackInput, label)
    if typeof(setclipboard) == "function" then
        setclipboard(text)
        self:Notify({ Title = label, Content = "Copied to clipboard.", Duration = 3 })
    else
        fallbackInput:Set(text, true)
        self:Notify({ Title = label, Content = "No clipboard access. JSON is in the input box.", Duration = 4 })
    end
end

--========================================================================--
-- SETTINGS PAGE
--========================================================================--

function Window:_buildSettings()
    local tab = self._settingsTab
    local pickers = {}
    self._themePickers = pickers

    -- sol kolon
    local appearance = tab:AddCategory({ Title = "Appearance", Side = "Left" })
    appearance:AddDropdown({
        Title = "Theme",
        Description = "Base color preset",
        Values = PRESET_ORDER,
        Default = "Default",
        Searchable = false,
        Callback = function(name)
            if name then
                self:SetThemePreset(name)
            end
        end,
    })
    pickers.Accent = appearance:AddColorPicker({
        Title = "Accent",
        Default = self._theme.Accent,
        Callback = function(color)
            self:SetAccent(color)
        end,
    })
    appearance:AddToggle({
        Title = "Keybind list",
        Description = "Show bound keys on screen",
        Callback = function(value)
            self:SetKeybindListVisible(value)
        end,
    })

    local custom = tab:AddCategory({ Title = "Custom colors", Side = "Left", Collapsed = true })
    for _, item in ipairs({
        { "Background", "Content" },
        { "Sidebar", "Window frame" },
        { "Surface", "Cards" },
        { "Text", "Text" },
    }) do
        local key = item[1]
        pickers[key] = custom:AddColorPicker({
            Title = item[2],
            Default = self._theme[key],
            Callback = function(color)
                self:SetThemeColor(key, color)
            end,
        })
    end
    custom:AddSeparator({ Text = "Share" })
    local themeJson = custom:AddInput({ Title = "Theme JSON", Placeholder = "{...}" })
    custom:AddButton({
        Title = "Import theme",
        Callback = function()
            self:ImportTheme(themeJson:Get())
        end,
    })
    custom:AddButton({
        Title = "Copy theme",
        Callback = function()
            self:_copy(self:ExportTheme(), themeJson, "Theme")
        end,
    })

    -- sag kolon
    local general = tab:AddCategory({ Title = "General", Side = "Right" })
    general:AddKeybind({
        Title = "Toggle UI",
        Description = "Show or hide the window",
        Default = Enum.KeyCode.RightShift,
        Flag = "Nexo_ToggleKey",
        Callback = function()
            self:ToggleVisibility()
        end,
    })
    self._toggleKeybind = general._components[#general._components]
    general:AddButton({
        Title = "Unload UI",
        Style = "Danger",
        Callback = function()
            self:UnloadGui()
        end,
    })

    local configs = tab:AddCategory({ Title = "Configs", Side = "Right" })
    local nameInput = configs:AddInput({ Title = "Name", Placeholder = "my-config" })
    local savedList
    savedList = configs:AddDropdown({
        Title = "Saved",
        Values = self:GetConfigs(),
        Searchable = false,
        Placeholder = "None",
        OnOpen = function()
            savedList:SetValues(self:GetConfigs())
        end,
        Callback = function(name)
            if name then
                nameInput:Set(name, true)
            end
        end,
    })
    configs:AddButton({
        Title = "Save",
        Style = "Primary",
        Callback = function()
            if self:SaveConfig(nameInput:Get()) then
                savedList:SetValues(self:GetConfigs())
            end
        end,
    })
    configs:AddButton({
        Title = "Load",
        Callback = function()
            self:LoadConfig(nameInput:Get())
        end,
    })

    local transfer = tab:AddCategory({ Title = "Import / Export", Side = "Right", Collapsed = true })
    local configJson = transfer:AddInput({ Title = "Config JSON", Placeholder = "{...}" })
    transfer:AddButton({
        Title = "Import",
        Callback = function()
            self:ImportConfig(configJson:Get())
        end,
    })
    transfer:AddButton({
        Title = "Copy config",
        Callback = function()
            self:_copy(self:ExportConfig(), configJson, "Config")
        end,
    })
end

--========================================================================--
-- LIBRARY ENTRY
--========================================================================--

function Nexo.CreateWindow(config)
    config = config or {}

    local self = setmetatable({}, Window)

    local theme = {}
    for key, value in pairs(Presets.Default) do
        theme[key] = value
    end
    local preset = config.Preset and Presets[config.Preset]
    if preset then
        for key, value in pairs(preset) do
            theme[key] = value
        end
    end
    if config.Theme then
        for key, value in pairs(config.Theme) do
            theme[LegacyKeys[key] or key] = value
        end
    end
    theme.AccentText = AccentTextFor(theme.Accent)

    self._theme = theme
    self._styles = {}
    self._conns = {}
    self._tabs = {}
    self._flags = {}
    self._toggleGroups = {}
    self._keybindEntries = {}
    self._memoryConfigs = {}
    self._notifyOrder = 0
    self._tipToken = 0
    self._themePickers = {}
    self._settingsOpen = false
    self._minimized = false
    self._maximized = false

    local guiParent = GetGuiParent()

    -- bildirimler
    local notifyGui = Create("ScreenGui", {
        Name = "NexoNotify",
        DisplayOrder = 101,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = guiParent,
    })
    local notifyHolder = Create("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -12, 1, -12),
        Size = UDim2.new(0, 280, 1, -24),
        Parent = notifyGui,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = notifyHolder,
    })
    self._notifyGui = notifyGui
    self._notifyHolder = notifyHolder

    -- ana pencere
    local screenGui = Create("ScreenGui", {
        Name = "NexoLib",
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = guiParent,
    })
    self.ScreenGui = screenGui

    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local width = config.Size and config.Size.X.Offset > 0 and config.Size.X.Offset or 640
    local height = config.Size and config.Size.Y.Offset > 0 and config.Size.Y.Offset or 420
    width = math.floor(math.clamp(width, 460, math.max(460, viewport.X - 40)))
    height = math.floor(math.clamp(height, 300, math.max(300, viewport.Y - 80)))

    local main = Create("Frame", {
        Name = "Main",
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0.5, -math.floor(width / 2), 0.5, -math.floor(height / 2)),
        Size = UDim2.fromOffset(width, height),
        Parent = screenGui,
    })
    local mainCorner = Corner(main, 8)
    local mainStroke = Stroke(main)
    self:_style(main, function(t)
        main.BackgroundColor3 = t.Sidebar
        mainStroke.Color = t.Border
    end)
    self.Main = main
    self._mainCorner = mainCorner

    -- topbar
    local topbar = Create("Frame", {
        Name = "Topbar",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = main,
    })

    local dragArea = Create("Frame", {
        Name = "Drag",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -110, 1, 0),
        Parent = topbar,
    })

    local logo = Create("ImageLabel", {
        Name = "Logo",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = dragArea,
    })
    self:_paint(logo, "ImageColor3", "Accent")
    local hasLogo = config.Icon ~= nil and ApplyIcon(logo, config.Icon)
    logo.Visible = hasLogo

    local titleLabel = Label({
        Name = "Title",
        Font = F.Semi,
        Position = UDim2.fromOffset(hasLogo and 38 or 14, 0),
        Size = UDim2.new(1, -(hasLogo and 38 or 14), 1, 0),
        Text = config.Title or "Nexo",
        Parent = dragArea,
    })
    self:_paint(titleLabel, "TextColor3", "Text")
    self.TitleLabel = titleLabel

    local controls = Create("Frame", {
        Name = "Controls",
        AnchorPoint = Vector2.new(1, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(0, 26),
        Parent = topbar,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = controls,
    })

    local function controlButton(kind, order, danger)
        local button = Create("TextButton", {
            Name = kind,
            BackgroundTransparency = 1,
            LayoutOrder = order,
            Size = UDim2.fromOffset(30, 26),
            Text = "",
            Parent = controls,
        })
        Corner(button, 5)
        local _, paint = Glyph[kind](button, 10)

        local hover = false
        local function render(animate)
            local t = self._theme
            Tween(button, {
                BackgroundTransparency = hover and 0 or 1,
                BackgroundColor3 = (danger and hover) and t.Danger or t.SurfaceHover,
            }, animate)
            if danger and hover then
                paint(Color3.new(1, 1, 1))
            else
                paint(hover and t.Text or t.TextDim)
            end
        end
        self:_style(button, function()
            render(false)
        end)
        button.MouseEnter:Connect(function() hover = true; render(true) end)
        button.MouseLeave:Connect(function() hover = false; render(true) end)
        return button
    end

    local minimizeButton = controlButton("minimize", 1, false)
    local maximizeButton = controlButton("maximize", 2, false)
    local closeButton = controlButton("close", 3, true)

    -- sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(0, 150, 1, -36),
        Parent = main,
    })

    local searchBox = Create("Frame", {
        Name = "Search",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 2),
        Size = UDim2.new(1, -18, 0, 28),
        Parent = sidebar,
    })
    Corner(searchBox, 6)
    local searchStroke = Stroke(searchBox)

    local magnifier, paintMagnifier = Glyph.search(searchBox, 12)
    magnifier.AnchorPoint = Vector2.new(0, 0.5)
    magnifier.Position = UDim2.new(0, 9, 0.5, 0)

    local searchInput = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = F.Regular,
        PlaceholderText = "Search",
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -46, 1, 0),
        Text = "",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = searchBox,
    })

    local clearButton = Create("TextButton", {
        Name = "Clear",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        Text = "",
        Visible = false,
        Parent = searchBox,
    })
    local _, paintClear = Glyph.close(clearButton, 7)

    self:_style(searchBox, function(t)
        searchBox.BackgroundColor3 = t.Elevated
        searchStroke.Color = searchInput:IsFocused() and t.Accent or t.Border
        searchInput.TextColor3 = t.Text
        searchInput.PlaceholderColor3 = t.TextMuted
        paintMagnifier(t.TextMuted)
        paintClear(t.TextDim)
    end)

    searchInput.Focused:Connect(function()
        Tween(searchStroke, { Color = self._theme.Accent })
    end)
    searchInput.FocusLost:Connect(function()
        Tween(searchStroke, { Color = self._theme.Border })
    end)
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        self:_runSearch()
    end)
    clearButton.MouseButton1Click:Connect(function()
        searchInput.Text = ""
    end)

    self._searchInput = searchInput
    self._searchClear = clearButton

    local navList = Create("ScrollingFrame", {
        Name = "Tabs",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Position = UDim2.fromOffset(0, 38),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, -86),
        Parent = sidebar,
    })
    Pad(navList, 4, 8)
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = navList,
    })
    self._navList = navList

    local settingsDivider = Create("Frame", {
        Name = "Divider",
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -44),
        Size = UDim2.new(1, -20, 0, 1),
        Parent = sidebar,
    })
    self:_paint(settingsDivider, "BackgroundColor3", "Border")

    local settingsHolder = Create("Frame", {
        Name = "SettingsHolder",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 1, -38),
        Size = UDim2.new(1, -16, 0, 30),
        Parent = sidebar,
    })
    self._settingsNav = self:_makeNavItem(settingsHolder, "Settings", "settings")

    -- icerik
    local content = Create("Frame", {
        Name = "Content",
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(150, 36),
        Size = UDim2.new(1, -158, 1, -44),
        Parent = main,
    })
    Corner(content, 8)
    local contentStroke = Stroke(content)
    self:_style(content, function(t)
        content.BackgroundColor3 = t.Background
        contentStroke.Color = t.Border
    end)
    self._content = content

    local noResults = Label({
        Name = "NoResults",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -40, 0, 20),
        Text = "No results",
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = content,
    })
    self:_paint(noResults, "TextColor3", "TextMuted")
    self._noResults = noResults

    -- resize tutamagi
    local grip = Create("TextButton", {
        Name = "Resize",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.fromOffset(16, 16),
        Text = "",
        ZIndex = 10,
        Parent = main,
    })
    local gripGlyph, paintGrip = Glyph.grip(grip, 8)
    gripGlyph.Position = UDim2.new(0.5, 1, 0.5, 1)
    self:_style(grip, function(t)
        paintGrip(t.TextMuted)
    end)
    self._resizeGrip = grip

    -- ayarlar sayfasi
    self._settingsTab = self:_newPage()
    self._settingsNav.button.MouseButton1Click:Connect(function()
        self._settingsOpen = not self._settingsOpen
        self:_refreshPages()
    end)

    --====================================================================--
    -- Pencere davranislari
    --====================================================================--

    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
        local key = self._toggleKeybind and self._toggleKeybind:Get()
        if key then
            self:Notify({
                Title = "UI hidden",
                Content = "Press " .. (KeyNames[key] or key.Name) .. " to bring it back.",
                Duration = 4,
            })
        end
    end)
    minimizeButton.MouseButton1Click:Connect(function()
        self:SetMinimized(not self._minimized)
    end)
    maximizeButton.MouseButton1Click:Connect(function()
        self:SetMaximized(not self._maximized)
    end)

    -- surukleme (+ cift tik = maximize)
    do
        local dragging = false
        local dragStart, startPosition
        local lastClick = 0

        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            local now = os.clock()
            if now - lastClick < 0.35 then
                lastClick = 0
                self:SetMaximized(not self._maximized)
                return
            end
            lastClick = now

            if self._maximized then
                return
            end
            dragging = true
            dragStart = input.Position
            startPosition = main.AbsolutePosition
        end)

        self:_connect(UserInputService.InputChanged, function(input)
            if not dragging then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                local screen = screenGui.AbsoluteSize
                local size = main.AbsoluteSize
                local x = math.clamp(startPosition.X + delta.X, 80 - size.X, screen.X - 80)
                local y = math.clamp(startPosition.Y + delta.Y, 0, screen.Y - 36)
                main.Position = UDim2.fromOffset(x, y)
            end
        end)

        self:_connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- boyutlandirma
    do
        local resizing = false
        local resizeStart, startSize

        grip.InputBegan:Connect(function(input)
            if self._minimized or self._maximized then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = input.Position
                startSize = main.AbsoluteSize
            end
        end)

        self:_connect(UserInputService.InputChanged, function(input)
            if not resizing then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - resizeStart
                local screen = screenGui.AbsoluteSize
                local position = main.AbsolutePosition
                local newX = math.clamp(startSize.X + delta.X, 460, math.max(460, screen.X - position.X))
                local newY = math.clamp(startSize.Y + delta.Y, 300, math.max(300, screen.Y - position.Y))
                main.Size = UDim2.fromOffset(newX, newY)
            end
        end)

        self:_connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)
    end

    self:_buildSettings()
    self:_refreshPages()

    function self.GetSettingsTab()
        return self._settingsTab
    end

    return self
end

return Nexo
