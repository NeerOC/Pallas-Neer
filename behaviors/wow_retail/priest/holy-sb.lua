local spellbook = {}

local sb = spellbook

sb.auras = {
  improvedpurify = 390632,
  lightweaver = 390993,
  surgeoflight = 114255
}

--- Class Spells/Buffs
local nextBuff = 0
function sb.PowerWordFortitude()
  if Me.InCombat or wector.Game.Time < nextBuff then return false end

  for _, friend in pairs(Heal.Friends.All) do
    if Spell.PowerWordFortitude:Apply(friend) then
      nextBuff = wector.Game.Time + 5000
      return true
    end
  end
end

function sb.Purify()
  if Spell.Purify:CooldownRemaining() > 0 then return false end

  if Me:HasAura(sb.auras.improvedpurify) then
    if Spell.Purify:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Disease) then return true end
    return
  end

  if Spell.Purify:Dispel(true, DispelPriority.Low, WoWDispelType.Magic) then return true end
end

function sb.DispelMagic()
  if Combat.Enemies == 0 or not Settings.PriestHolyPurge then return false end

  return Spell.DispelMagic:Dispel(false, DispelPriority.Low, WoWDispelType.Magic)
end

function sb.DesperatePrayer()
  if not Me.InCombat or Me.HealthPct > Settings.PriestDesperatePrayer then return false end

  return Spell.DesperatePrayer:CastEx(Me)
end

function sb.Fade()
  if Spell.Fade:CooldownRemaining() > 0 then return false end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Aggro or enemy.IsCastingOrChanneling and enemy.Target and enemy.Target == Me then
      if Spell.Fade:CastEx(Me) then return true end
    end
  end

  return false
end

--- Single Target Healing Spells
function sb.PrayerOfMending(target)
  if Spell.PrayerOfMending:CooldownRemaining() > 0 then return false end

  if target then
    if target.HealthPct > Settings.PriestHolyPrayerOfMending then return false end

    if Spell.PrayerOfMending:Apply(target) then return end
  end

  if not Settings.PriestHolySpreadMending or not Me.InCombat then return false end

  for _, friend in pairs(Heal.Friends.All) do
    if Spell.PrayerOfMending:Apply(friend) then return end
  end
end

function sb.FlashHeal(target)
  local surgeoflight = Me:GetAura(sb.auras.surgeoflight)
  if surgeoflight then
    if target.HealthPct < Settings.PriestHolyInstantFlashHeal or surgeoflight.Remaining < 2500 then
      local ligthtweaver = Me:GetAura(sb.auras.lightweaver)
      if ligthtweaver and ligthtweaver.Stacks > 1 and surgeoflight.Remaining > 2500 then
        -- Surge of Light is active and Lightweaver stacks are greater than 1 and Surge of Light has more than 3 seconds remaining
        return
      end
      -- Surge of Light is active and none of the above conditions are met, cast Flash Heal
      if Spell.FlashHeal:CastEx(target) then
        return true
      end
    end
  elseif target.HealthPct < Settings.PriestHolyFlashHeal and Spell.FlashHeal:CastEx(target) then
    -- Surge of Light is not active and target health is below the Flash Heal threshold, cast Flash Heal
    return true
  end

  return false
end

function sb.Heal(target)
  if target.HealthPct > Settings.PriestHolyLightweaveHeal then return false end

  if Me:HasAura(sb.auras.lightweaver) and Spell.Heal:CastEx(target) then return true end

  if target.HealthPct > Settings.PriestHolyHeal then return false end

  return Spell.Heal:CastEx(target)
end

function sb.Renew(target)
  if target.HealthPct > Settings.PriestHolyRenew then return false end

  return Spell.Renew:Apply(target)
end

function sb.PowerWordShield(target)
  if target.HealthPct > Settings.PriestHolyWordShield then return false end

  return Spell.PowerWordShield:Apply(target)
end

function sb.HolyWordSerenity(target)
  if target.HealthPct > Settings.PriestHolyWordSerenity then return false end

  return Spell.HolyWordSerenity:CastEx(target)
end

function sb.GuardianSpirit(target)
  if not target.InCombat or target.HealthPct > Settings.PriestHolyGuardianSpirit then return false end

  return Spell.GuardianSpirit:CastEx(target)
end

function sb.PowerWordLife(target)
  if target.HealthPct > Settings.PriestPowerWordLife then return false end

  return Spell.PowerWordLife:CastEx(target)
end

--- DPS Spells
function sb.DivineStar()
  if Spell.DivineStar:CooldownRemaining() > 0 then return false end

  local friends = 0
  local enemies = 0

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    if Me:GetDistance(friend) < 27 and Me:IsFacing(friend, 45) then
      friends = friends + 1
    end
  end

  for _, enemy in pairs(Combat.Targets) do
    if Me:GetDistance(enemy) < 27 and Me:IsFacing(enemy, 45) then
      enemies = enemies + 1
    end
  end

  return friends > 0 and enemies > 0 and Spell.DivineStar:CastEx(Me)
end

function sb.HolyWordChastise(target)
  if Spell.HolyWordChastise:CooldownRemaining() > 0 then return false end

  return Spell.HolyWordChastise:CastEx(target)
end

function sb.ShadowWordPain(target)
  if Spell.ShadowWordPain:Apply(target) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Spell.ShadowWordPain:Apply(enemy) then return true end
  end
end

function sb.HolyFire(target)
  if Spell.HolyFire:CooldownRemaining() > 0 then return false end

  if Spell.HolyFire:Apply(target) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and Spell.HolyFire:Apply(enemy) then return true end
  end

  if Spell.HolyFire:CastEx(target) then return true end
end

function sb.Smite(target)
  return Spell.Smite:CastEx(target)
end

return spellbook
