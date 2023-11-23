local options = {
  -- The sub menu name
  Name = "Demonhunter",
  -- widgets  TODO
  Widgets = {
  }
}

local function DemonHunterInitialCombat()
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if not Spell.AutoAttack.IsActive then
    Me:ToggleAttack()
  end

  if Spell.SoulCleave:CastEx(target) then return end
  if Spell.Shear:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = DemonHunterInitialCombat
}

return { Options = options, Behaviors = behaviors }
