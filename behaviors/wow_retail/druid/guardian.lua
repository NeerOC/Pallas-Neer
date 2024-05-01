local gui = require("behaviors.wow_retail.druid.guardian-gui")
local sb = require("behaviors.wow_retail.druid.guardian-sb")

local function DruidGuardian()
  if Me.IsMounted or Me.IsCastingOrChanneling or Me:IsStunned() then return false end
  if Me.ShapeshiftForm ~= ShapeshiftForm.Bear then return end

  -- General
  if sb.markofthewild() then return end
  if sb.growl() then return end
  -- Defensives
  if sb.frenziedregeneration() then return end
  if sb.barkskin() then return end
  if sb.ironfur() then return end
  if sb.docRegrowth() then return end

  -- Offensive
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return false end

  -- Interrupt
  if Me:InMeleeRange(target) and Spell.SkullBash:Interrupt() then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if sb.afflicted() then return end
  if sb.removecorruption() then return end
  if sb.thrash() then return end
  if sb.moonfire(target, true) then return end -- add aoe threat check
  if sb.maul(target) then return end
  if sb.mangle(target) then return end
  if sb.swipe(true) then return end
  if sb.moonfire(target) then return end
  if sb.swipe() then return end
end

local behaviors = {
  [BehaviorType.Combat] = DruidGuardian,
  [BehaviorType.Heal] = DruidGuardian
}

return { Options = gui, Behaviors = behaviors }
