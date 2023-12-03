---@diagnostic disable: undefined-field
local gui = require("behaviors.wow_retail.priest.holy-gui")
local sb = require("behaviors.wow_retail.priest.holy-sb")

local function PriestHolyAOE(friend)
  if sb.holynova() then return end

  local pohCount = 0
  local divinehymnCount = 0
  local cohCount = 0
  local sancTargets = {}

  for k, v in pairs(Heal.PriorityList) do
    local member = v.Unit

    if member.HealthPct < Settings.PriestHolyWordSanctifyPct then
      table.insert(sancTargets, member)
    end

    if member.HealthPct < Settings.PriestHolyPrayerOfHealingPct then
      pohCount = pohCount + 1
    end

    if member.HealthPct < Settings.PriestHolyDivineHymnPct then
      divinehymnCount = divinehymnCount + 1
    end

    if member.HealthPct < Settings.PriestHolyCircleOfHealingPct then
      cohCount = cohCount + 1
    end
  end

  if #sancTargets >= Settings.PriestHolyWordSanctifyCount then
    local bestTarget = nil
    local goodTargets = 0

    for i, target1 in pairs(sancTargets) do
      for j, target2 in pairs(sancTargets) do
        if i == j then
          print("Same target debug for sanc")
        end
        if i ~= j and target1:GetDistance(target2) <= 10 then
          bestTarget = target1
          goodTargets = goodTargets + 1
        end
      end
    end

    if goodTargets >= Settings.PriestHolyWordSanctifyCount then
      if Spell.HolyWordSanctify:CastEx(bestTarget) then
        return
      end
    end
  end

  if divinehymnCount >= Settings.PriestHolyDivineHymnCount then
    if Spell.DivineHymn:CastEx(Me) then return end
  end

  if cohCount >= Settings.PriestHolyCircleOfHealingCount then
    if Spell.CircleOfHealing:CastEx(friend) then return end
  end

  if pohCount >= Settings.PriestHolyPrayerOfHealingCount then
    if Spell.PrayerOfHealing:CastEx(friend) then return end
  end
end

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

local function PriestHoly()
  DebugAuras()


  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  local friend = Heal.PriorityList[1] and Heal.PriorityList[1].Unit
  if sb.stopdamage(friend) then return end

  if Me.IsCastingOrChanneling then return end

  if WoWItem:UseHealthstone() then return end
  if sb.fade() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if not Me.InCombat then
    if sb.powerwordfortitude() then return end
  end

  if sb.purify() then return end

  local targetFriend = Me.Target and not Me:CanAttack(Me.Target) and Me.Target

  if targetFriend then
    if Spell.Renew:Apply(targetFriend) then return end
    if Spell.PowerWordShield:CastEx(targetFriend) then return end
  end

  if friend then
    if friend.HealthPct > Settings.PriestHolyDoNotAoe then
      if PriestHolyAOE(friend) then return end
    end

    if sb.healtrinket(friend) then return end

    if friend == Me then
      if sb.desperateprayer() then return end
    end

    if sb.powerwordlife(friend) then return end
    if sb.holywordserenity(friend) then return end
    if sb.flashheal(friend) then return end
    if sb.heal(friend) then return end
    if sb.renew(friend) then return end
    if sb.prayerofmending(friend) then return end
    if sb.powerwordshield(friend) then return end
  end

  if sb.prayerofmending() then return end
  if sb.divinestar() then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if sb.shadowfiend(target) then return end
  if sb.holywordchastise(target) then return end
  if sb.holyfire(target) then return end
  if sb.shadowwordpain(target) then return end
  if sb.smite(target) then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestHoly,
  [BehaviorType.Combat] = PriestHoly
}

return { Options = gui, Behaviors = behaviors }
