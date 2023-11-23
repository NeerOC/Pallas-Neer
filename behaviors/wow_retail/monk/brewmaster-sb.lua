local spellbook = {}

local sb = spellbook

sb.auras = {
  heavystagger = 124273,
  moderatestagger = 124274,
  spheres = 224863,
  bonedustbrew = 386276,
  presstheadvantage = 418361
}

function sb.validdeathtarget(unit)
  local minHealth = Me.HealthMax * 0.8
  local maxHealth = Me.HealthMax

  return unit.Health <= maxHealth and unit.Health >= minHealth
end

function sb.touchofdeath()
  if Spell.TouchOfDeath:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    if sb.validdeathtarget(enemy) then
      if Spell.TouchOfDeath:CastEx(enemy, SpellCastExFlags.NoUsable) then return end
    end
  end
end

function sb.spinningcranekick()
  return Me.PowerPct >= 40 and Combat:GetEnemiesWithinDistance(8) > 1 and Spell.SpinningCraneKick:CastEx(Me)
end

function sb.kegsmash(target)
  return Spell.KegSmash:CastEx(target)
end

function sb.risingsunkick(target)
  return Spell.RisingSunKick:CastEx(target)
end

function sb.blackoutkick(target)
  return Spell.BlackoutKick:CastEx(target)
end

function sb.tigerpalm(target)
  return Combat.EnemiesInMeleeRange == 1 and Spell.TigerPalm:CastEx(target)
end

function sb.rushingjadewind()
  return Spell.RushingJadeWind:Apply(Me)
end

function sb.provoke()
  for _, enemy in pairs(Combat.Targets) do
    if not Me:InMeleeRange(enemy) and Me:GetDistance(enemy) > 15 then
      if enemy.Target and enemy.Target.IsPlayer and not enemy.Aggro then
        if Spell.Provoke:CastEx(enemy) then return end
      end
    end
  end
end

function sb.spearhandstrike()
  return Spell.SpearHandStrike:Interrupt()
end

function sb.breathoffire(target)
  return (Me:InMeleeRange(target) or Me:GetDistance(target) < 10) and Me:IsFacing(target) and
      Spell.BreathOfFire:CastEx(Me)
end

function sb.purifyingbrew()
  local moderate = Me:HasAura(sb.auras.moderatestagger)
  local heavy = Me:HasAura(sb.auras.heavystagger)

  if moderate and Spell.PurifyingBrew.Charges > 1 then
    Spell.PurifyingBrew:CastEx(Me)
    Spell.CelestialBrew:AddToQueue(Me)
  end

  if heavy then
    Spell.PurifyingBrew:CastEx(Me)
    Spell.CelestialBrew:AddToQueue(Me)
  end
end

function sb.expelharm()
  if Me.HealthPct > Settings.BrewmasterExpelharmPct or Spell.ExpelHarm:CooldownRemaining() > 0 then return end

  local sphereAura = Me:GetAura(sb.auras.spheres)
  return sphereAura and sphereAura.Stacks > 0 and Spell.ExpelHarm:CastEx(Me)
end

function sb.chiwave(target)
  return Spell.ChiWave:CastEx(target)
end

function sb.bonedustbrew(target)
  return not target:HasAura(sb.auras.bonedustbrew) and Spell.BonedustBrew:CastEx(target)
end

function sb.explodingkeg(target)
  return target:HasAura(sb.auras.bonedustbrew) and Combat:AllTargetsGathered(10) and
  Combat:TargetsAverageDeathTime() > 15 and Spell.ExplodingKeg:CastEx(target)
end

function sb.presstheadvantage(target)
  local press = Me:GetAura(sb.auras.presstheadvantage)
  local action = Combat:GetEnemiesWithinDistance(10) > 1 and Spell.KegSmash or Spell.RisingSunKick

  return press and press.Stacks == 10 and action:CastEx(target)
end

return spellbook
