---@diagnostic disable: param-type-mismatch
local common = require('behaviors.wow_wrath.paladin.common')
local sb = require('behaviors.wow_wrath.paladin.holy-sb')
local gui = require('behaviors.wow_wrath.paladin.holy-gui')

local function BeaconLogic()
  local tank = sb:gettank()

  if tank and tank.HealthPct < 50 then return tank end

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    local friendLost = friend:GetHealthLost()

    if tank and friend == tank then goto continue end

    if not tank then return friend end

    if friendLost > 0 and tank and tank:WithinLineOfSight(friend) then
      return friend
    end

    ::continue::
  end

  return tank or Me
end

local function PaladinHolyDPS()
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target or not Me:IsFacing(target) then return end
  if common:Judgement(target) then return end

  if not Settings.HolyDPSToggle or Me.PowerPct <= Settings.DPSManaPct then return end

  if sb.consecration() then return true end
  if sb.holywrath() then return true end
  if common:HammerOfWrath() then return true end
  if sb.exorcism(target) then return true end
  if sb.shieldofrighteousness(target) then return true end
end

local function debugSpell()
  local target = Me.Target
  if not target then return end

  local cast = target.CurrentCast
  local spell = target.CurrentSpell
  local channel = target.CurrentChannel

  if cast or spell or channel then
    local curSpell = cast or spell or channel
    if not curSpell then return end

    print("Target Casting: " .. curSpell.Name .. ", With ID: " .. curSpell.Id .. ", Cast Remaining: " .. curSpell:CastRemaining())
  end
end

local function PaladinHolyHeal()
  if sb.handleoverheal() then return end
  if sb.handleimages() then return end
  if sb.handleinterrupt() then return end

  --debugSpell()

  if Me.IsCastingOrChanneling or Me:IsStunned() or Me:IsSitting() then return end

  if common:DoAura() then return end

  if Me.IsMounted or wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  -- Pre Buffs
  if not Me.InCombat then
    common:DoSeal()
    --common:DoBuff()
    common:DoRF()
  end

  WoWItem:UseHealthstone()

  -- Mirror image cleanup

  local friend = BeaconLogic()

  if sb.layonhands(friend) then return end
  if sb.handofprotection(friend) then return end
  if sb.handofsacrifice() then return end

  if sb.beaconoflight() then return end

  if sb.holygrace(friend) then return end
  if sb.holylight(friend) then return end
  if sb.holyshock(friend) then return end
  if sb.flashoflight(friend) then return end

  if sb.sacredshield() then return end
  if sb.cleanse() then return end
  if sb.flashhot() then return end
  if sb.prehealcast() then return end
  if sb.handofsalvation() then return end
  if sb.handoffreedom() then return end
  if sb.redemption() then return end

  if PaladinHolyDPS() then return end
end

local behaviors = {
  [BehaviorType.Heal] = PaladinHolyHeal,
  [BehaviorType.Combat] = PaladinHolyHeal
}

return { Options = gui, Behaviors = behaviors }
