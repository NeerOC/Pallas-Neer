local spellbook = {}

local sb = spellbook

sb.auras = {
  stealth = 115191,
  subterfuge = 115192,
  shadowdance = 185422,
  sliceanddice = 315496,
  audacity = 386270,
  opportunity = 195627,
  adrenalinerush = 13750,
  dices = {
    broadside = 193356,
    buriedtreasure = 199600,
    grandmelee = 193358,
    ruthprecision = 193357,
    skullandbones = 199603,
    truebearing = 193359
  }
}

function sb.stealthreturn()
  local stealthForm = Me.ShapeshiftForm == ShapeshiftForm.Stealth
  local stealthed = Me:HasAura(sb.auras.stealth)

  return stealthForm or stealthed
end

function sb.instantpoison()
  return Spell.InstantPoison:Apply(Me)
end

function sb.atrophicpoison()
  return Spell.AtrophicPoison:Apply(Me)
end

function sb.adrenalinerush()
  return Me:GetPowerByType(PowerType.ComboPoints) <= 2 and Spell.AdrenalineRush:Apply(Me, nil, true)
end

function sb.stealth()
  return Spell.Stealth:Apply(Me)
end

function sb.kick()
  return Spell.Kick:Interrupt()
end

function sb.cheapshotinterrupt()
  return Settings.RogueOutlawCheapInterrupt and Spell.CheapShot:Interrupt()
end

function sb.kidneyshotinterrupt()
  return Settings.RogueOutlawKidneyInterrupt and Spell.KidneyShot:Interrupt()
end

function sb.bladeflurry()
  local enemyCount = Combat:GetEnemiesWithinDistance(12)
  local aoeTrigger = enemyCount >= 5
  local combosMissing = Me:GetPowerByType(PowerType.ComboPoints) - Me:GetPowerMaxByType(PowerType.ComboPoints)
  local hasBroad = Me:HasAura(sb.auras.dices.broadside)

  if aoeTrigger and Spell.BladeFlurry:CastEx(Me) then
    return
  end

  if enemyCount >= 3 then
    local willGenerate = enemyCount
    if hasBroad then
      willGenerate = willGenerate + 1
    end

    if combosMissing >= willGenerate and Spell.BladeFlurry:CastEx(Me) then return end
  end

  return Spell.BladeFlurry:Apply(Me)
end

function sb.rollthebones()
  if Spell.RollTheBones:CooldownRemaining() > 0 then return end

  local auraCount = 0
  for _, dice in pairs(sb.auras.dices) do
    local aura = Me:GetAura(dice)
    if aura and aura.Remaining > 2000 then
      auraCount = auraCount + 1
    end
  end

  return (auraCount == 0 or auraCount == 1 and not Me:HasAura(sb.auras.dices.truebearing)) and
      Spell.RollTheBones:CastEx(Me)
end

function sb.ghostlystrike(target)
  return Me:GetPowerByType(PowerType.ComboPoints) < 7 and Spell.GhostlyStrike:CastEx(target)
end

function sb.vanishbetween(target)
  if Me:HasAura(sb.auras.subterfuge) or Me:HasAura(sb.auras.shadowdance) then return end
  if Spell.Vanish:CooldownRemaining() > 0 or Spell.BetweenTheEyes:CooldownRemaining() > 0 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end

  Spell.Vanish:CastEx(Me)
  Spell.BetweenTheEyes:AddToQueue(target)
end

function sb.dancebetween(target)
  if Me:HasAura(sb.auras.subterfuge) then return end
  if Spell.ShadowDance:CooldownRemaining() > 0 or Spell.BetweenTheEyes:CooldownRemaining() > 0 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end

  Spell.ShadowDance:CastEx(Me)
  Spell.BetweenTheEyes:AddToQueue(target)
end

function sb.betweentheeyes(target)
  if Me:GetPowerByType(PowerType.ComboPoints) < 5 then return end
  local stealthauras = Me:HasAura(sb.auras.stealth)
      or Me:HasAura(sb.auras.subterfuge)
      or Me:HasAura(sb.auras.shadowdance)
  local cooldownHold = Spell.Vanish:CooldownRemaining() < 45000 or Spell.ShadowDance:CooldownRemaining() < 12000

  if not stealthauras and cooldownHold then return end

  local cp = stealthauras and 5 or 6

  return Me:GetPowerByType(PowerType.ComboPoints) >= cp and Spell.BetweenTheEyes:CastEx(target)
end

function sb.sliceanddice()
  local sliceanddice = Me:GetAura(sb.auras.sliceanddice)

  if sliceanddice and sliceanddice.Remaining > 12000 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end
  if Me:HasAura(sb.auras.subterfuge) or Me:HasAura(sb.auras.shadowdance) then return end

  return Spell.SliceAndDice:CastEx(Me)
end

function sb.dispatch(target)
  local stealthauras = Me:HasAura(sb.auras.stealth)
      or Me:HasAura(sb.auras.subterfuge)
      or Me:HasAura(sb.auras.shadowdance)
  local cp = stealthauras and 5 or 6

  return Me:GetPowerByType(PowerType.ComboPoints) >= cp and Spell.Dispatch:CastEx(target)
end

function sb.ambush(target)
  local audacity = Me:HasAura(sb.auras.audacity)
  local stealthAuras = Me:HasAura(sb.auras.subterfuge) or Me:HasAura(sb.auras.shadowdance) or
      Me:HasAura(sb.auras.stealth)
  local combos = Me:GetPowerByType(PowerType.ComboPoints)

  if stealthAuras and combos < 5 then
    return Spell.Ambush:CastEx(target)
  end

  return audacity and Spell.Ambush:CastEx(target)
end

function sb.pistolshot(target, noAmbush)
  local broadSide = Me:HasAura(sb.auras.dices.broadside)
  local combos = Me:GetPowerByType(PowerType.ComboPoints)
  local opportunity = Me:HasAura(sb.auras.opportunity)
  local stealth = Me:HasAura(sb.auras.stealth) or Me:HasAura(sb.auras.subterfuge) or Me:HasAura(sb.auras.shadowdance)

  if broadSide and combos < 2 and opportunity and stealth then
    if Spell.PistolShot:CastEx(target) then return end
  end

  if noAmbush then
    return opportunity and Spell.PistolShot:CastEx(target)
  end
end

function sb.sinisterstrike(target)
  return Me:GetPowerByType(PowerType.ComboPoints) <= 5 and Me:GetPowerByType(PowerType.Energy) >= 50 and
      Spell.SinisterStrike:CastEx(target)
end

function sb.tricksofthetrade()
  if Spell.TricksOfTheTrade:CooldownRemaining() > 0 then return end
  if not Me.FocusTarget then return end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Aggro then
      if Spell.TricksOfTheTrade:CastEx(Me.FocusTarget) then return end
    end
  end
end

return spellbook
