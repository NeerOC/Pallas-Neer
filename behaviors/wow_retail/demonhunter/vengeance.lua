local gui = require("behaviors.wow_retail.demonhunter.vengeance-gui")

local auras = {
  soulfragments = 203981,
  frailty = 247456
}

local nextEly = 0
local function ElysianDecree(target)
  if target:IsMoving() then return end
  if nextEly > wector.Game.Time then
    return
  end

  if Spell.ElysianDecree:CastEx(target) then
    nextEly = wector.Game.Time + 4000
  end
end

local function Incorporeal()
  for _, incorp in pairs(Combat.Incorporeals) do
    if Me:IsFacing(incorp) and Spell.Imprison:CastEx(incorp) then return end
    if Spell.Imprison:CooldownRemaining() > 0 and Spell.SigilOfMisery:CastEx(incorp) then return end
  end
end

local function DemonhunterVengeanceCombat()
  if Me:IsSitting() or Me.IsMounted or Me:IsCastingFixed() then return end

  local fragments = Me:GetAura(auras.soulfragments)
  local fragStacks = fragments and fragments.Stacks or 0
  local enemies10 = 0
  local interruptibles = {}
  local silenceTarget
  local imprisonTarget
  local totalHealth = 0
  local bigBois = 0
  local biggestBoi
  local glaiveAggro
  local furthestBoi

  for _, enemy in pairs(Combat.Targets) do
    totalHealth = totalHealth + enemy.Health

    local distance = Me:GetDistance(enemy)

    if Me:IsFacing(enemy) and enemy.Health > Me.HealthMax * 2 and (not furthestBoi or Me:GetDistance(furthestBoi) < distance) then
      furthestBoi = enemy
    end

    if not biggestBoi or enemy.Health > biggestBoi.Health then
      biggestBoi = enemy
    end

    if Me:IsFacing(enemy) and not enemy.Aggro then
      glaiveAggro = enemy
    end

    if enemy.Health > Me.HealthMax * 1.5 and Me:InMeleeRange(enemy) then
      bigBois = bigBois + 1
    end

    if enemy.Target and enemy.Target.IsPlayer and enemy.Target ~= Me and not enemy.Aggro and not enemy.IsCastingOrChanneling then
      if Spell.Torment:CastEx(enemy) then Alert("Taunted!", 2) end
    end

    if Me:InMeleeRange(enemy) or Me:GetDistance(enemy) < 10 then
      enemies10 = enemies10 + 1
    end

    if enemy:IsCastingFixed() and enemy.IsInterruptible then
      if Spell.Disrupt:InRange(enemy) and Spell.Disrupt:CastEx(enemy) then Alert("Interrupt", 2) end
      if Spell.Imprison:InRange(enemy) then imprisonTarget = enemy end
      table.insert(interruptibles, enemy)
    end
  end


  if table.length(interruptibles) > 1 then
    local otherKickable
    for _, kickable in pairs(interruptibles) do
      if not otherKickable then
        otherKickable = kickable
        goto continue
      end

      if kickable:InMeleeRange(otherKickable) or kickable:GetDistance(otherKickable) < 16 then
        silenceTarget = kickable
      end

      ::continue::
    end
  end

  if WoWItem:UseHealthstone() then Alert("Healthstone", 2) end
  if (bigBois > 0 or totalHealth > Me.HealthMax * 3) and enemies10 > 0 and Spell.DemonSpikes.Charges == 2 and Spell.DemonSpikes:CastEx(Me) then
    Alert("Defensive", 2) end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end


  if Incorporeal() then return end
  if silenceTarget and Spell.SigilOfSilence:CastEx(silenceTarget) then return end
  --if imprisonTarget and Spell.Imprison:CastEx(imprisonTarget) then return end
  if enemies10 > 0 and fragStacks >= 4 and Spell.SpiritBomb:CastEx(Me) then return end
  if enemies10 > 0 and Spell.ImmolationAura:CastEx(Me) then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if totalHealth > Me.HealthMax * 3 and Spell.FieryBrand:CastEx(biggestBoi) then return end
  if not Me:IsMoving() and furthestBoi and totalHealth > Me.HealthMax * 3 and Spell.TheHunt:CastEx(furthestBoi) then return end
  if not Me:IsMoving() and fragStacks <= 2 and ElysianDecree(target) then return end
  if not Me:IsMoving() and not target:IsMoving() and Spell.SigilOfFlame:CastEx(target) then return end
  if fragStacks == 0 and Me.Power >= 50 and Spell.SoulCleave:CastEx(target) then return end
  if Spell.Fracture:CastEx(target) then return end
  if Me:InMeleeRange(target) and Spell.Felblade:CastEx(target) then return end

  if glaiveAggro and Spell.ThrowGlaive:CastEx(glaiveAggro) then return end
  if Spell.ThrowGlaive:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = DemonhunterVengeanceCombat
}

return { Options = gui, Behaviors = behaviors }
