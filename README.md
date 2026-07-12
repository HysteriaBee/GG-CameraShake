# GG Camera Shake
A port of GasGiant's [camera shake](https://github.com/gasgiant/Camera-Shake) from Unity for Roblox/Luau. Strictly typed.

__Features__:
* One line of code shake with presets
* Several shake algorithms suitable for a wide range of use cases
* Change strength and direction of the shake depending on  
position of the shake source
* Easy to write custom shakes

[__Watch GasGiant's video!__](https://youtu.be/fn3hIPLbSn8)
![Thumbnail](https://i.imgur.com/n0ndQ9x.png "Video thumbnail")

Most of the info below is taken from gasgiant's repo, as well... this is literally his module ported to Luau. All of the references are their updated Luau counterparts.

## Table of Contents
1. [Installation](#installation)
2. [Usage](#usage)
    * [Setup](#setup)
    * [Using Presets](#using-presets)
    * [Without Presets](#without-presets)
	* [Handling Offset](#handling-offset)
  	* [List of the Functions](#functions)
2. [Presets](#presets)
2. [PerlinShake](#perlinshake)
2. [BounceShake](#bounceshake)
2. [KickShake](#kickshake)
2. [Displacement](#displacement)
2. [Time Envelope](#time-envelope)
2. [Spatial Attenuation](#spatial-attenuation)
2. [Writing Custom Shakes](#writing-custom-shakes)

## Installation

**Wally**
```
GG-CameraShake = "hysteriabee/gg-camerashake@*"
```

**Get the latest release** ([.rbxm](https://github.com/HysteriaBee/GG-CameraShake/releases/latest)).

Since I am not ID-verified, I cannot make this public on the Roblox creator store.


## Usage
### Setup

Require the module
```luau
local Shaker = require(path.to.GGCameraShaker)
```

### Using Presets

It is incredibly simple to use this module with presets. All it takes is one line.

```luau
Shaker.Shake(Shaker.Presets.Explosion3D())
```

### Without Presets

Simply create a preset in the CameraShakePresets module! You can choose from (#presets) and just fill in whatever's necessary! Take a look at current presets if you're stuck.
Otherwise, just require one of three modules: `PerlinShake, BounceShake, or KickShake` and do as seen below (Details on these shake types are here: #perlinshake, #bounceshake, #kickshake):

```luau
local PerlinShake = require(path.to.GGCameraShaker.PerlinShake) -- the shake algorithm of your choice
Shaker.Shake(PerlinShake.New(...fill in the parameters!...))
```

### Handling Offset

For guns or scripts that require the cursor or camera's position you'll need to add the camera offset from the shaker. This is because otherwise scripts using the camera's position/rotation do not see the changes made by the shaker. Here is an example implementation for correcting a raycast using mouse location.

```luau
local UserInputService = game:GetService("UserInputService")
local Shaker = require(path.to.GGCameraShaker)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function RayCast()
	local mouse = UserInputService:GetMouseLocation()
	local ray = game.Workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)

	-- Main focus --
	local offset = Shaker.GetOffset() -- Getting offset
	local correctedRay = offset:VectorToWorldSpace(ray.Direction) * 1000 -- Applying that offset to correct the raycast
	
	local result = workspace:Raycast(ray.Origin, correctedRay, raycastParams)

	if result == nil then
		return ray.Origin + correctedDir
	else
		return result.Position
	end
end
```

For correcting CFrame.

```luau
local Shaker = require(path.to.GGCameraShaker)
local CameraCFrame = workspace.CurrentCamera.CFrame
local CorrectedCFrame = CameraCFrame * Shaker.GetOffset()
```

## Functions

```luau
-- Shakes the camera with the passed through shake instance (created with the .New() constructor).
function CameraShaker.Shake(shake: ICameraShake)
```

```luau
-- Set the strength scale of all shakes. Preferred over enable/disable methods. This allows for more fine tuned customization.
function CameraShaker.SetStrengthScale(scale: number)
```

```luau
-- Enables the shaker if it was disabled. Equivalent to SetStrengthScale(1).
function CameraShaker.Enable()
```

```luau
-- Disables the shaker if it was enabled. Equivalent to SetStrengthScale(0).
function CameraShaker.Disable()
```

```luau
-- Returns the camera offset produced by the camera shaker. See #handling-offset for more details.
function CameraShaker.GetOffset(): CFrame
```


## Presets

__ShortShake3D__  
Suitable for short and snappy shakes in 3D. Rotates camera in all three axes. Uses `BounceShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| strength: number?     | Strength of the shake.|
| freq: number?     | Frequency of shaking.|
| numBounces: number?     | Number of vibrations before stop.|

```luau
function CameraShakePresets.ShortShake3D(strength: number?, freq: number?, numBounces: number?): BounceShake
```

---

__ShortShake2D__  
Suitable for short and snappy shakes in 2D. Moves camera in X and Y axes and rotates it in Z axis. Uses `BounceShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| positionStrength: number?     | Strength of motion in X and Y axes.|
| rotationStrength : number?    | Strength of rotation in Z axis.|
| freq: number?     | Frequency of shaking.|
| numBounces: number?     | Number of vibrations before stop.|

```luau
function CameraShakePresets.ShortShake2D(positionStrength: number?, rotationStrength: number?, freq: number?, numBounces: number?): BounceShake
```

---

__Explosion3D__  
Suitable for longer and stronger shakes in 3D. Rotates camera in all three axes. Uses `PerlinShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| strength: number?     | Strength of the shake.|
| duration: number?     | Duration of the shake.|

```luau
function CameraShakePresets.Explosion3D(strength: number?, duration: number?, sourcePosition: Vector3?): PerlinShake
```

---

__Explosion2D__  
Suitable for longer and stronger shakes in 2D. Moves camera in X and Y axes and rotates it in Z axis. Uses `PerlinShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| positionStrength: number?     | Strength of motion in X and Y axes.|
| rotationStrength: number?     | Strength of rotation in Z axis.|
| duration: number?     | Duration of the shake.|

```luau
function CameraShakePresets.Explosion2D(positionStrength: number?, rotationStrength: number?, duration: number?): PerlinShake
```

---

__GunFire3D__  
Suitable for gun recoil. Rotates camera in two axes: vertical, and horizontal. Uses `KickShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| verticalStrength: number     | Strength of rotation in X axis.|
| horizontalStrength: number     | Strength of rotation in Y axis.|
| attack: number     | Duration of the recoil attack.|
| recover: number     | Duration for camera to return to normal.|
| forceEnabled: boolean?     | If enabled then it is unaffected by strengthMultiplier changes (enabled by default for fair play reasons).|

```luau
function CameraShakePresets.GunFire3D(strength: {verticalStrength: number, horizontalStrength: number}?, duration: {attack: number, recover: number}?, forceEnabled: boolean?): KickShake
```

---

## PerlinShake
`PerlinShake` combines layers of Perlin noise with different frequencies to create smooth and nuanced shake. Works better for longer shakes. For very short shakes consider using `BounceShake`.
### Constructor

```luau
function PerlinShake.New(parameters: Params?, maxAmplitude: number?, sourcePosition: Vector3?, manualStrengthControl: boolean?, forceEnabled: boolean?): PerlinShake
```

| Parameter        |   |  Description | 
| :------------- |:-------------|:-------------|
| parameters: Params?     | | Parameters of the shake. |
| maxAmplitude: number?     | | Maximum amplitude of the shake.|
| sourcePosition: Vector3?		| | World position of the source of the shake. |
| manualStrengthControl: boolean?		| false | Play shake once automatically. |
|  | true| Manually control strength over time. |
| forceEnabled: boolean? | | If true, then remain unaffected by strengthMultiplier changes. |

For more details on `maxAmplitude` and `manualStrengthControl` see [Time Envelope](#time-envelope).

### Params

```luau
function PerlinShake.GetDefaultParams(): Params
```

| Parameter        | Description | 
| :------------- |:-------------|
| strength: Displacement     | Strength of the shake for each axis. |
| noiseModes: {{freq: number, amplitude: number}}     | Layers of Perlin noise with different frequencies. |
| envelope: EnvelopeParams     | Strength of the shake over time. |
| attenuation: StrengthAttenuationParams     | How strength falls with distance from the shake source. |

For more details on `envelope` see [Time Envelope](#time-envelope). For more details on `attenuation` see [Spatial Attenuation](#spatial-attenuation).

## BounceShake
`BounceShake` is useful for short and precise shakes. Unlike `PerlinShake`, it will provide reliable shake strength. Consider using `PerlinShake` for longer and stronger shakes.

### Constructor

```luau
function BounceShake.New(parameters: Params?, initialDirection: Displacement?, sourcePosition: Vector3?, forceEnabled: boolean?): BounceShake
```

#### BounceShake
| Parameter        | Description | 
| :------------- |:-------------|
| parameters: Params?     | Parameters of the shake. |
| initialDirection: Displacement?     | Initial direction of the shake motion. |
| sourcePosition: Vector3?     | World position of the source of the shake. |
| forceEnabled: boolean?		| If true, then remain unaffected by strengthMultiplier changes. |

### Params

```luau
function BounceShake.GetDefaultParams(): Params
```

| Parameter        | Description | 
| :------------- |:-------------|
| positionStrength: number     | Parameters of the shake. |
| rotationStrength: number     | Strength of the shake for rotational axes. |
| axesMultiplier: Displacement     | Preferred direction of shaking. |
| freq: number     | Frequency of shaking. |
| numBounces: number     | Number of vibrations before stop. |
| randomness: number     | Randomness of motion. |
| attenuation: StrengthAttenuationParams     | How strength falls with distance from the shake source. |

 For more details on `attenuation` see [Spatial Attenuation](#spatial-attenuation).

## KickShake
Makes one kick in specified direction. Useful for recoil.

### Constructors

```luau
function KickShake.New(parameters: Params?, overload: Overload, forceEnabled: boolean?): KickShake
```

### KickShake
| Parameter        | Description | 
| :------------- |:-------------|
| parameters: Params?     | Parameters of the shake. |
| forceEnabled: boolean?		| If true, then remain unaffected by strengthMultiplier changes. |

#### First Overload
| Parameter        | Description | 
| :------------- |:-------------|
| direction: Displacement     | Direction of the kick. |

#### Second Overload
Creates an instance of KickShake in the direction from the source to the camera.
| Parameter        | Description | 
| :------------- |:-------------|
| sourcePosition: Vector3     | World position of the source of the shake. |
| attenuateStrength: boolean     | Change strength depending on distance from the camera? |

### Params

```luau
function KickShake.GetDefaultParams(): Params
```

```luau
type AnimationCurve = (t: number) -> number
```

| Parameter        | Description | 
| :------------- |:-------------|
| strength: Displacement     | Strength of the shake for each axis. |
| attackTime: number     | How long it takes to move forward. |
| attackCurve: AnimationCurve    | Forward motion curve. |
| releaseTime: number     | How long it takes to move back. |
| releaseCurve: AnimationCurve     | Back motion curve. |
| attenuation: StrengthAttenuationParams     | How strength falls with distance from the shake source. |

 For more details on `attenuation` see [Spatial Attenuation](#spatial-attenuation).

 ## Displacement
Class `Displacement` is composed of position and eulerAngle (both Vector3).

```luau
function Displacement.New(position: Vector3, eulerAngles: Vector3): Displacement
```

 ## Time Envelope
Class `Envelope` controls amplitude of the shake over time. It can work in two modes. In automatic mode it plays the shake ones with selected `maxAmplitude`. 

```luau
function Envelope.New(pars: EnvelopeParams, initialTargetAmplitude: number, controlMode: EnvelopeControlMode): Envelope
```

```luau
--Set the target amplitude for an envelope.
function Envelope.SetTargetAmplitude(self: Envelope, value: number)
```

```luau
-- Set an envelope to finish.
function Envelope.Finish(self: Envelope)
```

```luau
-- Set an envelope to finish immediately.
function Envelope.FinishImmediately(self: Envelope)
```

In manual mode you can keep the reference to the `PerlinShake` and change amplitude whenever you like.
```luau
local Shaker = require(path.to.GGCameraShaker)
local PerlinShake = require(path.to.GGCameraShaker.PerlinShake)
local ICameraShake = require(path.to.ICameraShake)

local params = PerlinShake.GetDefaultParams()
params...--your params here, or pass through nothing in PerlinShake.New() if you want the default params.

type ICameraShake = ICameraShake.ICameraShake

local function Start()
	shake = PerlinShake.New(params);
	Shaker.Shake(shake);
end

local function Vibrate(shake: ICameraShake, amplitude: number)
	shake.AmplitudeController:SetTargetAmplitude(amplitude);
end
```


### EnvelopeParams

```luau
function Envelope.GetDefaultParams(): EnvelopeParams
```

[See interactive demonstration.](https://www.desmos.com/calculator/e9wxr78uu2)
| Parameter        | Description | 
| :------------- |:-------------|
| attack: number     | How fast the amplitude increases. |
| sustain: number     | How long in seconds the amplitude holds maximum value. |
| decay: number     | How fast the amplitude decreases. |
| degree: number     | Power in which the amplitude is raised to get intensity. |

## Spatial Attenuation

Class `Attenuator` provides methods for changing strength and direction of the shake depending on position of the shake source relative to the camera.


### StrengthAttenuationParams

```luau
function Attenuator.GetDefaultParams(): StrengthAttenuationParams
```

[See interactive demonstration.](https://www.desmos.com/calculator/iivcfrotk8)
| Parameter        | Description | 
| :------------- |:-------------|
| clippingDistance: number     | Radius in which shake doesn't lose strength. |
| falloffScale: number     | How fast strength falls with distance. |
| falloffDegree: number     | Power of the falloff function. |
| axesMultiplier: Vector3     | Contribution of each axis to distance. E. g. (1, 1, 0) for a 2D game in XY plane. |


## Writing Custom Shakes
`CameraShaker` works with any class that implements `ICameraShake` interface. 

```luau 
export type ICameraShake = {
	-- Represents current position and rotation of the camera according to the shake.
	CurrentDisplacement: Displacement.Displacement,
	
	-- Shake system will dispose the shake on the first frame when this is true.
	IsFinished: boolean,
	
	-- CameraShaker calls this when the shake is added to the list of active shakes.
	Initialize: (self: any, cameraCFrame: CFrame) -> (),
	
	-- CameraShaker calls this every frame on active shakes.
	Update: (self: any, deltaTime: number, cameraCFrame: CFrame) -> (),

	-- Bypasses IsEnabled = false for the camera shaker.
	ForceEnabled: boolean?,
}
```
Here is an example of a basic custom shake.

```luau
local Displacement = require(path.to.GGCameraShaker.Displacement)
type Displacement = Displacement.Displacement

local EEEMANEEE72SHAKER = {}
EEEMANEEE72SHAKER.__index = EEEMANEEE72SHAKER

export type EEEMANEEE72SHAKER = {
	time: number,
	intensity: number,
	duration: duration,
	IsFinished: boolean,
	CurrentDisplacement: Displacement,
} & typeof(EEEMANEEE72SHAKER)

function EEEMANEEE72SHAKER.New(intensity: number, duration: number): EEEMANEEE72SHAKER
	local self = setmetatable({}, EEEMANEEE72SHAKER) :: EEEMANEEE72SHAKER

	self.intensity = intensity or 1 -- default 1 if nothing is passed through
	self.duration = duration or 1

	return self
end

function EEEMANEEE72.Initialize(self: EEEMANEEE72SHAKER, cameraCFrame: CFrame)
end

function EEEMANEEE72.Update(self: EEEMANEEE72SHAKER, deltaTime: number, cameraCFrame: CFrame)
	self.time += deltaTime
	if time > duration then
		self.IsFinished = true
	end
	CurrentDisplacement = Displacement.New(Vector3.new(bro idk some random value using like getrandominsideunitcircle) * intensity, Vector3.zero)
	print("Greetings, you are at the end. Again, all thanks to gasgiant, none of this would've been possible without his original code. Darklizarditsmeagain stinks.")
end
```

