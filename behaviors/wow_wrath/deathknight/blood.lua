local common = require('behaviors.wow_wrath.deathknight.common')

local options = {
  -- The sub menu name
  Name = "Deathknight (Blood)",
  -- widgets
  Widgets = {

  }
}

local function DeathknightBlood()
  if Me.IsMounted or Me:IsCastingFixed() then return end

  if Spell.BoneShield:Apply(Me) then return end

  local diseaseTarget
  local missingDisease = 0
  local holdForHeal = Me.HealthPct < 50
  local caster
  local runicPower = Me:GetPowerByType(PowerType.RunicPower)

  for _, enemy in pairs(Combat.Targets) do
    local hasIcy = enemy:HasAura("Frost Fever")
    local hasDisease = enemy:HasAura("Blood Plague")

    if enemy.IsCastingOrChanneling and enemy.IsInterruptible then
      caster = enemy
    end

    if hasDisease and hasIcy and not diseaseTarget then
      diseaseTarget = enemy
    end

    if not hasDisease or not hasIcy then
      missingDisease = missingDisease + 1
    end
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if caster then
    Spell.MindFreeze:CastEx(caster)
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if (runicPower > 90 or Me.HealthPct < 90) and Spell.DeathStrike:CastEx(target) then return end

  if not diseaseTarget then
    if not holdForHeal then
      if not target:HasAura("Frost Fever") and Spell.IcyTouch:CastEx(target) then return end
      if not target:HasAura("Blood Plague") and Spell.PlagueStrike:CastEx(target) then return end
    end
  else
    if not Me:IsMoving() and missingDisease > 1 and Spell.Pestilence:CastEx(diseaseTarget) then return end
    if Spell.HeartStrike:CastEx(diseaseTarget) then return end
  end

  if runicPower > 90 and Spell.DeathCoil:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = DeathknightBlood
}

return { Options = options, Behaviors = behaviors }
