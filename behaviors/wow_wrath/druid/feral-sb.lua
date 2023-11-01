local colors = require "data.colors"
local spellbook = {}
local sb = spellbook

TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('PLAYER_TARGET_CHANGED')

local changePause = 0
function TargetListener:PLAYER_TARGET_CHANGED()
  changePause = wector.Game.Time + 400
end

function sb.autoattack(target)
  if wector.Game.Time > changePause and not Me:IsAttacking(target) then
    Me:StartAttack(target)
  end
end

function sb.rake(target)
  return Spell.Rake:Apply(target)
end

function sb.rip(target)
  return target:TimeToDeath() > 10 and target:TimeToDeath() ~= 9999 and Spell.Rip:Apply(target)
end

function sb.ferociousbite(target)
  return target:TimeToDeath() < 10 and Spell.FerociousBite:CastEx(target)
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

function sb.swipe()
  return not Spell.Maul.IsActive and Me:GetPowerByType(PowerType.Rage) >= 25 and Combat:GetEnemiesWithinDistance(8) > 2 and
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

return spellbook
