---@diagnostic disable: duplicate-set-field, inject-field
local colors = require "data.colors"
local options = {
  Name = "Hunter (Beastmastery)",

  Widgets = {
  }
}

local nextShot = 0
local function GetNextAutoAttack()
  local shotTime = nextShot - wector.Game.Time
  return shotTime > 0 and math.floor(shotTime) or 0
end

TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

function TargetListener:COMBAT_LOG_EVENT_UNFILTERED(entry)
  if not entry then return end
  if entry.EventTypeName ~= "SPELL_CAST_SUCCESS" then return end
  if entry.Source.Name ~= Me.NameUnsafe then return end

  local spellID = entry.Args[1]
  if spellID == 75 then
    nextShot = wector.Game.Time + Me.BaseRangedAttackSpeed * 1000
  end

  if spellID == Spell.ArcaneShot.Id or spellID == Spell.Multishot.Id then
    if not Me:HasAura(Spell.AspectOfTheViper.Id) then
      Spell.AspectOfTheViper:Cast(Me)
    end
  end
end

local function getBestTarget()
  local bestTarget
  for _, totem in pairs(Combat.Totems) do
    return totem
  end

  for _, enemy in pairs(Combat.Targets) do
    if not bestTarget or enemy:GetThreatValue(Me) > bestTarget:GetThreatValue(Me) then
      bestTarget = enemy
    end
  end

  return bestTarget
end

local function AspectToggle()
  if table.length(Combat.Targets) > 0 or Me.InCombat then
    local viperOrHawk = Me.PowerPct < 5 and Spell.AspectOfTheViper or
        (not Me:HasAura(Spell.AspectOfTheViper.Id) or Me.PowerPct > 10) and Spell.AspectOfTheHawk

    return viperOrHawk and viperOrHawk:Apply(Me)
  else
    if Me:IsMoving() and Spell.AspectOfTheCheetah:Apply(Me) then return end
  end
end

local function PetAttack()
  if not Me.Pet or Me.Pet.DeadOrGhost then return end
  local bestTarget = getBestTarget()
  local petTarget = Me.Pet.Target

  if not bestTarget or petTarget ~= bestTarget then Me:PetAttack(bestTarget) end
  if Me.Pet:InMeleeRange(bestTarget) then
    if Spell.Growl:CastEx(bestTarget) then return end
    if Combat.Burst and Spell.Rake:CastEx(bestTarget) then return end
    if Spell.Claw:CastEx(bestTarget) then return end
  end
end

local function PetFollow()
  if not Me.Pet or Me.Pet.DeadOrGhost then return end
  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end
  if Me.Pet.Target then Me:PetFollow() end
end

local function PetSmart()
  if not Me.Pet or Me.Pet.DeadOrGhost then return end
  local mend = Me.Pet:GetAura(Spell.MendPet.Name)
  if Me.Pet.HealthPct < 90 and (not mend or mend.Remaining < 3000) and Spell.MendPet:CastEx(Me) then return end
end

local function getGoodAttackSpeed()
  return Me.BaseRangedAttackSpeed * 0.7 * 1000
end

local function serpentSting(target)
  if Me:HasAura(Spell.AspectOfTheViper.Id) or not Combat.MiniBurst then return end

  if Spell.SerpentSting:Apply(target) then return end

  for _, enemy in pairs(Combat.Targets) do
    if enemy:TimeToDeath() > 15 and enemy:TimeToDeath() ~= 9999 and Spell.SerpentSting:Apply(enemy) then return end
  end
end

local function HuntersMark(target)
  local alreadyHas = false
  for _, enemy in pairs(Combat.Targets) do
    if enemy:HasAura(Spell.HuntersMark.Id) then
      alreadyHas = true
    end
  end

  return not alreadyHas and Spell.HuntersMark:Apply(target)
end

local function HunterBeastmasteryCombat()
  DrawText(World2Screen(Me.Position), colors.white, tostring(GetNextAutoAttack()))

  if Me.IsMounted or Me.IsCastingOrChanneling then return end

  AspectToggle()
  PetSmart()

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then
    PetFollow()
    return
  end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  PetAttack()

  if Combat.Burst then
    if Spell.BestialWrath:CastEx(Me) then return end
    if Spell.BloodFury:CastEx(Me) then return end
    if Spell.RapidFire:CastEx(Me) then return end
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if target:IsMoving() and not target.IsCastingOrChanneling and Combat.TimeInCombat > 3000 and target.Aggro and Spell.ConcussiveShot:CastEx(target) then return end
  if GetNextAutoAttack() > 1300 and Combat:GetTargetsAround(target, 10) > 1 and Spell.Multishot:CastEx(target) then return end
  if Me:GetDistance(target) > 10 and HuntersMark(target) then return end
  if serpentSting(target) then return end
  if GetNextAutoAttack() > 1300 and Spell.ArcaneShot:CastEx(target) then return end

  if Me:InMeleeRange(target) then
    if Spell.RaptorStrike:CastEx(target) then return end
    if Spell.MongooseBite:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = HunterBeastmasteryCombat
}

return { Options = options, Behaviors = behaviors }
