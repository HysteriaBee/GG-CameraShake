-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
--!strict

local ICameraShake = require(script.Parent.ICameraShake)
local Attenuator = require(script.Parent.Attenuator)
local Displacement = require(script.Parent.Displacement)

type StrengthAttenuationParams = Attenuator.StrengthAttenuationParams
type Displacement = Displacement.Displacement
type ICameraShake = ICameraShake.ICameraShake

export type Params = {
	positionStrength: number, -- Strength of the shake for positional axes.
	rotationStrength: number, -- Strength of the shake for rotational axes.
	axesMultiplier: Displacement, -- Preferred direction of shaking.
	freq: number, -- Frequency of shaking.
	numBounces: number, -- Number of vibrations before stop.
	randomness: number, -- Randomness of motion.
	attenuation: StrengthAttenuationParams, -- How strength falls with distance from the shake source.
}

local BounceShake = {}
BounceShake.__index = BounceShake

export type BounceShake = {
	CurrentDisplacement: Displacement,
	ForceEnabled: boolean?,
	IsFinished: boolean,
	bounceIndex: number,
	direction: Displacement,
	previousWaypoint: Displacement,
	currentWaypoint: Displacement,
	pars: Params,
	sourcePosition: Vector3?,
	attenuation: number,
	t: number,
} & typeof(BounceShake) & ICameraShake

-- Returns Unity's AnimationCurve.Evaluate (AnimationCurve.EaseInOut(0, 0, 1, 1)).
local function moveCurveEvaluate(t: number): number
	return t * t * (3 - 2 * t)
end

-- Returns default parameters.
function BounceShake.GetDefaultParams(): Params
	return {
		positionStrength = 0.05,
		rotationStrength = 0.1,
		axesMultiplier = Displacement.New(Vector3.new(1, 1, 0), Vector3.new(0, 0, 1)), -- Assumes custom format mapping mapping Vector2.one & Vector3.forward
		freq = 25,
		numBounces = 5,
		randomness = 0.5,
		attenuation = Attenuator.GetDefaultParams(),
	}
end

-- Creates a new BounceShake instance.
function BounceShake.New(parameters: Params?, initialDirection: Displacement?, sourcePosition: Vector3?, forceEnabled: boolean?): BounceShake
	local self = setmetatable({}, BounceShake) :: BounceShake
	
	self.pars = parameters or BounceShake.GetDefaultParams()
	self.CurrentDisplacement = Displacement.Zero()
	self.previousWaypoint = Displacement.Zero()
	self.direction = (initialDirection and Displacement.Scale(initialDirection, self.pars.axesMultiplier) or Displacement.Scale(Displacement.InsideUnitSpheres(), self.pars.axesMultiplier)):Normalized()
	self.sourcePosition = sourcePosition
	self.ForceEnabled = forceEnabled
	self.bounceIndex = 0
	self.t = 0
	
	return self
end

-- Initializes a Bounceshake instance.
function BounceShake.Initialize(self: BounceShake, cameraPosition: Vector3)
	self.attenuation = self.sourcePosition and Attenuator.Strength(self.pars.attenuation, self.sourcePosition, cameraPosition) or 1
	self.currentWaypoint = self.attenuation * self.direction:ScaledBy(self.pars.positionStrength, self.pars.rotationStrength)
end

-- Updates a current BounceShake instance.
function BounceShake.Update(self : BounceShake, deltaTime: number, cameraCFrame: CFrame) -- I know this doesn't use cameraCFrame, but for the sake of it being an ICameraShake type.
	if self.t < 1 then
		self.t += deltaTime * self.pars.freq

		if self.pars.freq == 0 then
			self.t = 1
		end

		self.CurrentDisplacement = Displacement.Lerp(self.previousWaypoint, self.currentWaypoint, moveCurveEvaluate(self.t))
	else
		self.t = 0
		self.CurrentDisplacement = self.currentWaypoint
		self.previousWaypoint = self.currentWaypoint
		self.bounceIndex += 1

		if self.bounceIndex > self.pars.numBounces then
			self.IsFinished = true
			return
		end

		self.direction = (-self.direction + self.pars.randomness
			* Displacement.Scale(Displacement.InsideUnitSpheres(), self.pars.axesMultiplier):Normalized()
		):Normalized()

		local decayValue = 1 - (self.bounceIndex / self.pars.numBounces)
		self.currentWaypoint = decayValue * decayValue * self.attenuation * self.direction:ScaledBy(self.pars.positionStrength, self.pars.rotationStrength)
	end
end

return BounceShake
