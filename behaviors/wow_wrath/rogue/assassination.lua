local colors = require "data.colors"
local options = {
  -- The sub menu name
  Name = "Rogue (Ass)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "placeholder",
      text = "placeholder",
      default = false
    },
  }
}

local auras = {
}

local function RogueAssassinationCombat()
  local CP = Me:GetPowerByType(PowerType.Obsolete)
  local Energy = Me.Power

  if CP >= 2 then
    if Spell.SliceAndDice:Apply(Me) then return end
    if Me.HealthPct < 70 and Spell.Recuperate:Apply(Me) then return end
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  local strongEnemy = target.Health > Me.HealthMax * 0.2

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Me:HasAura(Spell.Stealth.Name) then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if CP >= 4 and Spell.Eviscerate:CastEx(target) then return end
  if strongEnemy and Spell.Mutilate:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = RogueAssassinationCombat
}

return { Options = options, Behaviors = behaviors }
