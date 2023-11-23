local options = {
  -- The sub menu name
  Name = "Monk (Initial)",
  -- widgets
  Widgets = {
  }
}

local function MonkInitial()
  if Me.IsMounted or Me:IsCastingFixed() or Me:IsStunned() then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  Me:ToggleAttack()

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Spell.SpinningCraneKick:CastEx(Me) then return end

  if Spell.BlackoutKick:CastEx(target) then return end
  if Spell.TigerPalm:CastEx(target) then return end
end

return {
  Options = options,
  Behaviors = {
    [BehaviorType.Combat] = MonkInitial
  }
}
