--!nonstrict
--[[
        init.client.luau
        Client bootstrap: build UI + pet visuals. Both modules subscribe
        to StateSync themselves.
]]

local UIController = require(script.UIController)
local PetVisuals = require(script.PetVisuals)

UIController.new()
PetVisuals.new()

print("[CoinRush] Client ready.")
