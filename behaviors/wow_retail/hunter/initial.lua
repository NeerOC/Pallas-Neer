---@diagnostic disable: duplicate-set-field, inject-field
local colors = require "data.colors"
local options = {
  Name = "Hunter (Beastmastery)",

  Widgets = {
  }
}

local function HunterInitialCombat()
  local pet = Me.Pet

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then
    if pet and pet.Target then Me:PetFollow() end
    return
  end

  if pet then
    if not pet.Target or pet.Target ~= target then
      Me:PetAttack(target)
    end
  end

  if not Spell.AutoShot.IsAutoRepeat then
    Spell.AutoShot:CastEx(target)
  end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if Spell.HuntersMark:Apply(target) then return end
  if Spell.ArcaneShot:CastEx(target) then return end
  if Spell.SteadyShot:CastEx(target) then return end
end


local behaviors = {
  [BehaviorType.Combat] = HunterInitialCombat
}

return { Options = options, Behaviors = behaviors }
