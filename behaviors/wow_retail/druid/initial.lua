local colors = require "data.colors"
BalanceListener = wector.FrameScript:CreateListener()
BalanceListener:RegisterEvent('CHAT_MSG_ADDON')

local tagging = false
local enemies = {}

local function removetag(which)
  for entry, enemy in pairs(enemies) do
    if enemy == which then
      table.remove(enemies, entry)
    end
  end
end

function BalanceListener:CHAT_MSG_ADDON(prefix, text, channel, sender)
  if prefix ~= "pallas" then return end

  if text == "toggletag" then
    tagging = not tagging
    print("Tagging: " .. tostring(tagging))
    return
  end

  if text == "addtag" then
    local target = Me.Target
    if target and Me:CanAttack(target) then
      if not table.contains(enemies, target.EntryId) then
        table.insert(enemies, target.EntryId)
        print("Added " .. target.NameUnsafe .. ' to taglist')
      else
        removetag(target.EntryId)
        print("Removed " .. target.NameUnsafe .. ' from taglist')
      end
    else
      print("No target or invalid target")
    end
  end
end



local function Tag()
  DrawText(World2Screen(Vec3(Me.Position.x, Me.Position.y + 0.1, Me.Position.z + 10.5)), colors.yellow, "Taglist")

  local x = 10
  for _, entry in pairs(enemies) do
    local textpos = World2Screen(Vec3(Me.Position.x, Me.Position.y, Me.Position.z + x))
    DrawText(textpos, colors.white, tostring(entry))
    x = x - 0.5
  end

  local gathered = {}
  local units = wector.Game.Units
  for _, unit in pairs(units) do
    local id = unit.EntryId
    local dotted = unit:GetAura(Spell.Moonfire.Name)
    local distance = Me:GetDistance(unit) < 40
    local dead = unit.DeadOrGhost
    if table.contains(enemies, id) and not unit.IsTapDenied and not dotted and distance and not dead then
      if Me:WithinLineOfSight(unit) then
        table.insert(gathered, unit)
      end
    end
  end

  table.sort(gathered, function(a, b)
    return Me:GetDistance(a) > Me:GetDistance(b)
  end)

  local trueTarget = gathered[1]
  if not trueTarget then return end

  if Spell.Moonfire:CastEx(trueTarget) then return end
end

local function DruidInitial()
  if tagging then Tag() return end

  local target = Combat.BestTarget
  if not target then return end

  if not Me:IsFacing(target) then return end

  if Me.ShapeshiftForm == ShapeshiftForm.Bear then
    if Spell.Mange:CastEx(target) then return end
  elseif Me.ShapeshiftForm == ShapeshiftForm.Cat then
    if Me:GetPowerByType(PowerType.ComboPoints) > 2 and Spell.FerociousBite:CastEx(target) then return end
    if Spell.Shred:CastEx(target) then return end
  elseif Me.ShapeshiftForm == ShapeshiftForm.Normal then
    if not target:HasDebuffByMe("Moonfire") and Spell.Moonfire:CastEx(target) then return end
    if Spell.Wrath:CastEx(target) then return end
  end

  if not Me:HasVisibleAura("Mark of the Wild") and Spell.MarkOfTheWild:CastEx(Me) then return end
end

local function DruidInitialHeal()
  if Me.HealthPct < 60 and Spell.Regrowth:CastEx(Me) then return end
end

return {
  Behaviors = {
    [BehaviorType.Combat] = DruidInitial,
    [BehaviorType.Heal] = DruidInitialHeal,
  }
}
