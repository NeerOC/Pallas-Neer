local options = {
  -- The sub menu name
  Name = "Hunter (Beast Mastery)",
  -- widgets
  Widgets = {
    {

    }
  }
}


local function HunterBeastmasteryCombat()
  local pet = Me.Pet

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then
    if pet and pet.Target then Me:PetFollow() end
    return
  end

  if pet then
    if not pet.Target or pet.Target ~= target then
      Me:PetAttack(target)
    end
  end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.HealthPct < 20 then
      if Spell.KillShot:CastEx(enemy, SpellCastExFlags.NoUsable) then return end
    end
  end

  if Spell.HuntersMark:Apply(target) then return end
  if Spell.KillCommand:CastEx(target) then return end
  if Spell.CobraShot:CastEx(target) then return end
end

local behaviors = {
      [BehaviorType.Combat] = HunterBeastmasteryCombat
}

return { Options = options, Behaviors = behaviors }
