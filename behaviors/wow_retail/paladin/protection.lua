local gui = require("behaviors.wow_retail.paladin.protection-gui")
local sb = require("behaviors.wow_retail.paladin.protection-sb")

local auras = {}
local function DebugAuras()
  local target = Me.Target
  if target then
    for _, aura in pairs(target.Auras) do
      if not table.contains(auras, aura.Name) then
        table.insert(auras, aura.Name)
        print("Aura: " .. aura.Name .. ", ID: " .. aura.Id)
      end
    end
  end
end

local function PaladinProtCombat()
  --DebugAuras()
  sb.percentfive = math.floor(sb.getdamagetakenlastseconds(5) / Me.HealthMax * 100)

  if Me:IsCastingFixed() or Me:IsSitting() or Me:IsStunned() or Me.IsMounted then return end

  if WoWItem:UseHealthstone() then return end
  if sb.handofreckoning() then return end
  if sb.rebuke() then return end
  if sb.shieldoftherigtheous() then return end

  -- GCD Check
  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if sb.devotionaura() then return end
  if sb.interecession() then return end

  if sb.blessingofprotection() then return end
  if sb.stunlogic() then return end
  if sb.defenselogic() then return end
  if sb.layonhands() then return end
  if sb.cleanse() then return end
  if sb.blessingofsacrifice() then return end
  if sb.blessingoffreedom() then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if sb.consecration() then return end
  if sb.wordofglory() then return end
  if sb.avengersshield(target, true) then return end
  if sb.judgment(target) then return end
  if sb.hammerofwrath() then return end
  if sb.avengersshield(target) then return end
  if sb.blessedhammer() then return end
  if sb.consecration(true) then return end
end

local behaviors = {
  [BehaviorType.Combat] = PaladinProtCombat,
  [BehaviorType.Heal] = PaladinProtCombat
}

return { Options = gui, Behaviors = behaviors }
