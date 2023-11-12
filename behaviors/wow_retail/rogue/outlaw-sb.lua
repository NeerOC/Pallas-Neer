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
  return (not Me:HasAura(sb.auras.adrenalinerush) or Me:GetPowerByType(PowerType.ComboPoints) == 0) and
      Spell.AdrenalineRush:CastEx(Me)
end

function sb.stealth()
  return Spell.Stealth:Apply(Me)
end

function sb.bladeflurry()
  return (table.length(Combat.Targets) > 1 or not Me:HasAura(sb.auras.subterfuge) and not Me:HasAura(sb.auras.shadowdance) and not Me:HasAura(sb.auras.stealth)) and Spell.BladeFlurry:Apply(Me)
end

function sb.rollthebones()
  if Me:HasAura(sb.auras.stealth) then return end

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
  return Spell.GhostlyStrike:CastEx(target)
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
  if not Me:HasAura(sb.auras.stealth) and not Me:HasAura(sb.auras.shadowdance) and not Me:HasAura(sb.auras.subterfuge) then
    if Spell.Vanish:CooldownRemaining() < 45000 or Spell.ShadowDance:CooldownRemaining() < 12000 then
      return
    end
  end

  local cp = (Me:HasAura(sb.auras.shadowdance) or Me:HasAura(sb.auras.subterfuge)) and 5 or 6

  return Me:GetPowerByType(PowerType.ComboPoints) >= cp and Spell.BetweenTheEyes:CastEx(target)
end

function sb.sliceanddice()
  local sliceanddice = Me:GetAura(sb.auras.sliceanddice)

  if sliceanddice and sliceanddice.Remaining > 12000 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end
  if Me:HasAura(sb.auras.subterfuge) or Me:HasAura(sb.auras.shadowdance) then return end

  return Spell.SliceAndDice:CastEx(Me)
end

function sb.dispatch(target)
  return Me:GetPowerByType(PowerType.ComboPoints) >= 6 and Spell.Dispatch:CastEx(target)
end

function sb.ambush(target)
  local ambushAuras = Me:HasAura(sb.auras.audacity) or Me:HasAura(sb.auras.subterfuge) or
      Me:HasAura(sb.auras.shadowdance)

  return ambushAuras and Me:GetPowerByType(PowerType.ComboPoints) <= 5 and Spell.Ambush:CastEx(target)
end

function sb.pistolshot(target)
  return Me:HasAura(sb.auras.opportunity) and Me:GetPowerByType(PowerType.ComboPoints) < 4 and
      Spell.PistolShot:CastEx(target)
end

function sb.sinisterstrike(target)
  return Me:GetPowerByType(PowerType.ComboPoints) <= 5 and Spell.SinisterStrike:CastEx(target)
end

return spellbook
