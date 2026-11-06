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

UDim = {}
UDim.__index = UDim
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
        UserInputType = makeEnum("UserInputType", { "MouseButton1", "Touch", "Keyboard" }),
        RaycastFilterType = makeEnum("RaycastFilterType", { "Exclude", "Include" }),
        TextXAlignment = makeEnum("TextXAlignment", { "Left", "Center", "Right" }),
        TextYAlignment = makeEnum("TextYAlignment", { "Top", "Center", "Bottom" }),
        SortOrder = makeEnum("SortOrder", { "LayoutOrder", "Name", "Custom" }),
        AutomaticSize = makeEnum("AutomaticSize", { "None", "X", "Y", "XY" }),
        HorizontalAlignment = makeEnum("HorizontalAlignment", { "Left", "Center", "Right" }),
        VerticalAlignment = makeEnum("VerticalAlignment", { "Top", "Center", "Bottom" }),
}

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

        local Workspace = Instance.new("Workspace")
        local camera = Instance.new("Camera")
        camera.Name = "Camera"
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
        for _, n in ipairs({ "CropData", "Recipes", "TasLogic", "Layout", "DuniaLogic" }) do
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

        local UserInputService = Instance.new("UserInputService")

        local services = {
                Players = Players,
                Workspace = Workspace,
                ReplicatedStorage = ReplicatedStorage,
                DataStoreService = DataStoreService,
                RunService = RunService,
                UserInputService = UserInputService,
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
        for _, n in ipairs({ "LandService", "DataService", "SmashService", "PlotService", "ShopService", "WorldBuilder", "RateLimit", "DevCodeVault", "BuildingKit", "TasService", "ZonaService" }) do
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
local MOD_CropData = (function()
local CropData = {}

CropData.GrowTime = 3
CropData.StartMoney = 900000
CropData.TasSlots = 50
CropData.TasStack = 250
CropData.BlokId = "blok_panen"

CropData.Packs = {
	common = { price = 2400, count = 3 },
	rare = { price = 9000, count = 3 },
}

CropData.Yield = {
	common = { min = 1, max = 10 },
	rare = { min = 1, max = 6 },
	epic = { min = 1, max = 4 },
}

CropData.Smash = {
	common = { hits = 5, seed = 0.45, blok = 0.20, micdaMin = 1, micdaMax = 5 },
	rare = { hits = 10, seed = 0.30, blok = 0.15, micdaMin = 3, micdaMax = 9 },
	epic = { hits = 15, seed = 0.10, blok = 0.15, micdaMin = 9, micdaMax = 19 },
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

function Recipes.sameSpot(currentCrop: any, newCrop: any): string?
	if type(currentCrop) ~= "string" or type(newCrop) ~= "string" then
		return nil
	end
	if currentCrop == newCrop then
		return nil
	end
	return Recipes.find(currentCrop, newCrop)
end

function Recipes.matchList(newCrop: string, neighborCrops: { string }): (string?, string?)
        if type(newCrop) ~= "string" then
                return nil, nil
        end
        for _, other in ipairs(neighborCrops) do
                if type(other) == "string" then
                        local out = Recipes.find(newCrop, other)
                        if out then
                                return out, other
                        end
                end
        end
        return nil, nil
end

return Recipes

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

local MOD_DuniaLogic = (function()
local DuniaLogic = {}

DuniaLogic.SaveEvery = 60
DuniaLogic.MaxPlots = 500
DuniaLogic.MaxMeja = 6

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

function DuniaLogic.serPlots(planted: any): { [number]: { c: string, r: number } }
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
			out[idx] = { c = rec.crop, r = math.floor(rec.readyAt) }
		end
	end
	return out
end

function DuniaLogic.desPlots(arr: any): { [number]: { c: string, r: number } }
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
			out[idx] = { c = rec.c, r = math.floor(rec.r) }
		end
	end
	return out
end

function DuniaLogic.serMeja(slots: any): { { c: string, h: number } }
	local out = {}
	if type(slots) ~= "table" then
		return out
	end
	for i, s in ipairs(slots) do
		if #out >= DuniaLogic.MaxMeja then
			break
		end
		if type(s) == "table" and type(s.crop) == "string" and #s.crop <= 40 and type(s.hitsLeft) == "number" then
			table.insert(out, { c = s.crop, h = math.max(1, math.floor(s.hitsLeft)) })
		end
	end
	return out
end

function DuniaLogic.desMeja(arr: any): { { c: string, h: number } }
	local out = {}
	if type(arr) ~= "table" then
		return out
	end
	for _, s in ipairs(arr) do
		if #out >= DuniaLogic.MaxMeja then
			break
		end
		if type(s) == "table" and type(s.c) == "string" and #s.c <= 40 and type(s.h) == "number" then
			table.insert(out, { c = s.c, h = math.max(1, math.floor(s.h)) })
		end
	end
	return out
end

return DuniaLogic

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
        SmashSync = "RemoteEvent",
        OpenPanel = "RemoteEvent",
        GetState = "RemoteFunction",
        DuniaAct = "RemoteFunction",
        PlotAct = "RemoteFunction",
        SmashAct = "RemoteFunction",
        ShopAct = "RemoteFunction",
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
        textBoard(model, Vector3.new(0.3, 5, 8), CFrame.new(-19.2, 13, -2), "PANDUAN TANAM 3 DETIK", Enum.NormalId.Right)
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

        BuildingKit.part(model, Vector3.new(6.4, 2, 1), CFrame.new(0, 11, fz), CREAM)
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(-1.5, 5, fz), Vector3.new(-1.55, 0, 0), -math.rad(105))
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(1.5, 5, fz), Vector3.new(1.55, 0, 0), math.rad(105))

        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(-4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.lamp(model, -12, 21, 0)
        BuildingKit.lamp(model, 0, 21, 0)
        BuildingKit.lamp(model, 12, 21, 0)
        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

function BuildingKit.buildSemai(parent: Instance): Model
        local model = Instance.new("Model")
        model.Name = "SemaiPanen"
        local w, d = 30, 30
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 2, 1, d - 2), CFrame.new(0, 1.5, 0), FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(w, 20, 1), CFrame.new(0, 11, d / 2 - 0.5), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(-(w / 2 - 0.5), 11, 0), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(w / 2 - 0.5, 11, 0), CREAM)
        local fz = -(d / 2 - 0.5)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(-12.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(12.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(20, 9, 1), CFrame.new(0, 16.5, fz), CREAM)
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(2, 20, 2), CFrame.new(sx * 11, 11, -13.5), DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(2, 20, 2), CFrame.new(sx * 13, 11, 13), DARKWOOD, Enum.Material.Wood)
        end
        trim(model, w, d, 1.5)
        trim(model, w, d, 20.5)
        BuildingKit.gableRoof(model, w, d, 3, 21, BRICKRED)
        BuildingKit.part(model, Vector3.new(12, 4, 4), CFrame.new(0, 4, 2), DARKWOOD, Enum.Material.Wood)
        local pad = BuildingKit.part(model, Vector3.new(8, 0.4, 4), CFrame.new(0, 2.4, -6), BRICKRED, Enum.Material.SmoothPlastic, 0.3)
        pad.CanCollide = false
        BuildingKit.part(model, Vector3.new(20.4, 2, 1), CFrame.new(0, 11, fz), CREAM)
        hingedDoor(model, Vector3.new(10, 10, 0.5), CFrame.new(-5, 5, fz), Vector3.new(-5.05, 0, 0), -math.rad(105))
        hingedDoor(model, Vector3.new(10, 10, 0.5), CFrame.new(5, 5, fz), Vector3.new(5.05, 0, 0), math.rad(105))
        BuildingKit.lamp(model, -6, 21, 0)
        BuildingKit.lamp(model, 6, 21, 0)
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

local DataService = {}

local store = DataStoreService:GetDataStore("AKM_T1")
local cache: { [number]: any } = {}
local dirty: { [number]: boolean } = {}
local zoneProvider: ((Player) -> (string, string?))? = nil

local function defaultData()
        return { m = CropData.StartMoney, t = {}, dev = false }
end

function DataService.setZoneProvider(fn)
        zoneProvider = fn
end

local function push(player: Player)
        local d = cache[player.UserId]
        if not d then
                return
        end
        local payload: any = { micda = math.floor(d.m), tas = d.t }
        if zoneProvider then
                local z, dn = zoneProvider(player)
                payload.zone = z
                payload.dunia = dn
        end
        Net.get("Sync"):FireClient(player, payload)
        local ls = player:FindFirstChild("leaderstats")
        if ls then
                local v = ls:FindFirstChild("Micda")
                if v then
                        v.Value = math.floor(d.m)
                end
        end
end

function DataService.get(player: Player)
        return cache[player.UserId]
end

function DataService.markDirty(player: Player)
        dirty[player.UserId] = true
end

function DataService.push(player: Player)
        push(player)
end

function DataService.addMicda(player: Player, amount: number)
        local d = cache[player.UserId]
        if not d then
                return
        end
        d.m = math.max(0, d.m + amount)
        dirty[player.UserId] = true
        push(player)
end

function DataService.trySpend(player: Player, amount: number): boolean
        local d = cache[player.UserId]
        if not d then
                return false
        end
        if d.m < amount then
                return false
        end
        d.m -= amount
        dirty[player.UserId] = true
        push(player)
        return true
end

function DataService.load(player: Player): boolean
        local ok, data = pcall(function()
                return store:GetAsync("u_" .. player.UserId)
        end)
        if ok and type(data) == "table" and type(data.m) == "number" then
                cache[player.UserId] = {
                        m = data.m,
                        t = type(data.t) == "table" and data.t or {},
                        dev = data.dev == true,
                }
        elseif ok then
                cache[player.UserId] = defaultData()
        else
                cache[player.UserId] = defaultData()
                return false
        end
        dirty[player.UserId] = false
        push(player)
        return true
end

function DataService.save(player: Player)
        local d = cache[player.UserId]
        if not d or not dirty[player.UserId] then
                return
        end
        local ok = pcall(function()
                store:SetAsync("u_" .. player.UserId, { m = math.floor(d.m), t = d.t, dev = d.dev })
        end)
        if ok then
                dirty[player.UserId] = false
        end
end

function DataService.startLoops()
        task.spawn(function()
                while true do
                        task.wait(60)
                        for _, p in ipairs(Players:GetPlayers()) do
                                DataService.save(p)
                        end
                end
        end)
end

function DataService.drop(player: Player)
        cache[player.UserId] = nil
        dirty[player.UserId] = nil
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

local MOD_SmashService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData

local SmashService = {}

local Land, Tas, Data, Net, Notify, World
local rng = Random.new()

local MAX_SLOTS = 6
local tables: { [number]: Vector3 } = {}
local slots: { [number]: { any } } = {}
local hasilFolders: { [number]: Folder } = {}

local RARITY_COLOR = {
        common = Color3.fromRGB(96, 168, 74),
        rare = Color3.fromRGB(70, 128, 214),
        epic = Color3.fromRGB(168, 92, 224),
}
local RARITY_SIZE = {
        common = Vector3.new(2, 2, 2),
        rare = Vector3.new(2, 3, 2),
        epic = Vector3.new(3, 3, 3),
}

function SmashService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Data = deps.Data
        Net = deps.Net
        Notify = deps.Notify
        World = deps.World
end

function SmashService.registerTable(index: number, pos: Vector3)
        tables[index] = pos
        slots[index] = {}
        if not hasilFolders[index] then
                local root = workspace:FindFirstChild("Dunia")
                if root then
                        local f = Instance.new("Folder")
                        f.Name = "Hasil_" .. index
                        f.Parent = root
                        hasilFolders[index] = f
                end
        end
end

function SmashService.tablePos(index: number): Vector3?
        return tables[index]
end

local function syncLahan(index: number, player: Player?)
        local arr = {}
        for i, s in ipairs(slots[index]) do
                arr[i] = { crop = s.crop, hits = s.hitsLeft, max = CropData.Smash[CropData.byId[s.crop].rarity].hits }
        end
        local ev = Net.get("SmashSync")
        if player then
                ev:FireClient(player, { lahan = index, slots = arr })
                return
        end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if Land.landOf(p) == index then
                        ev:FireClient(p, { lahan = index, slots = arr })
                end
        end
end

function SmashService.clearLahan(index: number)
        slots[index] = {}
        local f = hasilFolders[index]
        if f then
                f:Destroy()
                hasilFolders[index] = nil
        end
end

function SmashService.syncTo(player, index: number)
        syncLahan(index, player)
end

function SmashService.refundLahan(index: number, player)
        for _, s in ipairs(slots[index] or {}) do
                Tas.add(player, "hasil", s.crop, 1)
        end
        slots[index] = {}
end

local function makeHasilModel(index: number, slotCount: number, info: any): Model
        local model = Instance.new("Model")
        model.Name = "Hasil_" .. slotCount
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanQuery = false
        part.Size = RARITY_SIZE[info.rarity]
        part.Color = RARITY_COLOR[info.rarity]
        part.Material = Enum.Material.SmoothPlastic
        part.Position = tables[index] + Vector3.new(-10 + slotCount * 4, part.Size.Y / 2 + 0.1, 0)
        part.Parent = model
        local f = hasilFolders[index]
        if f then
                model.Parent = f
        else
                model.Parent = workspace:FindFirstChild("Dunia")
        end
        return model
end

function SmashService.place(player, cropId: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Hasil panen tidak dikenal."
        end
        if #slots[index] >= MAX_SLOTS then
                return false, "Meja penuh. Pukul dulu yang ada."
        end
        if Tas.count(player, "hasil", cropId) < 1 then
                return false, "Hasil panen tidak ada di tas."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - tables[index]).Magnitude > 24 then
                return false, "Terlalu jauh dari meja."
        end
        Tas.remove(player, "hasil", cropId, 1)
        local info = CropData.byId[cropId]
        local model = makeHasilModel(index, #slots[index], info)
        table.insert(slots[index], { crop = cropId, hitsLeft = CropData.Smash[info.rarity].hits, model = model })
        if World then
                World.touch(index)
        end
        syncLahan(index, player)
        return true, info.nama .. " diletakkan di meja."
end

function SmashService.hit(player, slotIdx: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(slotIdx) ~= "number" or slotIdx < 1 or slotIdx > #slots[index] then
                return false, "Tidak ada hasil di posisi itu."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - tables[index]).Magnitude > 24 then
                return false, "Terlalu jauh dari meja."
        end
        local s = slots[index][slotIdx]
        local info = CropData.byId[s.crop]
        local cfg = CropData.Smash[info.rarity]
        s.hitsLeft -= 1
        if s.hitsLeft <= 0 then
                s.model:Destroy()
                table.remove(slots[index], slotIdx)
                local micda = rng:NextInteger(cfg.micdaMin, cfg.micdaMax)
                Data.addMicda(player, micda)
                if World then
                        World.touch(index)
                end
                local pesan = "+" .. micda .. " Micda"
                if rng:NextNumber() < cfg.seed then
                        local put = Tas.add(player, "benih", s.crop, 1)
                        if put > 0 then
                                pesan ..= ", +1 Benih " .. info.nama
                        else
                                Notify(player, "Tas Penuh", "Benih gagal masuk, tas penuh.")
                        end
                end
                if rng:NextNumber() < cfg.blok then
                        local put = Tas.add(player, "blok", CropData.BlokId, 1)
                        if put > 0 then
                                pesan ..= ", +1 Blok Panen"
                        else
                                Notify(player, "Tas Penuh", "Blok panen gagal masuk, tas penuh.")
                        end
                end
                syncLahan(index, player)
                return true, pesan
        end
        local part = s.model:FindFirstChildWhichIsA("BasePart")
        if part then
                part.Size = part.Size * 0.92
        end
        syncLahan(index, player)
        return true, "Pukulan " .. (cfg.hits - s.hitsLeft) .. "/" .. cfg.hits
end

function SmashService.take(player, slotIdx: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(slotIdx) ~= "number" or slotIdx < 1 or slotIdx > #slots[index] then
                return false, "Tidak ada hasil di posisi itu."
        end
        local s = slots[index][slotIdx]
        if Tas.roomFor(player, "hasil", s.crop, 1) < 1 then
                return false, "Tas penuh!"
        end
        s.model:Destroy()
        table.remove(slots[index], slotIdx)
        Tas.add(player, "hasil", s.crop, 1)
        if World then
                World.touch(index)
        end
        syncLahan(index, player)
        return true, "Diambil kembali."
end

function SmashService.serializeLahan(index: number): { { c: string, h: number } }
        local out = {}
        for _, s in ipairs(slots[index] or {}) do
                table.insert(out, { c = s.crop, h = s.hitsLeft })
        end
        return out
end

function SmashService.restoreLahan(index: number, arr: { any })
        if not tables[index] then
                return
        end
        slots[index] = slots[index] or {}
        for _, rec in ipairs(arr or {}) do
                local info = CropData.byId[rec.c]
                if info and #slots[index] < MAX_SLOTS then
                        local model = makeHasilModel(index, #slots[index], info)
                        table.insert(slots[index], { crop = rec.c, hitsLeft = rec.h, model = model })
                end
        end
end

return SmashService

end)()

local MOD_PlotService = (function()
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData
local Layout = MOD_Layout
local Recipes = MOD_Recipes

local PlotService = {}

local Land, Tas, Net, World
local rng = Random.new()

local folders: { [number]: Folder } = {}
local planted: { [number]: { [number]: any } } = {}
local running: { [number]: boolean } = {}

local RARITY_COLOR = {
        common = Color3.fromRGB(76, 145, 65),
        rare = Color3.fromRGB(58, 112, 200),
        epic = Color3.fromRGB(150, 80, 205),
}

function PlotService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Net = deps.Net
        World = deps.World
end

local function plotPos(index: number, idx: number): Vector3
        local o = Land.origin(index)
        local x, z = Layout.plotLocal(idx)
        return Vector3.new(o.X + x, 1.4, o.Z + z)
end

local function now(): number
        return Workspace:GetServerTimeNow()
end

local function sync(player: Player, index: number, idx: number)
        local rec = planted[index] and planted[index][idx]
        local st = "kosong"
        local crop, readyAt
        if rec then
                crop = rec.crop
                readyAt = rec.readyAt
                st = now() >= rec.readyAt and "siap" or "tumbuh"
        end
        Net.get("PlotSync"):FireClient(player, {
                lahan = index,
                idx = idx,
                st = st,
                crop = crop,
                readyAt = readyAt,
        })
end

local function makePlantModel(index: number, idx: number, cropId: string): Model
        local info = CropData.byId[cropId]
        local model = Instance.new("Model")
        model.Name = "Tanaman_" .. idx
        local pos = plotPos(index, idx)
        local stem = Instance.new("Part")
        stem.Anchored = true
        stem.CanQuery = false
        stem.Size = Vector3.new(1, 2, 1)
        stem.Position = pos + Vector3.new(0, 1, 0)
        stem.Color = Color3.fromRGB(96, 116, 58)
        stem.Material = Enum.Material.Grass
        stem.Parent = model
        local head = Instance.new("Part")
        head.Name = "Kepala"
        head.Anchored = true
        head.CanQuery = false
        head.Size = Vector3.new(2, 1, 2)
        head.Position = pos + Vector3.new(0, 2.5, 0)
        head.Color = RARITY_COLOR[info.rarity] or RARITY_COLOR.common
        head.Material = Enum.Material.SmoothPlastic
        head.Parent = model
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
                                                local head = rec.model and rec.model:FindFirstChild("Kepala")
                                                if head then
                                                        head.Size = Vector3.new(3, 2, 3)
                                                        head.Position = plotPos(index, idx) + Vector3.new(0, 3, 0)
                                                end
                                                for _, p in ipairs(Players:GetPlayers()) do
                                                        sync(p, index, idx)
                                                end
                                        end
                                end
                        end
                end
        end)
end

function PlotService.plant(player: Player, idx: number, cropId: string): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(idx) ~= "number" or idx < 0 or idx >= Layout.plotCount() then
                return false, "Plot tidak sah."
        end
        local info = CropData.byId[cropId]
        if not info then
                return false, "Tanaman tidak dikenal."
        end
        local pl = planted[index]
        if not pl then
                return false, "Lahan belum siap."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - plotPos(index, idx)).Magnitude > 48 then
                return false, "Terlalu jauh dari plot."
        end
        local rec = pl[idx]
        if rec then
                local pasangan = Recipes.sameSpot(rec.crop, cropId)
                if not pasangan then
                        return false, "Plot masih terisi. Untuk gabung benih, tanam benih pasangan resep di plot yang sama."
                end
                if Tas.count(player, "benih", cropId) < 1 then
                        return false, "Benih tidak ada di tas."
                end
                Tas.remove(player, "benih", cropId, 1)
                local namaLama = CropData.byId[rec.crop].nama
                if rec.model then
                        rec.model:Destroy()
                end
                rec.crop = pasangan
                rec.readyAt = now() + CropData.GrowTime
                rec.ready = false
                rec.model = makePlantModel(index, idx, pasangan)
                if World then
                        World.touch(index)
                end
                sync(player, index, idx)
                return true, "Gabung benih: " .. namaLama .. " + " .. info.nama .. " menjadi " .. CropData.byId[pasangan].nama .. "!"
        end
        if Tas.count(player, "benih", cropId) < 1 then
                return false, "Benih tidak ada di tas."
        end
        Tas.remove(player, "benih", cropId, 1)
        local model = makePlantModel(index, idx, cropId)
        pl[idx] = {
                crop = cropId,
                readyAt = now() + CropData.GrowTime,
                model = model,
                ready = false,
        }
        if World then
                World.touch(index)
        end
        sync(player, index, idx)
        return true, "Ditanam."
end

function PlotService.harvest(player: Player, idx: number): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(idx) ~= "number" or idx < 0 or idx >= Layout.plotCount() then
                return false, "Plot tidak sah."
        end
        local rec = planted[index] and planted[index][idx]
        if not rec then
                return false, "Plot kosong."
        end
        if now() < rec.readyAt then
                return false, "Belum siap panen."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - plotPos(index, idx)).Magnitude > 48 then
                return false, "Terlalu jauh dari plot."
        end
        local info = CropData.byId[rec.crop]
        local y = CropData.Yield[info.rarity]
        local jumlah = rng:NextInteger(y.min, y.max)
        if Tas.roomFor(player, "hasil", rec.crop, jumlah) < jumlah then
                return false, "Tas penuh! Kosongkan slot dulu."
        end
        rec.model:Destroy()
        planted[index][idx] = nil
        Tas.add(player, "hasil", rec.crop, jumlah)
        if World then
                World.touch(index)
        end
        sync(player, index, idx)
        return true, "Panen " .. jumlah .. " " .. info.nama .. "."
end

function PlotService.serialize(index: number): { [number]: { c: string, r: number } }
        local out = {}
        local pl = planted[index]
        if not pl then
                return out
        end
        for idx, rec in pairs(pl) do
                out[idx] = { c = rec.crop, r = rec.readyAt }
        end
        return out
end

function PlotService.restore(index: number, arr: { [number]: { c: string, r: number } })
        local pl = planted[index]
        if not pl then
                return
        end
        for idx, rec in pairs(arr or {}) do
                if not pl[idx] and CropData.byId[rec.c] then
                        local model = makePlantModel(index, idx, rec.c)
                        local ready = now() >= rec.r
                        pl[idx] = { crop = rec.c, readyAt = rec.r, model = model, ready = ready }
                        if ready then
                                local head = model:FindFirstChild("Kepala")
                                if head then
                                        head.Size = Vector3.new(3, 2, 3)
                                        head.Position = plotPos(index, idx) + Vector3.new(0, 3, 0)
                                end
                        end
                end
        end
end

return PlotService

end)()

local MOD_ShopService = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = MOD_CropData

local ShopService = {}

local Data, Tas
local rng = Random.new()
local shopPoint: Vector3? = nil

function ShopService.bind(deps)
	Data = deps.Data
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

function ShopService.buy(player, packId: any): (boolean, string)
	if type(packId) ~= "string" then
		return false, "Permintaan tidak sah."
	end
	local pack = CropData.Packs[packId]
	if not pack then
		return false, "Pack tidak dikenal."
	end
	if not ShopService.near(player, 30) then
		return false, "Terlalu jauh dari kasir."
	end
	local d = Data.get(player)
	if not d or d.m < pack.price then
		return false, "Micda tidak cukup."
	end
	local pool = CropData.byRarity(packId)
	local items = {}
	for _ = 1, pack.count do
		local pick = pool[rng:NextInteger(1, #pool)]
		table.insert(items, { kind = "benih", id = pick.id, count = 1 })
	end
	if not Tas.canFitBatch(player, items) then
		return false, "Tas penuh! Kosongkan slot dulu."
	end
	if not Data.trySpend(player, pack.price) then
		return false, "Micda tidak cukup."
	end
	local nama = {}
	for _, it in ipairs(items) do
		Tas.add(player, it.kind, it.id, it.count)
		table.insert(nama, CropData.byId[it.id].nama)
	end
	return true, "Pack " .. packId .. ": " .. table.concat(nama, ", ")
end

function ShopService.sell(player, cropId: any, count: any): (boolean, string)
	if type(cropId) ~= "string" or not CropData.byId[cropId] then
		return false, "Barang tidak dikenal."
	end
	if not ShopService.near(player, 30) then
		return false, "Terlalu jauh dari kasir."
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
	Tas.remove(player, "hasil", cropId, n)
	Data.addMicda(player, total)
	return true, "Terjual " .. n .. " " .. info.nama .. " (+" .. total .. " Micda)."
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

	local semai = BuildingKit.buildSemai(folder)
	semai:PivotTo(CFrame.new(dX + ox + 185, gt, oz + 50))
	for _, p in ipairs(semai:GetDescendants()) do
		if p:IsA("BasePart") and p.Size == Vector3.new(12, 4, 4) then
			if hooks and hooks.registerTable then
				hooks.registerTable(index, p.Position + Vector3.new(0, 2, 0))
			end
			if hooks and hooks.onSemaiPrompt then
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Semai Panen"
				prompt.ObjectText = "Meja Hasil"
				prompt.HoldDuration = 0.3
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.Parent = p
				p:SetAttribute("LahanIdx", index)
				prompt.Triggered:Connect(function(player: Player)
					hooks.onSemaiPrompt(player, index)
				end)
			end
		end
	end

	BuildingKit.marker(folder, dX + ox + 185, oz + 85, gt, 30, 30, MARKER_A)
	BuildingKit.marker(folder, dX + ox + 195, oz + 125, gt, 50, 30, MARKER_A)
	BuildingKit.marker(folder, dX + ox + 40, oz + 185, gt, 40, 40, MARKER_B)
	BuildingKit.marker(folder, dX + ox + 82, oz + 177, gt, 24, 24, MARKER_B)
	BuildingKit.marker(folder, dX + ox + 112, oz + 177, gt, 24, 24, MARKER_B)
	BuildingKit.marker(folder, dX + ox + 142, oz + 177, gt, 24, 24, MARKER_B)
	BuildingKit.marker(folder, dX + ox + 172, oz + 177, gt, 24, 24, MARKER_B)

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

local Land, Plot, Smash, Data, Notify, Hooks
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
        Smash = deps.Smash
        Data = deps.Data
        Notify = deps.Notify
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
                        Workspace:RequestStreamAroundAsync(pos, 2)
                end)
                task.delay(0.25, function()
                        if root.Parent then
                                root.Anchored = false
                        end
                end)
        end)
        task.delay(5, function()
                if root.Parent and root.Anchored then
                        root.Anchored = false
                end
        end)
        watchVoid(player, pos)
        Data.push(player)
        return true
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

local function payloadOf(s: Seksi)
        return {
                n = s.ownerName,
                pl = DuniaLogic.serPlots(Plot.serialize(s.idx)),
                mj = DuniaLogic.serMeja(Smash.serializeLahan(s.idx)),
                t = os.time(),
        }
end

local function saveSeksi(s: Seksi, force: boolean)
        if s.ghost or not s.canSave or (not s.dirty and not force) then
                return
        end
        local ok = pcall(function()
                store:SetAsync(DuniaLogic.keyFor(s.ownerId), payloadOf(s))
        end)
        if ok then
                s.dirty = false
        end
end

local function loadWorld(ownerId: number): (boolean, string?, any, any)
        local ok, data = pcall(function()
                return store:GetAsync(DuniaLogic.keyFor(ownerId))
        end)
        if not ok then
                return false, nil, {}, {}
        end
        if type(data) ~= "table" then
                return true, nil, {}, {}
        end
        return true, DuniaLogic.cleanName(data.n), DuniaLogic.desPlots(data.pl), DuniaLogic.desMeja(data.mj)
end

local function buildSection(idx: number, ownerId: number, nama: string, ghost: boolean, savedOk: boolean, plots: any, meja: any): Seksi
        local model = WorldBuilder.buildLahan(Hooks, idx, nama)
        Plot.buildGrid(idx, model)
        Plot.restore(idx, plots)
        Plot.startLoop(idx)
        Smash.restoreLahan(idx, meja)
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
        Smash.clearLahan(idx)
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
                placeAt(player, arrivalPos(s.idx), "dunia", s.ownerName)
                return true, "Kamu kembali ke duniamu."
        end
        if s and s.ghost then
                s.ghost = false
                s.canSave = s.savedOk
                s.dirty = false
                byOwner[player.UserId] = s.idx
                Land.claim(s.idx, player.UserId)
                placeAt(player, arrivalPos(s.idx), "dunia", s.ownerName)
                return true, "Kamu kembali ke duniamu."
        end
        local loadOk, namaTersimpan, plots, meja = loadWorld(player.UserId)
        local nama = namaTersimpan or player.Name
        local idx = Land.claimFree(player.UserId, taken)
        if idx <= 0 then
                return false, "Semua petak dunia di server ini sedang terpakai. Coba lagi sebentar."
        end
        buildSection(idx, player.UserId, nama, false, loadOk, plots, meja)
        byOwner[player.UserId] = idx
        placeAt(player, arrivalPos(idx), "dunia", nama)
        return true, "Duniamu siap. Masuk dan pulang kini tanpa loading."
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
                                placeAt(player, arrivalPos(s.idx), "dunia", s.ownerName)
                                Notify(p, "Tamu Datang", player.Name .. " sedang berkunjung ke duniamu.")
                                return true, "Kamu berkunjung ke dunia " .. s.ownerName .. ". Semua aksi perubahan terkunci."
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
                placeAt(player, arrivalPos(s.idx), "dunia", s.ownerName)
                return true, "Kamu berkunjung ke dunia " .. s.ownerName .. "."
        end
        local loadOk, namaTersimpan, plots, meja = loadWorld(targetId)
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
        buildSection(idx, targetId, namaDunia, true, loadOk, plots, meja)
        placeAt(player, arrivalPos(idx), "dunia", namaDunia)
        return true, "Kamu berkunjung ke dunia " .. namaDunia .. " (salinan tersimpan)."
end

function ZonaService.pulang(player: Player): (boolean, string)
        if placeAt(player, kotaPos(), "kota", nil) then
                return true, "Kembali ke Pusat Kota."
        end
        return false, "Titik kota belum siap."
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
                saveSeksi(s, true)
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

local MOD_UIController = nil
local function LOAD_UIController()
	if not MOD_UIController then
		MOD_UIController = (function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CropData = MOD_CropData
local Recipes = MOD_Recipes
local Net = MOD_Remotes

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local state = {
        micda = 0,
        tas = {},
        lahan = nil,
        plot = {},
        semai = {},
        zone = "kota",
        dunia = nil,
        role = "hub",
}

local function fmt(n: number): string
        local s = tostring(math.floor(n))
        local rev = string.reverse(s)
        rev = rev:gsub("(%d%d%d)", "%1.")
        rev = rev:gsub("%.$", "")
        return string.reverse(rev)
end

local KIND_COLOR = {
        benih = Color3.fromRGB(122, 85, 52),
        hasil = Color3.fromRGB(72, 130, 62),
        blok = Color3.fromRGB(96, 98, 104),
}
local RARITY_COLOR = {
        common = Color3.fromRGB(150, 200, 130),
        rare = Color3.fromRGB(120, 170, 235),
        epic = Color3.fromRGB(200, 140, 240),
}
local PANEL_TITLES = {
        tas = "Tas (50 slot, maks 250 per slot)",
        plot = "Plot Tanam",
        semai = "Semai Panen",
        toko = "Toko Benih",
        gerbang = "Gerbang Dunia",
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
        mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, inst)
end

local gui = mk("ScreenGui", {
        Name = "DuniaAkiomida",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local hud = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52), Position = UDim2.new(0, 0, 0, 8) }, gui)

local micdaFrame = mk("Frame", { Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 190, 0, 44), BackgroundColor3 = Color3.fromRGB(18, 20, 24), BackgroundTransparency = 0.15 }, hud)
round(micdaFrame)
mk("TextLabel", { Size = UDim2.new(0, 40, 1, 0), BackgroundTransparency = 1, Text = "M", TextScaled = true, Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(255, 208, 96) }, micdaFrame)
local micdaLabel = mk("TextLabel", { Position = UDim2.new(0, 46, 0, 0), Size = UDim2.new(1, -54, 1, 0), BackgroundTransparency = 1, Text = "0 Micda", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(240, 240, 240), TextXAlignment = Enum.TextXAlignment.Left }, micdaFrame)

local tasBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0, 150, 0, 44), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Tas", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, hud)
round(tasBtn)

local toastHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 66), Size = UDim2.new(0, 470, 0, 220), BackgroundTransparency = 1 }, gui)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, toastHolder)

local zonaLabel = mk("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.new(0, 260, 0, 24), BackgroundColor3 = Color3.fromRGB(18, 20, 24), BackgroundTransparency = 0.25, Text = "Pusat Kota", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110) }, gui)
round(zonaLabel, 6)

local toastOrder = 0
local function toast(title: string, msg: string)
        toastOrder += 1
        local f = mk("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Color3.fromRGB(18, 20, 24), BackgroundTransparency = 0.12, LayoutOrder = -toastOrder }, toastHolder)
        round(f)
        mk("TextLabel", { Size = UDim2.new(1, -16, 0, 22), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left }, f)
        mk("TextLabel", { Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 28), BackgroundTransparency = 1, Text = msg, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1, 1, 1), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
        task.delay(3.2, function()
                f:Destroy()
        end)
end

local dim = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false }, gui)
local panelHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 580, 0, 420), BackgroundColor3 = Color3.fromRGB(22, 24, 30) }, dim)
round(panelHolder, 12)
local panelTitle = mk("TextLabel", { Size = UDim2.new(1, -70, 0, 40), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, panelHolder)
local closeBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8), Size = UDim2.new(0, 44, 0, 40), BackgroundColor3 = Color3.fromRGB(140, 60, 56), Text = "X", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, panelHolder)
round(closeBtn)

local panels = {}
local currentPanel: string? = nil

local function closePanel()
        dim.Visible = false
        currentPanel = nil
end

local function makePanel(name: string): Frame
        local f = mk("Frame", { Size = UDim2.new(1, -24, 1, -66), Position = UDim2.new(0, 12, 0, 52), BackgroundTransparency = 1, Visible = false }, panelHolder)
        panels[name] = f
        return f
end

local function openPanel(name: string)
        for n, f in pairs(panels) do
                f.Visible = n == name
        end
        panelTitle.Text = PANEL_TITLES[name] or ""
        dim.Visible = true
        currentPanel = name
end

closeBtn.Activated:Connect(closePanel)

local tasPanel = makePanel("tas")
local tasGrid = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -58), Position = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tasPanel)
mk("UIGridLayout", { CellSize = UDim2.new(0, 96, 0, 76), CellPadding = UDim2.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tasGrid)
local slotFrames = {}
for i = 1, 50 do
        local cell = mk("Frame", { BackgroundColor3 = Color3.fromRGB(34, 38, 46), LayoutOrder = i }, tasGrid)
        round(cell, 6)
        local nama = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 36), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1, 1, 1) }, cell)
        local count = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 1, -26), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110) }, cell)
        slotFrames[i] = { frame = cell, nama = nama, count = count }
end
local tasUsedLabel = mk("TextLabel", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -6), Size = UDim2.new(0.5, 0, 0, 28), BackgroundTransparency = 1, Text = "0/50 slot", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, tasPanel)
mk("TextLabel", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -8, 1, -6), Size = UDim2.new(0.5, -12, 0, 28), BackgroundTransparency = 1, Text = "Mau gabung benih? Tanam satu benih di plot lahanku, lalu tanam benih pasangannya lagi di plot yang sama.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 200, 130), TextXAlignment = Enum.TextXAlignment.Right }, tasPanel)

local function refreshTas()
        local used = #state.tas
        for i = 1, 50 do
                local s = state.tas[i]
                local slot = slotFrames[i]
                if s then
                        local info = CropData.byId[s.id]
                        slot.frame.BackgroundColor3 = KIND_COLOR[s.kind] or Color3.fromRGB(60, 60, 66)
                        slot.nama.Text = s.kind == "blok" and "Blok Panen" or (info and info.nama or s.id)
                        slot.count.Text = "x" .. s.count
                else
                        slot.frame.BackgroundColor3 = Color3.fromRGB(34, 38, 46)
                        slot.nama.Text = ""
                        slot.count.Text = ""
                end
        end
        tasUsedLabel.Text = used .. "/50 slot terpakai"
end

local gerbangPanel = makePanel("gerbang")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 56), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Duniamu terbuka seketika tanpa loading dan tanpa ID. Tamu bisa berkunjung dan tidak bisa mengubah apa pun.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, gerbangPanel)
local masukBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 52), Position = UDim2.new(0, 8, 0, 68), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Masuk Dunia-ku", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gerbangPanel)
round(masukBtn)
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 130), BackgroundTransparency = 1, Text = "Kunjungi dunia pemain lain:", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, gerbangPanel)
local kunjungiNama = mk("TextBox", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.new(0, 8, 0, 158), BackgroundColor3 = Color3.fromRGB(30, 33, 40), Text = "", PlaceholderText = "Ketik nama pemain...", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = false }, gerbangPanel)
round(kunjungiNama, 6)
local kunjungiBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.new(0, 8, 0, 210), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Kunjungi", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gerbangPanel)
round(kunjungiBtn)
local function syncState()
        task.spawn(function()
                local st = Net.get("GetState"):InvokeServer()
                if st then
                        state.micda = st.micda or 0
                        state.tas = st.tas or {}
                        state.lahan = st.lahan
                        state.zone = st.zone or "kota"
                        state.dunia = st.dunia
                        state.role = st.role or "hub"
                        micdaLabel.Text = fmt(state.micda) .. " Micda"
                        if state.zone == "dunia" then
                                zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                        else
                                zonaLabel.Text = "Pusat Kota"
                        end
                        refreshTas()
                end
        end)
end

masukBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
        toast(ok and "Gerbang Dunia" or "Gagal", msg)
        if ok then
                syncState()
        end
end)
kunjungiBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("kunjungi", kunjungiNama.Text)
        toast(ok and "Kunjungan" or "Gagal", msg)
        if ok then
                syncState()
        end
end)

local function seedList(): { any }
        local out = {}
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" then
                        table.insert(out, s)
                end
        end
        return out
end

local plotPanel = makePanel("plot")
local plotInfo = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 64), Position = UDim2.new(0, 8, 0, 6), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, plotPanel)
local plotActions = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -86), Position = UDim2.new(0, 8, 0, 76), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, plotPanel)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, plotActions)

local plotCtx = { lahan = nil, idx = nil }
local countdownToken = 0

local function tampilGabung(cropId: string)
        local pasangan = {}
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" and s.id ~= cropId and Recipes.sameSpot(cropId, s.id) then
                        table.insert(pasangan, s)
                end
        end
        if #pasangan == 0 then
                return
        end
        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), BackgroundTransparency = 1, Text = "Gabung benih di plot ini:", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(150, 200, 130), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 50 }, plotActions)
        for order, s in ipairs(pasangan) do
                local sinfo = CropData.byId[s.id]
                local hasil = CropData.byId[Recipes.sameSpot(cropId, s.id)]
                local btn = mk("TextButton", { Size = UDim2.new(1, -8, 0, 40), BackgroundColor3 = Color3.fromRGB(122, 85, 52), Text = "Gabung " .. (sinfo and sinfo.nama or s.id) .. " -> " .. (hasil and hasil.nama or "?"), TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 50 + order }, plotActions)
                round(btn, 6)
                btn.Activated:Connect(function()
                        local ok, msg = Net.get("PlotAct"):InvokeServer(plotCtx.idx, "plant", s.id)
                        toast(ok and "Gabung Benih" or "Gagal Gabung", msg)
                end)
        end
end

local function refreshPlotPanel()
        countdownToken += 1
        local token = countdownToken
        for _, c in ipairs(plotActions:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then
                        c:Destroy()
                end
        end
        local lahan, idx = plotCtx.lahan, plotCtx.idx
        if lahan == nil or idx == nil then
                return
        end
        local key = tostring(lahan) .. "_" .. tostring(idx)
        local rec = state.plot[key]
        local st = rec and rec.st or "kosong"
        local info = rec and rec.crop and CropData.byId[rec.crop]
        local nama = info and info.nama or "-"
        if state.lahan ~= lahan then
                plotInfo.Text = "Lahan #" .. lahan .. ", plot #" .. (idx + 1) .. " (" .. st .. ") " .. nama .. "\nIni lahan pemain lain. Pengunjung tidak bisa mengubah isi."
                return
        end
        if st == "kosong" then
                plotInfo.Text = "Lahanmu, plot #" .. (idx + 1) .. " — kosong. Pilih benih untuk menanam:"
                local seeds = seedList()
                if #seeds == 0 then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada benih di tas. Beli pack benih di Toko Benih, Pusat Kota.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230, 170, 120), LayoutOrder = 1 }, plotActions)
                        return
                end
                for order, s in ipairs(seeds) do
                        local sinfo = CropData.byId[s.id]
                        local btn = mk("TextButton", { Size = UDim2.new(1, -8, 0, 40), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Tanam " .. (sinfo and sinfo.nama or s.id) .. " x" .. s.count, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = order }, plotActions)
                        round(btn, 6)
                        btn.Activated:Connect(function()
                                local ok, msg = Net.get("PlotAct"):InvokeServer(idx, "plant", s.id)
                                toast(ok and "Menanam" or "Gagal Tanam", msg)
                                if ok then
                                        closePanel()
                                end
                        end)
                end
        elseif st == "tumbuh" then
                plotInfo.Text = nama .. " sedang tumbuh (3 detik)."
                local label = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "...", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), LayoutOrder = 1 }, plotActions)
                task.spawn(function()
                        while token == countdownToken and currentPanel == "plot" do
                                local r = state.plot[key]
                                if not r or r.st ~= "tumbuh" then
                                        break
                                end
                                local left = math.max(0, (r.readyAt or 0) - Workspace:GetServerTimeNow())
                                label.Text = string.format("Siap panen dalam %.1f detik", left)
                                task.wait(0.2)
                        end
                end)
                tampilGabung(rec.crop)
        else
                plotInfo.Text = nama .. " siap panen!"
                local btn = mk("TextButton", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = Color3.fromRGB(196, 148, 48), Text = "Panen Sekarang", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 1 }, plotActions)
                round(btn, 6)
                btn.Activated:Connect(function()
                        local ok, msg = Net.get("PlotAct"):InvokeServer(idx, "harvest")
                        toast(ok and "Panen" or "Gagal Panen", msg)
                        if ok then
                                closePanel()
                        end
                end)
                tampilGabung(rec.crop)
        end
end

local semaiPanel = makePanel("semai")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Letakkan hasil panen di meja, lalu pukul hingga hancur untuk Micda + peluang benih & blok panen.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, semaiPanel)
local semaiLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -80), Position = UDim2.new(0, 8, 0, 44), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
local semaiRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -80), Position = UDim2.new(0.5, 6, 0, 44), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiRight)

local function actionBtn(parent, text: string, color: Color3, order: number, onAct)
        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 64), BackgroundColor3 = Color3.fromRGB(38, 42, 52), LayoutOrder = order }, parent)
        round(holder, 6)
        mk("TextLabel", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 6, 0, 3), BackgroundTransparency = 1, Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, holder)
        return holder
end

local function subBtn(parent: Frame, text: string, posX: number, width: number, color: Color3, onAct)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 0, 1, -30), Size = UDim2.new(width, -6, 0, 26), BackgroundColor3 = color, Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, 6)
        btn.Activated:Connect(onAct)
end

local function refreshSemai()
        for _, col in ipairs({ semaiLeft, semaiRight }) do
                for _, c in ipairs(col:GetChildren()) do
                        if c:IsA("Frame") or c:IsA("TextLabel") then
                                c:Destroy()
                        end
                end
        end
        local order = 0
        local adaHasil = false
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        adaHasil = true
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(semaiLeft, (info and info.nama or s.id) .. " x" .. s.count, Color3.new(1, 1, 1), order, function() end)
                        subBtn(holder, "Letakkan 1", 0.5, 0.5, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("SmashAct"):InvokeServer("place", s.id)
                                toast(ok and "Meja" or "Gagal", msg)
                        end)
                end
        end
        if not adaHasil then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, semaiLeft)
        end
        if #state.semai == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Meja kosong.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, semaiRight)
        end
        for i, slot in ipairs(state.semai) do
                local info = CropData.byId[slot.crop]
                local cfg = info and CropData.Smash[info.rarity]
                local holder = actionBtn(semaiRight, (info and info.nama or slot.crop) .. " — pukul " .. tostring(slot.hits) .. "/" .. tostring(cfg and cfg.hits or "?"), RARITY_COLOR[info and info.rarity] or Color3.new(1, 1, 1), i, function() end)
                subBtn(holder, "Pukul", 0, 0.5, Color3.fromRGB(196, 96, 48), function()
                        local ok, msg = Net.get("SmashAct"):InvokeServer("hit", i)
                        toast(ok and "Pukul" or "Gagal", msg)
                end)
                subBtn(holder, "Ambil", 0.5, 0.5, Color3.fromRGB(90, 90, 100), function()
                        local ok, msg = Net.get("SmashAct"):InvokeServer("take", i)
                        toast(ok and "Meja" or "Gagal", msg)
                end)
        end
end

local tokoPanel = makePanel("toko")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Ambil pack benih lewat kasir atau rak berisi benih. Pack berisi 3 benih acak; toko juga membeli hasil panenmu.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, tokoPanel)
local tokoBuy = mk("Frame", { Size = UDim2.new(1, -16, 0, 100), Position = UDim2.new(0, 8, 0, 38), BackgroundColor3 = Color3.fromRGB(30, 33, 40) }, tokoPanel)
round(tokoBuy, 8)
local tokoSell = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -160), Position = UDim2.new(0, 8, 0, 146), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tokoPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tokoSell)

local function refreshToko()
        for _, c in ipairs(tokoSell:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") then
                        c:Destroy()
                end
        end
        local order = 0
        local ada = false
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        ada = true
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(tokoSell, (info and info.nama or s.id) .. " x" .. s.count .. " — " .. (info and info.jual or 0) .. " Micda/unit", RARITY_COLOR[info and info.rarity] or Color3.new(1, 1, 1), order, function() end)
                        subBtn(holder, "Jual 1", 0, 0.34, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", s.id, 1)
                                toast(ok and "Terjual" or "Gagal", msg)
                        end)
                        subBtn(holder, "Jual Semua", 0.34, 0.33, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", s.id)
                                toast(ok and "Terjual" or "Gagal", msg)
                        end)
                end
        end
        if not ada then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen untuk dijual.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, tokoSell)
        end
end

local function buyBtn(parent: Frame, text: string, posX: number, packId: string)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 6, 0, 10), Size = UDim2.new(0.5, -18, 0, 80), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, 8)
        btn.Activated:Connect(function()
                local ok, msg = Net.get("ShopAct"):InvokeServer("buy", packId)
                toast(ok and "Pembelian" or "Gagal", msg)
        end)
end

buyBtn(tokoBuy, "Pack Common\n2.400 Micda\n3 benih acak", 0, "common")
buyBtn(tokoBuy, "Pack Rare\n9.000 Micda\n3 benih acak", 0.5, "rare")

tasBtn.Activated:Connect(function()
        if currentPanel == "tas" then
                closePanel()
                return
        end
        openPanel("tas")
        refreshTas()
end)

local camera = Workspace.CurrentCamera
local function onTap(inputPos: Vector2)
        if dim.Visible then
                return
        end
        local ray = camera:ViewportPointToRay(inputPos.X, inputPos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local char = player.Character
        params.FilterDescendantsInstances = char and { char } or {}
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 400, params)
        if result and result.Instance then
                local plotIdx = result.Instance:GetAttribute("PlotIdx")
                local lahanIdx = result.Instance:GetAttribute("LahanIdx")
                if plotIdx ~= nil and lahanIdx ~= nil then
                        plotCtx = { lahan = lahanIdx, idx = plotIdx }
                        openPanel("plot")
                        refreshPlotPanel()
                end
        end
end

UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
                return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                onTap(Vector2.new(input.Position.X, input.Position.Y))
        end
end)

Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = payload.tas or {}
        micdaLabel.Text = fmt(state.micda) .. " Micda"
        if payload.zone then
                state.zone = payload.zone
                state.dunia = payload.dunia
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                else
                        zonaLabel.Text = "Pusat Kota"
                end
        end
        refreshTas()
        if currentPanel == "semai" then
                refreshSemai()
        elseif currentPanel == "toko" then
                refreshToko()
        end
end)

Net.get("Notify").OnClientEvent:Connect(function(title, msg)
        toast(tostring(title), tostring(msg))
end)

Net.get("PlotSync").OnClientEvent:Connect(function(p)
        state.plot[tostring(p.lahan) .. "_" .. tostring(p.idx)] = { st = p.st, crop = p.crop, readyAt = p.readyAt }
        if currentPanel == "plot" and plotCtx.lahan == p.lahan and plotCtx.idx == p.idx then
                refreshPlotPanel()
        end
end)

Net.get("SmashSync").OnClientEvent:Connect(function(p)
        if p.lahan == state.lahan then
                state.semai = p.slots or {}
                if currentPanel == "semai" then
                        refreshSemai()
                end
        end
end)

Net.get("OpenPanel").OnClientEvent:Connect(function(name)
        if name == "semai" then
                openPanel("semai")
                refreshSemai()
        elseif name == "toko" then
                openPanel("toko")
                refreshToko()
        elseif name == "gerbang" then
                openPanel("gerbang")
        end
end)

task.spawn(function()
        local st = Net.get("GetState"):InvokeServer()
        if st then
                state.micda = st.micda or 0
                state.tas = st.tas or {}
                state.lahan = st.lahan
                state.zone = st.zone or "kota"
                state.dunia = st.dunia
                state.role = st.role or "hub"
                micdaLabel.Text = fmt(state.micda) .. " Micda"
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                else
                        zonaLabel.Text = "Pusat Kota"
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

local Net = MOD_Remotes

local Modules = script.Modules
local DevCodeVault = MOD_DevCodeVault
local RateLimit = MOD_RateLimit
local DataService = MOD_DataService
local TasService = MOD_TasService
local LandService = MOD_LandService
local PlotService = MOD_PlotService
local SmashService = MOD_SmashService
local ShopService = MOD_ShopService
local ZonaService = MOD_ZonaService
local WorldBuilder = MOD_WorldBuilder

Net.init()

local function notify(player: Player, title: string, msg: string)
        Net.get("Notify"):FireClient(player, title, msg)
end

local deps = {
        Land = LandService,
        Tas = TasService,
        Data = DataService,
        Net = Net,
        Notify = notify,
        Plot = PlotService,
        Smash = SmashService,
        World = ZonaService,
}
TasService.bind(DataService)
PlotService.bind(deps)
SmashService.bind(deps)
ShopService.bind(deps)
ZonaService.bind(deps)

local function openSemai(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Semai Panen", "Hanya pemilik dunia yang bisa memakai meja ini.")
                return
        end
        SmashService.syncTo(player, lahanIdx)
        Net.get("OpenPanel"):FireClient(player, "semai", { lahan = lahanIdx })
end

local function openShop(player: Player)
        if not ShopService.near(player, 35) then
                notify(player, "Toko Benih", "Dekati kasir atau rak benih dulu.")
                return
        end
        Net.get("OpenPanel"):FireClient(player, "toko", {})
end

local hooks = {
        onSemaiPrompt = openSemai,
        onShopPrompt = openShop,
        onGerbangDunia = function(player: Player)
                Net.get("OpenPanel"):FireClient(player, "gerbang", {})
        end,
        onPulang = function(player: Player)
                ZonaService.pulang(player)
        end,
        registerTable = SmashService.registerTable,
        setShopPoint = ShopService.setShopPoint,
        registerKota = LandService.registerKota,
        registerUmum = LandService.registerUmum,
}
ZonaService.setHooks(hooks)
DataService.setZoneProvider(ZonaService.zoneOf)

WorldBuilder.buildHub(hooks)

local function applySpawn(player: Player)
        local target = LandService.kotaSpawn() or LandService.umumSpawn()
        if target then
                player.RespawnLocation = target
        end
end

local function enterServer(player: Player)
        local ok = DataService.load(player)
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local micda = Instance.new("IntValue")
        micda.Name = "Micda"
        local d = DataService.get(player)
        micda.Value = d and math.floor(d.m) or 0
        micda.Parent = leaderstats
        leaderstats.Parent = player
        applySpawn(player)
        DataService.push(player)
        task.delay(4, function()
                if player.Parent then
                        if ok then
                                notify(player, "Pusat Kota", "Selamat datang! Lewati Gerbang Dunia untuk masuk ke duniamu sendiri.")
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

Players.PlayerRemoving:Connect(function(player)
        ZonaService.leaveGame(player)
        DataService.save(player)
        RateLimit.clear(player.UserId)
        DataService.drop(player)
end)

game:BindToClose(function()
        ZonaService.shutdown()
        for _, p in ipairs(Players:GetPlayers()) do
                DataService.save(p)
        end
end)

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
                micda = math.floor(d.m),
                tas = d.t,
                lahan = lahan,
                zone = zone,
                role = role,
                dunia = dunia,
        }
end

Net.get("DuniaAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "dunia", 2, 3) then
                return false, "Terlalu cepat."
        end
        if action == "masuk" then
                return ZonaService.masuk(player)
        elseif action == "kunjungi" then
                return ZonaService.visit(player, arg)
        elseif action == "pulang" then
                return ZonaService.pulang(player)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("PlotAct").OnServerInvoke = function(player, idx, action, cropId)
        if not RateLimit.allow(player.UserId, "plot", 6, 8) then
                return false, "Terlalu cepat."
        end
        local deny = ZonaService.mutationDeny(player)
        if deny then
                return false, deny
        end
        if action == "plant" then
                return PlotService.plant(player, idx, cropId)
        elseif action == "harvest" then
                return PlotService.harvest(player, idx)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("SmashAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "smash", 5, 8) then
                return false, "Terlalu cepat."
        end
        local deny = ZonaService.mutationDeny(player)
        if deny then
                return false, deny
        end
        if action == "place" then
                return SmashService.place(player, arg)
        elseif action == "hit" then
                return SmashService.hit(player, arg)
        elseif action == "take" then
                return SmashService.take(player, arg)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("ShopAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "shop", 3, 5) then
                return false, "Terlalu cepat."
        end
        if action == "buy" then
                return ShopService.buy(player, a)
        elseif action == "sell" then
                return ShopService.sell(player, a, b)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("RedeemDevCode").OnServerInvoke = function(player, code)
        local d = DataService.get(player)
        if not d then
                return false, "Data belum siap."
        end
        if type(code) ~= "string" or code ~= DevCodeVault.CODE then
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

print("[AKIOMIDA] Pusat Kota dan dunia pribadi siap dalam satu server. Gerbang instan menunggu pemain.")

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

print("=== PLAYTEST DUNIA AKIOMIDA (simulasi server + klien) ===")
Stub.Scheduler.advance(0.05)

section("Booting server")
local serverScript = Stub.serverScript()
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

local gabungFound = {}
if dunia then
        for _, d in ipairs(dunia:GetDescendants()) do
                local t = d.Name or ""
                if type(d.Text) == "string" then
                        t = t .. " " .. d.Text
                end
                if type(d.ActionText) == "string" then
                        t = t .. " " .. d.ActionText
                end
                if type(d.ObjectText) == "string" then
                        t = t .. " " .. d.ObjectText
                end
                if string.find(string.lower(t), "gabung") then
                        table.insert(gabungFound, t)
                end
        end
end
check("Tidak ada fitur/bangunan gabung benih di pusat kota", #gabungFound == 0, table.concat(gabungFound, " | "))

local toko = dunia and dunia:FindFirstChild("TokoBenih", true)
check("Model TokoBenih ada", toko ~= nil)
local partToko = toko and countClass(toko, "BasePart") or 0
check("Interior toko penuh pernak-pernik (>=90 bagian)", partToko >= 90, "jumlah bagian: " .. tostring(partToko))

local doors = {}
if toko then
        for _, d in ipairs(toko:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("PintuDaun") == true then
                        table.insert(doors, d)
                end
        end
end
check("Toko punya pintu sungguhan 2 daun (bukan melompong)", #doors == 2, "daun pintu: " .. tostring(#doors))
if #doors == 2 then
        local d1 = doors[1]
        local prompt = d1:FindFirstChildWhichIsA("ProximityPrompt")
        check("Pintu punya prompt buka/tutup", prompt ~= nil)
        if prompt then
                local closed = d1.CFrame
                prompt.Triggered:Fire(nil)
                Stub.Scheduler.advance(0.6)
                local opened = d1.CFrame
                check("Pintu bisa dibuka (berputar)", (opened.Position - closed.Position).Magnitude > 0.5, tostring((opened.Position - closed.Position).Magnitude))
                prompt.Triggered:Fire(nil)
                Stub.Scheduler.advance(0.6)
                check("Pintu bisa ditutup lagi", (d1.CFrame.Position - closed.Position).Magnitude < 0.2, tostring((d1.CFrame.Position - closed.Position).Magnitude))
        end
end

section("Pemain utama masuk")
local profStore = Stub.Services.DataStoreService:GetDataStore("AKM_T1")
profStore.__data["u_1001"] = {
        m = 900000,
        t = {
                { kind = "benih", id = "wortel", count = 5 },
                { kind = "benih", id = "jeruk_mandarin", count = 2 },
                { kind = "benih", id = "grapefruit", count = 2 },
                { kind = "benih", id = "pisang", count = 2 },
        },
        dev = false,
}
local P1 = Stub.addPlayer(1001, "akiomida")
Stub.giveCharacter(P1, 0, 6, 44)
Players.PlayerAdded:Fire(P1)
Stub.Scheduler.advance(0.5)

local ls = P1:FindFirstChild("leaderstats")
check("leaderstats Micda dibuat", ls ~= nil and ls:FindFirstChild("Micda") ~= nil)
check("Micda awal 900.000", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 900000, ls and ls:FindFirstChild("Micda") and tostring(ls:FindFirstChild("Micda").Value))

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
check("Label Micda terisi dari GetState", findGui(gui, "TextLabel", "Micda") ~= nil)
check("Label Micda menunjukkan 900.000", (findGui(gui, "TextLabel", "900.000 Micda") ~= nil), findGui(gui, "TextLabel", "Micda") and findGui(gui, "TextLabel", "Micda").Text or "tidak ada")

section("Toko Benih: buka panel dan beli benih")
moveTo(P1, 8, 4, -46)
local kasirFired = firePrompt(dunia, { object = "Kasir" }, P1)
check("Prompt kasir toko bisa dipicu", kasirFired)
Stub.Scheduler.advance(0.1)

local buyCommon = findGui(gui, "TextButton", "Pack Common")
check("Tombol beli Pack Common tampil", buyCommon ~= nil)
local buyRare = findGui(gui, "TextButton", "Pack Rare")
check("Tombol beli Pack Rare tampil", buyRare ~= nil)

local st0 = serverCall("GetState", P1)
local benihSebelum = 0
if st0 then
        for _, s in ipairs(st0.tas) do
                if s.kind == "benih" then
                        benihSebelum += s.count
                end
        end
end

if buyCommon then
        buyCommon.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local micdaAfterBuy = ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value
check("Beli Pack Common berhasil (900.000 - 2.400 = 897.600)", micdaAfterBuy == 897600, tostring(micdaAfterBuy))

local st = serverCall("GetState", P1)
local nBenih = 0
if st then
        for _, s in ipairs(st.tas) do
                if s.kind == "benih" then
                        nBenih += s.count
                end
        end
end
check("3 benih acak masuk tas", nBenih == benihSebelum + 3, tostring(nBenih) .. " vs " .. tostring(benihSebelum + 3))

if buyRare then
        buyRare.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Beli Pack Rare berhasil (897.600 - 9.000 = 888.600)", ls:FindFirstChild("Micda").Value == 888600, tostring(ls:FindFirstChild("Micda").Value))

local okBuyFake, msgFake = serverCall("ShopAct", P1, "buy", "epic")
check("Pack tidak dikenal ditolak", okBuyFake == false, tostring(msgFake))

local toastLabel = findGui(gui, "TextLabel", "Pack rare")
check("Toast hasil pembelian tampil di UI", toastLabel ~= nil)

section("Gerbang Dunia: masuk ke lahan lewat UI")
moveTo(P1, 0, 5, 20)
local gerbangFired = firePrompt(dunia, { action = "Dunia-ku" }, P1)
check("Gerbang Dunia di kota bisa dipicu", gerbangFired)
Stub.Scheduler.advance(0.1)

local masukBtn = findGui(gui, "TextButton", "Masuk Dunia")
check("Tombol Masuk Dunia-ku tampil di panel", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
local r1 = rootOf(P1)
check("Pemain terbangun instan di dunia lahan (X > 5000)", r1 and r1.Position.X > 5000, r1 and tostring(r1.Position) or "tanpa karakter")

st = serverCall("GetState", P1)
check("Zona aktif = dunia milik sendiri", st and st.zone == "dunia" and st.role == "pemilik", st and (st.zone .. "/" .. tostring(st.role)) or "tidak ada state")

section("Grid plot di dunia lahan")
local grid = dunia and dunia:FindFirstChild("PlotGrid_1", true)
check("PlotGrid_1 dibuat di dunia lahan", grid ~= nil)
local nPlot = grid and #grid:GetChildren() or 0
check("Jumlah plot 500", nPlot == 500, tostring(nPlot))
local nyasar = 0
if grid then
        for _, p in ipairs(grid:GetChildren()) do
                if p.Position.X < 5000 then
                        nyasar += 1
                end
        end
end
check("Semua plot berada di dalam dunia lahan, bukan nyasar ke kota", grid ~= nil and nyasar == 0, tostring(nyasar) .. " plot nyasar")

section("Tanam & gabung benih di plot lahan")
moveTo(P1, 5013, 5, 38)
local okP, msgP = serverCall("PlotAct", P1, 0, "plant", "wortel")
check("Tanam wortel di plot 1", okP == true, tostring(msgP))

moveTo(P1, 5019, 5, 38)
okP, msgP = serverCall("PlotAct", P1, 1, "plant", "jeruk_mandarin")
check("Tanam jeruk mandarin di plot 2", okP == true, tostring(msgP))

okP, msgP = serverCall("PlotAct", P1, 1, "plant", "grapefruit")
check("Gabung di plot yang sama: jeruk_mandarin + grapefruit = tangelo", okP == true and string.find(tostring(msgP), "Tangelo", 1, true) ~= nil, tostring(msgP))

okP, msgP = serverCall("PlotAct", P1, 0, "plant", "pisang")
check("Gabung tanpa resep ditolak (benih tidak terpakai)", okP == false, tostring(msgP))

Stub.Scheduler.advance(3.6)
local tanaman = grid and grid:FindFirstChild("Tanaman_1", true)
local kepala = tanaman and tanaman:FindFirstChild("Kepala")
check("Tanaman gabung membesar saat siap panen", kepala ~= nil and kepala.Size == Vector3.new(3, 2, 3), kepala and tostring(kepala.Size) or "tanaman hilang")

okP, msgP = serverCall("PlotAct", P1, 1, "harvest")
check("Panen hasil gabung tangelo", okP == true and string.find(tostring(msgP), "Tangelo", 1, true) ~= nil, tostring(msgP))

st = serverCall("GetState", P1)
local adaTangelo = false
if st then
        for _, s in ipairs(st.tas) do
                if s.kind == "hasil" and s.id == "tangelo" then
                        adaTangelo = true
                end
        end
end
check("Tangelo hasil gabung masuk tas", adaTangelo)

section("Pulang ke kota lalu balik lagi ke lahan")
local zona = dunia and dunia:FindFirstChild("Zona_1", true)
local pulangFired = zona and firePrompt(zona, { action = "Pulang ke Kota" }, P1)
check("Gerbang pulang di lahan bisa dipicu", pulangFired == true)
Stub.Scheduler.advance(0.5)
local r2 = rootOf(P1)
check("Sampai pusat kota lagi", r2 and math.abs(r2.Position.X) < 3 and math.abs(r2.Position.Z - 44) < 4, r2 and tostring(r2.Position) or "-")

local kotaFired = firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
masukBtn = findGui(gui, "TextButton", "Masuk Dunia")
check("Panel gerbang terbuka lagi dengan tombol masuk", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.6)
end
local r3 = rootOf(P1)
check("BALIK ke dunia lahan sukses (bug user teratasi)", r3 and r3.Position.X > 5000, r3 and tostring(r3.Position) or "-")

section("Tamu berkunjung, tidak bisa mengubah")
local P2 = Stub.addPlayer(2002, "tamu")
Stub.giveCharacter(P2, 0, 6, 44)
Players.PlayerAdded:Fire(P2)
Stub.Scheduler.advance(0.3)
local okV, msgV = serverCall("DuniaAct", P2, "kunjungi", "akiomida")
check("Tamu bisa berkunjung ke dunia akiomida", okV == true, tostring(msgV))
local r4 = rootOf(P2)
check("Tamu tiba di dunia lahan", r4 and r4.Position.X > 5000, r4 and tostring(r4.Position) or "-")
Stub.Scheduler.advance(0.3)
moveTo(P2, 5013, 5, 38)
local okDeny = serverCall("PlotAct", P2, 0, "plant", "wortel")
check("Tamu dilarang menanam di lahan orang lain", okDeny == false, tostring(okDeny))

section("Jual hasil & pukul di meja semai")
burn(1.2)
moveTo(P1, 8, 4, -46)
local okSell, msgSell = serverCall("ShopAct", P1, "sell", "tangelo", 1)
check("Jual tangelo = +17 Micda", okSell == true and string.find(tostring(msgSell), "17", 1, true) ~= nil, tostring(msgSell))

burn(1.2)
moveTo(P1, 5013, 5, 38)
local okH, msgH = serverCall("PlotAct", P1, 0, "harvest")
check("Panen wortel", okH == true, tostring(msgH))

burn(1.2)
moveTo(P1, 5185, 5, 56)
local okPlace, msgPlace = serverCall("SmashAct", P1, "place", "wortel")
check("Letakkan hasil di meja semai", okPlace == true, tostring(msgPlace))
local micdaSebelum = ls:FindFirstChild("Micda").Value
local okHit, msgHit
for _ = 1, 5 do
        okHit, msgHit = serverCall("SmashAct", P1, "hit", 1)
        if not okHit then
                break
        end
        Stub.Scheduler.advance(0.05)
        burn(0.35)
end
check("Pukul hasil sampai hancur", okHit == true, tostring(msgHit))
local micdaSesudah = ls:FindFirstChild("Micda").Value
check("Pukul memberi Micda", micdaSesudah > micdaSebelum, tostring(micdaSebelum) .. " -> " .. tostring(micdaSesudah))

section("Simpan data saat keluar")
Players.PlayerRemoving:Fire(P1)
Stub.Scheduler.advance(0.3)
local duniaStore = Stub.stores["AKM_Dunia"]
check("Dunia pemain tersimpan (d_1001)", duniaStore and duniaStore.__data["d_1001"] ~= nil)
local t1 = Stub.stores["AKM_T1"]
check("Profil pemain tersimpan (u_1001)", t1 and t1.__data["u_1001"] ~= nil)

section("Bersih dari error runtime")
check("Tidak ada error runtime tersembunyi", #__SIM_ERRORS == 0, table.concat(__SIM_ERRORS, " | "))

print(string.format("HASIL PLAYTEST: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tahap playtest gagal", failed))
end
