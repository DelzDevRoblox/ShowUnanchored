--!strict

--[[

  ShowUnanchored plugin by DelzDev (@RenanMSV) at xMoon Games Studios
  Since July 2026.

  A Roblox plugin to show unanchored parts in the workspace

]]

local CoreGui = game:GetService("CoreGui")

local toolbar = plugin:CreateToolbar("ShowUnanchoredPlugin")

local PLUGIN_VERSION = "1.0.0"

local ICON_SHOW = "rbxassetid://93917691212732"
local ICON_HIDE = "rbxassetid://101655275937723"
local ICON_GIZMO = "rbxassetid://94876904753668"
local BILLBOARD_NAME = "ShowUnanchored_Marker"

local isOn = false

local pluginStorage: ScreenGui = CoreGui:FindFirstChild("ShowUnanchoredPlugin") :: ScreenGui
  or Instance.new("ScreenGui")
pluginStorage.Name = "ShowUnanchoredPlugin"
pluginStorage.Parent = CoreGui

local button: PluginToolbarButton = toolbar:CreateButton(
  "Show Unanchored",
  "Toggles viewing unanchored parts.\nv" .. PLUGIN_VERSION,
  ICON_HIDE
)
button.ClickableWhenViewportHidden = true

local function calcBillboardSize(): UDim2
  -- Calculates the billboard size based on the current ViewportSize.
  -- Chose not to watch ViewportSize changes.
  local cam = workspace.CurrentCamera
  if not cam then return UDim2.fromOffset(10, 10) end -- fallback billboard size
  local size = math.round(cam.ViewportSize.X / 75)
  return UDim2.fromOffset(size, size)
end

local function placeMarker(part: BasePart, billboardSize: UDim2)
  local billboard = script:FindFirstChild(BILLBOARD_NAME):Clone() :: BillboardGui
  billboard.Size = billboardSize
  billboard.Adornee = part
  billboard.Parent = pluginStorage
  local icon = billboard:FindFirstChild("Icon") :: ImageLabel
  icon.Image = ICON_GIZMO
end

local function onPluginButtonClicked()
  -- shows unanchored baseparts
  -- by cloning the billboard and placing it in the part
  local billboardSize = calcBillboardSize()
  for _, instance: Instance in pairs(workspace:GetDescendants()) do
    if instance:IsA("BasePart") then
      if instance.Anchored == false then
        placeMarker(instance, billboardSize)
      end
    end
  end
end

local function onPluginUndoClicked()
  -- deletes all billboards cloned by the show button
  pluginStorage:ClearAllChildren()
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
