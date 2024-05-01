local colors = require "data.colors"
local spellbook = {}

local sb = spellbook

sb.auras = {
  motw = 1126,
  dreamofcenarius = 372152,
  toothandclaw = 135286,
  frenziedregeneration = 22842
}

function sb.markofthewild()
  return Settings.DruidMotw and not Me:HasAura(sb.auras.motw) and Spell.MarkOfTheWild:CastEx(Me)
end

function sb.barkskin()
  if Spell.Barkskin:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.GuardianBarkskinPct and Combat:GetEnemiesWithinDistance(30) > 0 and
      Spell.Barkskin:CastEx(Me)
end

function sb.ironfur()
  return Combat:GetEnemiesWithinDistance(10) > 0 and Spell.Ironfur:CastEx(Me)
end

function sb.frenziedregeneration()
  if Me:HasAura(sb.auras.frenziedregeneration) then
    return false
  end

  local charges = Spell.FrenziedRegeneration.Charges
  local healthPct = Me.HealthPct

  if (healthPct < Settings.GuardianFR2Pct and charges == 2) or
      (healthPct < Settings.GuardianFR1Pct and charges == 1) then
    if Spell.FrenziedRegeneration:CastEx(Me) then
      return
    end
  end
end

function sb.removecorruption()
  return Spell.RemoveCorruption:Dispel(true, DispelPriority.Low, WoWDispelType.Curse, WoWDispelType.Poison)
end

function sb.growl()
  if not Settings.DruidAutoTaunt or Spell.Growl:CooldownRemaining() > 0 then return false end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Target and enemy.Target.IsPlayer and enemy.Target ~= Me and not enemy.Aggro and not enemy.IsCastingOrChanneling then
      Alert("Enemy Target: " .. enemy.Target.NameUnsafe, 5)
      return Spell.Growl:CastEx(enemy)
    end
  end
end

function sb.mangle(target)
  return Spell.Mangle:CastEx(target)
end

function sb.thrash()
  return Combat:GetEnemiesWithinDistance(8) > 0 and Spell.Thrash:CastEx(Me)
end

function sb.swipe(aoe)
  return Combat:GetEnemiesWithinDistance(8) > 0 and (not aoe or aoe and Combat:GetEnemiesWithinDistance(8) > 2) and
      Spell.Swipe:CastEx(Me)
end

function sb.moonfire(target, aggro)
  if aggro then
    for _, enemy in pairs(Combat.Targets) do
      if Me:GetDistance(enemy) >= 15 and not enemy.Aggro and enemy.Target and enemy.Target.IsPlayer then
        return Spell.Moonfire:CastEx(enemy)
      end
    end

    return
  end

  if Spell.Moonfire:Apply(target) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Spell.Moonfire:Apply(enemy) then return true end
  end
end

function sb.docRegrowth()
  local friend = Heal:GetLowestMember()
  local docAura = Me:GetAura(sb.auras.dreamofcenarius)
  if not docAura then return end

  if friend and (friend.HealthPct < 50 or docAura.Remaining < 12000 and friend.HealthPct < 99) then
    if Spell.Regrowth:CastEx(friend) then
      return true
    end
  end
end

function sb.maul(target)
  return Me:HasAura(sb.auras.toothandclaw) and (Combat:GetTargetsAround(target, 8) > 2 and Spell.Raze:CastEx(target) or Spell.Maul:CastEx(target))
end

function sb.afflicted()
  for _, affli in pairs(Heal.Afflicted) do
    DrawLine(Me:GetScreenPosition(), affli:GetScreenPosition(), colors.white, 2)
    if Spell.RemoveCorruption:CastEx(affli) then return end
  end
end

return spellbook
