local options = {
  -- The sub menu name
  Name = "Rogue (Combat)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "RogueCommonInStealth",
      text = "Attack in stealth",
      default = false
    },
  }
}
local function RogueCombatCombat()
  local CP = Me:GetPowerByType(PowerType.Obsolete)
  if CP >= 2 and Spell.SliceAndDice:Apply(Me) then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if CP >= 3 and Spell.Eviscerate:CastEx(target) then return end
  if Spell.SinisterStrike:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = RogueCombatCombat
}

return { Options = options, Behaviors = behaviors }
