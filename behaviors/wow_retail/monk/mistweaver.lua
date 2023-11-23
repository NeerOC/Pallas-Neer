---@diagnostic disable: undefined-field, duplicate-set-field
local gui = require("behaviors.wow_retail.monk.mistweaver-gui")
local sb = require("behaviors.wow_retail.monk.mistweaver-sb")
local colors = require("data.colors")

MistListener = wector.FrameScript:CreateListener()
MistListener:RegisterEvent('CHAT_MSG_ADDON')
MistListener:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

local pausing = false
function MistListener:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
  if prefix ~= "pallas" then return end

  if text == "pause" and not pausing then
    pausing = true
  end
end

function MistListener:COMBAT_LOG_EVENT_UNFILTERED(entry)
  if not entry then return end
  if entry.EventTypeName ~= "SPELL_CAST_SUCCESS" then return end
  if entry.Source.Name ~= Me.NameUnsafe then return end

  if pausing then
    pausing = false
  end
end

local function HealTrinket(friend)
  local trink1Pct = Settings.MistweaverTrinket1Pct
  local trink2Pct = Settings.MistweaverTrinket2Pct
  local trinket1 = WoWItem:GetUsableEquipment(EquipSlot.Trinket1)
  local trinket2 = WoWItem:GetUsableEquipment(EquipSlot.Trinket2)

  if trink1Pct == 0 and trink2Pct == 0 then return false end

  if trinket1 then
    if friend.HealthPct < trink1Pct and trinket1:UseX(friend) then return true end
  end

  if trinket2 then
    if friend.HealthPct < trink2Pct and trinket2:UseX(friend) then return true end
  end
end

local function MistweaverAoEHeal(lowest)
  local revivalBelow = 0
  local essencefontBelow = 0
  local sheilunBelow = 0

  lowest = lowest or Me

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if friend.HealthPct < Settings.MistweaverSheilunPct then
      sheilunBelow = sheilunBelow + 1
    end

    if friend.HealthPct < Settings.MistweaverRevivalPct then
      revivalBelow = revivalBelow + 1
    end

    if friend.HealthPct < Settings.MistweaverEssenceFontPct then
      essencefontBelow = essencefontBelow + 1
    end
  end

  if revivalBelow >= Settings.MistweaverRevivalCount then
    if Spell.Revival:CastEx(Me) then return end
  end

  if sheilunBelow >= Settings.MistweaverSheilunCount then
    local sheilun = Me:GetAura(sb.auras.sheilunsgift)

    if sheilun and sheilun.Stacks >= 5 and Spell.SheilunsGift:CastEx(lowest) then return end
  end

  if essencefontBelow >= Settings.MistweaverEssenceFontCount then
    if Spell.EssenceFont:CastEx(Me) then return end
  end
end

local function MonkMistweaver()
  if pausing then
    DrawText(Me:GetScreenPosition(), colors.white, "Pausing")
    return
  end

  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  -- Cancel mana tea if 100% mana
  if sb.manateacancel() then return end

  -- Return if we are currently casting and its not Soothing mist/Spinning Crane Kick
  if sb.mistweavercasting() then return end

  -- OGCD Interrupt, so can used whenever we are not channeling or casting.
  if sb.spearhandstrike() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  local friend = Heal.PriorityList[1] and Heal.PriorityList[1].Unit
  local targetFriend = Me.Target and not Me:CanAttack(Me.Target) and Me.Target

  if targetFriend then
    if sb.soothingfriend(targetFriend) then return end
  end

  if friend then
    if friend.HealthPct > Settings.MistweaverDoNotAoePct then
      if MistweaverAoEHeal(friend) then return end
    end

    if HealTrinket(friend) then return end

    if friend == Me then
      if sb.expelharm() then return end
    end

    if sb.envelopingmist() then return end

    if sb.lifecocoon(friend) then return end
    if sb.zenpulse(friend) then return end
    if sb.vivify(friend) then return end
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget

  if sb.risingsunkick(target) then return end
  if sb.renewingmist() then return end
  if sb.detox() then return end


  if not target or friend and friend.HealthPct < Settings.MistweaverVivifyPct and not Me:IsSilenced() then return end

  if sb.touchofdeath(target) then return end
  if sb.spinningcranekick() then return end
  if sb.blackoutkick(target) then return end
  if sb.tigerpalm(target) then return end
end

return {
  Options = gui,
  Behaviors = {
    [BehaviorType.Heal] = MonkMistweaver,
    [BehaviorType.Combat] = MonkMistweaver
  }
}
