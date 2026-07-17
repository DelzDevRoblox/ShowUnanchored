--!strict

--[[

  ShowUnanchored plugin by DelzDev (@RenanMSV) at xMoon Games Studios
  Since July 2026.

  A Roblox plugin to show unanchored parts in the workspace

]]

local CollectionService = game:GetService("CollectionService")

local toolbar = plugin:CreateToolbar("ShowUnanchoredPlugin")

local ICON_SHOW = "rbxassetid://93917691212732"
local ICON_HIDE = "rbxassetid://101655275937723"
local ICON_GIZMO = "rbxassetid://94876904753668"
local TAG = "ToggleUnanchoredTBOFD2026"

local isOn = false

local button: PluginToolbarButton = toolbar:CreateButton(
  "Show unanchored",
  "Toggles viewing unanchored parts.",
  ICON_HIDE
)
button.ClickableWhenViewportHidden = true

local function calcBillboardSize(): UDim2
  -- Calculates the billboard size based on the current ViewportSize.
  -- Choosed not to watch ViewportSize changes.
  local cam = workspace.CurrentCamera
  if not cam then return UDim2.fromOffset(10, 10) end -- fallback billboard size
  local size = math.round(cam.ViewportSize.X / 100)
  return UDim2.fromOffset(size, size)
end

local function putTag(part: BasePart, billboardSize: UDim2)
  if part:FindFirstChild("UnanchoredBillboardTBOFD2026") then
    return
  end

  local billboard = script.UnanchoredBillboardTBOFD2026:Clone()
  billboard.Size = billboardSize
  billboard.Icon.Image = ICON_GIZMO
  billboard:AddTag(TAG)
  billboard.Parent = part
end

local function onPluginButtonClicked()
  -- shows unanchored baseparts
  -- by cloning the billboard and placing it in the part
  local billboardSize = calcBillboardSize()
  for _, instance: Instance in pairs(workspace:GetDescendants()) do
    if instance:IsA("BasePart") then
      if instance.Anchored == false then
        putTag(instance, billboardSize)
      end
    end
  end
end

local function onPluginUndoClicked()
  -- deletes all billboards cloned by the show button
  -- by search for the billboardgui unique tag
  for _, instance: Instance in pairs(CollectionService:GetTagged(TAG)) do
    if instance:IsA("BillboardGui") and instance.Name == "UnanchoredBillboardTBOFD2026" then
      instance:Destroy()
    end
  end
end

button.Click:Connect(function()
  if isOn then
    onPluginUndoClicked()
    button.Icon = ICON_HIDE
    button:SetActive(false)
  else
    onPluginButtonClicked()
    button.Icon = ICON_SHOW
    button:SetActive(true)
  end
  isOn = not isOn
end)

-- when unloading the plugin we must clear instances and reset the button
plugin.Unloading:Connect(function ()
  if isOn then
    onPluginUndoClicked()
    button:SetActive(false)
    button.Icon = ICON_HIDE
    isOn = false
  end
end)

-- we call this once we start to remove instances leftover
-- from broken sessions such as studio crashes, autosaves etc...
onPluginUndoClicked()
