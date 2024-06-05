local colors = require "data.colors"
local options = {
  -- The sub menu name
  Name = "Warrior (Arms)",

  -- widgets
  Widgets = {

  }
}

local auras = {
  suddendeath = 1
}

ArmsListener = wector.FrameScript:CreateListener()
ArmsListener:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
ArmsListener:RegisterEvent('UNIT_COMBAT')

local function WarriorArmsCombat()
  if Me.IsMounted or Me:IsCastingFixed() then return end
  if (not Me.InCombat or Me.Power < 5) and Spell.BattleShout:CastEx(Me) then return end
  if Spell.BattleStance:Apply(Me) then return end

  if Me:IsFeared() then
    Spell.BerserkerRage:CastEx(Me)
  end

  local enemies6 = Combat:GetEnemiesWithinDistance(6, true, 60)
  local enemies8 = Combat:GetEnemiesWithinDistance(8, false)

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end


  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if Me:GetDistance(target) > 20 and Spell.HeroicThrow:CastEx(target) then return end

  if Me:IsFacing(target) and Me:GetDistance(target) > 15 then
    if Spell.Charge:CastEx(target) then return end
  end

  if enemies6 > 2 and Me.Power >= 30 then
    Spell.SweepingStrikes:CastEx(Me)
  end

  if Me.Power > 90 then
    Spell.InnerRage:CastEx(Me)
  end

  if Me:HasAura("Blood Fury") then
    Spell.DeadlyCalm:CastEx(Me)
  end

  if enemies6 > 1 then
    if enemies6 > 2 and Me.Power > 50 or Me.Power > 75 or Me:HasAura("Deadly Calm") then
      Spell.Cleave:CastEx(target)
    end
  else
    if Me.Power > 75 or Me:HasAura("Deadly Calm") then
      Spell.HeroicStrike:CastEx(target)
    end
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Me.HealthPct < 80 and Spell.VictoryRush:CastEx(target) then return end

  if Me.Power >= 30 then
    for _, enemy in pairs(Combat.Targets) do
      if enemy.HealthPct < 20 and Spell.Execute:CastEx(enemy, SpellCastExFlags.NoUsable) then return end
    end
  end

  if not Me:InMeleeRange(target) then return end

  if Spell.Rend:Apply(target) then return end
  if Me.Power >= 30 and target.HealthPct < 20 and Spell.Execute:CastEx(target) then return end

  if not target:GetAuraByMe("Rend") and target:TimeToDeath() > 10 then return end

  if enemies8 > 2 and Spell.ThunderClap:CastEx(Me) then return end

  if Me:InMeleeRange(target) then
    if Spell.MortalStrike:CastEx(target) then return end
    if Spell.Overpower:CastEx(target) then return end
    if Spell.Slam:CastEx(target) then return end
    if Spell.VictoryRush:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorArmsCombat,
}

return { Options = options, Behaviors = behaviors }
