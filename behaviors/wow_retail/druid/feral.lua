local colors = require("data.colors")

BalanceListener = wector.FrameScript:CreateListener()
BalanceListener:RegisterEvent('CHAT_MSG_ADDON')

local tagging = false
local tagany = false
local enemies = {}

local function removetag(which)
  for entry, enemy in pairs(enemies) do
    if enemy == which then
      table.remove(enemies, entry)
    end
  end
end

local function GetLootAround(unit, table)
  local count = 0
  for _, loot in pairs(table) do
    if Me:GetDistance(loot) < 40 then
      if loot ~= unit then
        if loot:GetDistance(unit) < 33 then
          count = count + 1
        end
      end
    end
  end

  return count
end

function BalanceListener:CHAT_MSG_ADDON(prefix, text, channel, sender)
  if prefix ~= "pallas" then return end

  if text == "toggletag" then
    tagging = not tagging
    print("Tagging: " .. tostring(tagging))
    return
  end

  if text == "tagany" then
    tagany = true
  end

  if text == "addtag" then
    local target = Me.Target
    if target then
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
  local x = 10
  for _, entry in pairs(enemies) do
    local textpos = World2Screen(Vec3(Me.Position.x, Me.Position.y, Me.Position.z + x))
    DrawText(textpos, colors.white, tostring(entry))
    x = x - 0.5
  end

  local units = wector.Game.Units
  for _, unit in pairs(units) do
    local dead = unit.DeadOrGhost
    local distance = Me:GetDistance(unit) < 45
    if dead or not distance then goto continue end
    local id = unit.EntryId
    local dotted = unit:GetAuraByMe(Spell.Moonfire.Name) or unit:GetAuraByMe(Spell.Sunfire.Name)
    local validUnit = Me:CanAttack(unit) and unit.Level > 1

    if (table.contains(enemies, id) or tagany) and not unit.IsTapDenied and not dotted and validUnit then
      if Me:WithinLineOfSight(unit) then
        Me:SetTarget(unit)
        if Spell.Moonfire:CastEx(unit) then
          return
        end
      end
    end
    ::continue::
  end
end

local function DruidFeralDamage()
  if Me:IsCastingFixed() then return end
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Spell.MarkOfTheWild:Apply(Me) then return end

  if tagging then
    if Me:GetPowerByType(PowerType.Energy) < 100 and Spell.TigersFury:CastEx(Me) then return end
    Tag()
    return
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if not Me:InMeleeRange(target) and Me:GetDistance(target) > 9 then return end

  if not Me:HasAura("Tiger's Fury") or Me:GetPowerByType(PowerType.Energy) < 50 then
    print(Me:GetPowerByType(PowerType.Energy))
    Spell.TigersFury:CastEx(Me)
  end
  if Spell.AdaptiveSwarm:CastEx(target) then return end
  if Me:HasAura("Tiger's Fury") and Spell.ConvokeTheSpirits:CastEx(target) then return end
  if Me:HasAura(391882) and Spell.FerociousBite:CastEx(target) then return end
  if Me:GetPowerByType(PowerType.ComboPoints) > 4 then
    if Combat:GetEnemiesWithinDistance(8) > 0 then
      if Spell.PrimalWrath:CastEx(target) then return end
    end
  end
  if Me:GetPowerByType(PowerType.ComboPoints) == 0 and Spell.FeralFrenzy:CastEx(target) then return end
  if Spell.BrutalSlash:CastEx(target) then return end
  if Spell.Thrash:Apply(target) then return end
  if Spell.Rake:Apply(target) then return end
  if Combat:GetEnemiesWithinDistance(8) > 1 and Spell.Swipe:CastEx(Me) then return end
  if Spell.Shred:CastEx(target) then return end
end

return {
  Behaviors = {
    [BehaviorType.Combat] = DruidFeralDamage,
  }
}
