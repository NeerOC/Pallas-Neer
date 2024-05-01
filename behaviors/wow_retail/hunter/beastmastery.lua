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
  local claw = WoWSpell("Claw")
  local pet = Me.Pet

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then
    if pet and pet.Target then Me:PetFollow() end
    return
  end



  if pet then
      Me:PetAttack(target)
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

  if target.HealthPct > 85 and Spell.HuntersMark:Apply(target) then return end
  if Spell.KillCommand:CastEx(target) then return end
  if Spell.KillCommand:CooldownRemaining() > 1500 and Spell.CobraShot:CastEx(target) then return end
end

local behaviors = {
      [BehaviorType.Combat] = HunterBeastmasteryCombat
}

return { Options = options, Behaviors = behaviors }
