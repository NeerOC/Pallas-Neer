---@diagnostic disable: undefined-field, duplicate-set-field
local gui = require("behaviors.wow_retail.priest.discipline-gui")
local colors = require("data.colors")

local auras = {
  atonement = 194384,
  rapture = 47536,
  powerwordshield = 17,
  instantflash = 114255,
  covenant = 322105,
  rhapsody = 390636,
  shadowcov = 322105,
  purge = 204213
}

DiscListener = wector.FrameScript:CreateListener()
DiscListener:RegisterEvent('CHAT_MSG_ADDON')

local raptureToggle = false
function DiscListener:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
  if prefix ~= "pallas" then return end

  if text == "rapture" then
    raptureToggle = not raptureToggle
  end
end

--- Class Spells/Buffs
local nextBuff = 0
local function PowerWordFortitude()
  if Me.InCombat or wector.Game.Time < nextBuff then return end

  for _, friend in pairs(Heal.Friends.All) do
    if Spell.PowerWordFortitude:Apply(friend) then
      nextBuff = wector.Game.Time + 5000
      return true
    end
  end
end

local function Fade()
  if Spell.Fade:CooldownRemaining() > 0 then return end

  for _, enemy in pairs(Combat.Targets) do
    if enemy.Aggro then
      if Spell.Fade:CastEx(Me) then return end
    end
  end
end

local function HealTrinket(friend)
  local trink1Pct = Settings.PriestDiscTrinket1Pct
  local trink2Pct = Settings.PriestDiscTrinket2Pct
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

local function DesperatePrayer()
  if Me.HealthPct > 70 then return end

  return Spell.DesperatePrayer:CastEx(Me)
end

local function PurgeTheWicked(target)
  if target.Health < Me.HealthMax then return end

  return Spell.PurgeTheWicked:Apply(target)
end

local function Dispel()
  return Spell.Purify:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Disease)
end

local function afflicted()
  for _, affli in pairs(Heal.Afflicted) do
    DrawLine(Me:GetScreenPosition(), affli:GetScreenPosition(), colors.white, 2)
    if Spell.Purify:CastEx(affli) then return end
    --if Spell.Purify:CooldownRemaining() > Spell.Heal.CastTime * 2 and Spell.Heal:CastEx(affli) then return end
  end
end

local function PriestDiscipline()
  if afflicted() then return end

  if raptureToggle then
    local textX, textY, textZ = Me.Position.x, Me.Position.y, Me.Position.z + Me.DisplayHeight
    local screenPos = World2Screen(Vec3(textX, textY, textZ))
    DrawText(screenPos, colors.teal, "Rapture Time")
  end

  if Me:IsSitting() or Me:IsCastingFixed() or Me.IsMounted or Me:IsStunned() then return end

  if PowerWordFortitude() then return end
  if DesperatePrayer() then return end
  if WoWItem:UseHealthstone() then return end
  if Fade() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  local tank = Me.FocusTarget
  if not tank then
    DrawText(Me:GetScreenPosition(), colors.white, "No Tank")
  end

  if Dispel() then return end

  local enemyCount = table.length(Combat.Targets)
  local hasInstantFlash = Me:HasAura(auras.instantflash)
  local radianceTarget
  local radianceCount = 0
  local haloHealCount = 0
  local haloDamageCount = 0
  local novaHealCount = 0
  local pwsTarget
  local penanceTarget
  local withoutAtonement = 0
  local noAtonementTarget
  local flashHealTarget
  for k, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if friend.InCombat then
      local hasAtonement = friend:HasAura(auras.atonement)

      if HealTrinket(friend) then return end

      if friend.HealthPct < 70 and not hasAtonement then
        withoutAtonement = withoutAtonement + 1
        if not noAtonementTarget then
          noAtonementTarget = friend
        end
      end

      if friend.HealthPct < 99 and Me:GetDistance(friend) < 12 then
        novaHealCount = novaHealCount + 1
      end

      if friend.HealthPct < 91 and Me:GetDistance(friend) < 20 and not hasAtonement then
        radianceCount = radianceCount + 1
        if not radianceTarget then
          radianceTarget = friend
        end
      end

      if friend.HealthPct < 88 and Me:GetDistance(friend) < 30 then
        haloHealCount = haloHealCount + 1
      end

      if friend.HealthPct < 95 and not pwsTarget then
        pwsTarget = friend
      end

      if friend.HealthPct < 30 and not penanceTarget then
        penanceTarget = friend
      end

      if friend.HealthPct < 70 and not hasAtonement then
        flashHealTarget = friend
      end

      if friend.HealthPct < 95 and not hasAtonement and hasInstantFlash then
        flashHealTarget = friend
      end

      if friend.HealthPct < 50 and Spell.Penance:CooldownRemaining() > 2000 then
        flashHealTarget = friend
      end
    end

    if enemyCount == 0 and friend.HealthPct < 70 then
      flashHealTarget = friend
    end
  end

  if raptureToggle and tank and Spell.Rapture:CastEx(tank) then return end

  if raptureToggle then
    if Spell.Rapture:CooldownRemaining() > 0 and not Me:HasAura(auras.rapture) then
      raptureToggle = false
    end

    for _, friend in pairs(Heal.Friends.All) do
      if not friend:HasAura(auras.powerwordshield) then
        if Spell.PowerWordShield:CastEx(friend) then return end
      end
    end
  end

  local pet = Me.Totems and Me.Totems[1].Name == "Mindbender"

  if tank and tank.InCombat and not tank:HasAura(auras.atonement) and Spell.PowerWordShield:CastEx(tank) then return end
  if withoutAtonement >= 2 and Spell.PowerWordRadiance:CastEx(noAtonementTarget) then return end
  if radianceCount > 2 and Spell.PowerWordRadiance.Charges == 2 and Spell.PowerWordRadiance:CastEx(radianceTarget) then return end
  if pwsTarget and Spell.PowerWordShield:CastEx(pwsTarget) then return end
  if penanceTarget and Spell.Penance:CastEx(penanceTarget) then return end
  if flashHealTarget and Spell.FlashHeal:CastEx(flashHealTarget) then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  local swdTarget
  local preShieldTarget
  local novaDamageCount = 0
  local totalEnemyHealth = 0
  local purgeSpread

  for _, enemy in pairs(Combat.Targets) do
    totalEnemyHealth = totalEnemyHealth + enemy.Health

    if not enemy:HasAura(auras.purge) and not purgeSpread then
      purgeSpread = enemy
    end

    if enemy.HealthPct < 20 then
      swdTarget = enemy
    end

    if Me:InMeleeRange(enemy) or Me:GetDistance(enemy) < 12 then
      novaDamageCount = novaDamageCount + 1
    end

    if Me:InMeleeRange(enemy) or Me:GetDistance(enemy) < 30 then
      haloDamageCount = haloDamageCount + 1
    end

    if not preShieldTarget then
      local eTarget = enemy.Target and enemy.Target.IsPlayer
      if eTarget and enemy.IsCastingOrChanneling then
        preShieldTarget = enemy.Target
      end
    end
  end

  if totalEnemyHealth > Me.HealthMax * 10 and not tank or not tank:IsMoving() and Spell.Mindbender:CastEx(target) then return end
  if PurgeTheWicked(target) then return end
  if Spell.Penance:CastEx(target) then return end
  if Spell.DarkReprimand:CastEx(target) then return end
  if not pet and purgeSpread and PurgeTheWicked(purgeSpread) then return end

  if preShieldTarget and not preShieldTarget:HasAura(auras.powerwordshield) and Spell.PowerWordShield:CastEx(preShieldTarget) then return end
  if swdTarget and Spell.ShadowWordDeath:CastEx(swdTarget) then return end
  local rhapsody = Me:GetAura(auras.rhapsody)
  if rhapsody and rhapsody.Stacks == 20 and novaDamageCount > 0 and novaHealCount > 0 then
    if Spell.HolyNova:CastEx(Me) then return end
  end
  if Me:HasAura(auras.shadowcov) and (haloHealCount >= 2 or haloDamageCount >= 2) and Spell.Halo:CastEx(Me) then return end
  if Spell.MindBlast:CastEx(target) then return end
  if swdTarget and Spell.ShadowWordDeath:CastEx(swdTarget) then return end
  if pet and Spell.ShadowWordDeath:CastEx(target) then return end
  if Spell.Smite:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestDiscipline,
  [BehaviorType.Combat] = PriestDiscipline
}

return { Options = gui, Behaviors = behaviors }
