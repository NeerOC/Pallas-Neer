local sb = require("behaviors.wow_retail.shaman.restoration-sb")
local gui = require("behaviors.wow_retail.shaman.restoration-gui")

local function RestorationDPS()
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target or not Me:IsFacing(target) then return false end

  local stormkeeper = Me:GetAura(sb.auras.stormkeeper)
  local forcelightning = stormkeeper and stormkeeper.Remaining < 5000

  if not forcelightning then
    if sb.HealingRain(target) then return true end
    if sb.FlameShock(target) then return true end
    if sb.LavaBurst(target) then return true end
  end
  if sb.ChainLightning(target) then return true end
  if sb.LightningBolt(target) then return true end
end

local auras = {}
local function DebugAuras(target)
  for _, aura in pairs(target.Auras) do
    if not table.contains(auras, aura.Id) then
      table.insert(auras, aura.Id)
      print("Inserted: " .. aura.Id .. ", " .. aura.Name)
    end
  end
end

local function DrawDebug()
  local add = 0
  for _, enemy in pairs(Combat.Targets) do
    local dx, dy, dz = Me.Position.x, Me.Position.y, Me.Position.z + add
    DrawText(World2Screen(Vec3(dx, dy, dz)), 0xFF80FF80, enemy.Name .. " , " .. tostring(enemy.Guid))
    add = add + 0.3
  end
end

local function RestorationAOEHeal()
  local lowest = Heal.PriorityList[1] and Heal.PriorityList[1].Unit

  if lowest and lowest.HealthPct < Settings.ShamanRestoCritical then
    return false
  end

  local asccount = 0
  local httcount = 0
  local pwcount = 0
  local chcount = 0

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    local hpct = friend.HealthPct

    if Me:GetDistance(friend) <= 20 and hpct < Settings.ShamanRestoAscendance then
      asccount = asccount + 1
    end

    if hpct < Settings.ShamanRestoHealingTideTotem then
      httcount = httcount + 1
    end

    if hpct < Settings.ShamanRestoPrimordialWave then
      pwcount = pwcount + 1
    end

    if hpct < Settings.ShamanRestoChainHeal then
      chcount = chcount + 1
    end
  end

  if chcount >= Settings.ShamanRestoChainHealCount then
    if sb.CloudburstTotem() then
      return true
    end

    if sb.ChainHeal() then return true end
  end

  if asccount >= Settings.ShamanRestoAscendanceCount then
    if sb.Ascendance() then return true end
  end

  if httcount >= Settings.ShamanRestoHealingTideTotemCount then
    if sb.HealingTideTotem() then return true end
  end

  if pwcount >= Settings.ShamanRestoPrimordialWaveCount then
    if sb.PrimordialWave() then return true end
  end

  if sb.HealingWave(Me, true) then return true end
end

local function HandleOverheal()
  local target = WoWSpell.Target
  if not target or not Me.CurrentSpell then return false end

  local castingHeal = Me.CurrentSpell == Spell.HealingSurge
  if castingHeal and target.HealthPct > Settings.ShamanRestoOverheal then
    Me:StopCasting()
  end
end

local function CancelDPS()
  local lowest = Heal.PriorityList[1] and Heal.PriorityList[1].Unit
  if not lowest then return end

  local badSpells = {
    Spell.LightningBolt,
    Spell.ChainLightning,
    Spell.HealingRain,
    Spell.LavaBurst
  }

  if lowest.HealthPct <= Settings.ShamanRestoCancelCast then
    local mySpell = Me.CurrentSpell
    if mySpell and mySpell:CastRemaining() > 800 and table.contains(badSpells, mySpell) then
      Me:StopCasting()
    end
  end
end

---@param check boolean perform only the check for casting hex and if it will be a good cast.
local function HandleIncorporeal(check)
  if not Settings.ShamanRestoIncorporeal then return false end

  if check and Me.IsCastingOrChanneling then
    local hexing = Me.CurrentSpell and Me.CurrentSpell == Spell.Hex
    if hexing then
      if WoWSpell.Target then
        if not WoWSpell.Target.IsCastingOrChanneling and WoWSpell.Target:IsStunned() then
          Me:StopCasting()
        end
      end
    end
    return false
  end

  for _, target in pairs(Combat.Incorporeals) do
    if target.IsCastingOrChanneling then
      if Spell.Hex:CastEx(target) then return true end
      if target.CurrentSpell:CastRemaining() < 500 and Spell.WindShear:CastEx(target) then return true end
    end
  end
end

local function HandleAfflicted()
  if not Settings.ShamanRestoAfflicted then return false end

  for _, affli in pairs(Heal.Afflicted) do
    if Spell.PurifySpirit:CastEx(affli) then return true end
  end
end

local function ShamanRestoration()
  if sb.SpiritwalkersGrace() then return end
  if HandleIncorporeal(true) then return end
  if HandleOverheal() then return end
  if CancelDPS() then return end

  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() or Me.IsCastingOrChanneling then return end

  -- OOC stuff (Mostly ..)
  if sb.Resurrect() then return end

  --- Defensive..s?
  if sb.AstralShift() then return end
  if WoWItem:UseHealthstone() then return end
  if sb.WindShear() then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  -- AoE Healing
  if Me.InCombat and RestorationAOEHeal() then return end

  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if sb.SpiritLinkTotem(friend) then return end
    if sb.UnleashLife(friend) then return end
    if sb.HealingSurge(friend) then return end
    if sb.Riptide(friend) then return end
    if sb.HealingStreamTotem(friend) then return end
    if sb.HealingWave(friend) then return end
  end

  if HandleAfflicted() then return end
  if HandleIncorporeal(false) then return end
  if sb.PoisonCleansingTotem() then return end

  if sb.EarthShield(Me) then return end
  local firstFriend = Heal.Friends.Tanks[1]
  if firstFriend and sb.EarthShield(firstFriend) then return end

  if sb.Thunderstorm() then return end
  if sb.PurifySpirit() then return end
  if sb.Purge() then return end

  if sb.EarthlivingWeapon() then return end
  if sb.WaterShield() then return end

  if RestorationDPS() then return end
end

local behaviors = {
  [BehaviorType.Combat] = ShamanRestoration,
  [BehaviorType.Heal] = ShamanRestoration
}

return { Options = gui, Behaviors = behaviors }
