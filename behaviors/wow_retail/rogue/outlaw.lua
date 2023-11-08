local sb = require("behaviors.wow_retail.rogue.outlaw-sb")
local gui = require("behaviors.wow_retail.rogue.outlaw-gui")

local function RogueOutlaw()
  if sb.stealthreturn() then return end
  if Me.IsMounted or Me:IsStunned() or Me:IsSitting() then return end

  if not Me.InCombat then
    if sb.instantpoison() then return end
    if sb.atrophicpoison() then return end
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if Me:GetDistance(target) > 15 or wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if sb.bladeflurry() then return end
  if sb.stealth() then return end
  if sb.rollthebones() then return end
  if sb.adrenalinerush() then return end
  if sb.vanishbetween(target) then return end
  if sb.dancebetween(target) then return end
  if sb.betweentheeyes(target) then return end
  if sb.sliceanddice() then return end
  if sb.dispatch(target) then return end
  if sb.ambush(target) then return end
  if sb.pistolshot(target) then return end
  if sb.sinisterstrike(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = RogueOutlaw
}

return { Options = gui, Behaviors = behaviors }
