---@diagnostic disable: duplicate-set-field
local sb = require("behaviors.wow_retail.rogue.outlaw-sb")
local gui = require("behaviors.wow_retail.rogue.outlaw-gui")
local colors = require("data.colors")

RogueListener = wector.FrameScript:CreateListener()
RogueListener:RegisterEvent('CHAT_MSG_ADDON')

local fullRotation = true
function RogueListener:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
  if prefix ~= "pallas" then return end

  if text == "toggletype" then
    fullRotation = not fullRotation
  end
end

local function RogueOutlawFullRotation(target)
  if sb.bladeflurry() then return end
  if sb.stealth() then return end
  if sb.adrenalinerush() then return end
  if sb.ghostlystrike(target) then return end
  if sb.vanishbetween(target) then return end
  if sb.dancebetween(target) then return end
  if sb.betweentheeyes(target) then return end
  if sb.sliceanddice() then return end
  if sb.dispatch(target) then return end
  if sb.pistolshot(target, false) then return end
  if sb.ambush(target) then return end
  if sb.pistolshot(target, true) then return end
  if sb.sinisterstrike(target) then return end
end

local spellsCast = {}
local function DebugCasts()
  for _, enemy in pairs(Combat.Targets) do
    local spell = enemy.CurrentSpell
    if spell and enemy.IsInterruptible and not table.contains(spellsCast, spell.Id) then
      print(enemy.NameUnsafe .. ", is casting an Interruptible spell: " .. spell.Name .. ", With ID: " .. spell.Id)
      table.insert(spellsCast, spell.Id)
    end
  end
end

local auras = {}
local function DebugAuras()
  local target = Me.Target
  if target then
    for _, aura in pairs(target.Auras) do
      if not table.contains(auras, aura.Name) then
        table.insert(auras, aura.Name)
        print("Aura: " .. aura.Name .. ", ID: " .. aura.Id)
      end
    end
  end
end

local function RogueOutlaw()
  --DebugCasts()
  --DebugAuras()
  if Me.IsMounted or Me:IsStunned() or Me:IsSitting() or Me.IsCastingOrChanneling then return end

  sb.getAuras()

  if not Me.InCombat then
    if Me.HealthPct < 40 and Spell.CrimsonVial:CastEx(Me) then return end
    if sb.instantpoison() then return end
    if sb.atrophicpoison() then return end
  end

  --if sb.pickpocket() then return end
  if sb.stealth() then return end
  if sb.kick() then return end
  if sb.tricksofthetrade() then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if sb.rollthebones() then return end

  if Me:GetDistance(target) > 30 or wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if sb.handleincorp() then return end
  if sb.stunspells() then return end
  if sb.cheapshotinterrupt() then return end
  if sb.kidneyshotinterrupt() then return end

  RogueOutlawFullRotation(target)
end

local behaviors = {
  [BehaviorType.Combat] = RogueOutlaw
}

return { Options = gui, Behaviors = behaviors }
