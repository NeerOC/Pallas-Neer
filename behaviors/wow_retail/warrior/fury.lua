local colors = require "data.colors"
local options = {
  Name = "Warrior (Fury)",
  Widgets = {
    {
      type = "combobox",
      uid = "CommonInterrupts",
      text = "Interrupt",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    },
    {
      type = "slider",
      uid = "CommonInterruptPct",
      text = "Kick Cast Left (%)",
      default = 20,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "FuryVictoryRushPct",
      text = "Victory (%)",
      default = 50,
      min = 0,
      max = 100
    },
  }
}

TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('PLAYER_TARGET_CHANGED')

local changePause = 0
function TargetListener:PLAYER_TARGET_CHANGED()
  changePause = wector.Game.Time + 250
end

local function WarriorFuryCombat()
  if Me:HasAura(Spell.Shadowmeld.Id) then
    return
  end

  if Spell.BerserkerStance:Apply(Me) then return end

  if Me.IsMounted or Me:IsStunned() then return end

  if WoWItem:UseHealthstone() then return end

  if Spell.BattleShout:Apply(Me) then return end

  if Spell.Pummel:Interrupt() then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
  local wwbuff = Me:HasAura(85739)
  local enemies16 = Combat:GetEnemiesWithinDistance(16)
  if not wwbuff and enemies16 > 1 and Spell.Whirlwind:CastEx(Me) then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if wector.Game.Time > changePause and not Me:IsAttacking(target) then
    Me:StartAttack(target)
  end

  if Me.HealthPct < Settings.FuryVictoryRushPct then
    if Spell.ImpendingVictory:CastEx(target) then return end
    if Spell.VictoryRush:CastEx(target) then return end
  end

  local enragebuff = Me:HasAura(184362)
  local ravagerbuff = Me:GetAura(390581)
  local regbuff = Me:HasAura(184364)

  if regbuff and Me.HealthPct < 80 then
    if Spell.Bloodthirst:CastEx(target) then return end
  end

  if Combat.MiniBurst then
    if Spell.Recklessness:CastEx(Me) then return end
    if Spell.Ravager:CastEx(target) then return end
  end

  if Combat.Burst then
    if Spell.Recklessness:CastEx(Me) then return end
    if Spell.Avatar:CastEx(Me) then return end
    if Spell.Ravager:CastEx(target) then return end
    if ravagerbuff and ravagerbuff.Stacks == 6 and Spell.ThunderousRoar:CastEx(Me) then return end
  end

  if Me.PowerPct < 70 and Spell.Onslaught:CastEx(target) then return end
  if not enragebuff and Spell.Bloodthirst:CastEx(target) then return end
  if Spell.Rampage:CastEx(target) then return end
  local sd = Me:GetAura(280776)
  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) and (enemy.HealthPct < 20 or sd) and Spell.Execute:CastEx(enemy, SpellCastExFlags.NoUsable) then return end
  end
  if Spell.RagingBlow:CastEx(target) then return end
  if Spell.Bloodthirst:CastEx(target) then return end
  if Spell.Whirlwind:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorFuryCombat
}

return { Options = options, Behaviors = behaviors }
