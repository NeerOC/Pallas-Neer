local spellbook = {}

local sb = spellbook

sb.auras = {
  motw = 1126,
  dreamofcenarius = 372152,
  toothandclaw = 135286
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
  if Me.HealthPct > Settings.GuardianFRPct then return false end

  return Combat:GetEnemiesWithinDistance(30) > 0 and Spell.FrenziedRegeneration:CastEx(Me)
end

function sb.growl()
  if not Settings.DruidAutoTaunt or Spell.Growl:CooldownRemaining() > 0 then return false end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Target and not enemy.Aggro then
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
      if Me:GetDistance(enemy) >= 10 and not enemy.Aggro and enemy.Target then
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
  if friend and friend.HealthPct < 40 then
    if Me:HasAura(sb.auras.dreamofcenarius) and Spell.Regrowth:CastEx(friend) then
      return true
    end
  end
end

function sb.maul(target)
  return Me:HasAura(sb.auras.toothandclaw) and Spell.Maul:CastEx(target)
end

return spellbook
