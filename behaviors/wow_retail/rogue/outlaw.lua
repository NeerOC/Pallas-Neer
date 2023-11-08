---@diagnostic disable: duplicate-set-field
local sb = require("behaviors.wow_retail.rogue.outlaw-sb")
local gui = require("behaviors.wow_retail.rogue.outlaw-gui")
local colors = require("data.colors")

RogueListener = wector.FrameScript:CreateListener()
RogueListener:RegisterEvent('CHAT_MSG_ADDON')

local fullRotation = false
function RogueListener:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
  if prefix ~= "Pallas" then return end

  if text == "toggletype" then
    fullRotation = not fullRotation
  end
end

local function RogueOutlawMiniRotation(target)
  if sb.sliceanddice() then return end
  if sb.rollthebones() then return end
  if sb.ambush(target) then return end
  if sb.pistolshot(target) then return end
  if sb.sinisterstrike(target) then return end
end

local function RogueOutlawFullRotation(target)
  if sb.bladeflurry() then return end
  if sb.stealth() then return end
  if sb.rollthebones() then return end
  if sb.adrenalinerush() then return end
  if sb.ghostlystrike() then return end
  if sb.vanishbetween(target) then return end
  if sb.dancebetween(target) then return end
  if sb.betweentheeyes(target) then return end
  if sb.sliceanddice() then return end
  if sb.dispatch(target) then return end
  if sb.ambush(target) then return end
  if sb.pistolshot(target) then return end
  if sb.sinisterstrike(target) then return end
end

local function RogueOutlaw()
  if Me.IsMounted or Me:IsStunned() or Me:IsSitting() then return end

  if not Me.InCombat then
    if sb.instantpoison() then return end
    if sb.atrophicpoison() then return end
  end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  local drawX, drawY, drawZ = Me.Position.x, Me.Position.y, Me.Position.z - 2
  local drawPos = World2Screen(Vec3(drawX, drawY, drawZ))

  if Me:GetDistance(target) > 15 or wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if fullRotation then
    DrawText(drawPos, colors.white, ">> Full Rotation <<")
    RogueOutlawFullRotation()
  else
    DrawText(drawPos, colors.white, "<< Mini Rotation >>")
    RogueOutlawMiniRotation()
  end
end

local behaviors = {
  [BehaviorType.Combat] = RogueOutlaw
}

return { Options = gui, Behaviors = behaviors }
