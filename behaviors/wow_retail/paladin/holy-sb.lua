local spellbook = {}

local sb = spellbook

sb.auras = {
  devotionaura = 465,
  crusaderaura = 32223,
  improvedcleanse = 393024,
  beaconoflight = 53563,
  breakingdawn = 387879,
  glimmeroflight = 287280,
  wings = 31884,
  divinity = 414273,
  beaconoffaith = 156910,
  tyrsdeliverancefriend = 200654,
  tyrsdeliveranceme = 200652
}

local extendedTyrs = 0

ExtensionListener = wector.FrameScript:CreateListener()
ExtensionListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

---@param castguid WoWGuid
function ExtensionListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castguid, SpellID)
  if SpellID == Spell.HolyLight.Id then
    extendedTyrs = extendedTyrs + 8
  end
  if SpellID == Spell.FlashOfLight then
    extendedTyrs = extendedTyrs + 4
  end
  if SpellID == Spell.HolyShock then
    extendedTyrs = extendedTyrs + 2
  end
end

function sb.crusaderstrike(target)
  local hp = Me:GetPowerByType(PowerType.HolyPower)
  if hp >= 4 then return false end

  return Spell.CrusaderStrike:CastEx(target)
end

function sb.hammerofwrath(target)
  local hasWings = Me:HasAura(sb.auras.wings)
  if Me:GetPowerByType(PowerType.HolyPower) == 5 then return false end

  if (hasWings or target.HealthPct < 20) and Spell.HammerOfWrath:CastEx(target, SpellCastExFlags.NoUsable) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and enemy.HealthPct < 20 and Spell.HammerOfWrath:CastEx(enemy, SpellCastExFlags.NoUsable) then
      return true
    end
  end
end

local consPos
function sb.consecration()
  local moving = Me.CurrentSpeed > 0 or Me:IsMoving()
  if Spell.Consecration:CooldownRemaining() > 0 then return false end
  local hasTotem = false

  for _, totem in pairs(Me.Totems) do
    if totem.Name == "Consecration" then
      hasTotem = true
    end
  end

  if (not hasTotem or not consPos or consPos and Me.Position:Distance(consPos) > 10) and Combat:GetEnemiesWithinDistance(10) > 0 and not moving and Spell.Consecration:CastEx(Me) then
    consPos = Me.Position
  end
end

function sb.shieldoftherigtheous()
  local hp = Me:GetPowerByType(PowerType.HolyPower)
  if hp < 5 then return false end

  local hits = 0
  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy, 45) and Me:InMeleeRange(enemy) then
      hits = hits + 1
    end
  end

  return hits > 0 and Spell.ShieldOfTheRighteous:CastEx(Me)
end

function sb.judgment(target)
  return Me:GetPowerByType(PowerType.HolyPower) < 5 and Spell.Judgment:CastEx(target)
end

function sb.wordofglory(friend)
  return friend.HealthPct < Settings.PaladinHolyWordOfGlory and Spell.WordOfGlory:CastEx(friend)
end

function sb.layonhands(friend)
  return friend.HealthPct < Settings.PaladinHolyLayOnhands and Spell.LayOnHands:CastEx(friend)
end

function sb.flashOflight(friend)
  return friend.HealthPct < Settings.PaladinHolyFlashOfLight and Spell.FlashOfLight:CastEx(friend)
end

function sb.holylight(friend, divinity)
  if divinity then
    local divinityAura = Me:GetAura(sb.auras.divinity)
    if not divinityAura then return false end

    for k, v in pairs(Heal.PriorityList) do
      local friend = v.Unit

      if friend:HasAura(sb.auras.tyrsdeliverancefriend) and friend.HealthPct < 100 then
        if Spell.HolyLight:CastEx(friend) then return end
      end
    end

    return (divinityAura and friend.HealthPct < 60 or divinityAura and divinityAura.Remaining < 3000) and
        Spell.HolyLight:CastEx(friend)
  end

  return friend.HealthPct < Settings.PaladinHolyHolyLight and Spell.HolyLight:CastEx(friend)
end

function sb.tyrsdeliverance()
  if not Me:HasAura(sb.auras.tyrsdeliveranceme) then
    if extendedTyrs > 0 then extendedTyrs = 0 end
    return false
  end

  if extendedTyrs < 40 then
    for k, v in pairs(Heal.PriorityList) do
      local friend = v.Unit
      if friend.HealthPct < 99 and Spell.HolyLight:CastEx(friend) then return true end
    end
  end
end

function sb.daybreak()
  local absorbCount = 0
  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if friend.HealthPct < 90 and friend:HasAura(sb.auras.glimmeroflight) then
      absorbCount = absorbCount + 1
    end
  end

  return absorbCount > 1 and Spell.Daybreak:CastEx(Me)
end

function sb.holyshock(friend)
  return Me:GetPowerByType(PowerType.HolyPower) < 5 and friend.HealthPct < Settings.PaladinHolyHolyShock and
      Spell.holyShock:CastEx(friend)
end

function sb.blessingofsacrifice(friend)
  local targetting = 0

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Target and enemy.Target == friend then
      targetting = targetting + 1
    end
  end

  return friend.HealthPct < Settings.PaladinHolyBlessingOfSacrifice and targetting > 0 and
      Spell.BlessingOfSacrifice:CastEx(friend)
end

function sb.glimmer()
  if not Settings.PaladinHolyGlimmer then return false end
  if table.length(Heal.PriorityList) == 0 then return false end
  if Me:GetPowerByType(PowerType.HolyPower) == 5 then return false end

  for k, v in pairs(Heal.PriorityList) do
    local unit = v.Unit

    if not unit:HasAura(sb.auras.glimmeroflight) then
      if Spell.HolyShock:CastEx(unit) then return true end
    end
  end
end

function sb.lightofdawn()
  local dawnRange = 15
  local dawnCount = 0

  if Me:HasAura(sb.auras.breakingdawn) then
    dawnRange = 40
  end

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if Me:IsFacing(friend) and friend.HealthPct < Settings.PaladinHolyHolyDawnPct and Me:GetDistance(friend) < dawnRange then
      dawnCount = dawnCount + 1
    end
  end

  return dawnCount > Settings.PaladinHolyHolyDawnCount and Spell.LightOfDawn:CastEx(Me)
end

function sb.holyprism(friend)
  return friend.HealthPct < Settings.PaladinHolyHolyPrismPct and Spell.HolyPrism:CastEx(friend)
end

function sb.handofdivinity(friend)
  return Me.InCombat and
      (Me:HasAura(sb.auras.tyrsdeliveranceme) or friend.HealthPct < Settings.PaladinHolyHandOfDivinity) and
      Spell.HandOfDivinity:CastEx(Me)
end

function sb.divineprotection()
  if Combat.Enemies == 0 then return false end
  if Me.HealthPct > Settings.PaladinHolyDivineProtection then return false end

  return Spell.DivineProtection:CastEx(Me)
end

function sb.divineshield()
  if Me.HealthPct > Settings.PaladinHolyDivineShield then return false end
  if Combat.Enemies == 0 then return false end

  return Spell.DivineShield:CastEx(Me)
end

function sb.intercession()
  if Spell.Intercession:CooldownRemaining() > 0 then return false end
  if not Me.Target or not Me.Target.IsPlayer then return false end

  local friend = Me.Target
  if friend and friend.DeadOrGhost then
    if Spell.Intercession:CastEx(friend) then return end
  end
end

function sb.beaconoflight()
  if #Heal.Friends.Tanks == 0 then return false end

  local anyBeacon = false
  local beaconTarget

  for _, friend in pairs(Heal.Friends.Tanks) do
    if friend:HasAura(sb.auras.beaconoflight) then
      anyBeacon = true
    else
      beaconTarget = friend
    end
  end

  return not anyBeacon and Spell.BeaconOfLight:CastEx(beaconTarget)
end

function sb.beaconoffaith()
  return not Me:HasAura(sb.auras.beaconoffaith) and Spell.BeaconOfFaith:CastEx(Me)
end

function sb.blessingoffreedom()
  if Spell.BlessingOfFreedom:CooldownRemaining() > 0 then return false end


  for _, friend in pairs(Heal.Friends.All) do
    if friend:IsRooted() and Spell.BlessingOfFreedom:CastEx(friend) then return end
  end
end

function sb.blessingofprotection()
  if Spell.BlessingOfProtection:CooldownRemaining() > 0 then return false end

  for _, friend in pairs(Heal.Friends.DPS) do
    if friend.HealthPct < Settings.PaladinHolyHOPPct then
      return Spell.BlessingOfProtection:CastEx(friend)
    end
  end
end

function sb.redemption()
  if not Settings.PaladinHolyResurrect or Me.InCombat then return false end
  if not Me.Target or not Me.Target.IsPlayer then return false end

  local ressTarget = Me.Target
  if ressTarget and ressTarget.DeadOrGhost then
    if Spell.Redemption:CastEx(ressTarget) then return true end
  end
end

function sb.devotionaura()
  if not Me.IsMounted and not Me:HasAura(sb.auras.devotionaura) then
    if Spell.DevotionAura:CastEx(Me) then return end
  end
end

function sb.crusaderaura()
  if Me.IsMounted and not Me:HasAura(sb.auras.crusaderaura) then
    if Spell.CrusaderAura:CastEx(Me) then return end
  end
end

function sb.blindinglight()
  if Spell.BlindingLight:CooldownRemaining() > 0 then return false end

  local casters = 0
  for _, enemy in pairs(Combat.Targets) do
    if enemy.CurrentSpell and enemy.IsInterruptible and Me:GetDistance(enemy) < 10 then
      casters = casters + 1
    end
  end

  return casters > 1 and Spell.BlindingLight:CastEx(Me)
end

function sb.rebuke()
  return Spell.Rebuke:Interrupt()
end

function sb.cleanse()
  if Spell.Cleanse:CooldownRemaining() > 0 then return false end

  local improved = Me:HasAura(sb.auras.improvedcleanse)

  if improved then
    Spell.Cleanse:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Poison, WoWDispelType.Disease)
  else
    Spell.Cleanse:Dispel(true, DispelPriority.Low, WoWDispelType.Magic)
  end
end

function sb.handleoverheal()
  local lowest = Heal.PriorityList[1] and Heal.PriorityList[1].Unit
  if not lowest then return false end

  local castingHeal = Me.CurrentSpell == Spell.FlashOfLight or Me.CurrentSpell == Spell.HolyLight

  if lowest.HealthPct > Settings.PaladinHolyOverheal and castingHeal then
    Me:StopCasting()
    return
  end
end

return spellbook
