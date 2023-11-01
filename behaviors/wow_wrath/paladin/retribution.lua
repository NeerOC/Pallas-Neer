local common = require('behaviors.wow_wrath.paladin.common')
local options = {
  -- The sub menu name
  Name = "Paladin (Ret)",

  -- widgets
  Widgets = {
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

TargetListener = wector.FrameScript:CreateListener()
TargetListener:RegisterEvent('PLAYER_TARGET_CHANGED')

local changePause = 0
function TargetListener:PLAYER_TARGET_CHANGED()
  changePause = wector.Game.Time + 250
end

local auras = {
  artofwar = 59578,
  JudgementOfLight = 20185
}

local function PaladinRetriCombat()
  if Me.IsMounted then
    if Spell.CrusaderAura:Apply(Me) then return end
  end

  local undeadNear = false
  local highestMob

  if Me.IsMounted or Me:IsSitting() then return end

  if Spell.RetributionAura:Apply(Me) then return end
  if Spell.SealOfCommand:Apply(Me) then return end
  if Spell.BlessingOfMight:Apply(Me) then return end

  for _, e in pairs(Combat.Targets) do
    local etarget = e.Target

    if not highestMob or highestMob.Health < e.Health and not e:HasAura(auras.JudgementOfLight) then
      highestMob = e
    end

    if (e.CreatureType == CreatureType.Undead or e.CreatureType == CreatureType.Demon) and Me:GetDistance(e) < 10 then
      undeadNear = true
    end

    if not etarget or not etarget.IsActivePlayer then
      if Spell.HandOfReckoning:CastEx(e) then return end
    end

    if e.HealthPct <= 20 and e.HealthPct > 10 and Me:IsFacing(e) then
      if Spell.HammerOfWrath:CastEx(e, SpellCastExFlags.NoUsable) then
        return
      end
    end
  end

  local target = Combat.BestTarget
  if not target or wector.SpellBook.GCD:CooldownRemaining() > 0 or Me.IsCastingOrChanneling then return end

  if changePause < wector.Game.Time then
    if Me:InMeleeRange(target) and not Me:IsAttacking(target) then
      Me:StartAttack(target)
    end
  end

  if target.HealthPct <= 20 and target.HealthPct > 10 and Spell.HammerOfWrath:CastEx(target) then return end

  if not Me:IsMoving() and Combat.EnemiesInMeleeRange > 1 and Me.PowerPct > 60 and Spell.Consecration:CastEx(Me) then return end

  if highestMob and Spell.JudgementOfLight:CastEx(highestMob) then return end

  if Spell.JudgementOfLight:CastEx(target) then return end
  if Me:HasAura(auras.artofwar) then
    local lowest = Heal:GetLowestMember()

    if target.InCombat and Spell.Exorcism:CastEx(target) then return end
    if lowest then
      if Spell.FlashOfLight:CastEx(lowest) then return end
    end
  end

  if Combat.EnemiesInMeleeRange > 1 and Spell.DivineStorm:CastEx(Me) then return end
  if Spell.CrusaderStrike:CastEx(target) then return end

  if undeadNear and not Me:IsMoving() and Spell.HolyWrath:CastEx(Me) then return end

  if Me:InMeleeRange(target) and Spell.DivineStorm:CastEx(Me) then return end
end

local behaviors = {
  [BehaviorType.Heal] = PaladinRetriCombat,
  [BehaviorType.Combat] = PaladinRetriCombat
}

return { Options = options, Behaviors = behaviors }
