local colors = require "data.colors"
local spellbook = {}
local sb = spellbook

TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('PLAYER_TARGET_CHANGED')
sb.auras = {
  swiftness = 69369
}

local changePause = 0
function TargetListener:PLAYER_TARGET_CHANGED()
  changePause = wector.Game.Time + 400
end

function sb.autoattack(target)
  if wector.Game.Time > changePause and not Me:IsAttacking(target) then
    Me:StartAttack(target)
  end
end

function sb.shred(target)
  return Me:IsBehind(target) and Spell.Shred:CastEx(target)
end

function sb.rake(target)
  return Spell.Rake:Apply(target, nil, true)
end

function sb.rip(target)
  return Me:GetPowerByType(PowerType.Obsolete) >= 4 and target:TimeToDeath() > 12 and target:TimeToDeath() ~= 9999 and
  Spell.Rip:Apply(target, nil, true)
end

function sb.ferociousbite(target)
  return Me:GetPowerByType(PowerType.Obsolete) >= 4 and target:TimeToDeath() < 12 and Spell.FerociousBite:CastEx(target)
end

function sb.berserk()
  return Combat.Burst and Spell.Berserk:CastEx(Me)
end

function sb.tigersfury()
  return Me.PowerPct < 40 and Spell.TigersFury:CastEx(Me)
end

function sb.manglecat(target)
  return Me:GetPowerByType(PowerType.Obsolete) < 5 and Spell.MangleCat:CastEx(target)
end

function sb.faeriefirecat(target)
  return Spell.FaerieFireFeral:Apply(target)
end

function sb.regrowth()
  return Me.HealthPct < 70 and Me:HasAura(sb.auras.swiftness) and Spell.Regrowth:CastEx(Me)
end

-- Bear

function sb.maul(target)
  return Me:GetPowerByType(PowerType.Rage) >= 25 and Spell.Maul:CastEx(target)
end

function sb.faeriefire(threatGet)
  if Spell.FaerieFireFeral:CooldownRemaining() > 0 then return end

  if threatGet and Spell.Growl:CooldownRemaining() > 0 then
    for _, enemy in pairs(Combat.Targets) do
      if not enemy.Aggro and enemy.Target then
        if Spell.FaerieFireFeral:CastEx(enemy) then return end
      end
    end
    return
  end

  local bestTarget = nil
  for _, enemy in pairs(Combat.Targets) do
    if not bestTarget or enemy:GetThreatValue(Me) > bestTarget:GetThreatValue(Me) then
      bestTarget = enemy
    end
  end

  return Spell.FaerieFireFeral:CastEx(bestTarget)
end

function sb.swipebear()
  return (not Spell.Maul.IsActive or Me:GetPowerByType(PowerType.Rage) > 60) and Me:GetPowerByType(PowerType.Rage) >= 25 and
      Combat:GetEnemiesWithinDistance(8) > 2 and
      Spell.SwipeBear:CastEx(Me)
end

function sb.growl()
  if Spell.Growl:CooldownRemaining() > 0 then return false end

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.Aggro and enemy.Target then
      if Spell.Growl:CastEx(enemy) then return end
    end
  end
end

function sb.challengingroar()
  if Spell.ChallengingRoar:CooldownRemaining() > 0 or Spell.Growl:CooldownRemaining() == 0 then return end
  local nonAggro = 0

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.Aggro and Me:GetDistance(enemy) < 10 then
      nonAggro = nonAggro + 1
    end
  end

  return not Me:IsMoving() and nonAggro > 1 and Spell.ChallengingRoar:CastEx(Me)
end

function sb.getlowestThreat()
  local lowest
  for _, enemy in pairs(Combat.Targets) do
    if Me:InMeleeRange(enemy) or Me:GetDistance(enemy) < 8 then
      if not lowest or lowest:GetThreatValue(Me) > enemy:GetThreatValue(Me) then
        lowest = enemy
      end
    end
  end

  if lowest then
    DrawText(lowest:GetScreenPosition(), colors.white, "Lowest threat unit")
  end
  return lowest
end

local lastFace = 0
function sb.faceunit(target)
  if not Me:IsFacing(target) and wector.Game.Time > lastFace then
    target:Interact()
    lastFace = wector.Game.Time + 500
  end
end

return spellbook
