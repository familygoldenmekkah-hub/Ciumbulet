-- AUTO-GENERATED oleh scripts/sim/gen.py - jangan edit manual
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
        UIFlexMode = makeEnum("UIFlexMode", { "None", "Grow", "Shrink", "Fill", "GrowShrink" }),
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


Stub.install()
local MOD_ArahPukul = (function()
local ArahPukul = {}

ArahPukul.Jangkauan = 14
ArahPukul.Radius = 2.6
ArahPukul.JarakMin = 1.2

local function sub(a, b)
	return { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }
end

local function dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

local function mag(a)
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function ArahPukul.pilih(asal, arah, daftar, jangkauan: number?, radius: number?, jarakMin: number?)
	local j = type(jangkauan) == "number" and jangkauan or ArahPukul.Jangkauan
	local r = type(radius) == "number" and radius or ArahPukul.Radius
	local m = type(jarakMin) == "number" and jarakMin or ArahPukul.JarakMin
	local pan = mag(arah)
	if pan <= 0 then
		return nil
	end
	local nx, ny, nz = arah.x / pan, arah.y / pan, arah.z / pan
	local terbaik = nil
	local terdekat = math.huge
	for _, k in ipairs(daftar) do
		if type(k) == "table" and type(k.pos) == "table" and k.idx ~= nil then
			local rel = sub(k.pos, asal)
			local f = rel.x * nx + rel.y * ny + rel.z * nz
			if f >= m and f <= j then
				local sx = rel.x - nx * f
				local sy = rel.y - ny * f
				local sz = rel.z - nz * f
				local sisi = math.sqrt(sx * sx + sy * sy + sz * sz)
				local batas = (type(k.radius) == "number" and k.radius or r)
				if sisi <= batas and f < terdekat then
					terdekat = f
					terbaik = {
						idx = k.idx,
						jarak = f,
						titik = { x = asal.x + nx * f, y = asal.y + ny * f, z = asal.z + nz * f },
					}
				end
			end
		end
	end
	return terbaik
end

function ArahPukul.titikPukul(asal, arah, jarak: number)
	local pan = mag(arah)
	if pan <= 0 then
		return { x = asal.x, y = asal.y, z = asal.z }
	end
	local f = jarak
	if f < 0 then
		f = 0
	end
	return { x = asal.x + (arah.x / pan) * f, y = asal.y + (arah.y / pan) * f, z = asal.z + (arah.z / pan) * f }
end

function ArahPukul.diDepan(asal, arah, pos, kosMin: number?): boolean
	local rel = sub(pos, asal)
	local pan = mag(arah)
	if pan <= 0 then
		return false
	end
	local panRel = mag(rel)
	if panRel <= 0 then
		return false
	end
	local kos = dot(rel, arah) / (pan * panRel)
	return kos >= (type(kosMin) == "number" and kosMin or 0.4)
end

return ArahPukul

end)()

local MOD_CropData = (function()
local CropData = {}

CropData.GrowTime = 3
CropData.StartMoney = 10000
CropData.TasSlots = 50
CropData.TasStack = 250
CropData.MesinSemai = {
        Kapasitas = 2000,
        WaktuGiling = 3,
        JarakMaks = 24,
}

CropData.Packs = {
        common = { price = 2400, count = 3 },
        rare = { price = 9000, count = 3 },
}

CropData.Yield = {
        common = { min = 1, max = 10 },
        rare = { min = 1, max = 6 },
        epic = { min = 1, max = 4 },
}

CropData.Giling = {
        common = { hits = 5, seed = 0.45, micdaMin = 1, micdaMax = 5 },
        rare = { hits = 10, seed = 0.30, micdaMin = 3, micdaMax = 9 },
        epic = { hits = 15, seed = 0.10, micdaMin = 9, micdaMax = 19 },
}

CropData.Crops = {
        { id = "wortel", nama = "Wortel", rarity = "common", jual = 1 },
        { id = "pisang", nama = "Pisang", rarity = "common", jual = 1 },
        { id = "bayam", nama = "Bayam", rarity = "common", jual = 1 },
        { id = "kentang", nama = "Kentang", rarity = "common", jual = 1 },
        { id = "ubi_jalar", nama = "Ubi Jalar", rarity = "common", jual = 2 },
        { id = "jambu_biji", nama = "Jambu Biji", rarity = "common", jual = 2 },
        { id = "singkong", nama = "Singkong", rarity = "common", jual = 2 },
        { id = "tebu", nama = "Tebu", rarity = "common", jual = 5 },
        { id = "kedelai", nama = "Kedelai", rarity = "common", jual = 6 },
        { id = "jamur", nama = "Jamur", rarity = "common", jual = 6 },
        { id = "brokoli", nama = "Brokoli", rarity = "common", jual = 7 },
        { id = "sorgum", nama = "Sorgum", rarity = "common", jual = 17 },
        { id = "jeruk_mandarin", nama = "Jeruk Mandarin", rarity = "rare", jual = 2 },
        { id = "plum", nama = "Plum", rarity = "rare", jual = 3 },
        { id = "aprikot", nama = "Aprikot", rarity = "rare", jual = 4 },
        { id = "nektarin", nama = "Nektarin", rarity = "rare", jual = 5 },
        { id = "brassica_rapa", nama = "Brassica Rapa", rarity = "rare", jual = 7 },
        { id = "brassica_oleracea", nama = "Brassica Oleracea", rarity = "rare", jual = 7 },
        { id = "grapefruit", nama = "Grapefruit", rarity = "rare", jual = 10 },
        { id = "labu_moschata", nama = "Labu Cucurbita Moschata", rarity = "rare", jual = 15 },
        { id = "labu_maxima", nama = "Labu Cucurbita Maxima", rarity = "rare", jual = 17 },
        { id = "gandum", nama = "Gandum", rarity = "rare", jual = 19 },
        { id = "arachis_duranensis", nama = "Arachis Duranensis", rarity = "rare", jual = 20 },
        { id = "arachis_ipaensis", nama = "Arachis Ipaensis", rarity = "rare", jual = 20 },
        { id = "rye", nama = "Rye", rarity = "rare", jual = 40 },
        { id = "ceri", nama = "Ceri", rarity = "rare", jual = 87 },
        { id = "tangelo", nama = "Tangelo", rarity = "epic", jual = 17 },
        { id = "plumcot", nama = "Plumcot", rarity = "epic", jual = 22 },
        { id = "nectaplum", nama = "Nectaplum", rarity = "epic", jual = 25 },
        { id = "kacang_tanah", nama = "Kacang Tanah", rarity = "epic", jual = 30 },
        { id = "pluerry", nama = "Pluerry", rarity = "epic", jual = 35 },
        { id = "canola", nama = "Canola", rarity = "epic", jual = 60 },
        { id = "triticale", nama = "Triticale", rarity = "epic", jual = 67 },
        { id = "tetsukabuto", nama = "Tetsukabuto", rarity = "epic", jual = 75 },
}

CropData.byId = {}
for _, c in ipairs(CropData.Crops) do
        CropData.byId[c.id] = c
end

CropData.PukulMaks = 5

CropData.Bentuk = {
        wortel = { jenis = "akar", t = 2.0, w = 1.0, b = 3, warna = { 224, 178, 120 }, siap = { 232, 112, 44 }, aksen = { 74, 142, 70 } },
        kentang = { jenis = "akar", t = 1.4, w = 1.2, b = 3, warna = { 198, 178, 142 }, siap = { 188, 140, 88 }, aksen = { 88, 148, 78 } },
        singkong = { jenis = "akar", t = 2.8, w = 1.0, b = 3, warna = { 168, 142, 110 }, siap = { 148, 104, 66 }, aksen = { 96, 156, 84 } },
        brassica_rapa = { jenis = "akar", t = 1.6, w = 1.3, b = 3, warna = { 222, 214, 224 }, siap = { 196, 148, 190 }, aksen = { 104, 162, 92 } },
        ubi_jalar = { jenis = "kacang", t = 0.9, w = 2.2, b = 5, warna = { 214, 150, 96 }, siap = { 226, 104, 58 }, aksen = { 88, 152, 86 } },
        bayam = { jenis = "daun", t = 1.5, w = 1.4, b = 1, warna = { 84, 146, 80 }, siap = { 44, 110, 60 }, aksen = { 110, 170, 96 } },
        brokoli = { jenis = "daun", t = 1.7, w = 1.5, b = 1, warna = { 96, 132, 70 }, siap = { 58, 118, 66 }, aksen = { 118, 166, 92 } },
        brassica_oleracea = { jenis = "daun", t = 1.9, w = 1.9, b = 1, warna = { 130, 168, 104 }, siap = { 170, 200, 132 }, aksen = { 96, 150, 88 } },
        labu_moschata = { jenis = "bulat", t = 1.1, w = 2.6, b = 1, warna = { 198, 142, 80 }, siap = { 230, 148, 58 }, aksen = { 96, 140, 70 } },
        labu_maxima = { jenis = "bulat", t = 1.3, w = 3.2, b = 1, warna = { 210, 120, 70 }, siap = { 236, 108, 52 }, aksen = { 90, 134, 66 } },
        tetsukabuto = { jenis = "bulat", t = 1.2, w = 2.8, b = 1, warna = { 120, 158, 92 }, siap = { 92, 140, 190 }, aksen = { 70, 120, 80 } },
        gandum = { jenis = "tangkai", t = 2.6, w = 1.6, b = 5, warna = { 146, 150, 72 }, siap = { 224, 182, 84 }, aksen = { 126, 152, 80 } },
        rye = { jenis = "tangkai", t = 3.0, w = 1.6, b = 5, warna = { 120, 136, 110 }, siap = { 150, 164, 128 }, aksen = { 110, 140, 96 } },
        triticale = { jenis = "tangkai", t = 2.8, w = 1.7, b = 5, warna = { 150, 142, 96 }, siap = { 216, 176, 110 }, aksen = { 96, 140, 104 } },
        sorgum = { jenis = "tangkai", t = 3.4, w = 1.8, b = 4, warna = { 150, 116, 66 }, siap = { 186, 88, 52 }, aksen = { 110, 150, 88 } },
        tebu = { jenis = "tangkai", t = 4.4, w = 1.6, b = 3, warna = { 130, 158, 96 }, siap = { 150, 96, 140 }, aksen = { 112, 160, 92 } },
        canola = { jenis = "tangkai", t = 2.4, w = 1.6, b = 5, warna = { 140, 168, 96 }, siap = { 240, 214, 70 }, aksen = { 120, 160, 96 } },
        pisang = { jenis = "pohon", t = 4.6, w = 2.6, b = 3, warna = { 120, 156, 88 }, siap = { 232, 208, 88 }, aksen = { 96, 148, 80 } },
        jambu_biji = { jenis = "pohon", t = 3.8, w = 2.2, b = 4, warna = { 110, 150, 90 }, siap = { 196, 190, 96 }, aksen = { 88, 140, 76 } },
        jeruk_mandarin = { jenis = "pohon", t = 3.4, w = 2.0, b = 5, warna = { 120, 164, 88 }, siap = { 238, 146, 44 }, aksen = { 84, 136, 72 } },
        grapefruit = { jenis = "pohon", t = 4.0, w = 2.4, b = 4, warna = { 116, 158, 92 }, siap = { 240, 168, 60 }, aksen = { 80, 132, 70 } },
        plum = { jenis = "pohon", t = 3.6, w = 2.2, b = 5, warna = { 122, 150, 96 }, siap = { 150, 86, 168 }, aksen = { 86, 136, 74 } },
        aprikot = { jenis = "pohon", t = 3.7, w = 2.2, b = 5, warna = { 118, 152, 92 }, siap = { 232, 138, 104 }, aksen = { 84, 134, 72 } },
        nektarin = { jenis = "pohon", t = 3.5, w = 2.1, b = 5, warna = { 116, 150, 90 }, siap = { 226, 92, 88 }, aksen = { 82, 132, 70 } },
        ceri = { jenis = "pohon", t = 3.0, w = 1.9, b = 6, warna = { 118, 148, 92 }, siap = { 216, 54, 58 }, aksen = { 80, 128, 68 } },
        tangelo = { jenis = "pohon", t = 3.6, w = 2.2, b = 5, warna = { 126, 160, 94 }, siap = { 244, 120, 52 }, aksen = { 226, 86, 70 } },
        plumcot = { jenis = "pohon", t = 3.6, w = 2.2, b = 5, warna = { 120, 148, 94 }, siap = { 168, 84, 180 }, aksen = { 210, 90, 110 } },
        nectaplum = { jenis = "pohon", t = 3.5, w = 2.1, b = 5, warna = { 118, 146, 92 }, siap = { 178, 58, 96 }, aksen = { 230, 120, 80 } },
        pluerry = { jenis = "pohon", t = 3.2, w = 2.0, b = 6, warna = { 120, 150, 94 }, siap = { 210, 70, 86 }, aksen = { 140, 80, 170 } },
        kedelai = { jenis = "semak", t = 1.6, w = 1.8, b = 6, warna = { 108, 146, 88 }, siap = { 222, 186, 70 }, aksen = { 96, 140, 82 } },
        arachis_duranensis = { jenis = "kacang", t = 0.8, w = 2.4, b = 5, warna = { 130, 160, 100 }, siap = { 220, 180, 90 }, aksen = { 104, 150, 88 } },
        arachis_ipaensis = { jenis = "kacang", t = 0.8, w = 2.2, b = 5, warna = { 140, 164, 96 }, siap = { 198, 146, 72 }, aksen = { 112, 154, 90 } },
        kacang_tanah = { jenis = "kacang", t = 1.0, w = 2.8, b = 6, warna = { 150, 168, 104 }, siap = { 236, 196, 110 }, aksen = { 100, 146, 86 } },
        jamur = { jenis = "cendawan", t = 1.8, w = 1.6, b = 1, warna = { 196, 150, 120 }, siap = { 206, 64, 56 }, aksen = { 224, 214, 196 } },
}

function CropData.namaBenih(cropId: string): string
        local info = CropData.byId[cropId]
        if not info then
                return "Benih"
        end
        return "Benih " .. info.nama
end

function CropData.byRarity(rarity: string): { any }
        local out = {}
        for _, c in ipairs(CropData.Crops) do
                if c.rarity == rarity then
                        table.insert(out, c)
                end
        end
        return out
end

return CropData

end)()

local MOD_DropBentuk = (function()
local DropBentuk = {}

local IKON = {
	akar = {
		{ bentuk = "kotak", dx = 0.3, dy = 0.32, dw = 0.4, dh = 0.4, warna = "buah" },
		{ bentuk = "kotak", dx = 0.38, dy = 0.2, dw = 0.24, dh = 0.24, warna = "buah" },
		{ bentuk = "batang", dx = 0.42, dy = 0.08, dw = 0.16, dh = 0.2, warna = "aksen" },
	},
	daun = {
		{ bentuk = "kotak", dx = 0.26, dy = 0.22, dw = 0.48, dh = 0.48, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.4, dy = 0.58, dw = 0.22, dh = 0.22, warna = "buah" },
	},
	bulat = {
		{ bentuk = "batang", dx = 0.44, dy = 0.08, dw = 0.12, dh = 0.18, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.22, dy = 0.24, dw = 0.56, dh = 0.56, warna = "buah" },
	},
	tangkai = {
		{ bentuk = "batang", dx = 0.26, dy = 0.3, dw = 0.09, dh = 0.5, warna = "aksen" },
		{ bentuk = "batang", dx = 0.46, dy = 0.24, dw = 0.09, dh = 0.56, warna = "aksen" },
		{ bentuk = "batang", dx = 0.66, dy = 0.3, dw = 0.09, dh = 0.5, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.24, dy = 0.16, dw = 0.13, dh = 0.13, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.44, dy = 0.1, dw = 0.13, dh = 0.13, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.64, dy = 0.16, dw = 0.13, dh = 0.13, warna = "buah" },
	},
	pohon = {
		{ bentuk = "batang", dx = 0.44, dy = 0.7, dw = 0.12, dh = 0.22, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.16, dy = 0.14, dw = 0.68, dh = 0.68, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.36, dy = 0.34, dw = 0.3, dh = 0.3, warna = "buah" },
	},
	semak = {
		{ bentuk = "pipih", dx = 0.16, dy = 0.68, dw = 0.68, dh = 0.16, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.12, dy = 0.42, dw = 0.3, dh = 0.3, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.36, dy = 0.3, dw = 0.34, dh = 0.34, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.58, dy = 0.44, dw = 0.28, dh = 0.28, warna = "buah" },
	},
	kacang = {
		{ bentuk = "batang", dx = 0.44, dy = 0.1, dw = 0.12, dh = 0.22, warna = "aksen" },
		{ bentuk = "pipih", dx = 0.14, dy = 0.34, dw = 0.32, dh = 0.22, warna = "buah" },
		{ bentuk = "pipih", dx = 0.54, dy = 0.34, dw = 0.32, dh = 0.22, warna = "buah" },
		{ bentuk = "pipih", dx = 0.34, dy = 0.6, dw = 0.32, dh = 0.22, warna = "aksen" },
	},
	cendawan = {
		{ bentuk = "batang", dx = 0.4, dy = 0.52, dw = 0.2, dh = 0.32, warna = "aksen" },
		{ bentuk = "topi", dx = 0.14, dy = 0.16, dw = 0.72, dh = 0.42, warna = "buah" },
	},
}

function DropBentuk.ikonBagian(jenis: string)
	return IKON[jenis]
end

function DropBentuk.spesifikasi(bentuk: any): { jenis: string, buah: { number }, aksen: { number }, skala: number }?
	if type(bentuk) ~= "table" or type(bentuk.jenis) ~= "string" then
		return nil
	end
	if not IKON[bentuk.jenis] then
		return nil
	end
	if type(bentuk.siap) ~= "table" or type(bentuk.aksen) ~= "table" then
		return nil
	end
	local w = type(bentuk.w) == "number" and bentuk.w or 1.4
	local skala = w * 0.55
	if skala < 0.7 then
		skala = 0.7
	elseif skala > 1.8 then
		skala = 1.8
	end
	return {
		jenis = bentuk.jenis,
		buah = { bentuk.siap[1] or 200, bentuk.siap[2] or 200, bentuk.siap[3] or 200 },
		aksen = { bentuk.aksen[1] or 110, bentuk.aksen[2] or 160, bentuk.aksen[3] or 90 },
		skala = skala,
	}
end

return DropBentuk

end)()

local MOD_DuniaLogic = (function()
local DuniaLogic = {}

DuniaLogic.SaveEvery = 60
DuniaLogic.MaxPlots = 500
DuniaLogic.MaxMeja = 6
DuniaLogic.MaxDrops = 80
DuniaLogic.MaksPukulSimpan = 5

function DuniaLogic.keyFor(userId: number): string
        return "d_" .. tostring(userId)
end

function DuniaLogic.cleanName(nama: any): string?
        if type(nama) ~= "string" then
                return nil
        end
        local n = nama:gsub("^%s+", ""):gsub("%s+$", "")
        if #n < 1 or #n > 30 then
                return nil
        end
        return n
end

function DuniaLogic.serPlots(planted: any): { [number]: { c: string, r: number, h: number, l: number } }
        local out = {}
        if type(planted) ~= "table" then
                return out
        end
        for idx, rec in pairs(planted) do
                if
                        type(idx) == "number"
                        and idx >= 0
                        and idx < DuniaLogic.MaxPlots
                        and idx == math.floor(idx)
                        and type(rec) == "table"
                        and type(rec.crop) == "string"
                        and #rec.crop <= 40
                        and type(rec.readyAt) == "number"
                        and rec.readyAt == rec.readyAt
                then
                        local h = type(rec.hits) == "number" and rec.hits or 0
                        local l = type(rec.lastHit) == "number" and rec.lastHit or 0
                        h = math.clamp(math.floor(h), 0, DuniaLogic.MaksPukulSimpan)
                        l = (l == l and l >= 0 and l ~= math.huge) and math.floor(l) or 0
                        out[idx] = { c = rec.crop, r = math.floor(rec.readyAt), h = h, l = l }
                end
        end
        return out
end

function DuniaLogic.desPlots(arr: any): { [number]: { c: string, r: number, h: number, l: number } }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for idx, rec in pairs(arr) do
                if
                        type(idx) == "number"
                        and idx >= 0
                        and idx < DuniaLogic.MaxPlots
                        and idx == math.floor(idx)
                        and type(rec) == "table"
                        and type(rec.c) == "string"
                        and #rec.c <= 40
                        and type(rec.r) == "number"
                        and rec.r == rec.r
                then
                        local h = type(rec.h) == "number" and rec.h or 0
                        local l = type(rec.l) == "number" and rec.l or 0
                        h = math.clamp(math.floor(h), 0, DuniaLogic.MaksPukulSimpan)
                        l = (l == l and l >= 0 and l ~= math.huge) and math.floor(l) or 0
                        out[idx] = { c = rec.c, r = math.floor(rec.r), h = h, l = l }
                end
        end
        return out
end

function DuniaLogic.serDrops(items: any): { any }
        local out = {}
        if type(items) ~= "table" then
                return out
        end
        for _, d in ipairs(items) do
                if #out >= DuniaLogic.MaxDrops then
                        break
                end
                if
                        type(d) == "table"
                        and type(d.id) == "string"
                        and #d.id <= 24
                        and type(d.crop) == "string"
                        and #d.crop <= 40
                        and type(d.count) == "number"
                        and d.count == d.count
                        and d.count >= 1
                        and d.count <= 250
                        and d.count == math.floor(d.count)
                        and type(d.pos) == "table"
                        and type(d.pos.x) == "number"
                        and type(d.pos.y) == "number"
                        and type(d.pos.z) == "number"
                        and d.pos.x == d.pos.x
                        and d.pos.y == d.pos.y
                        and d.pos.z == d.pos.z
                then
                        table.insert(out, {
                                i = d.id,
                                c = d.crop,
                                n = math.floor(d.count),
                                p = { x = d.pos.x, y = d.pos.y, z = d.pos.z },
                        })
                end
        end
        return out
end

function DuniaLogic.desDrops(arr: any): { any }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for _, d in ipairs(arr) do
                if #out >= DuniaLogic.MaxDrops then
                        break
                end
                if
                        type(d) == "table"
                        and type(d.i) == "string"
                        and #d.i <= 24
                        and type(d.c) == "string"
                        and #d.c <= 40
                        and type(d.n) == "number"
                        and d.n == d.n
                        and d.n >= 1
                        and d.n <= 250
                        and d.n == math.floor(d.n)
                        and type(d.p) == "table"
                        and type(d.p.x) == "number"
                        and type(d.p.y) == "number"
                        and type(d.p.z) == "number"
                        and d.p.x == d.p.x
                        and d.p.y == d.p.y
                        and d.p.z == d.p.z
                then
                        table.insert(out, {
                                id = d.i,
                                crop = d.c,
                                count = math.floor(d.n),
                                pos = { x = d.p.x, y = d.p.y, z = d.p.z },
                        })
                end
        end
        return out
end

function DuniaLogic.serMesin(batch: any): { { c: string, j: number, m: number, b: number, k: number } }
        local out = {}
        if type(batch) ~= "table" then
                return out
        end
        if type(batch.c) == "string" and #batch.c <= 40 and type(batch.j) == "number" then
                table.insert(out, {
                        c = batch.c,
                        j = math.max(1, math.floor(batch.j)),
                        m = type(batch.m) == "number" and math.max(0, math.floor(batch.m)) or 0,
                        b = type(batch.b) == "number" and math.max(0, math.floor(batch.b)) or 0,
                        k = type(batch.k) == "number" and math.max(0, math.floor(batch.k)) or 0,
                })
        end
        return out
end

function DuniaLogic.desMesin(arr: any): { { c: string, j: number?, m: number?, b: number?, k: number?, h: number? } }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for _, s in ipairs(arr) do
                if #out < 1 and type(s) == "table" then
                        if type(s.c) == "string" and #s.c <= 40 and type(s.j) == "number" then
                                table.insert(out, {
                                        c = s.c,
                                        j = math.max(1, math.floor(s.j)),
                                        m = type(s.m) == "number" and math.max(0, math.floor(s.m)) or nil,
                                        b = type(s.b) == "number" and math.max(0, math.floor(s.b)) or nil,
                                        k = type(s.k) == "number" and math.max(0, math.floor(s.k)) or nil,
                                })
                        elseif type(s.c) == "string" and #s.c <= 40 and type(s.h) == "number" then
                                table.insert(out, { c = s.c, j = 1, h = math.max(1, math.floor(s.h)) })
                        end
                end
        end
        return out
end

return DuniaLogic

end)()

local MOD_GudangLogic = (function()
local GudangLogic = {}

GudangLogic.MaksSlot = 1000
GudangLogic.MaksIsi = 250

function GudangLogic.baru(): { s: { { id: string, count: number } } }
        return { s = {} }
end

function GudangLogic.terpakai(gd: any): number
        if type(gd) ~= "table" or type(gd.s) ~= "table" then
                return 0
        end
        return #gd.s
end

function GudangLogic.simpan(gd: any, id: any, n: any, byId: any?): (boolean, string)
        if type(id) ~= "string" or #id == 0 or #id > 40 or (byId ~= nil and type(byId) == "table" and not byId[id]) then
                return false, "Barang tidak sah."
        end
        if type(n) ~= "number" or n ~= n or n % 1 ~= 0 or n < 1 or n > GudangLogic.MaksIsi then
                return false, "Jumlah setor harus 1 sampai 250."
        end
        if GudangLogic.terpakai(gd) >= GudangLogic.MaksSlot then
                return false, "Gudang penuh! Tampungan 1000 sudah habis."
        end
        table.insert(gd.s, { id = id, count = n })
        return true, "Tampungan terpakai " .. GudangLogic.terpakai(gd) .. "/" .. GudangLogic.MaksSlot .. " (sisa " .. GudangLogic.MaksSlot - GudangLogic.terpakai(gd) .. ")."
end

function GudangLogic.ambil(gd: any, i: any, n: any): (boolean, string, number)
        if type(i) ~= "number" or i ~= i or i % 1 ~= 0 or i < 1 or i > GudangLogic.terpakai(gd) then
                return false, "Slot gudang tidak ada.", 0
        end
        local s = gd.s[i]
        if type(n) ~= "number" or n ~= n or n % 1 ~= 0 or n < 1 then
                n = s.count
        end
        n = math.max(1, math.min(math.floor(n), s.count, GudangLogic.MaksIsi))
        return true, "OK", n
end

function GudangLogic.kurangi(gd: any, i: number, n: number)
        local s = gd.s[i]
        if not s then
                return
        end
        s.count -= n
        if s.count <= 0 then
                table.remove(gd.s, i)
        end
end

function GudangLogic.ser(gd: any, byId: any?): { { id: string, count: number } }
        local out = {}
        if type(gd) ~= "table" or type(gd.s) ~= "table" then
                return out
        end
        for _, s in ipairs(gd.s) do
                if #out >= GudangLogic.MaksSlot then
                        break
                end
                if type(s) == "table" and type(s.id) == "string" and #s.id <= 40 and type(s.count) == "number" and s.count == s.count and s.count >= 1 and (byId == nil or type(byId) ~= "table" or byId[s.id] ~= nil) then
                        table.insert(out, { id = s.id, count = math.min(GudangLogic.MaksIsi, math.floor(s.count)) })
                end
        end
        return out
end

function GudangLogic.des(x: any, byId: any?): { s: { { id: string, count: number } } }
        local gd = GudangLogic.baru()
        if type(x) ~= "table" then
                return gd
        end
        for _, s in ipairs(x) do
                if #gd.s >= GudangLogic.MaksSlot then
                        break
                end
                if type(s) == "table" and type(s.id) == "string" and #s.id <= 40 and type(s.count) == "number" and s.count == s.count and s.count >= 1 and (byId == nil or type(byId) ~= "table" or byId[s.id] ~= nil) then
                        table.insert(gd.s, { id = s.id, count = math.min(GudangLogic.MaksIsi, math.floor(s.count)) })
                end
        end
        return gd
end

return GudangLogic

end)()

local MOD_HUDLayout = (function()
local HUDLayout = {}

HUDLayout.SaldoSkalaX = 0.012
HUDLayout.SaldoSkalaY = 0.02
HUDLayout.SaldoSkalaLebar = 0.26
HUDLayout.SaldoSkalaTinggi = 0.085
HUDLayout.SaldoLebarMin = 150
HUDLayout.SaldoLebarMaks = 560
HUDLayout.SaldoPadX = 8
HUDLayout.SaldoGapX = 8
HUDLayout.SaldoIkonPx = 26
HUDLayout.SaldoTeksPx = 22
HUDLayout.SaldoSatuanPx = 15
HUDLayout.SaldoEm = 0.62
HUDLayout.IkonSkalaX = 0.035
HUDLayout.IkonSkalaY = 0.14
HUDLayout.IkonSkalaLebar = 0.15
HUDLayout.IkonSkalaTinggi = 0.72
HUDLayout.AngkaSkalaX = 0.215
HUDLayout.AngkaSkalaLebar = 0.53
HUDLayout.SatuanSkalaX = 0.775
HUDLayout.SatuanSkalaLebar = 0.21
HUDLayout.NavSkalaY = 0.125
HUDLayout.NavGapSkala = 0.02
HUDLayout.NavSkalaLebarMin = 0.185
HUDLayout.NavSkalaLebarMaks = 0.34
HUDLayout.NavSkalaTinggi = 0.072
HUDLayout.NavTinggiMin = 26
HUDLayout.NavTinggiMaks = 52
HUDLayout.NavIsiPx = 24
HUDLayout.NavTambahanMaks = 40
HUDLayout.TasSkalaLebar = 0.17
HUDLayout.TasLebarMin = 90
HUDLayout.TasLebarMaks = 200
HUDLayout.TeksMaks = 22
HUDLayout.TeksMin = 11

function HUDLayout.areaAman(vpX: number, vpY: number, insetKiri: number, insetAtas: number): { [string]: number }
        local kiri = math.clamp(insetKiri or 0, 0, vpX)
        local atas = math.clamp(insetAtas or 0, 0, vpY)
        return {
                kiri = kiri,
                atas = atas,
                lebar = math.max(vpX - kiri, 0),
                tinggi = math.max(vpY - atas, 0),
        }
end

function HUDLayout.batasSaldo(aman: { [string]: number }): { [string]: number }
        local lebar = math.clamp(aman.lebar * HUDLayout.SaldoSkalaLebar, HUDLayout.SaldoLebarMin, HUDLayout.SaldoLebarMaks)
        local tinggi = aman.tinggi * HUDLayout.SaldoSkalaTinggi
        return { lebar = lebar, tinggi = tinggi }
end

function HUDLayout.rectSaldo(vpX: number, vpY: number, insetKiri: number, insetAtas: number): { [string]: number }
        local aman = HUDLayout.areaAman(vpX, vpY, insetKiri, insetAtas)
        local b = HUDLayout.batasSaldo(aman)
        return {
                x = aman.kiri + aman.lebar * HUDLayout.SaldoSkalaX,
                y = aman.atas + aman.tinggi * HUDLayout.SaldoSkalaY,
                w = b.lebar,
                h = b.tinggi,
        }
end

function HUDLayout.lebarTeksPx(teks: any, ukuran: number): number
        if type(teks) ~= "string" then
                return 0
        end
        return math.max(1, math.floor(#teks * ukuran * HUDLayout.SaldoEm + 0.5))
end

function HUDLayout.lebarSaldoPx(teksAngka: any, adaSatuan: boolean): number
        local w = HUDLayout.SaldoPadX * 2 + HUDLayout.SaldoIkonPx + HUDLayout.SaldoGapX * 2
                + HUDLayout.lebarTeksPx(teksAngka, HUDLayout.SaldoTeksPx)
        if adaSatuan then
                w += HUDLayout.lebarTeksPx("Micda", HUDLayout.SaldoSatuanPx)
        end
        return math.clamp(w, HUDLayout.SaldoLebarMin, HUDLayout.SaldoLebarMaks)
end

function HUDLayout.muatLayar(vpX: number, teksAngka: any, adaSatuan: boolean, insetKiri: number): boolean
        local kiri = math.clamp(insetKiri or 0, 0, vpX)
        local x0 = kiri + (vpX - kiri) * HUDLayout.SaldoSkalaX
        return x0 + HUDLayout.lebarSaldoPx(teksAngka, adaSatuan) <= vpX + 0.5
end

function HUDLayout.batasNav(aman: { [string]: number }): { [string]: number }
        local minim = aman.lebar * HUDLayout.NavSkalaLebarMin
        local maks = math.max(aman.lebar * HUDLayout.NavSkalaLebarMaks, minim + HUDLayout.NavTambahanMaks)
        local tinggi = math.clamp(aman.tinggi * HUDLayout.NavSkalaTinggi, HUDLayout.NavTinggiMin, HUDLayout.NavTinggiMaks)
        return { minim = minim, maks = maks, tinggi = tinggi }
end

function HUDLayout.batasTas(aman: { [string]: number }): { [string]: number }
        local lebar = math.clamp(aman.lebar * HUDLayout.TasSkalaLebar, HUDLayout.TasLebarMin, HUDLayout.TasLebarMaks)
        return { lebar = lebar, tinggi = aman.tinggi * HUDLayout.SaldoSkalaTinggi }
end

function HUDLayout.rectNav(vpX: number, vpY: number, insetKiri: number, insetAtas: number, teksLebarPx: number): { [string]: number }
        local aman = HUDLayout.areaAman(vpX, vpY, insetKiri, insetAtas)
        local b = HUDLayout.batasNav(aman)
        local w = math.clamp((teksLebarPx or 0) + HUDLayout.NavIsiPx, b.minim, b.maks)
        local terpotong = (teksLebarPx or 0) + HUDLayout.NavIsiPx > b.maks
        return {
                x = aman.kiri + aman.lebar * HUDLayout.SaldoSkalaX,
                y = aman.atas + aman.tinggi * HUDLayout.NavSkalaY,
                w = w,
                h = b.tinggi,
                terpotong = terpotong,
                minim = b.minim,
                maks = b.maks,
        }
end

function HUDLayout.diDalam(dalam: { [string]: number }, luar: { [string]: number }): boolean
        return dalam.x >= luar.x and dalam.y >= luar.y and dalam.x + dalam.w <= luar.x + luar.w and dalam.y + dalam.h <= luar.y + luar.h
end

function HUDLayout.tumpangTindih(a: { [string]: number }, b: { [string]: number }): boolean
        return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

return HUDLayout

end)()

local MOD_IkonJempol = (function()
local IkonJempol = {}

IkonJempol.Bagian = {
        { dx = 0.14, dy = 0.34, dw = 0.52, dh = 0.48, bentuk = "kotak" },
        { dx = 0.14, dy = 0.22, dw = 0.13, dh = 0.20, bentuk = "lingkaran" },
        { dx = 0.30, dy = 0.16, dw = 0.13, dh = 0.20, bentuk = "lingkaran" },
        { dx = 0.46, dy = 0.18, dw = 0.13, dh = 0.20, bentuk = "lingkaran" },
        { dx = 0.60, dy = 0.26, dw = 0.12, dh = 0.18, bentuk = "lingkaran" },
        { dx = 0.02, dy = 0.44, dw = 0.16, dh = 0.34, bentuk = "kotak" },
        { dx = 0.20, dy = 0.40, dw = 0.40, dh = 0.05, bentuk = "garis" },
        { dx = 0.20, dy = 0.52, dw = 0.40, dh = 0.05, bentuk = "garis" },
        { dx = 0.20, dy = 0.64, dw = 0.40, dh = 0.05, bentuk = "garis" },
}

function IkonJempol.bagian(): { any }
        local out = {}
        for _, g in ipairs(IkonJempol.Bagian) do
                table.insert(out, { dx = g.dx, dy = g.dy, dw = g.dw, dh = g.dh, bentuk = g.bentuk })
        end
        return out
end

function IkonJempol.valid(): boolean
        for _, g in ipairs(IkonJempol.Bagian) do
                if g.dx < 0 or g.dy < 0 or g.dx + g.dw > 1 or g.dy + g.dh > 1 then
                        return false
                end
                if g.dw <= 0 or g.dh <= 0 then
                        return false
                end
        end
        return #IkonJempol.Bagian >= 4
end

return IkonJempol

end)()

local MOD_IkonKoin = (function()
local IkonKoin = {}

function IkonKoin.ukuran(pxTeks: any): number
	local v = tonumber(pxTeks)
	if type(v) ~= "number" or v ~= v then
		return 12
	end
	return math.max(12, math.floor(v * 1.05 + 0.5))
end

function IkonKoin.buat(parent: Instance?, ukuran: number?): Frame
	local px = IkonKoin.ukuran(ukuran or 20)
	local wadah = Instance.new("Frame")
	wadah.Name = "IkonKoin"
	wadah.Size = UDim2.fromOffset(px, px)
	wadah.BackgroundTransparency = 1
	local lingkar = Instance.new("Frame")
	lingkar.Name = "Koin"
	lingkar.Size = UDim2.fromScale(1, 1)
	lingkar.BackgroundColor3 = Color3.fromRGB(255, 199, 71)
	lingkar.BorderSizePixel = 0
	lingkar.Parent = wadah
	local sudut = Instance.new("UICorner")
	sudut.CornerRadius = UDim.new(0.5, 0)
	sudut.Parent = lingkar
	local gradasi = Instance.new("UIGradient")
	gradasi.Color = ColorSequence.new(Color3.fromRGB(255, 226, 132), Color3.fromRGB(199, 133, 28))
	gradasi.Rotation = 105
	gradasi.Parent = lingkar
	local tepi = Instance.new("UIStroke")
	tepi.Color = Color3.fromRGB(148, 94, 16)
	tepi.Thickness = math.max(1, math.floor(px / 11))
	tepi.Transparency = 0.12
	tepi.Parent = lingkar
	local kilau = Instance.new("Frame")
	kilau.Name = "Kilau"
	kilau.AnchorPoint = Vector2.new(0.5, 0.5)
	kilau.Position = UDim2.fromScale(0.34, 0.3)
	kilau.Size = UDim2.fromScale(0.36, 0.24)
	kilau.Rotation = -28
	kilau.BackgroundColor3 = Color3.fromRGB(255, 247, 219)
	kilau.BackgroundTransparency = 0.4
	kilau.BorderSizePixel = 0
	kilau.Parent = lingkar
	local sudutKilau = Instance.new("UICorner")
	sudutKilau.CornerRadius = UDim.new(0.5, 0)
	sudutKilau.Parent = kilau
	wadah.Parent = parent
	return wadah
end

return IkonKoin

end)()

local MOD_JualLogic = (function()
local JualLogic = {}

function JualLogic.saring(teks: any, maks: number): number?
        if type(teks) ~= "string" and type(teks) ~= "number" then
                return nil
        end
        local n = tonumber(teks)
        if not n or n ~= n or n % 1 ~= 0 or n < 1 then
                return nil
        end
        n = math.floor(n)
        if type(maks) == "number" then
                if maks < 1 then
                        return nil
                end
                if n > maks then
                        n = maks
                end
        end
        if n < 1 then
                return nil
        end
        return n
end

function JualLogic.total(unit: number, n: number): number
        return math.floor(unit) * math.floor(n)
end

return JualLogic

end)()

local MOD_KameraKunci = (function()
local KameraKunci = {}

local JARAK_MIN = 0.5
local JARAK_MAKS = 128

function KameraKunci.batas(): (number, number)
	return JARAK_MIN, JARAK_MAKS
end

function KameraKunci.jepit(jarak: any): number
	if type(jarak) ~= "number" or jarak ~= jarak then
		return JARAK_MIN
	end
	if jarak < JARAK_MIN then
		return JARAK_MIN
	end
	if jarak > JARAK_MAKS then
		return JARAK_MAKS
	end
	return jarak
end

function KameraKunci.kunci(minLama: any, maxLama: any, jarak: any): (number, number, { any })
	local j = KameraKunci.jepit(jarak)
	local simpan = {
		min = KameraKunci.jepit(minLama),
		max = KameraKunci.jepit(maxLama),
	}
	if simpan.max < simpan.min then
		simpan.max = simpan.min
	end
	return j, j, simpan
end

function KameraKunci.buka(tersimpan: any): (number, number)
	if type(tersimpan) == "table" and type(tersimpan.min) == "number" and type(tersimpan.max) == "number" then
		local mn = KameraKunci.jepit(tersimpan.min)
		local mx = KameraKunci.jepit(tersimpan.max)
		if mx < mn then
			mx = mn
		end
		return mn, mx
	end
	return JARAK_MIN, JARAK_MAKS
end

return KameraKunci

end)()

local MOD_KlaimDrop = (function()
local KlaimDrop = {}

KlaimDrop.JarakAmbil = 14

function KlaimDrop.baru(owner: number): any
        return { owner = owner, status = "ada", id = nil }
end

function KlaimDrop.valid(rec: any): boolean
        return type(rec) == "table" and rec.status == "ada"
end

function KlaimDrop.coba(rec: any, userId: number, dist: number): (boolean, string)
        if type(rec) ~= "table" then
                return false, "rusak"
        end
        if rec.owner ~= userId then
                return false, "bukan_milik"
        end
        if rec.status ~= "ada" then
                return false, "sudah_diambil"
        end
        if type(dist) ~= "number" or dist ~= dist or dist > KlaimDrop.JarakAmbil then
                return false, "jarak"
        end
        rec.status = "proses"
        return true, "ok"
end

function KlaimDrop.selesai(rec: any, userId: number): boolean
        if type(rec) ~= "table" or rec.status ~= "proses" or rec.owner ~= userId then
                return false
        end
        rec.status = "ambil"
        return true
end

function KlaimDrop.batalkan(rec: any, userId: number): boolean
        if type(rec) ~= "table" or rec.status ~= "proses" or rec.owner ~= userId then
                return false
        end
        rec.status = "ada"
        return true
end

return KlaimDrop

end)()

local MOD_KontrolHP = (function()
local KontrolHP = {}

KontrolHP.JumpSkala = 0.19
KontrolHP.PunchSkala = 0.175
KontrolHP.RasioPunch = KontrolHP.PunchSkala / KontrolHP.JumpSkala
KontrolHP.InsetSkala = 0.032
KontrolHP.GapSkala = 0.02
KontrolHP.GapMinPx = 12
KontrolHP.GapMaksPx = 20
KontrolHP.Anggaran = 0.45
KontrolHP.AnggaranKeras = 0.62
KontrolHP.BesarMin = 0.8
KontrolHP.BesarMaks = 1.0
KontrolHP.ZonaTanamX = 0.25
KontrolHP.ZonaTanamLebar = 0.35
KontrolHP.ZonaTanamY = 0.2
KontrolHP.ZonaTanamTinggi = 0.6
KontrolHP.ZonaJempolX = 0.45
KontrolHP.ZonaJempolY = 0.55

function KontrolHP.ukuranJump(vpX: number, vpY: number, jumpPx: number?): number
        if type(jumpPx) == "number" and jumpPx > 0 then
                return jumpPx
        end
        return KontrolHP.JumpSkala * math.min(vpX, vpY)
end

function KontrolHP.ukuranGap(vpX: number, vpY: number): number
        local g = KontrolHP.GapSkala * math.min(vpX, vpY)
        return math.clamp(g, KontrolHP.GapMinPx, KontrolHP.GapMaksPx)
end

function KontrolHP.posisiPunch(vpX: number, vpY: number, jumpPx: number?): { [string]: number }
        local j = KontrolHP.ukuranJump(vpX, vpY, jumpPx)
        local p = j * KontrolHP.RasioPunch
        local dasar = math.min(vpX, vpY)
        local inset = KontrolHP.InsetSkala * dasar
        local gap = KontrolHP.ukuranGap(vpX, vpY)
        local anggaran = KontrolHP.Anggaran * vpX
        local dariKanan = inset + j + gap + p
        if dariKanan > anggaran then
                gap = KontrolHP.GapMinPx
                dariKanan = inset + j + gap + p
                if dariKanan > anggaran then
                        local pBaru = math.max(KontrolHP.BesarMin * j, anggaran - inset - j - gap)
                        dariKanan -= p - pBaru
                        p = pBaru
                end
        end
        dariKanan = math.min(dariKanan, KontrolHP.AnggaranKeras * vpX)
        return {
                skalaX = 1 - dariKanan / vpX,
                skalaY = 1 - inset / vpY,
                skalaLebar = p / vpX,
                skalaTinggi = p / vpY,
                gapPx = gap,
                jumpPx = j,
                punchPx = p,
                dariKananPx = dariKanan,
                dariBawahPx = inset,
        }
end

function KontrolHP.rectJump(vpX: number, vpY: number, jumpPx: number?): { [string]: number }
        local j = KontrolHP.ukuranJump(vpX, vpY, jumpPx)
        local inset = KontrolHP.InsetSkala * math.min(vpX, vpY)
        return { x = vpX - inset - j, y = vpY - inset - j, w = j, h = j }
end

function KontrolHP.rectPunch(vpX: number, vpY: number, jumpPx: number?): { [string]: number }
        local pos = KontrolHP.posisiPunch(vpX, vpY, jumpPx)
        return { x = vpX - pos.dariKananPx, y = vpY - pos.dariBawahPx - pos.punchPx, w = pos.punchPx, h = pos.punchPx }
end

function KontrolHP.zonaTanam(vpX: number, vpY: number): { [string]: number }
        return {
                x = KontrolHP.ZonaTanamX * vpX,
                y = KontrolHP.ZonaTanamY * vpY,
                w = KontrolHP.ZonaTanamLebar * vpX,
                h = KontrolHP.ZonaTanamTinggi * vpY,
        }
end

function KontrolHP.tumpangTindih(a: { [string]: number }, b: { [string]: number }): boolean
        return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

function KontrolHP.valid(vpX: number, vpY: number, jumpPx: number?): (boolean, string)
        local pos = KontrolHP.posisiPunch(vpX, vpY, jumpPx)
        local pp = KontrolHP.rectPunch(vpX, vpY, jumpPx)
        local pj = KontrolHP.rectJump(vpX, vpY, jumpPx)
        if pp.x < 0 or pp.y < 0 or pp.x + pp.w > vpX + 0.5 or pp.y + pp.h > vpY + 0.5 then
                return false, "keluar layar"
        end
        local rasio = pos.punchPx / pos.jumpPx
        if rasio < KontrolHP.BesarMin - 0.001 or rasio > KontrolHP.BesarMaks + 0.001 then
                return false, "ukuran punch vs jump"
        end
        if pos.gapPx < KontrolHP.GapMinPx - 0.01 or pos.gapPx > KontrolHP.GapMaksPx + 0.5 then
                return false, "jarak punch-jump"
        end
        if pos.dariKananPx > KontrolHP.AnggaranKeras * vpX + 0.5 then
                return false, "molor dari jempol"
        end
        if KontrolHP.tumpangTindih(pp, pj) then
                return false, "menimpa jump"
        end
        if math.abs((pp.y + pp.h) - (pj.y + pj.h)) > 0.5 then
                return false, "dasar tidak segaris"
        end
        local cx = pp.x + pp.w / 2
        local cy = pp.y + pp.h / 2
        if cx < KontrolHP.ZonaJempolX * vpX or cy < KontrolHP.ZonaJempolY * vpY then
                return false, "di luar area jempol"
        end
        if KontrolHP.tumpangTindih(pp, KontrolHP.zonaTanam(vpX, vpY)) then
                return false, "menutupi area tanam"
        end
        return true, "ok"
end

return KontrolHP

end)()

local MOD_Layout = (function()
local Layout = {}

Layout.LahanCount = 24
Layout.Cols = 6
Layout.Rows = 4
Layout.SizeX = 240
Layout.SizeZ = 220
Layout.Gap = 40

Layout.PlotCols = 25
Layout.PlotRows = 20
Layout.PlotSize = 4
Layout.PlotPitch = 6
Layout.PlotBlockX = 10
Layout.PlotBlockZ = 30
Layout.PlotBlockW = 150
Layout.PlotBlockD = 120
Layout.PlotTopY = 1.4

function Layout.diAreaPlot(lx: number, lz: number): boolean
        return lx >= Layout.PlotBlockX and lx <= Layout.PlotBlockX + Layout.PlotBlockW
                and lz >= Layout.PlotBlockZ and lz <= Layout.PlotBlockZ + Layout.PlotBlockD
end

function Layout.cellOrigin(index: number): (number, number)
        local row = math.floor((index - 1) / Layout.Cols)
        local col = (index - 1) % Layout.Cols
        return col * (Layout.SizeX + Layout.Gap), row * (Layout.SizeZ + Layout.Gap)
end

function Layout.plotCount(): number
        return Layout.PlotCols * Layout.PlotRows
end

function Layout.plotLocal(idx: number): (number, number)
        local col = idx % Layout.PlotCols
        local row = math.floor(idx / Layout.PlotCols)
        local x = Layout.PlotBlockX + 1 + Layout.PlotSize / 2 + Layout.PlotPitch * col
        local z = Layout.PlotBlockZ + 1 + Layout.PlotSize / 2 + Layout.PlotPitch * row
        return x, z
end

function Layout.duniaOffsetX(): number
        return 5000
end

return Layout

end)()

local MOD_MesinLogika = (function()
local MesinLogika = {}

function MesinLogika.angkaJumlah(jumlah: any): number?
	if type(jumlah) ~= "number" or jumlah ~= jumlah or jumlah % 1 ~= 0 or jumlah < 1 then
		return nil
	end
	return math.floor(jumlah)
end

function MesinLogika.isiMesin(batch: any): number
	if type(batch) ~= "table" then
		return 0
	end
	if type(batch.jumlah) ~= "number" or batch.jumlah ~= batch.jumlah or batch.jumlah < 0 then
		return 0
	end
	return math.floor(batch.jumlah)
end

function MesinLogika.sisaKapasitas(batch: any, kapasitas: number): number
	local sisa = kapasitas - MesinLogika.isiMesin(batch)
	if sisa < 0 then
		return 0
	end
	return sisa
end

function MesinLogika.maksIsi(dimiliki: any, batch: any, kapasitas: number): number
	local d = 0
	if type(dimiliki) == "number" and dimiliki == dimiliki and dimiliki > 0 then
		d = math.floor(dimiliki)
	end
	local sisa = MesinLogika.sisaKapasitas(batch, kapasitas)
	if d < sisa then
		return d
	end
	return sisa
end

function MesinLogika.batchAktif(batch: any): boolean
	return type(batch) == "table" and batch.tahap ~= nil and batch.tahap ~= "kosong"
end

function MesinLogika.atur(batch: any, cropId: any, jumlah: any, dimiliki: any, kapasitas: number, namaA: any, namaB: any): (boolean, string)
	if type(cropId) ~= "string" then
		return false, "Hasil panen tidak dikenal."
	end
	if type(batch) == "table" and batch.tahap == "giling" then
		return false, "Mesin sedang menggiling " .. tostring(namaB) .. ". Tunggu sampai SEMAI TUNTAS."
	end
	if type(batch) == "table" and batch.tahap == "tuntas" then
		return false, "Klaim hasil " .. tostring(namaB) .. " dulu. Mesin masih berisi."
	end
	if MesinLogika.batchAktif(batch) and batch.crop ~= cropId then
		return false, "Mesin sedang memproses " .. tostring(namaB) .. ". Selesaikan semai itu dulu sebelum memasukkan item lain."
	end
	local n = MesinLogika.angkaJumlah(jumlah)
	if not n then
		return false, "Jumlah tidak sah. Isi angka bulat minimal 1."
	end
	local d = 0
	if type(dimiliki) == "number" and dimiliki == dimiliki and dimiliki > 0 then
		d = math.floor(dimiliki)
	end
	if d < 1 then
		return false, "Tidak ada " .. tostring(namaA) .. " di tas. Panen dulu hasilnya dengan Punch."
	end
	if n > d then
		return false, "Jumlah melebihi stok di tas! Ada " .. tostring(d) .. " " .. tostring(namaA) .. "."
	end
	local sisa = MesinLogika.sisaKapasitas(batch, kapasitas)
	if sisa < 1 then
		return false, "Kapasitas mesin penuh (" .. tostring(kapasitas) .. "/" .. tostring(kapasitas) .. "). Klaim isi mesin dulu."
	end
	if n > sisa then
		return false, "Jumlah melebihi sisa kapasitas mesin! Sisa " .. tostring(sisa) .. " lagi."
	end
	return true, ""
end

return MesinLogika

end)()

local MOD_PanenStatus = (function()
local PanenStatus = {}

function PanenStatus.hitung(records: any, t: number): { { id: string, siap: number, tumbuh: number } }
        local per: { [string]: { id: string, siap: number, tumbuh: number } } = {}
        local urut: { { id: string, siap: number, tumbuh: number } } = {}
        if type(records) ~= "table" then
                return urut
        end
        for _, rec in pairs(records) do
                if type(rec) == "table" and type(rec.crop) == "string" and #rec.crop <= 40 then
                        local key = rec.crop
                        local entri = per[key]
                        if not entri then
                                entri = { id = key, siap = 0, tumbuh = 0 }
                                per[key] = entri
                                table.insert(urut, entri)
                        end
                        local siap = type(rec.readyAt) == "number" and t >= rec.readyAt
                        if siap then
                                entri.siap += 1
                        else
                                entri.tumbuh += 1
                        end
                end
        end
        return urut
end

return PanenStatus

end)()

local MOD_PanenWaktu = (function()
local PanenWaktu = {}

PanenWaktu.HARVEST_EXPIRE_SECONDS = 900

function PanenWaktu.masihAman(leaveTime: any, now: number): boolean
        if type(leaveTime) ~= "number" or leaveTime ~= leaveTime or leaveTime <= 0 then
                return true
        end
        return now - leaveTime < PanenWaktu.HARVEST_EXPIRE_SECONDS
end

function PanenWaktu.sisaDetik(leaveTime: any, now: number): number
        if type(leaveTime) ~= "number" or leaveTime ~= leaveTime then
                return -1
        end
        local sisa = PanenWaktu.HARVEST_EXPIRE_SECONDS - (now - leaveTime)
        if sisa < 0 then
                return 0
        end
        return math.floor(sisa)
end

return PanenWaktu

end)()

local MOD_PukulAnim = (function()
local PukulAnim = {}

PukulAnim.Durasi = 0.32
PukulAnim.MomenKena = 0.12
PukulAnim.Ayunan = 1.85
PukulAnim.Ulang = 0.38

export type Fase = { memukul: boolean, kena: boolean, p: number, sudut: number }

function PukulAnim.fase(t0: number, t: number): Fase
	local dt = t - t0
	if dt < 0 or dt > PukulAnim.Durasi then
		return { memukul = false, kena = false, p = 0, sudut = 0 }
	end
	local p = dt / PukulAnim.Durasi
	local sudut
	if p < 0.24 then
		sudut = -0.45 * PukulAnim.Ayunan * math.sin(math.pi * p / 0.24)
	else
		sudut = PukulAnim.Ayunan * math.sin(math.pi * (p - 0.24) / 0.72)
	end
	return {
		memukul = true,
		kena = dt >= PukulAnim.MomenKena,
		p = p,
		sudut = sudut,
	}
end

function PukulAnim.mulaiUlang(t0Lama: number?, t: number): number
	return t
end

function PukulAnim.getar(tier: number): number
	local t = tier or 1
	if t < 1 then
		t = 1
	elseif t > 3 then
		t = 3
	end
	return 0.35 + 0.25 * (t - 1)
end

return PukulAnim

end)()

local MOD_PukulLogic = (function()
local PukulLogic = {}

PukulLogic.MaksPukul = 5
PukulLogic.Jendela = 8

function PukulLogic.catat(hits: number, lastHit: number, t: number, jendela: number?): (number, boolean)
        local h = type(hits) == "number" and hits or 0
        local l = type(lastHit) == "number" and lastHit or 0
        local j = type(jendela) == "number" and jendela or PukulLogic.Jendela
        local beruntun = (l > 0 and t - l <= j and t - l >= 0) and (h + 1) or 1
        if beruntun < 1 then
                beruntun = 1
        end
        return beruntun, beruntun >= PukulLogic.MaksPukul
end

return PukulLogic

end)()

local MOD_Recipes = (function()
local Recipes = {}

Recipes.List = {
        { a = "jeruk_mandarin", b = "grapefruit", out = "tangelo" },
        { a = "plum", b = "aprikot", out = "plumcot" },
        { a = "nektarin", b = "plum", out = "nectaplum" },
        { a = "arachis_duranensis", b = "arachis_ipaensis", out = "kacang_tanah" },
        { a = "ceri", b = "plum", out = "pluerry" },
        { a = "brassica_rapa", b = "brassica_oleracea", out = "canola" },
        { a = "gandum", b = "rye", out = "triticale" },
        { a = "labu_maxima", b = "labu_moschata", out = "tetsukabuto" },
}

function Recipes.find(a: string, b: string): string?
        for _, r in ipairs(Recipes.List) do
                if (r.a == a and r.b == b) or (r.a == b and r.b == a) then
                        return r.out
                end
        end
        return nil
end

return Recipes

end)()

local MOD_SanitasiTas = (function()
local SanitasiTas = {}

local MAX_SLOT = 50
local MAX_STACK = 250
local KIND_OK = { benih = true, hasil = true }

function SanitasiTas.bersih(raw: any, byId: any): ({ any }, number)
	local out = {}
	local dibuang = 0
	if type(byId) ~= "table" then
		if type(raw) == "table" then
			for _ in ipairs(raw) do
				dibuang += 1
			end
		end
		return out, dibuang
	end
	if type(raw) ~= "table" then
		return out, dibuang
	end
	for _, s in ipairs(raw) do
		local ok = false
		if #out < MAX_SLOT and type(s) == "table" and KIND_OK[s.kind] and type(s.id) == "string" and byId[s.id] then
			local n = tonumber(s.count)
			if n and n == n and n >= 1 then
				table.insert(out, { kind = s.kind, id = s.id, count = math.min(MAX_STACK, math.floor(n)) })
				ok = true
			end
		end
		if not ok then
			dibuang += 1
		end
	end
	return out, dibuang
end

function SanitasiTas.slotValid(s: any, byId: any): boolean
	if type(byId) ~= "table" then
		return false
	end
	if type(s) ~= "table" then
		return false
	end
	if s.kind ~= "benih" and s.kind ~= "hasil" then
		return false
	end
	if type(s.id) ~= "string" or not byId[s.id] then
		return false
	end
	local n = tonumber(s.count)
	return n ~= nil and n == n and n >= 1 and n <= MAX_STACK and n == math.floor(n)
end

return SanitasiTas

end)()

local MOD_SemaiLogic = (function()
local SemaiLogic = {}

SemaiLogic.UrutanTuas = { "kanan", "kiri" }

function SemaiLogic.saringJumlah(teks: any, dimiliki: any, kapasitas: number): number?
        if type(teks) ~= "string" and type(teks) ~= "number" then
                return nil
        end
        local n = tonumber(teks)
        if not n or n ~= n or n % 1 ~= 0 or n < 1 then
                return nil
        end
        n = math.floor(n)
        if type(dimiliki) ~= "number" or dimiliki < 1 then
                return nil
        end
        local maks = math.floor(dimiliki)
        if type(kapasitas) == "number" and kapasitas >= 1 and maks > kapasitas then
                maks = math.floor(kapasitas)
        end
        if n > maks then
                n = maks
        end
        if n < 1 then
                return nil
        end
        return n
end

function SemaiLogic.pukulanPerItem(cfg: any): number
        if type(cfg) ~= "table" or type(cfg.hits) ~= "number" or cfg.hits < 1 then
                return 1
        end
        return math.floor(cfg.hits)
end

function SemaiLogic.pukulanTotal(jumlah: number, perItem: number): number
        return math.floor(jumlah) * math.floor(perItem)
end

function SemaiLogic.gulung(rng: any, cfg: any, jumlah: number): { micda: number, benih: number }
        local jml = math.max(1, math.floor(jumlah))
        local mMin = 1
        local mMax = 1
        local pBenih = 0
        if type(cfg) == "table" then
                mMin = type(cfg.micdaMin) == "number" and math.max(0, cfg.micdaMin) or 1
                mMax = type(cfg.micdaMax) == "number" and math.max(mMin, cfg.micdaMax) or mMin
                pBenih = type(cfg.seed) == "number" and cfg.seed or 0
        end
        local micda = 0
        local benih = 0
        for _ = 1, jml do
                micda += rng:NextInteger(mMin, mMax)
                if rng:NextNumber() < pBenih then
                        benih += 1
                end
        end
        return { micda = micda, benih = benih }
end

function SemaiLogic.tuasBaru(): { kanan: boolean, kiri: boolean }
        return { kanan = false, kiri = false }
end

function SemaiLogic.saringSisi(sisi: any): string?
        if sisi == "kanan" or sisi == "kiri" then
                return sisi
        end
        return nil
end

function SemaiLogic.tuasBerikut(tuas: any): string?
        if type(tuas) ~= "table" then
                return nil
        end
        if tuas.kanan ~= true then
                return "kanan"
        end
        if tuas.kiri ~= true then
                return "kiri"
        end
        return nil
end

function SemaiLogic.tuasSelesai(tuas: any): boolean
        return type(tuas) == "table" and tuas.kanan == true and tuas.kiri == true
end

function SemaiLogic.prosesTekan(tuas: any, sisi: any): (boolean, string)
        local sisiBersih = SemaiLogic.saringSisi(sisi)
        if not sisiBersih then
                return false, "sisi"
        end
        if type(tuas) ~= "table" then
                return false, "tuas"
        end
        if tuas[sisiBersih] == true then
                return false, "sudah"
        end
        local berikut = SemaiLogic.tuasBerikut(tuas)
        if berikut ~= sisiBersih then
                return false, "urutan"
        end
        tuas[sisiBersih] = true
        return true, "ok"
end

return SemaiLogic

end)()

local MOD_SesiLogic = (function()
local SesiLogic = {}

SesiLogic.StaleDetik = 90

function SesiLogic.bisaAmbil(old: any, jobId: any, now: number): boolean
        if type(old) ~= "table" then
                return true
        end
        if old.j == nil or old.j == "" then
                return true
        end
        if old.j == jobId then
                return true
        end
        if type(old.t) ~= "number" then
                return true
        end
        return now - old.t >= SesiLogic.StaleDetik
end

function SesiLogic.kunciBaru(jobId: any, now: number): any
        return { j = tostring(jobId), t = math.floor(now) }
end

function SesiLogic.lepas(jobId: any): any
        return { j = "", t = 0 }
end

return SesiLogic

end)()

local MOD_SoalLogic = (function()
local SoalLogic = {}

local function sig(op: string, a: number, b: number): string
	return op .. ":" .. a .. ":" .. b
end

function SoalLogic.buat(rng: Random, nomor: number, used: { [string]: boolean }): { teks: string, jawab: number, op: string, a: number, b: number }
	local op: string
	if nomor <= 20 then
		op = rng:NextNumber() < 0.5 and "tambah" or "kurang"
	elseif nomor <= 35 then
		op = "kali"
	else
		op = "bagi"
	end
	local a, b, jawab = 2, 2, 4
	for _ = 1, 80 do
		if op == "tambah" then
			a = rng:NextInteger(12, 99)
			b = rng:NextInteger(7, 99)
			jawab = a + b
		elseif op == "kurang" then
			a = rng:NextInteger(25, 99)
			b = rng:NextInteger(6, a - 2)
			jawab = a - b
		elseif op == "kali" then
			a = rng:NextInteger(3, 15)
			b = rng:NextInteger(3, 12)
			jawab = a * b
		else
			b = rng:NextInteger(3, 12)
			local hasil = rng:NextInteger(3, 15)
			a = b * hasil
			jawab = hasil
		end
		if not used[sig(op, a, b)] then
			used[sig(op, a, b)] = true
			break
		end
	end
	local tanda = "+"
	if op == "kurang" then
		tanda = "-"
	elseif op == "kali" then
		tanda = "×"
	elseif op == "bagi" then
		tanda = "÷"
	end
	return { teks = tostring(a) .. " " .. tanda .. " " .. tostring(b) .. " = ?", jawab = jawab, op = op, a = a, b = b }
end

return SoalLogic

end)()

local MOD_StrukBeli = (function()
local StrukBeli = {}

function StrukBeli.rangkum(picks: { any }, byId: { [string]: any }): { any }
        local urut = {}
        local hitung: { [string]: number } = {}
        for _, id in ipairs(picks) do
                local kunci = tostring(id)
                if not hitung[kunci] then
                        hitung[kunci] = 0
                        table.insert(urut, id)
                end
                hitung[kunci] += 1
        end
        local rows = {}
        for _, id in ipairs(urut) do
                local info = byId and byId[id]
                local nama = (info and info.nama) or tostring(id)
                table.insert(rows, {
                        id = id,
                        nama = "Benih " .. nama,
                        count = hitung[tostring(id)],
                })
        end
        return rows
end

function StrukBeli.totalBaris(rows: { any }): number
        local n = 0
        for _, r in ipairs(rows) do
                n += r.count
        end
        return n
end

return StrukBeli

end)()

local MOD_TanahDrops = (function()
local TanahDrops = {}

TanahDrops.SELISIH_TENGGELAM = 0.05
TanahDrops.DUDUK_DIATAS = 0.08
TanahDrops.TIDUR_CEWAH = 2
TanahDrops.TIDUR_MAKS = 2.5

function TanahDrops.bagianBawah(rootY: number, setengah: number): number
        return rootY - setengah
end

function TanahDrops.tenggelam(rootBottomY: number, groundY: number): boolean
        return rootBottomY < groundY - TanahDrops.SELISIH_TENGGELAM
end

function TanahDrops.istirahatY(groundY: number, setengah: number): number
        return groundY + setengah + TanahDrops.DUDUK_DIATAS
end

function TanahDrops.harusTidur(settleTicks: number, umur: number): boolean
        return settleTicks >= TanahDrops.TIDUR_CEWAH or umur > TanahDrops.TIDUR_MAKS
end

function TanahDrops.perluNaik(rootBottomY: number, groundY: number, setengah: number): boolean
        return TanahDrops.tenggelam(rootBottomY, groundY) or rootBottomY < groundY
end

return TanahDrops

end)()

local MOD_TasLogic = (function()
export type Slot = { kind: string, id: string, count: number }

local TasLogic = {}

TasLogic.MaxSlots = 50
TasLogic.MaxStack = 250

function TasLogic.usedSlots(tas: { any }): number
        return #tas
end

function TasLogic.countOf(tas: { any }, kind: string, id: string): number
        local total = 0
        for _, s in ipairs(tas) do
                if s.kind == kind and s.id == id then
                        total += s.count
                end
        end
        return total
end

function TasLogic.roomFor(tas: { any }, kind: string, id: string, want: number): number
        local room = 0
        for _, s in ipairs(tas) do
                if s.kind == kind and s.id == id then
                        room += TasLogic.MaxStack - s.count
                end
        end
        local used = #tas
        if used < TasLogic.MaxSlots then
                room += (TasLogic.MaxSlots - used) * TasLogic.MaxStack
        end
        if room > want then
                return want
        end
        return room
end

function TasLogic.add(tas: { any }, kind: string, id: string, count: number): number
        local left = count
        for _, s in ipairs(tas) do
                if left <= 0 then
                        break
                end
                if s.kind == kind and s.id == id and s.count < TasLogic.MaxStack then
                        local put = math.min(TasLogic.MaxStack - s.count, left)
                        s.count += put
                        left -= put
                end
        end
        while left > 0 do
                if #tas >= TasLogic.MaxSlots then
                        break
                end
                local put = math.min(TasLogic.MaxStack, left)
                table.insert(tas, { kind = kind, id = id, count = put })
                left -= put
        end
        return count - left
end

function TasLogic.remove(tas: { any }, kind: string, id: string, count: number): number
        local left = count
        for i = #tas, 1, -1 do
                if left <= 0 then
                        break
                end
                local s = tas[i]
                if s.kind == kind and s.id == id then
                        local take = math.min(s.count, left)
                        s.count -= take
                        left -= take
                        if s.count <= 0 then
                                table.remove(tas, i)
                        end
                end
        end
        return count - left
end

function TasLogic.ringkas(tas: { any }, kind: string): { { id: string, count: number } }
        local urutan, total = {}, {}
        for _, s in ipairs(tas) do
                if s.kind == kind and type(s.id) == "string" and type(s.count) == "number" and s.count == s.count and s.count > 0 then
                        if not total[s.id] then
                                total[s.id] = 0
                                table.insert(urutan, s.id)
                        end
                        total[s.id] += math.floor(s.count)
                end
        end
        local out = {}
        for _, id in ipairs(urutan) do
                table.insert(out, { id = id, count = total[id] })
        end
        return out
end

function TasLogic.canFitBatch(tas: { any }, items: { any }): boolean
        local clone = {}
        for i, s in ipairs(tas) do
                clone[i] = { kind = s.kind, id = s.id, count = s.count }
        end
        for _, it in ipairs(items) do
                local put = TasLogic.add(clone, it.kind, it.id, it.count)
                if put < it.count then
                        return false
                end
        end
        return true
end

return TasLogic

end)()

local MOD_UIStyle = (function()
local UIStyle = {}

UIStyle.Latar = { 23, 25, 30 }
UIStyle.Permukaan = { 32, 35, 42 }
UIStyle.PermukaanAktif = { 48, 54, 66 }
UIStyle.Teks = { 240, 241, 244 }
UIStyle.Abu = { 148, 154, 165 }
UIStyle.AbuGelap = { 96, 102, 112 }
UIStyle.Aksen = { 138, 158, 184 }
UIStyle.Hijau = { 62, 142, 90 }
UIStyle.Merah = { 178, 84, 72 }
UIStyle.Kuning = { 255, 214, 110 }

UIStyle.Font = "Gotham"
UIStyle.FontTebal = "GothamBold"
UIStyle.FontHitam = "GothamBlack"

UIStyle.UkuranJudul = 19
UIStyle.UkuranIsi = 15
UIStyle.UkuranKecil = 12

UIStyle.Sudut = 8
UIStyle.SudutKecil = 6
UIStyle.AmanAtas = 56
UIStyle.LebarPanelMaks = 640
UIStyle.TinggiPanelMaks = 480

UIStyle.NamaMaks = 18

function UIStyle.cekTigaUkuran(): boolean
        local n = 0
        for _, _ in pairs({ judul = UIStyle.UkuranJudul, isi = UIStyle.UkuranIsi, kecil = UIStyle.UkuranKecil }) do
                n += 1
        end
        return n == 3
end

function UIStyle.tabTampak(tab: string): { [string]: boolean }
        local penuh = {
                tanam = { daftarTanam = true, angka = true, mulai = true, gabung = false, status = false, soal = false },
                gabung = { daftarTanam = false, angka = false, mulai = false, gabung = true, status = false, soal = false },
                status = { daftarTanam = false, angka = false, mulai = false, gabung = false, status = true, soal = false },
        }
        local p = penuh[tab]
        if not p then
                return { daftarTanam = false, angka = false, mulai = false, gabung = false, status = false, soal = false }
        end
        return p
end

function UIStyle.tabTunggal(tab: string): boolean
        local t = UIStyle.tabTampak(tab)
        local n = 0
        if t.daftarTanam then
                n += 1
        end
        if t.gabung then
                n += 1
        end
        if t.status then
                n += 1
        end
        return n == 1 and t.daftarTanam == (t.angka and t.mulai)
end

function UIStyle.potong(nama: any, maks: number?): string
        if type(nama) ~= "string" then
                return "?"
        end
        local m = type(maks) == "number" and maks or UIStyle.NamaMaks
        if #nama <= m then
                return nama
        end
        return string.sub(nama, 1, m - 1) .. "…"
end

return UIStyle

end)()

local MOD_UangLogic = (function()
local UangLogic = {}

UangLogic.MaksSaldo = 1000000000000000
UangLogic.BatasLedger = 24

UangLogic.Alasan = {
	jual_hasil = true,
	beli_benih = true,
	semai_hasil = true,
	hadiah = true,
}

function UangLogic.baru(saldoAwal: number): any
	local m = math.max(0, math.floor(tonumber(saldoAwal) or 0))
	if m > UangLogic.MaksSaldo then
		m = UangLogic.MaksSaldo
	end
	return {
		m = m,
		ledger = {},
	}
end

function UangLogic.sah(nilai: any): boolean
	if type(nilai) ~= "number" or nilai ~= nilai or nilai == math.huge or nilai == -math.huge then
		return false
	end
	if nilai <= 0 or nilai ~= math.floor(nilai) then
		return false
	end
	return true
end

function UangLogic.alasanOk(reason: any): boolean
	if type(reason) ~= "string" then
		return false
	end
	return UangLogic.Alasan[reason] == true
end

function UangLogic.format(n: number): string
	if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then
		return tostring(n)
	end
	local neg = n < 0
	local v = math.floor(math.abs(n))
	local parts = {}
	repeat
		table.insert(parts, 1, string.format("%03d", v % 1000))
		v = math.floor(v / 1000)
	until v == 0
	parts[1] = tostring(tonumber(parts[1]))
	return (neg and "-" or "") .. table.concat(parts, ".")
end

function UangLogic.saldo(st: any): number
	if type(st) ~= "table" or type(st.m) ~= "number" then
		return 0
	end
	return st.m
end

function UangLogic.ruangSisa(st: any): number
	local sisa = UangLogic.MaksSaldo - UangLogic.saldo(st)
	if sisa < 0 then
		return 0
	end
	return sisa
end

local function catat(st: any, now: number, delta: number, reason: string)
	table.insert(st.ledger, { t = math.floor(now), d = delta, r = reason, s = "ok" })
	while #st.ledger > UangLogic.BatasLedger do
		table.remove(st.ledger, 1)
	end
end

local function gerbang(st: any, amount: any, reason: any, arah: string): (boolean, string)
	if not UangLogic.sah(amount) then
		return false, "Jumlah Micda tidak sah."
	end
	if not UangLogic.alasanOk(reason) then
		return false, "Alasan transaksi tidak sah."
	end
	if arah == "masuk" then
		local sisa = UangLogic.ruangSisa(st)
		if sisa < 1 then
			return false, "Rekening Micda sudah penuh! Batas maksimal " .. UangLogic.format(UangLogic.MaksSaldo) .. " Micda (1000 T)."
		end
		if amount > sisa then
			return false, "Ruangan Micda tinggal " .. UangLogic.format(sisa) .. "! Lakukan dalam bagian lebih kecil."
		end
	else
		if UangLogic.saldo(st) < amount then
			return false, "Micda tidak cukup."
		end
	end
	return true, "ok"
end

function UangLogic.tambah(st: any, amount: any, reason: any, now: number): (boolean, string)
	local ok, msg = gerbang(st, amount, reason, "masuk")
	if not ok then
		return false, msg
	end
	st.m += amount
	catat(st, now, amount, tostring(reason))
	return true, "ok"
end

function UangLogic.bayar(st: any, amount: any, reason: any, now: number): (boolean, string)
	local ok, msg = gerbang(st, amount, reason, "keluar")
	if not ok then
		return false, msg
	end
	st.m -= amount
	catat(st, now, -amount, tostring(reason))
	return true, "ok"
end

function UangLogic.ledgerOf(st: any): { any }
	local out = {}
	for _, l in ipairs(st.ledger) do
		table.insert(out, { t = l.t, d = l.d, r = l.r, s = l.s })
	end
	return out
end

return UangLogic

end)()

local MOD_UangSingkat = (function()
local UangSingkat = {}

local SATUAN = {
	{ ambang = 1000000000000, nama = "T" },
	{ ambang = 1000000000, nama = "M" },
	{ ambang = 1000000, nama = "Jt" },
	{ ambang = 1000, nama = "Rb" },
}

local function bersih(nilai: any): number
	local n = tonumber(nilai)
	if not n or n ~= n or n == math.huge or n == -math.huge or n < 0 then
		return 0
	end
	return math.floor(n)
end

local function bertitik(v: number): string
	local parts = {}
	local x = math.floor(v)
	repeat
		table.insert(parts, 1, string.format("%03d", x % 1000))
		x = math.floor(x / 1000)
	until x == 0
	parts[1] = tostring(tonumber(parts[1]))
	return table.concat(parts, ".")
end

function UangSingkat.penuh(nilai: any): string
	return bertitik(bersih(nilai))
end

function UangSingkat.singkat(nilai: any): string
	local n = bersih(nilai)
	for _, s in ipairs(SATUAN) do
		if n >= s.ambang then
			local utuh = (n - n % s.ambang) / s.ambang
			local sisa = n % s.ambang
			local langkah = s.ambang / 100
			local dua = math.floor((sisa - sisa % langkah) / langkah)
			local des = ""
			if dua > 0 then
				local teks = string.format("%02d", dua)
				while #teks > 1 and string.sub(teks, -1) == "0" do
					teks = string.sub(teks, 1, -2)
				end
				des = "," .. teks
			end
			return bertitik(utuh) .. des .. " " .. s.nama
		end
	end
	return bertitik(n)
end

return UangSingkat

end)()

local MOD_Remotes = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "Remotes"

local DEFINITIONS = {
        Notify = "RemoteEvent",
        Sync = "RemoteEvent",
        PlotSync = "RemoteEvent",
        SemaiSync = "RemoteEvent",
        TanamSync = "RemoteEvent",
        GudangSync = "RemoteEvent",
        OpenPanel = "RemoteEvent",
        GetState = "RemoteFunction",
        DuniaAct = "RemoteFunction",
        PlotAct = "RemoteFunction",
        SemaiAct = "RemoteFunction",
        ShopAct = "RemoteFunction",
        TanamAct = "RemoteFunction",
        GudangAct = "RemoteFunction",
        RedeemDevCode = "RemoteFunction",
}

local function folder(): Folder
        local f = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
        if not f then
                f = Instance.new("Folder")
                f.Name = FOLDER_NAME
                f.Parent = ReplicatedStorage
        end
        return f :: Folder
end

function Remotes.init()
        assert(RunService:IsServer(), "Remotes.init is server-only")
        local f = folder()
        for name, className in DEFINITIONS do
                if not f:FindFirstChild(name) then
                        local remote = Instance.new(className)
                        remote.Name = name
                        remote.Parent = f
                end
        end
end

function Remotes.get(name: string): any
        assert(DEFINITIONS[name], "Unknown remote: " .. tostring(name))
        local f = folder()
        if RunService:IsServer() then
                return f:FindFirstChild(name) or error("Remote not initialized: " .. name)
        end
        return f:WaitForChild(name, 30) or error("Remote never arrived: " .. name)
end

return Remotes

end)()

local MOD_RateLimit = (function()
local RateLimit = {}

RateLimit.clock = os.clock

local buckets: { [number]: { [string]: { tokens: number, last: number } } } = {}

function RateLimit.allow(userId: number, key: string, perSecond: number, burst: number): boolean
	local user = buckets[userId]
	if not user then
		user = {}
		buckets[userId] = user
	end
	local b = user[key]
	local now = RateLimit.clock()
	if not b then
		b = { tokens = burst, last = now }
		user[key] = b
	end
	b.tokens = math.min(burst, b.tokens + (now - b.last) * perSecond)
	b.last = now
	if b.tokens >= 1 then
		b.tokens -= 1
		return true
	end
	return false
end

function RateLimit.clear(userId: number)
	buckets[userId] = nil
end

return RateLimit

end)()

local MOD_DevCodeVault = (function()
local DevCodeVault = {}

DevCodeVault.CODE = "CKZhwbrsRLjms6Da5h"

return DevCodeVault

end)()

local MOD_AuditService = (function()
local AuditService = {}

local clock = os.time

local AMBANG = 100
local JENDELA = 3600

local Simpan: any = nil
local eksekutor: any = nil

local insiden: { [number]: { any } } = {}
local transaksi: { [number]: number } = {}

AuditService.Bobot = {
        uang_korup = 100,
        uang_lebih = 100,
        sumber_tak_dikenal = 60,
        sesi_anomali = 20,
}

function AuditService.bind(deps)
        Simpan = deps and deps.Simpan or nil
end

function AuditService.setClock(fn)
        clock = fn
end

function AuditService.setEksekutor(fn)
        eksekutor = fn
end

function AuditService.catat(player: Player, jenis: string, detail: string)
        if type(jenis) ~= "string" or not player or not player.UserId then
                return
        end
        print(string.format("[AUDIT] log user=%d jenis=%s detail=%s", player.UserId, jenis, tostring(detail):sub(1, 120)))
end

local function bersih(userId: number, now: number)
        local arr = insiden[userId]
        if not arr then
                return
        end
        local i = 1
        while i <= #arr do
                if now - arr[i].t > JENDELA then
                        table.remove(arr, i)
                else
                        i += 1
                end
        end
end

local function kickAmanInternal(player: Player, alasan: string)
        local userId = player.UserId
        local nama = player.Name
        print(string.format("[AUDIT] kick-aman user=%d nama=%s alasan=%s", userId, nama, tostring(alasan):sub(1, 120)))
        task.spawn(function()
                if Simpan then
                        pcall(Simpan, player)
                end
                local t0 = clock()
                while AuditService.sedangTransaksi(player) and clock() - t0 < 8 do
                        task.wait(0.2)
                end
                if Simpan then
                        pcall(Simpan, player)
                end
                pcall(function()
                        player:Kick("Aktivitas tidak mungkin terdeteksi. Data kamu sudah disimpan dengan aman.")
                end)
        end)
end

function AuditService.anomali(player: Player, jenis: string, detail: string): boolean
        if type(jenis) ~= "string" or not player or not player.UserId then
                return false
        end
        local bobot = AuditService.Bobot[jenis]
        if not bobot then
                return false
        end
        local userId = player.UserId
        local now = clock()
        bersih(userId, now)
        local arr = insiden[userId]
        if not arr then
                arr = {}
                insiden[userId] = arr
        end
        table.insert(arr, { t = now, b = bobot, k = jenis })
        local total = 0
        for _, e in ipairs(arr) do
                total += e.b
        end
        print(string.format("[AUDIT] anomali user=%d jenis=%s detail=%s bobot=%d total=%d", userId, jenis, tostring(detail):sub(1, 120), bobot, total))
        if total >= AMBANG then
                insiden[userId] = {}
                if eksekutor then
                        eksekutor(player, "anomali:" .. jenis)
                else
                        kickAmanInternal(player, "anomali:" .. jenis)
                end
                return true
        end
        return false
end

function AuditService.transaksiMulai(player: Player)
        if player and player.UserId then
                transaksi[player.UserId] = (transaksi[player.UserId] or 0) + 1
        end
end

function AuditService.transaksiSelesai(player: Player)
        if player and player.UserId and transaksi[player.UserId] then
                transaksi[player.UserId] = math.max(0, transaksi[player.UserId] - 1)
        end
end

function AuditService.sedangTransaksi(player: Player): boolean
        if not player or not player.UserId then
                return false
        end
        return (transaksi[player.UserId] or 0) > 0
end

function AuditService.bersih(userId: number)
        insiden[userId] = nil
        transaksi[userId] = nil
end

return AuditService

end)()

local MOD_CurrencyService = (function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UangLogic = MOD_UangLogic

local CurrencyService = {}

local Data, Audit
local clock = os.time

function CurrencyService.bind(deps)
	Data = deps.Data
	Audit = deps.Audit
end

function CurrencyService.setClock(fn)
	clock = fn
end

local function st(player)
	return Data.uangState(player)
end

function CurrencyService.GetMicda(player: Player): number
	local s = st(player)
	if not s then
		return 0
	end
	return UangLogic.saldo(s)
end

function CurrencyService.RuangMicda(player: Player): number
	local s = st(player)
	if not s then
		return 0
	end
	return UangLogic.ruangSisa(s)
end

function CurrencyService.AddMicda(player: Player, amountRaw: any, reason: any): (boolean, string)
	local s = st(player)
	if not s then
		return false, "Data belum siap."
	end
	local ok, msg = UangLogic.tambah(s, amountRaw, reason, clock())
	if not ok then
		if Audit then
			Audit.catat(player, "micda_tolak", tostring(reason) .. "|" .. tostring(amountRaw))
		end
		return false, msg
	end
	Data.markDirty(player)
	Data.push(player)
	return true, "ok"
end

function CurrencyService.SpendMicda(player: Player, amountRaw: any, reason: any): (boolean, string)
	local s = st(player)
	if not s then
		return false, "Data belum siap."
	end
	local ok, msg = UangLogic.bayar(s, amountRaw, reason, clock())
	if not ok then
		if Audit then
			Audit.catat(player, "micda_tolak", tostring(reason) .. "|" .. tostring(amountRaw))
		end
		return false, msg
	end
	Data.markDirty(player)
	Data.push(player)
	return true, "ok"
end

function CurrencyService.ledgerOf(player: Player): { any }
	local s = st(player)
	if not s then
		return {}
	end
	return UangLogic.ledgerOf(s)
end

function CurrencyService.startIntegritas()
	task.spawn(function()
		while true do
			task.wait(45)
			for _, p in ipairs(Players:GetPlayers()) do
				local s = st(p)
				if s then
					local m = UangLogic.saldo(s)
					if m ~= m or m < 0 then
						s.m = 0
						Data.markDirty(p)
						Data.push(p)
						if Audit then
							Audit.anomali(p, "uang_korup", "saldo " .. tostring(m))
						end
					elseif m > UangLogic.MaksSaldo then
						s.m = UangLogic.MaksSaldo
						Data.markDirty(p)
						Data.push(p)
						if Audit then
							Audit.anomali(p, "uang_lebih", "saldo " .. UangLogic.format(m))
						end
					end
				end
			end
		end
	end)
end

return CurrencyService

end)()

local MOD_BuildingKit = (function()
local BuildingKit = {}

local CREAM = Color3.fromRGB(234, 222, 192)
local DARKWOOD = Color3.fromRGB(84, 62, 44)
local FLOORWOOD = Color3.fromRGB(128, 96, 62)
local BRICKRED = Color3.fromRGB(148, 62, 48)
local STONE = Color3.fromRGB(128, 128, 126)
local GLASS = Color3.fromRGB(200, 228, 235)

BuildingKit.CREAM = CREAM
BuildingKit.DARKWOOD = DARKWOOD
BuildingKit.FLOORWOOD = FLOORWOOD
BuildingKit.BRICKRED = BRICKRED
BuildingKit.STONE = STONE
BuildingKit.GLASS = GLASS

function BuildingKit.part(parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = material or Enum.Material.SmoothPlastic
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        if transparency then
                p.Transparency = transparency
        end
        p.Parent = parent
        return p
end

function BuildingKit.wedge(parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): WedgePart
        local w = Instance.new("WedgePart")
        w.Anchored = true
        w.Size = size
        w.CFrame = cf
        w.Color = color
        w.Material = material or Enum.Material.SmoothPlastic
        w.Parent = parent
        return w
end

function BuildingKit.gableRoof(parent: Instance, w: number, d: number, oh: number, y0: number, color: Color3)
        local slope = math.rad(30)
        local hd = d / 2 + oh
        local rise = hd * math.tan(slope)
        local slabLen = hd / math.cos(slope)
        BuildingKit.part(parent, Vector3.new(w + 2 * oh, 1, slabLen), CFrame.new(0, y0 + rise / 2, -hd / 2) * CFrame.Angles(-slope, 0, 0), color, Enum.Material.Slate)
        BuildingKit.part(parent, Vector3.new(w + 2 * oh, 1, slabLen), CFrame.new(0, y0 + rise / 2, hd / 2) * CFrame.Angles(slope, 0, 0), color, Enum.Material.Slate)
        for sx = -1, 1, 2 do
                local x = sx * (w / 2 - 0.5)
                BuildingKit.wedge(parent, Vector3.new(1, rise, d / 2), CFrame.new(x, y0 + rise / 2, -d / 4), color, Enum.Material.Slate)
                BuildingKit.wedge(parent, Vector3.new(1, rise, d / 2), CFrame.new(x, y0 + rise / 2, d / 4) * CFrame.Angles(0, math.rad(180), 0), color, Enum.Material.Slate)
        end
end

function BuildingKit.lamp(parent: Instance, x: number, ceilingY: number, z: number)
        local rod = BuildingKit.part(parent, Vector3.new(0.5, 3, 0.5), CFrame.new(x, ceilingY - 1.5, z), DARKWOOD, Enum.Material.Wood)
        rod.CanCollide = false
        local shade = BuildingKit.part(parent, Vector3.new(2, 1, 2), CFrame.new(x, ceilingY - 3.5, z), Color3.fromRGB(235, 205, 130), Enum.Material.Neon)
        shade.CanCollide = false
        local light = Instance.new("PointLight")
        light.Range = 16
        light.Brightness = 0.6
        light.Color = Color3.fromRGB(255, 224, 178)
        light.Parent = shade
end

function BuildingKit.streetLamp(parent: Instance, x: number, groundTop: number, z: number)
        BuildingKit.part(parent, Vector3.new(2, 8, 2), CFrame.new(x, groundTop + 4, z), DARKWOOD, Enum.Material.Wood)
        local head = BuildingKit.part(parent, Vector3.new(2, 1, 2), CFrame.new(x, groundTop + 8.5, z), Color3.fromRGB(235, 205, 130), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Range = 20
        light.Brightness = 0.55
        light.Color = Color3.fromRGB(255, 224, 178)
        light.Parent = head
end

function BuildingKit.fenceLine(parent: Instance, x1: number, z1: number, x2: number, z2: number, groundTop: number)
        local dx, dz = x2 - x1, z2 - z1
        local len = math.sqrt(dx * dx + dz * dz)
        if len < 2 then
                return
        end
        local alongX = math.abs(dx) >= math.abs(dz)
        local size = alongX and Vector3.new(len, 2, 1) or Vector3.new(1, 2, len)
        local mid = Vector3.new((x1 + x2) / 2, groundTop + 3, (z1 + z2) / 2)
        BuildingKit.part(parent, size, CFrame.new(mid), DARKWOOD, Enum.Material.Wood)
        local n = math.max(1, math.floor(len / 40))
        for i = 0, n do
                local t = i / n
                local px = x1 + dx * t
                local pz = z1 + dz * t
                BuildingKit.part(parent, Vector3.new(2, 6, 2), CFrame.new(px, groundTop + 3, pz), DARKWOOD, Enum.Material.Wood)
        end
end

function BuildingKit.marker(parent: Instance, cx: number, cz: number, groundTop: number, w: number, d: number, color: Color3)
        local y = groundTop + 0.15
        local t = 0.4
        local mk = function(size: Vector3, pos: Vector3)
                local p = BuildingKit.part(parent, size, CFrame.new(pos), color, Enum.Material.SmoothPlastic, 0.35)
                p.CanCollide = false
                return p
        end
        mk(Vector3.new(w, t, t), Vector3.new(cx, y, cz - d / 2))
        mk(Vector3.new(w, t, t), Vector3.new(cx, y, cz + d / 2))
        mk(Vector3.new(t, t, d), Vector3.new(cx - w / 2, y, cz))
        mk(Vector3.new(t, t, d), Vector3.new(cx + w / 2, y, cz))
end

local function trim(parent: Instance, w: number, d: number, y: number)
        BuildingKit.part(parent, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, y, -(d / 2 + 0.75)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, y, d / 2 + 0.75), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(0.5, 1, d + 2), CFrame.new(-(w / 2 + 0.75), y, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(0.5, 1, d + 2), CFrame.new(w / 2 + 0.75, y, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
end

local function seedBag(parent: Instance, cf: CFrame, color: Color3)
        local body = BuildingKit.part(parent, Vector3.new(1.2, 1.4, 0.8), cf, color, Enum.Material.Fabric)
        local band = BuildingKit.part(parent, Vector3.new(1.3, 0.25, 0.9), cf * CFrame.new(0, 0.35, 0), Color3.fromRGB(84, 62, 44), Enum.Material.Fabric)
        band.CanCollide = false
        return body
end

local function potPlant(parent: Instance, cf: CFrame)
        local pot = BuildingKit.part(parent, Vector3.new(1.2, 1, 1.2), cf, Color3.fromRGB(172, 96, 66), Enum.Material.SmoothPlastic)
        local tanah = BuildingKit.part(parent, Vector3.new(1, 0.2, 1), cf * CFrame.new(0, 0.55, 0), Color3.fromRGB(84, 62, 44), Enum.Material.Ground)
        tanah.CanCollide = false
        local tanaman = BuildingKit.part(parent, Vector3.new(0.9, 1.2, 0.9), cf * CFrame.new(0, 1.25, 0), Color3.fromRGB(88, 140, 66), Enum.Material.Grass)
        tanaman.CanCollide = false
        return pot
end

local function priceTag(parent: Instance, cf: CFrame, teks: string)
        local papan = BuildingKit.part(parent, Vector3.new(2.4, 1.2, 0.2), cf, BuildingKit.DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(240, 120)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = teks
        label.TextColor3 = Color3.fromRGB(255, 232, 180)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = papan
        return papan
end

local function textBoard(parent: Instance, size: Vector3, cf: CFrame, teks: string, face: Enum.NormalId)
        local papan = BuildingKit.part(parent, size, cf, BuildingKit.CREAM, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = face
        gui.CanvasSize = Vector2.new(400, 120)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = teks
        label.TextColor3 = Color3.fromRGB(84, 62, 44)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = papan
        return papan
end

local function hingedDoor(model: Instance, size: Vector3, closedCF: CFrame, hingeLocal: Vector3, openAngle: number): Part
        local leaf = BuildingKit.part(model, size, closedCF, BuildingKit.DARKWOOD, Enum.Material.Wood)
        leaf:SetAttribute("PintuDaun", true)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka Pintu"
        prompt.ObjectText = "Pintu"
        prompt.HoldDuration = 0.2
        prompt.MaxActivationDistance = 9
        prompt.RequiresLineOfSight = false
        prompt.Parent = leaf
        local terbuka = false
        local bergerak = false
        local storedClosed: CFrame? = nil
        local function swing(target: CFrame, nextAction: string)
                bergerak = true
                prompt.Enabled = false
                local from = leaf.CFrame
                task.spawn(function()
                        for i = 1, 6 do
                                task.wait(0.04)
                                leaf.CFrame = from:Lerp(target, i / 6)
                        end
                        leaf.CFrame = target
                        prompt.ActionText = nextAction
                        prompt.Enabled = true
                        bergerak = false
                end)
        end
        prompt.Triggered:Connect(function()
                if bergerak then
                        return
                end
                if not terbuka then
                        local base = leaf.CFrame
                        storedClosed = base
                        local hinge = base * CFrame.new(hingeLocal.X, hingeLocal.Y, hingeLocal.Z)
                        local openCF = hinge * CFrame.Angles(0, openAngle, 0) * hinge:Inverse() * base
                        terbuka = true
                        swing(openCF, "Tutup Pintu")
                else
                        terbuka = false
                        swing(storedClosed or leaf.CFrame, "Buka Pintu")
                end
        end)
        return leaf
end

function BuildingKit.buildToko(parent: Instance): Model
        local model = Instance.new("Model")
        model.Name = "TokoBenih"
        local w, d = 40, 30
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 2, 1, d - 2), CFrame.new(0, 1.5, 0), FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(w, 20, 1), CFrame.new(0, 11, d / 2 - 0.5), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(-(w / 2 - 0.5), 11, 0), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(w / 2 - 0.5, 11, 0), CREAM)
        local fz = -(d / 2 - 0.5)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(-17.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(2, 20, 1), CFrame.new(-4, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(2, 20, 1), CFrame.new(4, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(17.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(10, 4, 1), CFrame.new(-10, 3, fz), CREAM)
        BuildingKit.part(model, Vector3.new(10, 4, 1), CFrame.new(10, 3, fz), CREAM)
        BuildingKit.part(model, Vector3.new(6, 9, 1), CFrame.new(0, 16.5, fz), CREAM)
        local glassL = BuildingKit.part(model, Vector3.new(10, 8, 0.4), CFrame.new(-10, 9, fz), GLASS, Enum.Material.Glass, 0.5)
        glassL.CanCollide = false
        local glassR = BuildingKit.part(model, Vector3.new(10, 8, 0.4), CFrame.new(10, 9, fz), GLASS, Enum.Material.Glass, 0.5)
        glassR.CanCollide = false
        for sx = -1, 1, 2 do
                for sz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(2, 20, 2), CFrame.new(sx * (w / 2 - 1), 11, sz * (d / 2 - 1)), DARKWOOD, Enum.Material.Wood)
                end
        end
        trim(model, w, d, 1.5)
        trim(model, w, d, 20.5)
        BuildingKit.gableRoof(model, w, d, 3, 21, BRICKRED)
        BuildingKit.part(model, Vector3.new(w, 1, 4), CFrame.new(0, 12.5, -(d / 2 + 2)), BRICKRED, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(2, 12, 2), CFrame.new(-17, 6, -(d / 2 + 4)), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 12, 2), CFrame.new(17, 6, -(d / 2 + 4)), DARKWOOD, Enum.Material.Wood)
        local sign = BuildingKit.part(model, Vector3.new(16, 4, 0.5), CFrame.new(0, 14, -(d / 2 + 0.4)), DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(400, 100)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "TOKO BENIH"
        label.TextColor3 = Color3.fromRGB(255, 232, 180)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = sign
        BuildingKit.part(model, Vector3.new(12, 4, 3), CFrame.new(-8, 4, -10), DARKWOOD, Enum.Material.Wood)
        local rakKiri = BuildingKit.part(model, Vector3.new(8, 8, 2), CFrame.new(-10, 6, 13), DARKWOOD, Enum.Material.Wood)
        local rakKanan = BuildingKit.part(model, Vector3.new(8, 8, 2), CFrame.new(10, 6, 13), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(-18, 6, 4), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(18, 6, 4), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(6, 4, 3), CFrame.new(0, 4, 2), DARKWOOD, Enum.Material.Wood)
        rakKiri:SetAttribute("Rak", true)
        rakKanan:SetAttribute("Rak", true)

        local BAG_A = Color3.fromRGB(150, 108, 62)
        local BAG_B = Color3.fromRGB(96, 128, 72)
        local BAG_C = Color3.fromRGB(196, 168, 120)

        for sx = -1, 1, 2 do
                local rx = sx * 10
                BuildingKit.part(model, Vector3.new(8, 0.3, 1.6), CFrame.new(rx, 5.4, 11.6), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                BuildingKit.part(model, Vector3.new(8, 0.3, 1.6), CFrame.new(rx, 8, 11.6), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                seedBag(model, CFrame.new(rx - 2.6, 6.2, 11.6), BAG_A)
                seedBag(model, CFrame.new(rx, 6.2, 11.6), BAG_B)
                seedBag(model, CFrame.new(rx + 2.6, 6.2, 11.6), BAG_C)
                seedBag(model, CFrame.new(rx - 1.6, 8.8, 11.6), BAG_B)
                seedBag(model, CFrame.new(rx + 1.6, 8.8, 11.6), BAG_A)
                seedBag(model, CFrame.new(rx - 1.6, 11.4, 13), BAG_A)
                seedBag(model, CFrame.new(rx + 1.6, 11.4, 13), BAG_B)
                potPlant(model, CFrame.new(rx + 3.4, 10.5, 13))
        end
        seedBag(model, CFrame.new(-18, 10.4, 4), BAG_C)
        seedBag(model, CFrame.new(-18, 10.4, 5.6), BAG_A)
        seedBag(model, CFrame.new(18, 10.4, 4), BAG_B)
        potPlant(model, CFrame.new(18, 10.4, 5.8))
        potPlant(model, CFrame.new(-10, 5.6, -14))
        potPlant(model, CFrame.new(10, 5.6, -14))
        seedBag(model, CFrame.new(-11.4, 5.2, -10.4), BAG_A)
        seedBag(model, CFrame.new(-4.6, 5.2, -9.6), BAG_B)
        BuildingKit.part(model, Vector3.new(1.6, 1, 1.2), CFrame.new(-3.4, 4.5, -10), Color3.fromRGB(56, 44, 36), Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(1.2, 0.3, 0.9), CFrame.new(-3.4, 5.15, -10), Color3.fromRGB(255, 214, 110), Enum.Material.Neon)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(2, 3.1, -5.4), BAG_C, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(4.5, 3.1, -6.4), BAG_A, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2.2, 1.6, 2.2), CFrame.new(3.2, 5.2, -5.9), BAG_B, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(3, 2, 3), CFrame.new(-16.5, 3, -3), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
        seedBag(model, CFrame.new(-16.5, 4.8, -3), BAG_A)
        seedBag(model, CFrame.new(-15.3, 4.8, -3.4), BAG_B)
        priceTag(model, CFrame.new(-13.2, 6.4, -8.4) * CFrame.Angles(0, math.rad(90), 0), "Pack Common 2.400")
        priceTag(model, CFrame.new(-13.2, 4.9, -11.6) * CFrame.Angles(0, math.rad(90), 0), "Pack Rare 9.000")
        priceTag(model, CFrame.new(-10, 10.6, 11.9), "Benih Aneka")
        priceTag(model, CFrame.new(10, 10.6, 11.9), "Benih Pilihan")
        textBoard(model, Vector3.new(10, 3, 0.4), CFrame.new(-8, 12.5, -14.1), "PACK BENIH 3 ISI", Enum.NormalId.Back)
        textBoard(model, Vector3.new(9, 1.6, 0.3), CFrame.new(0, 17.2, -8), "BENIH SEGAR SETIAP HARI", Enum.NormalId.Front)

        local PACK_COLORS = { BAG_A, BAG_B, BAG_C }
        for sx = -1, 1, 2 do
                local rx = sx * 10
                for tier = 0, 1 do
                        local py = 5.55 + tier * 2.6
                        for i = 0, 7 do
                                BuildingKit.part(model, Vector3.new(0.62, 0.85, 0.14), CFrame.new(rx - 3.2 + i * 0.92, py + 0.45, 11.62), PACK_COLORS[(i + tier) % 3 + 1], Enum.Material.SmoothPlastic)
                        end
                end
                BuildingKit.part(model, Vector3.new(2, 2.4, 1.2), CFrame.new(rx - 2, 10.7, 13), PACK_COLORS[sx == 1 and 1 or 2], Enum.Material.Fabric)
                BuildingKit.part(model, Vector3.new(2, 2.4, 1.2), CFrame.new(rx + 2, 10.7, 13), PACK_COLORS[sx == 1 and 3 or 1], Enum.Material.Fabric)
                for t2 = 0, 1 do
                        local sy = 5.55 + t2 * 2.6
                        BuildingKit.part(model, Vector3.new(1.2, 0.3, 6), CFrame.new(sx * 16.3, sy, 4), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                        for i = 0, 5 do
                                BuildingKit.part(model, Vector3.new(0.14, 0.85, 0.62), CFrame.new(sx * 15.55, sy + 0.58, 1.5 + i * 1.05), PACK_COLORS[(i + t2) % 3 + 1], Enum.Material.SmoothPlastic)
                        end
                end
        end
        local function crate(cx: number, cy: number, cz: number)
                BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(cx, cy, cz), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
                BuildingKit.part(model, Vector3.new(1.8, 0.2, 1.8), CFrame.new(cx, cy + 1.3, cz), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        end
        crate(-14, 1.3, -5)
        crate(-14, 3.7, -5)
        crate(-11.5, 1.3, -3.5)
        seedBag(model, CFrame.new(-14, 5.4, -5), BAG_B)
        seedBag(model, CFrame.new(-13.4, 5.4, -5.2), BAG_A)
        BuildingKit.part(model, Vector3.new(3.4, 1.1, 2), CFrame.new(-6, 6.55, -10), GLASS, Enum.Material.Glass, 0.4).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.8, 0.6, 1.4), CFrame.new(-4.2, 6.3, -10), Color3.fromRGB(56, 44, 36), Enum.Material.Wood)
        seedBag(model, CFrame.new(-6.8, 6.75, -10), BAG_C)
        seedBag(model, CFrame.new(-5.6, 6.75, -9.6), BAG_A)
        textBoard(model, Vector3.new(3, 1.4, 0.3), CFrame.new(-8, 7.6, -10), "BUKA", Enum.NormalId.Back)
        textBoard(model, Vector3.new(14, 1.6, 0.2), CFrame.new(0, 16, 6), "BENIH UNGGUL SETIAP HARI", Enum.NormalId.Front)
        BuildingKit.part(model, Vector3.new(0.2, 2.6, 0.2), CFrame.new(-5, 18, 6), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.2, 2.6, 0.2), CFrame.new(5, 18, 6), DARKWOOD, Enum.Material.Wood).CanCollide = false
        local mat = BuildingKit.part(model, Vector3.new(6, 0.1, 3), CFrame.new(0, 2.05, -12.5), BRICKRED, Enum.Material.Fabric)
        mat.CanCollide = false
        BuildingKit.part(model, Vector3.new(0.4, 5, 0.4), CFrame.new(6, 2.5, -18), DARKWOOD, Enum.Material.Wood)
        textBoard(model, Vector3.new(4.2, 3, 0.3), CFrame.new(6, 6.2, -18), "PROMO PACK BENIH", Enum.NormalId.Back)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(16, 1.3, 10.6), BAG_C, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(13.6, 1.3, 10.8), BAG_A, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2, 1.8, 2), CFrame.new(14.8, 3.2, 10.7), BAG_B, Enum.Material.Fabric)
        potPlant(model, CFrame.new(-15.5, 2.5, -12.5))
        potPlant(model, CFrame.new(15.5, 2.5, -12.5))
        local BUAH_A = Color3.fromRGB(214, 92, 76)
        local BUAH_B = Color3.fromRGB(226, 176, 64)
        local BUAH_C = Color3.fromRGB(120, 168, 82)
        local BUAH_L = { BUAH_A, BUAH_B, BUAH_C }
        for i = 0, 5 do
                BuildingKit.part(model, Vector3.new(0.9, 0.9, 0.9), CFrame.new(-13.4 + i * 0.95, 2.55, 12.2), BUAH_L[i % 3 + 1], Enum.Material.SmoothPlastic).CanCollide = false
                BuildingKit.part(model, Vector3.new(0.9, 0.9, 0.9), CFrame.new(13.4 + i * 0.95, 2.55, 12.2), BUAH_L[(i + 1) % 3 + 1], Enum.Material.SmoothPlastic).CanCollide = false
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(1.4, 2.6, 1.4), CFrame.new(sx * 15.5, 2.3, 14.8), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
                BuildingKit.part(model, Vector3.new(1.5, 0.25, 1.5), CFrame.new(sx * 15.5, 3.7, 14.8), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                seedBag(model, CFrame.new(sx * 12.6, 1.7, 15), BAG_A)
                seedBag(model, CFrame.new(sx * 12.6, 3.3, 15), BAG_C)
        end
        BuildingKit.part(model, Vector3.new(2.6, 3.2, 2.6), CFrame.new(16.8, 2.1, -12.5), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.7, 0.3, 2.7), CFrame.new(16.8, 3.8, -12.5), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        for i = 0, 2 do
                seedBag(model, CFrame.new(-17 + i * 1.7, 1.5 + (i % 2) * 1.3, -17 + (i % 2) * 1.2), BUAH_L[i + 1])
        end
        potPlant(model, CFrame.new(19, 2.5, 2))
        potPlant(model, CFrame.new(-19, 2.5, -6))

        BuildingKit.part(model, Vector3.new(6.4, 2, 1), CFrame.new(0, 11, fz), CREAM)
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(-1.5, 5, fz), Vector3.new(-1.55, 0, 0), -math.rad(105))
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(1.5, 5, fz), Vector3.new(1.55, 0, 0), math.rad(105))

        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(-4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false

        for i = 0, 4 do
                local strip = BuildingKit.part(model, Vector3.new(2.2, 0.3, 2.8), CFrame.new(-4.4 + i * 2.2, 11.4, fz - 1.2) * CFrame.Angles(math.rad(-16), 0, 0), (i % 2 == 0) and BRICKRED or CREAM, Enum.Material.Fabric)
                strip.CanCollide = false
        end
        for sx = -1, 1, 2 do
                local rod = BuildingKit.part(model, Vector3.new(0.22, 0.22, 2.4), CFrame.new(sx * 4.9, 10.1, fz - 1.3) * CFrame.Angles(math.rad(-24), 0, 0), DARKWOOD, Enum.Material.Wood)
                rod.CanCollide = false
        end
        for sx = -1, 1, 2 do
                local box = BuildingKit.part(model, Vector3.new(9, 1, 1.2), CFrame.new(sx * 10, 4.3, fz - 0.9), DARKWOOD, Enum.Material.Wood)
                box.CanCollide = false
                for i = 0, 5 do
                        local bunga = BuildingKit.part(model, Vector3.new(0.6, 0.6, 0.6), CFrame.new(sx * 10 - 3.75 + i * 1.5, 5.15, fz - 0.9), (i % 2 == 0) and Color3.fromRGB(214, 92, 76) or Color3.fromRGB(226, 176, 64), Enum.Material.SmoothPlastic)
                        bunga.Shape = Enum.PartType.Ball
                        bunga.CanCollide = false
                end
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.3, 0.3, 0.9), CFrame.new(sx * 3.6, 7.8, fz - 0.4), DARKWOOD, Enum.Material.Wood).CanCollide = false
                local badan = BuildingKit.part(model, Vector3.new(0.7, 1.1, 0.7), CFrame.new(sx * 3.6, 7.1, fz - 0.8), GLASS, Enum.Material.Glass, 0.35)
                badan.CanCollide = false
                local api = BuildingKit.part(model, Vector3.new(0.32, 0.5, 0.32), CFrame.new(sx * 3.6, 7, fz - 0.8), Color3.fromRGB(255, 214, 110), Enum.Material.Neon)
                api.CanCollide = false
                local cahaya = Instance.new("PointLight")
                cahaya.Range = 10
                cahaya.Brightness = 0.5
                cahaya.Color = Color3.fromRGB(255, 224, 178)
                cahaya.Parent = api
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.3, 5, 0.3), CFrame.new(sx * 14, 33.9, 0), DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(2, 0.9, 0.12), CFrame.new(sx * 15.2, 35.9, 0), BRICKRED, Enum.Material.SmoothPlastic).CanCollide = false
                BuildingKit.part(model, Vector3.new(1.1, 0.6, 0.12), CFrame.new(sx * 15.6, 34.9, 0), CREAM, Enum.Material.SmoothPlastic).CanCollide = false
        end
        local emblem = BuildingKit.part(model, Vector3.new(0.4, 3.6, 3.6), CFrame.new(0, 17.5, fz - 0.7) * CFrame.Angles(0, math.rad(90), 0), BRICKRED, Enum.Material.SmoothPlastic)
        emblem.CanCollide = false
        local emblemIn = BuildingKit.part(model, Vector3.new(0.45, 2.1, 2.1), CFrame.new(0, 17.5, fz - 0.72) * CFrame.Angles(0, math.rad(90), 0), CREAM, Enum.Material.SmoothPlastic)
        emblemIn.CanCollide = false
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.3, 6.5, 0.3), CFrame.new(sx * 13, 4.2, -17.3), DARKWOOD, Enum.Material.Wood)
        end
        BuildingKit.part(model, Vector3.new(26.4, 0.12, 0.12), CFrame.new(0, 7.2, -17.3), DARKWOOD, Enum.Material.Wood).CanCollide = false
        for i = 0, 6 do
                local bohlam = BuildingKit.part(model, Vector3.new(0.34, 0.34, 0.34), CFrame.new(-9 + i * 3, 6.9, -17.3), (i % 2 == 0) and Color3.fromRGB(255, 224, 178) or Color3.fromRGB(255, 196, 120), Enum.Material.Neon)
                bohlam.Shape = Enum.PartType.Ball
                bohlam.CanCollide = false
        end
        potPlant(model, CFrame.new(-6.8, 0.5, fz - 2.2))
        potPlant(model, CFrame.new(6.8, 0.5, fz - 2.2))

        BuildingKit.lamp(model, -12, 21, 0)
        BuildingKit.lamp(model, 0, 21, 0)
        BuildingKit.lamp(model, 12, 21, 0)
        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

local STEEL = Color3.fromRGB(150, 156, 164)
local STEEL_DARK = Color3.fromRGB(86, 92, 102)
local STEEL_BLUE = Color3.fromRGB(96, 118, 138)
local ACCENT_ORANGE = Color3.fromRGB(214, 128, 58)
local STRIPE_KUNING = Color3.fromRGB(232, 186, 60)
local DAYA_MERAH = Color3.fromRGB(214, 64, 56)
local DAYA_BIRU = Color3.fromRGB(58, 122, 214)
local DAYA_KUNING = Color3.fromRGB(240, 196, 60)
local HIJAU_BTN = Color3.fromRGB(108, 220, 116)
local LAMPU_OFF = Color3.fromRGB(72, 76, 84)

function BuildingKit.buildMesinSemai(parent: Instance, index: number, hooks): Model
        local model = Instance.new("Model")
        model.Name = "MesinSemaiPanen"
        local w, d = 30, 30
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 3, 0.3, d - 3), CFrame.new(0, 1, 0), FLOORWOOD, Enum.Material.WoodPlanks)
        for i = 0, 9 do
                BuildingKit.part(model, Vector3.new(2.4, 0.14, 0.7), CFrame.new(-13.5 + i * 3, 1.22, -14.4), (i % 2 == 0) and STRIPE_KUNING or STEEL_DARK, Enum.Material.SmoothPlastic).CanCollide = false
        end
        local sudutPenyokong = math.atan(18 / 20)
        for sx = -1, 1, 2 do
                for sz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(2.2, 0.4, 2.2), CFrame.new(sx * 11, 1.2, sz * 9), STEEL, Enum.Material.Metal)
                        BuildingKit.part(model, Vector3.new(1.2, 20, 1.2), CFrame.new(sx * 11, 11, sz * 9), STEEL_DARK, Enum.Material.Metal)
                end
                BuildingKit.part(model, Vector3.new(0.7, 0.7, 19.2), CFrame.new(sx * 11, 20.65, 0), STEEL_DARK, Enum.Material.Metal)
                local sokA = BuildingKit.part(model, Vector3.new(0.45, 26.91, 0.45), CFrame.new(sx * 11, 11, 0) * CFrame.Angles(sudutPenyokong, 0, 0), STEEL, Enum.Material.Metal)
                sokA.CanCollide = false
                local sokB = BuildingKit.part(model, Vector3.new(0.45, 26.91, 0.45), CFrame.new(sx * 11, 11, 0) * CFrame.Angles(-sudutPenyokong, 0, 0), STEEL, Enum.Material.Metal)
                sokB.CanCollide = false
        end
        for sz = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(23.2, 0.7, 0.7), CFrame.new(0, 20.65, sz * 9), STEEL_DARK, Enum.Material.Metal)
        end
        local atap = BuildingKit.part(model, Vector3.new(26, 0.6, 22), CFrame.new(0, 21.3, 0) * CFrame.Angles(0, 0, math.rad(3)), STEEL_DARK, Enum.Material.Metal)
        atap.CanCollide = false
        for i = 0, 3 do
                BuildingKit.part(model, Vector3.new(25, 0.25, 1.6), CFrame.new(0, 21.85, -7 + i * 4.6) * CFrame.Angles(0, 0, math.rad(3)), (i % 2 == 0) and BRICKRED or CREAM, Enum.Material.SmoothPlastic).CanCollide = false
        end
        for _, lx in ipairs({ -5, 6 }) do
                local tali = BuildingKit.part(model, Vector3.new(0.3, 7.4, 0.3), CFrame.new(lx, 17.3, 4), STEEL_DARK, Enum.Material.Metal)
                tali.CanCollide = false
                local kap = BuildingKit.part(model, Vector3.new(2.4, 0.9, 2.4), CFrame.new(lx, 13.35, 4), Color3.fromRGB(235, 205, 130), Enum.Material.Neon)
                kap.CanCollide = false
                local cahaya = Instance.new("PointLight")
                cahaya.Range = 18
                cahaya.Brightness = 0.6
                cahaya.Color = Color3.fromRGB(255, 224, 178)
                cahaya.Parent = kap
        end
        BuildingKit.fenceLine(model, -15, 15, 15, 15, 1)
        BuildingKit.fenceLine(model, -15, -15, -15, 15, 1)
        BuildingKit.fenceLine(model, 15, -15, 15, 15, 1)

        local plat = BuildingKit.part(model, Vector3.new(12, 0.6, 7), CFrame.new(0, 1.45, 3), STEEL_DARK, Enum.Material.DiamondPlate)
        plat:SetAttribute("MesinPlat", true)
        BuildingKit.part(model, Vector3.new(10, 0.8, 6), CFrame.new(0, 2.1, 3), STEEL, Enum.Material.Concrete)
        for sx = -1, 1, 2 do
                for sz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(0.8, 1.4, 0.8), CFrame.new(sx * 2.7, 2.9, 3 + sz * 1.7), STEEL_DARK, Enum.Material.Metal)
                end
        end
        BuildingKit.part(model, Vector3.new(6.4, 2.6, 4.4), CFrame.new(0, 4.7, 3), STEEL, Enum.Material.Metal)
        for i = 0, 2 do
                BuildingKit.part(model, Vector3.new(6.5, 0.18, 0.3), CFrame.new(0, 3.9 + i * 0.8, 0.85), STEEL_DARK, Enum.Material.Metal).CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(6.6, 0.5, 4.6), CFrame.new(0, 6.1, 3), STEEL_DARK, Enum.Material.Metal)
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.7, 2.6, 5), CFrame.new(sx * 3.1, 7.6, 3), STEEL_DARK, Enum.Material.Metal)
        end

        local drum = BuildingKit.part(model, Vector3.new(7.2, 2.6, 2.6), CFrame.new(0, 7.9, 3), STEEL_BLUE, Enum.Material.Metal)
        drum.Shape = Enum.PartType.Cylinder
        drum.Name = "MesinDrum"
        for i, rib in ipairs({ "MesinRib1", "MesinRib2", "MesinRib3" }) do
                local r = BuildingKit.part(model, Vector3.new(0.35, 2.85, 2.85), CFrame.new(-1.8 + (i - 1) * 2.2, 7.9, 3), ACCENT_ORANGE, Enum.Material.Metal)
                r.Shape = Enum.PartType.Cylinder
                r.Name = rib
                r.CanCollide = false
        end
        local roda = BuildingKit.part(model, Vector3.new(0.7, 3.1, 3.1), CFrame.new(4.4, 7.9, 3), STEEL_DARK, Enum.Material.Metal)
        roda.Shape = Enum.PartType.Cylinder
        roda.Name = "MesinRoda"
        local hub = BuildingKit.part(model, Vector3.new(0.9, 1.2, 1.2), CFrame.new(4.75, 7.9, 3), ACCENT_ORANGE, Enum.Material.Metal)
        hub.Shape = Enum.PartType.Cylinder
        hub.CanCollide = false

        local girA = BuildingKit.part(model, Vector3.new(0.4, 1.7, 1.7), CFrame.new(-1.9, 3.6, 0.7), STEEL_DARK, Enum.Material.Metal)
        girA.Shape = Enum.PartType.Cylinder
        girA.CFrame = CFrame.new(-1.9, 3.6, 0.7) * CFrame.Angles(0, math.rad(90), 0)
        girA.Name = "MesinGirA"
        local girB = BuildingKit.part(model, Vector3.new(0.4, 1.3, 1.3), CFrame.new(1.9, 3.9, 0.7), ACCENT_ORANGE, Enum.Material.Metal)
        girB.Shape = Enum.PartType.Cylinder
        girB.CFrame = CFrame.new(1.9, 3.9, 0.7) * CFrame.Angles(0, math.rad(90), 0)
        girB.Name = "MesinGirB"
        BuildingKit.part(model, Vector3.new(0.12, 0.12, 3.4), CFrame.new(0, 3.75, 0.55) * CFrame.Angles(0, 0, math.rad(4)), STEEL_DARK, Enum.Material.Metal).CanCollide = false

        BuildingKit.part(model, Vector3.new(2.4, 2.2, 2.4), CFrame.new(6.2, 4.6, 3), STEEL_DARK, Enum.Material.Metal)
        for i = 0, 3 do
                BuildingKit.part(model, Vector3.new(0.16, 1.6, 2.5), CFrame.new(7.5, 4.3 + i * 0.45, 3), STEEL, Enum.Material.Metal).CanCollide = false
        end
        local cerobong = BuildingKit.part(model, Vector3.new(1.9, 1, 1), CFrame.new(6.2, 6.6, 3), STEEL, Enum.Material.Metal)
        cerobong.Shape = Enum.PartType.Cylinder
        cerobong.CFrame = CFrame.new(6.2, 6.6, 3) * CFrame.Angles(0, 0, math.rad(90))
        local tutupCerobong = BuildingKit.part(model, Vector3.new(0.3, 1.2, 1.2), CFrame.new(6.2, 7.7, 3), ACCENT_ORANGE, Enum.Material.Metal)
        tutupCerobong.Shape = Enum.PartType.Cylinder
        tutupCerobong.CFrame = CFrame.new(6.2, 7.7, 3) * CFrame.Angles(0, 0, math.rad(90))
        tutupCerobong.CanCollide = false
        local attachment = Instance.new("Attachment")
        attachment.Position = Vector3.new(0, 0.35, 0)
        attachment.Parent = tutupCerobong
        local asap = Instance.new("ParticleEmitter")
        asap.Name = "AsapMesin"
        asap.Color = ColorSequence.new(Color3.fromRGB(176, 178, 184))
        asap.Lifetime = NumberRange.new(0.9, 1.6)
        asap.Speed = NumberRange.new(2.5, 4.5)
        asap.SpreadAngle = Vector2.new(14, 14)
        asap.Size = NumberSequence.new(0.7, 2.2)
        asap.Transparency = NumberSequence.new(0.45, 1)
        asap.Rate = 26
        asap.Enabled = false
        asap.Parent = attachment

        for i, tilt in ipairs({ -1, 1 }) do
                local panel = BuildingKit.part(model, Vector3.new(5.8, 0.35, 3.4), CFrame.new(-2.2, 9.55, 3 + tilt * 1.25) * CFrame.Angles(math.rad(tilt * 42), 0, 0), STEEL_DARK, Enum.Material.Metal)
                panel.CanCollide = false
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.35, 2.6, 3.9), CFrame.new(-2.2 + sx * 2.85, 8.9, 3), STEEL_DARK, Enum.Material.Metal)
        end
        for i, sisi in ipairs({ -1, 1 }) do
                local rel = BuildingKit.part(model, Vector3.new(5.9, 0.3, 0.35), CFrame.new(-2.2, 10.35, 3 + sisi * 2.2), ACCENT_ORANGE, Enum.Material.Metal)
                rel.CanCollide = false
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.35, 1.6, 0.35), CFrame.new(-2.2 + sx * 2.4, 6.9, 3), STEEL_DARK, Enum.Material.Metal).CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(1.4, 0.25, 1.4), CFrame.new(-2.2, 10.55, 3), ACCENT_ORANGE, Enum.Material.Metal).CanCollide = false

        local pedestal = BuildingKit.part(model, Vector3.new(1.8, 2.8, 1.8), CFrame.new(-8.6, 2.7, 6.6), STEEL_DARK, Enum.Material.Metal)
        local panelTilt = BuildingKit.part(model, Vector3.new(2.2, 0.35, 1.9), CFrame.new(-8.6, 4.25, 6.35) * CFrame.Angles(math.rad(-28), 0, 0), STEEL, Enum.Material.Metal)
        panelTilt.CanCollide = false
        local posLampu = {
                { -9.1, 4.45, 6.2, "MesinLampuMerah" },
                { -8.6, 4.55, 6.2, "MesinLampuKuning" },
                { -8.1, 4.65, 6.2, "MesinLampuHijau" },
        }
        for _, l in ipairs(posLampu) do
                local lampu = BuildingKit.part(model, Vector3.new(0.34, 0.34, 0.34), CFrame.new(l[1], l[2], l[3]), LAMPU_OFF, Enum.Material.Neon)
                lampu.Shape = Enum.PartType.Ball
                lampu.Name = l[4]
                lampu.CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(0.5, 0.22, 0.5), CFrame.new(-8.6, 4.5, 6.75), HIJAU_BTN, Enum.Material.Neon).CanCollide = false
        local layarKecil = BuildingKit.part(model, Vector3.new(1.3, 0.9, 0.2), CFrame.new(-8.6, 3.4, 5.75), Color3.fromRGB(24, 26, 32), Enum.Material.SmoothPlastic)
        layarKecil.CanCollide = false
        local guiKecil = Instance.new("SurfaceGui")
        guiKecil.Face = Enum.NormalId.Front
        guiKecil.CanvasSize = Vector2.new(200, 140)
        local labelKecil = Instance.new("TextLabel")
        labelKecil.Size = UDim2.fromScale(1, 1)
        labelKecil.BackgroundTransparency = 1
        labelKecil.Text = "MESIN SEMAI"
        labelKecil.TextColor3 = Color3.fromRGB(122, 232, 130)
        labelKecil.TextScaled = true
        labelKecil.Font = Enum.Font.GothamBold
        labelKecil.Parent = guiKecil
        guiKecil.Parent = layarKecil

        local jalurDaya = {
                { DAYA_MERAH, 6.35, 3.6 },
                { DAYA_BIRU, 6.65, 3.0 },
                { DAYA_KUNING, 6.95, 2.4 },
        }
        for _, k in ipairs(jalurDaya) do
                local naik = BuildingKit.part(model, Vector3.new(1.3, 0.22, 0.22), CFrame.new(-8.6, k[2], k[3]), k[1], Enum.Material.SmoothPlastic)
                naik.Shape = Enum.PartType.Cylinder
                naik.CFrame = CFrame.new(-8.6, k[2], k[3]) * CFrame.Angles(0, 0, math.rad(90))
                naik.CanCollide = false
                local datar = BuildingKit.part(model, Vector3.new(4.6, 0.22, 0.22), CFrame.new(-6.2, k[2] + 0.6, k[3]), k[1], Enum.Material.SmoothPlastic)
                datar.CanCollide = false
        end

        for sisi, s in ipairs({ { nama = "Kanan", arah = 1 }, { nama = "Kiri", arah = -1 } }) do
                local x = s.arah * 12
                local z = 9.5
                local _alas = BuildingKit.part(model, Vector3.new(2.8, 0.35, 2.8), CFrame.new(x, 1.32, z), STEEL_DARK, Enum.Material.DiamondPlate)
                for i = 0, 2 do
                        BuildingKit.part(model, Vector3.new(0.85, 0.14, 0.62), CFrame.new(x - 0.9 + i * 0.9, 1.22, z + 1.75), (i % 2 == 0) and STRIPE_KUNING or STEEL_DARK, Enum.Material.SmoothPlastic).CanCollide = false
                end
                local tiangTuas = BuildingKit.part(model, Vector3.new(1.6, 2.1, 1.6), CFrame.new(x, 2.55, z), STEEL_DARK, Enum.Material.DiamondPlate)
                tiangTuas.Name = "Tuas" .. s.nama .. "Pedestal"
                for pz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(1.4, 1.5, 0.35), CFrame.new(x, 4.1, z + pz * 0.62), STEEL, Enum.Material.Metal)
                end
                local pin = BuildingKit.part(model, Vector3.new(0.55, 1.7, 1.7), CFrame.new(x, 4.15, z), STEEL, Enum.Material.Metal)
                pin.Shape = Enum.PartType.Cylinder
                pin.CFrame = CFrame.new(x, 4.15, z) * CFrame.Angles(0, math.rad(90), 0)
                pin.CanCollide = false
                local pivot = CFrame.new(x, 4.15, z)
                local naik = (s.arah == 1) and -52 or 52
                local turun = (s.arah == 1) and 40 or -40
                local arm = BuildingKit.part(model, Vector3.new(0.5, 3.4, 0.5), pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 1.7, 0), STEEL, Enum.Material.Metal)
                arm.Name = "Tuas" .. s.nama .. "Arm"
                arm:SetAttribute("CFNaik", pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 1.7, 0))
                arm:SetAttribute("CFTurun", pivot * CFrame.Angles(0, 0, math.rad(turun)) * CFrame.new(0, 1.7, 0))
                local knob = BuildingKit.part(model, Vector3.new(0.9, 0.9, 0.9), pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 3.78, 0), BRICKRED, Enum.Material.Neon)
                knob.Shape = Enum.PartType.Ball
                knob.Name = "Tuas" .. s.nama .. "Knob"
                knob:SetAttribute("CFNaik", pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 3.78, 0))
                knob:SetAttribute("CFTurun", pivot * CFrame.Angles(0, 0, math.rad(turun)) * CFrame.new(0, 3.78, 0))
                local lampu = BuildingKit.part(model, Vector3.new(0.42, 0.42, 0.42), CFrame.new(x, 3.35, z + 0.95), LAMPU_OFF, Enum.Material.Neon)
                lampu.Shape = Enum.PartType.Ball
                lampu.Name = "Tuas" .. s.nama .. "Lampu"
                lampu.CanCollide = false
                local label = Instance.new("SurfaceGui")
                label.Face = Enum.NormalId.Front
                label.CanvasSize = Vector2.new(160, 90)
                local teksLabel = Instance.new("TextLabel")
                teksLabel.Size = UDim2.fromScale(1, 1)
                teksLabel.BackgroundTransparency = 1
                teksLabel.Text = "TUAS " .. string.upper(s.nama)
                teksLabel.TextColor3 = Color3.fromRGB(255, 232, 180)
                teksLabel.TextScaled = true
                teksLabel.Font = Enum.Font.GothamBold
                teksLabel.Parent = label
                label.Parent = tiangTuas
                BuildingKit.part(model, Vector3.new(7.9, 0.45, 0.45), CFrame.new(s.arah * 7.25, 2, z), STEEL_DARK, Enum.Material.Metal)
                for _, px in ipairs({ 5.4, 9 }) do
                        BuildingKit.part(model, Vector3.new(0.35, 1.3, 0.35), CFrame.new(s.arah * px, 1.9, z), STEEL, Enum.Material.Metal)
                end
                local suaraTuas = Instance.new("Sound")
                suaraTuas.Name = "SuaraTuas" .. s.nama
                suaraTuas.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                suaraTuas.Volume = 0.65
                suaraTuas.PlaybackSpeed = 0.5
                suaraTuas.RollOffMaxDistance = 90
                suaraTuas.Parent = tiangTuas
                local promptTuas = Instance.new("ProximityPrompt")
                promptTuas.Name = "PromptTuas" .. s.nama
                promptTuas.ActionText = "Tekan Tuas"
                promptTuas.ObjectText = "Tuas " .. s.nama
                promptTuas.HoldDuration = 0.2
                promptTuas.MaxActivationDistance = 9
                promptTuas.RequiresLineOfSight = false
                promptTuas.Enabled = false
                promptTuas.Parent = tiangTuas
                promptTuas.Triggered:Connect(function(player: Player)
                        if hooks and hooks.onTuasPrompt then
                                hooks.onTuasPrompt(player, index, string.lower(s.nama))
                        end
                end)
        end

        local corong = BuildingKit.part(model, Vector3.new(2.8, 0.35, 2.2), CFrame.new(-4.6, 6.9, 3) * CFrame.Angles(0, 0, math.rad(32)), STEEL_DARK, Enum.Material.Metal)
        corong.CanCollide = false
        BuildingKit.part(model, Vector3.new(0.35, 2.4, 2), CFrame.new(-5.75, 5.7, 3), STEEL_DARK, Enum.Material.Metal).CanCollide = false
        local _bak = BuildingKit.part(model, Vector3.new(2.8, 2.4, 2.8), CFrame.new(-7.4, 2.75, 3), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.9, 0.25, 2.9), CFrame.new(-7.4, 4.05, 3), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        for i = 0, 2 do
                local buah = BuildingKit.part(model, Vector3.new(0.8, 0.8, 0.8), CFrame.new(-7.9 + i * 0.55, 4.5, 3.1 + (i % 2) * 0.3), (i == 1) and STEEL_BLUE or ACCENT_ORANGE, Enum.Material.SmoothPlastic)
                buah.Shape = Enum.PartType.Ball
                buah.CanCollide = false
        end

        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.4, 6, 0.4), CFrame.new(sx * 3.4, 5, -4.6), STEEL_DARK, Enum.Material.Metal)
        end
        local papan = BuildingKit.part(model, Vector3.new(8.6, 3.4, 0.5), CFrame.new(0, 8.6, -4.6), DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(520, 200)
        local judul = Instance.new("TextLabel")
        judul.Size = UDim2.new(1, -12, 0.42, 0)
        judul.Position = UDim2.new(0, 6, 0.04, 0)
        judul.BackgroundTransparency = 1
        judul.Text = "MESIN SEMAI PANEN"
        judul.TextColor3 = Color3.fromRGB(255, 232, 180)
        judul.TextScaled = true
        judul.Font = Enum.Font.GothamBlack
        judul.Parent = gui
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusMesin"
        statusLabel.Size = UDim2.new(1, -12, 0.44, 0)
        statusLabel.Position = UDim2.new(0, 6, 0.5, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "NONAKTIF"
        statusLabel.TextColor3 = Color3.fromRGB(208, 210, 216)
        statusLabel.TextScaled = true
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = gui
        local guiBack = gui:Clone()
        guiBack.Face = Enum.NormalId.Back
        gui.Parent = papan
        guiBack.Parent = papan

        local tong = BuildingKit.part(model, Vector3.new(2.4, 2, 2), CFrame.new(12.5, 2.2, -7), STEEL_BLUE, Enum.Material.Metal)
        tong.Shape = Enum.PartType.Cylinder
        tong.CFrame = CFrame.new(12.5, 2.2, -7) * CFrame.Angles(0, 0, math.rad(90))
        local tongBand = BuildingKit.part(model, Vector3.new(0.3, 2.05, 2.05), CFrame.new(12.5, 2.2, -7), STEEL, Enum.Material.Metal)
        tongBand.Shape = Enum.PartType.Cylinder
        tongBand.CFrame = CFrame.new(12.5, 2.2, -7) * CFrame.Angles(0, 0, math.rad(90))
        tongBand.CanCollide = false
        local tong2 = BuildingKit.part(model, Vector3.new(2.4, 2, 2), CFrame.new(12.5, 2.2, -4), ACCENT_ORANGE, Enum.Material.Metal)
        tong2.Shape = Enum.PartType.Cylinder
        tong2.CFrame = CFrame.new(12.5, 2.2, -4) * CFrame.Angles(0, 0, math.rad(90))
        for i = 0, 2 do
                BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(9 + i * 2.4, 2.3, -8.6), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        end
        local _kotakAlat = BuildingKit.part(model, Vector3.new(1.6, 0.9, 1), CFrame.new(-12, 1.65, 7.5), BRICKRED, Enum.Material.Metal)
        BuildingKit.part(model, Vector3.new(0.9, 0.16, 0.3), CFrame.new(-12, 2.25, 7.5), STEEL, Enum.Material.Metal).CanCollide = false
        for i = 0, 1 do
                local karung = BuildingKit.part(model, Vector3.new(1.6, 1.9, 1), CFrame.new(-12.6 + i * 1.8, 2.15, -8.2), (i == 0) and Color3.fromRGB(150, 108, 62) or Color3.fromRGB(96, 128, 72), Enum.Material.Fabric)
                karung.CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(1.6, 1.9, 1), CFrame.new(-11.7, 3.9, -8.2), Color3.fromRGB(196, 168, 120), Enum.Material.Fabric).CanCollide = false
        local pipa = BuildingKit.part(model, Vector3.new(22, 0.7, 0.7), CFrame.new(0, 2.6, 13.6), STEEL_DARK, Enum.Material.Metal)
        pipa.CanCollide = false
        for i = 0, 3 do
                BuildingKit.part(model, Vector3.new(0.35, 1.6, 0.35), CFrame.new(-8 + i * 5.4, 1.9, 13.6), STEEL, Enum.Material.Metal).CanCollide = false
        end

        local suaraGiling = Instance.new("Sound")
        suaraGiling.Name = "SuaraGiling"
        suaraGiling.SoundId = "rbxasset://sounds/swoosh.wav"
        suaraGiling.Looped = true
        suaraGiling.Volume = 0.55
        suaraGiling.PlaybackSpeed = 0.55
        suaraGiling.RollOffMaxDistance = 90
        suaraGiling.Parent = drum
        local suaraDing = Instance.new("Sound")
        suaraDing.Name = "SuaraDing"
        suaraDing.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        suaraDing.Volume = 0.6
        suaraDing.PlaybackSpeed = 0.72
        suaraDing.RollOffMaxDistance = 90
        suaraDing.Parent = pedestal
        local suaraStart = Instance.new("Sound")
        suaraStart.Name = "SuaraStart"
        suaraStart.SoundId = "rbxasset://sounds/swoosh.wav"
        suaraStart.Volume = 0.5
        suaraStart.PlaybackSpeed = 1.25
        suaraStart.RollOffMaxDistance = 90
        suaraStart.Parent = pedestal

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Semai Panen"
        prompt.ObjectText = "Mesin Semai"
        prompt.HoldDuration = 0.3
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = pedestal
        prompt.Triggered:Connect(function(player: Player)
                if hooks and hooks.onSemaiPrompt then
                        hooks.onSemaiPrompt(player, index)
                end
        end)

        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

return BuildingKit

end)()

local MOD_LandService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = MOD_Layout

local LandService = {}

local ownerOf: { [number]: number } = {}
local landOf: { [number]: number } = {}
local umumSpawn: SpawnLocation? = nil
local kotaSpawn: SpawnLocation? = nil

function LandService.registerUmum(spawn: SpawnLocation)
        umumSpawn = spawn
end

function LandService.registerKota(spawn: SpawnLocation)
        kotaSpawn = spawn
end

function LandService.origin(index: number): Vector3
        local x, z = Layout.cellOrigin(index)
        return Vector3.new(x + Layout.duniaOffsetX(), 0, z)
end

function LandService.ownerOf(index: number): number?
        return ownerOf[index]
end

function LandService.landOf(player): number?
        return landOf[player.UserId]
end

function LandService.umumSpawn(): SpawnLocation?
        return umumSpawn
end

function LandService.kotaSpawn(): SpawnLocation?
        return kotaSpawn
end

function LandService.claimFree(userId: number, isTaken: (number) -> boolean): number
        for i = 1, Layout.LahanCount do
                if not ownerOf[i] and not isTaken(i) then
                        ownerOf[i] = userId
                        landOf[userId] = i
                        return i
                end
        end
        return 0
end

function LandService.firstFree(isTaken: (number) -> boolean): number
        for i = 1, Layout.LahanCount do
                if not ownerOf[i] and not isTaken(i) then
                        return i
                end
        end
        return 0
end

function LandService.reserve(index: number, userId: number): boolean
        if ownerOf[index] then
                return false
        end
        ownerOf[index] = userId
        return true
end

function LandService.claim(index: number, userId: number): boolean
        if ownerOf[index] and ownerOf[index] ~= userId then
                return false
        end
        ownerOf[index] = userId
        landOf[userId] = index
        return true
end

function LandService.free(index: number, userId: number)
        if ownerOf[index] == userId then
                ownerOf[index] = nil
                if landOf[userId] == index then
                        landOf[userId] = nil
                end
        end
end

function LandService.isInside(index: number, position: Vector3, margin: number): boolean
        local o = LandService.origin(index)
        local p = position - o
        return p.X >= -margin and p.X <= Layout.SizeX + margin and p.Z >= -margin and p.Z <= Layout.SizeZ + margin
end

return LandService

end)()

local MOD_DataService = (function()
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local Net = MOD_Remotes
local UangLogic = MOD_UangLogic
local SesiLogic = MOD_SesiLogic
local SanitasiTas = MOD_SanitasiTas

local DataService = {}

local store = DataStoreService:GetDataStore("AKM_T1")
local jobId = game.JobId ~= "" and game.JobId or "studio"
local cache: { [number]: any } = {}
local dirty: { [number]: boolean } = {}
local loadedOk: { [number]: boolean } = {}
local zoneProvider: ((Player) -> (string, string?))? = nil
local lahanProvider: ((Player) -> number?)? = nil

local function now(): number
        return os.time()
end

local function defaultData(): any
        return { u = UangLogic.baru(CropData.StartMoney), t = {}, dev = false }
end

function DataService.setZoneProvider(fn)
        zoneProvider = fn
end

function DataService.setLahanProvider(fn)
        lahanProvider = fn
end

local function push(player: Player)
        local d = cache[player.UserId]
        if not d then
                return
        end
        local payload: any = { micda = UangLogic.saldo(d.u), tas = d.t }
        if zoneProvider then
                local z, dn = zoneProvider(player)
                payload.zone = z
                payload.dunia = dn
        end
        if lahanProvider then
                payload.lahan = lahanProvider(player)
        end
        Net.get("Sync"):FireClient(player, payload)
        local ls = player:FindFirstChild("leaderstats")
        if ls then
                local v = ls:FindFirstChild("Micda")
                if v then
                        v.Value = UangLogic.saldo(d.u)
                end
        end
end

function DataService.get(player: Player)
        return cache[player.UserId]
end

function DataService.uangState(player: Player)
        local d = cache[player.UserId]
        return d and d.u or nil
end

function DataService.markDirty(player: Player)
        dirty[player.UserId] = true
end

function DataService.push(player: Player)
        push(player)
end

function DataService.bolehSimpan(player: Player): boolean
        return loadedOk[player.UserId] == true
end

local function ambilKunci(userId: number): boolean
        local ambil = false
        local ok = pcall(function()
                store:UpdateAsync("l_" .. tostring(userId), function(old)
                        if SesiLogic.bisaAmbil(old, jobId, now()) then
                                ambil = true
                                return SesiLogic.kunciBaru(jobId, now())
                        end
                        ambil = false
                        return old
                end)
        end)
        return ok and ambil
end

local function lepasKunci(userId: number)
        pcall(function()
                store:UpdateAsync("l_" .. tostring(userId), function(old)
                        if type(old) == "table" and old.j == jobId then
                                return SesiLogic.lepas(jobId)
                        end
                        return old
                end)
        end)
end

function DataService.load(player: Player): (boolean, string?, number)
        local userId = player.UserId
        local ok, data = pcall(function()
                return store:GetAsync("u_" .. tostring(userId))
        end)
        if not ok then
                cache[userId] = defaultData()
                loadedOk[userId] = false
                dirty[userId] = false
                push(player)
                return false, "galat", 0
        end
        if type(data) == "table" and type(data.m) == "number" and not data.u then
                data.u = UangLogic.baru(data.m)
        end
        if type(data) ~= "table" or type(data.u) ~= "table" or type(data.u.m) ~= "number" then
                data = { u = UangLogic.baru(CropData.StartMoney), t = {}, dev = false }
        end
        if not ambilKunci(userId) then
                cache[userId] = defaultData()
                loadedOk[userId] = false
                dirty[userId] = false
                push(player)
                return false, "kunci", 0
        end
        local tasBersih, dibuang = SanitasiTas.bersih(data.t, CropData.byId)
        cache[userId] = {
                u = { m = data.u.m, ledger = type(data.u.ledger) == "table" and data.u.ledger or {} },
                t = tasBersih,
                dev = data.dev == true,
        }
        loadedOk[userId] = true
        dirty[userId] = dibuang > 0
        push(player)
        return true, nil, dibuang
end

local function simpanSekali(userId: number, d: any): boolean
        local hasil = false
        local ok = pcall(function()
                store:UpdateAsync("u_" .. tostring(userId), function()
                        hasil = true
                        return {
                                u = { m = UangLogic.saldo(d.u), ledger = d.u.ledger },
                                t = d.t,
                                dev = d.dev,
                        }
                end)
        end)
        return ok and hasil
end

function DataService.save(player: Player)
        local userId = player.UserId
        local d = cache[userId]
        if not d or not loadedOk[userId] or not dirty[userId] then
                return
        end
        for i = 1, 3 do
                if simpanSekali(userId, d) then
                        dirty[userId] = false
                        return
                end
                task.wait(0.4 * i)
        end
end

function DataService.startLoops()
        task.spawn(function()
                while true do
                        task.wait(75)
                        for _, p in ipairs(Players:GetPlayers()) do
                                DataService.save(p)
                        end
                end
        end)
end

function DataService.drop(player: Player)
        local userId = player.UserId
        if loadedOk[userId] then
                lepasKunci(userId)
        end
        cache[userId] = nil
        dirty[userId] = nil
        loadedOk[userId] = nil
end

return DataService

end)()

local MOD_TasService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TasLogic = MOD_TasLogic

local TasService = {}
local dataOf: any = nil

function TasService.bind(dataService)
	dataOf = dataService
end

function TasService.tas(player)
	local d = dataOf.get(player)
	return d and d.t or nil
end

function TasService.roomFor(player, kind: string, id: string, want: number): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	return TasLogic.roomFor(tas, kind, id, want)
end

function TasService.add(player, kind: string, id: string, count: number): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	local put = TasLogic.add(tas, kind, id, count)
	if put > 0 then
		dataOf.markDirty(player)
		dataOf.push(player)
	end
	return put
end

function TasService.remove(player, kind: string, id: string, count: number): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	local took = TasLogic.remove(tas, kind, id, count)
	if took > 0 then
		dataOf.markDirty(player)
		dataOf.push(player)
	end
	return took
end

function TasService.count(player, kind: string, id: string): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	return TasLogic.countOf(tas, kind, id)
end

function TasService.canFitBatch(player, items): boolean
	local tas = TasService.tas(player)
	if not tas then
		return false
	end
	return TasLogic.canFitBatch(tas, items)
end

return TasService

end)()

local MOD_MesinSemaiService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CropData = MOD_CropData
local SemaiLogic = MOD_SemaiLogic
local MesinLogika = MOD_MesinLogika
local UangLogic = MOD_UangLogic

local MesinSemaiService = {}

local Land, Tas, Uang, Net, World
local rng = Random.new()

local mesin: { [number]: any } = {}
local batch: { [number]: any } = {}

local TEKS_TAHAP = {
        kosong = { teks = "NONAKTIF", warna = { 208, 210, 216 } },
        tuas = { teks = "TEKAN TUAS KANAN LALU KIRI", warna = { 255, 214, 110 } },
        giling = { teks = "MENGGILING...", warna = { 255, 158, 74 } },
        tuntas = { teks = "SEMAI TUNTAS - KLAIM HASIL", warna = { 122, 232, 130 } },
}

local LAMPU_MATI = 0.55
local LAMPU_NYALA = 0

local WAKTU_ANIM_TUAS = 0.45

local function bagian(model: Instance, nama: string): any
        local d = model:FindFirstChild(nama, true)
        return d
end

local function baseOf(p: BasePart?): CFrame?
        if p and p.Parent then
                return p.CFrame
        end
        return nil
end

function MesinSemaiService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Uang = deps.Uang
        Net = deps.Net
        World = deps.World
end

local function daftarTuas(model: Model, nama: string): any
        local pedestal = bagian(model, "Tuas" .. nama .. "Pedestal")
        local arm = bagian(model, "Tuas" .. nama .. "Arm")
        local knob = bagian(model, "Tuas" .. nama .. "Knob")
        if not arm or not arm:GetAttribute("CFNaik") then
                return nil
        end
        return {
                arm = arm,
                knob = knob,
                lampu = bagian(model, "Tuas" .. nama .. "Lampu"),
                prompt = pedestal and pedestal:FindFirstChild("PromptTuas" .. nama),
                suara = pedestal and pedestal:FindFirstChild("SuaraTuas" .. nama),
                cfNaik = arm:GetAttribute("CFNaik"),
                cfTurun = arm:GetAttribute("CFTurun"),
                knobNaik = knob and knob:GetAttribute("CFNaik"),
                knobTurun = knob and knob:GetAttribute("CFTurun"),
        }
end

function MesinSemaiService.registerMesin(index: number, model: Model)
        local drum = bagian(model, "MesinDrum")
        local m = {
                pos = model:GetPivot().Position,
                status = bagian(model, "StatusMesin"),
                drum = drum,
                drumBase = baseOf(drum),
                girA = bagian(model, "MesinGirA"),
                girABase = baseOf(bagian(model, "MesinGirA")),
                girB = bagian(model, "MesinGirB"),
                girBBase = baseOf(bagian(model, "MesinGirB")),
                roda = bagian(model, "MesinRoda"),
                rodaBase = baseOf(bagian(model, "MesinRoda")),
                rib1 = bagian(model, "MesinRib1"),
                rib1Base = baseOf(bagian(model, "MesinRib1")),
                rib2 = bagian(model, "MesinRib2"),
                rib2Base = baseOf(bagian(model, "MesinRib2")),
                rib3 = bagian(model, "MesinRib3"),
                rib3Base = baseOf(bagian(model, "MesinRib3")),
                lampuMerah = bagian(model, "MesinLampuMerah"),
                lampuKuning = bagian(model, "MesinLampuKuning"),
                lampuHijau = bagian(model, "MesinLampuHijau"),
                asap = bagian(model, "AsapMesin"),
                suaraGiling = bagian(model, "SuaraGiling"),
                suaraDing = bagian(model, "SuaraDing"),
                suaraStart = bagian(model, "SuaraStart"),
                tuasKanan = daftarTuas(model, "Kanan"),
                tuasKiri = daftarTuas(model, "Kiri"),
                blink = false,
                mode = "",
        }
        mesin[index] = m
        if m.asap then
                m.asap.Enabled = false
        end
        if m.suaraGiling then
                m.suaraGiling.Playing = false
        end
        MesinSemaiService.terapkanTahap(index)
end

local function setStatus(index: number)
        local m = mesin[index]
        if not m or not m.status or not m.status.Parent then
                return
        end
        local b = batch[index]
        local cfg = TEKS_TAHAP[b and b.tahap or "kosong"]
        m.status.Text = cfg.teks
        m.status.TextColor3 = Color3.fromRGB(cfg.warna[1], cfg.warna[2], cfg.warna[3])
end

local function setLampu(part: any, warna: Color3, nyala: boolean)
        if part and part.Parent then
                part.Color = warna
                part.Transparency = nyala and LAMPU_NYALA or LAMPU_MATI
        end
end

local MERAH_ON = Color3.fromRGB(232, 76, 60)
local KUNING_ON = Color3.fromRGB(255, 206, 84)
local HIJAU_ON = Color3.fromRGB(108, 220, 116)
local LAMPU_OFF = Color3.fromRGB(72, 76, 84)

local function lampuTuas(index: number, nama: string, t: any, kuningBlink: boolean)
        local m = mesin[index]
        local tuas = m and m["tuas" .. nama]
        if not tuas or not tuas.lampu then
                return
        end
        if type(t) == "table" and t[string.lower(nama)] == true then
                setLampu(tuas.lampu, HIJAU_ON, true)
        elseif kuningBlink then
                setLampu(tuas.lampu, KUNING_ON, true)
        else
                setLampu(tuas.lampu, LAMPU_OFF, false)
        end
end

local function lampuUpdate(index: number)
        local m = mesin[index]
        if not m then
                return
        end
        local b = batch[index]
        local tahap = b and b.tahap or "kosong"
        if tahap ~= m.mode then
                m.mode = tahap
                m.blink = false
        end
        local tuasAktif = tahap == "tuas"
        local merahNyala = tahap == "kosong"
        local kuningNyala = tahap == "giling" or (tuasAktif and m.blink)
        local hijauNyala = tahap == "tuntas"
        setLampu(m.lampuMerah, merahNyala and MERAH_ON or LAMPU_OFF, merahNyala)
        setLampu(m.lampuKuning, kuningNyala and KUNING_ON or LAMPU_OFF, kuningNyala)
        setLampu(m.lampuHijau, hijauNyala and HIJAU_ON or LAMPU_OFF, hijauNyala)
        local t = tuasAktif and b.tuas or nil
        lampuTuas(index, "Kanan", t, tuasAktif and m.blink)
        lampuTuas(index, "Kiri", t, tuasAktif and m.blink and (type(t) == "table" and t.kanan == true))
end

local function aturPromptTuas(index: number)
        local m = mesin[index]
        if not m then
                return
        end
        local b = batch[index]
        local tahap = b and b.tahap or "kosong"
        local t = b and b.tuas
        local berikut = (tahap == "tuas") and SemaiLogic.tuasBerikut(t) or nil
        if m.tuasKanan and m.tuasKanan.prompt then
                m.tuasKanan.prompt.Enabled = berikut == "kanan"
        end
        if m.tuasKiri and m.tuasKiri.prompt then
                m.tuasKiri.prompt.Enabled = berikut == "kiri"
        end
end

function MesinSemaiService.terapkanTahap(index: number)
        setStatus(index)
        lampuUpdate(index)
        aturPromptTuas(index)
        local m = mesin[index]
        if not m then
                return
        end
        local b = batch[index]
        local tahap = b and b.tahap or "kosong"
        local aktif = tahap == "giling"
        if m.asap then
                m.asap.Enabled = aktif
        end
        if m.suaraGiling then
                m.suaraGiling.Playing = aktif
        end
        if tahap == "tuntas" and m.suaraDing then
                m.suaraDing:Play()
        end
        if tahap == "giling" and m.suaraStart then
                m.suaraStart:Play()
        end
end

local function animasiTuas(m: any, nama: string, turun: boolean)
        local tuas = m and m["tuas" .. nama]
        if not tuas or not tuas.cfTurun or not tuas.cfNaik then
                return
        end
        local target = turun and tuas.cfTurun or tuas.cfNaik
        local targetKnob = turun and tuas.knobTurun or tuas.knobNaik
        local info = TweenInfo.new(WAKTU_ANIM_TUAS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(tuas.arm, info, { CFrame = target }):Play()
        if tuas.knob and targetKnob then
                TweenService:Create(tuas.knob, info, { CFrame = targetKnob }):Play()
        end
end

RunService.Heartbeat:Connect(function(dt)
        local now = os.clock()
        for index, m in pairs(mesin) do
                local b = batch[index]
                if b and b.tahap == "giling" then
                        local sudut = now * 8
                        local putar = CFrame.Angles(sudut, 0, 0)
                        if m.drum and m.drumBase then
                                m.drum.CFrame = m.drumBase * putar
                        end
                        if m.rib1 and m.rib1Base then
                                m.rib1.CFrame = m.rib1Base * putar
                        end
                        if m.rib2 and m.rib2Base then
                                m.rib2.CFrame = m.rib2Base * putar
                        end
                        if m.rib3 and m.rib3Base then
                                m.rib3.CFrame = m.rib3Base * putar
                        end
                        if m.girA and m.girABase then
                                m.girA.CFrame = m.girABase * CFrame.Angles(now * 6, 0, 0)
                        end
                        if m.girB and m.girBBase then
                                m.girB.CFrame = m.girBBase * CFrame.Angles(-now * 6, 0, 0)
                        end
                        if m.roda and m.rodaBase then
                                m.roda.CFrame = m.rodaBase * CFrame.Angles(now * 10, 0, 0)
                        end
                end
        end
end)

task.spawn(function()
        while true do
                task.wait(0.4)
                for index, m in pairs(mesin) do
                        local b = batch[index]
                        local tahap = b and b.tahap or "kosong"
                        if tahap == "tuas" then
                                m.blink = not m.blink
                        elseif m.blink then
                                m.blink = false
                        end
                        lampuUpdate(index)
                end
        end
end)

local function syncLahan(index: number, player: Player?)
        local b = batch[index]
        local p: any = { lahan = index, tahap = b and b.tahap or "kosong" }
        if b then
                p.crop = b.crop
                p.jumlah = b.jumlah
                p.pukulan = b.pukulan
                p.micda = b.hasil.micda
                p.benih = b.hasil.benih
                if b.tahap == "tuas" then
                        p.tuas = { kanan = b.tuas.kanan, kiri = b.tuas.kiri }
                end
        end
        local ev = Net.get("SemaiSync")
        if player then
                ev:FireClient(player, p)
                return
        end
        for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
                if Land.landOf(pl) == index then
                        ev:FireClient(pl, p)
                end
        end
end

function MesinSemaiService.syncTo(player, index: number)
        syncLahan(index, player)
end

function MesinSemaiService.clearLahan(index: number)
        batch[index] = nil
        local m = mesin[index]
        if m then
                m.mode = ""
                m.blink = false
        end
        MesinSemaiService.terapkanTahap(index)
end

local function dekatMesin(player: Player, index: number): boolean
        local m = mesin[index]
        if not m then
                return false
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - m.pos).Magnitude > CropData.MesinSemai.JarakMaks then
                return false
        end
        return true
end

local function resetTuas(index: number)
        local m = mesin[index]
        if not m then
                return
        end
        for _, nama in ipairs({ "Kanan", "Kiri" }) do
                local tuas = m["tuas" .. nama]
                if tuas and tuas.cfNaik then
                        tuas.arm.CFrame = tuas.cfNaik
                        if tuas.knob and tuas.knobNaik then
                                tuas.knob.CFrame = tuas.knobNaik
                        end
                end
        end
end

function MesinSemaiService.atur(player, cropId: any, jumlah: any): (boolean, string, any?)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Hasil panen tidak dikenal."
        end
        if not mesin[index] or not dekatMesin(player, index) then
                return false, "Terlalu jauh dari mesin."
        end
        local b = batch[index]
        if b and b.pemilik ~= player.UserId then
                return false, "Bukan semaianmu."
        end
        local info = CropData.byId[cropId]
        local namaB = "?"
        if b then
                local infoB = CropData.byId[b.crop]
                namaB = infoB and infoB.nama or tostring(b.crop)
        end
        local dimiliki = Tas.count(player, "hasil", cropId)
        local ok, pesan = MesinLogika.atur(b, cropId, jumlah, dimiliki, CropData.MesinSemai.Kapasitas, info.nama, namaB)
        if not ok then
                return false, pesan
        end
        local cfg = CropData.Giling[info.rarity]
        local per = SemaiLogic.pukulanPerItem(cfg)
        local diambil = Tas.remove(player, "hasil", cropId, jumlah)
        if diambil < 1 then
                return false, "Hasil panen tidak bisa diambil dari tas."
        end
        local tambahan = SemaiLogic.gulung(rng, cfg, diambil)
        if b then
                b.jumlah += diambil
                b.pukulan += SemaiLogic.pukulanTotal(diambil, per)
                b.hasil.micda += tambahan.micda
                b.hasil.benih += tambahan.benih
        else
                resetTuas(index)
                batch[index] = {
                        pemilik = player.UserId,
                        crop = cropId,
                        jumlah = diambil,
                        pukulan = SemaiLogic.pukulanTotal(diambil, per),
                        hasil = tambahan,
                        tahap = "tuas",
                        tuas = SemaiLogic.tuasBaru(),
                }
        end
        if World then
                World.touch(index)
        end
        MesinSemaiService.terapkanTahap(index)
        syncLahan(index)
        local total = batch[index].jumlah
        local kapasitas = CropData.MesinSemai.Kapasitas
        return true, info.nama .. " x" .. tostring(diambil) .. " masuk mesin (isi " .. tostring(total) .. "/" .. tostring(kapasitas) .. "). Tekan tuas KANAN, lalu tuas KIRI!", {
                crop = cropId,
                jumlah = total,
                pukulan = batch[index].pukulan,
                kapasitas = kapasitas,
                sisa = kapasitas - total,
        }
end

function MesinSemaiService.tekan(player, sisi: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        local b = batch[index]
        if not b then
                return false, "Mesin kosong. Isi dulu hasil panennya."
        end
        if b.pemilik ~= player.UserId then
                return false, "Bukan semaianmu."
        end
        if b.tahap ~= "tuas" then
                return false, "Tuas sudah selesai ditekan."
        end
        if not dekatMesin(player, index) then
                return false, "Terlalu jauh dari mesin."
        end
        local ok, kode = SemaiLogic.prosesTekan(b.tuas, sisi)
        if not ok then
                if kode == "urutan" then
                        local berikut = SemaiLogic.tuasBerikut(b.tuas)
                        return false, "Urutan salah! Tekan tuas " .. string.upper(berikut or "kanan") .. " dulu."
                elseif kode == "sudah" then
                        return false, "Tuas ini sudah ditekan."
                elseif kode == "sisi" then
                        return false, "Sisi tuas tidak dikenal."
                end
                return false, "Tuas tidak bisa ditekan."
        end
        local namaBesar = (sisi == "kanan") and "Kanan" or "Kiri"
        animasiTuas(mesin[index], namaBesar, true)
        local tuasM = mesin[index] and mesin[index]["tuas" .. namaBesar]
        if tuasM and tuasM.suara then
                tuasM.suara:Play()
        end
        if SemaiLogic.tuasSelesai(b.tuas) then
                b.tahap = "giling"
                MesinSemaiService.terapkanTahap(index)
                syncLahan(index)
                local waktu = CropData.MesinSemai.WaktuGiling
                task.delay(waktu, function()
                        local b2 = batch[index]
                        if b2 and b2.tahap == "giling" then
                                b2.tahap = "tuntas"
                                if World then
                                        World.touch(index)
                                end
                                MesinSemaiService.terapkanTahap(index)
                                syncLahan(index)
                        end
                end)
                return true, "Kedua tuas aktif! Mesin menyala dan menggiling selama " .. tostring(waktu) .. " detik."
        end
        MesinSemaiService.terapkanTahap(index)
        syncLahan(index)
        if sisi == "kanan" then
                return true, "Tuas KANAN aktif! Sekarang tekan tuas KIRI."
        end
        return true, "Tuas aktif."
end

function MesinSemaiService.klaim(player): (boolean, string, any)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        local b = batch[index]
        if not b then
                return false, "Mesin kosong. Belum ada hasil untuk diklaim."
        end
        if b.pemilik ~= player.UserId then
                return false, "Bukan semaianmu."
        end
        if b.tahap == "tuas" then
                return false, "Tekan kedua tuas mesin dulu."
        elseif b.tahap == "giling" then
                return false, "Mesin masih menggiling. Tunggu sebentar."
        end
        if not dekatMesin(player, index) then
                return false, "Terlalu jauh dari mesin."
        end
        local info = CropData.byId[b.crop]
        local items = {}
        if b.hasil.benih > 0 then
                table.insert(items, { kind = "benih", id = b.crop, count = b.hasil.benih })
        end
        if #items > 0 and not Tas.canFitBatch(player, items) then
                return false, "Tas penuh! Kosongkan slot dulu, lalu klaim lagi."
        end
        if b.hasil.micda > 0 and Uang then
                local ruang = Uang.RuangMicda(player)
                if ruang < b.hasil.micda then
                        return false, "Ruangan Micda rekeningmu tinggal " .. UangLogic.format(ruang) .. "! Isi micda lebih dulu, lalu klaim lagi."
                end
        end
        for _, it in ipairs(items) do
                Tas.add(player, it.kind, it.id, it.count)
        end
        local okUang, msgUang = true, "ok"
        if b.hasil.micda > 0 and Uang then
                okUang, msgUang = Uang.AddMicda(player, b.hasil.micda, "semai_hasil")
                if not okUang then
                        if b.hasil.benih > 0 then
                                Tas.remove(player, "benih", b.crop, b.hasil.benih)
                        end
                        return false, "Micda ditunda: " .. tostring(msgUang)
                end
        end
        local struk = {
                crop = b.crop,
                nama = info and info.nama or b.crop,
                jumlah = b.jumlah,
                pukulan = b.pukulan,
                micda = b.hasil.micda,
                benih = b.hasil.benih,
                uangOk = okUang,
        }
        batch[index] = nil
        if World then
                World.touch(index)
        end
        MesinSemaiService.terapkanTahap(index)
        syncLahan(index)
        if okUang then
                return true, "Semai tuntas! Semua hasil masuk tas.", struk
        end
        return false, "Micda ditunda: " .. tostring(msgUang), struk
end

function MesinSemaiService.serializeLahan(index: number): { any }
        local out = {}
        local b = batch[index]
        if b then
                table.insert(out, { c = b.crop, j = b.jumlah, m = b.hasil.micda, b = b.hasil.benih })
        end
        return out
end

function MesinSemaiService.restoreLahan(index: number, arr: any, ownerId: number?)
        if not mesin[index] then
                return
        end
        for _, rec in ipairs(arr or {}) do
                if type(rec) == "table" and type(rec.c) == "string" and CropData.byId[rec.c] then
                        local info = CropData.byId[rec.c]
                        local jumlah = 1
                        local micda = info.jual
                        local benih = 0
                        if type(rec.j) == "number" and rec.j >= 1 then
                                jumlah = math.min(math.floor(rec.j), CropData.MesinSemai.Kapasitas)
                                micda = type(rec.m) == "number" and math.max(0, math.floor(rec.m)) or 0
                                benih = type(rec.b) == "number" and math.max(0, math.floor(rec.b)) or 0
                        end
                        resetTuas(index)
                        batch[index] = {
                                pemilik = ownerId,
                                crop = rec.c,
                                jumlah = jumlah,
                                pukulan = jumlah,
                                hasil = { micda = micda, benih = benih },
                                tahap = "tuntas",
                        }
                        break
                end
        end
        MesinSemaiService.terapkanTahap(index)
end

return MesinSemaiService

end)()

local MOD_PlantModels = (function()
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData

local PlantModels = {}

local KAYAK = Color3.fromRGB(110, 82, 54)

local function warna3(t: any): Color3
        if type(t) == "table" then
                return Color3.fromRGB(t[1] or 255, t[2] or 255, t[3] or 255)
        end
        return Color3.fromRGB(200, 200, 200)
end

local function part(model: Model, size: Vector3, cf: CFrame, color: Color3, shape: Enum.PartType?): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanQuery = true
        p.CanTouch = false
        p.CanCollide = false
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        if shape then
                p.Shape = shape
        end
        p.Parent = model
        return p
end

local function buah(model: Model, size: Vector3, cf: CFrame, color: Color3): Part
        local p = part(model, size, cf, color, Enum.PartType.Ball)
        p:SetAttribute("Buah", true)
        return p
end

local function silinder(model: Model, tinggi: number, dia: number, cf: CFrame, color: Color3): Part
        return part(model, Vector3.new(tinggi, dia, dia), cf * CFrame.Angles(0, 0, math.rad(90)), color, Enum.PartType.Cylinder)
end

local function buatAkar(model: Model, pos: Vector3, b: any)
        local w = b.w
        local root = buah(model, Vector3.new(w, w * 0.7, w), CFrame.new(pos + Vector3.new(0, w * 0.22, 0)), b.warna)
        root.Shape = Enum.PartType.Ball
        for i = 0, b.b - 1 do
                local sudut = math.rad(i * (360 / b.b))
                local arah = CFrame.new(pos + Vector3.new(0, b.t * 0.45, 0)) * CFrame.Angles(0, sudut, 0) * CFrame.new(w * 0.35, 0, 0) * CFrame.Angles(0, 0, math.rad(24))
                part(model, Vector3.new(0.22, b.t * 0.85, 0.55), arah, b.aksen)
        end
end

local function buatDaun(model: Model, pos: Vector3, b: any)
        local w = b.w
        part(model, Vector3.new(w, 0.5, w), CFrame.new(pos + Vector3.new(0, 0.45, 0)), b.aksen)
        part(model, Vector3.new(w * 0.8, 0.5, w * 0.8), CFrame.new(pos + Vector3.new(0, 0.95, 0)), b.warna)
        part(model, Vector3.new(w * 0.55, 0.5, w * 0.55), CFrame.new(pos + Vector3.new(0, 1.45, 0)), b.aksen)
        buah(model, Vector3.new(w * 0.42, w * 0.42, w * 0.42), CFrame.new(pos + Vector3.new(0, b.t * 0.85, 0)), b.warna)
end

local function buatBulat(model: Model, pos: Vector3, b: any)
        buah(model, Vector3.new(b.w, b.w, b.w), CFrame.new(pos + Vector3.new(0, b.w * 0.48, 0)), b.warna)
        silinder(model, b.t * 0.8, 0.3, CFrame.new(pos + Vector3.new(0, b.w * 0.9 + b.t * 0.35, 0)), b.aksen)
end

local function buatTangkai(model: Model, pos: Vector3, b: any)
        local n = math.max(2, b.b)
        for i = 0, n - 1 do
                local sudut = (i / n) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.33
                local oz = math.sin(sudut) * b.w * 0.33
                local tinggi = b.t * (0.82 + 0.18 * ((i % 3) / 2))
                local dasar = pos + Vector3.new(ox, tinggi / 2, oz)
                silinder(model, tinggi, 0.22, CFrame.new(dasar), b.aksen)
                buah(model, Vector3.new(0.55, 0.55, 0.55), CFrame.new(pos + Vector3.new(ox, tinggi + 0.25, oz)), b.warna)
        end
end

local function buatPohon(model: Model, pos: Vector3, b: any)
        local batang = b.t * 0.62
        silinder(model, batang, 0.5, CFrame.new(pos + Vector3.new(0, batang / 2, 0)), KAYAK)
        local kanopiY = batang + b.w * 0.32
        part(model, Vector3.new(b.w, b.w * 0.8, b.w), CFrame.new(pos + Vector3.new(0, kanopiY, 0)), b.aksen, Enum.PartType.Ball)
        for i = 0, b.b - 1 do
                local sudut = (i / b.b) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.3
                local oz = math.sin(sudut) * b.w * 0.3
                local fy = kanopiY - 0.2 + 0.3 * ((i % 2))
                buah(model, Vector3.new(0.55, 0.55, 0.55), CFrame.new(pos + Vector3.new(ox, fy, oz)), b.warna)
        end
end

local function buatSemak(model: Model, pos: Vector3, b: any)
        silinder(model, b.t * 0.4, 0.3, CFrame.new(pos + Vector3.new(0, b.t * 0.2, 0)), KAYAK)
        part(model, Vector3.new(b.w, 0.4, b.w * 0.8), CFrame.new(pos + Vector3.new(0, b.t * 0.42, 0)), b.aksen)
        for i = 0, b.b - 1 do
                local sudut = (i / b.b) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.3
                local oz = math.sin(sudut) * b.w * 0.3
                buah(model, Vector3.new(b.w * 0.26, b.w * 0.26, b.w * 0.26), CFrame.new(pos + Vector3.new(ox, b.t * 0.62 + 0.22 * (i % 2), oz)), b.warna)
        end
end

local function buatKacang(model: Model, pos: Vector3, b: any)
        part(model, Vector3.new(b.w, 0.3, b.w * 0.8), CFrame.new(pos + Vector3.new(0, 0.35, 0)), b.aksen)
        part(model, Vector3.new(b.w * 0.6, 0.3, b.w * 0.5), CFrame.new(pos + Vector3.new(0, 0.65, 0)), b.aksen)
        for i = 0, b.b - 1 do
                local sudut = (i / b.b) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.28
                local oz = math.sin(sudut) * b.w * 0.24
                local pod = part(model, Vector3.new(0.62, 0.28, 0.26), CFrame.new(pos + Vector3.new(ox, 0.95, oz)) * CFrame.Angles(0, sudut, 0), b.warna)
                pod:SetAttribute("Buah", true)
        end
end

local function buatCendawan(model: Model, pos: Vector3, b: any)
        silinder(model, b.t * 0.6, 0.5, CFrame.new(pos + Vector3.new(0, b.t * 0.3, 0)), b.aksen)
        local topi = part(model, Vector3.new(0.6, b.w, b.w), CFrame.new(pos + Vector3.new(0, b.t * 0.72, 0)) * CFrame.Angles(0, 0, math.rad(90)), b.warna, Enum.PartType.Cylinder)
        topi:SetAttribute("Buah", true)
end

local PEMBENTUK: { [string]: (Model, Vector3, any) -> () } = {
        akar = buatAkar,
        daun = buatDaun,
        bulat = buatBulat,
        tangkai = buatTangkai,
        pohon = buatPohon,
        semak = buatSemak,
        kacang = buatKacang,
        cendawan = buatCendawan,
}

function PlantModels.buat(pos: Vector3, info: any): Model
        local model = Instance.new("Model")
        model.Name = "Tanaman"
        local b = CropData.Bentuk[info.id]
        local bentuk = b or { jenis = "daun", t = 1.6, w = 1.4, b = 1, warna = Color3.fromRGB(96, 140, 80), siap = Color3.fromRGB(220, 160, 70), aksen = Color3.fromRGB(110, 160, 90) }
        if type(b.warna) == "table" then
                bentuk = {
                        jenis = b.jenis,
                        t = b.t,
                        w = b.w,
                        b = b.b,
                        warna = warna3(b.warna),
                        siap = warna3(b.siap),
                        aksen = warna3(b.aksen),
                }
        end
        local pembentuk = PEMBENTUK[bentuk.jenis] or buatDaun
        pembentuk(model, pos, bentuk)
        return model
end

function PlantModels.setSiap(model: Model, info: any)
        local b = CropData.Bentuk[info.id]
        if not b then
                return
        end
        local siap = warna3(b.siap)
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        d.Color = siap
                        d.Size = d.Size * 1.12
                end
        end
        model:SetAttribute("Siap", true)
end

function PlantModels.efekKena(model: Model, titik: Vector3?, tier: number)
        local target: BasePart? = nil
        if titik then
                local terdekat = math.huge
                for _, d in ipairs(model:GetDescendants()) do
                        if d:IsA("BasePart") then
                                local jarak = (d.Position - titik).Magnitude
                                if jarak < terdekat then
                                        terdekat = jarak
                                        target = d
                                end
                        end
                end
        end
        if not target then
                for _, d in ipairs(model:GetDescendants()) do
                        if d:IsA("BasePart") and d:GetAttribute("Buah") then
                                target = d
                                break
                        end
                end
        end
        if not target then
                target = model:FindFirstChildWhichIsA("BasePart") :: BasePart?
        end
        if not target then
                return
        end
        local awal = target.Size
        local turun = TweenService:Create(target, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = awal * 0.78 })
        turun:Play()
        turun.Completed:Connect(function()
                if target.Parent then
                        TweenService:Create(target, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = awal }):Play()
                end
        end)
        local titikLokal = target.CFrame:PointToObjectSpace(titik or target.Position)
        local lampir = Instance.new("Attachment")
        lampir.Position = titikLokal
        lampir.Parent = target
        local pem = Instance.new("ParticleEmitter")
        pem.Color = ColorSequence.new(target.Color)
        pem.Lifetime = NumberRange.new(0.3, 0.6)
        pem.Speed = NumberRange.new(6, 12)
        pem.SpreadAngle = Vector2.new(180, 180)
        pem.Size = NumberSequence.new(0.4, 0)
        pem.Transparency = NumberSequence.new(0.15, 1)
        pem.Enabled = false
        pem.Parent = lampir
        pem:Emit(6 + 4 * tier)
        Debris:AddItem(lampir, 1.2)
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        snd.Volume = 0.3 + 0.08 * tier
        snd.PlaybackSpeed = 0.85
        snd.Parent = target
        snd:Play()
        Debris:AddItem(snd, 1.2)
end

return PlantModels

end)()

local MOD_DropModels = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local DropBentuk = MOD_DropBentuk

local DropModels = {}

local function warna3(t: any): Color3
	if type(t) == "table" then
		return Color3.fromRGB(t[1] or 200, t[2] or 200, t[3] or 200)
	end
	return Color3.fromRGB(200, 200, 200)
end

local function bagian(model: Model, ukuran: Vector3, cf: CFrame, warna: Color3, bentuk: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Size = ukuran
	p.CFrame = cf
	p.Color = warna
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	if bentuk then
		p.Shape = bentuk
	end
	p.Parent = model
	return p
end

local function bundar(model: Model, ukuran: Vector3, cf: CFrame, warna: Color3): Part
	return bagian(model, ukuran, cf, warna, Enum.PartType.Ball)
end

local function batang(model: Model, panjang: number, dia: number, cf: CFrame, warna: Color3): Part
	return bagian(model, Vector3.new(panjang, dia, dia), cf * CFrame.Angles(0, 0, math.rad(90)), warna, Enum.PartType.Cylinder)
end

local PEMBENTUK: { [string]: (Model, Vector3, number, Color3, Color3) -> Part } = {}

PEMBENTUK.akar = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.9 * s, 0.9 * s, 0.9 * s), CFrame.new(pos + Vector3.new(0, 1.1 * s, 0)), buah)
	bundar(model, Vector3.new(0.6 * s, 0.6 * s, 0.6 * s), CFrame.new(pos + Vector3.new(0, 0.45 * s, 0)), buah)
	bundar(model, Vector3.new(0.36 * s, 0.36 * s, 0.36 * s), CFrame.new(pos + Vector3.new(0, 0.05 * s, 0)), buah)
	batang(model, 0.4 * s, 0.16 * s, CFrame.new(pos + Vector3.new(0, 1.7 * s, 0)), aksen)
	return root
end

PEMBENTUK.kacang = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.8 * s, 0.8 * s, 0.8 * s), CFrame.new(pos + Vector3.new(0, 1.0 * s, 0)), buah)
	local kiri = bagian(model, Vector3.new(0.9 * s, 0.34 * s, 0.5 * s), CFrame.new(pos + Vector3.new(-0.6 * s, 0.4 * s, 0.1 * s)) * CFrame.Angles(0, 0, math.rad(14)), buah)
	local kanan = bagian(model, Vector3.new(0.9 * s, 0.34 * s, 0.5 * s), CFrame.new(pos + Vector3.new(0.6 * s, 0.4 * s, -0.1 * s)) * CFrame.Angles(0, 0, math.rad(-14)), aksen)
	return root, { kiri, kanan }
end

PEMBENTUK.daun = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.72 * s, 0.72 * s, 0.72 * s), CFrame.new(pos + Vector3.new(0, 1.0 * s, 0)), buah)
	local atas = bagian(model, Vector3.new(1.15 * s, 0.12 * s, 1.15 * s), CFrame.new(pos + Vector3.new(0, 1.5 * s, 0)) * CFrame.Angles(0, math.rad(24), 0), aksen)
	local bawah = bagian(model, Vector3.new(1.0 * s, 0.12 * s, 1.0 * s), CFrame.new(pos + Vector3.new(0, 0.55 * s, 0)) * CFrame.Angles(0, math.rad(-18), 0), aksen)
	return root, { atas, bawah }
end

PEMBENTUK.bulat = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(1.05 * s, 1.05 * s, 1.05 * s), CFrame.new(pos + Vector3.new(0, 1.05 * s, 0)), buah)
	local tangkai = batang(model, 0.42 * s, 0.16 * s, CFrame.new(pos + Vector3.new(0, 1.75 * s, 0)), aksen)
	return root, { tangkai }
end

PEMBENTUK.tangkai = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.5 * s, 0.5 * s, 0.5 * s), CFrame.new(pos + Vector3.new(0, 1.65 * s, 0)), buah)
	local kiri = batang(model, 1.1 * s, 0.14 * s, CFrame.new(pos + Vector3.new(-0.3 * s, 0.75 * s, 0)) * CFrame.Angles(math.rad(8), 0, math.rad(10)), aksen)
	local kanan = batang(model, 1.1 * s, 0.14 * s, CFrame.new(pos + Vector3.new(0.3 * s, 0.75 * s, 0.05 * s)) * CFrame.Angles(math.rad(-8), 0, math.rad(-10)), aksen)
	local butirKiri = bundar(model, Vector3.new(0.38 * s, 0.38 * s, 0.38 * s), CFrame.new(pos + Vector3.new(-0.42 * s, 1.4 * s, 0)), buah)
	local butirKanan = bundar(model, Vector3.new(0.38 * s, 0.38 * s, 0.38 * s), CFrame.new(pos + Vector3.new(0.42 * s, 1.4 * s, 0.05 * s)), buah)
	return root, { kiri, kanan, butirKiri, butirKanan }
end

PEMBENTUK.pohon = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.95 * s, 0.95 * s, 0.95 * s), CFrame.new(pos + Vector3.new(0, 1.3 * s, 0.18 * s)), buah)
	local daun = bundar(model, Vector3.new(1.1 * s, 1.1 * s, 1.1 * s), CFrame.new(pos + Vector3.new(0, 1.25 * s, -0.4 * s)), aksen)
	local batok = batang(model, 0.5 * s, 0.2 * s, CFrame.new(pos + Vector3.new(0, 0.45 * s, 0)), aksen)
	return root, { daun, batok }
end

PEMBENTUK.semak = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.7 * s, 0.7 * s, 0.7 * s), CFrame.new(pos + Vector3.new(0, 1.05 * s, 0)), buah)
	local kiri = bundar(model, Vector3.new(0.52 * s, 0.52 * s, 0.52 * s), CFrame.new(pos + Vector3.new(-0.5 * s, 0.8 * s, 0.1 * s)), buah)
	local kanan = bundar(model, Vector3.new(0.5 * s, 0.5 * s, 0.5 * s), CFrame.new(pos + Vector3.new(0.5 * s, 0.85 * s, -0.1 * s)), buah)
	local dasar = bagian(model, Vector3.new(1.0 * s, 0.14 * s, 1.0 * s), CFrame.new(pos + Vector3.new(0, 0.4 * s, 0)), aksen)
	return root, { kiri, kanan, dasar }
end

PEMBENTUK.cendawan = function(model, pos, s, buah, aksen)
	local root = batang(model, 0.42 * s, 1.0 * s, CFrame.new(pos + Vector3.new(0, 1.25 * s, 0)), buah)
	local badan = batang(model, 0.6 * s, 0.36 * s, CFrame.new(pos + Vector3.new(0, 0.6 * s, 0)), aksen)
	return root, { badan }
end

function DropModels.buat(pos: Vector3, cropId: string, tier: number): Model?
	local info = CropData.byId[cropId]
	if not info then
		return nil
	end
	local b = CropData.Bentuk[cropId]
	if not b then
		return nil
	end
	local spes = DropBentuk.spesifikasi(b)
	if not spes then
		return nil
	end
	local buah = warna3(spes.buah)
	local aksen = warna3(spes.aksen)
	local s = (spes.skala) * (1 + 0.14 * (tier or 1))
	local model = Instance.new("Model")
	model.Name = "Hasil_" .. cropId
	local pembentuk = PEMBENTUK[spes.jenis] or PEMBENTUK.bulat
	local root, ekstra = pembentuk(model, pos, s, buah, aksen)
	root.Name = "Hasil"
	root.CanCollide = true
	root.CanTouch = true
	root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
	for _, e in ipairs(ekstra or {}) do
		local las = Instance.new("WeldConstraint")
		las.Part0 = root
		las.Part1 = e
		las.Parent = root
	end
	model.PrimaryPart = root
	return model
end

return DropModels

end)()

local MOD_PlotService = (function()
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local Layout = MOD_Layout
local PanenStatus = MOD_PanenStatus
local PukulLogic = MOD_PukulLogic
local ArahPukul = MOD_ArahPukul
local PlantModels = MOD_PlantModels

local PlotService = {}

local Land, Net, World, Drop
local rng = Random.new()

local folders: { [number]: Folder } = {}
local planted: { [number]: { [number]: any } } = {}
local running: { [number]: boolean } = {}
local boards: { [number]: { TextLabel } } = {}
local combo: { [number]: { t: number, n: number } } = {}
local cooldown: { [number]: number } = {}

function PlotService.bind(deps)
        Land = deps.Land
        Net = deps.Net
        World = deps.World
        Drop = deps.Drop
end

local function plotPos(index: number, idx: number): Vector3
        local o = Land.origin(index)
        local x, z = Layout.plotLocal(idx)
        return Vector3.new(o.X + x, 1.4, o.Z + z)
end

local function now(): number
        return Workspace:GetServerTimeNow()
end

local function payloadOf(index: number, idx: number): any
        local rec = planted[index] and planted[index][idx]
        local st = "kosong"
        local crop, readyAt
        if rec then
                crop = rec.crop
                readyAt = rec.readyAt
                st = now() >= rec.readyAt and "siap" or "tumbuh"
        end
        return {
                lahan = index,
                idx = idx,
                st = st,
                crop = crop,
                readyAt = readyAt,
        }
end

local function syncAll(index: number, idx: number)
        Net.get("PlotSync"):FireAllClients(payloadOf(index, idx))
end

local function pasangModel(index: number, idx: number, cropId: string): Model
        local model = PlantModels.buat(plotPos(index, idx), CropData.byId[cropId])
        model.Name = "Tanaman_" .. idx
        model:SetAttribute("PlotIdx", idx)
        model:SetAttribute("LahanIdx", index)
        model.Parent = folders[index]
        return model
end

function PlotService.buildGrid(index: number, parent: Instance?)
        if folders[index] then
                return
        end
        local root = parent or Workspace:FindFirstChild("Dunia")
        if not root then
                return
        end
        local folder = Instance.new("Folder")
        folder.Name = "PlotGrid_" .. index
        local o = Land.origin(index)
        local tmpl = Instance.new("Part")
        tmpl.Anchored = true
        tmpl.Size = Vector3.new(Layout.PlotSize, 0.4, Layout.PlotSize)
        tmpl.Color = Color3.fromRGB(96, 72, 48)
        tmpl.Material = Enum.Material.Ground
        tmpl.TopSurface = Enum.SurfaceType.Smooth
        for idx = 0, Layout.plotCount() - 1 do
                local p = tmpl:Clone()
                local x, z = Layout.plotLocal(idx)
                p.Position = Vector3.new(o.X + x, 1.2, o.Z + z)
                p:SetAttribute("LahanIdx", index)
                p:SetAttribute("PlotIdx", idx)
                p.CanQuery = false
                p.Parent = folder
        end
        tmpl:Destroy()
        folder.Parent = root
        folders[index] = folder
        planted[index] = {}
end

function PlotService.clearGrid(index: number)
        running[index] = false
        planted[index] = nil
        if folders[index] then
                folders[index]:Destroy()
                folders[index] = nil
        end
        if boards[index] then
                boards[index] = nil
        end
end

function PlotService.stateOf(index: number, idx: number): string
        local rec = planted[index] and planted[index][idx]
        if not rec then
                return "kosong"
        end
        if now() >= rec.readyAt then
                return "siap"
        end
        return "tumbuh"
end

function PlotService.filledCount(index: number): number
        local n = 0
        local pl = planted[index]
        if pl then
                for _ in pairs(pl) do
                        n += 1
                end
        end
        return n
end

function PlotService.plotTotal(): number
        return Layout.plotCount()
end

function PlotService.setBoard(index: number, label: any)
        local list = {}
        local ok, isLabel = pcall(function()
                return label ~= nil and label:IsA("TextLabel")
        end)
        if ok and isLabel then
                table.insert(list, label :: TextLabel)
        elseif type(label) == "table" then
                for _, l in ipairs(label) do
                        local ok2, isL = pcall(function()
                                return l ~= nil and l:IsA("TextLabel")
                        end)
                        if ok2 and isL then
                                table.insert(list, l :: TextLabel)
                        end
                end
        end
        boards[index] = list
        PlotService.updateBoard(index)
end

function PlotService.updateBoard(index: number)
        local list = boards[index]
        if not list then
                return
        end
        local teks = "TERTANAM " .. PlotService.filledCount(index) .. "/" .. Layout.plotCount()
        for _, l in ipairs(list) do
                l.Text = teks
        end
end

function PlotService.statusPanen(index: number): { any }
        local daftar = PanenStatus.hitung(planted[index] or {}, now())
        for _, row in ipairs(daftar) do
                local info = CropData.byId[row.id]
                row.nama = info and info.nama or row.id
        end
        return daftar
end

function PlotService.startLoop(index: number)
        if running[index] then
                return
        end
        running[index] = true
        task.spawn(function()
                while running[index] do
                        task.wait(1)
                        local pl = planted[index]
                        if pl then
                                for idx, rec in pairs(pl) do
                                        if not rec.ready and now() >= rec.readyAt then
                                                rec.ready = true
                                                PlantModels.setSiap(rec.model, CropData.byId[rec.crop])
                                                syncAll(index, idx)
                                        end
                                end
                        end
                end
        end)
end

function PlotService.scanTargets(index: number, cropId: string): { number }
        local pl = planted[index]
        if not pl then
                return {}
        end
        local out = {}
        for idx = 0, Layout.plotCount() - 1 do
                if not pl[idx] then
                        table.insert(out, idx)
                end
        end
        return out
end

function PlotService.fillPlot(index: number, idx: number, cropId: string): boolean
        local pl = planted[index]
        if not pl then
                return false
        end
        if type(idx) ~= "number" or idx < 0 or idx >= Layout.plotCount() or not CropData.byId[cropId] then
                return false
        end
        if pl[idx] then
                return false
        end
        pl[idx] = {
                crop = cropId,
                readyAt = now() + CropData.GrowTime,
                model = pasangModel(index, idx, cropId),
                ready = false,
                hits = 0,
                lastHit = 0,
        }
        if World then
                World.touch(index)
        end
        syncAll(index, idx)
        PlotService.updateBoard(index)
        return true
end

local function arahKarakter(player: Player, index: number): (BasePart?, Vector3, Vector3)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return nil, Vector3.zero, Vector3.zero
        end
        local asal = (root.CFrame * CFrame.new(0, 0.8, 0)).Position
        local arah = root.CFrame.LookVector
        return root, asal, arah
end

local function sasaranRaycast(player: Player, index: number): (number?, Vector3?)
        local folder = folders[index]
        if not folder then
                return nil, nil
        end
        local _, asal, arah = arahKarakter(player, index)
        if asal == Vector3.zero then
                return nil, nil
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = { folder }
        local hasil = Workspace:Raycast(asal, arah * ArahPukul.Jangkauan, params)
        if hasil then
                local model = hasil.Instance
                while model and model.Parent and not (model:IsA("Model") and string.sub(model.Name, 1, 8) == "Tanaman_") do
                        model = model.Parent :: Instance
                end
                if model and model:IsA("Model") and model:GetAttribute("PlotIdx") ~= nil then
                        return model:GetAttribute("PlotIdx"), hasil.Position
                end
        end
        return nil, nil
end

local function sasaranKerucut(player: Player, index: number): (number?, Vector3?)
        local pl = planted[index]
        if not pl then
                return nil, nil
        end
        local _, asal, arah = arahKarakter(player, index)
        if asal == Vector3.zero then
                return nil, nil
        end
        local daftar = {}
        for idx in pairs(pl) do
                local pos = plotPos(index, idx)
                local info = CropData.byId[pl[idx].crop]
                local b = info and CropData.Bentuk[info.id]
                local radius = math.min(2.4, ((b and b.t or 2) * 0.5) + 0.8)
                table.insert(daftar, { idx = idx, pos = { x = pos.X, y = 0, z = pos.Z }, radius = radius })
        end
        local asalT = { x = asal.X, y = 0, z = asal.Z }
        local arahT = { x = arah.X, y = 0, z = arah.Z }
        local pilih = ArahPukul.pilih(asalT, arahT, daftar)
        if not pilih then
                return nil, nil
        end
        local rec = planted[index][pilih.idx]
        local info = CropData.byId[rec.crop]
        local b = info and CropData.Bentuk[info.id]
        local tinggi = math.min((b and b.t or 2) * 0.6, 2.4)
        return pilih.idx, plotPos(index, pilih.idx) + Vector3.new(0, tinggi, 0)
end

function PlotService.punch(player: Player, idx: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        local t0 = now()
        local cd = cooldown[player.UserId]
        if cd and t0 - cd < 0.35 then
                return false, "Terlalu cepat."
        end
        cooldown[player.UserId] = t0
        local sasaran, titik = sasaranRaycast(player, index)
        if sasaran == nil then
                sasaran, titik = sasaranKerucut(player, index)
        end
        if sasaran == nil then
                return false, "Tidak ada tanaman di depanmu."
        end
        idx = sasaran
        local rec = planted[index] and planted[index][idx]
        if not rec then
                return false, "Plot kosong."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - plotPos(index, idx)).Magnitude > 18 then
                return false, "Terlalu jauh. Dekati tanaman itu."
        end
        if titik == nil then
                titik = plotPos(index, idx) + Vector3.new(0, 1.2, 0)
        end
        local t = now()
        local c = combo[player.UserId]
        if c and t - c.t <= 4 then
                c.n += 1
                c.t = t
        else
                c = { t = t, n = 1 }
                combo[player.UserId] = c
        end
        local tier = 1
        if c.n >= 8 then
                tier = 3
        elseif c.n >= 4 then
                tier = 2
        end
        local info = CropData.byId[rec.crop]
        if t < rec.readyAt then
                local n, habis = PukulLogic.catat(rec.hits or 0, rec.lastHit or 0, t)
                rec.hits = n
                rec.lastHit = t
                PlantModels.efekKena(rec.model, titik, tier)
                if habis then
                        rec.model:Destroy()
                        planted[index][idx] = nil
                        if World then
                                World.touch(index)
                        end
                        syncAll(index, idx)
                        PlotService.updateBoard(index)
                end
                return true, "Pukulan " .. n .. "/" .. PukulLogic.MaksPukul
        end
        local y = CropData.Yield[info.rarity]
        local jumlah = rng:NextInteger(y.min, y.max)
        if Drop then
                local titikDrop = titik :: Vector3
                if titikDrop.Y < 1.8 then
                        titikDrop = Vector3.new(titikDrop.X, 1.8, titikDrop.Z)
                end
                Drop.spawn(index, titikDrop, rec.crop, jumlah, c.n, tier)
        end
        rec.model:Destroy()
        planted[index][idx] = nil
        if World then
                World.touch(index)
        end
        syncAll(index, idx)
        PlotService.updateBoard(index)
        return true, "Panen " .. jumlah .. " " .. info.nama
end

function PlotService.serialize(index: number): { [number]: any }
        local out = {}
        local pl = planted[index]
        if not pl then
                return out
        end
        for idx, rec in pairs(pl) do
                out[idx] = { crop = rec.crop, readyAt = rec.readyAt, hits = rec.hits, lastHit = rec.lastHit }
        end
        return out
end

function PlotService.restore(index: number, arr: { [number]: any })
        local pl = planted[index]
        if not pl then
                return
        end
        for idx, rec in pairs(arr or {}) do
                if not pl[idx] and CropData.byId[rec.c] then
                        local model = pasangModel(index, idx, rec.c)
                        local ready = now() >= rec.r
                        pl[idx] = {
                                crop = rec.c,
                                readyAt = rec.r,
                                model = model,
                                ready = ready,
                                hits = rec.h or 0,
                                lastHit = rec.l or 0,
                        }
                        if ready then
                                PlantModels.setSiap(model, CropData.byId[rec.c])
                        end
                end
        end
end

return PlotService

end)()

local MOD_ShopService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local StrukBeli = MOD_StrukBeli
local UangLogic = MOD_UangLogic

local ShopService = {}

local Uang, Tas
local rng = Random.new()
local shopPoint: Vector3? = nil

function ShopService.bind(deps)
        Uang = deps.Uang
        Tas = deps.Tas
end

function ShopService.setShopPoint(pos: Vector3)
        shopPoint = pos
end

function ShopService.shopPoint(): Vector3?
        return shopPoint
end

function ShopService.near(player, maxDist: number): boolean
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or not shopPoint then
                return false
        end
        return (root.Position - shopPoint).Magnitude <= maxDist
end

function ShopService.buy(player, packId: any): (boolean, string, { any }?)
        if type(packId) ~= "string" then
                return false, "Permintaan tidak sah."
        end
        local pack = CropData.Packs[packId]
        if not pack then
                return false, "Pack tidak dikenal."
        end
        if not ShopService.near(player, 45) then
                return false, "Dekati kasir Toko Benih dulu."
        end
        if not Uang or Uang.GetMicda(player) < pack.price then
                return false, "Micda tidak cukup."
        end
        local pool = CropData.byRarity(packId)
        local items = {}
        local picks = {}
        for _ = 1, pack.count do
                local pick = pool[rng:NextInteger(1, #pool)]
                table.insert(items, { kind = "benih", id = pick.id, count = 1 })
                table.insert(picks, pick.id)
        end
        if not Tas.canFitBatch(player, items) then
                return false, "Tas penuh! Kosongkan slot dulu."
        end
        local okBayar = Uang.SpendMicda(player, pack.price, "beli_benih")
        if not okBayar then
                return false, "Micda tidak cukup."
        end
        local nama = {}
        for _, it in ipairs(items) do
                Tas.add(player, it.kind, it.id, it.count)
                table.insert(nama, CropData.byId[it.id].nama)
        end
        return true, "Pack " .. packId .. ": " .. table.concat(nama, ", "), StrukBeli.rangkum(picks, CropData.byId)
end

function ShopService.sell(player, cropId: any, count: any): (boolean, string)
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Barang tidak dikenal."
        end
        if not ShopService.near(player, 45) then
                return false, "Dekati kasir Toko Benih dulu."
        end
        local ada = Tas.count(player, "hasil", cropId)
        local n
        if count == nil then
                n = ada
        else
                if type(count) ~= "number" or count ~= count or count % 1 ~= 0 then
                        return false, "Jumlah tidak sah."
                end
                n = math.floor(count)
        end
        if n <= 0 then
                return false, "Jumlah tidak sah."
        end
        if n > ada then
                n = ada
        end
        if n <= 0 then
                return false, "Tidak ada yang bisa dijual."
        end
        local info = CropData.byId[cropId]
        local total = info.jual * n
        local ruang = Uang and Uang.RuangMicda and Uang.RuangMicda(player) or math.huge
        if total > ruang then
                return false, "Ruangan Micda rekeningmu tinggal " .. UangLogic.format(ruang) .. "! Jual dalam bagian lebih kecil."
        end
        local diambil = Tas.remove(player, "hasil", cropId, n)
        if diambil < 1 then
                return false, "Hasil panen tidak bisa diambil dari tas."
        end
        local okUang = Uang and Uang.AddMicda(player, total, "jual_hasil")
        if not okUang then
                Tas.add(player, "hasil", cropId, diambil)
                return false, "Penjualan ditunda sebentar. Barangmu dikembalikan utuh ke tas."
        end
        return true, "Terjual " .. diambil .. " " .. info.nama .. " (+" .. UangLogic.format(total) .. " Micda)."
end

return ShopService

end)()

local MOD_WorldBuilder = (function()
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = MOD_Layout
local BuildingKit = MOD_BuildingKit

local WorldBuilder = {}

local GRASS = Color3.fromRGB(106, 148, 79)
local PATH = Color3.fromRGB(168, 162, 150)
local MARKER_A = Color3.fromRGB(120, 180, 220)
local MARKER_B = Color3.fromRGB(220, 170, 90)
local BUNGA = {
        Color3.fromRGB(232, 96, 84),
        Color3.fromRGB(240, 190, 70),
        Color3.fromRGB(150, 190, 240),
        Color3.fromRGB(226, 120, 200),
        Color3.fromRGB(240, 240, 240),
}

local function groundTop(): number
        return 1
end

local function ensureRoot(): Folder
        local f = Workspace:FindFirstChild("Dunia")
        if not f then
                f = Instance.new("Folder")
                f.Name = "Dunia"
                f.Parent = Workspace
        end
        return f :: Folder
end

local function spawnPad(parent: Instance, pos: Vector3): SpawnLocation
        local spawn = Instance.new("SpawnLocation")
        spawn.Anchored = true
        spawn.Size = Vector3.new(12, 1, 12)
        spawn.Position = pos
        spawn.Color = Color3.fromRGB(235, 200, 110)
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.TopSurface = Enum.SurfaceType.Smooth
        spawn.Duration = 0
        spawn.Enabled = true
        spawn.Parent = parent
        return spawn
end

local function archGate(parent: Instance, x: number, z: number, gt: number, action: string, object: string, onTrigger)
        BuildingKit.part(parent, Vector3.new(2, 10, 2), CFrame.new(x - 12, gt + 5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(2, 10, 2), CFrame.new(x + 12, gt + 5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local beam = BuildingKit.part(parent, Vector3.new(26, 2, 2), CFrame.new(x, gt + 11, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = action
        prompt.ObjectText = object
        prompt.HoldDuration = 0.4
        prompt.MaxActivationDistance = 14
        prompt.RequiresLineOfSight = false
        prompt.Parent = beam
        prompt.Triggered:Connect(function(player)
                onTrigger(player)
        end)
end

local function signBoard(parent: Instance, x: number, z: number, gt: number, text: string)
        BuildingKit.part(parent, Vector3.new(1, 8, 1), CFrame.new(x, gt + 4, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local board = BuildingKit.part(parent, Vector3.new(8, 4, 0.5), CFrame.new(x, gt + 10, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(400, 200)
        local label = Instance.new("TextLabel")
        label.Name = "NamaLahan"
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 240, 200)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = board
        return board
end

local function bedBunga(folder: Instance, x: number, z: number, gt: number, w: number, d: number, bibit: number)
        for _, sx in ipairs({ -1, 1 }) do
                local tepi1 = BuildingKit.part(folder, Vector3.new(w + 0.8, 0.9, 0.5), CFrame.new(x, gt + 0.45, z + sx * d / 2), Color3.fromRGB(168, 160, 148), Enum.Material.Concrete)
                tepi1.CanCollide = false
                local tepi2 = BuildingKit.part(folder, Vector3.new(0.5, 0.9, d + 0.8), CFrame.new(x + sx * w / 2, gt + 0.45, z), Color3.fromRGB(168, 160, 148), Enum.Material.Concrete)
                tepi2.CanCollide = false
        end
        BuildingKit.part(folder, Vector3.new(w, 0.5, d), CFrame.new(x, gt + 0.55, z), Color3.fromRGB(84, 62, 44), Enum.Material.Ground).CanCollide = false
        for i = 0, bibit - 1 do
                local fx = x - w / 2 + (w / bibit) * (i + 0.5)
                local fz = z + (((i % 2) == 0) and -d / 4 or d / 4)
                BuildingKit.part(folder, Vector3.new(0.16, 0.6, 0.16), CFrame.new(fx, gt + 1.05, fz), Color3.fromRGB(74, 128, 60), Enum.Material.Grass).CanCollide = false
                local b = BuildingKit.part(folder, Vector3.new(0.55, 0.55, 0.55), CFrame.new(fx, gt + 1.45, fz), BUNGA[(i + math.floor(x) + math.floor(z)) % #BUNGA + 1], Enum.Material.SmoothPlastic)
                b.Shape = Enum.PartType.Ball
                b.CanCollide = false
        end
end

local function pohonHias(folder: Instance, x: number, z: number, gt: number)
        BuildingKit.part(folder, Vector3.new(1.6, 7, 1.6), CFrame.new(x, gt + 3.5, z), Color3.fromRGB(112, 80, 52), Enum.Material.Wood)
        local a = BuildingKit.part(folder, Vector3.new(6.4, 6.4, 6.4), CFrame.new(x, gt + 8.6, z), Color3.fromRGB(66, 118, 58), Enum.Material.Grass)
        a.Shape = Enum.PartType.Ball
        a.CanCollide = false
        local b = BuildingKit.part(folder, Vector3.new(4.2, 4.2, 4.2), CFrame.new(x + 1.7, gt + 10.4, z + 1.1), Color3.fromRGB(84, 140, 70), Enum.Material.Grass)
        b.Shape = Enum.PartType.Ball
        b.CanCollide = false
        local c = BuildingKit.part(folder, Vector3.new(3.4, 3.4, 3.4), CFrame.new(x - 1.8, gt + 9.9, z - 1.2), Color3.fromRGB(92, 150, 76), Enum.Material.Grass)
        c.Shape = Enum.PartType.Ball
        c.CanCollide = false
end

local function bangkuTaman(folder: Instance, x: number, z: number, gt: number, yaw: number)
        local cf = CFrame.new(x, gt, z) * CFrame.Angles(0, yaw, 0)
        BuildingKit.part(folder, Vector3.new(4.4, 0.4, 1.6), cf * CFrame.new(0, 1.5, 0), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(folder, Vector3.new(4.4, 1.5, 0.3), cf * CFrame.new(0, 2.4, -0.65), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(folder, Vector3.new(0.4, 1.5, 1.4), cf * CFrame.new(-1.8, 0.75, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(0.4, 1.5, 1.4), cf * CFrame.new(1.8, 0.75, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
end

local function tiangBendera(folder: Instance, x: number, z: number, gt: number, arah: number, warnaBendera: Color3)
        BuildingKit.part(folder, Vector3.new(0.4, 9, 0.4), CFrame.new(x, gt + 4.5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(2.2, 1.1, 0.14), CFrame.new(x + arah * 1.3, gt + 8.2, z), warnaBendera, Enum.Material.SmoothPlastic).CanCollide = false
        BuildingKit.part(folder, Vector3.new(1.2, 0.7, 0.14), CFrame.new(x + arah * 1.75, gt + 7.2, z), warnaBendera, Enum.Material.SmoothPlastic).CanCollide = false
end

local function lampuTaman(folder: Instance, x: number, z: number, gt: number)
        BuildingKit.part(folder, Vector3.new(0.5, 3.2, 0.5), CFrame.new(x, gt + 1.6, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local kepala = BuildingKit.part(folder, Vector3.new(0.8, 0.8, 0.8), CFrame.new(x, gt + 3.6, z), Color3.fromRGB(255, 224, 178), Enum.Material.Neon)
        kepala.Shape = Enum.PartType.Ball
        kepala.CanCollide = false
        local cahaya = Instance.new("PointLight")
        cahaya.Range = 12
        cahaya.Brightness = 0.45
        cahaya.Color = Color3.fromRGB(255, 224, 178)
        cahaya.Parent = kepala
end

local function lindung(folder: Instance, x: number, z: number, gt: number, panjang: number, yaw: number)
        local cf = CFrame.new(x, gt, z) * CFrame.Angles(0, yaw, 0)
        BuildingKit.part(folder, Vector3.new(panjang, 2.2, 1.6), cf * CFrame.new(0, 1.5, 0), Color3.fromRGB(74, 122, 62), Enum.Material.Grass).CanCollide = false
        BuildingKit.part(folder, Vector3.new(panjang, 0.5, 1.7), cf * CFrame.new(0, 2.75, 0), Color3.fromRGB(88, 140, 72), Enum.Material.Grass).CanCollide = false
end

local function gerbangRambate(folder: Instance, x: number, z: number, gt: number)
        BuildingKit.part(folder, Vector3.new(0.8, 8, 0.8), CFrame.new(x - 6.5, gt + 4, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(0.8, 8, 0.8), CFrame.new(x + 6.5, gt + 4, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(14.5, 0.8, 1.2), CFrame.new(x, gt + 8.2, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        for i = -1, 1 do
                local bx = x + i * 4.2
                BuildingKit.part(folder, Vector3.new(0.12, 1.4, 0.12), CFrame.new(bx, gt + 7.1, z), BuildingKit.DARKWOOD, Enum.Material.Wood).CanCollide = false
                local pot = BuildingKit.part(folder, Vector3.new(1.2, 1, 1.2), CFrame.new(bx, gt + 5.9, z), Color3.fromRGB(172, 96, 66), Enum.Material.SmoothPlastic)
                pot.CanCollide = false
                local bunga = BuildingKit.part(folder, Vector3.new(0.9, 0.9, 0.9), CFrame.new(bx, gt + 6.65, z), BUNGA[i + 2], Enum.Material.SmoothPlastic)
                bunga.Shape = Enum.PartType.Ball
                bunga.CanCollide = false
        end
end

local function buildPapan(folder: Instance, x: number, z: number, gt: number, index: number, hooks)
        local pad = BuildingKit.part(folder, Vector3.new(14, 0.2, 3), CFrame.new(x, gt + 0.12, z - 2.5), Color3.fromRGB(235, 200, 110), Enum.Material.SmoothPlastic, 0.25)
        pad.CanCollide = false
        for sx = -1, 1, 2 do
                BuildingKit.part(folder, Vector3.new(1, 9, 1), CFrame.new(x + sx * 6, gt + 4.5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        end
        local panel = BuildingKit.part(folder, Vector3.new(14, 5, 0.8), CFrame.new(x, gt + 9.5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local labels = {}
        for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
                local gui = Instance.new("SurfaceGui")
                gui.Face = face
                gui.CanvasSize = Vector2.new(560, 200)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, -16, 0.86, 0)
                l.Position = UDim2.new(0, 8, 0.07, 0)
                l.BackgroundTransparency = 1
                l.Text = "TERTANAM 0/500"
                l.TextColor3 = Color3.fromRGB(255, 226, 140)
                l.TextScaled = true
                l.Font = Enum.Font.GothamBlack
                l.Parent = gui
                gui.Parent = panel
                table.insert(labels, l)
        end
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Mulai Tanam"
        prompt.ObjectText = "Papan Tanam"
        prompt.HoldDuration = 0.3
        prompt.MaxActivationDistance = 13
        prompt.RequiresLineOfSight = false
        prompt.Parent = panel
        prompt.Triggered:Connect(function(player: Player)
                if hooks and hooks.onPapanPrompt then
                        hooks.onPapanPrompt(player, index)
                end
        end)
        return labels
end

local function buildGudang(folder: Instance, x: number, z: number, gt: number, index: number, hooks)
        local w, d = 22, 18
        local h = 12
        local model = Instance.new("Model")
        model.Name = "GudangPanen_" .. index
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), BuildingKit.STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 2, 1, d - 2), CFrame.new(0, 1.5, 0), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(w, h, 1), CFrame.new(0, h / 2 + 1, d / 2 - 0.5), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(1, h, d - 2), CFrame.new(-(w / 2 - 0.5), h / 2 + 1, 0), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(1, h, d - 2), CFrame.new(w / 2 - 0.5, h / 2 + 1, 0), BuildingKit.CREAM)
        local fz = -(d / 2 - 0.5)
        BuildingKit.part(model, Vector3.new(6, h, 1), CFrame.new(-(w / 2 - 3.5), h / 2 + 1, fz), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(6, h, 1), CFrame.new(w / 2 - 3.5, h / 2 + 1, fz), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(10, 4, 1), CFrame.new(0, h - 1, fz), BuildingKit.CREAM)
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(2, h, 2), CFrame.new(sx * (w / 2 - 1), h / 2 + 1, sx * (d / 2 - 1)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        end
        for _, yy in ipairs({ 1.5, h + 0.5 }) do
                BuildingKit.part(model, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, yy, -(d / 2 + 0.75)), BuildingKit.DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, yy, d / 2 + 0.75), BuildingKit.DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(0.5, 1, d + 2), CFrame.new(-(w / 2 + 0.75), yy, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(0.5, 1, d + 2), CFrame.new(w / 2 + 0.75, yy, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
        end
        BuildingKit.gableRoof(model, w, d, 3, h + 1, BuildingKit.BRICKRED)
        local counter = BuildingKit.part(model, Vector3.new(10, 4, 2), CFrame.new(0, 4, -(d / 2 - 5)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        counter:SetAttribute("MejaGudang", true)
        for sx = -1, 1, 2 do
                local rack = BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(sx * (w / 2 - 4), 6, 2), BuildingKit.DARKWOOD, Enum.Material.Wood)
                rack:SetAttribute("GudangRak", true)
                BuildingKit.part(model, Vector3.new(5.6, 0.3, 7), CFrame.new(sx * (w / 2 - 4), 4.2, 2), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                BuildingKit.part(model, Vector3.new(5.6, 0.3, 7), CFrame.new(sx * (w / 2 - 4), 7, 2), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                for i = 0, 3 do
                        BuildingKit.part(model, Vector3.new(1.8, 1.5, 1.8), CFrame.new(sx * (w / 2 - 4) - 1.2 + i * 0.9, 5.05, 0.8 + (i % 2)), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
                        BuildingKit.part(model, Vector3.new(1.6, 1.3, 1.6), CFrame.new(sx * (w / 2 - 4) - 1 + i * 0.85, 7.8, 1.4 + (i % 2)), Color3.fromRGB(196, 168, 120), Enum.Material.WoodPlanks)
                end
                BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(sx * (w / 2 - 4), 9.6, 2), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        end
        BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(3.6, 3.1, -4.5), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(5.9, 3.1, -4.2), Color3.fromRGB(170, 132, 84), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.2, 1.8, 2.2), CFrame.new(4.7, 5.3, -4.4), Color3.fromRGB(196, 168, 120), Enum.Material.WoodPlanks)
        local sackRow = { Color3.fromRGB(150, 108, 62), Color3.fromRGB(96, 128, 72), Color3.fromRGB(196, 168, 120) }
        for i = 0, 2 do
                BuildingKit.part(model, Vector3.new(2.2, 2.4, 1.6), CFrame.new(-4.2 - i * 2.4, 3.2, -4.6), sackRow[i + 1], Enum.Material.Fabric)
        end
        BuildingKit.part(model, Vector3.new(2.4, 3.2, 2.4), CFrame.new(-w / 2 + 3.2, 2.6, -d / 2 + 2.6), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.5, 0.3, 2.5), CFrame.new(-w / 2 + 3.2, 4.3, -d / 2 + 2.6), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        local papan = BuildingKit.part(model, Vector3.new(14, 3, 0.5), CFrame.new(0, h + 3, -(d / 2 + 0.4)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local guiPapan = Instance.new("SurfaceGui")
        guiPapan.Face = Enum.NormalId.Front
        guiPapan.CanvasSize = Vector2.new(400, 90)
        local labelPapan = Instance.new("TextLabel")
        labelPapan.Size = UDim2.fromScale(1, 1)
        labelPapan.BackgroundTransparency = 1
        labelPapan.Text = "GUDANG HASIL PANEN"
        labelPapan.TextColor3 = Color3.fromRGB(255, 232, 180)
        labelPapan.TextScaled = true
        labelPapan.Font = Enum.Font.GothamBold
        labelPapan.Parent = guiPapan
        guiPapan.Parent = papan
        BuildingKit.lamp(model, 0, h + 1, 0)
        BuildingKit.lamp(model, -6, h + 1, 4)
        BuildingKit.lamp(model, 6, h + 1, 4)
        model.WorldPivot = CFrame.new(0, 0, 0)
        model:PivotTo(CFrame.new(x, gt, z))
        model.Parent = folder
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka Gudang"
        prompt.ObjectText = "Meja Gudang"
        prompt.HoldDuration = 0.3
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = counter
        prompt.Triggered:Connect(function(player: Player)
                if hooks and hooks.onGudangPrompt then
                        hooks.onGudangPrompt(player, index)
                end
        end)
        if hooks and hooks.setGudangPoint then
                hooks.setGudangPoint(index, (model:GetPivot() * CFrame.new(0, 0, -(d / 2 - 5))).Position + Vector3.new(0, 3, 0))
        end
        return model
end

function WorldBuilder.buildHub(hooks)
        local root = ensureRoot()
        local gt = 0

        BuildingKit.part(root, Vector3.new(400, 1, 400), CFrame.new(0, -0.5, 0), GRASS, Enum.Material.Grass)
        BuildingKit.part(root, Vector3.new(10, 0.2, 90), CFrame.new(0, gt + 0.1, 10), PATH, Enum.Material.Concrete)

        local spawn = spawnPad(root, Vector3.new(0, gt + 0.5, 44))
        if hooks and hooks.registerKota then
                hooks.registerKota(spawn)
        end
        if hooks and hooks.registerUmum then
                hooks.registerUmum(spawn)
        end

        archGate(root, 0, 20, gt, "Dunia-ku", "Gerbang Dunia", function(player: Player)
                if hooks and hooks.onGerbangDunia then
                        hooks.onGerbangDunia(player)
                end
        end)

        signBoard(root, -30, 6, gt, "PUSAT KOTA")

        local toko = BuildingKit.buildToko(root)
        toko:PivotTo(CFrame.new(0, gt, -60) * CFrame.Angles(0, math.rad(180), 0))
        for _, p in ipairs(toko:GetDescendants()) do
                if p:IsA("BasePart") and p.Size == Vector3.new(12, 4, 3) then
                        if hooks and hooks.setShopPoint then
                                hooks.setShopPoint(p.Position)
                        end
                        if hooks and hooks.onShopPrompt then
                                local prompt = Instance.new("ProximityPrompt")
                                prompt.ActionText = "Toko Benih"
                                prompt.ObjectText = "Kasir"
                                prompt.HoldDuration = 0.3
                                prompt.MaxActivationDistance = 12
                                prompt.RequiresLineOfSight = false
                                prompt.Parent = p
                                prompt.Triggered:Connect(function(player: Player)
                                        hooks.onShopPrompt(player)
                                end)
                        end
                elseif p:IsA("BasePart") and p:GetAttribute("Rak") == true then
                        if hooks and hooks.onShopPrompt then
                                local prompt = Instance.new("ProximityPrompt")
                                prompt.ActionText = "Beli Benih"
                                prompt.ObjectText = "Rak Benih"
                                prompt.HoldDuration = 0.3
                                prompt.MaxActivationDistance = 10
                                prompt.RequiresLineOfSight = false
                                prompt.Parent = p
                                prompt.Triggered:Connect(function(player: Player)
                                        hooks.onShopPrompt(player)
                                end)
                        end
                end
        end

        BuildingKit.streetLamp(root, 8, gt, 32)
        BuildingKit.streetLamp(root, -8, gt, 32)
        BuildingKit.streetLamp(root, 8, gt, -30)
        BuildingKit.streetLamp(root, -8, gt, -30)

        for _, sx in ipairs({ -1, 1 }) do
                lindung(root, sx * 7.4, 48, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, 44, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, 20, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, 16, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -6, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -10, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -26, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -35, gt, 5, math.pi / 2)
        end
        bedBunga(root, -8, 40, gt, 5, 2.4, 4)
        bedBunga(root, 8, 24, gt, 5, 2.4, 4)
        bedBunga(root, -8, 12, gt, 5, 2.4, 5)
        bedBunga(root, 8, 0, gt, 5, 2.4, 4)
        bedBunga(root, -8, -14, gt, 5, 2.4, 5)
        bedBunga(root, 8, -24, gt, 5, 2.4, 4)
        pohonHias(root, -13, 36, gt)
        pohonHias(root, 13, 36, gt)
        pohonHias(root, -13, -12, gt)
        pohonHias(root, 13, -12, gt)
        bangkuTaman(root, -7.5, -40, gt, math.pi / 2)
        bangkuTaman(root, 7.5, -40, gt, -math.pi / 2)
        tiangBendera(root, -5.5, -43, gt, -1, MARKER_A)
        tiangBendera(root, 5.5, -43, gt, 1, MARKER_B)
        lampuTaman(root, -9.5, 46, gt)
        lampuTaman(root, 9.5, 46, gt)
        lampuTaman(root, -9.5, -20, gt)
        lampuTaman(root, 9.5, -20, gt)
        gerbangRambate(root, 0, -38, gt)

        return root
end

function WorldBuilder.buildLahan(hooks, index: number, namaPemilik: string): Model
        local root = ensureRoot()
        local model = Instance.new("Model")
        model.Name = "Zona_" .. index
        local folder = Instance.new("Folder")
        folder.Name = "Isi_" .. index
        folder.Parent = model
        local ox, oz = Layout.cellOrigin(index)
        local dX = Layout.duniaOffsetX()
        local gt = groundTop()

        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 1, Layout.SizeZ), CFrame.new(dX + ox + Layout.SizeX / 2, gt - 0.5, oz + Layout.SizeZ / 2), GRASS, Enum.Material.Grass)

        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 0.2, 10), CFrame.new(dX + ox + Layout.SizeX / 2, gt + 0.1, oz + 25), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 0.2, 10), CFrame.new(dX + ox + Layout.SizeX / 2, gt + 0.1, oz + 155), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 120), CFrame.new(dX + ox + 165, gt + 0.1, oz + 90), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 20), CFrame.new(dX + ox + 120, gt + 0.1, oz + 10), PATH, Enum.Material.Concrete)

        BuildingKit.fenceLine(folder, dX + ox, oz, dX + ox, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, dX + ox + Layout.SizeX, oz, dX + ox + Layout.SizeX, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, dX + ox, oz + Layout.SizeZ, dX + ox + Layout.SizeX, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, dX + ox, oz, dX + ox + 108, oz, gt)
        BuildingKit.fenceLine(folder, dX + ox + 132, oz, dX + ox + Layout.SizeX, oz, gt)

        archGate(folder, dX + ox + 120, oz, gt, "Pulang ke Kota", "Gerbang Dunia", function(player: Player)
                if hooks and hooks.onPulang then
                        hooks.onPulang(player)
                end
        end)

        signBoard(folder, dX + ox + 96, oz + 8, gt, "Dunia " .. (namaPemilik or "Petani"))

        BuildingKit.streetLamp(folder, dX + ox + 104, gt, oz + 24)
        BuildingKit.streetLamp(folder, dX + ox + 166, gt, oz + 156)
        BuildingKit.streetLamp(folder, dX + ox + 40, gt, oz + 210)

        local mesin = BuildingKit.buildMesinSemai(folder, index, hooks)
        mesin:PivotTo(CFrame.new(dX + ox + 185, gt, oz + 50))
        if hooks and hooks.registerMesin then
                hooks.registerMesin(index, mesin)
        end

        BuildingKit.marker(folder, dX + ox + 185, oz + 85, gt, 30, 30, MARKER_A)
        BuildingKit.marker(folder, dX + ox + 195, oz + 125, gt, 50, 30, MARKER_A)
        BuildingKit.marker(folder, dX + ox + 40, oz + 185, gt, 40, 40, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 82, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 112, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 142, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 172, oz + 177, gt, 24, 24, MARKER_B)

        local labelPapan = buildPapan(folder, dX + ox + 85, oz + 18, gt, index, hooks)
        if hooks and hooks.registerBoard then
                hooks.registerBoard(index, labelPapan, Vector3.new(dX + ox + 85, gt + 6, oz + 18))
        end
        buildGudang(folder, dX + ox + 205, oz + 185, gt, index, hooks)

        model.Parent = root
        return model
end

return WorldBuilder

end)()

local MOD_ZonaService = (function()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DuniaLogic = MOD_DuniaLogic
local WorldBuilder = MOD_WorldBuilder

local ZonaService = {}

local Land, Plot, Mesin, Data, Notify, Hooks, Gudang, Drop
local store = DataStoreService:GetDataStore("AKM_Dunia")

type Seksi = {
        idx: number,
        ownerId: number,
        ownerName: string,
        ghost: boolean,
        savedOk: boolean,
        canSave: boolean,
        dirty: boolean,
        model: Model,
        lastSeen: number,
}

local seksi: { [number]: Seksi } = {}
local byOwner: { [number]: number } = {}
local zoneOf: { [number]: { zone: string, dunia: string? } } = {}

function ZonaService.bind(deps)
        Land = deps.Land
        Plot = deps.Plot
        Mesin = deps.Mesin
        Data = deps.Data
        Notify = deps.Notify
        Gudang = deps.Gudang
        Drop = deps.Drop
end

function ZonaService.setHooks(hooks)
        Hooks = hooks
end

local function taken(idx: number): boolean
        return seksi[idx] ~= nil
end

local function ownerSection(userId: number): Seksi?
        for _, s in pairs(seksi) do
                if s.ownerId == userId then
                        return s
                end
        end
        return nil
end

local function arrivalPos(idx: number): Vector3
        local o = Land.origin(idx)
        return Vector3.new(o.X + 120, 4, o.Z + 12)
end

local function kotaPos(): Vector3
        local sp = Land.kotaSpawn() or Land.umumSpawn()
        return sp and (sp.Position + Vector3.new(0, 3, 0)) or Vector3.new(0, 6, 44)
end

local function watchVoid(player: Player, homePos: Vector3)
        task.spawn(function()
                for _ = 1, 60 do
                        task.wait(0.25)
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        if not root then
                                return
                        end
                        if root.Position.Y < -20 then
                                root.Anchored = false
                                root.CFrame = CFrame.new(homePos + Vector3.new(0, 4, 0))
                        end
                end
        end)
end

local function placeAt(player: Player, pos: Vector3, zone: string, dunia: string?): boolean
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return false
        end
        zoneOf[player.UserId] = { zone = zone, dunia = dunia }
        root.Anchored = true
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.spawn(function()
                pcall(function()
                        Workspace:RequestStreamAroundAsync(pos, 4)
                end)
                task.delay(0.8, function()
                        if root.Parent then
                                root.Anchored = false
                        end
                end)
        end)
        task.delay(8, function()
                if root.Parent and root.Anchored then
                        root.Anchored = false
                end
        end)
        watchVoid(player, pos)
        Data.push(player)
        return true
end

local function placeWait(player: Player, pos: Vector3, zone: string, dunia: string?): boolean
        for _ = 1, 12 do
                if placeAt(player, pos, zone, dunia) then
                        return true
                end
                task.wait(0.5)
        end
        return false
end

function ZonaService.zoneOf(player: Player): (string, string?)
        local z = zoneOf[player.UserId]
        if z then
                return z.zone, z.dunia
        end
        return "kota", nil
end

function ZonaService.touch(index: number)
        local s = seksi[index]
        if s and s.canSave then
                s.dirty = true
        end
end

local function payloadOf(s: Seksi, leaving: boolean?)
        local p = {
                n = s.ownerName,
                pl = DuniaLogic.serPlots(Plot.serialize(s.idx)),
                mj = DuniaLogic.serMesin(Mesin.serializeLahan(s.idx)),
                gd = Gudang and Gudang.serLahan(s.idx) or {},
                dr = Drop and DuniaLogic.serDrops(Drop.serLahan(s.idx)) or {},
                t = os.time(),
        }
        if leaving then
                p.lt = os.time()
        end
        return p
end

local function simpanSekali(s: Seksi, leaving: boolean?): boolean
        local hasil = false
        local ok = pcall(function()
                store:UpdateAsync(DuniaLogic.keyFor(s.ownerId), function()
                        hasil = true
                        return payloadOf(s, leaving)
                end)
        end)
        return ok and hasil
end

local function saveSeksi(s: Seksi, force: boolean, leaving: boolean?)
        if s.ghost or not s.canSave or (not s.dirty and not force) then
                return
        end
        for i = 1, 3 do
                if simpanSekali(s, leaving) then
                        s.dirty = false
                        return
                end
                task.wait(0.4 * i)
        end
end

local function loadWorld(ownerId: number): (boolean, string?, any, any, any, any, any)
        local ok, data = pcall(function()
                return store:GetAsync(DuniaLogic.keyFor(ownerId))
        end)
        if not ok then
                return false, nil, {}, {}, nil, {}, nil
        end
        if type(data) ~= "table" then
                return true, nil, {}, {}, nil, {}, nil
        end
        return true, DuniaLogic.cleanName(data.n), DuniaLogic.desPlots(data.pl), DuniaLogic.desMesin(data.mj), data.gd, data.dr, data.lt
end

local function buildSection(idx: number, ownerId: number, nama: string, ghost: boolean, savedOk: boolean, plots: any, meja: any, gd: any, dr: any, lt: any): Seksi
        local model = WorldBuilder.buildLahan(Hooks, idx, nama)
        Plot.buildGrid(idx, model)
        Plot.restore(idx, plots)
        Plot.startLoop(idx)
        Mesin.restoreLahan(idx, meja, ownerId)
        if Gudang then
                Gudang.restoreLahan(idx, gd)
        end
        if Drop then
                Drop.restoreLahan(idx, dr, lt)
        end
        local s: Seksi = {
                idx = idx,
                ownerId = ownerId,
                ownerName = nama,
                ghost = ghost,
                savedOk = savedOk,
                canSave = savedOk and not ghost,
                dirty = false,
                model = model,
                lastSeen = os.clock(),
        }
        seksi[idx] = s
        return s
end

local function destroySection(idx: number)
        local s = seksi[idx]
        if not s then
                return
        end
        Plot.clearGrid(idx)
        Mesin.clearLahan(idx)
        if Drop then
                Drop.clearLahan(idx)
        end
        if Gudang then
                Gudang.clearLahan(idx)
        end
        s.model:Destroy()
        seksi[idx] = nil
        if byOwner[s.ownerId] == idx then
                byOwner[s.ownerId] = nil
        end
        Land.free(idx, s.ownerId)
end

function ZonaService.masuk(player: Player): (boolean, string)
        local s = ownerSection(player.UserId)
        if s and not s.ghost then
                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                        return true, "Kamu kembali ke duniamu."
                end
                return false, "Karakter belum siap. Coba lagi sebentar."
        end
        if s and s.ghost then
                s.ghost = false
                s.canSave = s.savedOk
                s.dirty = false
                byOwner[player.UserId] = s.idx
                Land.claim(s.idx, player.UserId)
                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                        return true, "Kamu kembali ke duniamu."
                end
                return false, "Karakter belum siap. Coba lagi sebentar."
        end
        local loadOk, namaTersimpan, plots, meja, gd, dr, lt = loadWorld(player.UserId)
        local nama = namaTersimpan or player.Name
        local idx = Land.claimFree(player.UserId, taken)
        if idx <= 0 then
                return false, "Semua petak dunia di server ini sedang terpakai. Coba lagi sebentar."
        end
        buildSection(idx, player.UserId, nama, false, loadOk, plots, meja, gd, dr, lt)
        byOwner[player.UserId] = idx
        if placeWait(player, arrivalPos(idx), "dunia", nama) then
                return true, "Duniamu siap. Masuk dan pulang kini tanpa loading."
        end
        return false, "Karakter belum siap. Duniamu sudah dibuat, coba masuk lagi."
end

function ZonaService.visit(player: Player, namaRaw: any): (boolean, string)
        local nama = DuniaLogic.cleanName(namaRaw)
        if not nama then
                return false, "Nama pemain tidak sah."
        end
        if nama == player.Name then
                return ZonaService.masuk(player)
        end
        for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == nama then
                        local s = ownerSection(p.UserId)
                        if s then
                                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                                        Notify(p, "Tamu Datang", player.Name .. " sedang berkunjung ke duniamu.")
                                        return true, "Kamu berkunjung ke dunia " .. s.ownerName .. ". Semua aksi perubahan terkunci."
                                end
                                return false, "Karakter belum siap. Coba lagi sebentar."
                        end
                        break
                end
        end
        local okId, targetId = pcall(function()
                return Players:GetUserIdFromNameAsync(nama)
        end)
        if not okId or type(targetId) ~= "number" or targetId <= 0 then
                return false, "Nama pemain tidak ditemukan."
        end
        local s = ownerSection(targetId)
        if s then
                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                        return true, "Kamu berkunjung ke dunia " .. s.ownerName .. "."
                end
                return false, "Karakter belum siap. Coba lagi sebentar."
        end
        local loadOk, namaTersimpan, plots, meja, gd, dr, lt = loadWorld(targetId)
        if not loadOk then
                return false, "Dunia " .. nama .. " tidak bisa dikunjungi sekarang."
        end
        if next(plots) == nil and next(meja) == nil and not namaTersimpan then
                return false, nama .. " belum punya dunia."
        end
        local idx = Land.firstFree(taken)
        if idx <= 0 then
                return false, "Semua petak dunia di server ini sedang terpakai."
        end
        if not Land.reserve(idx, targetId) then
                return false, "Petak dunia habis. Coba lagi sebentar."
        end
        local namaDunia = namaTersimpan or nama
        buildSection(idx, targetId, namaDunia, true, loadOk, plots, meja, gd, dr, lt)
        if placeWait(player, arrivalPos(idx), "dunia", namaDunia) then
                return true, "Kamu berkunjung ke dunia " .. namaDunia .. " (salinan tersimpan)."
        end
        return false, "Karakter belum siap. Coba lagi sebentar."
end

function ZonaService.pulang(player: Player): (boolean, string)
        if placeWait(player, kotaPos(), "kota", nil) then
                return true, "Kembali ke Pusat Kota."
        end
        return false, "Karakter belum siap. Coba lagi sebentar."
end

function ZonaService.mutationDeny(player: Player): string?
        if Land.landOf(player) then
                return nil
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
                for _, s in pairs(seksi) do
                        if Land.isInside(s.idx, root.Position, 8) then
                                return "Dunia ini milik " .. s.ownerName .. ". Kamu sedang berkunjung."
                        end
                end
        end
        return nil
end

local function insideCount(s: Seksi): number
        local n = 0
        for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root and Land.isInside(s.idx, root.Position, 30) then
                        n += 1
                end
        end
        return n
end

function ZonaService.leaveGame(player: Player)
        zoneOf[player.UserId] = nil
        local idx = byOwner[player.UserId]
        if not idx then
                return
        end
        local s = seksi[idx]
        if s then
                saveSeksi(s, true, true)
        end
        destroySection(idx)
end

function ZonaService.startLoops()
        task.spawn(function()
                local t = 0
                while true do
                        task.wait(20)
                        t += 20
                        for _, s in pairs(seksi) do
                                if s.ghost then
                                        if insideCount(s) > 0 then
                                                s.lastSeen = os.clock()
                                        elseif os.clock() - s.lastSeen > 120 then
                                                destroySection(s.idx)
                                        end
                                end
                        end
                        if t >= DuniaLogic.SaveEvery then
                                t = 0
                                for _, s in pairs(seksi) do
                                        if not s.ghost then
                                                saveSeksi(s, false)
                                        end
                                end
                        end
                end
        end)
end

function ZonaService.shutdown()
        for _, s in pairs(seksi) do
                if not s.ghost then
                        saveSeksi(s, true)
                end
        end
end

return ZonaService

end)()

local MOD_TanamService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local Recipes = MOD_Recipes
local SoalLogic = MOD_SoalLogic

local TanamService = {}

local Land, Plot, Tas, Net, World
local rng = Random.new()

local points: { [number]: Vector3 } = {}
local sesi: { [number]: any } = {}

function TanamService.bind(deps)
        Land = deps.Land
        Plot = deps.Plot
        Tas = deps.Tas
        Net = deps.Net
        World = deps.World
end

function TanamService.setPoint(index: number, pos: Vector3)
        points[index] = pos
end

local function near(player, index: number): boolean
        local p = points[index]
        if not p then
                return false
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return false
        end
        return (root.Position - p).Magnitude <= 30
end

local function payload(s: any, selesai: boolean?, tuntas: any?): any
        local p: any = {
                aktif = s ~= nil,
                crop = s and s.cropId or nil,
                nama = s and s.nama or nil,
                jumlah = s and s.jumlah or 0,
                tertanam = s and s.tertanam or 0,
                totalSoal = s and math.ceil(s.jumlah / 10) or 0,
                selesai = selesai == true,
        }
        if tuntas then
                p.selesaiTuntas = true
                p.selesaiNama = tuntas.nama
                p.selesaiHasil = tuntas.total
        end
        if s and s.tertanam < s.jumlah and s.soal then
                p.soal = { teks = s.soal.teks, nomor = math.floor(s.tertanam / 10) + 1 }
        end
        return p
end

local function sync(player, s: any, selesai: boolean?, tuntas: any?)
        Net.get("TanamSync"):FireClient(player, payload(s, selesai, tuntas))
end

function TanamService.syncTo(player)
        sync(player, sesi[player.UserId])
end

function TanamService.start(player, cropId: any, jumlahRaw: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if sesi[player.UserId] then
                return false, "Sesi tanam masih berjalan. Jawab soalnya atau batalkan dulu."
        end
        if not near(player, index) then
                return false, "Dekati Papan Tanam dulu."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Benih tidak dikenal."
        end
        local seeds = Tas.count(player, "benih", cropId)
        if seeds < 1 then
                return false, "Benih itu tidak ada di tas."
        end
        local targets = Plot.scanTargets(index, cropId)
        if #targets < 1 then
                return false, "Tidak ada plot kosong yang bisa ditanam."
        end
        local jumlah = math.floor(tonumber(jumlahRaw) or 0)
        if jumlah < 1 then
                jumlah = seeds
        end
        jumlah = math.min(jumlah, #targets, seeds)
        if jumlah < 1 then
                return false, "Jumlah tanam tidak sah."
        end
        local info = CropData.byId[cropId]
        local s = {
                index = index,
                cropId = cropId,
                nama = info.nama,
                jumlah = jumlah,
                tertanam = 0,
                used = {},
        }
        s.soal = SoalLogic.buat(rng, 1, s.used)
        sesi[player.UserId] = s
        Plot.updateBoard(index)
        sync(player, s)
        return true, "Mulai tanam " .. info.nama
end

function TanamService.jawab(player, ans: any): (boolean, string)
        local s = sesi[player.UserId]
        if not s then
                return false, "Tidak ada sesi tanam berjalan."
        end
        if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true, { nama = s.nama, total = s.tertanam })
                return true, "+" .. s.tertanam .. " " .. s.nama
        end
        local n = tonumber(ans)
        if type(n) ~= "number" or n ~= n then
                sync(player, s)
                return false, "Masukkan angka dulu."
        end
        if n ~= s.soal.jawab then
                sync(player, s)
                return false, "salah"
        end
        local seeds = Tas.count(player, "benih", s.cropId)
        local batch = math.min(10, s.jumlah - s.tertanam, seeds)
        if batch <= 0 then
                sesi[player.UserId] = nil
                sync(player, s, true)
                return true, "Benih habis"
        end
        local targets = Plot.scanTargets(s.index, s.cropId)
        local tanam = 0
        for i = 1, math.min(batch, #targets) do
                local idx = targets[i]
                if Tas.count(player, "benih", s.cropId) < 1 then
                        break
                end
                if Plot.fillPlot(s.index, idx, s.cropId) then
                        Tas.remove(player, "benih", s.cropId, 1)
                        tanam += 1
                end
        end
        s.tertanam += tanam
        if World then
                World.touch(s.index)
        end
        Plot.updateBoard(s.index)
        if tanam == 0 then
                sesi[player.UserId] = nil
                sync(player, s, true)
                return true, "Plot tidak tersedia"
        end
        if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true, { nama = s.nama, total = s.tertanam })
                return true, "+" .. s.tertanam .. " " .. s.nama
        end
        s.soal = SoalLogic.buat(rng, math.floor(s.tertanam / 10) + 1, s.used)
        sync(player, s)
        return true, "+" .. tanam .. " " .. s.nama
end

function TanamService.batal(player): (boolean, string)
        if not sesi[player.UserId] then
                return false, "Tidak ada sesi tanam."
        end
        sesi[player.UserId] = nil
        sync(player, nil, true)
        return true, "Tanam dibatalkan"
end

function TanamService.gabung(player, a: any, b: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if not near(player, index) then
                return false, "Dekati Papan Tanam dulu."
        end
        if type(a) ~= "string" or type(b) ~= "string" or not CropData.byId[a] or not CropData.byId[b] then
                return false, "Tidak bisa di-combine"
        end
        if a == b then
                return false, "Tidak bisa di-combine"
        end
        local hasil = Recipes.find(a, b)
        if not hasil then
                return false, "Tidak bisa di-combine"
        end
        if Tas.count(player, "benih", a) < 1 or Tas.count(player, "benih", b) < 1 then
                return false, "Benih tidak cukup di tas."
        end
        if Tas.roomFor(player, "benih", hasil, 1) < 1 then
                return false, "Tas penuh. Kosongkan satu slot dulu."
        end
        Tas.remove(player, "benih", a, 1)
        Tas.remove(player, "benih", b, 1)
        Tas.add(player, "benih", hasil, 1)
        return true, "Combine berhasil: benih " .. CropData.byId[hasil].nama .. " masuk tas."
end

function TanamService.statusPayload(player)
        local p = payload(sesi[player.UserId])
        local index = Land.landOf(player)
        p.status = index and Plot.statusPanen(index) or {}
        p.tertanamTotal = index and Plot.filledCount(index) or 0
        p.plotTotal = Plot.plotTotal()
        return p
end

function TanamService.leave(player)
        sesi[player.UserId] = nil
end

return TanamService

end)()

local MOD_GudangService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local GudangLogic = MOD_GudangLogic

local GudangService = {}

local Land, Tas, Net, World
local points: { [number]: Vector3 } = {}
local gudang: { [number]: any } = {}

function GudangService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Net = deps.Net
        World = deps.World
end

function GudangService.setPoint(index: number, pos: Vector3)
        points[index] = pos
        if not gudang[index] then
                gudang[index] = GudangLogic.baru()
        end
end

local function near(player, index: number): boolean
        local p = points[index]
        if not p then
                return false
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return false
        end
        return (root.Position - p).Magnitude <= 34
end

local function stateOf(index: number)
        if not gudang[index] then
                gudang[index] = GudangLogic.baru()
        end
        return gudang[index]
end

function GudangService.syncTo(player, index: number)
        local gd = stateOf(index)
        local slots = {}
        for i, s in ipairs(gd.s) do
                slots[i] = { i = i, id = s.id, count = s.count }
        end
        Net.get("GudangSync"):FireClient(player, { lahan = index, terpakai = #gd.s, maks = GudangLogic.MaksSlot, slots = slots })
end

function GudangService.simpan(player, cropId: any, nRaw: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Barang tidak dikenal."
        end
        if not near(player, index) then
                return false, "Dekati gudang dulu."
        end
        local stock = Tas.count(player, "hasil", cropId)
        if stock < 1 then
                return false, "Tidak ada hasil panen itu di tas."
        end
        local n = math.floor(tonumber(nRaw) or 0)
        if n < 1 then
                n = stock
        end
        n = math.min(n, stock, GudangLogic.MaksIsi)
        local gd = stateOf(index)
        local ok, msg = GudangLogic.simpan(gd, cropId, n, CropData.byId)
        if not ok then
                return false, msg
        end
        Tas.remove(player, "hasil", cropId, n)
        if World then
                World.touch(index)
        end
        GudangService.syncTo(player, index)
        local info = CropData.byId[cropId]
        return true, "Disimpan " .. n .. " " .. info.nama .. ". " .. msg
end

function GudangService.ambil(player, slotI: any, nRaw: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if not near(player, index) then
                return false, "Dekati gudang dulu."
        end
        local gd = stateOf(index)
        local i = math.floor(tonumber(slotI) or 0)
        local ok, msg, n = GudangLogic.ambil(gd, i, tonumber(nRaw))
        if not ok then
                return false, msg
        end
        local s = gd.s[i]
        if not CropData.byId[s.id] then
                return false, "Barang tidak dikenal."
        end
        local room = Tas.roomFor(player, "hasil", s.id, n)
        if room < 1 then
                return false, "Tas penuh! Kosongkan slot tas dulu."
        end
        if room < n then
                n = room
        end
        Tas.add(player, "hasil", s.id, n)
        GudangLogic.kurangi(gd, i, n)
        if World then
                World.touch(index)
        end
        GudangService.syncTo(player, index)
        local info = CropData.byId[s.id]
        return true, "Diambil " .. n .. " " .. (info and info.nama or s.id) .. ". " .. "Tampungan terpakai " .. #gd.s .. "/" .. GudangLogic.MaksSlot .. " (sisa " .. GudangLogic.MaksSlot - #gd.s .. ")."
end

function GudangService.serLahan(index: number)
        return GudangLogic.ser(gudang[index], CropData.byId)
end

function GudangService.restoreLahan(index: number, arr: any)
        gudang[index] = GudangLogic.des(arr, CropData.byId)
end

function GudangService.clearLahan(index: number)
        gudang[index] = nil
        points[index] = nil
end

return GudangService

end)()

local MOD_DropService = (function()
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CropData = MOD_CropData
local DropModels = MOD_DropModels
local KlaimDrop = MOD_KlaimDrop
local PanenWaktu = MOD_PanenWaktu
local DuniaLogic = MOD_DuniaLogic
local TanahDrops = MOD_TanahDrops
local Layout = MOD_Layout

local DropService = {}

local Land, Tas, Audit

local folders: { [number]: Folder } = {}
local rekaman: { [number]: { [string]: any } } = {}
local counters: { [number]: number } = {}

function DropService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Audit = deps.Audit
end

local function folderFor(index: number): Folder?
        local root = Workspace:FindFirstChild("Dunia")
        if not root then
                return nil
        end
        local f = root:FindFirstChild("Drops_" .. index)
        if not f then
                f = Instance.new("Folder")
                f.Name = "Drops_" .. index
                f.Parent = root
        end
        folders[index] = f :: Folder
        return f :: Folder
end

local function hitungHidup(index: number): number
        local n = 0
        for _, rec in pairs(rekaman[index] or {}) do
                if rec.status == "ada" or rec.status == "proses" then
                        n += 1
                end
        end
        return n
end

local function hapusModel(model: Model?)
        if model and model.Parent then
                model:Destroy()
        end
end

function DropService.clearLahan(index: number)
        rekaman[index] = nil
        counters[index] = nil
        local f = folders[index]
        if f then
                f:Destroy()
                folders[index] = nil
        end
end

local function floatify(root: BasePart, basePos: Vector3)
        root.Anchored = true
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        TweenService:Create(root, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = basePos + Vector3.new(0, 2.8, 0) }):Play()
end

local function idBaru(index: number): string
        counters[index] = (counters[index] or 0) + 1
        local unik = tostring(os.time()):sub(-8)
        return "d" .. tostring(index) .. "x" .. tostring(counters[index]) .. "y" .. unik .. tostring(math.random(100, 999))
end

local PENGECUALI_AWAL = { "Drops_", "PlotGrid_" }

local function tanahDiBawah(index: number, pos: Vector3): number?
        local dunia = Workspace:FindFirstChild("Dunia")
        local rayY: number? = nil
        if dunia then
                local excl: { Instance } = {}
                for _, c in ipairs(dunia:GetDescendants()) do
                        if c:IsA("Folder") or c:IsA("Model") then
                                local nm = c.Name
                                for _, awalan in ipairs(PENGECUALI_AWAL) do
                                        if string.sub(nm, 1, #awalan) == awalan then
                                                table.insert(excl, c)
                                                break
                                        end
                                end
                        end
                end
                for _, pl in ipairs(Players:GetPlayers()) do
                        local char = pl.Character
                        if char then
                                table.insert(excl, char)
                        end
                end
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = excl
                local hit = Workspace:Raycast(pos + Vector3.new(0, 8, 0), Vector3.new(0, -90, 0), params)
                if hit then
                        rayY = hit.Position.Y
                end
        end
        local o = Land and Land.origin and Land.origin(index)
        if o then
                local lx = pos.X - o.X
                local lz = pos.Z - o.Z
                if Layout.diAreaPlot(lx, lz) then
                        if rayY == nil or Layout.PlotTopY > rayY - 0.01 then
                                return Layout.PlotTopY
                        end
                end
        end
        return rayY
end

local function letakkanDiAtasTanah(rec: any)
        local part = rec.part
        if not part or not part.Parent or not rec.groundY then
                return
        end
        local half = part.Size.Y / 2
        local p = part.Position
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
        part.CFrame = CFrame.new(p.X, TanahDrops.istirahatY(rec.groundY, half), p.Z) * part.CFrame.Rotation
end

local function pasangClaim(index: number, rec: any, part: BasePart, basePos: Vector3)
        part.Touched:Connect(function(hit)
                if rec.status ~= "ada" then
                        return
                end
                local karakter = hit and hit.Parent
                local p = karakter and Players:GetPlayerFromCharacter(karakter)
                if not p then
                        return
                end
                local root = karakter:FindFirstChild("HumanoidRootPart") :: BasePart?
                local dist = root and (root.Position - part.Position).Magnitude or math.huge
                local ok, alasan = KlaimDrop.coba(rec, p.UserId, dist)
                if not ok then
                        if Audit then
                                if alasan == "bukan_milik" then
                                        Audit.catat(p, "milik", "drop " .. tostring(rec.id))
                                elseif alasan == "jarak" then
                                        Audit.catat(p, "jarak", "drop " .. tostring(rec.id))
                                elseif alasan == "sudah_diambil" then
                                        Audit.catat(p, "klaim_ganda", "drop " .. tostring(rec.id))
                                end
                        end
                        return
                end
                local cid = rec.crop
                local n = rec.count
                if Tas.roomFor(p, "hasil", cid, n) < n then
                        KlaimDrop.batalkan(rec, p.UserId)
                        floatify(part, basePos)
                        return
                end
                if not KlaimDrop.selesai(rec, p.UserId) then
                        return
                end
                Tas.add(p, "hasil", cid, n)
                local pem = part:FindFirstChildWhichIsA("ParticleEmitter")
                if pem then
                        pem:Emit(8)
                end
                local ding = Instance.new("Sound")
                ding.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                ding.Volume = 0.45
                ding.PlaybackSpeed = 1.5
                ding.Parent = part
                ding:Play()
                part.Anchored = true
                part.CanCollide = false
                for _, d in ipairs(rec.model:GetDescendants()) do
                        if d:IsA("BasePart") then
                                d.Anchored = true
                                d.CanCollide = false
                        end
                end
                task.delay(0.9, function()
                        hapusModel(rec.model)
                end)
        end)
end

local function bangunModel(index: number, rec: any): boolean
        local f = folderFor(index)
        if not f then
                return false
        end
        local info = CropData.byId[rec.crop]
        if not info then
                return false
        end
        local model = DropModels.buat(rec.pos, rec.crop, rec.tier or 1)
        if not model then
                return false
        end
        local part = model.PrimaryPart :: BasePart
        part:SetAttribute("DropId", rec.id)
        part:SetAttribute("LahanIdx", index)
        model.Parent = f
        rec.model = model
        rec.part = part
        rec.groundY = tanahDiBawah(index, part.Position)
        rec.lahir = os.clock()
        rec.settle = 0
        if rec.groundY then
                local half = part.Size.Y / 2
                local bawah = TanahDrops.bagianBawah(part.Position.Y, half)
                if TanahDrops.perluNaik(bawah, rec.groundY, half) or bawah < rec.groundY + 0.4 then
                        local target = rec.groundY + half + 0.55
                        local naik = target - part.Position.Y
                        if naik > 0 then
                                model:PivotTo(model:GetPivot() + Vector3.new(0, naik, 0))
                        end
                end
        end
        local warna = part.Color
        local pem = Instance.new("ParticleEmitter")
        pem.Color = ColorSequence.new(warna)
        pem.Lifetime = NumberRange.new(0.45, 0.9)
        pem.Speed = NumberRange.new(8, 16)
        pem.SpreadAngle = Vector2.new(180, 180)
        pem.Size = NumberSequence.new(0.55, 0)
        pem.Transparency = NumberSequence.new(0.1, 1)
        pem.Enabled = false
        pem.Parent = part
        if not rec.pulih then
                pem:Emit(10 + 9 * (rec.tier or 1))
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                snd.Volume = 0.3 + 0.12 * (rec.tier or 1)
                snd.PlaybackSpeed = 1.25 - 0.14 * (rec.tier or 1)
                snd.Parent = part
                snd:Play()
                if (rec.comboN or 0) >= 4 then
                        local whoosh = Instance.new("Sound")
                        whoosh.SoundId = "rbxasset://sounds/swoosh.wav"
                        whoosh.Volume = 0.35
                        whoosh.Parent = part
                        whoosh:Play()
                end
                part.AssemblyLinearVelocity = Vector3.new(math.random(-7, 7), 18 + 5 * (rec.tier or 1), math.random(-7, 7))
                part.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
        end
        local basePos = part.Position
        pasangClaim(index, rec, part, basePos)
        return true
end

task.spawn(function()
        while true do
                task.wait(0.25)
                local kini = os.clock()
                for _, map in pairs(rekaman) do
                        for _, rec in pairs(map) do
                                local part = rec.part
                                if rec.status == "ada" and part and part.Parent and part:IsDescendantOf(Workspace) and rec.groundY then
                                        local half = part.Size.Y / 2
                                        local bawah = TanahDrops.bagianBawah(part.Position.Y, half)
                                        if not part.Anchored then
                                                if TanahDrops.perluNaik(bawah, rec.groundY, half) then
                                                        letakkanDiAtasTanah(rec)
                                                        rec.settle = 0
                                                else
                                                        local v = part.AssemblyLinearVelocity
                                                        if (v and v.Magnitude or 0) < 0.6 then
                                                                rec.settle += 1
                                                        else
                                                                rec.settle = 0
                                                        end
                                                        if TanahDrops.harusTidur(rec.settle, kini - (rec.lahir or kini)) then
                                                                letakkanDiAtasTanah(rec)
                                                                part.Anchored = true
                                                        end
                                                end
                                        end
                                end
                        end
                end
        end
end)

function DropService.spawn(index: number, pos: Vector3, cropId: string, count: number, comboN: number, tier: number)
        local info = CropData.byId[cropId]
        if not info then
                return
        end
        local owner = Land and Land.ownerOf(index)
        if not owner then
                return
        end
        rekaman[index] = rekaman[index] or {}
        if hitungHidup(index) >= DuniaLogic.MaxDrops then
                local tertua, waktuTua = nil, math.huge
                for id, rec in pairs(rekaman[index]) do
                        if rec.status == "ada" and rec.bornAt < waktuTua then
                                tertua, waktuTua = id, rec.bornAt
                        end
                end
                if tertua then
                        local lama = rekaman[index][tertua]
                        hapusModel(lama.model)
                        rekaman[index][tertua] = nil
                end
        end
        local rec: any = {
                id = idBaru(index),
                crop = cropId,
                count = count,
                pos = pos,
                bornAt = os.time(),
                status = "ada",
                owner = owner,
                comboN = comboN,
                tier = tier,
                pulih = false,
        }
        if not bangunModel(index, rec) then
                return
        end
        rekaman[index][rec.id] = rec
end

function DropService.serLahan(index: number): { any }
        local out = {}
        for _, rec in pairs(rekaman[index] or {}) do
                if rec.status == "ada" then
                        table.insert(out, {
                                id = rec.id,
                                crop = rec.crop,
                                count = rec.count,
                                pos = { x = rec.pos.X, y = rec.pos.Y, z = rec.pos.Z },
                        })
                end
        end
        return out
end

function DropService.restoreLahan(index: number, arr: any, leaveTime: any): number
        rekaman[index] = rekaman[index] or {}
        if leaveTime ~= nil and not PanenWaktu.masihAman(leaveTime, os.time()) then
                return 0
        end
        local n = 0
        for _, d in ipairs(DuniaLogic.desDrops(arr or {})) do
                local rec: any = {
                        id = d.id,
                        crop = d.crop,
                        count = d.count,
                        pos = Vector3.new(d.pos.x, d.pos.y, d.pos.z),
                        bornAt = os.time(),
                        status = "ada",
                        owner = Land and Land.ownerOf(index),
                        pulih = true,
                }
                if not rekaman[index][rec.id] and CropData.byId[rec.crop] and bangunModel(index, rec) then
                        rekaman[index][rec.id] = rec
                        n += 1
                end
                if n >= DuniaLogic.MaxDrops then
                        break
                end
        end
        return n
end

function DropService.hidup(index: number): number
        return hitungHidup(index)
end

return DropService

end)()

local MOD_UIController = nil
local function LOAD_UIController()
	if not MOD_UIController then
		MOD_UIController = (function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local CropData = MOD_CropData
local Net = MOD_Remotes
local UIStyle = MOD_UIStyle
local PukulAnim = MOD_PukulAnim
local ArahPukul = MOD_ArahPukul
local KontrolHP = MOD_KontrolHP
local HUDLayout = MOD_HUDLayout
local DropBentuk = MOD_DropBentuk
local IkonJempol = MOD_IkonJempol
local JualLogic = MOD_JualLogic
local SemaiLogic = MOD_SemaiLogic
local MesinLogika = MOD_MesinLogika
local KameraKunci = MOD_KameraKunci
local TasLogic = MOD_TasLogic
local SanitasiTas = MOD_SanitasiTas
local UangSingkat = MOD_UangSingkat
local IkonKoin = MOD_IkonKoin

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local state = {
        micda = 0,
        tas = {},
        lahan = nil,
        semai = {} :: any,
        zone = "kota",
        dunia = nil,
        role = "hub",
        gudang = nil,
        tanam = nil,
}

local function fmt(n: number): string
        local s = tostring(math.floor(n))
        local rev = string.reverse(s)
        rev = rev:gsub("(%d%d%d)", "%1.")
        rev = rev:gsub("%.$", "")
        return string.reverse(rev)
end

local function warna(t: { number }): Color3
        return Color3.fromRGB(t[1] or 255, t[2] or 255, t[3] or 255)
end

local function warna3b(t: any): Color3
        if type(t) == "table" then
                return Color3.fromRGB(t[1] or 200, t[2] or 200, t[3] or 200)
        end
        return warna(UIStyle.Abu)
end

local function folderTanaman(): Folder?
        local dunia = Workspace:FindFirstChild("Dunia")
        return dunia and dunia:FindFirstChild("PlotGrid_" .. tostring(state.lahan), true)
end

local function fxTumbuh(posisi: Vector3)
        local wadah = Instance.new("Part")
        wadah.Size = Vector3.new(0.4, 0.4, 0.4)
        wadah.Transparency = 1
        wadah.CFrame = CFrame.new(posisi)
        wadah.Anchored = true
        wadah.CanCollide = false
        wadah.CanQuery = false
        wadah.CanTouch = false
        wadah.Parent = Workspace
        local cahaya = Instance.new("ParticleEmitter")
        cahaya.Color = ColorSequence.new(Color3.fromRGB(160, 240, 165), Color3.fromRGB(96, 198, 112))
        cahaya.LightEmission = 0.85
        cahaya.Lifetime = NumberRange.new(0.35, 0.7)
        cahaya.Speed = NumberRange.new(2.5, 5)
        cahaya.SpreadAngle = Vector2.new(180, 180)
        cahaya.Size = NumberSequence.new(0.32, 0)
        cahaya.Enabled = false
        cahaya.Parent = wadah
        local bunyi = Instance.new("Sound")
        bunyi.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        bunyi.PlaybackSpeed = 1.5
        bunyi.Volume = 0.4
        bunyi.Parent = wadah
        pcall(function()
                cahaya:Emit(14)
                bunyi:Play()
        end)
        task.delay(1.6, function()
                wadah:Destroy()
        end)
end

local function efekTanamanBaru(sebelum: { [number]: boolean })
        task.spawn(function()
                task.wait(0.14)
                local folder = state.zone == "dunia" and state.lahan and folderTanaman() or nil
                if not folder then
                        return
                end
                local jumlahFx = 0
                for _, m in ipairs(folder:GetChildren()) do
                        if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" and jumlahFx < 12 then
                                local idx = m:GetAttribute("PlotIdx")
                                if type(idx) == "number" and not sebelum[idx] then
                                        jumlahFx += 1
                                        fxTumbuh(m:GetPivot().Position + Vector3.new(0, 0.8, 0))
                                end
                        end
                end
        end)
end

local FON = Enum.Font[UIStyle.Font]
local FONTB = Enum.Font[UIStyle.FontTebal]

local PANEL_TITLES = {
        tas = "Tas",
        semai = "Mesin Semai Panen",
        toko = "Toko Benih",
        gerbang = "Gerbang Dunia",
        tanam = "Papan Tanam",
        gudang = "Gudang Hasil Panen",
}

local function mk(class: string, props: { [string]: any }, parent: Instance?): Instance
        local inst = Instance.new(class)
        for k, v in props do
                (inst :: any)[k] = v
        end
        inst.Parent = parent
        return inst
end

local function round(inst: Instance, r: number?)
        mk("UICorner", { CornerRadius = UDim.new(0, r or UIStyle.Sudut) }, inst)
end

local gui = mk("ScreenGui", {
        Name = "DuniaAkiomida",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
}, playerGui)

local camera = Workspace.CurrentCamera

local aman = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, gui)
local amanPad = mk("UIPadding", { PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0) }, aman)

local function teksSkala(props: { [string]: any }, parent: Instance): TextLabel
        props.TextScaled = true
        local l = mk("TextLabel", props, parent)
        mk("UITextSizeConstraint", { MaxTextSize = HUDLayout.TeksMaks, MinTextSize = HUDLayout.TeksMin }, l)
        return l :: TextLabel
end

local kolomKiri = mk("Frame", { Name = "KolomKiri", Position = UDim2.fromScale(HUDLayout.SaldoSkalaX, 0), Size = UDim2.fromScale(HUDLayout.SaldoSkalaLebar, 1), BackgroundTransparency = 1 }, aman)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Top }, kolomKiri)

local saldo = mk("TextButton", { Name = "SaldoHUD", LayoutOrder = 1, Size = UDim2.new(0, 0, HUDLayout.SaldoSkalaTinggi, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.12, Text = "", AutoButtonColor = false }, kolomKiri)
round(saldo)
mk("UISizeConstraint", { MinSize = Vector2.new(HUDLayout.SaldoLebarMin, 30), MaxSize = Vector2.new(HUDLayout.SaldoLebarMaks, 64) }, saldo)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, HUDLayout.SaldoGapX), HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, saldo)
mk("UIPadding", { PaddingLeft = UDim.new(0, HUDLayout.SaldoPadX), PaddingRight = UDim.new(0, HUDLayout.SaldoPadX) }, saldo)

local ikonSaldo = mk("Frame", { LayoutOrder = 1, Size = UDim2.fromOffset(HUDLayout.SaldoIkonPx, HUDLayout.SaldoIkonPx), BackgroundTransparency = 1 }, saldo)
IkonKoin.buat(ikonSaldo, HUDLayout.SaldoIkonPx)
local angkaLabel = mk("TextLabel", { Name = "SaldoAngka", LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "0", TextSize = HUDLayout.SaldoTeksPx, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd }, saldo)
local satuanLabel = mk("TextLabel", { Name = "SaldoSatuan", LayoutOrder = 3, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "Micda", TextSize = HUDLayout.SaldoSatuanPx, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false }, saldo)

local saldoPenuh = false
local function renderSaldo()
        local n = state.micda or 0
        angkaLabel.Text = saldoPenuh and UangSingkat.penuh(n) or UangSingkat.singkat(n)
        satuanLabel.Visible = not saldoPenuh
end
saldo.Activated:Connect(function()
        saldoPenuh = not saldoPenuh
        renderSaldo()
end)
renderSaldo()

local travelBtn = mk("TextButton", { LayoutOrder = 2, Size = UDim2.fromScale(1, HUDLayout.NavSkalaTinggi), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = warna(UIStyle.Permukaan), Text = "Masuk Dunia-ku", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Center }, kolomKiri)
round(travelBtn)
mk("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, travelBtn)
local navUkuran = mk("UISizeConstraint", { MinSize = Vector2.new(120, 26), MaxSize = Vector2.new(220, 26) }, travelBtn)

local tasBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.992, HUDLayout.SaldoSkalaY), Size = UDim2.fromScale(HUDLayout.TasSkalaLebar, HUDLayout.SaldoSkalaTinggi), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Tas", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, aman)
round(tasBtn)
local tasUkuran = mk("UISizeConstraint", { MinSize = Vector2.new(90, 30), MaxSize = Vector2.new(200, 64) }, tasBtn)

local punchShadow = mk("Frame", { Name = "BayanganPunch", AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.62, BorderSizePixel = 0, ZIndex = 0 }, gui)
round(punchShadow, 46)
local punchBtn = mk("TextButton", {
        Name = "TombolPunch",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = warna(UIStyle.Hijau),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
}, gui)
round(punchBtn, 46)
mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(88, 178, 114), Color3.fromRGB(46, 108, 72)), Rotation = 90 }, punchBtn)
mk("UIStroke", { Color = Color3.fromRGB(214, 226, 218), Thickness = 1.5, Transparency = 0.55 }, punchBtn)
local punchSkalaUI = mk("UIScale", { Scale = 1 }, punchBtn)
local ikonPunch = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.62), BackgroundTransparency = 1 }, punchBtn)
for _, g in ipairs(IkonJempol.bagian()) do
        local f = mk("Frame", { Position = UDim2.fromScale(g.dx, g.dy), Size = UDim2.fromScale(g.dw, g.dh), BackgroundColor3 = warna(UIStyle.Teks), BorderSizePixel = 0, ZIndex = 3 }, ikonPunch)
        if g.bentuk == "lingkaran" then
                mk("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
        end
end

local function efekTekan(turun: boolean)
        TweenService:Create(punchSkalaUI, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = turun and 0.9 or 1 }):Play()
end
punchBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                efekTekan(true)
        end
end)
punchBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                efekTekan(false)
        end
end)

local jumpPxNyata: number? = nil
local lompatBtnNyata: GuiObject? = nil
local function aturPunch()
        local vp = camera.ViewportSize
        local pos = KontrolHP.posisiPunch(vp.X, vp.Y, jumpPxNyata)
        punchBtn.Position = UDim2.fromScale(pos.skalaX, pos.skalaY)
        punchBtn.Size = UDim2.fromScale(pos.skalaLebar, pos.skalaTinggi)
        punchShadow.Position = UDim2.new(pos.skalaX, 0, pos.skalaY, 3)
        punchShadow.Size = UDim2.fromScale(pos.skalaLebar, pos.skalaTinggi)
end

local function aturUkuranAman()
        local inset = GuiService.TopbarInset
        amanPad.PaddingTop = UDim.new(0, inset.Min.Y + 10)
        amanPad.PaddingLeft = UDim.new(0, inset.Min.X)
        local vp = camera.ViewportSize
        local a = HUDLayout.areaAman(vp.X, vp.Y, inset.Min.X, inset.Min.Y)
        local bs = HUDLayout.batasSaldo(a)
        local bn = HUDLayout.batasNav(a)
        navUkuran.MinSize = Vector2.new(bn.minim, bn.tinggi)
        navUkuran.MaxSize = Vector2.new(bn.maks, bn.tinggi)
        local bt = HUDLayout.batasTas(a)
        tasUkuran.MinSize = Vector2.new(bt.lebar, bs.tinggi)
        tasUkuran.MaxSize = Vector2.new(bt.lebar, bs.tinggi)
        aturPunch()
end

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(aturUkuranAman)
camera:GetPropertyChangedSignal("ViewportSize"):Connect(aturUkuranAman)
aturUkuranAman()

task.spawn(function()
        local ui = playerGui:WaitForChild("TouchGui", 8)
        if not ui then
                return
        end
        task.wait(0.1)
        local tcf = ui:FindFirstChild("TouchControlFrame")
        local jump = tcf and tcf:FindFirstChild("JumpButton")
        if not jump or not jump:IsA("GuiObject") then
                return
        end
        jumpPxNyata = jump.AbsoluteSize.X
        lompatBtnNyata = jump
        aturPunch()
end)

local toastHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.2), Size = UDim2.fromScale(0.7, 0.42), BackgroundTransparency = 1 }, aman)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, toastHolder)

local zonaLabel = teksSkala({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, HUDLayout.SaldoSkalaY), Size = UDim2.fromScale(0.24, HUDLayout.NavSkalaTinggi), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.2, Text = "Pusat Kota", Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextTruncate = Enum.TextTruncate.AtEnd }, aman)
round(zonaLabel, UIStyle.SudutKecil)

local toastOrder = 0

local function toastSaja(teks: string)
        toastOrder += 1
        local f = mk("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.1, LayoutOrder = -toastOrder }, toastHolder)
        round(f)
        mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, f)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, f)
        IkonKoin.buat(f, 18).LayoutOrder = 1
        mk("TextLabel", { LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false }, f)
        task.delay(2, function()
                f:Destroy()
        end)
end

local function toast(title: string, msg: string)
        toastOrder += 1
        local f = mk("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.08, LayoutOrder = -toastOrder }, toastHolder)
        round(f)
        mk("TextLabel", { Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, Text = title, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, f)
        mk("TextLabel", { Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 24), BackgroundTransparency = 1, Text = msg, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
        task.delay(3.2, function()
                f:Destroy()
        end)
end

local dim = mk("Frame", { Name = "DimLayar", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false, Active = true }, gui)
local panelHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromScale(0.94, 0.88), BackgroundColor3 = warna(UIStyle.Latar), Active = true }, dim)
round(panelHolder, 12)
local panelBatas = mk("UISizeConstraint", { MinSize = Vector2.new(300, 240), MaxSize = Vector2.new(UIStyle.LebarPanelMaks, UIStyle.TinggiPanelMaks) }, panelHolder)
mk("UIPadding", {
        PaddingTop = UDim.new(0, UIStyle.AmanAtas),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
}, panelHolder)

local panelTitle = mk("TextLabel", { Size = UDim2.new(1, -60, 0, 34), Position = UDim2.new(0, 2, 0, 2), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, panelHolder)
local closeBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 44, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "X", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, panelHolder)
round(closeBtn, UIStyle.SudutKecil)

local panels = {}
local currentPanel: string? = nil

local zoomTersimpan: any? = nil
local kameraTipeTersimpan: any? = nil

local function kunciKamera()
        if zoomTersimpan then
                return
        end
        local jarak = KameraKunci.jepit((camera.CFrame.Position - camera.Focus.Position).Magnitude)
        local mn, mx, simpan = KameraKunci.kunci(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, jarak)
        player.CameraMinZoomDistance = mn
        player.CameraMaxZoomDistance = mx
        zoomTersimpan = simpan
        kameraTipeTersimpan = camera.CameraType
        camera.CameraType = Enum.CameraType.Scriptable
end

local function bukaKamera()
        if not zoomTersimpan then
                return
        end
        local mn, mx = KameraKunci.buka(zoomTersimpan)
        player.CameraMinZoomDistance = mn
        player.CameraMaxZoomDistance = mx
        zoomTersimpan = nil
        camera.CameraType = kameraTipeTersimpan or Enum.CameraType.Custom
        kameraTipeTersimpan = nil
end

local function sembunyikanKontrol()
        punchBtn.Visible = false
        punchShadow.Visible = false
        if lompatBtnNyata then
                lompatBtnNyata.Visible = false
        end
end

local function tampilkanKontrol()
        punchBtn.Visible = true
        punchShadow.Visible = true
        if lompatBtnNyata then
                lompatBtnNyata.Visible = true
        end
end

local function closePanel()
        dim.Visible = false
        currentPanel = nil
        tampilkanKontrol()
        bukaKamera()
end

local function makePanel(name: string): Frame
        local f = mk("Frame", { Size = UDim2.new(1, 0, 1, -44), Position = UDim2.new(0, 0, 0, 42), BackgroundTransparency = 1, Visible = false }, panelHolder)
        panels[name] = f
        return f
end

local function openPanel(name: string)
        for n, f in pairs(panels) do
                f.Visible = n == name
        end
        panelTitle.Text = PANEL_TITLES[name] or ""
        if name == "semai" or name == "tanam" then
                panelBatas.MaxSize = Vector2.new(760, 620)
        else
                panelBatas.MaxSize = Vector2.new(UIStyle.LebarPanelMaks, UIStyle.TinggiPanelMaks)
        end
        kunciKamera()
        dim.Visible = true
        currentPanel = name
        if name == "tanam" then
                sembunyikanKontrol()
        end
end

closeBtn.Activated:Connect(closePanel)

local function bersihkan(parent: Instance)
        for _, c in ipairs(parent:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then
                        c:Destroy()
                end
        end
end

local tasPanel = makePanel("tas")
local tasGrid = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -40), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tasPanel)
mk("UIGridLayout", { CellSize = UDim2.new(0, 96, 0, 88), CellPadding = UDim2.new(0, 8, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tasGrid)
local slotFrames = {}
for i = 1, 50 do
        local cell = mk("Frame", { BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = i }, tasGrid)
        round(cell, UIStyle.SudutKecil)
        local nama = mk("TextLabel", { Size = UDim2.new(1, -10, 0, 28), Position = UDim2.new(0, 5, 0, 36), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks) }, cell)
        local count = mk("TextLabel", { Size = UDim2.new(1, -10, 0, 16), Position = UDim2.new(0, 5, 1, -20), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen) }, cell)
        slotFrames[i] = { frame = cell, nama = nama, count = count }
end
local tasUsedLabel = mk("TextLabel", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 4, 1, -2), Size = UDim2.new(0.6, 0, 0, 26), BackgroundTransparency = 1, Text = "0/50 slot", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, tasPanel)

local function ikonSlot(cell: Frame, s: any?)
        local lama = cell:FindFirstChild("Ikon")
        if lama then
                lama:Destroy()
        end
        if not s then
                return
        end
        local wadah = mk("Frame", { Name = "Ikon", Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 6, 0, 5), BackgroundTransparency = 1 }, cell)
        local info = CropData.byId[s.id]
        local b = info and CropData.Bentuk[info.id]
        local buahC = warna3b(b and b.siap)
        local aksenC = warna3b(b and b.aksen)
        local bagian = DropBentuk.ikonBagian(b and b.jenis or "daun") or {}
        for _, g in ipairs(bagian) do
                local f = mk("Frame", { Position = UDim2.fromScale(g.dx, g.dy), Size = UDim2.fromScale(g.dw, g.dh), BackgroundColor3 = g.warna == "buah" and buahC or aksenC, BorderSizePixel = 0, ZIndex = 2 }, wadah)
                if g.bentuk == "lingkaran" then
                        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
                elseif g.bentuk == "topi" then
                        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
                elseif g.bentuk == "kotak" then
                        f.Rotation = 45
                end
        end
end

local function bersihkanTasClient(raw: any): { any }
        local out = {}
        for _, s in ipairs(type(raw) == "table" and raw or {}) do
                if SanitasiTas.slotValid(s, CropData.byId) then
                        table.insert(out, s)
                end
        end
        return out
end

local function refreshTas()
        local used = #state.tas
        for i = 1, 50 do
                local s = state.tas[i]
                local slot = slotFrames[i]
                if s then
                        local info = CropData.byId[s.id]
                        slot.frame.BackgroundColor3 = s.kind == "benih" and warna(UIStyle.Permukaan) or warna(UIStyle.PermukaanAktif)
                        slot.nama.Text = UIStyle.potong(info and (s.kind == "benih" and ("Benih " .. info.nama) or info.nama) or s.id)
                        slot.count.Text = "x" .. s.count
                        ikonSlot(slot.frame, s)
                else
                        slot.frame.BackgroundColor3 = warna(UIStyle.Permukaan)
                        slot.nama.Text = ""
                        slot.count.Text = ""
                        ikonSlot(slot.frame, nil)
                end
        end
        tasUsedLabel.Text = used .. "/50 slot terpakai"
end

local gerbangPanel = makePanel("gerbang")
local gerbangScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gerbangPanel)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, gerbangScroll)
mk("TextLabel", { Size = UDim2.new(1, -12, 0, 56), BackgroundTransparency = 1, Text = "Duniamu terbuka seketika tanpa loading dan tanpa ID. Tamu bisa berkunjung dan tidak bisa mengubah apa pun. Tombol kiri atas juga bisa dipakai untuk pergi-pulang.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1 }, gerbangScroll)
local masukBtn = mk("TextButton", { Size = UDim2.new(1, -12, 0, 46), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Masuk Dunia-ku", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 2 }, gerbangScroll)
round(masukBtn)
local pulangBtn = mk("TextButton", { Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Pulang ke Pusat Kota", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 3 }, gerbangScroll)
round(pulangBtn)
mk("TextLabel", { Size = UDim2.new(1, -12, 0, 22), BackgroundTransparency = 1, Text = "Kunjungi dunia pemain lain:", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 4 }, gerbangScroll)
local kunjungiNama = mk("TextBox", { Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", PlaceholderText = "Ketik nama pemain...", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = false, LayoutOrder = 5 }, gerbangScroll)
round(kunjungiNama, UIStyle.SudutKecil)
local kunjungiBtn = mk("TextButton", { Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Kunjungi", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 6 }, gerbangScroll)
round(kunjungiBtn)

local function syncState()
        task.spawn(function()
                local st = Net.get("GetState"):InvokeServer()
                if st then
                        state.micda = st.micda or 0
                        state.tas = bersihkanTasClient(st.tas)
                        state.lahan = st.lahan
                        state.zone = st.zone or "kota"
                        state.dunia = st.dunia
                        state.role = st.role or "hub"
                        renderSaldo()
                        refreshTas()
                end
        end)
end

masukBtn.Activated:Connect(function()
        closePanel()
        task.spawn(function()
                local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
                toast(ok and "Gerbang Dunia" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end)
end)
pulangBtn.Activated:Connect(function()
        closePanel()
        task.spawn(function()
                local ok, msg = Net.get("DuniaAct"):InvokeServer("pulang")
                toast(ok and "Pulang" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end)
end)
kunjungiBtn.Activated:Connect(function()
        closePanel()
        task.spawn(function()
                local ok, msg = Net.get("DuniaAct"):InvokeServer("kunjungi", kunjungiNama.Text)
                toast(ok and "Kunjungan" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end)
end)

travelBtn.Activated:Connect(function()
        if state.zone == "dunia" then
                local ok, msg = Net.get("DuniaAct"):InvokeServer("pulang")
                toast(ok and "Pulang" or "Gagal", msg)
                if ok then
                        syncState()
                end
        else
                local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
                toast(ok and "Gerbang Dunia" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end
end)

local semaiPanel = makePanel("semai")
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 46), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Text = "Mesin semai mengubah hasil panen jadi Micda dan benih baru. Pilih hasil panen, atur jumlah, isi mesin, lalu tekan dua tuas sampai SEMAI TUNTAS.", TextWrapped = true, TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, semaiPanel)
local semaiLangkah = mk("Frame", { Size = UDim2.new(1, -8, 0, 54), Position = UDim2.new(0, 4, 0, 50), BackgroundTransparency = 1 }, semaiPanel)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, semaiLangkah)
for li, lt in ipairs({ { "1", "Pilih hasil panen" }, { "2", "Atur jumlah" }, { "3", "Tekan 2 tuas" } }) do
        local kartu = mk("Frame", { Size = UDim2.new(0.333, -6, 1, 0), BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = li }, semaiLangkah)
        round(kartu, UIStyle.SudutKecil)
        local badge = mk("Frame", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 8, 0.5, -13), BackgroundColor3 = warna(UIStyle.Aksen) }, kartu)
        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, badge)
        mk("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = lt[1], Font = FONTB, TextSize = UIStyle.UkuranIsi, TextColor3 = warna(UIStyle.Latar), ZIndex = 2 }, badge)
        mk("TextLabel", { Size = UDim2.new(1, -46, 1, -8), Position = UDim2.new(0, 42, 0, 4), BackgroundTransparency = 1, Text = lt[2], TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, kartu)
end
local semaiScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -116), Position = UDim2.new(0, 4, 0, 108), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiScroll)

local semaiDim = mk("Frame", { Name = "ModalSemai", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Visible = false, Active = true }, gui)
local semaiBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0.88, 0, 0, 290), BackgroundColor3 = warna(UIStyle.Latar), Active = true }, semaiDim)
round(semaiBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(300, 250), MaxSize = Vector2.new(470, 360) }, semaiBox)
local semaiPopTitle = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "Atur Jumlah Semai", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, semaiBox)
local semaiPopItem = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 42), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, semaiBox)
local semaiPopMesin = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 66), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, semaiBox)
local semaiPopKurang = mk("TextButton", { Size = UDim2.new(0, 48, 0, 44), Position = UDim2.new(0, 12, 0, 92), BackgroundColor3 = warna(UIStyle.Latar), Text = "-", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, semaiBox)
round(semaiPopKurang, UIStyle.SudutKecil)
local semaiPopQty = mk("TextBox", { Name = "SemaiQty", Size = UDim2.new(0, 92, 0, 44), Position = UDim2.new(0, 64, 0, 92), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "1", PlaceholderText = "1", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = false }, semaiBox)
round(semaiPopQty, UIStyle.SudutKecil)
local semaiPopTambah = mk("TextButton", { Size = UDim2.new(0, 48, 0, 44), Position = UDim2.new(0, 160, 0, 92), BackgroundColor3 = warna(UIStyle.Latar), Text = "+", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, semaiBox)
round(semaiPopTambah, UIStyle.SudutKecil)
local semaiPopMaks = mk("TextButton", { Name = "SemaiMaks", Size = UDim2.new(0, 76, 0, 44), Position = UDim2.new(0, 212, 0, 92), BackgroundColor3 = warna(UIStyle.Aksen), Text = "Maks", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Latar) }, semaiBox)
round(semaiPopMaks, UIStyle.SudutKecil)
mk("TextLabel", { Size = UDim2.new(1, -296, 0, 44), Position = UDim2.new(0, 296, 0, 92), BackgroundTransparency = 1, Text = "Maks = stok tas\natau sisa kapasitas", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Center }, semaiBox)
local semaiPopPrev = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 52), Position = UDim2.new(0, 12, 0, 144), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, semaiBox)
local semaiPopYa = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 44), Position = UDim2.new(0, 12, 1, -56), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Masukkan ke Mesin", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, semaiBox)
round(semaiPopYa, UIStyle.SudutKecil)
local semaiPopBatal = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 44), Position = UDim2.new(0.5, 9, 1, -56), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Batal", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, semaiBox)
round(semaiPopBatal, UIStyle.SudutKecil)

local semaiPopAktif: { id: string, stok: number, sisa: number, topUp: boolean }? = nil
local bukaStrukKlaim: (any) -> ()

local function tasTotal(kind: string, id: string): number
        local total = 0
        for _, s in ipairs(state.tas) do
                if s.kind == kind and s.id == id then
                        total += s.count
                end
        end
        return total
end

local function semaiPopTutup()
        semaiPopAktif = nil
        semaiDim.Visible = false
end

local function semaiPopMaksNilai(): number
        local a = semaiPopAktif
        if not a then
                return 0
        end
        local sb = state.semai
        local adaB = type(sb) == "table" and sb.tahap ~= nil and sb.tahap ~= "kosong"
        local batchKirim = nil
        if adaB and sb.crop == a.id then
                batchKirim = sb
        end
        return MesinLogika.maksIsi(a.stok, batchKirim, CropData.MesinSemai.Kapasitas)
end

local function semaiPopPreview()
        local a = semaiPopAktif
        if not a then
                return
        end
        local info = CropData.byId[a.id]
        local cfg = info and CropData.Giling[info.rarity] or nil
        local per = cfg and SemaiLogic.pukulanPerItem(cfg) or 1
        local maks = semaiPopMaksNilai()
        local raw = tonumber(semaiPopQty.Text)
        if not raw or raw ~= raw or raw % 1 ~= 0 or math.floor(raw) < 1 then
                semaiPopPrev.TextColor3 = warna(UIStyle.Merah)
                semaiPopPrev.Text = "Jumlah harus angka bulat minimal 1. Jumlah 0 tidak bisa dikonfirmasi."
                return
        end
        local n = math.floor(raw)
        if maks < 1 then
                semaiPopPrev.TextColor3 = warna(UIStyle.Merah)
                semaiPopPrev.Text = "Tidak bisa menambah: kapasitas mesin penuh atau tas kosong."
                return
        end
        if n > a.stok then
                semaiPopPrev.TextColor3 = warna(UIStyle.Merah)
                semaiPopPrev.Text = "Melebihi stok di tas! Ada " .. tostring(a.stok) .. " " .. info.nama .. "."
                return
        end
        if n > maks then
                semaiPopPrev.TextColor3 = warna(UIStyle.Merah)
                semaiPopPrev.Text = "Melebihi sisa kapasitas mesin! Sisa " .. tostring(maks) .. " lagi."
                return
        end
        semaiPopPrev.TextColor3 = warna(UIStyle.Teks)
        semaiPopPrev.Text = "Total pukulan: " .. tostring(SemaiLogic.pukulanTotal(n, per)) .. " (per item " .. tostring(per) .. "). Mesin jalan setelah dua tuas ditekan."
end

local function semaiPopBuka(id: string)
        local info = CropData.byId[id]
        if not info then
                return
        end
        local stok = tasTotal("hasil", id)
        if stok < 1 then
                toast("Mesin Semai", "Tidak ada " .. info.nama .. " di tas.")
                return
        end
        local sb = state.semai
        local adaB = type(sb) == "table" and sb.tahap ~= nil and sb.tahap ~= "kosong"
        local isi = 0
        if adaB and sb.crop == id and type(sb.jumlah) == "number" then
                isi = math.max(0, math.floor(sb.jumlah))
        end
        local sisa = math.max(0, CropData.MesinSemai.Kapasitas - isi)
        if sisa < 1 then
                toast("Mesin Semai", "Kapasitas mesin penuh (" .. tostring(CropData.MesinSemai.Kapasitas) .. "/" .. tostring(CropData.MesinSemai.Kapasitas) .. "). Klaim isi mesin dulu.")
                return
        end
        local cfg = CropData.Giling[info.rarity]
        local per = cfg and SemaiLogic.pukulanPerItem(cfg) or 1
        local aktif = { id = id, stok = stok, sisa = sisa, topUp = adaB and sb.crop == id }
        semaiPopAktif = aktif
        semaiPopTitle.Text = aktif.topUp and "Tambah Isi Mesin" or "Atur Jumlah Semai"
        semaiPopItem.Text = info.nama .. " — stok di tas: " .. tostring(stok) .. " · " .. tostring(per) .. " pukulan/item"
        if aktif.topUp then
                semaiPopMesin.Text = "Mesin berisi " .. tostring(isi) .. "/" .. tostring(CropData.MesinSemai.Kapasitas) .. " — sisa " .. tostring(sisa)
        else
                semaiPopMesin.Text = "Mesin kosong — kapasitas " .. tostring(CropData.MesinSemai.Kapasitas)
        end
        semaiPopQty.Text = "1"
        semaiPopPreview()
        semaiDim.Visible = true
end

semaiPopQty:GetPropertyChangedSignal("Text"):Connect(semaiPopPreview)
semaiPopKurang.Activated:Connect(function()
        local n = tonumber(semaiPopQty.Text) or 2
        semaiPopQty.Text = tostring(math.max(1, math.floor(n) - 1))
end)
semaiPopTambah.Activated:Connect(function()
        local maks = math.max(1, semaiPopMaksNilai())
        local n = tonumber(semaiPopQty.Text) or 0
        semaiPopQty.Text = tostring(math.min(maks, math.max(1, math.floor(n) + 1)))
end)
semaiPopMaks.Activated:Connect(function()
        local maks = semaiPopMaksNilai()
        if maks >= 1 then
                semaiPopQty.Text = tostring(maks)
        end
end)
semaiPopBatal.Activated:Connect(semaiPopTutup)
semaiPopYa.Activated:Connect(function()
        local a = semaiPopAktif
        if not a then
                return
        end
        local maks = semaiPopMaksNilai()
        local raw = tonumber(semaiPopQty.Text)
        if not raw or raw ~= raw or raw % 1 ~= 0 then
                semaiPopPreview()
                return
        end
        local n = math.floor(raw)
        if n < 1 or maks < 1 or n > maks then
                semaiPopPreview()
                return
        end
        semaiPopTutup()
        task.spawn(function()
                local ok, msg = Net.get("SemaiAct"):InvokeServer("atur", a.id, n)
                toast(ok and "Mesin Semai" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end)
end)

local function klaimSemai()
        task.spawn(function()
                local ok, msg, struk = Net.get("SemaiAct"):InvokeServer("klaim")
                if ok and type(struk) == "table" then
                        syncState()
                        bukaStrukKlaim(struk)
                        toast("Semai Tuntas", msg)
                else
                        toast("Gagal", tostring(msg))
                end
        end)
end

local function actionBtn(parent, text: string, order: number)
        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 60), BackgroundColor3 = warna(UIStyle.Latar), LayoutOrder = order }, parent)
        round(holder, UIStyle.SudutKecil)
        mk("TextLabel", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1, Text = text, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, holder)
        return holder
end

local function subBtn(parent: Frame, text: string, posX: number, width: number, warnaBtn: Color3, onAct)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 0, 1, -28), Size = UDim2.new(width, -6, 0, 24), BackgroundColor3 = warnaBtn, Text = text, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, UIStyle.SudutKecil)
        btn.Activated:Connect(onAct)
        return btn
end

local function refreshSemai()
        local b = state.semai
        local adaBatch = type(b) == "table" and b.tahap ~= nil and b.tahap ~= "kosong"
        local namaBatch = ""
        bersihkan(semaiScroll)
        if adaBatch then
                local info = CropData.byId[b.crop]
                namaBatch = info and info.nama or tostring(b.crop)
                local kepala = mk("Frame", { Size = UDim2.new(1, -8, 0, 48), BackgroundColor3 = warna(UIStyle.PermukaanAktif), LayoutOrder = 1 }, semaiScroll)
                round(kepala, UIStyle.SudutKecil)
                mk("TextLabel", { Size = UDim2.new(0.62, -12, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Isi mesin: " .. tostring(b.jumlah) .. " x " .. UIStyle.potong(namaBatch, 14), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, kepala)
                mk("TextLabel", { Size = UDim2.new(0.38, -12, 1, -8), Position = UDim2.new(0.62, 8, 0, 4), BackgroundTransparency = 1, Text = "Total " .. tostring(b.pukulan) .. " pukulan", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, kepala)
                if b.tahap == "tuas" then
                        local tuas = type(b.tuas) == "table" and b.tuas or {}
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), BackgroundTransparency = 1, Text = "AKTIFKAN MESIN — tekan dua tuas di pinggir mesin:", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Kuning), LayoutOrder = 2 }, semaiScroll)
                        local urutanTuas = 3
                        for _, L in ipairs({ { sisi = "kanan", nomor = "1", judul = "Tuas KANAN", ket = "Pinggir kanan mesin" }, { sisi = "kiri", nomor = "2", judul = "Tuas KIRI", ket = "Pinggir kiri mesin" } }) do
                                local selesai = tuas[L.sisi] == true
                                local row = mk("Frame", { Size = UDim2.new(1, -8, 0, 54), BackgroundColor3 = warna(selesai and UIStyle.Hijau or UIStyle.Permukaan), LayoutOrder = urutanTuas }, semaiScroll)
                                urutanTuas += 1
                                round(row, UIStyle.SudutKecil)
                                local badge = mk("Frame", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0.5, -15), BackgroundColor3 = warna(selesai and UIStyle.Latar or UIStyle.AbuGelap) }, row)
                                mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, badge)
                                mk("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = selesai and "OK" or L.nomor, Font = FONTB, TextSize = UIStyle.UkuranJudul, TextColor3 = warna(selesai and UIStyle.Hijau or UIStyle.Teks), ZIndex = 2 }, badge)
                                mk("TextLabel", { Size = UDim2.new(1, -130, 1, -8), Position = UDim2.new(0, 50, 0, 4), BackgroundTransparency = 1, Text = L.judul .. " — " .. L.ket, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(selesai and UIStyle.Latar or UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                                mk("TextLabel", { Size = UDim2.new(0, 72, 1, -8), Position = UDim2.new(1, -78, 0, 4), BackgroundTransparency = 1, Text = selesai and "SELESAI" or (SemaiLogic.tuasBerikut(tuas) == L.sisi and "TEKAN!" or "TUNGGU"), TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(selesai and UIStyle.Latar or UIStyle.Kuning), TextXAlignment = Enum.TextXAlignment.Right }, row)
                        end
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 56), BackgroundTransparency = 1, Text = "Dekati tiap tuas di ujung kanan & kiri mesin, lalu tahan tombol [Tekan Tuas]. Urutan: KANAN dulu, baru KIRI. Keduanya selesai = mesin langsung menyala.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 5 }, semaiScroll)
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 22), BackgroundTransparency = 1, Text = "Hasil panen di tas — klik item untuk menambah isi mesin:", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 6 }, semaiScroll)
                elseif b.tahap == "giling" then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Mesin sedang menggiling " .. tostring(b.jumlah) .. " x " .. UIStyle.potong(namaBatch, 12) .. ". Tunggu sebentar sampai label SEMAI TUNTAS menyala.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 2 }, semaiScroll)
                        return
                elseif b.tahap == "tuntas" then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 26), BackgroundTransparency = 1, Text = "SEMAI TUNTAS! Hasil gilingan siap diambil:", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Kuning), LayoutOrder = 2 }, semaiScroll)
                        local urut = 3
                        local function barisHasil(ikonData: any?, teks: string, kanan: string)
                                local row = mk("Frame", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = urut }, semaiScroll)
                                urut += 1
                                round(row, UIStyle.SudutKecil)
                                if ikonData then
                                        ikonSlot(row, ikonData)
                                else
                                        local m = IkonKoin.buat(row, 28)
                                        m.Position = UDim2.new(0, 6, 0, 5)
                                end
                                mk("TextLabel", { Size = UDim2.new(1, -100, 1, -8), Position = UDim2.new(0, 42, 0, 4), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                                mk("TextLabel", { Size = UDim2.new(0, 52, 1, -8), Position = UDim2.new(1, -56, 0, 4), BackgroundTransparency = 1, Text = kanan, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, row)
                        end
                        barisHasil(nil, "+" .. fmt(b.micda or 0) .. " Micda", "Micda")
                        if (b.benih or 0) > 0 then
                                barisHasil({ kind = "benih", id = b.crop, count = b.benih }, "Benih " .. UIStyle.potong(namaBatch, 18), "x" .. tostring(b.benih))
                        end
                        local btnKlaim = mk("TextButton", { Size = UDim2.new(1, -8, 0, 52), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Klaim Semua", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 9 }, semaiScroll)
                        round(btnKlaim)
                        btnKlaim.Activated:Connect(klaimSemai)
                        return
                end
        end
        local order = 100
        local tampil = 0
        for _, r in ipairs(TasLogic.ringkas(state.tas, "hasil")) do
                local info = CropData.byId[r.id]
                if not info then
                        continue
                end
                tampil += 1
                local cfg = CropData.Giling[info.rarity]
                local per = cfg and SemaiLogic.pukulanPerItem(cfg) or 0
                local row = mk("TextButton", { Size = UDim2.new(1, -8, 0, 54), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, semaiScroll)
                order += 1
                round(row, UIStyle.SudutKecil)
                ikonSlot(row, { kind = "hasil", id = r.id, count = r.count })
                mk("TextLabel", { Size = UDim2.new(0.46, -46, 1, -8), Position = UDim2.new(0, 44, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(info.nama), TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                mk("TextLabel", { Size = UDim2.new(0.2, -8, 1, -8), Position = UDim2.new(0.46, 44, 0, 4), BackgroundTransparency = 1, Text = "x" .. tostring(r.count), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, row)
                mk("TextLabel", { Size = UDim2.new(0.3, -10, 1, -8), Position = UDim2.new(0.7, 6, 0, 4), BackgroundTransparency = 1, Text = tostring(per) .. " pukulan/item", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, row)
                row.Activated:Connect(function()
                        if adaBatch and r.id ~= b.crop then
                                toast("Mesin Semai", "Mesin sedang memproses " .. UIStyle.potong(namaBatch, 16) .. ". Selesaikan dulu sebelum memasukkan item lain.")
                                return
                        end
                        semaiPopBuka(r.id)
                end)
        end
        if tampil == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas. Panen tanaman siap dengan tombol Punch dulu.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1000 }, semaiScroll)
        end
end

local tokoPanel = makePanel("toko")
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), Position = UDim2.new(0, 4, 0, 2), BackgroundTransparency = 1, Text = "Ambil pack benih lewat kasir atau rak berisi benih. Toko juga membeli hasil panenmu.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, tokoPanel)
local tokoBuy = mk("Frame", { Size = UDim2.new(1, -8, 0, 64), Position = UDim2.new(0, 4, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan) }, tokoPanel)
round(tokoBuy)
local tokoSell = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -112), Position = UDim2.new(0, 4, 0, 106), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tokoPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tokoSell)

local jualDim = mk("Frame", { Name = "ModalJual", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Visible = false, Active = true }, gui)
local jualBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0.88, 0, 0, 252), BackgroundColor3 = warna(UIStyle.Latar), Active = true }, jualDim)
round(jualBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(280, 220), MaxSize = Vector2.new(420, 340) }, jualBox)
local jualTitle = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "Atur Jual", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, jualBox)
local jualInfo = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, 44), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, jualBox)
local jualQty = mk("TextBox", { Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, 94), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "1", PlaceholderText = "Tulis jumlah yang dijual", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = false }, jualBox)
round(jualQty, UIStyle.SudutKecil)
local jualBaris = mk("Frame", { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 140), BackgroundTransparency = 1 }, jualBox)
        mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, jualBaris)
        IkonKoin.buat(jualBaris, 20).LayoutOrder = 1
        local jualPreview = mk("TextLabel", { LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, jualBaris)
local jualYa = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0, 12, 1, -54), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Ya, Jual", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, jualBox)
round(jualYa, UIStyle.SudutKecil)
local jualBatal = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0.5, 9, 1, -54), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Batal", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, jualBox)
round(jualBatal, UIStyle.SudutKecil)

local jualAktif: { id: string, mode: string, maks: number, unit: number }? = nil

local function perbaruiJual()
        local a = jualAktif
        if not a then
                return
        end
        local n = JualLogic.saring(jualQty.Text, a.maks)
        if n then
                jualPreview.Text = "Jual " .. tostring(n) .. " — total " .. fmt(JualLogic.total(a.unit, n)) .. " Micda"
        else
                jualPreview.Text = "Tulis jumlah 1 sampai " .. tostring(a.maks)
        end
end

local function bukaJual(s: any, mode: string)
        local info = CropData.byId[s.id]
        if not info or s.count < 1 then
                return
        end
        jualAktif = { id = s.id, mode = mode, maks = s.count, unit = info.jual }
        jualTitle.Text = mode == "atur" and "Atur Jual" or "Jual Semua"
        jualInfo.Text = UIStyle.potong(info.nama, 24) .. " x" .. tostring(s.count) .. " — " .. tostring(info.jual) .. " Micda/unit"
        jualQty.Visible = mode == "atur"
        jualQty.Text = mode == "atur" and "1" or tostring(s.count)
        perbaruiJual()
        jualDim.Visible = true
end

jualQty:GetPropertyChangedSignal("Text"):Connect(perbaruiJual)
jualBatal.Activated:Connect(function()
        jualAktif = nil
        jualDim.Visible = false
end)
jualYa.Activated:Connect(function()
        local a = jualAktif
        if not a then
                return
        end
        local n = JualLogic.saring(jualQty.Text, a.maks)
        if a.mode == "atur" then
                if not n then
                        return
                end
        else
                n = a.maks
        end
        jualAktif = nil
        jualDim.Visible = false
        task.spawn(function()
                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", a.id, n)
                toast(ok and "Terjual" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end)
end)

local function refreshToko()
        bersihkan(tokoSell)
        local order = 0
        for _, s in ipairs(TasLogic.ringkas(state.tas, "hasil")) do
                order += 1
                local info = CropData.byId[s.id]
                local holder = actionBtn(tokoSell, (info and info.nama or s.id) .. " x" .. s.count .. " — " .. (info and info.jual or 0) .. " Micda/unit", order)
                subBtn(holder, "Atur Jual", 0, 0.34, warna(UIStyle.Hijau), function()
                        bukaJual(s, "atur")
                end)
                subBtn(holder, "Jual Semua", 0.34, 0.33, warna(UIStyle.Hijau), function()
                        bukaJual(s, "semua")
                end)
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen untuk dijual.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, tokoSell)
        end
end

local modalDim = mk("Frame", { Name = "ModalBeli", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Visible = false, Active = true }, gui)
local modalBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0.88, 0, 0, 268), BackgroundColor3 = warna(UIStyle.Latar), Active = true }, modalDim)
round(modalBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(280, 240), MaxSize = Vector2.new(420, 360) }, modalBox)
local modalTitle = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "Konfirmasi Pembelian", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, modalBox)
local modalIsi = mk("Frame", { Size = UDim2.new(1, -24, 1, -110), Position = UDim2.new(0, 12, 0, 46), BackgroundTransparency = 1 }, modalBox)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, modalIsi)
local modalYa = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0, 12, 1, -54), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Ya, Beli", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, modalBox)
round(modalYa, UIStyle.SudutKecil)
local modalBatal = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0.5, 9, 1, -54), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Batal", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, modalBox)
round(modalBatal, UIStyle.SudutKecil)
local modalOke = mk("TextButton", { Size = UDim2.new(1, -24, 0, 42), Position = UDim2.new(0, 12, 1, -54), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Oke", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), Visible = false }, modalBox)
round(modalOke, UIStyle.SudutKecil)

local konfirmPackId: string? = nil

local function bersihkanModalIsi()
        for _, c in ipairs(modalIsi:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then
                        c:Destroy()
                end
        end
end

local function tutupModal()
        konfirmPackId = nil
        modalDim.Visible = false
end

local function aturModalTombol(mode: string)
        modalYa.Visible = mode == "konfirmasi"
        modalBatal.Visible = mode == "konfirmasi"
        modalOke.Visible = mode == "struk"
end

local function bukaStrukBeli(rows: { any }, total: number)
        bersihkanModalIsi()
        modalTitle.Text = "Pembelian Berhasil"
        local urutan = 0
        for _, r in ipairs(rows) do
                urutan += 1
                local baris = mk("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan) }, modalIsi)
                round(baris, UIStyle.SudutKecil)
                ikonSlot(baris, { kind = "benih", id = r.id, count = r.count })
                mk("TextLabel", { Size = UDim2.new(1, -100, 0, 36), Position = UDim2.new(0, 42, 0, 0), BackgroundTransparency = 1, Text = UIStyle.potong(r.nama), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, baris)
                mk("TextLabel", { Size = UDim2.new(0, 52, 0, 36), Position = UDim2.new(1, -56, 0, 0), BackgroundTransparency = 1, Text = "x" .. tostring(r.count), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, baris)
                local skala = mk("UIScale", { Scale = 0.01 }, baris)
                task.delay(0.07 * urutan, function()
                        if baris.Parent then
                                TweenService:Create(skala, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
                        end
                end)
        end
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Total " .. fmt(total) .. " Micda · benih sudah masuk tas", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, modalIsi)
        aturModalTombol("struk")
        modalDim.Visible = true
end

local function bukaKonfirmasiBeli(packId: string)
        local pack = CropData.Packs[packId]
        if not pack then
                return
        end
        bersihkanModalIsi()
        konfirmPackId = packId
        modalTitle.Text = "Konfirmasi Pembelian"
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Pack " .. (packId == "rare" and "Rare" or "Common"), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1 }, modalIsi)
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = tostring(pack.count) .. " benih acak kategori " .. packId, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2 }, modalIsi)
        local hargaRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 3 }, modalIsi)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, hargaRow)
IkonKoin.buat(hargaRow, 20).LayoutOrder = 1
mk("TextLabel", { LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "Harga: " .. fmt(pack.price) .. " Micda", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, hargaRow)
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "Ya = benih langsung dirapatkan server dan masuk tas.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, LayoutOrder = 4 }, modalIsi)
        aturModalTombol("konfirmasi")
        modalDim.Visible = true
end

modalBatal.Activated:Connect(tutupModal)
modalOke.Activated:Connect(tutupModal)
modalYa.Activated:Connect(function()
        local packId = konfirmPackId
        if not packId then
                return
        end
        tutupModal()
        task.spawn(function()
                local ok, msg, struk = Net.get("ShopAct"):InvokeServer("buy", packId)
                local pack = CropData.Packs[packId]
                if ok and type(struk) == "table" and pack then
                        syncState()
                        bukaStrukBeli(struk, pack.price)
                else
                        toast(ok and "Pembelian" or "Gagal", tostring(msg))
                end
        end)
end)

bukaStrukKlaim = function(s: any)
        bersihkanModalIsi()
        modalTitle.Text = "Semai Tuntas - Hasil Diklaim"
        local urutan = 0
        local function baris(ikonData: any?, teks: string, kanan: string)
                urutan += 1
                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan) }, modalIsi)
                round(row, UIStyle.SudutKecil)
                if ikonData then
                        ikonSlot(row, ikonData)
                else
                        local m = IkonKoin.buat(row, 28)
                        m.Position = UDim2.new(0, 6, 0, 4)
                end
                mk("TextLabel", { Size = UDim2.new(1, -100, 0, 36), Position = UDim2.new(0, 42, 0, 0), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                mk("TextLabel", { Size = UDim2.new(0, 52, 0, 36), Position = UDim2.new(1, -56, 0, 0), BackgroundTransparency = 1, Text = kanan, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, row)
                local skala = mk("UIScale", { Scale = 0.01 }, row)
                task.delay(0.07 * urutan, function()
                        if row.Parent then
                                TweenService:Create(skala, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
                        end
                end)
        end
        baris(nil, "+" .. fmt(s.micda or 0) .. " Micda", "Micda")
        if (s.benih or 0) > 0 then
                baris({ kind = "benih", id = s.crop, count = s.benih }, "Benih " .. UIStyle.potong(s.nama, 18), "x" .. tostring(s.benih))
        end
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Hasil dari " .. tostring(s.jumlah) .. " x " .. UIStyle.potong(s.nama, 14) .. " (" .. tostring(s.pukulan) .. " pukulan) — semua masuk tas", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, modalIsi)
        aturModalTombol("struk")
        modalDim.Visible = true
end

local function buyBtn(parent: Frame, text: string, posX: number, packId: string)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 6, 0, 8), Size = UDim2.new(0.5, -18, 1, -16), BackgroundColor3 = warna(UIStyle.Hijau), Text = text, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), TextWrapped = true }, parent)
        round(btn, UIStyle.SudutKecil)
        btn.Activated:Connect(function()
                bukaKonfirmasiBeli(packId)
        end)
end

buyBtn(tokoBuy, "Pack Common\n2.400 Micda (3 benih)", 0, "common")
buyBtn(tokoBuy, "Pack Rare\n9.000 Micda (3 benih)", 0.5, "rare")

local tanamPanel = makePanel("tanam")
local tamuMode = false

local tamuNotice = mk("TextLabel", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, Text = "Hanya pemilik dunia yang bisa memakai papan ini.", TextWrapped = true, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Abu), Visible = false }, tanamPanel)

local tabRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, tanamPanel)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tabRow)

local function tabBtn(teks: string, order: number): (TextButton, Frame)
        local b = mk("TextButton", { Size = UDim2.new(1 / 3, -8, 1, 0), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Abu), LayoutOrder = order }, tabRow)
        local garis = mk("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -1), Size = UDim2.new(0.7, 0, 0, 2), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0, Visible = false }, b)
        return b, garis
end

local tabTanamBtn, garisTanam = tabBtn("Tanam", 1)
local tabGabungBtn, garisGabung = tabBtn("Combine Seed", 2)
local tabStatusBtn, garisStatus = tabBtn("Status", 3)

local tanamBody = mk("Frame", { Size = UDim2.new(1, 0, 1, -42), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1 }, tanamPanel)

local tanamTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true }, tanamBody)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tanamTab)
local kepalaTanam = mk("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1 }, tanamTab)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }, kepalaTanam)
mk("TextLabel", { Size = UDim2.new(0.55, 0, 1, 0), BackgroundTransparency = 1, Text = "Pilih benih untuk ditanam", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1 }, kepalaTanam)
local jumlahLabel = mk("TextLabel", { Size = UDim2.new(0.45, -4, 1, 0), BackgroundTransparency = 1, Text = "Jumlah: -", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 2 }, kepalaTanam)
local tanamList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -118), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), LayoutOrder = 2 }, tanamTab)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tanamList)
mk("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow }, tanamList)
local tanamFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 3 }, tanamTab)

local angkaRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 4 }, tanamTab)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, angkaRow)
local selectedSeed: string? = nil
local selectedQty: number? = 10
local angkaPilih: { TextButton } = {}
local refreshTanam: () -> ()

local function tombolAngka(teks: string, order: number, nilai: number?): TextButton
        local b = mk("TextButton", { Size = UDim2.new(1 / 6, -6, 1, 0), BackgroundColor3 = warna(UIStyle.Permukaan), Text = teks, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = order }, angkaRow)
        round(b, UIStyle.SudutKecil)
        b.Activated:Connect(function()
                selectedQty = nilai
                refreshTanam()
        end)
        return b
end

local tombolMaks = tombolAngka("Maks", 6, nil)
for i, n in ipairs({ 1, 10, 50, 100, 250 }) do
        angkaPilih[i] = tombolAngka(tostring(n), i + 1, n)
end

local mulaiBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Mulai Tanam", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 5 }, tanamTab)
round(mulaiBtn)

local soalView = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tanamBody)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, soalView)
mk("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, soalView)
local progresRow = mk("Frame", { Size = UDim2.new(1, -20, 0, 22), BackgroundTransparency = 1, LayoutOrder = 1 }, soalView)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, progresRow)
local progresBar = mk("Frame", { Size = UDim2.new(0.62, -10, 1, -6), BackgroundColor3 = warna(UIStyle.PermukaanAktif), LayoutOrder = 1 }, progresRow)
round(progresBar, 5)
local progresIsi = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, progresBar)
round(progresIsi, 5)
local progresTeks = mk("TextLabel", { Size = UDim2.new(0.38, -10, 1, 0), BackgroundTransparency = 1, Text = "0/0", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2 }, progresRow)
local soalTeks = mk("TextLabel", { Size = UDim2.new(1, -20, 0, 58), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "?", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 2 }, soalView)
round(soalTeks)
local soalJawab = mk("TextBox", { Size = UDim2.new(1, -20, 0, 44), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", PlaceholderText = "Tulis jawaban angka", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = true, LayoutOrder = 3 }, soalView)
round(soalJawab, UIStyle.SudutKecil)
local soalSkala = mk("UIScale", { Scale = 1 }, soalJawab)
local soalBtn = mk("TextButton", { Size = UDim2.new(1, -20, 0, 44), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Jawab", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 4 }, soalView)
round(soalBtn)
local batalBtn = mk("TextButton", { Size = UDim2.new(1, -20, 0, 44), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "Batalkan Sesi Tanam", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Merah), LayoutOrder = 5 }, soalView)
round(batalBtn, UIStyle.SudutKecil)

local gabungTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "Benih A", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)
local slotAList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 64), Position = UDim2.new(0, 0, 0, 18), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gabungTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, slotAList)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 0, 88), BackgroundTransparency = 1, Text = "Benih B", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)
local slotBList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 64), Position = UDim2.new(0, 0, 0, 106), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gabungTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, slotBList)
local slotA: string? = nil
local slotB: string? = nil
local gabungBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 1, -52), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Gabung", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, gabungTab)
round(gabungBtn)
local gabungFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 1, -14), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, gabungTab)

local statusTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
local statusSummary = mk("TextLabel", { Size = UDim2.new(1, -100, 0, 26), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, statusTab)
local statusRefresh = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 92, 0, 26), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Perbarui", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, statusTab)
round(statusRefresh, UIStyle.SudutKecil)
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), Position = UDim2.new(0, 2, 0, 27), BackgroundTransparency = 1, Text = "Ambil hasil panen segera dan jangan biarkan tergeletak terlalu lama karena bisa hilang!", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Kuning), TextXAlignment = Enum.TextXAlignment.Left }, statusTab)
local statusList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -94), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, statusTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, statusList)

local tabAktif = "tanam"

local function muatStatus()
        task.spawn(function()
                local ok, res = Net.get("TanamAct"):InvokeServer("status")
                if not ok or type(res) ~= "table" then
                        return
                end
                statusSummary.Text = "Tertanam " .. tostring(res.tertanamTotal or 0) .. "/" .. tostring(res.plotTotal or 500)
                bersihkan(statusList)
                local daftar = res.status or {}
                if #daftar == 0 then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 36), BackgroundTransparency = 1, Text = "Belum ada tanaman di lahan.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, statusList)
                        return
                end
                local order = 0
                for _, row in ipairs(daftar) do
                        order += 1
                        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = order }, statusList)
                        round(holder, UIStyle.SudutKecil)
                        mk("TextLabel", { Size = UDim2.new(0.4, -8, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(row.nama or row.id), TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, holder)
                        mk("TextLabel", { Size = UDim2.new(0.32, -8, 1, -8), Position = UDim2.new(0.4, 8, 0, 4), BackgroundTransparency = 1, Text = "Siap " .. tostring(row.siap or 0), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                        mk("TextLabel", { Size = UDim2.new(0.28, -8, 1, -8), Position = UDim2.new(0.72, 8, 0, 4), BackgroundTransparency = 1, Text = "Tumbuh " .. tostring(row.tumbuh or 0), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                end
        end)
end

local function refreshGabung()
        for _, col in ipairs({ slotAList, slotBList }) do
                bersihkan(col)
        end
        local order = 0
        for _, s in ipairs(TasLogic.ringkas(state.tas, "benih")) do
                order += 1
                local info = CropData.byId[s.id]
                local nama = info and info.nama or s.id
                local pilihA = mk("TextButton", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = warna(s.id == slotA and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, slotAList)
                round(pilihA, UIStyle.SudutKecil)
                if s.id == slotA then
                        mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, pilihA)
                end
                mk("TextLabel", { Size = UDim2.new(0.68, -8, 1, -8), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong("Benih " .. nama), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, pilihA)
                mk("TextLabel", { Size = UDim2.new(0.24, -8, 1, -8), Position = UDim2.new(0.68, 8, 0, 4), BackgroundTransparency = 1, Text = "x" .. s.count, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, pilihA)
                pilihA.Activated:Connect(function()
                        slotA = s.id
                        refreshGabung()
                end)
                local pilihB = mk("TextButton", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = warna(s.id == slotB and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, slotBList)
                round(pilihB, UIStyle.SudutKecil)
                if s.id == slotB then
                        mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, pilihB)
                end
                mk("TextLabel", { Size = UDim2.new(0.68, -8, 1, -8), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong("Benih " .. nama), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, pilihB)
                mk("TextLabel", { Size = UDim2.new(0.24, -8, 1, -8), Position = UDim2.new(0.68, 8, 0, 4), BackgroundTransparency = 1, Text = "x" .. s.count, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, pilihB)
                pilihB.Activated:Connect(function()
                        slotB = s.id
                        refreshGabung()
                end)
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Tidak ada benih di tas.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, slotAList)
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Tidak ada benih di tas.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, slotBList)
        end
end

local function setTab(nama: string)
        tabAktif = nama
        bersihkan(tanamList)
        bersihkan(statusList)
        bersihkan(slotAList)
        bersihkan(slotBList)
        tanamTab.Visible = nama == "tanam"
        soalView.Visible = false
        gabungTab.Visible = nama == "gabung"
        statusTab.Visible = nama == "status"
        tabTanamBtn.TextColor3 = warna(nama == "tanam" and UIStyle.Teks or UIStyle.Abu)
        tabGabungBtn.TextColor3 = warna(nama == "gabung" and UIStyle.Teks or UIStyle.Abu)
        tabStatusBtn.TextColor3 = warna(nama == "status" and UIStyle.Teks or UIStyle.Abu)
        garisTanam.Visible = nama == "tanam"
        garisGabung.Visible = nama == "gabung"
        garisStatus.Visible = nama == "status"
        if nama == "status" then
                muatStatus()
        elseif nama == "gabung" then
                refreshGabung()
        else
                refreshTanam()
        end
end

refreshTanam = function()
        tabRow.Visible = not tamuMode
        tanamBody.Visible = not tamuMode
        tamuNotice.Visible = tamuMode
        if tamuMode then
                return
        end
        local t = state.tanam or {}
        local aktif = t.aktif == true
        tanamTab.Visible = not aktif
        soalView.Visible = aktif
        local benihAda = selectedSeed and tasTotal("benih", selectedSeed) or 0
        jumlahLabel.Text = selectedQty and ("Jumlah: " .. tostring(selectedQty)) or ("Jumlah: Maks (" .. tostring(benihAda) .. ")")
        for i, n in ipairs({ 1, 10, 50, 100, 250 }) do
                angkaPilih[i].BackgroundColor3 = warna(selectedQty == n and UIStyle.PermukaanAktif or UIStyle.Permukaan)
        end
        tombolMaks.BackgroundColor3 = warna(selectedQty == nil and UIStyle.PermukaanAktif or UIStyle.Permukaan)
        if aktif then
                local nomor = t.soal and t.soal.nomor or math.min(math.floor((t.tertanam or 0) / 10) + 1, t.totalSoal or 1)
                local total = t.totalSoal or 1
                progresTeks.Text = tostring(nomor) .. "/" .. tostring(total)
                progresIsi.Size = UDim2.fromScale(math.clamp((t.tertanam or 0) / math.max(1, t.jumlah or 1), 0, 1), 1)
                if t.soal then
                        soalTeks.Text = t.soal.teks
                end
        else
                tanamFeedback.Text = ""
        end
        bersihkan(tanamList)
        local order = 0
        for _, s in ipairs(TasLogic.ringkas(state.tas, "benih")) do
                order += 1
                local info = CropData.byId[s.id]
                local row = mk("TextButton", { Size = UDim2.new(1, -8, 0, 40), BackgroundColor3 = warna(s.id == selectedSeed and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, tanamList)
                round(row, UIStyle.SudutKecil)
                if s.id == selectedSeed then
                        mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, row)
                end
                mk("TextLabel", { Size = UDim2.new(0.66, -8, 1, -8), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(info and ("Benih " .. info.nama) or s.id), TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                mk("TextLabel", { Size = UDim2.new(0.26, -8, 1, -8), Position = UDim2.new(0.66, 8, 0, 4), BackgroundTransparency = 1, Text = "x" .. s.count, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, row)
                row.Activated:Connect(function()
                        selectedSeed = s.id
                        refreshTanam()
                end)
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 36), BackgroundTransparency = 1, Text = "Tidak ada benih di tas. Beli pack benih di Toko Benih, Pusat Kota.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, tanamList)
        end
end

mulaiBtn.Activated:Connect(function()
        if not selectedSeed then
                tanamFeedback.TextColor3 = warna(UIStyle.Merah)
                tanamFeedback.Text = "Pilih benih dulu di daftar."
                return
        end
        local jumlah = selectedQty
        if jumlah == nil then
                jumlah = selectedSeed and tasTotal("benih", selectedSeed) or 0
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("start", selectedSeed, jumlah)
        if ok then
                tanamFeedback.Text = ""
                refreshTanam()
        else
                tanamFeedback.TextColor3 = warna(UIStyle.Merah)
                tanamFeedback.Text = tostring(msg)
        end
end)

local function goyangJawab()
        soalJawab.BackgroundColor3 = warna(UIStyle.Merah)
        soalSkala.Scale = 0.96
        task.delay(0.12, function()
                soalSkala.Scale = 1.02
        end)
        task.delay(0.24, function()
                soalSkala.Scale = 1
        end)
        task.delay(0.55, function()
                soalJawab.BackgroundColor3 = warna(UIStyle.Permukaan)
        end)
end

soalBtn.Activated:Connect(function()
        local n = tonumber(soalJawab.Text)
        if not n then
                goyangJawab()
                return
        end
        local folderSebelum: { [number]: boolean } = {}
        local folder = state.zone == "dunia" and state.lahan and folderTanaman() or nil
        if folder then
                for _, m in ipairs(folder:GetChildren()) do
                        if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                                local idx = m:GetAttribute("PlotIdx")
                                if type(idx) == "number" then
                                        folderSebelum[idx] = true
                                end
                        end
                end
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("jawab", n)
        if ok then
                soalJawab.Text = ""
                if tostring(msg) ~= "" then
                        toastSaja(tostring(msg))
                end
                efekTanamanBaru(folderSebelum)
        else
                goyangJawab()
        end
end)

batalBtn.Activated:Connect(function()
        local ok, msg = Net.get("TanamAct"):InvokeServer("batal")
        if ok then
                state.tanam = nil
                toastSaja(tostring(msg))
                refreshTanam()
        end
end)

gabungBtn.Activated:Connect(function()
        if not slotA or not slotB then
                gabungFeedback.TextColor3 = warna(UIStyle.Merah)
                gabungFeedback.Text = "Pilih benih untuk kedua slot."
                return
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("gabung", slotA, slotB)
        gabungFeedback.TextColor3 = warna(ok and UIStyle.Aksen or UIStyle.Merah)
        gabungFeedback.Text = msg
        if ok then
                refreshGabung()
        end
end)

statusRefresh.Activated:Connect(function()
        muatStatus()
end)

tabTanamBtn.Activated:Connect(function()
        setTab("tanam")
end)
tabGabungBtn.Activated:Connect(function()
        setTab("gabung")
end)
tabStatusBtn.Activated:Connect(function()
        setTab("status")
end)

local gudangPanel = makePanel("gudang")
local gudangTampungan = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, gudangPanel)
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 16), Position = UDim2.new(0, 4, 0, 24), BackgroundTransparency = 1, Text = "Kiri: setor hasil panen. Kanan: ambil dari gudang.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, gudangPanel)
local gudangLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -10, 1, -52), Position = UDim2.new(0, 4, 0, 46), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gudangPanel)
local gudangRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -10, 1, -52), Position = UDim2.new(0.5, 6, 0, 46), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gudangPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, gudangLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, gudangRight)

local function refreshGudang()
        local g = state.gudang
        if not g then
                return
        end
        gudangTampungan.Text = "Tampungan: " .. tostring(g.terpakai) .. "/" .. tostring(g.maks) .. " — 1-250 buah = 1 tampungan"
        for _, col in ipairs({ gudangLeft, gudangRight }) do
                bersihkan(col)
        end
        local order = 0
        for _, s in ipairs(TasLogic.ringkas(state.tas, "hasil")) do
                order += 1
                local info = CropData.byId[s.id]
                local holder = actionBtn(gudangLeft, (info and info.nama or s.id) .. " x" .. s.count, order)
                subBtn(holder, "Setor 250", 0, 0.5, warna(UIStyle.Hijau), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("simpan", s.id, 250)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
                subBtn(holder, "Setor Semua", 0.5, 0.5, warna(UIStyle.PermukaanAktif), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("simpan", s.id)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas untuk disimpan.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, gudangLeft)
        end
        local order2 = 0
        for _, slot in ipairs(g.slots or {}) do
                order2 += 1
                local info = CropData.byId[slot.id]
                local holder = actionBtn(gudangRight, "Slot " .. slot.i .. ": " .. (info and info.nama or slot.id) .. " x" .. slot.count, order2)
                subBtn(holder, "Ambil Semua", 0, 0.5, warna(UIStyle.Hijau), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("ambil", slot.i)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
                subBtn(holder, "Ambil 100", 0.5, 0.5, warna(UIStyle.PermukaanAktif), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("ambil", slot.i, 100)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
        end
        if order2 == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Gudang masih kosong.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, gudangRight)
        end
end

tasBtn.Activated:Connect(function()
        if currentPanel == "tas" then
                closePanel()
                return
        end
        openPanel("tas")
        refreshTas()
end)

local punchTarget: number? = nil
local animT0: number? = nil
local motorKanan: Motor6D? = nil
local motorKiri: Motor6D? = nil
local punchSisi = 1
local punchSisiAktif = 1
local shakeT0: number? = nil
local pegangPunch = false
local punchN, punchT = 0, 0
local punchTier = 1

local highlight = Instance.new("Highlight")
highlight.FillColor = warna(UIStyle.Aksen)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.78
highlight.OutlineTransparency = 0.2
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local function cariModelTanaman(induk: Instance): Model?
        local m = induk
        while m and m.Parent do
                if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                        return m :: Model
                end
                m = m.Parent
        end
        return nil
end

local function kandidat(folder: Folder): { any }
        local daftar = {}
        for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                        local pos = m:GetPivot().Position
                        table.insert(daftar, { idx = m:GetAttribute("PlotIdx"), pos = { x = pos.X, y = 0, z = pos.Z }, radius = ArahPukul.Radius })
                end
        end
        return daftar
end

local function cariMotor(kanan: boolean): Motor6D?
        local char = player.Character
        if not char then
                return nil
        end
        local m = char:FindFirstChild(kanan and "RightShoulder" or "LeftShoulder", true)
        if not m then
                m = char:FindFirstChild(kanan and "Right Shoulder" or "Left Shoulder", true)
        end
        if m and m:IsA("Motor6D") then
                return m :: Motor6D
        end
        return nil
end

local function resetMotor(m: Motor6D?)
        if m and m.Parent then
                m.Transform = CFrame.new()
        end
end

local function posisiTangan(kanan: boolean): Vector3?
        local char = player.Character
        if not char then
                return nil
        end
        for _, n in ipairs(kanan and { "RightHand", "Right Arm" } or { "LeftHand", "Left Arm" }) do
                local p = char:FindFirstChild(n)
                if p and p:IsA("BasePart") then
                        return (p :: BasePart).Position
                end
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
                return (root :: BasePart).Position
        end
        return nil
end

local function fxKilau(pos: Vector3, tier: number)
        local bola = Instance.new("Part")
        bola.Shape = Enum.PartType.Ball
        bola.Material = Enum.Material.Neon
        bola.Color = warna(UIStyle.Kuning)
        bola.Size = Vector3.one * (0.9 + 0.4 * tier)
        bola.CFrame = CFrame.new(pos)
        bola.Anchored = true
        bola.CanCollide = false
        bola.CanQuery = false
        bola.CanTouch = false
        bola.Parent = Workspace
        local tw = TweenService:Create(bola, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * (2.6 + 1.4 * tier), Transparency = 1 })
        tw.Completed:Connect(function()
                bola:Destroy()
        end)
        tw:Play()
end

local function fxSabetan(dari: Vector3, ke: Vector3, tier: number)
        local v = ke - dari
        local pan = v.Magnitude
        if pan < 0.5 then
                return
        end
        local garis = Instance.new("Part")
        garis.Material = Enum.Material.Neon
        garis.Color = Color3.fromRGB(255, 244, 214)
        garis.Size = Vector3.new(0.26 + 0.08 * tier, 0.26 + 0.08 * tier, pan)
        garis.CFrame = CFrame.lookAt((dari + ke) / 2, ke)
        garis.Anchored = true
        garis.CanCollide = false
        garis.CanQuery = false
        garis.CanTouch = false
        garis.Transparency = 0.35
        garis.Parent = Workspace
        local tw = TweenService:Create(garis, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
        tw.Completed:Connect(function()
                garis:Destroy()
        end)
        tw:Play()
end

task.spawn(function()
        while true do
                task.wait(0.1)
                local idxBaru: number? = nil
                local modelBaru: Model? = nil
                if state.zone == "dunia" and state.lahan then
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        local folder = folderTanaman()
                        if root and folder then
                                local asal = (root.CFrame * CFrame.new(0, 0.8, 0)).Position
                                local arah = root.CFrame.LookVector
                                local params = RaycastParams.new()
                                params.FilterType = Enum.RaycastFilterType.Include
                                params.FilterDescendantsInstances = { folder }
                                local ray = Workspace:Raycast(asal, arah * ArahPukul.Jangkauan, params)
                                if ray then
                                        modelBaru = cariModelTanaman(ray.Instance)
                                        if modelBaru then
                                                idxBaru = modelBaru:GetAttribute("PlotIdx") :: number?
                                        end
                                end
                                if not modelBaru then
                                        local arahXZ = { x = arah.X, y = 0, z = arah.Z }
                                        local pilih = ArahPukul.pilih({ x = asal.X, y = 0, z = asal.Z }, arahXZ, kandidat(folder))
                                        if pilih and type(pilih.idx) == "number" then
                                                idxBaru = pilih.idx
                                                modelBaru = folder:FindFirstChild("Tanaman_" .. tostring(pilih.idx))
                                        end
                                end
                        end
                end
                punchTarget = idxBaru
                highlight.Parent = modelBaru
        end
end)

RunService:BindToRenderStep("DuniaPunchAnim", Enum.RenderPriority.Character.Value + 1, function()
        local t = os.clock()
        if shakeT0 and t - shakeT0 < 0.09 then
                local g = PukulAnim.getar(punchTier)
                camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad((math.random() - 0.5) * 2 * g))
        end
        if animT0 == nil then
                return
        end
        local f = PukulAnim.fase(animT0, t)
        if not f.memukul then
                resetMotor(motorKanan)
                resetMotor(motorKiri)
                motorKanan, motorKiri = nil, nil
                animT0 = nil
                return
        end
        if motorKanan == nil or motorKanan.Parent == nil then
                motorKanan = cariMotor(true)
        end
        if motorKiri == nil or motorKiri.Parent == nil then
                motorKiri = cariMotor(false)
        end
        local aktif = punchSisiAktif == 1 and motorKanan or motorKiri
        local nonaktif = punchSisiAktif == 1 and motorKiri or motorKanan
        resetMotor(nonaktif)
        if aktif then
                if aktif.Name == "Right Shoulder" then
                        aktif.Transform = CFrame.Angles(0, 0, -f.sudut)
                elseif aktif.Name == "Left Shoulder" then
                        aktif.Transform = CFrame.Angles(0, 0, f.sudut)
                elseif aktif.Name == "LeftShoulder" then
                        aktif.Transform = CFrame.Angles(f.sudut, 0, 0)
                else
                        aktif.Transform = CFrame.Angles(-f.sudut, 0, 0)
                end
        end
end)

local function eksekusiPunch()
        local t = os.clock()
        animT0 = t
        punchSisiAktif = punchSisi
        punchSisi = punchSisi == 1 and 2 or 1
        if t - punchT <= 4 then
                punchN += 1
        else
                punchN = 1
        end
        punchT = t
        punchTier = punchN >= 8 and 3 or (punchN >= 4 and 2 or 1)
        shakeT0 = t
        task.spawn(function()
                local awal = camera.FieldOfView
                camera.FieldOfView = awal + 3 + 2 * punchTier
                task.wait(0.09)
                camera.FieldOfView = awal
        end)
        local target = punchTarget
        local kanan = punchSisiAktif == 1
        task.delay(PukulAnim.MomenKena, function()
                local folder = state.zone == "dunia" and state.lahan and folderTanaman() or nil
                local titik: Vector3? = nil
                if folder and type(target) == "number" then
                        local m = folder:FindFirstChild("Tanaman_" .. tostring(target))
                        if m and m:IsA("Model") then
                                titik = m:GetPivot().Position + Vector3.new(0, 1.1, 0)
                        end
                end
                local asal = posisiTangan(kanan)
                if titik and asal then
                        fxSabetan(asal, titik, punchTier)
                        fxKilau(titik, punchTier)
                end
                pcall(function()
                        Net.get("PlotAct"):InvokeServer(target, "punch")
                end)
        end)
end

punchBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if input.UserInputState ~= Enum.UserInputState.Begin or pegangPunch then
                        return
                end
                pegangPunch = true
                efekTekan(true)
                eksekusiPunch()
                task.spawn(function()
                        while pegangPunch and punchBtn.Parent do
                                task.wait(PukulAnim.Ulang)
                                if pegangPunch then
                                        eksekusiPunch()
                                end
                        end
                end)
        end
end)

punchBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                pegangPunch = false
                efekTekan(false)
        end
end)

Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = bersihkanTasClient(payload.tas)
        renderSaldo()
        if payload.zone then
                state.zone = payload.zone
                state.dunia = payload.dunia
                state.lahan = payload.lahan
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                        travelBtn.Text = "Pulang ke Kota"
                else
                        zonaLabel.Text = "Pusat Kota"
                        travelBtn.Text = "Masuk Dunia-ku"
                end
        end
        refreshTas()
        if currentPanel == "semai" then
                refreshSemai()
        elseif currentPanel == "toko" then
                refreshToko()
        elseif currentPanel == "tanam" then
                if tabAktif == "gabung" then
                        refreshGabung()
                elseif tabAktif ~= "status" then
                        refreshTanam()
                end
        elseif currentPanel == "gudang" then
                refreshGudang()
        end
end)

Net.get("Notify").OnClientEvent:Connect(function(title, msg)
        toast(tostring(title), tostring(msg))
end)

Net.get("SemaiSync").OnClientEvent:Connect(function(p)
        if p.lahan == state.lahan then
                state.semai = p
                if currentPanel == "semai" then
                        refreshSemai()
                end
                if p.tahap == "tuntas" then
                        toast("Semai Tuntas", "Mesin selesai menggiling! Klaim hasilmu di mesin semai.")
                end
        end
end)

Net.get("TanamSync").OnClientEvent:Connect(function(p)
        state.tanam = p
        if currentPanel == "tanam" and tabAktif == "tanam" then
                refreshTanam()
        end
        if p and p.selesaiTuntas == true and currentPanel == "tanam" then
                closePanel()
        end
end)

Net.get("GudangSync").OnClientEvent:Connect(function(p)
        state.gudang = p
        if currentPanel == "gudang" then
                refreshGudang()
        end
end)

Net.get("OpenPanel").OnClientEvent:Connect(function(name, payload)
        if name == "semai" then
                openPanel("semai")
                refreshSemai()
        elseif name == "toko" then
                openPanel("toko")
                refreshToko()
        elseif name == "gerbang" then
                openPanel("gerbang")
        elseif name == "tanam" then
                tamuMode = payload ~= nil and payload.tamu == true
                openPanel("tanam")
                setTab("tanam")
        elseif name == "gudang" then
                openPanel("gudang")
                refreshGudang()
        end
end)

task.spawn(function()
        local st = Net.get("GetState"):InvokeServer()
        if st then
                state.micda = st.micda or 0
                state.tas = bersihkanTasClient(st.tas)
                state.lahan = st.lahan
                state.zone = st.zone or "kota"
                state.dunia = st.dunia
                state.role = st.role or "hub"
                renderSaldo()
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                        travelBtn.Text = "Pulang ke Kota"
                else
                        zonaLabel.Text = "Pusat Kota"
                        travelBtn.Text = "Masuk Dunia-ku"
                end
                refreshTas()
        end
end)

print("[AKIOMIDA] UI siap.")

return true

		end)()
		return MOD_UIController
	else
		return MOD_UIController
	end
end
local function LOAD_UI() return LOAD_UIController() end

local function RUN_init_server()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UangLogic = MOD_UangLogic
local Net = MOD_Remotes

local Modules = script.Modules
local DevCodeVault = MOD_DevCodeVault
local RateLimit = MOD_RateLimit
local AuditService = MOD_AuditService
local DataService = MOD_DataService
local CurrencyService = MOD_CurrencyService
local TasService = MOD_TasService
local LandService = MOD_LandService
local PlotService = MOD_PlotService
local MesinSemaiService = MOD_MesinSemaiService
local ShopService = MOD_ShopService
local ZonaService = MOD_ZonaService
local TanamService = MOD_TanamService
local GudangService = MOD_GudangService
local DropService = MOD_DropService
local WorldBuilder = MOD_WorldBuilder

Net.init()

local function notify(player: Player, title: string, msg: string)
        Net.get("Notify"):FireClient(player, title, msg)
end

CurrencyService.bind({ Data = DataService, Audit = AuditService })
AuditService.bind({
        Data = DataService,
        Simpan = function(p: Player)
                DataService.markDirty(p)
                DataService.save(p)
        end,
})

local function denganTransaksi(player: Player, fn)
        AuditService.transaksiMulai(player)
        local ok, a, b, c = pcall(fn)
        AuditService.transaksiSelesai(player)
        if not ok then
                return false, "Terjadi galat. Coba lagi."
        end
        return a, b, c
end

local deps = {
        Land = LandService,
        Tas = TasService,
        Data = DataService,
        Uang = CurrencyService,
        Audit = AuditService,
        Net = Net,
        Notify = notify,
        Plot = PlotService,
        Mesin = MesinSemaiService,
        World = ZonaService,
        Tanam = TanamService,
        Gudang = GudangService,
        Drop = DropService,
}
TasService.bind(DataService)
PlotService.bind(deps)
MesinSemaiService.bind(deps)
ShopService.bind(deps)
ZonaService.bind(deps)
TanamService.bind(deps)
GudangService.bind(deps)
DropService.bind(deps)

local function openSemai(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Semai Panen", "Hanya pemilik dunia yang bisa memakai mesin ini.")
                return
        end
        MesinSemaiService.syncTo(player, lahanIdx)
        Net.get("OpenPanel"):FireClient(player, "semai", { lahan = lahanIdx })
end

local function openTanam(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                Net.get("OpenPanel"):FireClient(player, "tanam", { tamu = true })
                return
        end
        TanamService.syncTo(player)
        Net.get("OpenPanel"):FireClient(player, "tanam", {})
end

local function openGudang(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Gudang", "Hanya pemilik dunia yang bisa memakai gudang ini.")
                return
        end
        GudangService.syncTo(player, lahanIdx)
        Net.get("OpenPanel"):FireClient(player, "gudang", {})
end

local function openShop(player: Player)
        if not ShopService.near(player, 45) then
                notify(player, "Toko Benih", "Dekati kasir atau rak benih dulu.")
                return
        end
        Net.get("OpenPanel"):FireClient(player, "toko", {})
end

local hooks = {
        onSemaiPrompt = openSemai,
        onTuasPrompt = function(player: Player, _lahanIdx: number, sisi: string)
                local ok, msg = MesinSemaiService.tekan(player, sisi)
                if not ok then
                        notify(player, "Mesin Semai", tostring(msg))
                end
        end,
        onShopPrompt = openShop,
        onGerbangDunia = function(player: Player)
                Net.get("OpenPanel"):FireClient(player, "gerbang", {})
        end,
        onPulang = function(player: Player)
                ZonaService.pulang(player)
        end,
        onPapanPrompt = openTanam,
        onGudangPrompt = openGudang,
        registerMesin = MesinSemaiService.registerMesin,
        setShopPoint = ShopService.setShopPoint,
        registerBoard = function(index: number, label: TextLabel, pos: Vector3)
                PlotService.setBoard(index, label)
                TanamService.setPoint(index, pos)
        end,
        setGudangPoint = GudangService.setPoint,
        registerKota = LandService.registerKota,
        registerUmum = LandService.registerUmum,
}
ZonaService.setHooks(hooks)
DataService.setZoneProvider(ZonaService.zoneOf)
DataService.setLahanProvider(LandService.landOf)

WorldBuilder.buildHub(hooks)

local function applySpawn(player: Player)
        local target = LandService.kotaSpawn() or LandService.umumSpawn()
        if target then
                player.RespawnLocation = target
        end
end

local function enterServer(player: Player)
        local ok, alasan, dibuang = DataService.load(player)
        local d = DataService.get(player)
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local micda = Instance.new("IntValue")
        micda.Name = "Micda"
        micda.Value = d and UangLogic.saldo(d.u) or 0
        micda.Parent = leaderstats
        leaderstats.Parent = player
        applySpawn(player)
        DataService.push(player)
        task.delay(4, function()
                if player.Parent then
                        if dibuang and dibuang > 0 then
                                notify(player, "Tas Dibersihkan", tostring(dibuang) .. " item lama yang tidak dipakai sudah dibuang otomatis dari tas.")
                        end
                        if ok then
                                notify(player, "Pusat Kota", "Selamat datang! Lewati Gerbang Dunia atau tombol Masuk untuk ke duniamu.")
                        elseif alasan == "kunci" then
                                AuditService.catat(player, "sesi_ganda", "load")
                                notify(player, "Mode Sesi", "Akunmu sedang aktif di server lain. Progres di sini tidak tersimpan.")
                        else
                                notify(player, "Mode Sesi", "Progres sementara hanya tersimpan di sesi ini.")
                        end
                end
        end)
end

local function onPlayerAdded(player: Player)
        enterServer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, p)
end

local function tutupSesi(player: Player)
        TanamService.leave(player)
        ZonaService.leaveGame(player)
        DataService.save(player)
        RateLimit.clear(player.UserId)
        AuditService.bersih(player.UserId)
        DataService.drop(player)
end

Players.PlayerRemoving:Connect(tutupSesi)

game:BindToClose(function()
        ZonaService.shutdown()
        for _, p in ipairs(Players:GetPlayers()) do
                tutupSesi(p)
        end
end)

local function lajuDitolak(player: Player, kunci: string)
        AuditService.catat(player, "laju", kunci)
        return false, "Terlalu cepat."
end

Net.get("GetState").OnServerInvoke = function(player)
        local d = DataService.get(player)
        if not d then
                return nil
        end
        local zone, dunia = ZonaService.zoneOf(player)
        local lahan = LandService.landOf(player)
        local role = "hub"
        if zone == "dunia" then
                role = lahan and "pemilik" or "tamu"
        end
        return {
                micda = UangLogic.saldo(d.u),
                tas = d.t,
                lahan = lahan,
                zone = zone,
                role = role,
                dunia = dunia,
        }
end

Net.get("DuniaAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "dunia", 2, 3) then
                return lajuDitolak(player, "dunia")
        end
        if action == "masuk" then
                return ZonaService.masuk(player)
        elseif action == "kunjungi" then
                if type(arg) ~= "string" then
                        AuditService.catat(player, "argumen", "kunjungi")
                        return false, "Nama tidak sah."
                end
                return ZonaService.visit(player, arg)
        elseif action == "pulang" then
                return ZonaService.pulang(player)
        end
        AuditService.catat(player, "argumen", "dunia:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("PlotAct").OnServerInvoke = function(player, idx, action)
        if not RateLimit.allow(player.UserId, "punch", 12, 18) then
                return lajuDitolak(player, "punch")
        end
        if action == "punch" then
                return denganTransaksi(player, function()
                        return PlotService.punch(player, idx)
                end)
        end
        AuditService.catat(player, "argumen", "plot:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("TanamAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "tanam", 6, 10) then
                return lajuDitolak(player, "tanam")
        end
        if action == "start" then
                return denganTransaksi(player, function()
                        return TanamService.start(player, a, b)
                end)
        elseif action == "jawab" then
                return denganTransaksi(player, function()
                        return TanamService.jawab(player, a)
                end)
        elseif action == "gabung" then
                return denganTransaksi(player, function()
                        return TanamService.gabung(player, a, b)
                end)
        elseif action == "status" then
                return true, TanamService.statusPayload(player)
        elseif action == "batal" then
                return TanamService.batal(player)
        end
        AuditService.catat(player, "argumen", "tanam:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("GudangAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "gudang", 6, 10) then
                return lajuDitolak(player, "gudang")
        end
        if action == "simpan" then
                return denganTransaksi(player, function()
                        return GudangService.simpan(player, a, b)
                end)
        elseif action == "ambil" then
                return denganTransaksi(player, function()
                        return GudangService.ambil(player, a, b)
                end)
        end
        AuditService.catat(player, "argumen", "gudang:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("SemaiAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "semai", 8, 12) then
                return lajuDitolak(player, "semai")
        end
        local deny = ZonaService.mutationDeny(player)
        if deny then
                return false, deny
        end
        if action == "atur" then
                return denganTransaksi(player, function()
                        return MesinSemaiService.atur(player, a, b)
                end)
        elseif action == "tuas" then
                return denganTransaksi(player, function()
                        return MesinSemaiService.tekan(player, a)
                end)
        elseif action == "klaim" then
                return denganTransaksi(player, function()
                        return MesinSemaiService.klaim(player)
                end)
        end
        AuditService.catat(player, "argumen", "semai:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("ShopAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "shop", 8, 14) then
                return lajuDitolak(player, "shop")
        end
        if action == "buy" then
                return denganTransaksi(player, function()
                        return ShopService.buy(player, a)
                end)
        elseif action == "sell" then
                return denganTransaksi(player, function()
                        return ShopService.sell(player, a, b)
                end)
        end
        AuditService.catat(player, "argumen", "shop:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("RedeemDevCode").OnServerInvoke = function(player, code)
        local d = DataService.get(player)
        if not d then
                return false, "Data belum siap."
        end
        if type(code) ~= "string" or code ~= DevCodeVault.CODE then
                AuditService.catat(player, "argumen", "kode_salah")
                return false, "Kode salah."
        end
        if d.dev then
                return false, "Kode sudah pernah dipakai."
        end
        d.dev = true
        DataService.markDirty(player)
        DataService.push(player)
        return true, "Status dev aktif. Terima kasih, pemilik dunia!"
end

DataService.startLoops()
ZonaService.startLoops()
CurrencyService.startIntegritas()

print("[AKIOMIDA] Server-authoritative: ekonomi 1000T, deteksi anomali tanpa batas angka tetap, transaksi terjaga, kick aman-data siap.")

end

local function RUN_init_client()
LOAD_UI()

end



local Services = Stub.Services
local Players = Services.Players
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage

local passed, failed = 0, 0
local function check(name, ok, detail)
        if ok then
                passed += 1
                print("  PASS  " .. name)
        else
                failed += 1
                print("  FAIL  " .. name .. (detail and ("  -> " .. detail) or ""))
        end
end

local function section(t)
        print("-- " .. t)
end

local function getRemote(name)
        local f = ReplicatedStorage:FindFirstChild("Remotes")
        return f and f:FindFirstChild(name)
end

local function serverCall(name, player, ...)
        local r = getRemote(name)
        if not r or not r.OnServerInvoke then
                return nil, "remote tidak siap"
        end
        return r.OnServerInvoke(player, ...)
end

local function findPrompts(root)
        local out = {}
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                        table.insert(out, d)
                end
        end
        return out
end

local function firePrompt(root, match, player)
        for _, p in ipairs(findPrompts(root)) do
                local okA = not match.action or p.ActionText == match.action
                local okO = not match.object or p.ObjectText == match.object
                if okA and okO then
                        p.Triggered:Fire(player)
                        return true
                end
        end
        return false
end

local function findGui(root, class, textMatch)
        if not root then
                return nil
        end
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA(class) and d.Text and (not textMatch or string.find(d.Text, textMatch, 1, true)) then
                        return d
                end
        end
        return nil
end

local function findTextBoxByPlaceholder(root, placeholder)
        if not root then
                return nil
        end
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextBox") and d.PlaceholderText == placeholder then
                        return d
                end
        end
        return nil
end

local function findSoalTeks(root)
        if not root then
                return nil
        end
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and string.match(d.Text, "^%d+ [%+%-%*x] %d+ = %?$") then
                        return d
                end
        end
        return nil
end

local function pilihBenih(root, nama)
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "" then
                        for _, c in ipairs(d:GetChildren()) do
                                if c:IsA("TextLabel") and c.Text and string.find(c.Text, nama, 1, true) then
                                        d.Activated:Fire()
                                        return true
                                end
                        end
                end
        end
        return false
end

local function jawabSoal(gui)
        local soalTeks = findSoalTeks(gui)
        if not soalTeks then
                return false, "soal hilang"
        end
        local teks = soalTeks.Text
        local a, op, b = string.match(teks, "^(%d+) (.+) (%d+) = %?$")
        local hasil
        if op == "+" then
                hasil = tonumber(a) + tonumber(b)
        elseif op == "-" then
                hasil = tonumber(a) - tonumber(b)
        elseif op == "*" or op == "x" then
                hasil = tonumber(a) * tonumber(b)
        else
                return false, "operator tak dikenal: " .. tostring(op)
        end
        local box = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
        if not box then
                return false, "kotak jawaban hilang"
        end
        box.Text = tostring(hasil)
        local btn = findGui(gui, "TextButton", "Jawab")
        if not btn then
                return false, "tombol jawab hilang"
        end
        btn.Activated:Fire()
        return true, tostring(hasil)
end

local function countClass(root, class)
        local n = 0
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA(class) then
                        n += 1
                end
        end
        return n
end

local function rootOf(p)
        local c = p.Character
        return c and c:FindFirstChild("HumanoidRootPart")
end

local function moveTo(p, x, y, z)
        local r = rootOf(p)
        if r then
                r.CFrame = CFrame.new(x, y, z)
        end
end

local function burn(t)
        local tgt = os.clock() + t
        while os.clock() < tgt do
        end
end

local function tasCount(player, kind, id)
        local st = serverCall("GetState", player)
        if not st then
                return -1
        end
        local n = 0
        for _, s in ipairs(st.tas) do
                if s.kind == kind and s.id == id then
                        n += s.count
                end
        end
        return n
end

print("=== PLAYTEST DUNIA AKIOMIDA (revisi final tanam-panen) ===")
Stub.Scheduler.advance(0.05)

section("Booting server")
script = Stub.serverScript()
RUN_init_server()
Stub.Scheduler.advance(0.2)

local dunia = Workspace:FindFirstChild("Dunia")
check("Workspace.Dunia dibuat saat boot", dunia ~= nil)

local modelNames = {}
if dunia then
        for _, d in ipairs(dunia:GetDescendants()) do
                if d:IsA("Model") then
                        table.insert(modelNames, d.Name)
                end
        end
        table.sort(modelNames)
end
check("Pusat kota hanya punya satu bangunan: TokoBenih", #modelNames == 1 and modelNames[1] == "TokoBenih", table.concat(modelNames, ","))

local teksTerlarang = {}
if dunia then
        for _, d in ipairs(dunia:GetDescendants()) do
                if d:IsA("TextLabel") and type(d.Text) == "string" then
                        local t = string.lower(d.Text)
                        if string.find(t, "panduan") or string.find(t, "dekati papan") or string.find(t, "tanam lewat") or string.find(t, "setor 1-250") or string.find(t, "pukul hasil") then
                                table.insert(teksTerlarang, d.Text)
                        end
                end
        end
end
check("Tidak ada teks instruksi tanam-panen di dunia", #teksTerlarang == 0, table.concat(teksTerlarang, " | "))
check("Tidak ada BillboardGui / teks melayang di dunia", countClass(dunia, "BillboardGui") == 0, tostring(countClass(dunia, "BillboardGui")))

section("Pemain utama masuk")
local profStore = Stub.Services.DataStoreService:GetDataStore("AKM_T1")
profStore.__data["u_1001"] = {
        m = 10000,
        t = {
                { kind = "benih", id = "wortel", count = 25 },
                { kind = "benih", id = "pisang", count = 2 },
                { kind = "benih", id = "jeruk_mandarin", count = 2 },
                { kind = "benih", id = "grapefruit", count = 2 },
                { kind = "benih", id = "bayam", count = 10 },
                { kind = "hasil", id = "wortel", count = 10 },
                { kind = "hasil", id = "pisang", count = 250 },
        },
        dev = false,
}
local P1 = Stub.addPlayer(1001, "akiomida")
Stub.giveCharacter(P1, 0, 6, 44)
Players.PlayerAdded:Fire(P1)
Stub.Scheduler.advance(0.5)

local ls = P1:FindFirstChild("leaderstats")
check("leaderstats Micda dibuat", ls ~= nil and ls:FindFirstChild("Micda") ~= nil)
check("Micda awal pemain 10.000", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 10000, tostring(ls and ls:FindFirstChild("Micda").Value))

section("Booting UI klien")
local pg = Instance.new("Folder")
pg.Name = "PlayerGui"
pg.Parent = P1
__SIM_IS_SERVER = false
script = Stub.clientScript()
Stub.setLocalPlayer(P1)
RUN_init_client()
Stub.Scheduler.advance(0.2)

local gui = pg:FindFirstChild("DuniaAkiomida")
check("GUI utama dibuat (UI benar-benar dimuat)", gui ~= nil)

local punchUI = gui:FindFirstChild("TombolPunch")
check("Tombol punch permanen ada di layar (ikon, tanpa tulisan)", punchUI ~= nil and punchUI:IsA("TextButton") and punchUI.Text == "" and punchUI.Visible == true, punchUI and tostring(punchUI.Text) or "hilang")

section("HUD saldo: singkatan Indonesia + ketuk angka penuh")
local saldoHUD = gui:FindFirstChild("SaldoHUD", true)
check("Kotak saldo ada dan bisa diketuk (TextButton)", saldoHUD ~= nil and saldoHUD:IsA("TextButton"), saldoHUD and saldoHUD.ClassName or "hilang")
check("Kotak saldo melebar otomatis (AutomaticSize X)", saldoHUD ~= nil and saldoHUD.AutomaticSize == Enum.AutomaticSize.X, saldoHUD and tostring(saldoHUD.AutomaticSize))
check("Ikon koin emas di HUD, tanpa huruf M", saldoHUD ~= nil and saldoHUD:FindFirstChild("IkonKoin", true) ~= nil and (function()
        for _, d in ipairs(saldoHUD:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text == "M" then
                        return false
                end
        end
        return true
end)(), "-")
local angkaHUD = saldoHUD and saldoHUD:FindFirstChild("SaldoAngka")
local satuanHUD = saldoHUD and saldoHUD:FindFirstChild("SaldoSatuan")
check("Teks angka satu baris (TextWrapped = false)", angkaHUD ~= nil and angkaHUD.TextWrapped == false, angkaHUD and tostring(angkaHUD.TextWrapped) or "hilang")
check("Saldo awal tampil singkat 10 Rb", angkaHUD ~= nil and angkaHUD.Text == "10 Rb", angkaHUD and angkaHUD.Text or "hilang")
check("Satuan Micda tampil di mode singkat", satuanHUD ~= nil and satuanHUD.Visible == true, "-")
if saldoHUD then
        saldoHUD.Activated:Fire()
        Stub.Scheduler.advance(0.05)
end
check("Ketuk 1: angka lengkap bertitik 10.000", angkaHUD ~= nil and angkaHUD.Text == "10.000", angkaHUD and angkaHUD.Text or "hilang")
check("Satuan Micda disembunyikan di mode penuh (hemat lebar)", satuanHUD ~= nil and satuanHUD.Visible == false, "-")
if saldoHUD then
        saldoHUD.Activated:Fire()
        Stub.Scheduler.advance(0.05)
end
check("Ketuk 2: kembali ke singkatan 10 Rb", angkaHUD ~= nil and angkaHUD.Text == "10 Rb", angkaHUD and angkaHUD.Text or "hilang")
check("Satuan Micda kembali tampil", satuanHUD ~= nil and satuanHUD.Visible == true, "-")
if angkaHUD then
        angkaHUD.Text = MOD_UangSingkat.singkat(1000000000000000)
end
check("Atap 1000 Triliun tampil 1.000 T", angkaHUD ~= nil and angkaHUD.Text == "1.000 T", angkaHUD and angkaHUD.Text or "hilang")
if angkaHUD then
        angkaHUD.Text = MOD_UangSingkat.singkat(250500000000)
end
check("Contoh pemilik 250,5 M tampil benar", angkaHUD ~= nil and angkaHUD.Text == "250,5 M", angkaHUD and angkaHUD.Text or "hilang")

local popupPlot = findGui(gui, "TextLabel", "Plot Tanam")
check("Tidak ada popup Plot Tanam", popupPlot == nil, popupPlot and popupPlot.Text or "-")
local instruksiGabung = findGui(gui, "TextLabel", "gabung benih terjadi")
check("Tidak ada teks instruksi gabung di panel tas", instruksiGabung == nil, instruksiGabung and instruksiGabung.Text or "-")

section("Toko Benih: konfirmasi dulu, struk kemudian")
moveTo(P1, 8, 4, -46)
local kasirFired = firePrompt(dunia, { object = "Kasir" }, P1)
check("Prompt kasir toko bisa dipicu", kasirFired)
Stub.Scheduler.advance(0.1)
local buyCommon = findGui(gui, "TextButton", "Pack Common")
check("Tombol beli Pack Common tampil", buyCommon ~= nil)
if buyCommon then
        buyCommon.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Popup konfirmasi muncul (tidak langsung beli)", (function()
        local m = gui:FindFirstChild("ModalBeli")
        return m ~= nil and m.Visible == true and findGui(gui, "TextLabel", "Konfirmasi Pembelian") ~= nil
end)(), "-")
check("Isi pack & harga tampil di konfirmasi", findGui(gui, "TextLabel", "3 benih acak") ~= nil and findGui(gui, "TextLabel", "Harga: 2.400 Micda") ~= nil, "-")
check("Micda belum terpotong sebelum Ya", ls and ls:FindFirstChild("Micda").Value == 10000, tostring(ls and ls:FindFirstChild("Micda").Value))
local batalBtn = (function()
        local m = gui:FindFirstChild("ModalBeli")
        return m and findGui(m, "TextButton", "Batal") or nil
end)()
check("Tombol Batal tersedia", batalBtn ~= nil)
if batalBtn then
        batalBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Batal = konfirmasi hilang & saldo utuh", (function()
        local m = gui:FindFirstChild("ModalBeli")
        return m ~= nil and m.Visible == false and ls and ls:FindFirstChild("Micda").Value == 10000
end)(), "-")
if buyCommon then
        buyCommon.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local yaBtn = (function()
        local m = gui:FindFirstChild("ModalBeli")
        return m and findGui(m, "TextButton", "Ya, Beli") or nil
end)()
check("Tombol Ya, Beli tersedia", yaBtn ~= nil)
if yaBtn then
        yaBtn.Activated:Fire()
        Stub.Scheduler.advance(0.2)
end
local micdaAfterBuy = ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value
check("Beli setelah Ya (10.000 - 2.400 = 7.600)", micdaAfterBuy == 7600, tostring(micdaAfterBuy))
check("Popup struk isi benih muncul", findGui(gui, "TextLabel", "Pembelian Berhasil") ~= nil, "-")
check("Struk memuat daftar benih & total", findGui(gui, "TextLabel", "Total 2.400 Micda") ~= nil and (function()
        local m = gui:FindFirstChild("ModalBeli")
        if not m then
                return false
        end
        for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("TextLabel") and string.match(d.Text, "^x%d+$") then
                        return true
                end
        end
        return false
end)(), "-")
local okeBtn = (function()
        local m = gui:FindFirstChild("ModalBeli")
        return m and findGui(m, "TextButton", "Oke") or nil
end)()
check("Tombol Oke struk tersedia", okeBtn ~= nil)
if okeBtn then
        okeBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Struk tertutup setelah Oke", (function()
        local m = gui:FindFirstChild("ModalBeli")
        return m ~= nil and m.Visible == false
end)(), "-")
check("3 benih acak masuk tas", tasCount(P1, "benih", "wortel") >= 25 and (function()
        local st = serverCall("GetState", P1)
        local n = 0
        for _, s in ipairs(st.tas) do
                if s.kind == "benih" then
                        n += s.count
                end
        end
        return n == 41 + 3
end)(), "-")

section("Gerbang Dunia: masuk ke lahan lewat UI")
moveTo(P1, 0, 5, 20)
firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
local dimKota = gui:FindFirstChild("DimLayar")
check("Pop up Gerbang Dunia terbuka", dimKota ~= nil and dimKota.Visible == true, dimKota and tostring(dimKota.Visible) or "DimLayar hilang")
local masukBtn = dimKota and findGui(dimKota, "TextButton", "Masuk Dunia-ku")
check("Tombol Masuk Dunia-ku tampil di panel", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
check("Pop up gerbang langsung hilang setelah pilih", dimKota ~= nil and dimKota.Visible == false, dimKota and tostring(dimKota.Visible) or "-")
local r1 = rootOf(P1)
check("Pemain terbangun instan di dunia lahan (X > 5000)", r1 and r1.Position.X > 5000, r1 and tostring(r1.Position) or "tanpa karakter")
local st = serverCall("GetState", P1)
check("Zona aktif = dunia milik sendiri", st and st.zone == "dunia" and st.role == "pemilik", st and (st.zone .. "/" .. tostring(st.role)) or "tidak ada state")

section("Grid plot di dunia lahan")
local grid = dunia and dunia:FindFirstChild("PlotGrid_1", true)
check("PlotGrid_1 dibuat di dunia lahan", grid ~= nil)
check("Jumlah plot 500", grid and #grid:GetChildren() == 500, grid and tostring(#grid:GetChildren()) or "-")

section("Papan Tanam: panel 3 tab terbuka")
moveTo(P1, 5085, 5, 18)
local papanFired = firePrompt(dunia, { object = "Papan Tanam" }, P1)
check("Prompt Papan Tanam bisa dipicu", papanFired)
Stub.Scheduler.advance(0.1)
check("Judul panel Papan Tanam tampil", findGui(gui, "TextLabel", "Papan Tanam") ~= nil, "-")
check("Tab Tanam ada", findGui(gui, "TextButton", "Tanam") ~= nil, "-")
check("Tab Combine Seed ada", findGui(gui, "TextButton", "Combine Seed") ~= nil, "-")
check("Tab Status ada", findGui(gui, "TextButton", "Status") ~= nil, "-")
check("Panel punya safe area atas (UIPadding >= 48)", (function()
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("UIPadding") and d.PaddingTop and d.PaddingTop.Offset and d.PaddingTop.Offset >= 48 then
                        return true
                end
        end
        return false
end)(), "-")
check("Panel berbasis skala + batas ukuran (UISizeConstraint)", (function()
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("UISizeConstraint") then
                        return true
                end
        end
        return false
end)(), "-")
check("Tombol angka 1/50/100/250/Maks tampil di tab Tanam", findGui(gui, "TextButton", "1") ~= nil and findGui(gui, "TextButton", "50") ~= nil and findGui(gui, "TextButton", "100") ~= nil and findGui(gui, "TextButton", "250") ~= nil and findGui(gui, "TextButton", "Maks") ~= nil, "-")
check("Tab Combine: tombol Gabung tersembunyi saat tab Tanam", (function()
        local g = findGui(gui, "TextButton", "Gabung")
        while g and g.Parent do
                if g.Visible == false then
                        return true
                end
                g = g.Parent
        end
        return false
end)(), "-")
local tabGabungUI = findGui(gui, "TextButton", "Combine Seed")
if tabGabungUI then
        tabGabungUI.Activated:Fire()
        Stub.Scheduler.advance(0.05)
end
check("Tab Combine: baris Benih A & B tampil", findGui(gui, "TextLabel", "Benih A") ~= nil and findGui(gui, "TextLabel", "Benih B") ~= nil, "-")
check("Tab Combine: Mulai Tanam tersembunyi", (function()
        local m = findGui(gui, "TextButton", "Mulai Tanam")
        while m and m.Parent do
                if m.Visible == false then
                        return true
                end
                m = m.Parent
        end
        return false
end)(), "-")
local tabTanamUI
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") and d.Text == "Tanam" then
                tabTanamUI = d
                break
        end
end
if tabTanamUI then
        tabTanamUI.Activated:Fire()
        Stub.Scheduler.advance(0.05)
end
check("Kembali ke tab Tanam: Mulai Tanam tampil lagi (daftar segar)", (function()
        local m = findGui(gui, "TextButton", "Mulai Tanam")
        while m and m.Parent do
                if m.Visible == false then
                        return false
                end
                m = m.Parent
        end
        return m ~= nil
end)(), "-")

section("Tanam lewat papan: 10 plot per soal, salah tertahan")
check("Pilih benih Wortel di daftar (klik baris)", pilihBenih(gui, "Wortel"), "-")
local angka10 = findGui(gui, "TextButton", "10")
check("Tombol angka 10 tampil", angka10 ~= nil)
if angka10 then
        angka10.Activated:Fire()
end
local mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
check("Tombol Mulai Tanam tampil", mulaiBtn ~= nil)
burn(1.2)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local soal1 = findSoalTeks(gui)
check("Soal matematika muncul di papan", soal1 ~= nil, soal1 and soal1.Text or "hilang")
check("Progres sederhana 1/1 tampil", findGui(gui, "TextLabel", "1/1") ~= nil, "-")
check("Teks gaya kuis 'Soal 1 dari' hilang", findGui(gui, "TextLabel", "Soal 1 dari") == nil, "-")
check("Tombol punch disembunyikan saat panel terbuka", gui:FindFirstChild("TombolPunch") ~= nil and gui:FindFirstChild("TombolPunch").Visible == false, "-")

local label0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Papan menampilkan TERTANAM 0/500 sebelum jawab", label0 ~= nil, "-")

if soal1 then
        local box = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
        box.Text = "999999"
        local jawabBtn = findGui(gui, "TextButton", "Jawab")
        jawabBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local boxSalah = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
local merah = Color3.fromRGB(178, 84, 72)
local warnaSalahOk = boxSalah ~= nil and math.abs(boxSalah.BackgroundColor3.r - merah.r) < 0.01 and math.abs(boxSalah.BackgroundColor3.g - merah.g) < 0.01 and math.abs(boxSalah.BackgroundColor3.b - merah.b) < 0.01
check("Jawaban salah: kolom memerah, tanpa kalimat kuis", warnaSalahOk and findGui(gui, "TextLabel", "Salah") == nil, boxSalah and tostring(boxSalah.BackgroundColor3) or "hilang")
local masih0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Jawaban salah tidak membuka plot", masih0 ~= nil, "-")
Stub.Scheduler.advance(0.7)
local boxPulih = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
local normal = Color3.fromRGB(32, 35, 42)
local warnaPulihOk = boxPulih ~= nil and math.abs(boxPulih.BackgroundColor3.r - normal.r) < 0.01 and math.abs(boxPulih.BackgroundColor3.g - normal.g) < 0.01 and math.abs(boxPulih.BackgroundColor3.b - normal.b) < 0.01
check("Kolom input pulih ke warna normal", warnaPulihOk, boxPulih and tostring(boxPulih.BackgroundColor3) or "hilang")

burn(1.2)
local okJ1, detJ1 = jawabSoal(gui)
Stub.Scheduler.advance(0.3)
check("Jawaban benar diterima server", okJ1 == true, tostring(detJ1))
check("Tanaman muncul dengan efek partikel singkat", countClass(Workspace, "ParticleEmitter") >= 1, tostring(countClass(Workspace, "ParticleEmitter")))
check("Tanaman muncul dengan suara pendek", countClass(Workspace, "Sound") >= 1, tostring(countClass(Workspace, "Sound")))
check("Toast netral '+10 Wortel' tampil", findGui(gui, "TextLabel", "+10 Wortel") ~= nil, "-")
local label10 = findGui(dunia, "TextLabel", "TERTANAM 10/500")
check("10 plot terisi setelah 1 soal benar", label10 ~= nil, label10 and label10.Text or "-")
check("Panel papan menutup sendiri setelah sesi selesai", gui:FindFirstChild("DimLayar") ~= nil and gui:FindFirstChild("DimLayar").Visible == false, "-")
check("Tombol punch tampil kembali setelah panel tutup", gui:FindFirstChild("TombolPunch") ~= nil and gui:FindFirstChild("TombolPunch").Visible == true, "-")
Stub.Scheduler.advance(2.0)
check("Toast hilang sendiri dalam 2 detik", findGui(gui, "TextLabel", "+10 Wortel") == nil, "-")
local t1 = grid and grid:FindFirstChild("Tanaman_0", true)
check("Tanaman_0 muncul di plot", t1 ~= nil, "-")
local adaBuah = false
if t1 then
        for _, d in ipairs(t1:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        adaBuah = true
                end
        end
end
check("Tanaman punya bagian buah (bentuk unik per jenis)", adaBuah, "-")
check("Benih wortel berkurang 10 (sisa 15)", tasCount(P1, "benih", "wortel") == 15, tostring(tasCount(P1, "benih", "wortel")))

section("Warna siap panen beda dari masih tumbuh")
Stub.Scheduler.advance(3.6)
local siapOk = false
if t1 then
        local tr, tg, tb = 232 / 255, 112 / 255, 44 / 255
        for _, d in ipairs(t1:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        if math.abs(d.Color.r - tr) < 0.02 and math.abs(d.Color.g - tg) < 0.02 and math.abs(d.Color.b - tb) < 0.02 then
                                siapOk = true
                        end
                end
        end
end
check("Buah berubah ke warna siap setelah matang", siapOk, "-")

section("Punch presisi: tombol PUNCH asli + drop bentuk tanaman")
burn(1.2)
moveTo(P1, 5013, 5, 38)
Stub.Scheduler.advance(0.25)
local tombolPunch = gui:FindFirstChild("TombolPunch")
check("Tombol punch bisa memukul tanaman di depan", tombolPunch ~= nil)
if tombolPunch then
        tombolPunch.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin })
        tombolPunch.InputEnded:Fire({ UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.End })
        Stub.Scheduler.advance(0.5)
end
local drops = dunia and dunia:FindFirstChild("Drops_1", true)
check("Tombol PUNCH memberi drop", drops ~= nil and #drops:GetChildren() >= 1, drops and tostring(#drops:GetChildren()) or "-")
local dropModel = drops and drops:GetChildren()[1]
local dropRoot = dropModel and dropModel:FindFirstChild("Hasil")
check("Drop berupa model tanaman Hasil_wortel (bukan kotak)", dropModel ~= nil and dropModel:IsA("Model") and dropModel.Name == "Hasil_wortel" and dropRoot ~= nil, dropModel and dropModel.Name or "-")
check("Drop wortel multi bagian sesuai bentuk", dropModel ~= nil and #dropModel:GetChildren() >= 3, dropModel and tostring(#dropModel:GetChildren()) or "-")
check("Drop berisi atribut server (DropId + LahanIdx)", dropRoot ~= nil and type(dropRoot:GetAttribute("DropId")) == "string" and dropRoot:GetAttribute("LahanIdx") == 1, dropRoot and tostring(dropRoot:GetAttribute("DropId")) or "-")
check("Warna drop = warna siap wortel", (function()
        if not dropRoot then
                return false
        end
        return math.abs(dropRoot.Color.r - 232 / 255) < 0.02 and math.abs(dropRoot.Color.g - 112 / 255) < 0.02 and math.abs(dropRoot.Color.b - 44 / 255) < 0.02
end)(), "-")
check("Drop tanpa label teks melayang", dropModel ~= nil and countClass(dropModel, "BillboardGui") == 0, "-")
local wortelHasilSebelum = tasCount(P1, "hasil", "wortel")
if dropRoot then
        dropRoot.Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(1)
end
local wortelHasilSesudah = tasCount(P1, "hasil", "wortel")
check("Drop masuk tas setelah disentuh", wortelHasilSesudah > wortelHasilSebelum, tostring(wortelHasilSebelum) .. " -> " .. tostring(wortelHasilSesudah))
moveTo(P1, 5019, 5, 38)
Stub.Scheduler.advance(0.15)
local okPunch, msgPunch = serverCall("PlotAct", P1, 1, "punch")
check("Punch presisi pindah sasaran tetap jalan", okPunch == true, tostring(msgPunch))
local dropsSisa = dunia and dunia:FindFirstChild("Drops_1", true)
local rootSisa = dropsSisa and dropsSisa:GetChildren()[1]
rootSisa = rootSisa and rootSisa:FindFirstChild("Hasil")
if rootSisa then
        rootSisa.Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(1)
end
check("Semua drop sudah dipungut (folder drop kembali kosong)", dropsSisa ~= nil and #dropsSisa:GetChildren() == 0, dropsSisa and tostring(#dropsSisa:GetChildren()) or "-")

section("Punch masih tumbuh: 5x beruntun hancur, tanpa drop")
moveTo(P1, 5085, 5, 18)
check("Pilih benih Bayam", pilihBenih(gui, "Bayam"), "-")
mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
burn(1.2)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
burn(1.2)
local okJ4, detJ4 = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
check("Sesi bayam: 1 soal benar -> TERTANAM 18/500", okJ4 == true and findGui(dunia, "TextLabel", "TERTANAM 18/500") ~= nil, tostring(detJ4))
check("Benih bayam habis (10)", tasCount(P1, "benih", "bayam") == 0, tostring(tasCount(P1, "benih", "bayam")))
local bayam1 = grid and grid:FindFirstChild("Tanaman_10", true)
check("Tanaman_10 (bayam) ada dan masih tumbuh", bayam1 ~= nil, "-")
moveTo(P1, 5073, 5, 38)
local okPg, msgPg
for _ = 1, 5 do
        burn(1.2)
        okPg, msgPg = serverCall("PlotAct", P1, 10, "punch")
        Stub.Scheduler.advance(0.4)
end
local bayamHilang = grid and grid:FindFirstChild("Tanaman_10", true) == nil
check("5x pukul menghancurkan tanaman tumbuh", bayamHilang, tostring(msgPg))
local dropsBayam = dunia and dunia:FindFirstChild("Drops_1", true)
check("Pukul tanaman tumbuh tidak memberi drop", dropsBayam ~= nil and #dropsBayam:GetChildren() == 0, dropsBayam and tostring(#dropsBayam:GetChildren()) or "-")

section("Drop tiap arketipe bentuk tanaman (8 jenis)")
local arketipe = {
        { "pisang", 491 },
        { "gandum", 492 },
        { "kedelai", 493 },
        { "labu_moschata", 494 },
        { "arachis_duranensis", 495 },
        { "jamur", 496 },
        { "tetsukabuto", 497 },
        { "bayam", 498 },
}
for _, a in ipairs(arketipe) do
        local okF = MOD_PlotService.fillPlot(1, a[2], a[1])
        check("Tanam langsung " .. a[1] .. " di plot " .. a[2], okF == true, tostring(okF))
end
Stub.Scheduler.advance(3.8)
for _, a in ipairs(arketipe) do
        local id, idx = a[1], a[2]
        local lx, lz = MOD_Layout.plotLocal(idx)
        moveTo(P1, 5000 + lx, 5, lz + 5)
        Stub.Scheduler.advance(0.4)
        local okP2, msgP2 = serverCall("PlotAct", P1, idx, "punch")
        local model = dunia and dunia:FindFirstChild("Hasil_" .. id, true)
        local rootP = model and model:FindFirstChild("Hasil")
        local b = MOD_CropData.Bentuk[id]
        check("Punch " .. id .. " memberi drop", okP2 == true and model ~= nil, tostring(msgP2))
        check("Drop " .. id .. " bentuk " .. b.jenis .. " (>= 2 bagian)", model ~= nil and #model:GetChildren() >= 2, model and tostring(#model:GetChildren()) or "-")
        check("Warna drop " .. id .. " = warna siap", (function()
                if not rootP then
                        return false
                end
                return math.abs(rootP.Color.r - b.siap[1] / 255) < 0.02 and math.abs(rootP.Color.g - b.siap[2] / 255) < 0.02 and math.abs(rootP.Color.b - b.siap[3] / 255) < 0.02
        end)(), "-")
        Stub.Scheduler.advance(0.4)
end

section("Combine Seed di papan: resep cocok, salah ditolak")
moveTo(P1, 5085, 5, 18)
burn(1.2)
local okG1, msgG1 = serverCall("TanamAct", P1, "gabung", "pisang", "wortel")
check("Kombinasi tanpa resep ditolak", okG1 == false and msgG1 == "Tidak bisa di-combine", tostring(okG1) .. "/" .. tostring(msgG1))
check("Benih tidak terpakai saat ditolak", tasCount(P1, "benih", "pisang") == 2, tostring(tasCount(P1, "benih", "pisang")))
burn(1.2)
local okG2, msgG2 = serverCall("TanamAct", P1, "gabung", "jeruk_mandarin", "grapefruit")
check("Jeruk mandarin + grapefruit = benih Tangelo", okG2 == true and string.find(tostring(msgG2), "Tangelo", 1, true) ~= nil, tostring(msgG2))
check("Bahan resep berkurang 1 masing-masing", tasCount(P1, "benih", "jeruk_mandarin") == 1 and tasCount(P1, "benih", "grapefruit") == 1, "-")
check("Benih hybrid masuk tas", tasCount(P1, "benih", "tangelo") == 1, tostring(tasCount(P1, "benih", "tangelo")))

section("Status papan: siap panen vs masih tumbuh")
burn(1.2)
local okS, resS = serverCall("TanamAct", P1, "status")
check("Status bisa diambil dari papan", okS == true and type(resS) == "table", tostring(okS))
check("Tertanam total 17 (20 tanam - 2 panen - 1 hancur)", resS and resS.tertanamTotal == 17, resS and tostring(resS.tertanamTotal) or "-")
local adaWortelRow, adaBayamRow = false, false
if resS and type(resS.status) == "table" then
        for _, row in ipairs(resS.status) do
                if row.id == "wortel" then
                        adaWortelRow = true
                end
                if row.id == "bayam" then
                        adaBayamRow = true
                end
        end
end
check("Status memuat baris wortel & bayam", adaWortelRow and adaBayamRow, "-")

section("Gudang: 250 per tampungan (999 lalu 998)")
burn(1.2)
moveTo(P1, 5205, 5, 181)
local okD1, msgD1 = serverCall("GudangAct", P1, "simpan", "pisang", 250)
check("Setor 250 pisang = 1 tampungan (sisa 999)", okD1 == true and string.find(tostring(msgD1), "999", 1, true) ~= nil, tostring(msgD1))
burn(1.2)
local okD2, msgD2 = serverCall("GudangAct", P1, "simpan", "wortel")
check("Setor sisanya = tampungan ke-2 (sisa 998)", okD2 == true and string.find(tostring(msgD2), "998", 1, true) ~= nil, tostring(msgD2))
burn(1.2)
local okA1, msgA1 = serverCall("GudangAct", P1, "ambil", 2)
check("Ambil kembali dari gudang", okA1 == true, tostring(msgA1))

section("Tamu berkunjung: papan kirim pemberitahuan tamu, aksi ditolak")
local P2 = Stub.addPlayer(2002, "tamu")
Stub.giveCharacter(P2, 0, 6, 44)
Players.PlayerAdded:Fire(P2)
Stub.Scheduler.advance(0.3)
burn(1.2)
local okV, msgV = serverCall("DuniaAct", P2, "kunjungi", "akiomida")
check("Tamu bisa berkunjung ke dunia akiomida", okV == true, tostring(msgV))
local r4 = rootOf(P2)
check("Tamu tiba di dunia lahan", r4 and r4.Position.X > 5000, r4 and tostring(r4.Position) or "-")
local tamuPayload = nil
Stub.setLocalPlayer(P2)
local connOpen = getRemote("OpenPanel").OnClientEvent:Connect(function(name, payload)
        if name == "tanam" then
                tamuPayload = payload
        end
end)
moveTo(P2, 5085, 5, 18)
firePrompt(dunia, { object = "Papan Tanam" }, P2)
Stub.Scheduler.advance(0.1)
connOpen:Disconnect()
Stub.setLocalPlayer(P1)
check("Papan kirim pemberitahuan tamu (tampil di dalam panel)", tamuPayload ~= nil and tamuPayload.tamu == true, tostring(tamuPayload and tamuPayload.tamu))
burn(1.2)
local okTamuTanam = serverCall("TanamAct", P2, "start", "pisang", 1)
check("Tamu tidak bisa mulai tanam", okTamuTanam == false, tostring(okTamuTanam))
burn(1.2)
moveTo(P2, 5013, 5, 38)
local okTamuPunch = serverCall("PlotAct", P2, 1, "punch")
check("Tamu tidak bisa punch tanaman orang lain", okTamuPunch == false, tostring(okTamuPunch))

section("Pulang ke kota lalu balik lagi ke lahan")
__SIM_IS_SERVER = true
Stub.setLocalPlayer(P1)
local zona = dunia and dunia:FindFirstChild("Zona_1", true)
local pulangFired = zona and firePrompt(zona, { action = "Pulang ke Kota" }, P1)
check("Gerbang pulang di lahan bisa dipicu", pulangFired == true)
Stub.Scheduler.advance(0.5)
local r2 = rootOf(P1)
check("Sampai pusat kota lagi", r2 and math.abs(r2.Position.X) < 3 and math.abs(r2.Position.Z - 44) < 4, r2 and tostring(r2.Position) or "-")
burn(1.2)
firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
local dimBalik = gui:FindFirstChild("DimLayar")
check("Panel gerbang terbuka lagi", dimBalik ~= nil and dimBalik.Visible == true, dimBalik and tostring(dimBalik.Visible) or "DimLayar hilang")
masukBtn = dimBalik and findGui(dimBalik, "TextButton", "Masuk Dunia-ku")
check("Panel gerbang terbuka lagi dengan tombol masuk", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.6)
end
check("Pop up gerbang tertutup lagi setelah balik dunia", dimBalik ~= nil and dimBalik.Visible == false, dimBalik and tostring(dimBalik.Visible) or "-")
local r3 = rootOf(P1)
check("BALIK ke dunia lahan sukses", r3 and r3.Position.X > 5000, r3 and tostring(r3.Position) or "-")
local labelBalik = findGui(dunia, "TextLabel", "TERTANAM 17/500")
check("Papan tetap menunjukkan progres terakhir (17/500)", labelBalik ~= nil, labelBalik and labelBalik.Text or "-")

section("Simpan data saat keluar")
Players.PlayerRemoving:Fire(P1)
Stub.Scheduler.advance(0.3)
local duniaStore = Stub.stores["AKM_Dunia"]
check("Dunia pemain tersimpan (d_1001)", duniaStore and duniaStore.__data["d_1001"] ~= nil)
local t1store = Stub.stores["AKM_T1"]
check("Profil pemain tersimpan (u_1001)", t1store and t1store.__data["u_1001"] ~= nil)

section("Bersih dari error runtime")
check("Tidak ada error runtime tersembunyi", #__SIM_ERRORS == 0, table.concat(__SIM_ERRORS, " | "))

print(string.format("HASIL PLAYTEST: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tahap playtest gagal", failed))
end
