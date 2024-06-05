local gui = require("behaviors.wow_retail.druid.guardian-gui")
local sb = require("behaviors.wow_retail.druid.guardian-sb")
local colors = require("data.colors")

BalanceListener = wector.FrameScript:CreateListener()
BalanceListener:RegisterEvent('CHAT_MSG_ADDON')

local tagging = false
local tagany = false
local enemies = {}

local function removetag(which)
  for entry, enemy in pairs(enemies) do
    if enemy == which then
      table.remove(enemies, entry)
    end
  end
end

local function GetLootAround(unit, table)
  local count = 0
  for _, loot in pairs(table) do
    if Me:GetDistance(loot) < 40 then
      if loot ~= unit then
        if loot:GetDistance(unit) < 33 then
          count = count + 1
        end
      end
    end
  end

  return count
end

function BalanceListener:CHAT_MSG_ADDON(prefix, text, channel, sender)
  if prefix ~= "pallas" then return end

  if text == "toggletag" then
    tagging = not tagging
    print("Tagging: " .. tostring(tagging))
    return
  end

  if text == "tagany" then
    tagany = true
  end

  if text == "addtag" then
    local target = Me.Target
    if target then
      if not table.contains(enemies, target.EntryId) then
        table.insert(enemies, target.EntryId)
        print("Added " .. target.NameUnsafe .. ' to taglist')
      else
        removetag(target.EntryId)
        print("Removed " .. target.NameUnsafe .. ' from taglist')
      end
    else
      print("No target or invalid target")
    end
  end
end

local function Tag()
  local x = 10
  for _, entry in pairs(enemies) do
    local textpos = World2Screen(Vec3(Me.Position.x, Me.Position.y, Me.Position.z + x))
    DrawText(textpos, colors.white, tostring(entry))
    x = x - 0.5
  end

  local units = wector.Game.Units
  for _, unit in pairs(units) do
    local dead = unit.DeadOrGhost
    local distance = Me:GetDistance(unit) < 45
    if dead or not distance then goto continue end
    local id = unit.EntryId
    local dotted = unit:GetAuraByMe(Spell.Moonfire.Name) or unit:GetAuraByMe(Spell.Sunfire.Name)
    local validUnit = Me:CanAttack(unit) and unit.Level > 1

    if (table.contains(enemies, id) or tagany) and not unit.IsTapDenied and not dotted and validUnit then
      if Me:WithinLineOfSight(unit) then
        Me:SetTarget(unit)
        if Spell.Moonfire:CastEx(unit) then
          return
        end
        return
      end
    end
    ::continue::
  end
end


local function DruidGuardian()
  if Me.IsMounted or Me.IsCastingOrChanneling or Me:IsStunned() then return false end
  if Me.ShapeshiftForm ~= ShapeshiftForm.Bear then return end

  -- General
  if sb.markofthewild() then return end
  -- Tagging
  if tagging then
    Tag()
    return
  end
  if sb.growl() then return end
  -- Defensives
  if sb.frenziedregeneration() then return end
  if sb.barkskin() then return end
  if sb.ironfur() then return end
  if sb.docRegrowth() then return end

  -- Offensive
  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return false end

  -- Interrupt
  if Me:InMeleeRange(target) and Spell.SkullBash:Interrupt() then return end

  if not Me:IsAutoAttacking() then
    Me:ToggleAttack()
  end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if sb.wardofsalvation() then return end
  if sb.afflicted() then return end
  if sb.removecorruption() then return end
  if sb.thrash() then return end
  if sb.moonfire(target, true) then return end -- add aoe threat check
  if sb.maul(target) then return end
  if sb.mangle(target) then return end
  if sb.swipe(true) then return end
  if sb.moonfire(target) then return end
  if sb.swipe() then return end
end

local behaviors = {
  [BehaviorType.Combat] = DruidGuardian,
  --[BehaviorType.Heal] = DruidGuardian
}

return { Options = gui, Behaviors = behaviors }
