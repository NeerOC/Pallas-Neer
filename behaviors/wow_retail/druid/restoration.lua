---@diagnostic disable: undefined-field, duplicate-set-field
local gui = require("behaviors.wow_retail.druid.restoration-gui")
local colors = require("data.colors")

RestoListener = wector.FrameScript:CreateListener()
RestoListener:RegisterEvent('CHAT_MSG_ADDON')

local damooge = false
function RestoListener:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
  if prefix ~= "pallas" then return end

  if text == "damooge" then
    damooge = not damooge
  end
end

local auras = {
  rejuvenation = 774,
  wildgrowth = 48438,
  clearcasting = 16870,
  efflorescence = 207386,
  rake = 155722,
  thrash = 405233,
  motw = 1126,
  wardofsalvation = 444622
}

local lastGrove = 0
local function GroveGuardian(friend, level)
  if wector.Game.Time < lastGrove then return end
  local groveCharge = Spell.GroveGuardians.Charges

  if (groveCharge < 3 and level == 1) or (groveCharge < 2 and level == 2) then
    return false
  end

  if Spell.GroveGuardians:CastEx(friend) then
    lastGrove = wector.Game.Time + 3500
    return
  end
end

local function DruidRestorationDamage()
  if not Settings.DruidRestoDamage then return end
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  local mfTargets = 0
  local mfTarget = nil


  if Me:GetPowerPctByType(PowerType.Mana) > 70 then
    if Me.ShapeshiftForm ~= ShapeshiftForm.Cat or Me:GetPowerByType(PowerType.Energy) < 30 then
      if Spell.AdaptiveSwarm:CastEx(target) then return end
      if Spell.Sunfire:Apply(target) then return end

      for _, enemy in pairs(Combat.Targets) do
        if enemy:HasDebuffByMe(Spell.Moonfire.Name) then
          mfTargets = mfTargets + 1
        else
          if enemy:TimeToDeath() ~= 9999 and enemy:TimeToDeath() > 12 then
            mfTarget = enemy
          end
        end
      end

      if mfTarget and mfTargets < 3 and Spell.Moonfire:CastEx(mfTarget) then return end
    end
  end

  if Spell.Rake:InRange(target) then
    if Me:GetPowerByType(PowerType.Energy) >= 40 then
      local rakeTargets = 0
      local thrashValid = false
      local rakeEnemy = nil
      local enemies = Combat:GetEnemiesWithinDistance(10)

      if Me.ShapeshiftForm ~= ShapeshiftForm.Cat then
        if Spell.CatForm:CastEx(Me) then return end
      end

      if Me:GetPowerByType(PowerType.ComboPoints) >= 5 and Spell.Rip:Apply(target) then return end
      if Me:GetPowerByType(PowerType.ComboPoints) >= 5 and Spell.FerociousBite:CastEx(target) then return end

      for _, enemy in pairs(Combat.Targets) do
        if enemy:HasDebuffByMe(Spell.Rake.Name) then
          rakeTargets = rakeTargets + 1
        else
          if not rakeEnemy then
            rakeEnemy = enemy
          end
        end

        if Spell.Thrash:InRange(enemy) and not enemy:HasAura(auras.thrash) and enemy:TimeToDeath() ~= 9999 and enemy:TimeToDeath() > 12 then
          thrashValid = true
        end
      end
      if enemies >= 3 and thrashValid and Spell.Thrash:CastEx(Me) then return end
      if enemies > 3 and Spell.Swipe:CastEx(Me) then return end
      if rakeTargets < 3 and rakeEnemy then
        if Spell.Rake:Apply(rakeEnemy) then return end
      end

      if enemies > 2 and Spell.Swipe:CastEx(Me) then return end
      if Spell.Shred:CastEx(target) then return end
    end
  else
    if Combat:GetTargetsAround(target, 8) > 2 and Spell.Starfire:CastEx(target) then return end
    if Spell.Wrath:CastEx(target) then return end
  end
end

local function Barkskin()
  if Spell.Barkskin:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    local eTarget = enemy.Target
    if eTarget == Me and enemy.IsCastingOrChanneling or enemy.Aggro and Me:GetDistance(enemy) < 10 then
      if Spell.Barkskin:CastEx(Me) then return end
    end
  end
end

local lastMotw = 0
local function Motw()
  if wector.Game.Time < lastMotw then return end

  for _, friend in pairs(Heal.Friends.All) do
    if not friend:HasAura(auras.motw) then
      if Spell.MarkOfTheWild:CastEx(friend) then
        lastMotw = wector.Game.Time + 5000
        return
      end
    end
  end
end

local lastEfflo = 0
local function Efflorescence()
  if lastEfflo > wector.Game.Time then return end
  local tank = Me.FocusTarget or Heal.Friends.Tanks[1]

  if not tank then return end

  if tank.InCombat and not tank:IsMoving() and not tank:HasAura(auras.efflorescence) and Spell.Efflorescence:CastEx(tank) then
    lastEfflo = wector.Game.Time + 5000
    return
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
local function IncapRoar()
  if Spell.IncapacitatingRoar:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    local spell = enemy.CurrentSpell
    if (spell and stunSpells[spell.Id] and not enemy.IsInterruptible) then
      if Me:GetDistance(enemy) < 12 then
        if Spell.IncapacitatingRoar:CastEx(Me) then return end
      end
    end
  end
end

local function Afflicted()
  for _, affli in pairs(Heal.Afflicted) do
    if Spell.NaturesCure:CastEx(affli) then return end
  end
end

local function Dispel()
  if Spell.NaturesCure:CooldownRemaining() > 0 then return end

  return Spell.NaturesCure:Dispel(true, DispelPriority.Low, WoWDispelType.Poison, WoWDispelType.Magic,
    WoWDispelType.Curse)
end

local function Soothe()
  if Spell.Soothe:CooldownRemaining() > 0 then return end

  return Spell.Soothe:Dispel(false, DispelPriority.Low, WoWDispelType.Enrage)
end

local nextLoot = 0
local function OpenGems()
  local items = wector.Game.Items

  if wector.Game.Time < nextLoot then
    return
  end

  for _, item in pairs(items) do
    local name = item.Name
    if name == "Asynchronized Prismatic Gem" then
      item:Use(Me.ToUnit)
    end
  end

  nextLoot = wector.Game.Time + 2000
end

local function DruidRestoration()
  if Me:IsSitting() or Me:IsStunned() or Me:IsCastingFixed() or Me.IsMounted then return end

  if damooge then
    DrawText(Me:GetScreenPosition(), colors.white, "DAMOOGE")
  end

  local tank = Me.FocusTarget or Heal.Friends.Tanks[1]
  local lowest = Heal:GetLowestMember()
  local clearCasting = Me:HasAura(auras.clearcasting)

  if not Me.InCombat then
    Motw()
  end

  if lowest and lowest.HealthPct < 50 then
    if damooge then
      damooge = false
    end

    Spell.NaturesSwiftness:CastEx(Me)
  end

  if Barkskin() then return end
  if Me.InCombat and Me.HealthPct < 65 and Spell.Renewal:CastEx(Me) then return end

  if Me.ShapeshiftForm == ShapeshiftForm.Travel then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if Afflicted() then return end
  if IncapRoar() then return end
  if Dispel() then return end
  if Soothe() then return end

  if damooge and Settings.DruidRestoDamage then
    DruidRestorationDamage()
  end

  if tank and tank.InCombat then
    local target = Me.Target
    if target and target == tank then
      if Spell.WardOfSalvation:CastEx(tank) then return end
      if Spell.Ironbark:CastEx(tank) then return end
      if Spell.CenarionWard:CastEx(tank) then return end
    end
  end

  local growthCount = 0
  local groveCount = 0
  local flourishCount = 0
  local groveCritical = 0
  local vokeCount = 0

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if friend.HealthPct < 70 then
      vokeCount = vokeCount + 1
    end

    if friend.HealthPct < 60 then
      groveCritical = groveCritical + 1
    end

    if friend.HealthPct < 85 then
      growthCount = growthCount + 1
    end

    if friend.HealthPct < 80 then
      groveCount = groveCount + 1
    end

    if friend.HealthPct < 80 and friend:HasAura(auras.rejuvenation) and friend:HasAura(auras.wildgrowth) then
      flourishCount = flourishCount + 1
    end
  end

  if vokeCount >= 3 and Spell.ConvokeTheSpirits:CastEx(lowest) then return end
  if groveCritical > 2 and GroveGuardian(lowest, 3) then return end
  if flourishCount >= 2 and Spell.Flourish:CastEx(Me) then return end
  if groveCount >= 2 and GroveGuardian(lowest, 2) then return end
  if growthCount >= 3 then
    Spell.Innervate:CastEx(Me)
    if Spell.WildGrowth:CastEx(Me) then return end
  end

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    local fhpct = friend.HealthPct

    if friend:HasAura(auras.wardofsalvation) then
      fhpct = fhpct - 99
      Spell.IncarnationTreeOfLife:CastEx(Me)
      Spell.GroveGuardians:CastEx(friend)
      Spell.NaturesSwiftness:CastEx(Me)
    end

    if Spell.AdaptiveSwarm:Apply(friend) then return end
    if fhpct < 90 and Spell.Rejuvenation:Apply(friend) then return end
    if fhpct < 75 and GroveGuardian(friend, 1) then return end
    if fhpct < 70 and Spell.Swiftmend:CastEx(friend, SpellCastExFlags.NoUsable) then return end
    if fhpct < 90 and clearCasting and Spell.Regrowth:CastEx(friend) then return end
    if fhpct < 70 and Spell.Regrowth:CastEx(friend) then return end
  end

  if Spell.Lifebloom:Apply(Me) then return end

  if tank then
    local thpct = tank.HealthPct
    if Spell.Lifebloom:Apply(tank) then return end
    if thpct < 95 and tank.InCombat and Spell.CenarionWard:CastEx(tank) then return end
  end

  if Efflorescence() then return end

  if DruidRestorationDamage() then return end
end

return {
  Options = gui,
  Behaviors = {
    [BehaviorType.Combat] = DruidRestoration,
    [BehaviorType.Heal] = DruidRestoration,
  }
}
