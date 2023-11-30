---@diagnostic disable: undefined-field
local spellbook = {}

local sb = spellbook

sb.auras = {
  improvedpurify = 390632,
  lightweaver = 390993,
  surgeoflight = 114255,
  rhapsody = 390636,
  entangled = 408556,
  protectivelight = 193065,
  inspiration = 390677
}

function sb.castingdamage()
  local spell = Me.CurrentSpell
  if not spell then return false end

  return spell.Id == Spell.Smite.Id or spell.Id == Spell.HolyFire.Id
end

function sb.stopdamage(friend)
  if not friend then return end

  if friend.HealthPct > Settings.PriestHolyStopDPS then return end

  return sb.castingdamage() and Me:StopCasting()
end

function sb.healtrinket(friend)
  local trink1Pct = Settings.PriestHolyTrinket1Pct
  local trink2Pct = Settings.PriestHolyTrinket2Pct
  local trinket1 = WoWItem:GetUsableEquipment(EquipSlot.Trinket1)
  local trinket2 = WoWItem:GetUsableEquipment(EquipSlot.Trinket2)

  if trink1Pct == 0 and trink2Pct == 0 then return false end

  if trinket1 then
    if friend.HealthPct < trink1Pct and trinket1:UseX(friend) then return true end
  end

  if trinket2 then
    if friend.HealthPct < trink2Pct and trinket2:UseX(friend) then return true end
  end
end

--- Class Spells/Buffs
local nextBuff = 0
function sb.powerwordfortitude()
  if Me.InCombat or wector.Game.Time < nextBuff then return false end

  for _, friend in pairs(Heal.Friends.All) do
    if Spell.PowerWordFortitude:Apply(friend) then
      nextBuff = wector.Game.Time + 5000
      return true
    end
  end
end

function sb.purify()
  if Spell.Purify:CooldownRemaining() > 0 then return false end

  if Me:HasAura(sb.auras.improvedpurify) then
    if Spell.Purify:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Disease) then return true end
    return
  end

  if Spell.Purify:Dispel(true, DispelPriority.Low, WoWDispelType.Magic) then return true end
end

function sb.dispelmagic()
  if Combat.Enemies == 0 or not Settings.PriestHolyPurge then return false end

  return Spell.DispelMagic:Dispel(false, DispelPriority.Low, WoWDispelType.Magic)
end

function sb.desperateprayer()
  if not Me.InCombat or Me.HealthPct > Settings.PriestDesperatePrayer then return false end

  return Spell.DesperatePrayer:CastEx(Me)
end

function sb.fade()
  if Spell.Fade:CooldownRemaining() > 0 then return false end

  if Me:HasAura(sb.auras.entangled) then
    if Spell.Fade:CastEx(Me) then return end
  end
  --[[
  for _, enemy in pairs(Combat.Targets) do
    if enemy.Aggro or enemy.IsCastingOrChanneling and enemy.Target and enemy.Target == Me then
      if Spell.Fade:CastEx(Me) then return true end
    end
  end
  --]]
end

function sb.protectivelight()
  local tank = Me.FocusTarget
  if not tank then return end

  return not tank:HasAura(sb.auras.inspiration) and Spell.FlashHeal:CastEx(tank)
end

--- Single Target Healing Spells
function sb.prayerofmending(target)
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

function sb.flashheal(target)
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

function sb.heal(target)
  if target.HealthPct > Settings.PriestHolyLightweaveHeal then return false end

  if Me:HasAura(sb.auras.lightweaver) and Spell.Heal:CastEx(target) then return true end

  if target.HealthPct > Settings.PriestHolyHeal then return false end

  return Spell.Heal:CastEx(target)
end

function sb.renew(target)
  if target.HealthPct > Settings.PriestHolyRenew then return false end

  return Spell.Renew:Apply(target)
end

function sb.powerwordshield(target)
  if target.HealthPct > Settings.PriestHolyWordShield then return false end

  return Spell.PowerWordShield:Apply(target)
end

function sb.holywordserenity(target)
  if target.HealthPct > Settings.PriestHolyWordSerenity then return false end

  return Spell.HolyWordSerenity:CastEx(target)
end

function sb.guardianspirit(target)
  if not target.InCombat or target.HealthPct > Settings.PriestHolyGuardianSpirit then return false end

  return Spell.GuardianSpirit:CastEx(target)
end

function sb.powerwordlife(target)
  if not Spell.PowerWordLife.IsKnown or target.HealthPct > 35 then return false end

  return Spell.PowerWordLife:CastEx(target, SpellCastExFlags.NoUsable)
end

--- DPS Spells
function sb.shadowfiend(target)
  return Me.PowerPct < 80 and target:TimeToDeath() > 12 and Spell.Shadowfiend:CastEx(target)
end

function sb.divinestar()
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

function sb.holywordchastise(target)
  if Spell.HolyWordChastise:CooldownRemaining() > 0 then return false end

  return Spell.HolyWordChastise:CastEx(target)
end

function sb.shadowwordpain(target)
  if Spell.ShadowWordPain:Apply(target) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Spell.ShadowWordPain:Apply(enemy) then return true end
  end
end

function sb.holyfire(target)
  if Spell.HolyFire:CooldownRemaining() > 0 then return false end

  if Spell.HolyFire:Apply(target) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and Spell.HolyFire:Apply(enemy) then return true end
  end

  if Spell.HolyFire:CastEx(target) then return true end
end

function sb.smite(target)
  return Spell.Smite:CastEx(target)
end

function sb.holynova()
  local aura = Me:GetAura(sb.auras.rhapsody)
  if not aura or aura.Stacks < 20 then return end

  local enemies = Combat:GetEnemiesWithinDistance(12)
  local friends = Heal:GetMembersAround(Me.ToUnit, 12, 95)

  return friends > 1 and enemies >= 1 and Spell.HolyNova:CastEx(Me)
end


return spellbook
