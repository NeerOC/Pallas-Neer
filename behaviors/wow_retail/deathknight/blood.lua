local gui = require("behaviors.wow_retail.deathknight.blood-gui")

local auras = {
  boneshield = 195181,
  disease = 55078
}

local function DeathKnightBlood()
  if Me.IsMounted or Me:IsCastingFixed() or Me:IsSitting() or Me:IsStunned() then return end

  local bone_shield_good = Me:GetAura(auras.boneshield) and Me:GetAura(auras.boneshield).Stacks >= 7

  if Spell.MindFreeze:Interrupt() then return end

  local withoutDisease = false
  local enemyCount = 0
  local noAggroEnemy

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.Aggro and enemy.Target and enemy.Target.IsPlayer then
      noAggroEnemy = enemy
    end
    if Me:InMeleeRange(enemy) or Me:GetDistance(enemy) < 10 then
      enemyCount = enemyCount + 1
      if not enemy:HasAura(auras.disease) then
        withoutDisease = true
      end
    end
  end

  if not Me:InMeleeRange(target) and Me:GetDistance(target) > 20 then
    if not target:HasAura(auras.disease) and Spell.DeathsCaress:CastEx(target) then return end
  end
  if noAggroEnemy and Spell.DarkCommand:CastEx(noAggroEnemy) then Alert("Taunt", 2) end
  if not bone_shield_good and Spell.Marrowrend:CastEx(target) then return end
  if Me.HealthPct < 50 and Spell.DeathStrike:CastEx(target) then return end
  if Me.Power >= 70 and Spell.DeathStrike:CastEx(target) then return end
  if (withoutDisease and Me:InMeleeRange(target) or Spell.BloodBoil.Charges == 2 and enemyCount > 0) and Spell.BloodBoil:CastEx(Me) then return end
  if bone_shield_good and Spell.HeartStrike:CastEx(target) then return end
  if Spell.RuneStrike:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = DeathKnightBlood
}

return { Options = gui, Behaviors = behaviors }
