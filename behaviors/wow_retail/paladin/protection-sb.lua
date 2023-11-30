---@diagnostic disable: duplicate-set-field
local spellbook = {}

local sb = spellbook

sb.auras = {
  consecration = 188370,
  shininglight = 327510
}

ProtListener = wector.FrameScript:CreateListener()
ProtListener:RegisterEvent('UNIT_COMBAT')
ProtListener:RegisterEvent('PLAYER_REGEN_ENABLED')

sb.percentfive = 0

local damageEvents = {}
function ProtListener:UNIT_COMBAT(target, event, text, amount, school)
  if target == Me and event == "WOUND" then
    local damage = {time = wector.Game.Time, amt = amount}
    table.insert(damageEvents, damage)
  end
end

function ProtListener:PLAYER_REGEN_ENABLED()
  damageEvents = {}
end

function sb.getdamagetakenlastseconds(seconds)
  local currentTime = wector.Game.Time
  local totalDamage = 0

  for i = #damageEvents, 1, -1 do
    local damage = damageEvents[i]

    if currentTime - damage.time <= seconds * 1000 then
      totalDamage = totalDamage + damage.amt
    else
      -- Assuming events are ordered by time, stop iterating if we go beyond the specified time frame
      break
    end
  end

  return totalDamage
end

function sb.devotionaura()
  return Spell.DevotionAura:Apply(Me)
end

function sb.consecration(filler)
  return (not Me:HasAura(sb.auras.consecration) or filler) and Combat:GetEnemiesWithinDistance(8) > 0 and
      Spell.Consecration:CastEx(Me)
end

function sb.judgment(target)
  return Spell.Judgment:CastEx(target)
end

function sb.blessedhammer()
  return (Combat:GetEnemiesWithinDistance(8) > 0 or Me:GetPowerByType(PowerType.HolyPower) < 5) and Spell.BlessedHammer:CastEx(Me)
end

function sb.shieldoftherigtheous()
  local targetsHit = 0

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and Me:InMeleeRange(enemy) then
      targetsHit = targetsHit + 1
    end
  end

  return targetsHit > 0 and Spell.ShieldOfTheRighteous:CastEx(Me)
end

function sb.hammerofwrath()
  if Spell.HammerOfWrath:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and enemy.HealthPct < 20 then
      if Spell.HammerOfWrath:CastEx(enemy) then return end
    end
  end
end

function sb.wordofglory()
  local freeWog = Me:HasAura(sb.auras.shininglight)

  if Me.HealthPct < 50 and freeWog and Spell.WordOfGlory:CastEx(Me) then return end

  local lowestFriend = Heal.PriorityList[1] and Heal.PriorityList[1].Unit

  return lowestFriend and lowestFriend.HealthPct < 40 and freeWog and Spell.WordOfGlory:CastEx(lowestFriend)
end

function sb.layonhands()
  return Me.HealthPct < 20 and Spell.LayOnHands:CastEx(Me)
end

function sb.avengersshield(target, aoe)
  if aoe and table.length(Combat.Targets) < 2 then return end

  if Spell.AvengersShield:CooldownRemaining() > 0 then return end

  local castTarget
  local noAggroTarget

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) then
      if enemy.IsCastingOrChanneling and enemy.IsInterruptible then
        castTarget = enemy
      end

      if not enemy.Aggro then
        noAggroTarget = enemy
      end
    end
  end

  target = castTarget or noAggroTarget or target

  return Spell.AvengersShield:CastEx(target)
end

function sb.handofreckoning()
  if Spell.HandOfReckoning:CooldownRemaining() > 0 then return end

  local rangeOverride = Spell.Judgment:CooldownRemaining() > 0 and Spell.AvengersShield:CooldownRemaining() > 0

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.Aggro and enemy.Target and enemy.Target ~= Me and (not Me:IsFacing(enemy) or rangeOverride) then
      if Spell.HandOfReckoning:CastEx(enemy) then return end
    end
  end
end

function sb.rebuke()
  return Spell.Rebuke:Interrupt()
end

function sb.cleanse()
  if Spell.Cleanse:CooldownRemaining() > 0 then return end

  return Spell.CleanseToxins:Dispel(true, DispelPriority.Low, WoWDispelType.Poison, WoWDispelType.Disease)
end

function sb.blessingofsacrifice()
  if Spell.BlessingOfSacrifice:CooldownRemaining() > 0 then return end
  if Spell.HandOfReckoning:CooldownRemaining() == 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    local enemyTarget = enemy.Target
    if (not enemy.Aggro or enemy.IsCastingOrChanneling) and enemyTarget and enemyTarget.IsPlayer and enemyTarget ~= Me then
      if Spell.BlessingOfSacrifice:CastEx(enemyTarget) then return end
    end
  end
end

function sb.blessingoffreedom()
  local friend = Heal.Friends.Healers[1]
  if not friend then return end

  return Me:IsMoving() and friend:IsMoving() and Spell.BlessingOfFreedom:CastEx(friend)
end

function sb.ardentdefender()
  return (Me.HealthPct < 15 or sb.percentfive > 20) and Spell.ArdentDefender:CastEx(Me)
end

function sb.eyeoftyr()
  if Spell.EyeOfTyr:CooldownRemaining() > 0 then return end

  return sb.percentfive > 15 and Combat:AllTargetsGathered(10) and Spell.EyeOfTyr:CastEx(Me)
end

return spellbook
