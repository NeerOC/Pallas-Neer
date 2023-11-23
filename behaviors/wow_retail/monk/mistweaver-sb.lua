---@diagnostic disable: undefined-field
local spellbook = {}

local sb = spellbook

sb.auras = {
  renewingmist = 119611,
  envelopingmist = 124682,
  soothingmist = 115175,
  teachingsofthemonastery = 202090,
  essencefont = 191840,
  faeline = 388193,
  improvedDetox = 388874,
  ancientteachings = 388026,
  ancientconcordance = 389391,
  invokechiji = 343820,
  sheilunsgift = 399510,
  chijibird = 325197
}

function sb.mistweavercasting()
  return Me.CurrentSpell and
      (Me.CurrentSpell.Id ~= Spell.SoothingMist.Id)
end

function sb.vivify(friend)
  if friend.HealthPct > Settings.MistweaverVivifyPct then return end

  return Spell.Vivify:CastEx(friend)
end

function sb.envelopingmist()
  local chijiAura = Me:GetAura(sb.auras.invokechiji)

  if not chijiAura or chijiAura.Stacks < 3 then return end

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if Spell.EnvelopingMist:Apply(friend) then return end
  end

  for _, friend in pairs(Heal.Friends.Tanks) do
    if Spell.EnvelopingMist:Apply(friend) then return end
  end

  for _, friend in pairs(Heal.Friends.DPS) do
    if Spell.EnvelopingMist:Apply(friend) then return end
  end
end

function sb.soothingmist(friend)
  if friend.HealthPct > Settings.MistweaverSoothingMistPct then return end

  return Spell.SoothingMist:Apply(friend)
end

function sb.lifecocoon(friend)
  if not friend.InCombat or friend.HealthPct > Settings.MistweaverLifeCocoonPct then return end

  return Spell.LifeCocoon:CastEx(friend)
end

function sb.zenpulse(friend)
  if friend.HealthPct > Settings.MistweaverZenPulsePct then return end

  return Spell.ZenPulse:CastEx(friend)
end

function sb.detox()
  if Spell.Detox:CooldownRemaining() > 0 then return end

  return Spell.Detox:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Poison, WoWDispelType.Disease)
end

function sb.renewingmist()
  if Spell.RenewingMist:CooldownRemaining() > 0 then return end

  Spell.ThunderFocusTea:CastEx(Me)

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    if Spell.RenewingMist:Apply(friend) then return end
  end

  for _, friend in pairs(Heal.Friends.All) do
    if Spell.RenewingMist:Apply(friend) then return end
  end
end

function sb.spinningcranekick()
  return Combat:GetEnemiesWithinDistance(15) > 3 and Spell.SpinningCraneKick:CastEx(Me)
end

function sb.risingsunkick(target)
  if Spell.RisingSunKick:CooldownRemaining() > 0 then return end

  if target then
    if Spell.RisingSunKick:CastEx(target) then return end
  end

  for _, enemy in pairs(Combat.Targets) do
    if Spell.RisingSunKick:InRange(enemy) and Me:IsFacing(enemy) then
      Spell.ThunderFocusTea:CastEx(Me)
      if Spell.RisingSunKick:CastEx(enemy) then return end
    end
  end
end

function sb.blackoutkick(target)
  return Spell.RisingSunKick:CooldownRemaining() > 2000 and Spell.BlackoutKick:CastEx(target)
end

function sb.tigerpalm(target)
  return Spell.TigerPalm:CastEx(target)
end

function sb.spearhandstrike()
  return Spell.SpearHandStrike:Interrupt()
end

function sb.manateacancel()
  local currSpell = Me.CurrentSpell

  if currSpell and currSpell.Id == Spell.ManaTea.Id then
    if Me.PowerPct == 100 then
      Me:StopCasting()
      return
    end
  end
end

function sb.soothingfriend(friend)
  if not friend then return end

  if friend.HealthPct < Settings.MistweaverSoothingMistPct then
    if Spell.SoothingMist:Apply(friend) then return end
  end
  if Spell.EnvelopingMist:Apply(friend) then return end
end

function sb.expelharm()
  return Me.HealthPct < Settings.MistweaverExpelharmPct and Spell.ExpelHarm:CastEx(Me)
end

function sb.touchofdeath(target)
  return target.HealthMax > Me.HealthMax and target.Health < Me.Health and Spell.TouchOfDeath:CastEx(target)
end

return spellbook
