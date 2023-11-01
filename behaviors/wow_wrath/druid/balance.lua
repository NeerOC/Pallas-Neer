local colors = require("data.colors")
local function BalanceHeal()

end

local function BalanceCombat()
  if Me:IsSitting() then return end

  if Spell.MarkOfTheWild:Apply(Me) then return end
  if Spell.Thorns:Apply(Me) then return end

  local target = Combat.BestTarget
  if not target then return end
  local textPos = World2Screen(target.Position)

  if Spell.Wrath:InRange(target) then
    DrawText(textPos, colors.green, "In Range")
  else
    DrawText(textPos, colors.red, "Out Of Range")
  end

  if not Me:IsAttacking(target) and Me:IsFacing(target) then
    Me:ToggleAttack()
  end

  if Spell.Wrath:CastEx(target) then return end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = BalanceHeal,
    [BehaviorType.Combat] = BalanceCombat
  }
}
