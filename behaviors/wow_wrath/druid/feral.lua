local gui = require("behaviors.wow_wrath.druid.feral-gui")
local sb = require("behaviors.wow_wrath.druid.feral-sb")
local colors = require("data.colors")

local function BearRotation()
  if sb.growl() then return end
  if sb.challengingroar() then return end

  local target = sb.getlowestThreat()
  if not target then return end

  Me:SetTarget(target)
  --sb.faceunit(target)

  if sb.faeriefire(true) then return end
  if sb.autoattack(target) then return end
  if Spell.MangleBear:CastEx(target) then return end
  if sb.swipebear() then return end
  if sb.maul(target) then return end
  if sb.faeriefire() then return end
end

local function CatRotation()
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if sb.regrowth() then return end
  if sb.autoattack(target) then return end
  if sb.faeriefirecat(target) then return end
  if sb.tigersfury() then return end
  if sb.berserk() then return end
  if sb.ferociousbite(target) then return end
  if sb.rip(target) then return end
  if sb.rake(target) then return end
  --if sb.shred(target) then return end
  if sb.manglecat(target) then return end
end

local function DruidFeralCombat()
  if Me:IsSitting() or Me.IsMounted or Me:IsCastingFixed() then return end

  if not Me.InCombat then
    if not Me:HasAura(Spell.MarkOfTheWild.Name) and Spell.MarkOfTheWild:CastEx(Me) then return end
    if not Me:HasAura(Spell.Thorns.Name) and Spell.Thorns:CastEx(Me) then return end
  end

  if Me.ShapeshiftForm == ShapeshiftForm.Bear or Me.ShapeshiftForm == ShapeshiftForm.DireBear then
    BearRotation()
    return
  end

  if Me.ShapeshiftForm == ShapeshiftForm.Cat then
    CatRotation()
    return
  end

  if not Me.InCombat then return end

  if Me.HealthPct <= 100 and Me.PowerPct > 50 then
    if Spell.Rejuvenation:Apply(Me, nil, true) then return end
  end
end

return {
  Options = gui,
  Behaviors = {
    [BehaviorType.Combat] = DruidFeralCombat
  }
}
