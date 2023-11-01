local options = {
  Name = "Hunter (Beastmastery)",

  Widgets = {
  }
}

TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('PLAYER_TARGET_CHANGED')

local changePause = 0
function TargetListener:PLAYER_TARGET_CHANGED()
  changePause = wector.Game.Time + 500
end

local function getBestTarget()
  local bestTarget
  for _, enemy in pairs(Combat.Targets) do
    if not bestTarget or enemy:GetThreatPct(Me) > bestTarget:GetThreatPct(Me) then
      bestTarget = enemy
    end
  end

  return bestTarget
end

local function AspectToggle()
  if table.length(Combat.Targets) > 0 or Me.InCombat then
    local viperOrHawk = Me.PowerPct < 5 and Spell.AspectOfTheViper or
    (not Me:HasAura(Spell.AspectOfTheViper.Id) or Me.PowerPct > 30) and Spell.AspectOfTheHawk

    return viperOrHawk and viperOrHawk:Apply(Me)
  else
    if Spell.AspectOfTheCheetah:Apply(Me) then return end
  end
end

local function PetAttack()
  if not Me.Pet or Me.Pet.DeadOrGhost then return end
  local bestTarget = getBestTarget()
  local petTarget = Me.Pet.Target

  if not bestTarget or petTarget ~= bestTarget then Me:PetAttack(bestTarget) end
  --if Spell.Growl:CastEx(bestTarget) then return end
  if Combat.Burst and Spell.Rake:CastEx(bestTarget) then return end
  if Spell.Claw:CastEx(bestTarget) then return end
end

local function PetFollow()
  if not Me.Pet or Me.Pet.DeadOrGhost then return end
  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end
  if Me.Pet.Target then Me:PetFollow() end
end

local function PetSmart()
  if not Me.Pet or Me.Pet.DeadOrGhost then return end
  local mend = Me.Pet:GetAura(Spell.MendPet.Name)
  if Me.Pet.HealthPct < 90 and (not mend or mend.Remaining < 3000) and Spell.MendPet:CastEx(Me) then return end
end

local function serpentSting(target)
  if Me:HasAura(Spell.AspectOfTheViper.Id) then return end

  if target:TimeToDeath() > 10 and target:TimeToDeath() ~= 9999 and Spell.SerpentSting:Apply(target) then return end

  for _, enemy in pairs(Combat.Targets) do
    if enemy:TimeToDeath() > 10 and enemy:TimeToDeath() ~= 9999 and Spell.SerpentSting:Apply(enemy) then return end
  end
end

local function HuntersMark(target)
  local alreadyHas = false
  for _, enemy in pairs(Combat.Targets) do
    if enemy:HasAura(Spell.HuntersMark.Id) then
      alreadyHas = true
    end
  end

  return not alreadyHas and Spell.HuntersMark:Apply(target)
end

local function HunterBeastmasteryCombat()
  DrawText(World2Screen(Me.Position), 0xFF008CFF, table.length(Combat.Targets))

  if Me.IsMounted or Me.IsCastingOrChanneling then return end

  AspectToggle()
  PetSmart()

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then
    PetFollow()
    return
  end

  if changePause < wector.Game.Time then
    if not Me:IsAttacking(target) then
      Me:StartAttack(target)
    end
  end

  PetAttack()

  if Combat.Burst and Spell.BloodFury:CastEx(Me) then return end
  if Combat:GetTargetsAround(target, 10) > 1 and Spell.Multishot:CastEx(target) then return end
  if Me:GetDistance(target) > 10 and HuntersMark(target) then return end
  if serpentSting(target) then return end
  if Spell.ArcaneShot:CastEx(target) then return end

  if Me:InMeleeRange(target) then
    if Spell.RaptorStrike:CastEx(target) then return end
    if Spell.MongooseBite:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = HunterBeastmasteryCombat
}

return { Options = options, Behaviors = behaviors }
