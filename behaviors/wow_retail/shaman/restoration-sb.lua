local spellbook = {}

local sb = spellbook

sb.auras = {
  earthliving = 382022,
  watershield = 52127,
  earthshield = 383648,
  elementalorbit = 383010,
  imppurify = 383016,
  primordialwave = 375986,
  riptide = 61295,
  spiritwalkersgrace = 79206,
  flameshock = 188389,
  tidalwaves = 53390,
  tidebringer = 236502,
  stormkeeper = 383009,
  cloudburst = 157504,
  masterofelements = 260734,
  tidaltotem = 404523
}

function sb.EarthlivingWeapon()
  local el = Me:GetAura(sb.auras.earthliving)

  return (not el or el.Remaining < 30000) and Spell.EarthlivingWeapon:CastEx(Me)
end

function sb.WaterShield()
  local ws = Me:GetAura(sb.auras.watershield)

  return (not ws or ws.Remaining < 30000) and Spell.WaterShield:CastEx(Me)
end

function sb.EarthShield(target)
  local orbit = Me:GetAura(sb.auras.elementalorbit)
  if not orbit and target == Me then return false end

  return Spell.EarthShield:Apply(target)
end

function sb.WindShear()
  if Spell.WindShear:CooldownRemaining() > 0 then return false end

  return Spell.WindShear:Interrupt()
end

function sb.PurifySpirit()
  if Spell.PurifySpirit:CooldownRemaining() > 0 then return false end

  local improved = Me:GetAura(sb.auras.imppurify)

  if improved then
    Spell.PurifySpirit:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Curse)
  else
    Spell.PurifySpirit:Dispel(true, DispelPriority.Low, WoWDispelType.Magic)
  end
end

function sb.Riptide(target)
  if target.HealthPct < Settings.ShamanRestoRiptide then
    return Spell.Riptide:Apply(target)
  end

  for _, tank in pairs(Heal.Friends.Tanks) do
    if Spell.Riptide:Apply(tank) then return true end
  end
end

function sb.HealingSurge(target)
  local spell = Spell.HealingSurge

  if Me:HasAura(sb.auras.tidaltotem) then
    spell = Spell.HealingWave
  end

  if target.HealthPct < Settings.ShamanRestoHealingSurge then
    return spell:CastEx(target)
  end
end

function sb.HealingWave(target, aoe)
  if target.HealthPct < Settings.ShamanRestoHealingWave then
    return Spell.HealingWave:CastEx(target)
  end

  if aoe and Me:HasAura(sb.auras.primordialwave) then
    local htarget = Heal.PriorityList[1].Unit

    return htarget and Spell.HealingWave:CastEx(htarget)
  end
end

function sb.UnleashLife(target)
  if target.HealthPct < Settings.ShamanRestoUnleashLife then
    return Spell.UnleashLife:CastEx(target)
  end
end

function sb.PrimordialWave()
  if Spell.PrimordialWave:CooldownRemaining() > 0 then return false end

  local members, count = Heal:GetMembersBelow(Settings.ShamanRestoPrimordialWave)
  if count >= Settings.ShamanRestoPrimordialWaveCount then
    local tidecount = 0
    local pwtarget
    for _, member in pairs(members) do
      if member:HasAura(sb.auras.riptide) then
        tidecount = tidecount + 1
      else
        pwtarget = member
      end
    end

    if tidecount >= Settings.ShamanRestoPrimordialWaveCount then
      return Spell.PrimordialWave:CastEx(pwtarget or members[1])
    end
  end
end

function sb.HealingStreamTotem(target)
  if Spell.HealingStreamTotem:CooldownRemaining() > 0 then return false end

  for _, totem in pairs(Me.Totems) do
    if totem.Name == "Healing Stream Totem" then
      return
    end
  end

  if target.HealthPct < Settings.ShamanRestoHealingStreamTotem then
    return Spell.HealingStreamTotem:CastEx(Me)
  end
end

function sb.AstralShift()
  if Spell.AstralShift:CooldownRemaining() > 0 then return false end

  local astralMulti = Settings.ShamanRestoAstralShift * 1.5

  if Me.InCombat and Me.HealthPct < Settings.ShamanRestoAstralShift then
    return Spell.AstralShift:CastEx(Me)
  end

  -- TODO, Add check for dangerous spells, not all spells.
  for _, enemy in pairs(Combat.Targets) do
    if enemy.IsCastingOrChanneling and (not enemy.IsInterruptible or enemy.CurrentSpell and enemy.CurrentSpell:CastRemaining() < 1000) then
      local target = enemy.Target
      if target and target == Me then
        return Me.HealthPct < astralMulti and Spell.AstralShift:CastEx(Me)
      end
    end
  end
end

function sb.Resurrect()
  if Me.InCombat or not Settings.ShamanRestoResurrect then return false end

  local target = Me.Target
  if target then
    if target.IsPlayer and not target.IsEnemy and target.Dead then
      return Spell.AncestralVision:CastEx(Me)
    end
  end
end

function sb.SpiritwalkersGrace()
  if Spell.SpiritwalkersGrace:CooldownRemaining() == 0 then return false end

  if Me:HasAura(sb.auras.spiritwalkersgrace) then
    WoWSpell.ignoreCastTime = true
  else
    WoWSpell.ignoreCastTime = false
  end
end

function sb.Ascendance()
  return Spell.Ascendance:CastEx(Me)
end

function sb.HealingTideTotem()
  return Spell.HealingTideTotem:CastEx(Me)
end

local function CalculateNearbyFriendlies(loc, range)
  local count = 0

  for _, friend in pairs(Heal.Friends.All) do
    if loc:DistanceSq(friend.Position) < range then
      count = count + 1
    end
  end

  return count
end

local function CalculateTotemPosition()
  local range = 40.0
  local nodeSize = 5.0
  local origin = Me.Position
  origin.z = origin.z + Me.DisplayHeight
  local bestPosition = Vec3(0.0, 0.0, 0.0)
  local bestCount = 0

  for x = origin.x - range, origin.x + range, nodeSize do
    for y = origin.y - range, origin.y + range, nodeSize do
      local from = Vec3(x, y, origin.z)
      local to = Vec3(x, y, 0.0)
      local hitFlags = TraceLineHitFlags.WmoCollision | TraceLineHitFlags.Terrain
      local intersected, result = wector.World:TraceLineWithResult(from, to, hitFlags)
      if intersected then
        -- XXX: zdelta is bogus sometimes which screws everything up
        local zDelta = 5.0 - math.abs(result.Hit.z - origin.z)
        origin.z = origin.z + zDelta

        result.Hit.z = result.Hit.z + 0.1
        if not wector.World:TraceLine(origin, result.Hit, TraceLineHitFlags.WmoCollision) then
          -- calculate nearby friendly units
          local num = CalculateNearbyFriendlies(result.Hit, 11) -- Assuming CalculateNearbyFriendlies uses the origin and range of 11
          if num > bestCount then
            bestPosition = result.Hit
            bestCount = num
          end
        end
      end
    end
  end

  return bestPosition
end

function sb.ChainHeal()
  if not Me:HasAura(sb.auras.tidalwaves) then return false end
  local range = Me:HasAura(sb.auras.tidebringer) and 60 or 12

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    if Heal:GetMembersAround(friend, range, Settings.ShamanRestoChainHeal) >= Settings.ShamanRestoChainHealCount then
      return Spell.ChainHeal:CastEx(friend)
    end
  end
end

function sb.CloudburstTotem()
  if not Me:HasAura(sb.auras.cloudburst) then
    return Spell.CloudburstTotem:CastEx(Me)
  end
end

function sb.FlameShock(target)
  if Spell.FlameShock:CooldownRemaining() > 0 then return false end

  if Spell.FlameShock:Apply(target) then return true end

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) then
      if Spell.FlameShock:Apply(enemy) then return true end
    end
  end
end

function sb.LavaBurst(target)
  if Me:HasAura(sb.auras.masterofelements) then return false end

  for _, enemy in pairs(Combat.Targets) do
    local fs = target:GetAuraByMe(sb.auras.flameshock)
    if Me:IsFacing(enemy) and fs and fs.Remaining > 3000 then
      return Spell.LavaBurst:CastEx(enemy)
    end
  end

  return Spell.LavaBurst:CastEx(target)
end

function sb.ChainLightning(target)
  if Combat:GetTargetsAround(target, 10) < 2 then return false end

  if Settings.ShamanRestoStormkeeper then
    Spell.Stormkeeper:CastEx(Me)
  end

  return Spell.ChainLightning:CastEx(target)
end

function sb.LightningBolt(target)
  return Combat:GetTargetsAround(target, 15) < 2 and Spell.LightningBolt:CastEx(target)
end

function sb.Purge()
  if not Settings.ShamanRestoPurge then return false end

  if Spell.Purge:Dispel(false, DispelPriority.Low, WoWDispelType.Magic) then return true end
end

function sb.Thunderstorm()
  if Spell.Thunderstorm:CooldownRemaining() > 0 then return false end

  local casters = 0
  for _, target in pairs(Combat.Targets) do
    if Me:GetDistance(target) < 10 and target.IsCastingOrChanneling and target.IsInterruptible then
      casters = casters + 1
    end
  end

  return casters > 1 and Spell.Thunderstorm:CastEx(Me)
end

function sb.HealingRain(target)
  if not Me:HasAura(sb.auras.masterofelements) or Spell.HealingRain:CooldownRemaining() > 0 then return false end

  local tank = Heal.Friends.Tanks[1]
  local goodcast = tank and not tank:IsMoving() and not target:IsMoving()

  if not goodcast then return false end

  Spell.NaturesSwiftness:CastEx(Me)

  return Spell.HealingRain:CastEx(tank)
end

local poisonCasts = {
  [210150] = true, -- Naraxas, Toxic Retch
}
function sb.PoisonCleansingTotem()
  if Spell.PoisonCleansingTotem:CooldownRemaining() > 0 then return false end

  -- ToDo Add Logic for pre casting poison totem on specific casts.
  for _, enemy in pairs(Combat.Targets) do
    local currentSpell = enemy.CurrentSpell
    if currentSpell and poisonCasts[currentSpell.Id] and Spell.PoisonCleansingTotem:CastEx(Me) then
      return true
    end
  end

  return false
end

return spellbook
