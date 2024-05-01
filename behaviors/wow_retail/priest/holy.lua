---@diagnostic disable: undefined-field
local gui = require("behaviors.wow_retail.priest.holy-gui")
local sb = require("behaviors.wow_retail.priest.holy-sb")
local colors = require("data.colors")

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
    local maxTargets = 0

    for i, target1 in pairs(sancTargets) do
      local goodTargets = 0
      for j, target2 in pairs(sancTargets) do
        if i ~= j and target1:GetDistance(target2) <= 10 then
          goodTargets = goodTargets + 1
        end
      end
      if goodTargets > maxTargets then
        maxTargets = goodTargets
        bestTarget = target1
      end
    end

    if maxTargets >= Settings.PriestHolyWordSanctifyCount then
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

local function DebugDraw()
  if Me.Target then
    DrawText(Me.Target:GetScreenPosition(), colors.white, tostring(Me:GetDistance(Me.Target)))
  end
end

local function PriestHoly()
  --DebugDraw()
  --DebugAuras()

  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if sb.stopdamage(friend) then return end

    if Me.IsCastingOrChanneling then return end

    if WoWItem:UseHealthstone() then return end
    if sb.fade() then return end
    if sb.incorporeal() then return end
    if sb.afflicted() then return end
    if sb.bursting() then return end

    local GCD = wector.SpellBook.GCD
    if GCD:CooldownRemaining() > 0 then return end

    if not Me.InCombat then
      if sb.powerwordfortitude() then return end
    end

    if sb.purify() then return end

    if friend then
      -- Out Of Combat, Heal up with heal.
      if sb.heal(friend, true) then return end

      if friend.HealthPct > Settings.PriestHolyDoNotAoe then
        if PriestHolyAOE(friend) then return end
      end

      if sb.healtrinket(friend) then return end

      if friend == Me then
        if sb.desperateprayer() then return end
      end

      if sb.guardianspirit(friend) then return end
      if sb.powerwordlife(friend) then return end
      if sb.holywordserenity(friend) then return end
      if sb.flashheal(friend) then return end
      if sb.heal(friend) then return end
      if sb.renew(friend) then return end
      if sb.prayerofmending(friend) then return end
      if sb.powerwordshield(friend) then return end
      if sb.renew(friend, true) then return end
    end
  end
  if sb.prayerofmending() then return end
  if sb.divinestar() then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  -- Fish for free heals when almost OOM
  if Me.PowerPct < 5 and Spell.Smite:CastEx(target) then return end

  if friend and friend.HealthPct < 70 then return end
  local enemies12 = Combat:GetEnemiesWithinDistance(12)

  if sb.empyrealblaze() then return end
  if sb.shadowfiend(target) then return end
  if sb.holywordchastise(target) then return end
  if sb.holyfire(target) then return end
  if sb.shadowwordpain(target) then return end
  if Me.PowerPct > 50 and (enemies12 > 2 or enemies12 > 0 and Me:IsMoving()) and Spell.HolyNova:CastEx(Me) then return end
  if sb.smite(target) then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestHoly,
  [BehaviorType.Combat] = PriestHoly
}

return { Options = gui, Behaviors = behaviors }
