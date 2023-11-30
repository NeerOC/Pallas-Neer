local gui = require("behaviors.wow_retail.deathknight.blood-gui")
local sb = require("behaviors.wow_retail.deathknight.blood-sb")

local function DeathKnightBlood()
  if Me.IsMounted or Me:IsCastingFixed() or Me:IsSitting() or Me:IsStunned() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if Spell.DeathStrike:CastEx(target) then return end
  if Spell.RuneStrike:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = DeathKnightBlood
}

return { Options = gui, Behaviors = behaviors }
