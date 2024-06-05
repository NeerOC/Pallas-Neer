local colors = require "data.colors"
local options = {
  Name = "Hunter (Survival)",

  Widgets = {
  }
}

local function HunterSurvivalCombat()
  if Me.IsMounted then return end

  local hasAggro = false

  if Combat:GetEnemiesWithinDistance(40) < 1 then
    if Spell.AspectOfTheCheetah:Apply(Me) then return end
  else
    if Spell.AspectOfTheHawk:Apply(Me) then return end
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  local TTD = target:TimeToDeath()
  local isBoss = target.HealthMax > Me.HealthMax * 8

  if Me:InMeleeRange(target) then
    if Spell.RaptorStrike:CastEx(target) then return end
  end

  Me:PetAttack(target)
  if Spell.Growl:CastEx(target) then return end

  if Me.IsCastingOrChanneling then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Spell.HuntersMark:Apply(target) then return end

  for _, enemy in pairs(Combat.Targets) do
    if Me:HasAura("Lock and Load") and not enemy:HasAura("Explosive Shot") then
      if Spell.ExplosiveShot:CastEx(enemy) then return end
    end
    if enemy.HealthPct < 20 and Spell.KillShot:CastEx(enemy, SpellCastExFlags.NoUsable) then return end
  end

  if Combat:GetTargetsAround(target, 8) > 2 then
    if Spell.Multishot:CastEx(target) then return end
    if Spell.ExplosiveTrap:CooldownRemaining() == 0 or Spell.IceTrap:CooldownRemaining() == 0 then
      Spell.TrapLauncher:CastEx(Me)
    end

    if not isBoss and not target:IsMoving() and Me:HasAura("Trap Launcher") then
      if Spell.IceTrap:CastEx(target) then return end
      if Spell.ExplosiveTrap:CastEx(target) then return end
    end
  else
    if not isBoss and (Spell.IceTrap:CooldownRemaining() == 0 or Spell.ImmolationTrap:CooldownRemaining() == 0) and Spell.TrapLauncher:Apply(Me) then return end
    if not target:IsMoving() and Me:HasAura("Trap Launcher") and Spell.IceTrap:CastEx(target) then return end
    if not target:IsMoving() and Me:HasAura("Trap Launcher") and Spell.ImmolationTrap:CastEx(target) then return end
    if TTD > 7 and not target:HasAura("Explosive Shot") and Spell.ExplosiveShot:CastEx(target) then return end
    if Spell.ExplosiveShot:CooldownRemaining() > 0 and TTD > 7 and Spell.SerpentSting:Apply(target) then return end
  end

  if Spell.SteadyShot:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = HunterSurvivalCombat
}

return { Options = options, Behaviors = behaviors }
