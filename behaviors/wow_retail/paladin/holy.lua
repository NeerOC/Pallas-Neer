local sb = require("behaviors.wow_retail.paladin.holy-sb")
local gui = require("behaviors.wow_retail.paladin.holy-gui")


local function HolyPaladinDPS()
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target or not Me:IsFacing(target) then return false end

  if sb.shieldoftherigtheous() then return end
  if sb.hammerofwrath(target) then return end
  if sb.consecration() then return end
  if sb.judgment(target) then return end
  if sb.crusaderstrike(target) then return end
  if Spell.HolyShock:CastEx(target) then return end
  if Spell.HolyPrism:CastEx(target) then return end
end

local function HolyAOEHeal()
  local lowest = Heal.PriorityList[1] and Heal.PriorityList[1].Unit

  if lowest and lowest.HealthPct < Settings.PaladinHolyCritical then
    return false
  end

  if sb.lightofdawn() then return true end

  local tollCount = 0
  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if friend.HealthPct < Settings.PaladinHolyDivineTollPct then
      tollCount = tollCount + 1
    end
  end

  if tollCount >= Settings.PaladinHolyDivineTollCount and Me:GetPowerByType(PowerType.HolyPower) < 3 then
    if Spell.DivineToll:CastEx(lowest) then return true end
  end
end

local function HolyPaladin()
  if sb.crusaderaura() then return end

  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() or Me.IsCastingOrChanneling then return end

  if sb.handleoverheal() then return end
  if sb.rebuke() then return end

  if sb.redemption() then return end
  if sb.devotionaura() then return end
  if sb.beaconoflight() then return end

  --- Defensive..s?
  if sb.divineshield() then return end
  if sb.divineprotection() then return end
  if WoWItem:UseHealthstone() then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  -- AoE Healing
  if HolyAOEHeal() then return end

  -- Regular healing
  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if sb.layonhands(friend) then return end
    if sb.handofdivinity(friend) then return end
    if sb.holylight(friend, true) then return end
    if sb.blessingofsacrifice(friend) then return end
    if sb.wordofglory(friend) then return end
    if sb.holyprism(friend) then return end
    if sb.flashOflight(friend) then return end
    if sb.holyshock(friend) then return end
    if sb.holylight(friend) then return end
  end

  -- Utility
  if sb.daybreak() then return end
  if sb.tyrsdeliverance() then return end
  if sb.beaconoffaith() then return end
  if sb.intercession() then return end
  if sb.blessingofprotection() then return end
  if sb.blindinglight() then return end
  if sb.cleanse() then return end
  if sb.blessingoffreedom() then return end
  if sb.glimmer() then return end

  -- Dps
  HolyPaladinDPS()
end

local behaviors = {
  [BehaviorType.Heal] = HolyPaladin,
  [BehaviorType.Combat] = HolyPaladin
}

return { Options = gui, Behaviors = behaviors }
