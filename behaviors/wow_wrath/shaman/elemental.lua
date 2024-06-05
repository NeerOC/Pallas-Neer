local colors = require "data.colors"
local options = {
  -- The sub menu name
  Name = "Shaman (Ele)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "placeholder",
      text = "placeholder",
      default = false
    },
  }
}

local auras = {
  flametongue = 10400
}

local function ShamanElementalCombat()
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
  if Me.IsCastingOrChanneling then return end

  if Spell.LightningShield:Apply(Me) then return end
  if not Me:HasAura(auras.flametongue) and Spell.FlametongueWeapon:CastEx(Me) then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  if Me:GetDistance(target) <= 30 then
    DrawCircle(target:GetScreenPosition(), 5, colors.green, 10)
  end

  if Spell.EarthShock:CastEx(target) then return end
  if Spell.PrimalStrike:CastEx(target) then return end
  if Spell.LightningBolt:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = ShamanElementalCombat
}

return { Options = options, Behaviors = behaviors }
