---@diagnostic disable: duplicate-set-field
local spellbook = {}

local sb = spellbook

sb.auras = {
  consecration = 188370,
  shininglight = 327510,
  avengingwrath = 389539,
  ardentdefender = 31850,
  guardianofancientkings = 86659,
  judgment = 197277,
  bulkwarkfury = 386652,
  shieldofrighteous = 132403
}

ProtListener = wector.FrameScript:CreateListener()
ProtListener:RegisterEvent('UNIT_COMBAT')
ProtListener:RegisterEvent('PLAYER_REGEN_ENABLED')

sb.percentfive = 0

local damageEvents = {}
function ProtListener:UNIT_COMBAT(target, event, text, amount, school)
  if target == Me and event == "WOUND" then
    local damage = { time = wector.Game.Time, amt = amount }
    table.insert(damageEvents, damage)
  end
end

---@diagnostic disable-next-line: inject-field
function ProtListener:PLAYER_REGEN_ENABLED()
  damageEvents = {}
end

function sb.getdamagetakenlastseconds(seconds)
  local currentTime = wector.Game.Time
  local totalDamage = 0

  for i = #damageEvents, 1, -1 do
    local damage = damageEvents[i]

    if currentTime - damage.time <= seconds * 1000 then
      totalDamage = totalDamage + damage.amt
    else
      -- Assuming events are ordered by time, stop iterating if we go beyond the specified time frame
      break
    end
  end

  return totalDamage
end

function sb.devotionaura()
  return Spell.DevotionAura:Apply(Me)
end

function sb.consecration(filler)
  return (not Me:HasAura(sb.auras.consecration) or filler) and Combat:GetEnemiesWithinDistance(8) > 0 and
      Spell.Consecration:CastEx(Me)
end

function sb.judgment(target)
  if Spell.Judgment.Charges == 0 then return end
  if not target:HasAura(sb.auras.judgment) and Spell.Judgment:CastEx(target) then return end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and not enemy:HasAura(sb.auras.judgment) and Spell.Judgment:CastEx(enemy) then return end
  end
end

function sb.blessedhammer()
  return (Combat:GetEnemiesWithinDistance(8) > 0 or Me:GetPowerByType(PowerType.HolyPower) < 5) and
      Spell.BlessedHammer:CastEx(Me)
end

function sb.shieldoftherigtheous()
  if not Me:HasAura(sb.auras.bulkwarkfury) and Me:GetPowerByType(PowerType.HolyPower) < 5 and Me:HasAura(sb.auras.shieldofrighteous) then return end

  local targetsHit = 0

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and Spell.ShieldOfTheRighteous:InRange(enemy) then
      targetsHit = targetsHit + 1
    end
  end

  return targetsHit > 0 and Spell.ShieldOfTheRighteous:CastEx(Me)
end

function sb.hammerofwrath()
  if Spell.HammerOfWrath:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and (enemy.HealthPct < 20 or Me:HasAura(sb.auras.avengingwrath)) then
      if Spell.HammerOfWrath:CastEx(enemy) then return end
    end
  end
end

function sb.wordofglory()
  local freeWog = Me:HasAura(sb.auras.shininglight)

  if Me.HealthPct < 50 and freeWog and Spell.WordOfGlory:CastEx(Me) then return end

  local lowestFriend = Heal.PriorityList[1] and Heal.PriorityList[1].Unit

  return lowestFriend and lowestFriend.HealthPct < 40 and freeWog and Spell.WordOfGlory:CastEx(lowestFriend)
end

function sb.layonhands()
  return Me.HealthPct < 20 and Spell.LayOnHands:CastEx(Me)
end

function sb.avengersshield(target, aoe)
  if aoe and table.length(Combat.Targets) < 2 then return end

  if Spell.AvengersShield:CooldownRemaining() > 0 then return end

  local farCastTarget
  local castTarget
  local farNoAggroTarget
  local noAggroTarget

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) then
      if enemy.IsCastingOrChanneling and enemy.IsInterruptible then
        if Me:GetDistance(enemy) > 10 then
          farCastTarget = enemy
        end

        castTarget = enemy
      end

      if not enemy.Aggro then
        if Me:GetDistance(enemy) > 10 then
          farNoAggroTarget = enemy
        end
        noAggroTarget = enemy
      end
    end
  end

  target = farCastTarget or castTarget or farNoAggroTarget or noAggroTarget or target

  return Spell.AvengersShield:CastEx(target)
end

function sb.handofreckoning()
  if Spell.HandOfReckoning:CooldownRemaining() > 0 or table.length(Heal.Friends.All) < 2 then return end

  local rangeOverride = Spell.Judgment:CooldownRemaining() > 0 and Spell.AvengersShield:CooldownRemaining() > 0

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.Aggro and enemy.Target and enemy.Target ~= Me and (not Me:IsFacing(enemy) or rangeOverride) then
      if Spell.HandOfReckoning:CastEx(enemy) then return end
    end
  end
end

function sb.rebuke()
  return Spell.Rebuke:Interrupt()
end

function sb.cleanse()
  if Spell.Cleanse:CooldownRemaining() > 0 then return end

  return Spell.CleanseToxins:Dispel(true, DispelPriority.Low, WoWDispelType.Poison, WoWDispelType.Disease)
end

function sb.blessingofsacrifice()
  if Spell.BlessingOfSacrifice:CooldownRemaining() > 0 then return end
  if Spell.HandOfReckoning:CooldownRemaining() == 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    local enemyTarget = enemy.Target
    if (not enemy.Aggro or enemy.IsCastingOrChanneling) and enemyTarget and enemyTarget.IsPlayer and enemyTarget ~= Me then
      if Spell.BlessingOfSacrifice:CastEx(enemyTarget) then return end
    end
  end
end

function sb.blessingoffreedom()
  return Me:IsRooted() and Spell.BlessingOfFreedom:CastEx(Me)
end

function sb.interecession()
  local target = Me.Target
  if target and not target.IsEnemy and target.IsPlayer and target.DeadOrGhost then
    if Me:GetPowerByType(PowerType.HolyPower) < 3 then
      if Spell.BlessedHammer:CastEx(Me) then return end
    end

    return Spell.Intercession:CastEx(target)
  end
end

local badDebuffs = {
  255421, -- Devour, rezan, atal
}
function sb.handofprotection()
  if Spell.HandOfProtection:CooldownRemaining() > 0 or table.length(Heal.Friends.All) < 3 then return end

  for _, friend in pairs(Heal.Friends.All) do
    for _, debuff in pairs(badDebuffs) do
      if friend:HasAura(debuff) and Spell.HandOfProtection:CastEx(friend) then return end
    end
  end
end

local stunSpells = {
  [429176] = true, -- Aquablast
  [200345] = true, -- Arrow Barrage
  [225562] = true, -- Blood Metamorphosis
  [225963] = true, -- Bloodthirsty Leap
  [172578] = true, -- Bounding Whirl
  [201139] = true, -- Brutal Assault
  [164965] = true, -- Choking Vines
  [413606] = true, -- Corroding Volley
  [225573] = true, -- Dark Mending
  [201400] = true, -- Dread Inferno
  [253583] = true, -- Fiery Enchant
  [411300] = true, -- Fish Bolt Volley
  [201061] = true, -- Frenzy Potion
  [164887] = true, -- Healing Waters
  [76813] = true,  -- Healing Wave
  [76820] = true,  -- Hex
  [278444] = true, -- Infest
  [200291] = true, -- Knife Dance
  [253517] = true, -- Mending Word
  [265346] = true, -- Pallid Glare
  [198904] = true, -- Poison Spear
  [427376] = true, -- Poisoned Spear
  [426905] = true, -- Psionic Pulse
  [271175] = true, -- Ravaging Leap
  [214002] = true, -- Raven's Dive
  [412233] = true, -- Rocket Bolt Volley
  [200105] = true, -- Sacrifice Soul
  [407120] = true, -- Serrated Axe
  [264390] = true, -- Spellbind
  [200658] = true, -- Star Shower
  [411958] = true, -- Stonebolt
  [412044] = true, -- Temposlice
  [255041] = true, -- Terrifying Screech
  [260666] = true, -- Transfusion
  [200630] = true, -- Unnerving Screech
  [253721] = true, -- bulwark of juju

}
local stunEnemies = {
  [131009] = true, -- Spirit of gold atal
}

function sb.stunlogic()
  for _, enemy in pairs(Combat.Targets) do
    local spell = enemy.CurrentSpell
    if not enemy:IsStunned() then
      if (spell and stunSpells[spell.Id] and not enemy.IsInterruptible or stunEnemies[enemy.EntryId]) then
        if Me:IsFacing(enemy) then
          if Spell.HammerOfJustice:CastEx(enemy) then return end
        end
        if Spell.HammerOfJustice:CooldownRemaining() > 0 then
          if not stunEnemies[enemy.EntryId] and Me:InMeleeRange(enemy) and Spell.BlindingLight:CastEx(Me) then return end
        end
      end
    end
  end
end

local tankBusters = {
  [407159] = true, -- blight reclaim galakrond
  [201139] = true, -- Brutal Assault, Blackrook
  [413013] = true, -- Chronoshear Galakrond
  [214003] = true, -- coup de grace, brh
  [429021] = true, -- Crush, Throne of the tides
  [260508] = true, -- Crush, Waycrest manor
  [427670] = true, -- crushing claw, throne
  [204611] = true, -- crushing grip, darkheart
  [409558] = true, -- crushing onslaught, galakrond
  [410254] = true, -- decap, murozonds rise
  [265881] = true, -- Decaying Touch, waycrest
  [413473] = true, -- double strike, gala, murozonds
  [164885] = true, -- dreadpetal pollen, everbloom
  [256138] = true, -- fervent strike, atal
  [265371] = true, -- focused strike, waycrest
  [264378] = true, -- fragment soul, waycrest
  [265391] = true, -- meaty rampage, waycrest
  [265347] = true, -- peck, waycrest.
  [255895] = true, -- poisoned claws, atal dazar
  [427376] = true, -- poisoned spear, throne
  [169658] = true, -- poison claws, everbloom
  [265410] = true, -- punch, waycrest manor.
  [412505] = true, -- rending cleave, murozonds
  [255814] = true, -- rending maul, atal
  [201902] = true, -- scorching shot, darkheart
  [255434] = true, -- serrated teeth, atal
  [273653] = true, -- Shadow Claw, waycrest
  [416716] = true, -- sheared lifespan, galakrond
  [426741] = true, -- Shellbreaker, throne
  [249919] = true, -- skewer, ataldazar
  [411700] = true, -- slobbering bite, murozonds
  [411644] = true, -- soggy bonk, murozond
  [412262] = true, -- staticky punch, murozond
  [225732] = true, -- strike down, blackrook
  [264556] = true, -- tearing strike, waycrest manor
  [412044] = true, -- temposlice, galakrond
  [265760] = true, -- thorned barrage, waycrest
  [264140] = true, -- thorned claw, waycrest
  [76807] = true,  -- thrash, throne tides
  [410240] = true, -- titanic blow, murozonds
  [413489] = true, -- triple strike, dawn of infinite
  [198635] = true, -- unerring shear, blackrook
  [197418] = true, -- vengeful shear, blackrook
  [252661] = true, -- venom tipped blade, atal
  [252687] = true, -- venomfang strike, atal
  [261438] = true, -- wasting strike, waycrest
}

function sb.defenselogic()
  if Spell.ArdentDefender:CooldownRemaining() > 0 and Spell.Sentinel:CooldownRemaining() > 0 and Spell.EyeOfTyr:CooldownRemaining() > 0 then return end
  local castingBaddie = false

  for _, enemy in pairs(Combat.Targets) do
    local spell = enemy.CurrentSpell

    if not spell or not tankBusters[spell.Id] or not enemy.Target or not enemy.Target == Me then
      goto continue
    end

    if not enemy.IsInterruptible then
      castingBaddie = true
      Alert("Baddie Inc: " .. spell.Name, 5)
    end

    ::continue::
  end

  local hasDefensive = Me:HasAura(sb.auras.ardentdefender) or Me:HasAura(sb.auras.avengingwrath) or
      Me:HasAura(sb.auras.guardianofancientkings)
  if not hasDefensive and castingBaddie then
    if not Me:HasAura(sb.auras.consecration) and Spell.Consecration:CastEx(Me) then return end
    if Spell.ArdentDefender:CastEx(Me) then return end
    if Spell.AvengingWrath:CastEx(Me) then return end
    if Spell.EyeOfTyr:CastEx(Me) then return end
    if Spell.GuardianOfAncientKings:CastEx(Me) then return end
  end
end

return spellbook
