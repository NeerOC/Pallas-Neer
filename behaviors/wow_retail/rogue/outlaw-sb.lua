local colors = require "data.colors"
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

sb.stealthed = false
sb.shadowdance = false
sb.subterfurge = false
sb.broadside = false
sb.audacity = false
sb.truebearing = false
sb.opportunity = false

function sb.getAuras()
  sb.stealthed = Me:HasAura(sb.auras.stealth)
  sb.shadowdance = Me:HasAura(sb.auras.shadowdance)
  sb.subterfurge = Me:HasAura(sb.auras.subterfuge)
  sb.broadside = Me:HasAura(sb.auras.dices.broadside)
  sb.audacity = Me:HasAura(sb.auras.audacity)
  sb.truebearing = Me:HasAura(sb.auras.dices.truebearing)
  sb.opportunity = Me:HasAura(sb.auras.opportunity)
end

function sb.stealthreturn()
  local stealthForm = Me.ShapeshiftForm == ShapeshiftForm.Stealth
  local stealthed = sb.stealthed

  return stealthForm or stealthed
end

function sb.hasStealthBuff()
  return sb.stealthed or sb.subterfurge or sb.shadowdance
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

function sb.pickpocket()
  if not sb.hasStealthBuff() then return end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.CreatureType == CreatureType.Humanoid and Spell.PickPocket:CastEx(enemy) then return end
  end
end

function sb.bladeflurry()
  local enemyCount = Combat:GetEnemiesWithinDistance(12)
  local aoeTrigger = enemyCount >= 5
  local combosMissing = Me:GetPowerMaxByType(PowerType.ComboPoints) - Me:GetPowerByType(PowerType.ComboPoints)
  local hasBroad = sb.broad

  if aoeTrigger and Me:GetPowerByType(PowerType.ComboPoints) < 4 and Spell.BladeFlurry:CastEx(Me) then
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

  return (auraCount == 0 or auraCount == 1 and not sb.truebearing) and
      Spell.RollTheBones:CastEx(Me)
end

function sb.ghostlystrike(target)
  return Me:GetPowerByType(PowerType.ComboPoints) < 7 and Spell.GhostlyStrike:CastEx(target)
end

function sb.vanishbetween(target)
  if sb.subterfurge or sb.shadowdance then return end
  if Spell.Vanish:CooldownRemaining() > 0 or Spell.BetweenTheEyes:CooldownRemaining() > 0 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end

  Spell.Vanish:CastEx(Me)
  Spell.BetweenTheEyes:AddToQueue(target)
end

function sb.dancebetween(target)
  if sb.subterfurge then return end
  if Spell.ShadowDance:CooldownRemaining() > 0 or Spell.BetweenTheEyes:CooldownRemaining() > 0 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end

  Spell.ShadowDance:CastEx(Me)
  Spell.BetweenTheEyes:AddToQueue(target)
end

function sb.betweentheeyes(target)
  if Me:GetPowerByType(PowerType.ComboPoints) < 5 then return end
  local stealthauras = sb.hasStealthBuff()
  local cooldownHold = Spell.Vanish:CooldownRemaining() < 45000 or Spell.ShadowDance:CooldownRemaining() < 12000

  if not stealthauras and cooldownHold then return end

  local cp = stealthauras and 5 or 6

  return Me:GetPowerByType(PowerType.ComboPoints) >= cp and Spell.BetweenTheEyes:CastEx(target)
end

function sb.sliceanddice()
  local sliceanddice = Me:GetAura(sb.auras.sliceanddice)

  if sliceanddice and sliceanddice.Remaining > 12000 or Me:GetPowerByType(PowerType.ComboPoints) < 6 then return end
  if sb.subterfurge or sb.shadowdance then return end

  return Spell.SliceAndDice:CastEx(Me)
end

function sb.dispatch(target)
  local stealthauras = sb.hasStealthBuff()
  local cp = stealthauras and 5 or 6

  return Me:GetPowerByType(PowerType.ComboPoints) >= cp and Spell.Dispatch:CastEx(target)
end

function sb.ambush(target)
  local audacity = sb.audacity
  local stealthAuras = sb.hasStealthBuff()
  local combos = Me:GetPowerByType(PowerType.ComboPoints)

  if stealthAuras and combos < 5 then
    return Spell.Ambush:CastEx(target)
  end

  return audacity and Spell.Ambush:CastEx(target)
end

function sb.pistolshot(target, noAmbush)
  local broadSide = sb.broadside
  local combos = Me:GetPowerByType(PowerType.ComboPoints)
  local opportunity = sb.opportunity
  local stealth = sb.hasStealthBuff()
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

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Aggro then
      if Spell.TricksOfTheTrade:CastEx(Me.FocusTarget) then return end
    end
  end
end

function sb.handleincorp()
  for _, enemy in pairs(Combat.Incorporeals) do
    if enemy.IsCastingOrChanneling then
      if Me:IsFacing(enemy) then
        if Spell.CheapShot:CastEx(enemy) then return end
        if Spell.KidneyShot:CastEx(enemy) then return end
      end
      if Spell.Blind:CastEx(enemy) then return end
    end
  end
end

local stunSpells = {
  [200291] = true, -- Knife dance Black rook hold
  [225562] = true, -- Metamorphosis, very bad.
}
function sb.stunspells()
  for _, enemy in pairs(Combat.Targets) do
    local spell = enemy.CurrentSpell
    if spell and stunSpells[spell.Id] then
      if Me:IsFacing(enemy) then
        if Spell.CheapShot:CastEx(enemy) then return end
        if Spell.KidneyShot:CastEx(enemy) then return end
      end
      if Spell.Blind:CastEx(enemy) then return end
    end
  end
end

return spellbook
