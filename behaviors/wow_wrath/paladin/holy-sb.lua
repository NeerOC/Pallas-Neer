local spellbook = {}

local sb = spellbook

sb.auras = {
  beaconoflight = 53563,
  sacredshield = 53601,
  flashhot = 66922,
  lightsgrace = 31834
}

function TankOrFriend(friend)
  local tank = sb.gettank()

  if not tank then return friend end

  local friendLost = friend:GetHealthLost()
  local tankLost = tank:GetHealthLost()

  return friendLost > tankLost and friend or tank
end

function sb.gettank()
  return Me.FocusTarget and not Me.FocusTarget.DeadOrGhost and Me.FocusTarget
end

function sb.gettanklost()
  local tank = sb.gettank()
  return tank and tank:GetHealthLost() or 0
end

function sb.flashoflight(friend)
  if TankOrFriend(friend):GetHealthLost() < Settings.FlashOfLightAmt then return false end

  return Spell.FlashOfLight:CastEx(friend)
end

function sb.holyshock(friend)
  if TankOrFriend(friend):GetHealthLost() < Settings.HolyShockAmt then return false end

  Spell.DivineFavor:CastEx(Me)

  return Spell.HolyShock:CastEx(friend)
end

function sb.holylight(friend)
  if TankOrFriend(friend):GetHealthLost() < Settings.HolyLightAmt then return false end

  return Spell.HolyLight:CastEx(friend)
end

function sb.layonhands(friend)
  if Spell.LayOnHands:CooldownRemaining() > 0 or friend.HealthPct > Settings.LayOnHandsPct or not friend.InCombat then return false end

  return Spell.LayOnHands:CastEx(friend)
end

function sb.handofprotection(friend)
  if friend.HealthPct > Settings.HandOfProtectionPct then return false end
  if Spell.HandOfProtection:CooldownRemaining() > 0 or not friend.InCombat then return false end
  if table.contains(Heal.Friends.Tanks, friend) then return false end

  local targettingFriend = false

  for _, enemy in pairs(Combat.Targets) do
    local eTarget = enemy.Target

    if eTarget and eTarget == friend and not enemy.IsCastingOrChanneling then
      targettingFriend = true
    end
  end

  return targettingFriend and Spell.HandOfProtection:CastEx(friend)
end

function sb.handofsalvation()
  if Spell.HandOfSalvation:CooldownRemaining() > 0 or not Me.InCombat or #Heal.Friends.All < 2 or not Settings.HolySalvation then return false end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Aggro then
      return Spell.HandOfSalvation:CastEx(Me)
    end
  end
end

function sb.handoffreedom()
  if not Settings.HolyFreedom then return end

  for _, friend in pairs(Heal.Friends.All) do
    if friend:IsRooted() then
      return Spell.HandOfFreedom:CastEx(friend)
    end
  end
end

function sb.handofsacrifice()
  if Me.HealthPct < 80 then return false end
  local tank = sb.gettank()
  if not tank then return false end

  return tank.InCombat and tank.HealthPct < Settings.HandOfSacrificePct and Spell.HandOfSacrifice:CastEx(tank)
end

function sb.redemption()
  local target = Me.Target
  if not target then return false end

  if not target.IsEnemy and target.DeadOrGhost then
    return Spell.Redemption:CastEx(target)
  end
end

function sb.beaconoflight()
  local tank = sb:gettank()
  if not tank then return false end

  local beacon = tank:GetAuraByMe(sb.auras.beaconoflight)

  return (not beacon or (beacon.Remaining < 3000 or table.length(Combat.Targets) == 0 and beacon.Remaining < 50000)) and
      Spell.BeaconOfLight:CastEx(tank)
end

function sb.sacredshield()
  local tank = sb:gettank()
  if not tank then return false end

  local sacred = tank:GetAuraByMe(sb.auras.sacredshield)

  return (not sacred or (sacred.Remaining < 3000 or table.length(Combat.Targets) == 0 and sacred.Remaining < 30000)) and
      Spell.SacredShield:CastEx(tank)
end

function sb.flashhot()
  local tank = sb:gettank()
  if not tank then return false end

  return tank.InCombat and tank:HasAura(sb.auras.sacredshield) and not tank:HasAura(sb.auras.flashhot) and
      Spell.FlashOfLight:CastEx(tank)
end

function sb.holygrace(friend)
  local tank = sb:gettank()
  if not tank or not Settings.AlwaysGrace then return false end

  local graceBuff = Me:GetAura(sb.auras.lightsgrace)
  local realTarget = friend or tank

  return Me.InCombat and (not graceBuff or graceBuff.Remaining < 2200) and Spell.HolyLight:CastEx(realTarget)
end

local isPreHeal = false
local preHealTime = 0
function sb.prehealcast()
  for _, enemy in pairs(Combat.Targets) do
    if enemy.IsCastingOrChanneling then
      local target = enemy.Target
      local currentSpell = enemy.CurrentSpell
      if currentSpell and target and not target.IsEnemy then
        local castRemaining = currentSpell:CastRemaining()
        if castRemaining > 0 and castRemaining < 300 then
          if not isPreHeal then
            Alert("Preheal: " .. castRemaining .. " Spell: " .. currentSpell.Name, 1.8)
            isPreHeal = true
            preHealTime = wector.Game.Time + 1800
          end

          if Spell.HolyLight:CastEx(target) then return end
        end
      end
    end
  end

  if wector.Game.Time > preHealTime then
    isPreHeal = false
  end
end

function sb.cleanse()
  return Spell.Cleanse:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Poison, WoWDispelType.Disease)
end

function sb.handleoverheal()
  local spellTarget = Me:GetSpellTarget()
  if not spellTarget then return false end
  local tank = sb.gettank()
  local graceBuff = Me:GetAura(sb.auras.lightsgrace)
  local extraChecks = (not Settings.AlwaysGrace or Settings.AlwaysGrace and graceBuff and graceBuff.Remaining > 2200) and
      tank and tank:HasAura(sb.auras.flashhot) and not isPreHeal
  local castingHeal = Me.CurrentSpell == Spell.FlashOfLight or Me.CurrentSpell == Spell.HolyLight

  if (spellTarget:GetHealthLost() < Settings.FlashOfLightAmt and tank and tank:GetHealthLost() < Settings.FlashOfLightAmt and extraChecks) and castingHeal then
    Me:StopCasting()
    return
  end
end

local interrupts = {
  71022, -- Disruptive ICC
  42708, -- Staggering Roar UK
  59708, -- Staggering Roar UK
}
function sb.handleinterrupt()
  for _, enemy in pairs(Combat.Targets) do
    if enemy.CurrentCast then
      local cast = enemy.CurrentSpell
      if table.contains(interrupts, cast.Id) and cast:CastRemaining() < 1500 then
        WoWSpell.dontCast = true

        if Me.IsCastingOrChanneling then
          local mySpell = Me.CurrentSpell
          if mySpell and mySpell:CastRemaining() > cast:CastRemaining() then
            Me:StopCasting()
          end
        end

        return
      end
    end
  end

  WoWSpell.dontCast = false
end

function sb.consecration()
  return Combat.EnemiesInMeleeRange > 0 and not Me:IsMoving() and Spell.Consecration:CastEx(Me)
end

function sb.exorcism(target)
  return Spell.Exorcism:CastEx(target)
end

function sb.shieldofrighteousness(target)
  return Spell.ShieldOfRighteousness:CastEx(target)
end

function sb.holywrath()
  if Spell.HolyWrath:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    local isValid = Me:GetDistance(enemy) < 10 and
        (enemy.CreatureType == CreatureType.Undead or enemy.CreatureType == CreatureType.Demon)

    if isValid and Spell.HolyWrath:CastEx(Me) then return end
  end
end

local lastAttack = 0
function sb.handleimages()
  local image1 = Combat.MirrorImages[1]
  if image1 then
    DrawLine(World2Screen(Me.Position), World2Screen(image1.Position), 0xFFFFFF00, 5)
  end

  for _, enemy in pairs(Combat.MirrorImages) do
    if Me:InMeleeRange(enemy) and Me:IsFacing(enemy) then
      if not Me:IsAttacking(enemy) and wector.Game.Time > lastAttack then
        Me:SetTarget(enemy)
        Me:ToggleAttack()
        lastAttack = wector.Game.Time + 150
        return
      end
      if Spell.ShieldOfRighteousness:CastEx(enemy) then return end
    end
    if not enemy.Aggro and Spell.HandOfReckoning:CastEx(enemy) then return end
  end
end

return spellbook
