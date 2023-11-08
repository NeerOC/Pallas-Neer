local spellbook = {}

local sb = spellbook

sb.auras = {
  stealth = 115191,
  subterfuge = 115192,
  shadowdance = 185422,
  sliceanddice = 315496,
  audacity = 386270,
  opportunity = 195627
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
  return Combat.MiniBurst and Spell.AdrenalineRush:CastEx(Me)
end

function sb.stealth()
  return Spell.Stealth:Apply(Me)
end

function sb.bladeflurry()
  return Spell.BladeFlurry:Apply(Me)
end

function sb.rollthebones()
  return not Me:HasAura(sb.auras.stealth) and Spell.RollTheBones:CastEx(Me)
end

function sb.vanishbetween(target)
  if Spell.Vanish:CooldownRemaining() > 0 or Spell.BetweenTheEyes:CooldownRemaining() > 0 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end

  Spell.Vanish:AddToQueue(Me)
  Spell.BetweenTheEyes:AddToQueue(target)
end

function sb.dancebetween(target)
  if Spell.ShadowDance:CooldownRemaining() > 0 or Spell.BetweenTheEyes:CooldownRemaining() > 0 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end

  Spell.ShadowDance:AddToQueue(Me)
  Spell.BetweenTheEyes:AddToQueue(target)
end

function sb.betweentheeyes(target)
  if Me:GetPowerByType(PowerType.ComboPoints) < 5 then return end
  if Spell.Vanish:CooldownRemaining() <= 45000 or Spell.ShadowDance:CooldownRemaining() < 15000 then return end

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
  local ambushAuras = Me:HasAura(sb.auras.audacity) or Me:HasAura(sb.auras.subterfuge) or Me:HasAura(sb.auras.shadowdance)

  return ambushAuras and Me:GetPowerByType(PowerType.ComboPoints) <= 5 and Spell.Ambush:CastEx(target)
end

function sb.pistolshot(target)
  return Me:HasAura(sb.auras.opportunity) and Me:GetPowerByType(PowerType.ComboPoints) <= 5 and Spell.PistolShot:CastEx(target)
end

function sb.sinisterstrike(target)
  return Me:GetPowerByType(PowerType.ComboPoints) <= 5 and Spell.SinisterStrike:CastEx(target)
end

return spellbook
