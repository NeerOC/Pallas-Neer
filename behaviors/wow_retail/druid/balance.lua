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
        if Spell.Sunfire:CastEx(unit) then
          return
        end
        return
      end
    end
    ::continue::
  end

  if not Me:HasAura(191034) or Me:GetPowerByType(PowerType.LunarPower) >= 90 then
    Spell.Starfall:CastEx(Me)
    return
  end
end

local travelForm = false
local function TirelessPursuit()
  if not Me:IsMoving() then return end

  if Me.InCombat or not travelForm then
    if Spell.StampedingRoar:CastEx(Me) then return end
    if not Me:HasAura(Spell.StampedingRoar.Name) then
      Spell.TigerDash:CastEx(Me)
    end

    if not Me:HasAura(393897) then
      if not Me:HasAura(768) then
        Spell.CatForm:CastEx(Me)
      end
    end
  else
    if Spell.TravelForm:Apply(Me) then return end
  end
end

local function CraftGems()
  local items = wector.Game.Items

  if Me.IsCastingOrChanneling then return end

  for _, item in pairs(items) do
    local name = item.Name
    local gem = string.find(name, "Chipped") or string.find(name, "Flawed")

    if gem and item.Count >= 3 then
      item:Use(Me.ToUnit)
      return
    end
  end
end

local function DruidBalance()
  if CraftGems() then return end

  if Me:IsCastingFixed() then return end

  if Me.HealthPct < 60 and Spell.Regrowth:CastEx(Me) then return end

  if Spell.MarkOfTheWild:Apply(Me) then return end

  if tagging then
    DrawText(World2Screen(Vec3(Me.Position.x, Me.Position.y + 0.1, Me.Position.z + 10.5)), colors.yellow,
      "Tagging Enabled")
    Tag()
    --TirelessPursuit()
    return
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if Me:HasAura(102560) or Me:HasAura(194223) then
    Spell.TirelessSpirit:CastEx(Me)
  end

  if not tagging and Spell.MoonkinForm:Apply(Me) then return end
  if Spell.Sunfire:Apply(target) then return end
  if Spell.Moonfire:Apply(target) then return end
  if Combat.Enemies > 2 and Spell.Starfall:CastEx(Me) then return end
  if Combat.Enemies <= 2 and Spell.Starsurge:CastEx(target) then return end
  if Spell.NewMoon:CastEx(target) then return end
  if Spell.HalfMoon:CastEx(target) then return end
  if Spell.FullMoon:CastEx(target) then return end
  if Spell.FuryOfElune:CastEx(target) then return end
  if Me:HasAura("Eclipse (Lunar)") and Spell.Starfire:CastEx(target) then return end
  if Spell.Wrath:CastEx(target) then return end
  if Spell.Moonfire:CastEx(target) then return end
end

return {
  Behaviors = {
    [BehaviorType.Combat] = DruidBalance,
  }
}
