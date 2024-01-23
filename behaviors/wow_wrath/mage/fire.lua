local options = {
  -- The sub menu name
  Name = "Mage (Fire)",
  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "UseAoe",
      text = "Use Aoe",
      default = true
    },
    {
      type = "checkbox",
      uid = "UseFrostfireBolt",
      text = "Use Frostfire Bolt instead of Fireball",
      default = false
    },
    {
      type = "combobox",
      uid = "CommonDispels",
      text = "Dispel",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    },
    {
      type = "slider",
      uid = "CommonInterruptPct",
      text = "Counterspell Cast Left (%)",
      default = 40,
      min = 0,
      max = 100
    },
    {
      type = "combobox",
      uid = "CommonInterrupts",
      text = "Interrupt",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    },
  }
}

local function Decurse()
  local spell = Spell.RemoveCurse
  if spell:CooldownRemaining() > 0 then return false end
  if spell:Dispel(true, DispelPriority.Low, WoWDispelType.Curse) then return end
end

local function DoInterrupt()
  if Spell.Counterspell:Interrupt() then return end
end


local function MageFireSingleTarget(target)
  -- Pyroblast
  if Me:HasVisibleAura("Hot Streak") then
    if Spell.Pyroblast:CastEx(target) then return end
  end

  -- Living Bomb
  if not target:HasVisibleAura("Living Bomb") then
    if Spell.LivingBomb:CastEx(target) then return end
  end

  -- Fire Blast
  if Spell.FireBlast:CastEx(target) then return end

  -- Frostfire Bolt or Fireball
  if Settings.UseFrostfireBolt then
    if Spell.FrostfireBolt:CastEx(target) then return end
  else
    if Spell.Fireball:CastEx(target) then return end
  end
end

local function MageFireAoe(target)
  -- Pyroblast
  if Me:HasVisibleAura("Hot Streak") then
    if Spell.Pyroblast:CastEx(target) then return end
  end

  -- Living Bomb
  if not target:HasVisibleAura("Living Bomb") then
    if Spell.LivingBomb:CastEx(target) then return end
  end

  -- Cast Living Bomb on multiple targets if they live longer than 12 seconds
  for _, enemy in ipairs(Combat.Targets) do
    if enemy:TimeToDeath() > 12 and not enemy:HasVisibleAura("Living Bomb") then
      if Spell.LivingBomb:CastEx(enemy) then return end
    end
  end

  if Me:HasVisibleAura("Firestarter") and Spell.Flamestrike:CastEx(target) then return end

  -- Blast Wave
  if (Combat:GetEnemiesWithinDistance(10) > 2) then
    if Spell.BlastWave:CastEx(Me) then return end
  end

  -- Dragon's Breath
  if (Me:IsFacing(target) and Combat:GetEnemiesWithinDistance(10) > 2) then
    if Spell.DragonsBreath:CastEx(Me) then return end
  end

  -- Spam Blizzard
  if not Me:IsMoving() and Me.PowerPct > 15 and Spell.Blizzard:CastEx(target) then return end
end

local function MageFireCombat()
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  if DoInterrupt() then return end
  if Decurse() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if Me.IsCastingOrChanneling then return end



  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  local aoe = Settings.UseAoe

  if aoe and Combat:GetEnemiesWithinDistance(20) > 2 then
    MageFireAoe(target)
  else
    MageFireSingleTarget(target)
  end
end

local behaviors = {
  [BehaviorType.Combat] = MageFireCombat
}

return { Options = options, Behaviors = behaviors }
