local gui = require("behaviors.wow_wrath.druid.feral-gui")
local sb = require("behaviors.wow_wrath.druid.feral-sb")
local colors = require("data.colors")

local function DruidFeralCombat()
  if Me:IsSitting() or Me.IsMounted or Me:IsCastingFixed() then return end

  if not Me.InCombat then
    --if not Me:HasAura(Spell.MarkOfTheWild.Name) and Spell.MarkOfTheWild:CastEx(Me) then return end
    --if not Me:HasAura(Spell.Thorns.Name) and Spell.Thorns:CastEx(Me) then return end
  end

  if sb.growl() then return end
  if sb.challengingroar() then return end

  local target = sb.getlowestThreat()
  if not target then return end

  Me:SetTarget(target)

  if sb.faeriefire(true) then return end
  if sb.autoattack(target) then return end
  if Spell.MangleBear:CastEx(target) then return end
  if sb.swipe() then return end
  if sb.maul(target) then return end
  if sb.faeriefire() then return end
end

return {
  Options = gui,
  Behaviors = {
    [BehaviorType.Combat] = DruidFeralCombat
  }
}
