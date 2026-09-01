# ZonePlusNext

**ZonePlusNext v1.2.1** is a dependency-free, high-performance zone and spatial-query system for Roblox.

It goes beyond basic `Touched`-based zone detection by providing a shared scheduler, player and zone spatial indexes, multiple detection modes, transition history, predictive queries, arbitrary tracked objects, tags, priorities, capacities, visibility queries, statistics, and a fluent query engine.

```lua
local ZonePlusNext = require(path.to.ZonePlusNext)

print(ZonePlusNext.Version())
-- 1.2.1
```

---

## Features

* Dependency-free
* Shared scheduler for every zone
* Player spatial-hash broad phase
* Hybrid zone spatial index
* Static, Dynamic, and Auto indexing modes
* Cached zone world bounds
* Dynamic zone containers
* Automatic geometry invalidation
* Player enter/exit detection
* Arbitrary tracked item enter/exit detection
* Enter and exit debounce delays
* Zone capacities
* Zone priorities
* Zone tags
* Player filtering
* Transition history
* Optional player position history
* Historical position lookup
* Entry direction tracking
* Predictive player entry
* Predictive object intersection
* Point, radius, box, part, ray, and path queries
* Zone overlap detection
* Nearest-zone queries
* Nearest-player queries
* Visibility queries
* Fluent player query builder
* Compound query API
* Per-zone statistics
* Global statistics
* Scheduler statistics
* Query statistics
* Spatial-index statistics
* Batch zone creation
* Deterministic cleanup
* No dependency on `Touched`
* No dependency on Workspace spatial queries for normal center detection

---

# Installation

Create a `ModuleScript` named:

```text
ZonePlusNext
```

Place the module somewhere accessible to your scripts, for example:

```text
ReplicatedStorage
└── Packages
    └── ZonePlusNext
```

Then require it:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZonePlusNext = require(
	ReplicatedStorage.Packages.ZonePlusNext
)
```

---

# Quick Start

Create a Part or Model that represents your zone.

```lua
local ZonePlusNext = require(path.to.ZonePlusNext)

local zone = ZonePlusNext.new(workspace.SafeZone)

zone.playerEntered:Connect(function(player)
	print(player.Name, "entered the zone")
end)

zone.playerExited:Connect(function(player)
	print(player.Name, "left the zone")
end)
```

That's enough to create a working player zone.

---

# Creating a Zone

```lua
local zone = ZonePlusNext.new(workspace.SafeZone, {
	Name = "SafeZone",
	Detection = "Center",
	UpdateInterval = 0.1,

	EnterDelay = 0,
	ExitDelay = 0.05,

	Priority = 10,
	Capacity = 20,

	TrackPlayers = true,
	BroadPhase = true,
	IndexMode = "Auto",

	Tags = {
		"Safe",
		"Spawn",
	},
})
```

A zone container may be:

```lua
BasePart
Model
Folder
Instance
{BasePart}
```

When an Instance container is supplied, ZonePlusNext automatically discovers its descendant `BasePart`s.

---

# Zone Options

```lua
type ZoneOptions = {
	Name: string?,
	UpdateInterval: number?,
	Detection: DetectionMode?,
	Padding: number | Vector3?,

	EnterDelay: number?,
	ExitDelay: number?,

	Priority: number?,
	Capacity: number?,

	TrackPlayers: boolean?,
	AutoDestroyWithContainer: boolean?,

	PlayerFilter: ((Player) -> boolean)?,

	Tags: {string}?,

	BroadPhase: boolean?,
	HistoryLimit: number?,
	IndexMode: IndexMode?,
}
```

### Default behavior

| Option                     |        Default |
| -------------------------- | -------------: |
| `UpdateInterval`           | `0.10` seconds |
| `Detection`                |     `"Center"` |
| `Padding`                  | `Vector3.zero` |
| `EnterDelay`               |            `0` |
| `ExitDelay`                |         `0.05` |
| `Priority`                 |            `0` |
| `Capacity`                 |      Unlimited |
| `TrackPlayers`             |         `true` |
| `AutoDestroyWithContainer` |         `true` |
| `BroadPhase`               |         `true` |
| `IndexMode`                |       `"Auto"` |
| `Enabled`                  |         `true` |

---

# Detection Modes

ZonePlusNext supports four player detection modes.

## Center

```lua
Detection = "Center"
```

Checks the player's character root position.

This is generally the cheapest detection mode.

```lua
local zone = ZonePlusNext.new(workspace.Zone, {
	Detection = "Center",
})
```

---

## Bounds

```lua
Detection = "Bounds"
```

Checks the bounds of the player's root part against the zone.

Box-like parts use oriented-box intersection, while Ball and Cylinder zone parts use shape-aware fallback checks.

```lua
local zone = ZonePlusNext.new(workspace.Zone, {
	Detection = "Bounds",
})
```

---

## AnyPart

```lua
Detection = "AnyPart"
```

The player is considered inside when any valid character body part is inside the zone.

Accessories and Tools are excluded from character-body detection.

```lua
local zone = ZonePlusNext.new(workspace.Zone, {
	Detection = "AnyPart",
})
```

---

## WholeCharacter

```lua
Detection = "WholeCharacter"
```

Every detected character body part must be inside the zone.

```lua
local zone = ZonePlusNext.new(workspace.Zone, {
	Detection = "WholeCharacter",
})
```

---

# Zone Shapes

For point checks, normal Roblox `Part`s receive shape-aware handling for:

```text
Block
Ball
Cylinder
```

Complex `BasePart` types such as:

```text
MeshPart
UnionOperation
WedgePart
CornerWedgePart
```

use their oriented bounding box for point detection.

---

# Events

Every zone exposes lightweight Signal objects.

## playerEntered

```lua
zone.playerEntered:Connect(function(player, zone, transition)
	print(player.Name, "entered", zone.Name)
end)
```

The transition contains information such as:

```lua
{
	Time = number,
	Inside = true,
	Position = Vector3?,
	Velocity = Vector3?,
	Direction = Vector3?,
	Speed = number,
	Side = string?,
}
```

---

## playerExited

```lua
zone.playerExited:Connect(function(player, zone, transition)
	print(player.Name, "exited", zone.Name)
end)
```

---

## itemEntered

```lua
zone.itemEntered:Connect(function(instance, zone)
	print(instance.Name, "entered", zone.Name)
end)
```

---

## itemExited

```lua
zone.itemExited:Connect(function(instance, zone)
	print(instance.Name, "exited", zone.Name)
end)
```

---

## occupancyChanged

```lua
zone.occupancyChanged:Connect(function(occupancy, capacity, zone)
	print("Players:", occupancy)
	print("Capacity:", capacity)
end)
```

---

## partsChanged

```lua
zone.partsChanged:Connect(function(parts)
	print("Zone now has", #parts, "parts")
end)
```

This is useful for dynamic zone Models or Folders.

---

## enabledChanged

```lua
zone.enabledChanged:Connect(function(enabled)
	print("Enabled:", enabled)
end)
```

---

## destroying

```lua
zone.destroying:Connect(function(zone)
	print(zone.Name, "is being destroyed")
end)
```

---

# Signal API

Zone signals support:

```lua
signal:Connect(callback)
signal:Once(callback)
signal:Wait()
signal:Fire(...)
signal:Destroy()
```

Example:

```lua
zone.playerEntered:Once(function(player)
	print("First player:", player.Name)
end)
```

---

# Checking Players

## FindPlayer

Immediately checks the player's current geometry.

```lua
if zone:FindPlayer(player) then
	print("Player is geometrically inside")
end
```

---

## IsPlayerInside

Checks ZonePlusNext's tracked membership state.

```lua
if zone:IsPlayerInside(player) then
	print("Player is registered inside")
end
```

This includes enter/exit delay behavior.

---

## Contains

`Contains` provides a generic API.

```lua
zone:Contains(player)
zone:Contains(workspace.Part)
zone:Contains(Vector3.new(0, 10, 0))
```

---

## ContainsPoint

```lua
local inside = zone:ContainsPoint(
	Vector3.new(100, 20, 50)
)
```

---

# Getting Players

```lua
local players = zone:GetPlayers()

for _, player in ipairs(players) do
	print(player.Name)
end
```

---

# Player State

```lua
local state = zone:GetPlayerState(player)

print(state.Inside)
print(state.Pending)
print(state.PendingInside)
print(state.PendingSeconds)
print(state.EntryTime)
print(state.ExitTime)
print(state.TimeInside)
```

The returned structure is:

```lua
{
	Inside = boolean,
	Pending = boolean,
	PendingInside = boolean?,
	PendingSeconds = number,

	EntryTime = number?,
	ExitTime = number?,
	TimeInside = number,
}
```

---

# Occupancy

```lua
print(zone:GetOccupancy())
```

Additional helpers:

```lua
zone:IsEmpty()
zone:IsOccupied()
zone:IsFull()
zone:GetCapacity()
zone:GetRemainingCapacity()
zone:CanAcceptPlayer(player)
```

Example:

```lua
if zone:CanAcceptPlayer(player) then
	print("There is room")
else
	print("Zone is full")
end
```

---

# Capacity

```lua
zone:SetCapacity(20)
```

Remove the capacity limit:

```lua
zone:SetCapacity(nil)
```

Check:

```lua
if zone:IsFull() then
	print("Maximum occupancy reached")
end
```

---

# Enable / Disable

```lua
zone:Disable()
zone:Enable()
```

Or:

```lua
zone:SetEnabled(false)
zone:SetEnabled(true)
```

Toggle:

```lua
local enabled = zone:ToggleEnabled()
print(enabled)
```

Disabling a zone resolves current memberships and prevents it from reporting subjects as inside.

---

# Enter / Exit Delays

Border jitter can cause rapid enter/exit state changes.

ZonePlusNext supports independent transition delays:

```lua
local zone = ZonePlusNext.new(workspace.Zone, {
	EnterDelay = 0.1,
	ExitDelay = 0.2,
})
```

Change them later:

```lua
zone:SetDelays(0.1, 0.25)
```

Use the same value for both:

```lua
zone:SetDelays(0.15)
```

---

# Padding

Increase or decrease zone detection bounds.

```lua
zone:SetPadding(5)
```

Equivalent to:

```lua
zone:SetPadding(
	Vector3.new(5, 5, 5)
)
```

Per-axis padding:

```lua
zone:SetPadding(
	Vector3.new(5, 2, 10)
)
```

---

# Player Filtering

Zones can decide which players are eligible.

```lua
local zone = ZonePlusNext.new(workspace.VIPZone, {
	PlayerFilter = function(player)
		return player:GetAttribute("VIP") == true
	end,
})
```

Change it later:

```lua
zone:SetPlayerFilter(function(player)
	return player.Team
		and player.Team.Name == "Red"
end)
```

Remove the filter:

```lua
zone:SetPlayerFilter(nil)
```

---

# Dynamic Zone Containers

ZonePlusNext watches Instance-based containers and refreshes their zone parts when geometry changes.

You can also force a refresh:

```lua
zone:Refresh()
```

Retrieve the current zone parts:

```lua
local parts = zone:GetParts()
```

---

# Region Zones

Create a zone directly from a `CFrame` and `Vector3` size:

```lua
local zone = ZonePlusNext.fromRegion(
	CFrame.new(0, 10, 0),
	Vector3.new(100, 20, 100),
	{
		Name = "GeneratedRegion",
	}
)
```

The internal region Part is managed by ZonePlusNext.

---

# Tracking Arbitrary Objects

Zones are not limited to players.

Supported tracked objects include:

```text
BasePart
Model
Attachment
```

## Track an item

```lua
zone:TrackItem(workspace.Crate)
```

Immediate initial detection:

```lua
zone:TrackItem(workspace.Crate, true)
```

---

## Item events

```lua
zone.itemEntered:Connect(function(item)
	print(item.Name, "entered")
end)

zone.itemExited:Connect(function(item)
	print(item.Name, "exited")
end)
```

---

## Track many items

```lua
zone:TrackItems({
	workspace.Crate1,
	workspace.Crate2,
	workspace.Crate3,
}, true)
```

---

## Untrack

```lua
zone:UntrackItem(workspace.Crate)
```

Or:

```lua
zone:UntrackItems({
	workspace.Crate1,
	workspace.Crate2,
})
```

---

## Item state

```lua
local state = zone:GetItemState(workspace.Crate)

print(state.Tracked)
print(state.Inside)
print(state.Pending)
```

---

## Get items currently inside

```lua
local items = zone:GetItems()
```

---

# Tags

Tags make it easy to organize large groups of zones.

```lua
local zone = ZonePlusNext.new(workspace.SafeZone, {
	Tags = {
		"Safe",
		"Spawn",
		"NoCombat",
	},
})
```

---

## Add Tags

```lua
zone:AddTag("Lobby")
```

Or:

```lua
zone:AddTags({
	"Safe",
	"Protected",
})
```

---

## Remove Tags

```lua
zone:RemoveTag("Safe")
```

```lua
zone:RemoveTags({
	"Safe",
	"Protected",
})
```

---

## Replace Tags

```lua
zone:SetTags({
	"Combat",
	"PVP",
})
```

---

## Check Tags

```lua
zone:HasTag("Combat")
zone:HasAnyTag({"Combat", "Danger"})
zone:HasAllTags({"Combat", "PVP"})
```

Get all tags:

```lua
local tags = zone:GetTags()
```

---

# Global Tag Queries

```lua
local combatZones =
	ZonePlusNext.GetZonesByTag("Combat")
```

Require all tags:

```lua
local zones = ZonePlusNext.GetZonesByTags({
	"Combat",
	"Outdoor",
})
```

Match any tag:

```lua
local zones = ZonePlusNext.GetZonesByTags({
	"Combat",
	"Safe",
}, false)
```

---

# Player Tag Queries

Check whether a player is in a zone with a tag:

```lua
if ZonePlusNext.IsPlayerInTag(player, "Safe") then
	print("Player is safe")
end
```

Other helpers:

```lua
ZonePlusNext.IsPlayerInAnyTag(player, {
	"Safe",
	"Lobby",
})

ZonePlusNext.IsPlayerInAllTags(player, {
	"Combat",
	"PVP",
})

ZonePlusNext.GetPlayerTags(player)
ZonePlusNext.GetPlayersByTag("Safe")
ZonePlusNext.CountPlayersByTag("Safe")
```

Find the player's highest-priority matching zone:

```lua
local zone =
	ZonePlusNext.GetPlayerZoneByTag(
		player,
		"Combat"
	)
```

---

# Priorities

Zones can overlap.

Priority gives you deterministic ordering for overlapping zones.

```lua
local lobby = ZonePlusNext.new(workspace.Lobby, {
	Priority = 1,
})

local shop = ZonePlusNext.new(workspace.Shop, {
	Priority = 10,
})
```

Get the player's highest-priority zone:

```lua
local zone =
	ZonePlusNext.GetHighestPriorityZone(player)

if zone then
	print(zone.Name)
end
```

Get every zone containing a player:

```lua
local zones =
	ZonePlusNext.GetZonesForPlayer(player)
```

---

# Zone Registry

Get every zone:

```lua
local zones = ZonePlusNext.GetZones()
```

Find by name:

```lua
local zone =
	ZonePlusNext.GetByName("SafeZone")
```

Get every zone sharing a name:

```lua
local zones =
	ZonePlusNext.GetAllByName("SafeZone")
```

Count zones:

```lua
print(ZonePlusNext.GetZoneCount())
```

Enabled zones only:

```lua
print(ZonePlusNext.GetZoneCount(true))
```

---

# Zone Query Engine

ZonePlusNext provides several spatial zone-query functions.

---

## QueryPoint

Find zones containing a position.

```lua
local zones = ZonePlusNext.QueryPoint(
	Vector3.new(0, 10, 0)
)
```

---

## QueryRadius

```lua
local zones = ZonePlusNext.QueryRadius(
	Vector3.new(0, 0, 0),
	100
)
```

---

## QueryBox

```lua
local zones = ZonePlusNext.QueryBox(
	CFrame.new(0, 10, 0),
	Vector3.new(100, 20, 100)
)
```

---

## QueryPart

```lua
local zones =
	ZonePlusNext.QueryPart(workspace.Detector)
```

---

## QueryRay

```lua
local zones = ZonePlusNext.QueryRay(
	workspace.Camera.CFrame.Position,
	workspace.Camera.CFrame.LookVector * 500
)
```

---

## QueryPath

Find zones intersecting a path.

```lua
local zones = ZonePlusNext.QueryPath(
	Vector3.new(0, 5, 0),
	Vector3.new(500, 5, 0)
)
```

Useful for:

```text
Projectiles
NPC movement
Roads
Navigation
Fast-moving objects
Teleport paths
```

---

# Zone Query Filters

Most zone queries accept:

```lua
{
	RequireTags = {"Combat"},
	ExcludeTags = {"Disabled"},

	MinPriority = 5,
	MaxPriority = 100,

	MinOccupancy = 1,
	MaxOccupancy = 20,

	Full = false,
	Enabled = true,

	Limit = 10,

	Precision = "Bounds",
}
```

Supported precision modes:

```text
Broad
Bounds
Exact
```

Example:

```lua
local zones = ZonePlusNext.QueryRadius(
	Vector3.new(0, 0, 0),
	500,
	{
		RequireTags = {"Shop"},
		Enabled = true,
		MinPriority = 5,
		Limit = 10,
	}
)
```

---

# QueryZones

Query the global zone registry without a spatial requirement.

```lua
local zones = ZonePlusNext.QueryZones({
	RequireTags = {"Combat"},
	MinPriority = 10,
	Enabled = true,
	Limit = 5,
})
```

---

# Zone Overlap

Find zones overlapping another zone:

```lua
local overlapping =
	ZonePlusNext.GetOverlappingZones(zone)
```

From a zone instance:

```lua
local nearby = zone:GetNearbyZones(100)
```

---

# Nearest Zones

```lua
local zone, distance =
	ZonePlusNext.GetNearestZone(
		Vector3.new(0, 0, 0)
	)

if zone then
	print(zone.Name, distance)
end
```

A Player can also be supplied:

```lua
local zone, distance =
	ZonePlusNext.GetNearestZone(player)
```

Retrieve multiple:

```lua
local zones =
	ZonePlusNext.GetNearestZones(
		Vector3.new(0, 0, 0),
		5
	)
```

---

# Player Spatial Queries

## Players in radius

```lua
local players =
	ZonePlusNext.QueryPlayersInRadius(
		Vector3.new(0, 0, 0),
		100
	)
```

---

## Players in box

```lua
local players =
	ZonePlusNext.QueryPlayersInBox(
		CFrame.new(0, 10, 0),
		Vector3.new(100, 20, 100)
	)
```

---

## Nearest players

```lua
local players =
	ZonePlusNext.GetNearestPlayers(
		Vector3.new(0, 0, 0),
		5
	)
```

You can also use a zone:

```lua
local players =
	ZonePlusNext.GetNearestPlayers(
		zone,
		5
	)
```

---

# Fluent Player Query Builder

ZonePlusNext includes a chainable query system.

```lua
local players = ZonePlusNext.QueryPlayers()
	:Inside(combatZone)
	:SpeedAbove(10)
	:InZoneTag("Combat")
	:SortByDistance(Vector3.zero)
	:Limit(10)
	:Execute()
```

Available filters include:

```lua
:Inside(zone)
:Outside(zone)

:InsideFor(zone, seconds)
:WasInside(zone, secondsAgo)
:EnteredWithin(zone, seconds)
:ExitedWithin(zone, seconds)

:WithinRadius(position, radius)
:WithinBox(cframe, size)

:SpeedAbove(speed)
:SpeedBelow(speed)

:InZoneTag(tag)
:NotInZoneTag(tag)
:InAnyZoneTag(tags)
:InAllZoneTags(tags)

:VisibleFrom(origin, options)

:And(predicate)
:Not(predicate)
:Or(predicate)

:SortByDistance(position)
:Limit(count)

:Execute()
```

---

# Query Builder Example

Find players who:

* are inside a combat zone,
* have been inside for at least 5 seconds,
* are moving at least 16 studs/second,
* are within 200 studs,
* and return only the nearest 10.

```lua
local origin = Vector3.new(0, 0, 0)

local players = ZonePlusNext.QueryPlayers()
	:Inside(combatZone)
	:InsideFor(combatZone, 5)
	:SpeedAbove(16)
	:WithinRadius(origin, 200)
	:SortByDistance(origin)
	:Limit(10)
	:Execute()
```

---

# Compound Query API

The same system can be used declaratively.

```lua
local players = ZonePlusNext.Query({
	Type = "Players",

	Spatial = {
		Zone = combatZone,
		Position = Vector3.zero,
		Radius = 250,
	},

	Temporal = {
		InsideFor = 5,
	},

	Velocity = {
		Min = 10,
		Max = 100,
	},

	ZoneTag = "Combat",

	SortByDistance = Vector3.zero,
	Limit = 10,
})
```

Zone queries can also use it:

```lua
local zones = ZonePlusNext.Query({
	Type = "Zones",

	RequireTags = {
		"Combat",
	},

	Enabled = true,
	MinPriority = 5,
	Limit = 10,
})
```

---

# Transition History

ZonePlusNext stores bounded player enter/exit history.

```lua
local history =
	zone:GetPlayerHistory(player)

for _, transition in ipairs(history) do
	print(
		transition.Time,
		transition.Inside,
		transition.Speed,
		transition.Side
	)
end
```

Limit by recent time:

```lua
local history =
	zone:GetPlayerHistory(player, 10)
```

This returns transitions from approximately the last 10 seconds.

---

# Temporal Queries

## Entry time

```lua
local time = zone:GetEntryTime(player)
```

---

## Exit time

```lua
local time = zone:GetExitTime(player)
```

---

## Time currently inside

```lua
local seconds =
	zone:GetTimeInside(player)
```

---

## Inside for duration

```lua
if zone:InsideFor(player, 10) then
	print("Player has been here for 10 seconds")
end
```

---

## Was inside

```lua
if zone:WasPlayerInside(player, 5) then
	print("Player was inside 5 seconds ago")
end
```

---

## Entered recently

```lua
if zone:EnteredWithin(player, 3) then
	print("Player entered within 3 seconds")
end
```

---

## Exited recently

```lua
if zone:ExitedWithin(player, 3) then
	print("Player exited within 3 seconds")
end
```

---

## Crossed zone

```lua
if zone:CrossedBy(player, 5) then
	print("Player crossed this zone recently")
end
```

---

## Players active during a time window

```lua
local players =
	zone:GetPlayersDuring(10)
```

Or:

```lua
local players =
	ZonePlusNext.QueryDuring(zone, 10)
```

---

# Entry Direction

Transitions can report which side of the zone the player entered from.

```lua
local transition =
	zone:GetEntryDirection(player)

if transition then
	print(transition.Side)
end
```

Possible sides include:

```text
East
West
Top
Bottom
North
South
```

Find players entering from one side:

```lua
local players =
	zone:GetPlayersEnteringFrom(
		"North",
		5
	)
```

---

# Position History

Position history is optional.

Enable it globally:

```lua
ZonePlusNext.EnableHistory({
	Position = true,
	Duration = 5,
	SampleRate = 20,
	TransitionLimit = 64,
})
```

Configuration:

```lua
{
	Position = boolean?,
	Duration = number?,
	SampleRate = number?,
	TransitionLimit = number?,
}
```

`SampleRate` supports up to `240`.

---

## Read configuration

```lua
local config =
	ZonePlusNext.GetHistoryConfig()
```

---

## Position samples

```lua
local history =
	ZonePlusNext.GetPositionHistory(player)

for _, sample in ipairs(history) do
	print(
		sample.Time,
		sample.Position,
		sample.Velocity
	)
end
```

---

## Historical position

Retrieve an interpolated position and velocity:

```lua
local position, velocity =
	ZonePlusNext.GetPositionAt(
		player,
		1.5
	)
```

This asks:

```text
Where was this player approximately 1.5 seconds ago?
```

Potential uses include:

* lag compensation
* rewind checks
* anti-cheat analysis
* replay systems
* hit validation
* movement analysis

---

## Clear History

One player:

```lua
ZonePlusNext.ClearHistory(player)
```

Everything:

```lua
ZonePlusNext.ClearHistory()
```

---

# Prediction

ZonePlusNext includes constant-velocity prediction helpers.

## PredictPosition

```lua
local predicted =
	ZonePlusNext.PredictPosition(
		player,
		2
	)
```

Predicts where the player would be after two seconds based on current velocity.

---

## PredictPlayerEntry

```lua
local prediction =
	zone:PredictPlayerEntry(
		player,
		3
	)

if prediction.WillEnter then
	print(
		"Expected entry in",
		prediction.Time,
		"seconds"
	)
end
```

Result:

```lua
{
	WillEnter = boolean,
	Time = number?,
	Position = Vector3?,
	Velocity = Vector3,
}
```

Custom prediction sampling:

```lua
local prediction =
	zone:PredictPlayerEntry(
		player,
		3,
		0.05
	)
```

---

# Predicting Arbitrary Objects

```lua
local projectile = workspace.Projectile

local result = zone:PredictIntersection(
	projectile,
	projectile.AssemblyLinearVelocity,
	2
)

if result.WillEnter then
	print(
		"Projectile will reach zone in",
		result.Time
	)
end
```

---

# Visibility Queries

Find visible players from a world position:

```lua
local visible =
	ZonePlusNext.QueryVisible(
		Vector3.new(0, 20, 0)
	)
```

Check one player:

```lua
local visible =
	zone:CanSeePlayer(
		player,
		Vector3.new(0, 20, 0)
	)
```

Options can include:

```lua
{
	IgnoreInstances = {
		workspace.IgnoreFolder,
	},

	MaxDistance = 500,
}
```

---

# Spatial Hash

ZonePlusNext maintains a shared player spatial hash.

Configure it globally:

```lua
ZonePlusNext.ConfigureSpatialHash({
	Enabled = true,
	CellSize = 64,
	MaxQueryCells = 2048,
	MaxPlayerCells = 128,
	BruteForceThreshold = 24,
})
```

Read configuration:

```lua
local config =
	ZonePlusNext.GetSpatialConfig()
```

Force rebuild:

```lua
ZonePlusNext.RebuildSpatialIndex()
```

The spatial hash reduces the number of players that need precise geometry checks for large worlds.

---

# Zone Spatial Index

ZonePlusNext also maintains a separate zone index.

```lua
ZonePlusNext.ConfigureZoneIndex({
	Enabled = true,
	CellSize = 128,
	MaxQueryCells = 4096,
	MaxZoneCells = 256,
	BruteForceThreshold = 64,
})
```

Read configuration:

```lua
local config =
	ZonePlusNext.GetZoneIndexConfig()
```

Rebuild:

```lua
ZonePlusNext.RebuildZoneIndex()
```

Warm both player and zone indexes:

```lua
ZonePlusNext.WarmIndexes()
```

---

# Zone Index Modes

Each zone supports:

```text
Auto
Static
Dynamic
```

## Auto

```lua
IndexMode = "Auto"
```

Recommended default.

A zone can begin in the static index and automatically promote to dynamic behavior if its geometry changes.

---

## Static

```lua
IndexMode = "Static"
```

Best for geometry that does not move or change.

Static zones use the static packed spatial tree.

---

## Dynamic

```lua
IndexMode = "Dynamic"
```

Best for moving or frequently changing zones.

Dynamic zones use the incrementally updated dynamic spatial grid.

---

## Change index mode

```lua
zone:SetIndexMode("Dynamic")
```

Inspect configured and effective modes:

```lua
local configured, effective =
	zone:GetIndexMode()

print(configured, effective)
```

---

# Shared Scheduler

All zones are processed by a shared Heartbeat scheduler instead of creating an independent loop for every zone.

Configure it globally:

```lua
ZonePlusNext.ConfigureScheduler({
	ActiveOnly = true,
	FrameBudgetMs = 1,
	MaxStepsPerFrame = 0,
})
```

`MaxStepsPerFrame = 0` means no explicit step-count limit.

---

## Scheduler Budget

```lua
ZonePlusNext.SetSchedulerBudget(1.5)
```

The value is in milliseconds.

---

## Scheduler Configuration

```lua
local config =
	ZonePlusNext.GetSchedulerConfig()

print(config.ActiveOnly)
print(config.FrameBudgetMs)
print(config.MaxStepsPerFrame)
```

---

# Manual Step

A zone can be checked immediately:

```lua
zone:StepNow()
```

Useful when you need an immediate state refresh instead of waiting for its next scheduled update.

---

# Batch Creation

Creating many zones individually can repeatedly update the shared registry.

ZonePlusNext supports batching.

```lua
local zones = ZonePlusNext.CreateMany({
	workspace.Zone1,
	workspace.Zone2,
	workspace.Zone3,
}, {
	Detection = "Center",
	Tags = {"WorldZone"},
})
```

Or manually:

```lua
ZonePlusNext.BeginBatch()

local a = ZonePlusNext.new(workspace.ZoneA)
local b = ZonePlusNext.new(workspace.ZoneB)
local c = ZonePlusNext.new(workspace.ZoneC)

ZonePlusNext.EndBatch()
```

Recommended:

```lua
ZonePlusNext.Batch(function()
	ZonePlusNext.new(workspace.ZoneA)
	ZonePlusNext.new(workspace.ZoneB)
	ZonePlusNext.new(workspace.ZoneC)
end)
```

`Batch` safely ends the batch even when the callback errors.

---

# Apply Multiple Settings

Instead of calling many setters:

```lua
zone:Apply({
	Name = "UpdatedZone",
	Detection = "Bounds",
	Padding = 2,
	Priority = 15,
	Capacity = 50,
	Tags = {
		"Combat",
		"Outdoor",
	},
	IndexMode = "Auto",
})
```

---

# Global Zone Management

Enable matching zones:

```lua
local changed =
	ZonePlusNext.SetZonesEnabled(
		true,
		{
			RequireTags = {
				"Event",
			},
		}
	)

print(changed)
```

Disable them:

```lua
ZonePlusNext.SetZonesEnabled(false, {
	RequireTags = {"Event"},
})
```

Destroy matching zones:

```lua
local destroyed =
	ZonePlusNext.DestroyZones({
		RequireTags = {
			"Temporary",
		},
	})
```

---

# Statistics

ZonePlusNext exposes several statistics systems for debugging and profiling.

---

# Per-Zone Stats

```lua
local stats = zone:GetStats()

print(stats.Checks)
print(stats.Hits)
print(stats.Misses)
print(stats.Enters)
print(stats.Exits)
print(stats.Errors)

print(stats.BroadPhaseQueries)
print(stats.BroadPhaseFallbacks)

print(stats.CandidatePlayers)
print(stats.PrecisePlayerChecks)
print(stats.CellsVisited)

print(stats.LastCheckSeconds)
print(stats.TotalCheckSeconds)
```

Reset:

```lua
zone:ResetStats()
```

---

# Global Stats

```lua
local stats =
	ZonePlusNext.GetGlobalStats()
```

Includes information such as:

```text
Version
Zones
EnabledZones
ActivePlayerMemberships
TrackedItems

SchedulerTicks
Checks
Errors

BroadPhaseQueries
BroadPhaseFallbacks
CandidatePlayers
PrecisePlayerChecks
CellsVisited

SpatialRebuilds
SpatialBuckets
IndexedPlayers

ZoneIndexRebuilds
ZoneIndexBuckets
IndexedZones
OversizedZones

StaticIndexNodes
StaticIndexedZones
DynamicIndexedZones
AutoPromotions

SchedulerCandidateZones
SchedulerSkippedZones
SchedulerSteps
SchedulerDeferredZones
SchedulerBudgetHits
SchedulerStepLimitHits
SchedulerBudgetOverruns

SchedulerLastFrameSeconds
SchedulerPeakFrameSeconds

TotalCheckSeconds
```

Reset:

```lua
ZonePlusNext.ResetGlobalStats()
```

---

# Scheduler Stats

```lua
local stats =
	ZonePlusNext.GetSchedulerStats()
```

Includes:

```text
Ticks
FrameBudgetMs
MaxStepsPerFrame
Steps
CandidateZones
SkippedZones
DeferredZones
BudgetHits
StepLimitHits
BudgetOverruns
LastFrameSeconds
PeakFrameSeconds
LastCandidateSeconds
PeakCandidateSeconds
LastWorkSeconds
PeakWorkSeconds
```

Reset:

```lua
ZonePlusNext.ResetSchedulerStats()
```

---

# Index Stats

```lua
local stats =
	ZonePlusNext.GetIndexStats()

print(stats.Player.IndexedPlayers)
print(stats.Player.Buckets)

print(stats.Zone.StaticZones)
print(stats.Zone.DynamicZones)
print(stats.Zone.StaticNodes)
print(stats.Zone.AutoPromotions)
```

---

# Query Stats

```lua
local stats =
	ZonePlusNext.GetQueryStats()

print(stats.Executions)
print(stats.Candidates)
print(stats.Results)
print(stats.VisibilityRays)
print(stats.ExactOverlapQueries)
print(stats.PredictionSamples)
print(stats.PositionSamples)
print(stats.ZoneIndexQueries)
print(stats.ZoneIndexFallbacks)
print(stats.ZoneCellsVisited)
```

Reset:

```lua
ZonePlusNext.ResetQueryStats()
```

---

# Compact Statistics

For a quick debug summary:

```lua
print(
	ZonePlusNext.GetCompactStats()
)
```

Or:

```lua
ZonePlusNext.PrintStats()
```

Example format:

```text
[ZonePlusNext v1.2.1] zones=...
```

---

# Zone Information

```lua
local info = zone:GetInfo()

print(info.Name)
print(info.Enabled)
print(info.Priority)
print(info.Occupancy)
print(info.Capacity)
print(info.Full)
print(info.PartCount)

for _, tag in ipairs(info.Tags) do
	print(tag)
end
```

---

# Example: Safe Zone

```lua
local ZonePlusNext = require(path.to.ZonePlusNext)

local zone = ZonePlusNext.new(
	workspace.SafeZone,
	{
		Name = "SafeZone",

		Detection = "Bounds",

		EnterDelay = 0.1,
		ExitDelay = 0.15,

		Priority = 100,

		Tags = {
			"Safe",
			"NoCombat",
		},

		IndexMode = "Auto",
	}
)

zone.playerEntered:Connect(
	function(player)
		player:SetAttribute(
			"InSafeZone",
			true
		)

		print(
			player.Name,
			"entered the safe zone"
		)
	end
)

zone.playerExited:Connect(
	function(player)
		player:SetAttribute(
			"InSafeZone",
			false
		)

		print(
			player.Name,
			"left the safe zone"
		)
	end
)
```

---

# Example: Limited Shop

```lua
local shop = ZonePlusNext.new(
	workspace.Shop,
	{
		Name = "Shop",

		Capacity = 10,
		Priority = 25,

		Tags = {
			"Shop",
			"Indoor",
		},
	}
)

shop.playerEntered:Connect(
	function(player)
		print(
			player.Name,
			"entered shop"
		)

		print(
			"Occupancy:",
			shop:GetOccupancy(),
			"/",
			shop:GetCapacity()
		)
	end
)

if shop:IsFull() then
	print("Shop is currently full")
end
```

---

# Example: Projectile Prediction

```lua
local projectile =
	workspace.Projectile

local result =
	combatZone:PredictIntersection(
		projectile,
		projectile.AssemblyLinearVelocity,
		3,
		0.025
	)

if result.WillEnter then
	print(
		"Impact zone intersection in:",
		result.Time
	)

	print(
		"Predicted position:",
		result.Position
	)
end
```

---

# Example: Advanced Player Query

```lua
local origin =
	Vector3.new(0, 0, 0)

local targets =
	ZonePlusNext.QueryPlayers()
		:Inside(combatZone)
		:InZoneTag("Combat")
		:SpeedAbove(5)
		:WithinRadius(origin, 300)
		:VisibleFrom(origin, {
			MaxDistance = 300,
		})
		:SortByDistance(origin)
		:Limit(10)
		:Execute()

for _, player in ipairs(targets) do
	print(player.Name)
end
```

---

# Example: History + Rewind

```lua
ZonePlusNext.EnableHistory({
	Position = true,
	Duration = 3,
	SampleRate = 30,
	TransitionLimit = 64,
})

local oldPosition, oldVelocity =
	ZonePlusNext.GetPositionAt(
		player,
		0.25
	)

if oldPosition then
	print(
		"Player position 250ms ago:",
		oldPosition
	)
end
```

---

# Performance Recommendations

For most games, keep the defaults first:

```lua
Detection = "Center"
BroadPhase = true
IndexMode = "Auto"
```

Use `"Bounds"` when center-only detection is not sufficient.

Use `"AnyPart"` or `"WholeCharacter"` only when the extra character-part precision is important.

For large numbers of zones:

```lua
ZonePlusNext.ConfigureZoneIndex({
	Enabled = true,
})
```

For large player counts:

```lua
ZonePlusNext.ConfigureSpatialHash({
	Enabled = true,
})
```

When creating many zones at once:

```lua
ZonePlusNext.CreateMany(...)
```

or:

```lua
ZonePlusNext.Batch(...)
```

Avoid extremely small `UpdateInterval` values unless the gameplay actually requires them.

Position history also has an ongoing sampling cost, so only enable it when temporal or rewind queries are needed.

---

# Cleanup

Always destroy zones that are no longer required.

```lua
zone:Destroy()
```

Destroying a zone:

* commits final exits,
* disconnects container connections,
* disconnects tracked-item connections,
* clears player membership,
* clears transition history,
* clears tracked items,
* removes the zone from indexes,
* removes the zone from the global registry,
* destroys its signals,
* stops the shared scheduler when no zones remain.

---

# Compatibility Aliases

ZonePlusNext includes lowercase compatibility aliases for easier migration.

For example:

```lua
zone:findPlayer(player)
zone:findItem(instance)
zone:contains(subject)

zone:enable()
zone:disable()

zone:setDetection("Bounds")
zone:setEnabled(true)
zone:setBroadPhase(true)

zone:trackItem(instance)
zone:untrackItem(instance)

ZonePlusNext.queryPoint(position)
ZonePlusNext.queryRadius(position, radius)
ZonePlusNext.queryBox(cframe, size)
ZonePlusNext.queryPart(part)
ZonePlusNext.queryRay(origin, direction)
ZonePlusNext.queryPath(startPosition, endPosition)

ZonePlusNext.queryPlayers()

ZonePlusNext.getNearestZone(position)
ZonePlusNext.getNearestPlayers(position)

ZonePlusNext.getZonesByTag(tag)
ZonePlusNext.getZonesForPlayer(player)

ZonePlusNext.configureScheduler(config)
ZonePlusNext.getSchedulerStats()

ZonePlusNext.warmIndexes()
```

The PascalCase API is recommended for new code.

---

# Core API Summary

### Creation

```lua
ZonePlusNext.new(container, options?)
ZonePlusNext.fromRegion(cframe, size, options?)
ZonePlusNext.CreateMany(containers, options?)
ZonePlusNext.Batch(callback)
```

### Zone Detection

```lua
zone:Contains(subject)
zone:ContainsPoint(position)
zone:FindPlayer(player)
zone:FindItem(instance)

zone:IsPlayerInside(player)
zone:IsItemInside(instance)
```

### Membership

```lua
zone:GetPlayers()
zone:GetItems()
zone:GetPlayerState(player)
zone:GetItemState(instance)

zone:GetOccupancy()
zone:IsEmpty()
zone:IsOccupied()
zone:IsFull()
zone:GetRemainingCapacity()
```

### Tracking

```lua
zone:TrackItem(instance, immediate?)
zone:UntrackItem(instance, fireExit?)
zone:TrackItems(instances, immediate?)
zone:UntrackItems(instances, fireExit?)
```

### Configuration

```lua
zone:SetName(name)
zone:SetEnabled(enabled)
zone:SetTrackPlayers(enabled)
zone:SetIndexMode(mode)
zone:SetBroadPhase(enabled)
zone:SetUpdateInterval(seconds)
zone:SetDetection(mode)
zone:SetPadding(padding)
zone:SetDelays(enterDelay, exitDelay?)
zone:SetPlayerFilter(filter)
zone:SetPriority(priority)
zone:SetCapacity(capacity)
zone:Apply(options)
```

### Tags

```lua
zone:AddTag(tag)
zone:RemoveTag(tag)
zone:AddTags(tags)
zone:RemoveTags(tags)
zone:SetTags(tags)

zone:HasTag(tag)
zone:HasAnyTag(tags)
zone:HasAllTags(tags)
zone:GetTags()
```

### Zone Queries

```lua
ZonePlusNext.QueryZones(options?)
ZonePlusNext.QueryPoint(point, options?)
ZonePlusNext.QueryRadius(position, radius, options?)
ZonePlusNext.QueryBox(cframe, size, options?)
ZonePlusNext.QueryPart(part, options?)
ZonePlusNext.QueryRay(origin, direction, options?)
ZonePlusNext.QueryPath(startPosition, endPosition, options?)

ZonePlusNext.GetOverlappingZones(zone, options?)
ZonePlusNext.GetNearestZone(subject, options?)
ZonePlusNext.GetNearestZones(position, count?, options?)
```

### Player Queries

```lua
ZonePlusNext.QueryPlayers()
ZonePlusNext.QueryPlayersInRadius(position, radius)
ZonePlusNext.QueryPlayersInBox(cframe, size)
ZonePlusNext.GetNearestPlayers(subject, count?)
ZonePlusNext.QueryVisible(origin, players?, options?)
```

### History

```lua
ZonePlusNext.EnableHistory(config?)
ZonePlusNext.GetHistoryConfig()
ZonePlusNext.GetPositionHistory(player)
ZonePlusNext.GetPositionAt(player, secondsAgo)
ZonePlusNext.ClearHistory(player?)

zone:GetPlayerHistory(player, withinSeconds?)
zone:GetEntryTime(player)
zone:GetExitTime(player)
zone:GetTimeInside(player)
zone:InsideFor(player, seconds)
zone:WasPlayerInside(player, secondsAgo)
zone:EnteredWithin(player, seconds)
zone:ExitedWithin(player, seconds)
zone:CrossedBy(player, seconds?)
```

### Prediction

```lua
ZonePlusNext.PredictPosition(player, seconds)

zone:PredictPlayerEntry(
	player,
	horizon,
	step?
)

zone:PredictIntersection(
	instance,
	velocity,
	horizon,
	step?
)
```

### Performance

```lua
ZonePlusNext.ConfigureScheduler(config)
ZonePlusNext.GetSchedulerConfig()
ZonePlusNext.GetSchedulerStats()

ZonePlusNext.ConfigureSpatialHash(config)
ZonePlusNext.GetSpatialConfig()
ZonePlusNext.RebuildSpatialIndex()

ZonePlusNext.ConfigureZoneIndex(config)
ZonePlusNext.GetZoneIndexConfig()
ZonePlusNext.RebuildZoneIndex()

ZonePlusNext.WarmIndexes()
ZonePlusNext.GetIndexStats()
```

### Statistics

```lua
zone:GetStats()
zone:ResetStats()

ZonePlusNext.GetGlobalStats()
ZonePlusNext.ResetGlobalStats()

ZonePlusNext.GetSchedulerStats()
ZonePlusNext.ResetSchedulerStats()

ZonePlusNext.GetQueryStats()
ZonePlusNext.ResetQueryStats()

ZonePlusNext.GetCompactStats()
ZonePlusNext.PrintStats()
```

### Cleanup

```lua
zone:Destroy()

ZonePlusNext.DestroyZones(options?)
```

---

# Version

```text
ZonePlusNext v1.2.1
```

Check at runtime:

```lua
print(ZonePlusNext.Version())
```

---

## Why ZonePlusNext?

Traditional Roblox zone systems often revolve around individual loops, `Touched` events, or repeated full-player scans.

ZonePlusNext is designed around shared infrastructure:

```text
Players
   │
   ▼
Player Spatial Hash
   │
   ▼
Shared Scheduler
   │
   ├── Static Zone Index
   │
   └── Dynamic Zone Index
           │
           ▼
     Candidate Zones
           │
           ▼
    Precise Detection
           │
           ▼
 Enter / Exit / History
```

This allows the same system to handle ordinary player zones while also supporting more advanced workloads such as:

* large maps,
* many simultaneous zones,
* overlapping regions,
* dynamic zones,
* moving objects,
* projectile prediction,
* rewind/history systems,
* zone-based AI,
* visibility filtering,
* spatial searches,
* tagged world regions,
* and performance diagnostics.

**ZonePlusNext is built to be a complete spatial-zone framework rather than only an enter/exit detector.**
