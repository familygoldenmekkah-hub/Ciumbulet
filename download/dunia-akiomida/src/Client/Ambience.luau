local SoundService = game:GetService("SoundService")

local Ambience = {}

local SCALE = { 0, 2, 4, 7, 9, 12, 14, 16 }

local MELODY = { 1, 3, 5, 4, 6, 5, 3, 2, 4, 6, 8, 7, 5, 3, 2, 1 }
local BASS_EVERY = 4
local BASE_SPEED = 0.62
local STEP = 0.55

local enabled = true
local running = false

function Ambience.isEnabled(): boolean
        return enabled
end

function Ambience.toggle(): boolean
        enabled = not enabled
        return enabled
end

local function note(speed: number, volume: number)
        local s = Instance.new("Sound")
        s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        s.Volume = volume
        s.PlaybackSpeed = speed
        s.Parent = SoundService
        s:Play()
        s.Ended:Once(function()
                s:Destroy()
        end)
        task.delay(4, function()
                if s.Parent then
                        s:Destroy()
                end
        end)
end

function Ambience.start()
        if running then
                return
        end
        running = true
        task.spawn(function()
                local step = 0
                while running do
                        if enabled then
                                local idx = MELODY[(step % #MELODY) + 1]
                                local semi = SCALE[idx] or 0
                                note(BASE_SPEED * (2 ^ (semi / 12)), 0.085)
                                if step % BASS_EVERY == 0 then
                                        note(BASE_SPEED * 0.5, 0.07)
                                end
                        end
                        step += 1
                        task.wait(STEP)
                end
        end)
end

return Ambience
