local Stub = {}

local function noteError(where, err)
        local list = __SIM_ERRORS
        list[#list + 1] = string.format("[%s] %s", where, tostring(err))
end

local Signal = {}
Signal.__index = Signal

local function newSignal()
        return setmetatable({ __handlers = {} }, Signal)
end

function Signal:Connect(fn)
        local h = { fn = fn }
        self.__handlers[#self.__handlers + 1] = h
        return { Disconnect = function()
                for i, x in ipairs(self.__handlers) do
                        if x == h then
                                table.remove(self.__handlers, i)
                                break
                        end
                end
        end }
end

function Signal:Fire(...)
        local snapshot = {}
        for i, h in ipairs(self.__handlers) do
                snapshot[i] = h
        end
        for _, h in ipairs(snapshot) do
                local ok, err = coroutine.resume(coroutine.create(h.fn), ...)
                if not ok then
                        noteError("signal", err)
                end
        end
end

local SignalNames = {
        Triggered = true,
        Activated = true,
        MouseButton1Click = true,
        InputBegan = true,
        InputEnded = true,
        Changed = true,
        PlayerAdded = true,
        PlayerRemoving = true,
        CharacterAdded = true,
        CharacterRemoving = true,
        Touched = true,
        RenderStepped = true,
        Heartbeat = true,
        InputChanged = true,
}

Vector3 = {}
Vector3.__index = function(v, k)
        if k == "Magnitude" then
                return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
        end
        if k == "X" then
                return v.x
        elseif k == "Y" then
                return v.y
        elseif k == "Z" then
                return v.z
        end
        return Vector3[k]
end
Vector3.__add = function(a, b)
        return setmetatable({ x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }, Vector3)
end
Vector3.__sub = function(a, b)
        return setmetatable({ x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }, Vector3)
end
Vector3.__mul = function(a, b)
        if type(a) == "number" then
                return setmetatable({ x = a * b.x, y = a * b.y, z = a * b.z }, Vector3)
        end
        if type(b) == "number" then
                return setmetatable({ x = a.x * b, y = a.y * b, z = a.z * b }, Vector3)
        end
        return setmetatable({ x = a.x * b.x, y = a.y * b.y, z = a.z * b.z }, Vector3)
end
Vector3.__unm = function(a)
        return setmetatable({ x = -a.x, y = -a.y, z = -a.z }, Vector3)
end
Vector3.__div = function(a, b)
        if type(a) == "number" then
                return setmetatable({ x = a / b.x, y = a / b.y, z = a / b.z }, Vector3)
        end
        if type(b) == "number" then
                return setmetatable({ x = a.x / b, y = a.y / b, z = a.z / b }, Vector3)
        end
        return setmetatable({ x = a.x / b.x, y = a.y / b.y, z = a.z / b.z }, Vector3)
end
Vector3.__eq = function(a, b)
        return a.x == b.x and a.y == b.y and a.z == b.z
end
Vector3.__tostring = function(v)
        return string.format("%.3f, %.3f, %.3f", v.x, v.y, v.z)
end

local function vec3(x, y, z)
        return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, Vector3)
end
Vector3.new = vec3
Vector3.one = vec3(1, 1, 1)
Vector3.zero = vec3(0, 0, 0)

Vector2 = {}
Vector2.__index = Vector2
Vector2.__eq = function(a, b)
        return a.x == b.x and a.y == b.y
end
function Vector2.new(x, y)
        return setmetatable({ x = x or 0, y = y or 0 }, Vector2)
end

CFrame = {}
CFrame.__index = function(cf, k)
        if k == "Position" then
                return vec3(cf.x, cf.y, cf.z)
        end
        if k == "LookVector" then
                local m = cf.m
                return vec3(-m[1][3], -m[2][3], -m[3][3])
        end
        if k == "UpVector" then
                local m = cf.m
                return vec3(m[1][2], m[2][2], m[3][2])
        end
        if k == "Rotation" then
                return setmetatable({ x = 0, y = 0, z = 0, m = cf.m }, CFrame)
        end
        if k == "PointToObjectSpace" or k == "VectorToObjectSpace" then
                return function(cf, p)
                        local m = cf.m
                        local dx, dy, dz = p.x - cf.x, p.y - cf.y, p.z - cf.z
                        return vec3(
                                m[1][1] * dx + m[2][1] * dy + m[3][1] * dz,
                                m[1][2] * dx + m[2][2] * dy + m[3][2] * dz,
                                m[1][3] * dx + m[2][3] * dy + m[3][3] * dz
                        )
                end
        end
        return CFrame[k]
end
CFrame.__mul = function(a, b)
        if getmetatable(b) == Vector3 then
                local m = a.m
                return vec3(
                        m[1][1] * b.x + m[1][2] * b.y + m[1][3] * b.z + a.x,
                        m[2][1] * b.x + m[2][2] * b.y + m[2][3] * b.z + a.y,
                        m[3][1] * b.x + m[3][2] * b.y + m[3][3] * b.z + a.z
                )
        end
        local am, bm = a.m, b.m
        local m = {}
        for i = 1, 3 do
                m[i] = {}
                for j = 1, 3 do
                        m[i][j] = am[i][1] * bm[1][j] + am[i][2] * bm[2][j] + am[i][3] * bm[3][j]
                end
        end
        local px = am[1][1] * b.x + am[1][2] * b.y + am[1][3] * b.z + a.x
        local py = am[2][1] * b.x + am[2][2] * b.y + am[2][3] * b.z + a.y
        local pz = am[3][1] * b.x + am[3][2] * b.y + am[3][3] * b.z + a.z
        return setmetatable({ x = px, y = py, z = pz, m = m }, CFrame)
end
CFrame.__eq = function(a, b)
        return a.x == b.x and a.y == b.y and a.z == b.z
end
CFrame.__add = function(a, b)
        if getmetatable(b) == Vector3 then
                return setmetatable({ x = a.x + b.x, y = a.y + b.y, z = a.z + b.z, m = a.m }, CFrame)
        end
        if getmetatable(a) == Vector3 then
                return setmetatable({ x = a.x + b.x, y = a.y + b.y, z = a.z + b.z, m = b.m }, CFrame)
        end
        error("CFrame + CFrame tidak didukung stub")
end
CFrame.__sub = function(a, b)
        if getmetatable(b) == Vector3 then
                return setmetatable({ x = a.x - b.x, y = a.y - b.y, z = a.z - b.z, m = a.m }, CFrame)
        end
        error("CFrame - bukan Vector3 tidak didukung stub")
end
CFrame.__tostring = function(cf)
        return string.format("CF(%.2f, %.2f, %.2f)", cf.x, cf.y, cf.z)
end

local function mkcf(x, y, z, m)
        if not m then
                m = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } }
        end
        return setmetatable({ x = x, y = y, z = z, m = m }, CFrame)
end

function CFrame.new(x, y, z)
        if type(x) == "table" and getmetatable(x) == Vector3 then
                return mkcf(x.x, x.y, x.z, nil)
        end
        return mkcf(x or 0, y or 0, z or 0, nil)
end

function CFrame.Angles(rx, ry, rz)
        local cx, sx = math.cos(rx), math.sin(rx)
        local cy, sy = math.cos(ry), math.sin(ry)
        local cz, sz = math.cos(rz), math.sin(rz)
        local Rx = { { 1, 0, 0 }, { 0, cx, -sx }, { 0, sx, cx } }
        local Ry = { { cy, 0, sy }, { 0, 1, 0 }, { -sy, 0, cy } }
        local Rz = { { cz, -sz, 0 }, { sz, cz, 0 }, { 0, 0, 1 } }
        local function mulm(a, b)
                local m = {}
                for i = 1, 3 do
                        m[i] = {}
                        for j = 1, 3 do
                                m[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j]
                        end
                end
                return m
        end
        return mkcf(0, 0, 0, mulm(Rx, mulm(Ry, Rz)))
end

function CFrame.lookAt(pos, target)
        local dx, dy, dz = target.x - pos.x, target.y - pos.y, target.z - pos.z
        local pan = math.sqrt(dx * dx + dy * dy + dz * dz)
        if pan < 1e-8 then
                return mkcf(pos.x, pos.y, pos.z, nil)
        end
        local bx, by, bz = -dx / pan, -dy / pan, -dz / pan
        local rx, ry, rz = bz, 0, -bx
        local rpan = math.sqrt(rx * rx + ry * ry + rz * rz)
        if rpan < 1e-8 then
                rx, ry, rz = 1, 0, 0
                rpan = 1
        end
        rx, ry, rz = rx / rpan, ry / rpan, rz / rpan
        local ux = by * rz - bz * ry
        local uy = bz * rx - bx * rz
        local uz = bx * ry - by * rx
        return mkcf(pos.x, pos.y, pos.z, {
                { rx, ux, bx },
                { ry, uy, by },
                { rz, uz, bz },
        })
end

function CFrame:Inverse()
        local m = self.m
        local t = {
                { m[1][1], m[2][1], m[3][1] },
                { m[1][2], m[2][2], m[3][2] },
                { m[1][3], m[2][3], m[3][3] },
        }
        local tx = -(t[1][1] * self.x + t[1][2] * self.y + t[1][3] * self.z)
        local ty = -(t[2][1] * self.x + t[2][2] * self.y + t[2][3] * self.z)
        local tz = -(t[3][1] * self.x + t[3][2] * self.y + t[3][3] * self.z)
        return mkcf(tx, ty, tz, t)
end

function CFrame:Lerp(other, t)
        local m = {}
        for i = 1, 3 do
                m[i] = {}
                for j = 1, 3 do
                        m[i][j] = self.m[i][j] * (1 - t) + other.m[i][j] * t
                end
        end
        return mkcf(
                self.x + (other.x - self.x) * t,
                self.y + (other.y - self.y) * t,
                self.z + (other.z - self.z) * t,
                m
        )
end

Color3 = {}
Color3.__index = Color3
function Color3.new(r, g, b)
        return setmetatable({ r = r or 0, g = g or 0, b = b or 0 }, Color3)
end
function Color3.fromRGB(r, g, b)
        return Color3.new(r / 255, g / 255, b / 255)
end

TweenInfo = {}
function TweenInfo.new(t, style, dir, repeatCount)
        return { t = t, style = style, dir = dir, repeatCount = repeatCount }
end

ColorSequence = {}
function ColorSequence.new(c)
        return { c = c }
end

NumberRange = {}
function NumberRange.new(a, b)
        return { a = a, b = b }
end

NumberSequence = {}
function NumberSequence.new(a, b)
        return { a = a, b = b }
end

PhysicalProperties = {}
function PhysicalProperties.new(a, b, c, d, e)
        return { a = a, b = b, c = c, d = d, e = e }
end

UDim = {}
UDim.__index = function(u, k)
        if k == "Scale" then
            return rawget(u, "s")
        end
        if k == "Offset" then
            return rawget(u, "o")
        end
        return UDim[k]
end
function UDim.new(s, o)
        return setmetatable({ s = s or 0, o = o or 0 }, UDim)
end

UDim2 = {}
UDim2.__index = UDim2
function UDim2.new(xs, xo, ys, yo)
        return setmetatable({ xs = xs or 0, xo = xo or 0, ys = ys or 0, yo = yo or 0 }, UDim2)
end
function UDim2.fromScale(xs, ys)
        return UDim2.new(xs, 0, ys, 0)
end
function UDim2.fromOffset(xo, yo)
        return UDim2.new(0, xo, 0, yo)
end

local function makeEnum(name, values)
        local e = {}
        for _, v in ipairs(values) do
                e[v] = { __enum = name .. "." .. v }
        end
        return setmetatable(e, { __tostring = function()
                return name
        end })
end

Enum = {
        Material = makeEnum("Material", { "Wood", "Glass", "Slate", "SmoothPlastic", "Fabric", "Ground", "Grass", "WoodPlanks", "Concrete", "Neon", "Plastic" }),
        SurfaceType = makeEnum("SurfaceType", { "Smooth", "Studs", "Weld", "Glue", "Inlet" }),
        NormalId = makeEnum("NormalId", { "Front", "Back", "Top", "Bottom", "Left", "Right" }),
        Font = makeEnum("Font", { "Gotham", "GothamBold", "GothamBlack", "Legacy" }),
        ZIndexBehavior = makeEnum("ZIndexBehavior", { "Sibling", "Global" }),
        CameraType = makeEnum("CameraType", { "Scriptable", "Custom", "Fixed", "Track", "Follow" }),
        UserInputType = makeEnum("UserInputType", { "MouseButton1", "Touch", "Keyboard" }),
        UserInputState = makeEnum("UserInputState", { "Begin", "Change", "End" }),
        RaycastFilterType = makeEnum("RaycastFilterType", { "Exclude", "Include" }),
        TextXAlignment = makeEnum("TextXAlignment", { "Left", "Center", "Right" }),
        TextYAlignment = makeEnum("TextYAlignment", { "Top", "Center", "Bottom" }),
        SortOrder = makeEnum("SortOrder", { "LayoutOrder", "Name", "Custom" }),
        AutomaticSize = makeEnum("AutomaticSize", { "None", "X", "Y", "XY" }),
        HorizontalAlignment = makeEnum("HorizontalAlignment", { "Left", "Center", "Right" }),
        VerticalAlignment = makeEnum("VerticalAlignment", { "Top", "Center", "Bottom" }),
        PartType = makeEnum("PartType", { "Ball", "Cylinder", "Block" }),
        EasingStyle = makeEnum("EasingStyle", { "Linear", "Sine", "Quad", "Back", "Bounce", "Elastic" }),
        EasingDirection = makeEnum("EasingDirection", { "In", "Out", "InOut" }),
        TextTruncate = makeEnum("TextTruncate", { "None", "AtEnd" }),
        FillDirection = makeEnum("FillDirection", { "Horizontal", "Vertical" }),
        HighlightDepthMode = makeEnum("HighlightDepthMode", { "AlwaysOnTop", "Occluded" }),
        RenderPriority = makeEnum("RenderPriority", { "First", "Input", "Camera", "Character", "Last" }),
}
Enum.RenderPriority.First.Value = 0
Enum.RenderPriority.Input.Value = 100
Enum.RenderPriority.Camera.Value = 200
Enum.RenderPriority.Character.Value = 300
Enum.RenderPriority.Last.Value = 2000

task = {}

Random = {}
function Random.new(seed)
        local state = (seed or 20261106) % 2147483647
        if state <= 0 then
                state = 1
        end
        local r = {}
        function r:NextInteger(a, b)
                state = (state * 48271) % 2147483647
                local span = b - a + 1
                if span <= 0 then
                        return a
                end
                return a + math.floor((state / 2147483647) * span)
        end
        function r:NextNumber()
                state = (state * 48271) % 2147483647
                return state / 2147483647
        end
        return r
end

local Scheduler = {
        vtime = 0,
        pending = {},
}

local function schedule(coro, at)
        Scheduler.pending[#Scheduler.pending + 1] = { at = at, coro = coro }
end

local function resumeCoro(coro, where)
        local ok, err = coroutine.resume(coro)
        if not ok then
                noteError(where, err)
        end
end

function task.wait(t)
        local coro = coroutine.running()
        schedule(coro, Scheduler.vtime + (t or 0.03))
        return coroutine.yield()
end

function task.spawn(fn, ...)
        local n = select("#", ...)
        local args = { ... }
        local coro = coroutine.create(function()
                if n > 0 then
                        fn(table.unpack(args, 1, n))
                else
                        fn()
                end
        end)
        resumeCoro(coro, "task.spawn")
        return coro
end

function task.delay(t, fn)
        local coro = coroutine.create(fn)
        schedule(coro, Scheduler.vtime + (t or 0))
        return coro
end

function task.defer(fn, ...)
        return task.spawn(fn, ...)
end

function Scheduler.advance(dt)
        local target = Scheduler.vtime + dt
        local guard = 0
        while guard < 20000 do
                guard += 1
                local bestIdx, bestAt = nil, math.huge
                for i, p in ipairs(Scheduler.pending) do
                        if p.at < bestAt then
                                bestIdx, bestAt = i, p.at
                        end
                end
                if not bestIdx or bestAt > target then
                        break
                end
                Scheduler.vtime = bestAt
                local p = table.remove(Scheduler.pending, bestIdx)
                if coroutine.status(p.coro) == "suspended" then
                        resumeCoro(p.coro, "scheduler")
                end
        end
        Scheduler.vtime = target
end

local ISA = {
        Part = { "BasePart", "PVInstance", "Instance" },
        WedgePart = { "BasePart", "PVInstance", "Instance" },
        SpawnLocation = { "BasePart", "PVInstance", "Instance" },
        Model = { "PVInstance", "Instance" },
        Folder = { "Instance" },
        ProximityPrompt = { "Instance" },
        SurfaceGui = { "Instance" },
        TextLabel = { "GuiObject", "GuiBase2d", "Instance" },
        TextButton = { "GuiObject", "GuiBase2d", "Instance" },
        TextBox = { "GuiObject", "GuiBase2d", "Instance" },
        Frame = { "GuiObject", "GuiBase2d", "Instance" },
        ScrollingFrame = { "GuiObject", "GuiBase2d", "Instance" },
        ScreenGui = { "Instance" },
        UICorner = { "Instance" },
        UIListLayout = { "Instance" },
        UIGridLayout = { "Instance" },
        PointLight = { "Instance" },
        IntValue = { "Instance" },
        Camera = { "Instance" },
        ModuleScript = { "Instance" },
        LocalScript = { "Instance" },
        Script = { "Instance" },
        Player = { "Instance" },
        RaycastParams = { "Instance" },
        Highlight = { "Instance" },
        UIPadding = { "Instance" },
        UISizeConstraint = { "Instance" },
        WeldConstraint = { "Instance" },
        Attachment = { "Instance" },
        Motor6D = { "Instance" },
}

local InstanceMethods = {}

function InstanceMethods:FindFirstChild(name, recursive)
        for _, c in ipairs(self.__children) do
                if c.Name == name then
                        return c
                end
        end
        if recursive then
                for _, c in ipairs(self.__children) do
                        local hit = c:FindFirstChild(name, true)
                        if hit then
                                return hit
                        end
                end
        end
        return nil
end

function InstanceMethods:WaitForChild(name, timeout)
        return self:FindFirstChild(name)
end

function InstanceMethods:GetChildren()
        local out = {}
        for i, c in ipairs(self.__children) do
                out[i] = c
        end
        return out
end

function InstanceMethods:GetDescendants()
        local out = {}
        local function walk(i)
                for _, c in ipairs(i.__children) do
                        out[#out + 1] = c
                        walk(c)
                end
        end
        walk(self)
        return out
end

function InstanceMethods:FindFirstChildWhichIsA(class)
        for _, c in ipairs(self.__children) do
                if c:IsA(class) then
                        return c
                end
        end
        return nil
end

function InstanceMethods:IsA(class)
        if self.__class == class then
                return true
        end
        local chain = ISA[self.__class]
        if chain then
                for _, c in ipairs(chain) do
                        if c == class then
                                return true
                        end
                end
        end
        return false
end

function InstanceMethods:SetAttribute(k, v)
        self.__attrs[k] = v
end

function InstanceMethods:GetAttribute(k)
        return self.__attrs[k]
end

function InstanceMethods:Destroy()
        local p = self.Parent
        if p then
                local list = p.__children
                for i, c in ipairs(list) do
                        if c == self then
                                table.remove(list, i)
                                break
                        end
                end
        end
        self.Parent = nil
        self.__destroyed = true
end

function InstanceMethods:Clone()
        local copy = Instance.new(self.__class)
        copy.Name = self.Name
        for k, v in pairs(self) do
                if k ~= "__children" and k ~= "Parent" and k ~= "__attrs" and k ~= "__class" and type(v) ~= "function" then
                        copy[k] = v
                end
        end
        for k, v in pairs(self.__attrs) do
                copy.__attrs[k] = v
        end
        return copy
end

function InstanceMethods:GetPivot()
        if self:IsA("BasePart") then
                return self.CFrame
        end
        if self.WorldPivot then
                return self.WorldPivot
        end
        local p = self:FindFirstChildWhichIsA("BasePart")
        return p and p.CFrame or CFrame.new()
end

function InstanceMethods:PivotTo(target)
        local current = self:GetPivot()
        local delta = target * current:Inverse()
        if self:IsA("BasePart") then
                self.CFrame = delta * self.CFrame
                return
        end
        self.WorldPivot = target
        for _, d in ipairs(self:GetDescendants()) do
                if d:IsA("BasePart") then
                        d.CFrame = delta * d.CFrame
                end
        end
end

function InstanceMethods:IsDescendantOf(ancestor)
        local p = self.Parent
        while p do
                if p == ancestor then
                        return true
                end
                p = p.Parent
        end
        return false
end

function InstanceMethods:GetPropertyChangedSignal(prop)
        local cache = rawget(self, "__propSignals")
        if not cache then
                cache = {}
                rawset(self, "__propSignals", cache)
        end
        if not cache[prop] then
                cache[prop] = newSignal()
        end
        return cache[prop]
end

function InstanceMethods:GetPropertyChangedSignal(prop)
        local cache = rawget(self, "__propSignals")
        if not cache then
                cache = {}
                rawset(self, "__propSignals", cache)
        end
        if not cache[prop] then
                cache[prop] = newSignal()
        end
        return cache[prop]
end

local function baseIndex(inst, k)
        if k == "Position" and inst:IsA("BasePart") then
                local cf = rawget(inst, "__cf")
                return cf and cf.Position or CFrame.new().Position
        end
        if k == "CFrame" and inst:IsA("BasePart") then
                return rawget(inst, "__cf") or CFrame.new()
        end
        if InstanceMethods[k] then
                return InstanceMethods[k]
        end
        if SignalNames[k] then
                local s = newSignal()
                rawset(inst, k, s)
                return s
        end
        if k == "ClassName" then
                return inst.__class
        end
        return nil
end

local InstanceMT = {
        __index = baseIndex,
        __newindex = function(inst, k, v)
                if k == "Parent" then
                        local old = rawget(inst, "Parent")
                        if old then
                                local list = old.__children
                                for i, c in ipairs(list) do
                                        if c == inst then
                                                table.remove(list, i)
                                                break
                                        end
                                end
                        end
                        rawset(inst, "Parent", v)
                        if v then
                                table.insert(v.__children, inst)
                        end
                        return
                end
                if k == "CFrame" and inst:IsA("BasePart") then
                        rawset(inst, "__cf", v)
                        return
                end
                if k == "Position" and inst:IsA("BasePart") then
                        local cf = rawget(inst, "__cf") or CFrame.new()
                        rawset(inst, "__cf", mkcf(v.x, v.y, v.z, cf.m))
                        return
                end
                rawset(inst, k, v)
        end,
}

Instance = {}

function Instance.new(class)
        local inst = {}
        rawset(inst, "__class", class)
        rawset(inst, "__children", {})
        rawset(inst, "__attrs", {})
        rawset(inst, "Name", class)
        local GUI = { TextButton = true, TextLabel = true, TextBox = true, Frame = true, ScrollingFrame = true, ScreenGui = true }
        if GUI[class] then
                rawset(inst, "Visible", true)
        end
        setmetatable(inst, InstanceMT)
        if class == "Part" or class == "WedgePart" or class == "SpawnLocation" then
                inst.__cf = CFrame.new()
                inst.Size = vec3(4, 1, 2)
                inst.Anchored = false
                inst.CanCollide = true
                inst.CanQuery = true
                inst.TopSurface = Enum.SurfaceType.Studs
                inst.BottomSurface = Enum.SurfaceType.Smooth
        end
        if class == "RemoteEvent" then
                inst.OnClientEvent = newSignal()
                inst.OnServerEvent = newSignal()
                function inst:FireClient(player, ...)
                        local gs = game
                        local lp = gs and gs:GetService("Players").LocalPlayer
                        if lp and player == lp then
                                self.OnClientEvent:Fire(...)
                        end
                end
                function inst:FireAllClients(...)
                        self.OnClientEvent:Fire(...)
                end
                function inst:FireServer(...)
                        self.OnServerEvent:Fire(...)
                end
        elseif class == "RemoteFunction" then
                function inst:InvokeServer(...)
                        local gs = game
                        local lp = gs and gs:GetService("Players").LocalPlayer
                        if not lp then
                                error("InvokeServer tanpa LocalPlayer")
                        end
                        return self.OnServerInvoke(lp, ...)
                end
        elseif class == "ParticleEmitter" then
                function inst:Emit(n)
                        return nil
                end
        elseif class == "Sound" then
                function inst:Play()
                        return nil
                end
        end
        return inst
end

local function moduleScript(name, path)
        local m = Instance.new("ModuleScript")
        m.Name = name
        m.__requirePath = path
        return m
end

function Stub.install()
        __SIM_ERRORS = {}
        RaycastParams = { new = function()
                return {}
        end }

        local Players = Instance.new("Players")
        Players.LocalPlayer = nil
        local playerList = {}
        Players.__playerList = playerList
        function Players:GetPlayers()
                local out = {}
                for i, p in ipairs(playerList) do
                        out[i] = p
                end
                return out
        end
        function Players:GetPlayerFromCharacter(char)
                for _, p in ipairs(playerList) do
                        if p.Character == char then
                                return p
                        end
                end
                return nil
        end

        local Workspace = Instance.new("Workspace")
        local camera = Instance.new("Camera")
        camera.Name = "Camera"
        camera.FieldOfView = 70
        camera.CFrame = CFrame.new(0, 0, 0)
        camera.Focus = CFrame.new(0, 0, 0)
        camera.ViewportSize = Vector3.new(1024, 600, 0)
        camera.Parent = Workspace
        function camera:ViewportPointToRay(x, y)
                return { Origin = vec3(x, y, 0), Direction = vec3(0, 0, -1) }
        end
        Workspace.CurrentCamera = camera
        Workspace.StreamingEnabled = true
        function Workspace:GetServerTimeNow()
                return Scheduler.vtime
        end
        function Workspace:RequestStreamAroundAsync(pos, radius)
                return nil
        end
        function Workspace:Raycast(origin, dir, params)
                return nil
        end
        workspace = Workspace

        local ReplicatedStorage = Instance.new("ReplicatedStorage")
        local shared = Instance.new("Folder")
        shared.Name = "Shared"
        shared.Parent = ReplicatedStorage
        for _, n in ipairs({ "CropData", "Recipes", "TasLogic", "Layout", "DuniaLogic", "SoalLogic", "GudangLogic", "PukulLogic", "PanenStatus", "TanahDrops" }) do
                local m = moduleScript(n, "./../download/dunia-akiomida/src/Shared/" .. n)
                m.Parent = shared
        end
        local remotesModule = moduleScript("Remotes", "./../download/dunia-akiomida/src/Remotes/init")
        remotesModule.Parent = ReplicatedStorage

        local DataStoreService = Instance.new("DataStoreService")
        local stores = {}
        function DataStoreService:GetDataStore(name)
                if not stores[name] then
                        local ds = { __data = {} }
                        function ds:GetAsync(key)
                                return self.__data[key]
                        end
                        function ds:SetAsync(key, value)
                                self.__data[key] = value
                                return true
                        end
                        function ds:UpdateAsync(key, transform)
                                local old = self.__data[key]
                                local baru = transform(old)
                                if baru ~= nil then
                                        self.__data[key] = baru
                                end
                                return baru
                        end
                        stores[name] = ds
                end
                return stores[name]
        end
        Stub.stores = stores

        local RunService = Instance.new("RunService")
        __SIM_IS_SERVER = true
        function RunService:IsServer()
                return __SIM_IS_SERVER
        end
        function RunService:BindToRenderStep(name, priority, fn)
                return nil
        end
        function RunService:UnbindFromRenderStep(name)
                return nil
        end

        local UserInputService = Instance.new("UserInputService")

        local GuiService = Instance.new("GuiService")
        GuiService.TopbarInset = { Min = { X = 0, Y = 58, x = 0, y = 58 }, Max = { X = 1024, Y = 658, x = 1024, y = 658 } }

        local TweenService = Instance.new("TweenService")
        function TweenService:Create(target, info, props)
                local tween = {}
                local completed = newSignal()
                tween.Completed = completed
                function tween:Play()
                        for k, v in pairs(props) do
                                target[k] = v
                        end
                        completed:Fire(Enum and "Completed" or "Completed")
                end
                return tween
        end

        local Debris = Instance.new("Debris")
        function Debris:AddItem(item, t)
                return nil
        end

        local services = {
                Players = Players,
                Workspace = Workspace,
                ReplicatedStorage = ReplicatedStorage,
                DataStoreService = DataStoreService,
                RunService = RunService,
                UserInputService = UserInputService,
                GuiService = GuiService,
                TweenService = TweenService,
                Debris = Debris,
        }

        game = Instance.new("DataModel")
        function game:GetService(name)
                local s = services[name]
                if not s then
                        error("No service named " .. tostring(name))
                end
                return s
        end
        function game:BindToClose(fn)
                __SIM_BIND_TO_CLOSE = fn
        end

        Stub.Services = services
        Stub.Scheduler = Scheduler
        Stub.noteError = noteError
        Stub.moduleScript = moduleScript
        Stub.newSignal = newSignal

        function Stub.addPlayer(userId, name)
                local p = Instance.new("Player")
                p.UserId = userId
                p.Name = name
                p.Parent = Players
                table.insert(playerList, p)
                return p
        end

        function Stub.setLocalPlayer(p)
                Players.LocalPlayer = p
        end

        function Stub.giveCharacter(p, x, y, z)
                if p.Character then
                        p.Character:Destroy()
                end
                local char = Instance.new("Model")
                char.Name = p.Name
                local root = Instance.new("Part")
                root.Name = "HumanoidRootPart"
                root.Anchored = false
                root.CanCollide = true
                root.Size = vec3(2, 2, 1)
                root.Position = vec3(x or 0, y or 3, z or 0)
                root.Parent = char
                char.Parent = Workspace
                p.Character = char
                return char, root
        end
end

function Stub.serverScript()
        local script = Instance.new("Script")
        script.Name = "Server"
        local modules = Instance.new("Folder")
        modules.Name = "Modules"
        modules.Parent = script
        for _, n in ipairs({ "LandService", "DataService", "MesinSemaiService", "PlotService", "ShopService", "WorldBuilder", "RateLimit", "DevCodeVault", "BuildingKit", "TasService", "ZonaService", "TanamService", "GudangService", "DropService", "PlantModels" }) do
                local m = moduleScript(n, "./../download/dunia-akiomida/src/Server/Modules/" .. n)
                m.Parent = modules
        end
        return script
end

function Stub.clientScript()
        local script = Instance.new("LocalScript")
        script.Name = "Client"
        local ui = moduleScript("UIController", "./../download/dunia-akiomida/src/Client/UIController")
        ui.Parent = script
        return script
end

return Stub
