-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
--!strict

local ICameraShake = require(script.Parent.ICameraShake)
local Attenuator = require(script.Parent.Attenuator)
local Displacement = require(script.Parent.Displacement)

type StrengthAttenuationParams = Attenuator.StrengthAttenuationParams
type Displacement = Displacement.Displacement
type ICameraShake = ICameraShake.ICameraShake

type SourceAtten = {sourcePosition: Vector3, attenuateStrength: boolean}
type AnimationCurve = (t: number) -> number
type Overload = Displacement | SourceAtten

export type Params = {
	strength: Displacement, -- Strength of the shake for each axis.
	attackTime: number, -- How long it takes to move forward.
	attackCurve: AnimationCurve, 
	releaseTime: number, -- How long it takes to move back.
	releaseCurve: AnimationCurve, 
	attenuation: StrengthAttenuationParams, -- How strength falls with distance from the shake source.
}

local KickShake = {}
KickShake.__index = KickShake

export type KickShake = {
	CurrentDisplacement: Displacement,
	ForceEnabled: boolean?,
	IsFinished: boolean,
	direction: Displacement,
	previousWaypoint: Displacement,
	currentWaypoint: Displacement,
	attenuateStrength: boolean,
	release: boolean,
	pars: Params,
	sourcePosition: Vector3?,
	t: number,
} & typeof(KickShake) & ICameraShake

-- Returns Unity's AnimationCurve.Evaluate (AnimationCurve.EaseInOut(0, 0, 1, 1)).
local function moveCurveEvaluate(t: number): number
	return t * t * (3 - 2 * t)
end

-- Returns default parameters.
function KickShake.GetDefaultParams(): Params
	return {
		strength = Displacement.New(Vector3.zero, Vector3.one),
		attackTime = 0.05,
		attackCurve = moveCurveEvaluate,
		releaseTime = 0.2,
		releaseCurve = moveCurveEvaluate,
		attenuation = Attenuator.GetDefaultParams(),
	}
end

-- Creates a new KickShake instance.
function KickShake.New(parameters: Params?, overload: Overload?, forceEnabled: boolean?): KickShake
	local self = setmetatable({}, KickShake) :: KickShake
	
	self.pars = parameters or KickShake.GetDefaultParams()
	self.previousWaypoint = Displacement.Zero()
	self.ForceEnabled = forceEnabled
	self.t = 0
	
	overload = overload or Displacement.New(Vector3.zero, Vector3.new(1,1,0))
	
	local attenuate = (overload :: any).attenuateStrength
	local source = (overload :: any).sourcePosition
	
	if attenuate and source then
		self.sourcePosition = source
		self.attenuateStrength = attenuate
	else
		self.direction = (overload :: Displacement):Normalized()
	end
	
	return self
end

-- Initializes a KickShake instance.
function KickShake.Initialize(self: KickShake, cameraCFrame: CFrame)
	if self.sourcePosition then
		self.direction = Attenuator.Direction(self.sourcePosition, cameraCFrame)
		
		if self.attenuateStrength then
			self.direction *= Attenuator.Strength(self.pars.attenuation, self.sourcePosition, cameraCFrame.Position)
		end
	end
	
	self.currentWaypoint = Displacement.Scale(self.direction, self.pars.strength)
end

-- Updates a KickShake instance. Man... why am I writing all these useless comments??
function KickShake.Update(self: KickShake, deltaTime: number, cameraCFrame: CFrame) -- I know this doesn't use cameraCFrame, but for the sake of it being an ICameraShake type.
	if self.t < 1 then
		self:Move(deltaTime,
			if self.release then self.pars.releaseTime else self.pars.attackTime,
			if self.release then self.pars.releaseCurve else self.pars.attackCurve
		)
	else
		self.CurrentDisplacement = self.currentWaypoint
		self.previousWaypoint = self.currentWaypoint
		
		if self.release then
			self.IsFinished = true
			return
		else
			self.release = true
			self.t = 0
			self.currentWaypoint = Displacement.Zero()
		end
	end
end

-- Moves a KickShake instance to its current waypoint with an AnimationCurve.
function KickShake.Move(self: KickShake, deltaTime: number, duration: number, curveEvaluate: AnimationCurve)
	if duration > 0 then
		self.t += deltaTime / duration
	else
		self.t = 1
	end
	
	self.CurrentDisplacement = Displacement.Lerp(self.previousWaypoint, self.currentWaypoint, curveEvaluate(self.t))
end

return KickShake
