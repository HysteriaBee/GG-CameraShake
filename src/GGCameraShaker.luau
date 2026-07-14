-- v1.1.3 GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
-- <Summary> Camera shaker component registeres new shakes, holds a list of active shakes, and applies them to the camera additively.
--!strict
--!optimize 2

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera :: Camera

local Displacement = require(script.Displacement)
local ICameraShake = require(script.ICameraShake)

type ICameraShake = ICameraShake.ICameraShake

local CameraShaker = {}

local strengthMultiplier : number = 10
local activeShakes : {ICameraShake} = {}
local CFrameOffset: CFrame = CFrame.new()
local baseCFrame: CFrame?

-- Drift prevention
local function setBaseCFrame()
	if not baseCFrame then
		return
	end

	Camera.CFrame = baseCFrame
end

-- Shakes the camera with the passed through shake instance (created with the .New() constructor).
function CameraShaker.Shake(shake: ICameraShake)
	shake:Initialize(Camera.CFrame)
	table.insert(activeShakes, shake)
end

-- Updates camera shakes.
function CameraShaker.Update(deltaTime: number)
	local cameraDisplacement = Displacement.Zero()

	for i = #activeShakes, 1, -1 do
		local shake = activeShakes[i]
		local multiplier = shake.ForceEnabled and 1 or strengthMultiplier
		
		if multiplier == 0 then
			continue
		end
		
		if shake.IsFinished then
			table.remove(activeShakes, i)
		else
			shake:Update(deltaTime, Camera.CFrame)
			cameraDisplacement += (shake.CurrentDisplacement * multiplier)
		end
	end

	baseCFrame = Camera.CFrame
	CFrameOffset = CFrame.new(cameraDisplacement.position)
		* CFrame.Angles(
			math.rad(cameraDisplacement.eulerAngles.X),
			math.rad(cameraDisplacement.eulerAngles.Y),
			math.rad(cameraDisplacement.eulerAngles.Z)
		)
	
	Camera.CFrame *= CFrameOffset
end

-- -- Set the strength scale of all shakes. Preferred over enable/disable methods. This allows for more fine tuned customization.
function CameraShaker.SetStrengthScale(scale: number)
	strengthMultiplier = scale
end

-- Enables the shaker if it was disabled. Equivalent to SetStrengthScale(1).
function CameraShaker.Enable()
	strengthMultiplier = 1
end

-- Disables the shaker if it was enabled. Equivalent to SetStrengthScale(0).
function CameraShaker.Disable()
	strengthMultiplier = 0
end

-- Returns the camera offset produced by the camera shaker.
function CameraShaker.GetOffset(): CFrame
	return CFrameOffset
end

RunService.PreRender:Connect(CameraShaker.Update)
RunService.Heartbeat:Connect(setBaseCFrame)

-- For ease of use
CameraShaker.Attenuator = require(script.Attenuator)
CameraShaker.Envelope = require(script.Envelope)
CameraShaker.Presets = require(script.CameraShakePresets)
CameraShaker.KickShake = require(script.KickShake)
CameraShaker.BounceShake = require(script.BounceShake)
CameraShaker.PerlinShake = require(script.PerlinShake)
CameraShaker.Displacement = Displacement

return CameraShaker
