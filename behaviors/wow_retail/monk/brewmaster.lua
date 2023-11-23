---@diagnostic disable: duplicate-set-field
local sb = require("behaviors.wow_retail.monk.brewmaster-sb")
local gui = require("behaviors.wow_retail.monk.brewmaster-gui")
local colors = require("data.colors")

local auras = {}
local function DebugAuras()
  for _, aura in pairs(Me.Auras) do
    if not table.contains(auras, aura.Id) then
      print("Inserted Aura: " .. aura.Name .. ", With ID: " .. aura.Id)
      table.insert(auras, aura.Id)
    end
  end
end

BrewListener = wector.FrameScript:CreateListener()
BrewListener:RegisterEvent('CHAT_MSG_ADDON')
BrewListener:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

local pausing = false
function BrewListener:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
  if prefix ~= "pallas" and prefix ~= "brewmaster" then return end

  if prefix == "brewmaster" then
    return
  end

  if text == "pause" and not pausing then
    pausing = true
  end
end

function BrewListener:COMBAT_LOG_EVENT_UNFILTERED(entry)
  if not entry then return end
  if entry.EventTypeName ~= "SPELL_CAST_SUCCESS" then return end
  if entry.Source.Name ~= Me.NameUnsafe then return end

  if pausing then
    pausing = false
  end
end

local function BrewmasterCombat()
  --DebugAuras()

  if pausing then
    DrawText(Me:GetScreenPosition(), colors.white, "Pausing")
    return
  end

  if Me.IsMounted or Me:IsStunned() or Me:IsCastingFixed() then return end

  if not Me.InCombat then
    if sb.rushingjadewind() then return end
  end

  if sb.spearhandstrike() then return end
  if sb.provoke() then return end
  if sb.purifyingbrew() then return end

  local target = Me.Target and Me:CanAttack(Me.Target) and Combat.BestTarget
  if not target then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if sb.expelharm() then return end

  if sb.touchofdeath() then return end
  if sb.blackoutkick(target) then return end
  if sb.bonedustbrew(target) then return end
  if sb.presstheadvantage(target) then return end
  if sb.risingsunkick(target) then return end
  if sb.kegsmash(target) then return end
  if sb.breathoffire(target) then return end
  if sb.rushingjadewind() then return end
  if sb.chiwave(target) then return end
  if sb.spinningcranekick() then return end
  if sb.tigerpalm(target) then return end
end

return {
  Options = gui,
  Behaviors = {
    [BehaviorType.Combat] = BrewmasterCombat
  }
}
