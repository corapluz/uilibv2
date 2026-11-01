--========================================================================--
--  NEXO UI v2.2
--
--  Ayni iskelet: ust tab'lar, topbar'da ayarlar, iki kolon, kategori kartlari.
--  Gorunum: duz koyu tema, kartlarda 1px cizgiyle ayrilmis satirlar,
--  buton / input'larda cok hafif gradient, tek font (Highway), resim ikonlar.
--  Kilit (Lock) ozelligi, pop / bounce animasyonlari, accent parlamasi yok.
--========================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local Nexo = {}
Nexo.__index = Nexo
Nexo.Version = "2.2.0"

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
    "Accent", "Window", "Surface", "Header", "Element", "ElementHover", "RowHover",
    "Border", "Divider", "Text", "TextDim", "TextMuted", "Danger",
}

-- Window (icerik zemini) < Surface (kart) < Header < Element (buton / input, ustten gradient ile)
local Presets = {
    Dark = {
        Accent = rgb(119, 147, 217),
        Window = rgb(21, 23, 25),
        Surface = rgb(26, 28, 31),
        Header = rgb(29, 31, 35),
        Element = rgb(42, 45, 50),
        ElementHover = rgb(51, 55, 61),
        RowHover = rgb(29, 31, 35),
        Border = rgb(37, 40, 44),
        Divider = rgb(37, 40, 44),
        Text = rgb(224, 232, 236),
        TextDim = rgb(128, 133, 141),
        TextMuted = rgb(84, 88, 95),
        Danger = rgb(218, 98, 98),
    },
    Midnight = {
        Accent = rgb(128, 116, 240),
        Window = rgb(14, 15, 26),
        Surface = rgb(20, 22, 37),
        Header = rgb(24, 26, 43),
        Element = rgb(36, 39, 62),
        ElementHover = rgb(45, 49, 76),
        RowHover = rgb(24, 26, 43),
        Border = rgb(36, 39, 62),
        Divider = rgb(36, 39, 62),
        Text = rgb(228, 230, 248),
        TextDim = rgb(138, 142, 180),
        TextMuted = rgb(90, 94, 128),
        Danger = rgb(218, 98, 98),
    },
    Amoled = {
        Accent = rgb(108, 160, 240),
        Window = rgb(0, 0, 0),
        Surface = rgb(11, 11, 12),
        Header = rgb(16, 16, 18),
        Element = rgb(30, 31, 34),
        ElementHover = rgb(40, 41, 45),
        RowHover = rgb(16, 16, 18),
        Border = rgb(30, 31, 34),
        Divider = rgb(30, 31, 34),
        Text = rgb(236, 238, 240),
        TextDim = rgb(138, 140, 146),
        TextMuted = rgb(88, 90, 95),
        Danger = rgb(218, 98, 98),
    },
    Ocean = {
        Accent = rgb(78, 158, 226),
        Window = rgb(11, 17, 24),
        Surface = rgb(16, 24, 34),
        Header = rgb(19, 29, 41),
        Element = rgb(33, 47, 64),
        ElementHover = rgb(42, 58, 78),
        RowHover = rgb(19, 29, 41),
        Border = rgb(30, 43, 58),
        Divider = rgb(30, 43, 58),
        Text = rgb(222, 234, 245),
        TextDim = rgb(132, 152, 174),
        TextMuted = rgb(86, 104, 124),
        Danger = rgb(218, 98, 98),
    },
    Crimson = {
        Accent = rgb(214, 92, 108),
        Window = rgb(22, 20, 21),
        Surface = rgb(28, 25, 26),
        Header = rgb(32, 28, 29),
        Element = rgb(48, 42, 44),
        ElementHover = rgb(58, 51, 54),
        RowHover = rgb(32, 28, 29),
        Border = rgb(42, 37, 39),
        Divider = rgb(42, 37, 39),
        Text = rgb(236, 230, 231),
        TextDim = rgb(146, 138, 140),
        TextMuted = rgb(98, 91, 93),
        Danger = rgb(236, 120, 120),
    },
    Light = {
        Accent = rgb(78, 108, 214),
        Window = rgb(238, 240, 243),
        Surface = rgb(250, 251, 252),
        Header = rgb(243, 244, 247),
        Element = rgb(255, 255, 255),
        ElementHover = rgb(244, 246, 250),
        RowHover = rgb(243, 244, 247),
        Border = rgb(217, 221, 228),
        Divider = rgb(225, 228, 234),
        Text = rgb(26, 30, 36),
        TextDim = rgb(98, 105, 116),
        TextMuted = rgb(148, 154, 164),
        Danger = rgb(200, 62, 62),
    },
}

local PRESET_ORDER = { "Dark", "Midnight", "Amoled", "Ocean", "Crimson", "Light" }

-- v2.0 tema anahtarlari -> yeniler
local LegacyKeys = {
    WindowBackground = "Window",
    TabBackground = "Window",
    CategoryBackground = "Surface",
    CategoryTopBar = "Header",
    PrimaryText = "Text",
    SecondaryText = "TextDim",
    TitleText = "Text",
    ToggleActive = "Accent",
    Stroke = "Border",
    MainStroke = "Border",
}

local function luminance(color)
    return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
end

local function AccentTextFor(color)
    if luminance(color) > 0.6 then
        return rgb(14, 16, 20)
    end
    return rgb(255, 255, 255)
end

-- acik temada gradient neredeyse hissedilmez, koyuda hafif
local function GradientDepth(theme)
    return luminance(theme.Window) > 0.5 and 0.05 or 0.2
end

--========================================================================--
-- CONSTANTS
--========================================================================--

local F = {
    Main = Enum.Font.Highway,
    Mono = Enum.Font.RobotoMono,
    Glyph = Enum.Font.GothamMedium,
}

local T_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_MED = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_SLOW = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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

-- Olculer (px)
local TOPBAR_HEIGHT = 36
local CARD_RADIUS = 7
local WINDOW_RADIUS = 10
local HEADER_HEIGHT = 35
local ROW_HEIGHT = 31 -- 1px ayirici + 30px icerik
local TITLE_SIZE = 14
local SMALL_SIZE = 12

-- Asset ikonlari (offline calisir). Lucide isimleri lucide.lua uzerinden cozulur.
local ICON_CHEVRON = 10709790948
local ICON_SEARCH = 10734943674
local ICON_CLEAR = 10723346158
local ICON_SETTINGS = 10734950309
local ICON_MAXIMIZE = 10734896465

local CONFIG_FOLDER = "NexoUI"

--========================================================================--
-- HELPERS
--========================================================================--

local function setProp(instance, key, value)
    instance[key] = value
end

-- Property'leri uygular, Parent'i en son atar. Desteklenmeyen property uyari verir, kirmaz.
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

-- Pad(p, hepsi) | Pad(p, ust, sag, alt, sol)
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
        Font = F.Main,
        TextSize = TITLE_SIZE,
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

-- Mouse konumu (ScreenGui koordinatinda, inset dusulmus)
local function mouseXY()
    local location = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    return location.X - inset.X, location.Y - inset.Y
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

local function IconLabel(parent, icon, size)
    local label = Create("ImageLabel", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        Parent = parent,
    })
    if icon ~= nil then
        ApplyIcon(label, icon)
    end
    return label
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

-- fn(theme) hem simdi hem her tema degisiminde calisir
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

-- Ustten alta cok hafif koyulasan gradient (buton, input, slider dolgusu...)
function Window:_gradient(instance, strength)
    local gradient = Create("UIGradient", { Rotation = 90, Parent = instance })
    self:_style(gradient, function(theme)
        local factor = 1 - GradientDepth(theme) * (strength or 1)
        gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(factor, factor, factor))
    end)
    return gradient
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
    for key, picker in pairs(self._themePickers) do
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
    if name == "Default" then
        name = "Dark"
    end
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
-- WINDOW: TABS / PAGES
--========================================================================--

function Window:_makeTabButton(title, icon)
    local item = { active = false, hover = false }

    local button = Create("TextButton", {
        Name = "Tab",
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        Font = F.Main,
        LayoutOrder = #self._tabs + 1,
        Size = UDim2.new(0, 0, 0, 30),
        Text = title,
        TextSize = TITLE_SIZE,
        Parent = self._tabList,
    })
    Corner(button, 6)
    local stroke = Stroke(button)
    local padding = Pad(button, 0, 12, 0, 12)

    local iconLabel = IconLabel(button, nil, 16)
    iconLabel.Position = UDim2.new(0, 19, 0.5, 0)
    iconLabel.Visible = false

    local function layout(hasIcon)
        iconLabel.Visible = hasIcon
        padding.PaddingLeft = UDim.new(0, hasIcon and 34 or 12)
    end
    layout(icon ~= nil and ApplyIcon(iconLabel, icon))

    local function render(animate)
        local theme = self._theme
        local color = item.active and theme.Text or (item.hover and theme.Text or theme.TextDim)
        Tween(button, {
            BackgroundTransparency = (item.active or item.hover) and 0 or 1,
            BackgroundColor3 = item.active and theme.Header or theme.RowHover,
            TextColor3 = color,
        }, animate)
        Tween(stroke, {
            Transparency = item.active and 0 or 1,
            Color = theme.Border,
        }, animate)
        iconLabel.ImageColor3 = item.active and theme.Accent or color
    end
    self:_style(button, function()
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

    item.button = button
    function item.SetActive(value)
        item.active = value
        render(true)
    end
    function item.SetTitle(text)
        button.Text = text
    end
    function item.SetIcon(newIcon)
        layout(ApplyIcon(iconLabel, newIcon))
    end

    return item
end

function Window:_buildPage()
    local tab = setmetatable({}, Tab)
    tab._window = self
    tab._categories = {}
    tab._order = 0

    local page = Create("ScrollingFrame", {
        Name = "Page",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = self._tabHolder,
    })
    Pad(page, 2, 6, 4, 2)
    self:_style(page, function(theme)
        page.ScrollBarImageColor3 = theme.Border
    end)

    local columns = Create("Frame", {
        Name = "Columns",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = page,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = columns,
    })

    local function column(order)
        local frame = Create("Frame", {
            Name = "Column",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = order,
            Size = UDim2.new(0.5, -5, 0, 0),
            Parent = columns,
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = frame,
        })
        return frame
    end

    tab.Root = page
    tab.Section1 = column(1)
    tab.Section2 = column(2)

    return tab
end

function Window:_refreshPages()
    for _, tab in ipairs(self._tabs) do
        local on = (not self._settingsOpen) and tab == self._activeTab
        tab.Root.Visible = on
        tab._nav.SetActive(on)
    end
    self._settingsTab.Root.Visible = self._settingsOpen
    self._settingsButtonRender(true)
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

    local tab = self:_buildPage()
    tab._nav = self:_makeTabButton(config.Title or "Tab", config.Icon)
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

--========================================================================--
-- TAB: CATEGORY
--========================================================================--

function Tab:AddCategory(config)
    config = config or {}
    if type(config) == "string" then
        config = { Title = config }
    end

    local window = self._window
    local side = config.Side == "Right" and "Right" or "Left"
    local column = side == "Right" and self.Section2 or self.Section1

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
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        LayoutOrder = self._order,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = column,
    })
    Corner(root, CARD_RADIUS)
    local rootStroke = Stroke(root)
    window:_style(root, function(theme)
        root.BackgroundColor3 = theme.Surface
        rootStroke.Color = theme.Border
    end)
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = root })

    -- header: kapaliyken tamamen yuvarlak, aciksa alt kosesi duz (fill ile)
    local header = Create("Frame", {
        Name = "Header",
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
        Parent = root,
    })
    Corner(header, CARD_RADIUS)
    local headerFill = Create("Frame", {
        Name = "Fill",
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, CARD_RADIUS + 1),
        Parent = header,
    })
    window:_style(header, function(theme)
        header.BackgroundColor3 = theme.Header
        headerFill.BackgroundColor3 = theme.Header
    end)

    local iconLabel = IconLabel(header, nil, 16)
    iconLabel.Position = UDim2.new(0, 19, 0.5, 0)
    iconLabel.Visible = false
    window:_paint(iconLabel, "ImageColor3", "Text")

    local iconSeparator = Create("Frame", {
        Name = "IconSeparator",
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 36, 0.5, 0),
        Size = UDim2.fromOffset(1, 14),
        Visible = false,
        Parent = header,
    })
    window:_paint(iconSeparator, "BackgroundColor3", "Border")

    local titleLabel = Label({
        Name = "Title",
        Text = category._title,
        Parent = header,
    })
    window:_paint(titleLabel, "TextColor3", "Text")

    local chevron = IconLabel(header, ICON_CHEVRON, 14)
    chevron.Position = UDim2.new(1, -18, 0.5, 0)
    window:_paint(chevron, "ImageColor3", "TextDim")

    local function layoutHeader(hasIcon)
        iconLabel.Visible = hasIcon
        iconSeparator.Visible = hasIcon
        local x = hasIcon and 48 or 11
        titleLabel.AnchorPoint = Vector2.new(0, 0.5)
        titleLabel.Position = UDim2.new(0, x, 0.5, 0)
        titleLabel.Size = UDim2.new(1, -(x + 36), 0, 18)
    end
    layoutHeader(config.Icon ~= nil and ApplyIcon(iconLabel, config.Icon))

    local headerHit = Create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        ZIndex = 3,
        Parent = header,
    })

    local body = Create("Frame", {
        Name = "Body",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = root,
    })
    Pad(body, 0, 0, 3, 0)
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })

    category.Root = root
    category.Header = header
    category.Body = body
    category._headerFill = headerFill
    category._chevron = chevron
    category._titleLabel = titleLabel
    category._iconLabel = iconLabel
    category._layoutHeader = layoutHeader

    headerHit.MouseButton1Click:Connect(function()
        category:SetCollapsed(not category._collapsed)
    end)

    table.insert(self._categories, category)
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
    self._headerFill.Visible = open
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

function Category:Destroy()
    removeValue(self._tab._categories, self)
    self.Root:Destroy()
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
-- ROW BUILDERS
--========================================================================--

-- Kartin icindeki her satir: en ustte 1px ayirici cizgi, hover'da hafif zemin
local function BuildHolder(window, parent, height)
    local holder = Create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height),
        Parent = parent,
    })
    window:_paint(holder, "BackgroundColor3", "RowHover")

    local divider = Create("Frame", {
        Name = "Divider",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
        Parent = holder,
    })
    window:_paint(divider, "BackgroundColor3", "Divider")

    return holder
end

-- reserve: sag tarafta kontrole ayrilan genislik
-- extra: kontrol icin ek yukseklik (slider = 15, input / dropdown = 31)
local function BuildRow(window, parent, title, description, reserve, extra)
    extra = extra or 0

    local row = BuildHolder(window, parent, ROW_HEIGHT)

    local titleLabel = Label({
        Name = "Title",
        Size = UDim2.new(1, -(reserve + 12), 0, 16),
        Text = title,
        Parent = row,
    })
    window:_paint(titleLabel, "TextColor3", "Text")

    local descLabel = Label({
        Name = "Description",
        Size = UDim2.new(1, -(reserve + 12), 0, 14),
        Text = description or "",
        TextSize = SMALL_SIZE,
        Parent = row,
    })
    window:_paint(descLabel, "TextColor3", "TextDim")

    local obj = { Row = row, Title = titleLabel, Desc = descLabel, rightControls = {} }
    local hoverCount = 0

    function obj.layout()
        local hasDesc = descLabel.Text ~= ""
        local height = (hasDesc and 43 or ROW_HEIGHT) + extra
        row.Size = UDim2.new(1, 0, 0, height)

        if hasDesc or extra > 0 then
            titleLabel.AnchorPoint = Vector2.new(0, 0)
            titleLabel.Position = UDim2.fromOffset(6, 7)
        else
            titleLabel.AnchorPoint = Vector2.new(0, 0.5)
            titleLabel.Position = UDim2.fromOffset(6, 16)
        end

        descLabel.Visible = hasDesc
        descLabel.Position = UDim2.fromOffset(6, 23)

        -- sagdaki kontroller icerigin ortasina hizalanir
        local centerY = math.floor((height + 1) / 2)
        for _, entry in ipairs(obj.rightControls) do
            entry.control.Position = UDim2.new(1, -entry.margin, 0, centerY)
        end

        if obj.onLayout then
            obj.onLayout(hasDesc)
        end
    end

    function obj.placeRight(control, margin)
        control.AnchorPoint = Vector2.new(1, 0.5)
        table.insert(obj.rightControls, { control = control, margin = margin })
        obj.layout()
    end

    obj.layout()

    -- hover sayaci: ust uste binen overlay'lerde flicker olmasin
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

-- Buton / input / chip gibi "kabartmali" kutular: Element rengi + hafif gradient + 1px cizgi
local function StyleElement(window, frame, stroke, hoverState)
    window:_gradient(frame)
    window:_style(frame, function(theme)
        local color = theme.Element
        if hoverState and hoverState.hover then
            color = theme.ElementHover
        end
        frame.BackgroundColor3 = color
        stroke.Color = theme.Border
    end)
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

    local holder = BuildHolder(window, self.Body, hasDesc and 55 or 39)

    local button = Create("TextButton", {
        Name = "Button",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(6, 7),
        Size = UDim2.new(1, -12, 1, -13),
        Text = "",
        Parent = holder,
    })
    Corner(button, 5)
    local stroke = Stroke(button)
    window:_gradient(button)

    local titleLabel = Label({
        Name = "Title",
        Text = config.Title or "Button",
        TextSize = 13,
        Parent = button,
    })
    local descLabel = Label({
        Name = "Description",
        Position = UDim2.fromOffset(10, 22),
        Size = UDim2.new(1, -20, 0, 14),
        Text = config.Description or "",
        TextSize = SMALL_SIZE,
        Parent = button,
    })

    local iconLabel = IconLabel(button, nil, 16)
    iconLabel.Position = UDim2.new(1, -18, 0.5, 0)
    iconLabel.Visible = false
    local hasIcon = config.Icon ~= nil and ApplyIcon(iconLabel, config.Icon)
    iconLabel.Visible = hasIcon

    local function layout()
        local desc = descLabel.Text ~= ""
        holder.Size = UDim2.new(1, 0, 0, desc and 55 or 39)
        descLabel.Visible = desc
        local rightPad = hasIcon and 34 or 20
        if desc then
            titleLabel.AnchorPoint = Vector2.new(0, 0)
            titleLabel.Position = UDim2.fromOffset(10, 5)
            titleLabel.Size = UDim2.new(1, -rightPad, 0, 16)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        else
            titleLabel.AnchorPoint = Vector2.new(0, 0.5)
            titleLabel.Position = UDim2.new(0, 10, 0.5, 0)
            titleLabel.Size = UDim2.new(1, -rightPad, 0, 16)
            titleLabel.TextXAlignment = hasIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
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
            if hover then bg = bg:Lerp(Color3.new(1, 1, 1), 0.1) end
            if down then bg = bg:Lerp(Color3.new(0, 0, 0), 0.15) end
        else
            bg = theme.Element
            border = theme.Border
            text = style == "Danger" and theme.Danger or theme.Text
            if hover then bg = theme.ElementHover end
            if down then bg = theme.Surface end
        end
        Tween(button, { BackgroundColor3 = bg }, animate)
        Tween(stroke, { Color = border }, animate)
        titleLabel.TextColor3 = text
        descLabel.TextColor3 = style == "Primary" and text or theme.TextDim
        iconLabel.ImageColor3 = text
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
    function api:SetIcon(icon)
        hasIcon = ApplyIcon(iconLabel, icon)
        iconLabel.Visible = hasIcon
        layout()
    end

    return self:_register(api, {
        holder = holder,
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

    local row = BuildRow(window, self.Body, config.Title or "Toggle", config.Description, 40)

    local track = Create("Frame", {
        Name = "Switch",
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(26, 15),
        Parent = row.Row,
    })
    Corner(track, 8)
    local trackStroke = Stroke(track)
    window:_gradient(track, 0.8)
    row.placeRight(track, 7)

    local knob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(9, 9),
        Parent = track,
    })
    Corner(knob, 5)

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
        Tween(track, { BackgroundColor3 = state and theme.Accent or theme.Element }, animate)
        Tween(trackStroke, { Color = state and theme.Accent or theme.Border }, animate)
        Tween(knob, {
            Position = state and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = state and Color3.new(1, 1, 1) or theme.TextMuted,
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

    local row = BuildRow(window, self.Body, config.Title or "Slider", config.Description, 64, 15)

    local valueLabel = Label({
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(1, -7, 0, 7),
        Size = UDim2.fromOffset(0, 16),
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row.Row,
    })
    window:_paint(valueLabel, "TextColor3", "TextDim")

    local track = Create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 7, 1, -7),
        Size = UDim2.new(1, -14, 0, 8),
        Parent = row.Row,
    })
    Corner(track, 4)
    local trackStroke = Stroke(track)

    local fill = Create("Frame", {
        Name = "Fill",
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    Corner(fill, 4)
    window:_gradient(fill, 0.8)

    local knob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(236, 238, 242),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(13, 13),
        ZIndex = 2,
        Parent = track,
    })
    Corner(knob, 7)

    window:_style(track, function(theme)
        track.BackgroundColor3 = theme.Surface
        trackStroke.Color = theme.Border
        fill.BackgroundColor3 = theme.Accent
    end)

    local hit = Create("TextButton", {
        Name = "Hit",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 24),
        Text = "",
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

    local row = BuildRow(window, self.Body, config.Title or "Input", config.Description, 0, 31)

    local box = Create("Frame", {
        Name = "Box",
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0, 6, 1, -7),
        Size = UDim2.new(1, -12, 0, 26),
        Parent = row.Row,
    })
    Corner(box, 5)
    local boxStroke = Stroke(box)
    window:_gradient(box)

    local textBox = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        ClearTextOnFocus = config.ClearOnFocus == true,
        Font = F.Main,
        PlaceholderText = config.Placeholder or "",
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -18, 1, 0),
        Text = config.Default or "",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })

    window:_style(box, function(theme)
        box.BackgroundColor3 = theme.Element
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

    local row = BuildRow(window, self.Body, config.Title or "Keybind", config.Description, 70)

    local chip = Create("TextButton", {
        Name = "Key",
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        Font = F.Mono,
        Size = UDim2.fromOffset(0, 22),
        Text = "",
        TextSize = 11,
        Parent = row.Row,
    })
    Corner(chip, 5)
    Pad(chip, 0, 9)
    Create("UISizeConstraint", { MinSize = Vector2.new(38, 22), Parent = chip })
    local chipStroke = Stroke(chip)
    window:_gradient(chip)
    row.placeRight(chip, 7)

    local currentKey = config.Default or Enum.KeyCode.K
    local listening = false

    local function keyLabel(key)
        return KeyNames[key] or key.Name
    end

    local function render()
        local theme = window._theme
        chip.Text = listening and "..." or keyLabel(currentKey)
        chip.TextColor3 = listening and theme.Accent or theme.TextDim
        chip.BackgroundColor3 = theme.Element
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
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Body,
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

    local row = BuildRow(window, holder, config.Title or "Dropdown", config.Description, 0, 31)
    row.Row.LayoutOrder = 1

    local box = Create("Frame", {
        Name = "Value",
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 6, 1, -7),
        Size = UDim2.new(1, -12, 0, 26),
        Parent = row.Row,
    })
    Corner(box, 5)
    local boxStroke = Stroke(box)
    window:_gradient(box)

    local valueLabel = Label({
        Name = "Text",
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -34, 1, 0),
        TextSize = 13,
        Parent = box,
    })

    local chevron = IconLabel(box, ICON_CHEVRON, 14)
    chevron.Position = UDim2.new(1, -16, 0.5, 0)
    window:_paint(chevron, "ImageColor3", "TextDim")

    local hit = Create("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = row.Row,
    })
    row.watch(hit)

    local panelWrap = Create("Frame", {
        Name = "PanelWrap",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 60),
        Visible = false,
        Parent = holder,
    })
    local panel = Create("Frame", {
        Name = "Panel",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(6, 0),
        Size = UDim2.new(1, -12, 1, -7),
        Parent = panelWrap,
    })
    Corner(panel, 5)
    local panelStroke = Stroke(panel)
    Pad(panel, 3)
    Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = panel,
    })

    local searchBox = nil
    if searchable then
        searchBox = Create("TextBox", {
            Name = "Search",
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Font = F.Main,
            LayoutOrder = 1,
            PlaceholderText = "Search...",
            Size = UDim2.new(1, 0, 0, 24),
            Text = "",
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = panel,
        })
        Corner(searchBox, 4)
        Pad(searchBox, 0, 8)
    end

    local scroller = Create("ScrollingFrame", {
        Name = "Options",
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        LayoutOrder = 2,
        ScrollBarThickness = 2,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = panel,
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroller })

    local emptyLabel = Label({
        Name = "Empty",
        LayoutOrder = 0,
        Size = UDim2.new(1, 0, 0, 24),
        Text = "No results",
        TextSize = SMALL_SIZE,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = scroller,
    })

    window:_style(holder, function(theme)
        box.BackgroundColor3 = theme.Element
        boxStroke.Color = expanded and theme.Accent or theme.Border
        panel.BackgroundColor3 = theme.Window
        panelStroke.Color = theme.Border
        scroller.ScrollBarImageColor3 = theme.Border
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
        local height = count == 0 and 24 or math.min(count * 25, 125)
        scroller.Size = UDim2.new(1, 0, 0, height)
        local panelHeight = 6 + (searchBox and 27 or 0) + height
        panelWrap.Size = UDim2.new(1, 0, 0, panelHeight + 7)
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
        option.button.BackgroundColor3 = theme.Element
        Tween(option.button, { BackgroundTransparency = option.hover and 0 or 1 }, animate)
        option.label.TextColor3 = isSelected and theme.Accent or (option.hover and theme.Text or theme.TextDim)
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
                Size = UDim2.new(1, 0, 0, 25),
                Text = "",
                Parent = scroller,
            })
            Corner(button, 4)
            local label = Label({
                Position = UDim2.fromOffset(8, 0),
                Size = UDim2.new(1, -28, 1, 0),
                Text = value,
                TextSize = 13,
                Parent = button,
            })
            local dot = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -9, 0.5, 0),
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
        panelWrap.Visible = state
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
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Body,
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

    local row = BuildRow(window, holder, config.Title or "Color", config.Description, 44)
    row.Row.LayoutOrder = 1

    local swatch = Create("Frame", {
        Name = "Swatch",
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(26, 15),
        Parent = row.Row,
    })
    Corner(swatch, 4)
    local swatchStroke = Stroke(swatch)
    window:_paint(swatchStroke, "Color", "Border")
    row.placeRight(swatch, 7)

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
        Size = UDim2.new(1, 0, 0, 163),
        Visible = false,
        Parent = holder,
    })
    local inner = Create("Frame", {
        Name = "Inner",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(6, 1),
        Size = UDim2.new(1, -12, 1, -8),
        Parent = panel,
    })

    -- saturation / value alani
    local sv = Create("TextButton", {
        Name = "SV",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 104),
        Text = "",
        Parent = inner,
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
        Size = UDim2.fromOffset(11, 11),
        ZIndex = 3,
        Parent = sv,
    })
    Corner(svKnob, 6)
    Create("UIStroke", {
        Color = Color3.new(0, 0, 0),
        Thickness = 1,
        Transparency = 0.45,
        Parent = svKnob,
    })

    -- hue cubugu
    local hueBar = Create("TextButton", {
        Name = "Hue",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 112),
        Size = UDim2.new(1, 0, 0, 9),
        Text = "",
        Parent = inner,
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
        Size = UDim2.fromOffset(13, 13),
        ZIndex = 3,
        Parent = hueBar,
    })
    Corner(hueKnob, 7)
    Create("UIStroke", {
        Color = Color3.new(0, 0, 0),
        Thickness = 1,
        Transparency = 0.45,
        Parent = hueKnob,
    })

    -- hex
    local hexBox = Create("Frame", {
        Name = "HexBox",
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(0, 130),
        Size = UDim2.fromOffset(104, 24),
        Parent = inner,
    })
    Corner(hexBox, 5)
    local hexStroke = Stroke(hexBox)
    window:_gradient(hexBox)
    local hexInput = Create("TextBox", {
        Name = "Hex",
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = F.Mono,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -18, 1, 0),
        Text = "",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = hexBox,
    })

    window:_style(panel, function(theme)
        hexBox.BackgroundColor3 = theme.Element
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

    local holder = BuildHolder(window, self.Body, 27)

    local label = Label({
        Name = "Text",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0, 15),
        Size = UDim2.new(1, -12, 0, 14),
        Text = string.upper(text),
        TextSize = 11,
        Parent = holder,
    })
    window:_paint(label, "TextColor3", "TextMuted")

    local api = {}
    function api:SetText(newText)
        label.Text = string.upper(newText)
        api._searchTitle = newText
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

    local holder = BuildHolder(window, self.Body, ROW_HEIGHT)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.Size = UDim2.new(1, 0, 0, 0)

    local label = Label({
        Name = "Text",
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Text = config.Text or "",
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.None,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = holder,
    })
    Pad(label, 9, 6, 8, 6)
    window:_paint(label, "TextColor3", "TextDim")

    local api = {}
    function api:SetText(text)
        label.Text = text
        api._searchTitle = text
    end
    function api:Get()
        return label.Text
    end

    return self:_register(api, { holder = holder, title = config.Text or "" })
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
        Font = F.Main,
        Size = UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = SMALL_SIZE + 1,
        Visible = false,
        ZIndex = 100,
        Parent = self.ScreenGui,
    })
    Corner(tip, 5)
    Pad(tip, 5, 8)
    local tipStroke = Stroke(tip)
    self:_style(tip, function(theme)
        tip.BackgroundColor3 = theme.Header
        tip.TextColor3 = theme.Text
        tipStroke.Color = theme.Border
    end)

    self._tooltip = tip
    return tip
end

function Window:AttachTooltip(guiObject, text)
    local tip = self:_ensureTooltip()

    local function place()
        local x, y = mouseXY()
        local viewport = self.ScreenGui.AbsoluteSize
        local width = tip.AbsoluteSize.X
        tip.Position = UDim2.fromOffset(
            math.max(4, math.min(x + 14, viewport.X - width - 8)),
            y + 18
        )
    end

    guiObject.MouseEnter:Connect(function()
        self._tipToken += 1
        local token = self._tipToken
        task.delay(0.45, function()
            if token ~= self._tipToken or self._unloaded then
                return
            end
            tip.Text = text
            tip.Visible = true
            place()
        end)
    end)
    guiObject.MouseMoved:Connect(function()
        if tip.Visible then
            place()
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
    Corner(frame, CARD_RADIUS)
    Pad(frame, 9, 12)
    local frameStroke = Stroke(frame)
    self:_style(frame, function(theme)
        frame.BackgroundColor3 = theme.Surface
        frameStroke.Color = theme.Border
    end)
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame,
    })

    local header = Label({
        Name = "Header",
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 0,
        Size = UDim2.fromOffset(0, 16),
        Text = "Keybinds",
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
            TextSize = SMALL_SIZE + 1,
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
        Position = UDim2.new(0, -300, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = wrap,
    })
    Corner(card, CARD_RADIUS)
    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = theme.Border,
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
        local iconLabel = IconLabel(body, nil, 16)
        iconLabel.Position = UDim2.fromOffset(20, 21)
        iconLabel.ImageColor3 = theme.Accent
        hasIcon = ApplyIcon(iconLabel, config.Icon)
        iconLabel.Visible = hasIcon
    end

    Pad(body, 10, 12, 14, hasIcon and 38 or 12)
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })

    local title = Label({
        Name = "Title",
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
        TextSize = 13,
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
        Position = UDim2.new(0, 12, 1, -6),
        Size = UDim2.new(1, -24, 0, 2),
        Parent = card,
    })
    Corner(timer, 1)

    local clickArea = Create("TextButton", {
        Name = "Click",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        ZIndex = 5,
        Parent = card,
    })

    local dismissed = false
    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        Tween(card, { Position = UDim2.new(0, -300, 0, 0) }, true, T_FAST)
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
        Tween(main, { Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, TOPBAR_HEIGHT + 1) }, true, T_MED)
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
        Tween(main, {
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(viewport.X, viewport.Y),
        }, true, T_SLOW)
        self._mainCorner.CornerRadius = UDim.new(0, 0)
    else
        Tween(main, {
            Position = self._restorePosition or main.Position,
            Size = self._restoreMaxSize or main.Size,
        }, true, T_SLOW)
        self._mainCorner.CornerRadius = UDim.new(0, WINDOW_RADIUS)
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
    local pickers = self._themePickers

    -- sol kolon
    local interface = tab:AddCategory({ Title = "Interface", Side = "Left" })
    interface:AddDropdown({
        Title = "Theme",
        Values = PRESET_ORDER,
        Default = "Dark",
        Searchable = false,
        Callback = function(name)
            if name then
                self:SetThemePreset(name)
            end
        end,
    })
    pickers.Accent = interface:AddColorPicker({
        Title = "Accent color",
        Default = self._theme.Accent,
        Callback = function(color)
            self:SetAccent(color)
        end,
    })
    interface:AddToggle({
        Title = "Keybind list",
        Callback = function(value)
            self:SetKeybindListVisible(value)
        end,
    })
    self._toggleKeybind = interface:AddKeybind({
        Title = "Toggle UI",
        Default = Enum.KeyCode.RightShift,
        Flag = "Nexo_ToggleKey",
        Callback = function()
            self:ToggleVisibility()
        end,
    })
    interface:AddButton({
        Title = "Unload UI",
        Style = "Danger",
        Callback = function()
            self:UnloadGui()
        end,
    })

    local custom = tab:AddCategory({ Title = "Custom colors", Side = "Left", Collapsed = true })
    for _, item in ipairs({
        { "Window", "Window" },
        { "Surface", "Cards" },
        { "Element", "Controls" },
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
    local configs = tab:AddCategory({ Title = "Configs", Side = "Right" })
    local nameInput = configs:AddInput({ Title = "Name", Placeholder = "my-config" })
    local savedList
    savedList = configs:AddDropdown({
        Title = "Saved configs",
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
    for key, value in pairs(Presets.Dark) do
        theme[key] = value
    end
    local presetName = config.Preset == "Default" and "Dark" or config.Preset
    local preset = presetName and Presets[presetName]
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
    self._themePickers = {}
    self._notifyOrder = 0
    self._tipToken = 0
    self._settingsOpen = false
    self._minimized = false
    self._maximized = false

    local guiParent = GetGuiParent()

    -- bildirimler (sol alt)
    local notifyGui = Create("ScreenGui", {
        Name = "NexoNotify",
        DisplayOrder = 101,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = guiParent,
    })
    local notifyHolder = Create("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 1, -12),
        Size = UDim2.new(0, 270, 1, -24),
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
    local width = config.Size and config.Size.X.Offset > 0 and config.Size.X.Offset or 580
    local height = config.Size and config.Size.Y.Offset > 0 and config.Size.Y.Offset or 520
    width = math.floor(math.clamp(width, 460, math.max(460, viewport.X - 40)))
    height = math.floor(math.clamp(height, 320, math.max(320, viewport.Y - 60)))

    local main = Create("Frame", {
        Name = "Main",
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0.5, -math.floor(width / 2), 0.5, -math.floor(height / 2)),
        Size = UDim2.fromOffset(width, height),
        Parent = screenGui,
    })
    self._mainCorner = Corner(main, WINDOW_RADIUS)
    local mainStroke = Stroke(main)
    self:_style(main, function(t)
        main.BackgroundColor3 = t.Window
        mainStroke.Color = t.Border
    end)
    self.Main = main

    --====================================================================--
    -- Topbar
    --====================================================================--

    local topbar = Create("Frame", {
        Name = "Topbar",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),
        Parent = main,
    })

    local topbarLine = Create("Frame", {
        Name = "Line",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, TOPBAR_HEIGHT),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = main,
    })
    self:_paint(topbarLine, "BackgroundColor3", "Border")

    local dragArea = Create("Frame", {
        Name = "Drag",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -130, 1, 0),
        Parent = topbar,
    })

    local logo = IconLabel(dragArea, nil, 18)
    logo.Position = UDim2.new(0, 23, 0.5, 0)
    logo.Visible = false
    self:_paint(logo, "ImageColor3", "Accent")
    local hasLogo = config.Icon ~= nil and ApplyIcon(logo, config.Icon)
    logo.Visible = hasLogo

    local titleLabel = Label({
        Name = "Title",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, hasLogo and 40 or 14, 0.5, 0),
        Size = UDim2.new(1, -(hasLogo and 48 or 22), 0, 18),
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
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(0, 26),
        Parent = topbar,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = controls,
    })

    -- Pencere kontrolu: resim ikon (asset / lucide), cozulemezse yazi / cizim yedegi
    local function controlButton(order, numericIcon, lucideName, fallbackText)
        local button = Create("TextButton", {
            Name = "Control",
            BackgroundTransparency = 1,
            LayoutOrder = order,
            Size = UDim2.fromOffset(28, 26),
            Text = "",
            Parent = controls,
        })
        Corner(button, 6)

        local image = IconLabel(button, nil, 16)
        image.Position = UDim2.fromScale(0.5, 0.5)

        local resolved = false
        if numericIcon then
            resolved = ApplyIcon(image, numericIcon)
        end
        if not resolved and lucideName then
            resolved = ApplyIcon(image, lucideName)
        end
        image.Visible = resolved

        local fallback = Label({
            Name = "Fallback",
            Font = F.Glyph,
            Size = UDim2.fromScale(1, 1),
            Text = fallbackText or "",
            TextSize = 18,
            TextTruncate = Enum.TextTruncate.None,
            TextXAlignment = Enum.TextXAlignment.Center,
            Visible = not resolved and fallbackText ~= nil,
            Parent = button,
        })

        local state = { hover = false, active = false }

        local function render(animate)
            local t = self._theme
            local color = state.active and t.Accent or (state.hover and t.Text or t.TextDim)
            Tween(button, { BackgroundTransparency = state.hover and 0 or 1, BackgroundColor3 = t.Header }, animate)
            image.ImageColor3 = color
            fallback.TextColor3 = color
        end
        self:_style(button, function()
            render(false)
        end)

        button.MouseEnter:Connect(function() state.hover = true; render(true) end)
        button.MouseLeave:Connect(function() state.hover = false; render(true) end)

        return button, function(value)
            state.active = value
            render(true)
        end
    end

    local settingsButton, setSettingsActive = controlButton(1, ICON_SETTINGS, "settings", "=")
    local minimizeButton = controlButton(2, nil, "minus", "-")
    local maximizeButton = controlButton(3, ICON_MAXIMIZE, "square", "+")
    local closeButton = controlButton(4, nil, "x", "x")

    self._settingsButtonRender = function()
        setSettingsActive(self._settingsOpen)
    end

    --====================================================================--
    -- Govde: tab'lar + arama + sayfalar
    --====================================================================--

    local body = Create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, TOPBAR_HEIGHT + 1),
        Size = UDim2.new(1, 0, 1, -(TOPBAR_HEIGHT + 1)),
        Parent = main,
    })
    Pad(body, 10, 12, 10, 12)

    local tabList = Create("ScrollingFrame", {
        Name = "Tabs",
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Size = UDim2.new(1, -176, 0, 32),
        Parent = body,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = tabList,
    })
    self._tabList = tabList

    local searchBox = Create("Frame", {
        Name = "Search",
        AnchorPoint = Vector2.new(1, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 2),
        Size = UDim2.fromOffset(166, 28),
        Parent = body,
    })
    Corner(searchBox, 6)
    local searchStroke = Stroke(searchBox)
    self:_gradient(searchBox)

    local magnifier = IconLabel(searchBox, ICON_SEARCH, 16)
    magnifier.Position = UDim2.new(0, 16, 0.5, 0)
    self:_paint(magnifier, "ImageColor3", "TextDim")

    local searchInput = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = F.Main,
        PlaceholderText = "Search",
        Position = UDim2.fromOffset(31, 0),
        Size = UDim2.new(1, -54, 1, 0),
        Text = "",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = searchBox,
    })

    local clearButton = Create("ImageButton", {
        Name = "Clear",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. tostring(ICON_CLEAR),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Visible = false,
        Parent = searchBox,
    })
    self:_paint(clearButton, "ImageColor3", "TextDim")

    self:_style(searchBox, function(t)
        searchBox.BackgroundColor3 = t.Element
        searchStroke.Color = searchInput:IsFocused() and t.Accent or t.Border
        searchInput.TextColor3 = t.Text
        searchInput.PlaceholderColor3 = t.TextMuted
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

    local tabHolder = Create("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(1, 0, 1, -42),
        Parent = body,
    })
    self._tabHolder = tabHolder

    local noResults = Label({
        Name = "NoResults",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.4),
        Size = UDim2.new(1, -40, 0, 20),
        Text = "No results",
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = tabHolder,
    })
    self:_paint(noResults, "TextColor3", "TextMuted")
    self._noResults = noResults

    -- resize tutamagi (sag alt kose, ince cizgiler)
    local grip = Create("TextButton", {
        Name = "Resize",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.fromOffset(18, 18),
        Text = "",
        ZIndex = 10,
        Parent = main,
    })
    local gripDots = {}
    for _, offset in ipairs({ { 12, 5 }, { 12, 9 }, { 12, 13 }, { 8, 9 }, { 8, 13 }, { 4, 13 } }) do
        local dot = Create("Frame", {
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(offset[1], offset[2]),
            Size = UDim2.fromOffset(2, 2),
            Parent = grip,
        })
        table.insert(gripDots, dot)
    end
    self:_style(grip, function(t)
        for _, dot in ipairs(gripDots) do
            dot.BackgroundColor3 = t.TextMuted
        end
    end)
    self._resizeGrip = grip

    self._settingsTab = self:_buildPage()

    --====================================================================--
    -- Pencere davranislari
    --====================================================================--

    settingsButton.MouseButton1Click:Connect(function()
        self._settingsOpen = not self._settingsOpen
        self:_refreshPages()
    end)

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
                local y = math.clamp(startPosition.Y + delta.Y, 0, screen.Y - TOPBAR_HEIGHT)
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
                local newY = math.clamp(startSize.Y + delta.Y, 320, math.max(320, screen.Y - position.Y))
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
