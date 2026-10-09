--!strict
-- Studio regression: place this Script beside the ZonePlus ModuleScript in
-- ServerScriptService. Run under Play/Run and check Output for PASS.
local ZonePlus = require(script.Parent:WaitForChild("ZonePlus"))
local Workspace = game:GetService("Workspace")

local folder = Instance.new("Folder")
folder.Name = "ZonePlusRegression"
folder.Parent = Workspace
local rotated = Instance.new("Part")
rotated.Size = Vector3.new(20, 1, 1)
rotated.Anchored = true
rotated.CanCollide = false
rotated.CFrame = CFrame.Angles(0, math.rad(45), 0)
rotated.Parent = folder
local zone = ZonePlus.new(rotated, {TrackPlayers = false})

-- This small segment lies inside the world-aligned bounding box but well
-- outside the actual rotated thin part. AABB-only ray hits were false positives.
local missOrigin = Vector3.new(-6, 0, -6)
local missVector = Vector3.new(0.5, 0, 0)
for _, hit in ipairs(ZonePlus.QueryRay(missOrigin, missVector)) do
    assert(hit ~= zone, "Rotated part: false-positive ray hit")
end

local hitOrigin = Vector3.new(-20, 0, 0)
local hitVector = Vector3.new(40, 0, 0)
local sawHit = false
for _, hit in ipairs(ZonePlus.QueryRay(hitOrigin, hitVector)) do
    if hit == zone then sawHit = true end
end
assert(sawHit, "Expected real ray hit")

-- Moving a part out and back into a Folder zone must restore it.
zone:Destroy()
local folderZone = ZonePlus.new(folder, {TrackPlayers = false})
local middle = rotated.Position
assert(folderZone:ContainsPoint(middle), "Initial point not contained")
rotated.Parent = nil
task.wait()
folderZone:Refresh()
assert(not folderZone:ContainsPoint(middle), "Removed part still detected")
rotated.Parent = folder
task.wait()
folderZone:Refresh()
assert(folderZone:ContainsPoint(middle), "Reparented part never recovered")

folderZone:Destroy()
folder:Destroy()
print("ZonePlusNext v1.2.2 regression PASS")
