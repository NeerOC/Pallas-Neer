local function InitialWarrior()
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Spell.Execute:CastEx(target) then return end
  if Spell.ShieldSlam:CastEx(target) then return end
  if Spell.VictoryRush:CastEx(target) then return end
  if Spell.Slam:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = InitialWarrior
}

return { Behaviors = behaviors }
