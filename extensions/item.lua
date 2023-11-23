---@return WoWItem?
---@param slot EquipSlot
function WoWItem:GetUsableEquipment(slot)
  for k, i in pairs(Me.Equipment) do
    if k == slot then
      return i
    end
  end
end

local itemDelay = {}
---@return boolean success if the item was successfully used
---@param unit WoWUnit? Unit to use the item on.
function WoWItem:UseX(unit)
  if not unit then unit = Me end
  if not unit then return false end

  if itemDelay[self.EntryId] and itemDelay[self.EntryId] > wector.Game.Time then return false end
  if not self.HasCooldown then return false end
  if self.CooldownRemaining > 0 then return false end

  wector.Console:Log("Use: " .. self.Name)
  itemDelay[self.EntryId] = wector.Game.Time + math.random(150, 500)
  return self:Use(unit.ToObject)
end

function WoWItem:UseHealthstone()
  if Me.HealthPct > Settings.PallasHealthstonePct then return false end
  local healthstone = nil

  for _, item in pairs(wector.Game.Items) do
    if string.find(item.Name, "Healthstone") then
      healthstone = item
    end
  end

  if not healthstone then return false end

  return healthstone:UseX() and Alert("Healthstone Used", 3)
end
