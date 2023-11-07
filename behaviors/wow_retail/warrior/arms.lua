TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('PLAYER_TARGET_CHANGED')

local changePause = 0
function TargetListener:PLAYER_TARGET_CHANGED()
  changePause = wector.Game.Time + 250
end

local function WarriorArmsCombat()
  if Spell.BattleStance:Apply(Me) then return end

  if Me.IsMounted or Me:IsStunned() then return end

  if Spell.BattleShout:Apply(Me) then return end

  local sd = Me:GetAura(280776)

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and (enemy.HealthPct < 35 or sd) and Spell.Execute:CastEx(enemy, SpellCastExFlags.NoUsable) then return end
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if wector.Game.Time > changePause and not Me:IsAttacking(target) then
    Me:StartAttack(target)
  end

  if Me.HealthPct < 60 then
    if Spell.ImpendingVictory:CastEx(target) then return end
    if Spell.VictoryRush:CastEx(target) then return end
  end

  local wwbuff = Me:HasAura(85739)
  local enemies8 = Combat:GetEnemiesWithinDistance(8)
  if enemies8 > 1 and Spell.SweepingStrikes:CastEx(Me) then return end

  if Me:IsFacing(target) then
    if Spell.Rend:Apply(target) then return end
    if Spell.ColossusSmash:CastEx(target) then return end
    if Spell.MortalStrike:CastEx(target) then return end
    if Spell.Overpower.Charges == 2 and Spell.Overpower:CastEx(target) then return end
    if Spell.Whirlwind:CastEx(Me) then return end
    if Spell.ThunderClap:CastEx(Me) then return end
    if Spell.Overpower.Charges > 0 and Spell.Overpower:CastEx(target) then return end
    if Spell.Slam:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorArmsCombat
}

return { Behaviors = behaviors }
