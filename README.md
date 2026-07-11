# GG-CameraShake
A port of gasgiant's camerashake from Unity for Roblox/Luau. Strictly typed.

__Features__:
* One line of code shake with presets
* Several shake algorithms suitable for a wide range of use cases
* Change strength and direction of the shake depending on  
position of the shake source
* Easy to write custom shakes

[__Watch gasgiant's video!__](https://youtu.be/fn3hIPLbSn8)
![Thumbnail](https://i.imgur.com/n0ndQ9x.png "Video thumbnail")

Most of the info below is taken from gasgiant's repo, as well... this is literally his module ported to Luau. All of the references are their updated Luau counterparts.

## Table of Contents
1. [Installation](#installation)
2. [Usage](#usage)
    * [Setup](#setup)
    * [Using Presets](#using-presets)
    * [Without Presets](#without-presets)
2. [Presets](#presets)
2. [PerlinShake](#perlinshake)
2. [BounceShake](#bounceshake)
2. [KickShake](#kickshake)

## Installation

1. [![.rbxm](https://img.shields.io/github/v/release/HysteriaBee/GG-CameraShake)](https://github.com/HysteriaBee/GG-CameraShake/releases/latest)

2. [Wally](https://www.youtube.com/watch?v=QDia3e12czc) Coming soon, lol

3. Roblox Creator Store unavailable, as I am unable to upload it there (I do not meet the requirements).


## Usage
### Setup

1. Require the module
```luau
local Shaker = require(path.to.GGCameraShaker)
```
Done.

### Using Presets

It is incredibly simple to use this module with presets. All it takes is one line.

```luau
Shaker.Shake(Shaker.Presets.Explosion3D())
```

### Without Presets

Simply create a preset in the CameraShakePresets module! You can choose from (#presets) and just fill in whatever's necessary! Take a look at current presets if you're stuck.
Otherwise, just require one of three modules: `PerlinShake, BounceShake, or KickShake` and do as seen below (Details on these shake types are here: #perlinshake, #bounceshake, #kickshake):

```luau
Shaker.Shake(PerlinShake.New(...fill in the parameters!...))
```


## Presets

__ShortShake3D__  
Suitable for short and snappy shakes in 3D. Rotates camera in all three axes. Uses `BounceShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| strength     | Strength of the shake.|
| freq     | Frequency of shaking.|
| numBounces     | Number of vibrations before stop.|

__ShortShake2D__  
Suitable for short and snappy shakes in 2D. Moves camera in X and Y axes and rotates it in Z axis. Uses `BounceShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| positionStrength     | Strength of motion in X and Y axes.|
| rotationStrength     | Strength of rotation in Z axis.|
| freq     | Frequency of shaking.|
| numBounces     | Number of vibrations before stop.|

__Explosion3D__  
Suitable for longer and stronger shakes in 3D. Rotates camera in all three axes. Uses `PerlinShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| strength     | Strength of the shake.|
| duration     | Duration of the shake.|

__Explosion2D__  
Suitable for longer and stronger shakes in 2D. Moves camera in X and Y axes and rotates it in Z axis. Uses `PerlinShake` algorithm.
| Parameter        | Description | 
| :------------- |:-------------|
| positionStrength     | Strength of motion in X and Y axes.|
| rotationStrength     | Strength of rotation in Z axis.|
| duration     | Duration of the shake.|

## PerlinShake
`PerlinShake` combines layers of Perlin noise with different frequencies to create smooth and nuanced shake. Works better for longer shakes. For very short shakes consider using `BounceShake`.
### Constructor

| Parameter        |   |  Description | 
| :------------- |:-------------|:-------------|
| parameters     | | Parameters of the shake. |
| maxAmplitude     | | Maximum amplitude of the shake.|
| sourcePosition | | World position of the source of the shake. |
| manualStrengthControl| false | Play shake once automatically. |
|  | true| Manually control strength over time. |

For more details on `maxAmplitude` and `manualStrengthControl` see [Time Envelope](#time-envelope).

### Params

| Parameter        | Description | 
| :------------- |:-------------|
| strength     | Strength of the shake for each axis. |
| noiseModes     | Layers of Perlin noise with different frequencies. |
| envelope     | Strength of the shake over time. |
| attenuation     | How strength falls with distance from the shake source. |

For more details on `envelope` see [Time Envelope](#time-envelope). For more details on `attenuation` see [Spatial Attenuation](#spatial-attenuation).

## BounceShake
`BounceShake` is useful for short and precise shakes. Unlike `PerlinShake`, it will provide reliable shake strength. Consider using `PerlinShake` for longer and stronger shakes.

### Constructors

#### BounceShake (first overload)
| Parameter        | Description | 
| :------------- |:-------------|
| parameters     | Parameters of the shake. |
| initialDirection     | Initial direction of the shake motion. |
| sourcePosition     | World position of the source of the shake. |

#### BounceShake (second overload)
Creates `BounceShake` with random initial direction.
| Parameter        | Description | 
| :------------- |:-------------|
| parameters     | Parameters of the shake. |
| sourcePosition     | World position of the source of the shake. |

### Params
| Parameter        | Description | 
| :------------- |:-------------|
| positionStrength     | Parameters of the shake. |
| rotationStrength     | Strength of the shake for rotational axes. |
| axesMultiplier     | Preferred direction of shaking. |
| freq     | Frequency of shaking. |
| numBounces     | Number of vibrations before stop. |
| randomness     | Randomness of motion. |
| attenuation     | How strength falls with distance from the shake source. |

 For more details on `attenuation` see [Spatial Attenuation](#spatial-attenuation).

## KickShake
Makes one kick in specified direction. Useful for recoil.

### Constructors

#### KickShake (first overload)
| Parameter        | Description | 
| :------------- |:-------------|
| parameters     | Parameters of the shake. |
| direction     | Direction of the kick. |

#### KickShake (second overload)
Creates an instance of KickShake in the direction from the source to the camera.
| Parameter        | Description | 
| :------------- |:-------------|
| parameters     | Parameters of the shake. |
| sourcePosition     | World position of the source of the shake. |
| attenuateStrength     | Change strength depending on distance from the camera? |

### Params
| Parameter        | Description | 
| :------------- |:-------------|
| strength     | Strength of the shake for each axis. |
| attackTime     | How long it takes to move forward. |
| attackCurve     | Forward motion curve. |
| releaseTime     | How long it takes to move back. |
| releaseCurve     | Back motion curve. |
| attenuation     | How strength falls with distance from the shake source. |

 For more details on `attenuation` see [Spatial Attenuation](#spatial-attenuation).


 ## Time Envelope
Class `Envelope` controls amplitude of the shake over time. It can work in two modes. In automatic mode it plays the shake ones with selected `maxAmplitude`. 

In manual mode you can keep the reference to the `PerlinShake` and change amplitude whenever you like.
```luau
local PerlinShake = require(path.to.GGCameraShaker.PerlinShake)
local params = PerlinShake.GetDefaultParams()
params...--your params here, or pass through nothing in PerlinShake.New() if you want the default params.

local function Start()
	shake = PerlinShake.New(params);
	CameraShaker.Shake(shake);
end

local function Vibrate(amplitude: number)
	shake.AmplitudeController:SetTargetAmplitude(amplitude);
end
```


### EnvelopeParams
[See interactive demonstration.](https://www.desmos.com/calculator/e9wxr78uu2)
| Parameter        | Description | 
| :------------- |:-------------|
| attack     | How fast the amplitude increases. |
| sustain     | How long in seconds the amplitude holds maximum value. |
| decay     | How fast the amplitude decreases. |
| degree     | Power in which the amplitude is raised to get intensity. |

## Spatial Attenuation

Class `Attenuator` provides methods for changing strength and direction of the shake depending on position of the shake source relative to the camera.


### StrengthAttenuationParams
[See interactive demonstration.](https://www.desmos.com/calculator/iivcfrotk8)
| Parameter        | Description | 
| :------------- |:-------------|
| clippingDistance     | Radius in which shake doesn't lose strength. |
| falloffScale     | How fast strength falls with distance. |
| falloffDegree     | Power of the falloff function. |
| axesMultiplier     | Contribution of each axis to distance. E. g. (1, 1, 0) for a 2D game in XY plane. |


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
	Update: (self: any, deltaTime: number, cameraCFrame: CFrame) -> ()
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

