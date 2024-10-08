---@diagnostic disable: param-type-mismatch, duplicate-set-field

---@class Combat : Targeting
Combat = Combat or Targeting:New()

---@type WoWUnit?
Combat.BestTarget = nil
Combat.EnemiesInMeleeRange = 0
Combat.Enemies = 0

---@type WoWUnit[]
Combat.Incorporeals = {}
Combat.MirrorImages = {}
Combat.Totems = {}
Combat.Casters = {}
Combat.Draws = {}

Combat.EventListener = wector.FrameScript:CreateListener()
Combat.EventListener:RegisterEvent("PLAYER_ENTER_COMBAT")
Combat.EventListener:RegisterEvent("PLAYER_LEAVE_COMBAT")
Combat.EventListener:RegisterEvent("CONSOLE_MESSAGE")
Combat.EventListener:RegisterEvent("PLAYER_REGEN_ENABLED")
Combat.EventListener:RegisterEvent("PLAYER_REGEN_DISABLED")
Combat.EventListener:RegisterEvent("CHAT_MSG_ADDON")

local specialUnits = {
  incorporeal = 204560,
}

local ignoreList = {
  [45704] = true,  -- Vortex Pinnacle, hiding mobs
  [8317] = true,   -- Spirits in Sunken temple
  [204560] = true, -- Incorporeals, cant attack em anyway.
}

---@type boolean Addon command burst to set on/off
Combat.Burst = false
---@type boolean Addon command mini burst to set on/off
Combat.MiniBurst = false

function Combat.EventListener:CHAT_MSG_ADDON(prefix, text, channel, target)
  if prefix ~= "pallas" then return end

  if text == "burst" then
    Combat.Burst = not Combat.Burst
  elseif text == "miniburst" then
    Combat.MiniBurst = not Combat.MiniBurst
  end
end

local combatStart = 0
function Combat.EventListener:PLAYER_REGEN_ENABLED()
  combatStart = 0

  if Combat.Burst then
    Combat.Burst = false
  end

  if Combat.MiniBurst then
    Combat.MiniBurst = false
  end
end

function Combat.EventListener:PLAYER_REGEN_DISABLED()
  combatStart = wector.Chrono.Time
end

function Combat:Update()
  Targeting.Update(self)

  if combatStart > 0 then
    Combat.TimeInCombat = wector.Chrono.Time - combatStart
  else
    Combat.TimeInCombat = 0
  end
end

function Combat:Reset()
  self.BestTarget = nil -- reset
  self.EnemiesInMeleeRange = 0
  self.Enemies = 0
  self.Incorporeals = {}
  self.Targets = {}
  self.MirrorImages = {}
  self.Totems = {}
  self.Casters = {}
  self.Draws = {}
end

function Combat:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Combat) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  return Settings.PallasAttackOOC or Me.InCombat
end

function Combat:CollectTargets()
  local flags = ObjectTypeFlag.Unit
  local units = wector.Game:GetObjectsByFlag(flags)

  if not Me.InCombat and Settings.PallasAttackOOC then
    local target = Me.Target
    if target and target:IsValidTarget() then
      table.insert(self.Targets, Me.Target)
    end
  else
    -- copy unit list
    for k, u in pairs(units) do
      self.Targets[k] = u.ToUnit
    end
  end
end

function Combat:ExclusionFilter()
  for k, u in pairs(self.Targets) do
    if not Me:CanAttack(u) then
      self.Targets[k] = nil
    elseif u.EntryId == specialUnits.incorporeal then -- Add to special units, remove from targets
      if u.IsCastingOrChanneling then
        table.insert(self.Incorporeals, u)
      end
      self.Targets[k] = nil
    elseif u.Name == "Mirror Image" and not u.DeadOrGhost then
      table.insert(self.MirrorImages, u)
      self.Targets[k] = nil
    elseif not u:InCombatWithMe() and not u:InCombatWithPartyMember() and not u:IsTrainingDummy() then
      self.Targets[k] = nil
    elseif u.DeadOrGhost or u.Health <= 0 then
      self.Targets[k] = nil
    elseif u:GetDistance(Me.ToUnit) > 40 and not Me:InMeleeRange(u) then
      self.Targets[k] = nil
    elseif u.IsTapDenied and (not u.Target or u.Target ~= Me) then
      self.Targets[k] = nil
    elseif u:IsImmune() then
      self.Targets[k] = nil
    elseif ignoreList[u.EntryId] then
      self.Targets[k] = nil
    elseif u.CreatureType == CreatureType.Totem then
      table.insert(self.Totems, u)
      self.Targets[k] = nil
    end
  end
end

function Combat:InclusionFilter()
  local target = Me.Target

  if target and (Me:GetDistance(target) < 40 or Me:InMeleeRange(target)) then
    for _, u in pairs(self.Targets) do
      if u.Guid == target.Guid then
        -- target already exists in our list
        return
      end
    end

    if not target.IsEnemy and Me:GetReaction(target) > UnitReaction.Neutral then
      return
    elseif target.DeadOrGhost or target.Health <= 0 then
      return
    elseif target:IsImmune() then
      return
    elseif ignoreList[target.EntryId] then
      return
    end

    table.insert(self.Targets, target)
    return
  end
end

function Combat:WeighFilter()
  local priorityList = {}
  for _, u in pairs(self.Targets) do
    local priority = 0

    Combat.Enemies = Combat.Enemies + 1

    if Me:InMeleeRange(u) then
      self.EnemiesInMeleeRange = self.EnemiesInMeleeRange + 1
    end

    if u:IsCastingFixed() then
      table.insert(self.Casters, u)
    end

    -- our only priority right now, current target
    if Me.Target and Me.Target == u then
      priority = priority + 50
    end

    table.insert(priorityList, { Unit = u, Priority = priority })
  end

  table.sort(priorityList, function(a, b)
    return a.Priority > b.Priority
  end)

  table.sort(self.MirrorImages, function(a, b)
    return Me:GetDistance(a) < Me:GetDistance(b)
  end)

  if #priorityList == 0 then
    return
  end

  self.BestTarget = priorityList[1].Unit

  -- If auto-target is disabled we're done here
  if not Settings.PallasAutoTarget then return end

  if not Me.Target then
    Me:SetTarget(self.BestTarget)
  elseif Me.Target.Guid ~= self.BestTarget.Guid then
    Me:SetTarget(self.BestTarget)
  end
end

---@return number deathtime seconds until all targets we are in combat with die.
function Combat:TargetsAverageDeathTime()
  local count = table.length(self.Targets)
  local seconds = 0

  if count == 0 then return 0 end

  for _, u in pairs(self.Targets) do
    local ttd = u:TimeToDeath()
    seconds = seconds + ttd
  end

  return seconds / count
end

---@return number count Amount of mobs that are within the distance you provided.
---@param dist number Range from myself to check for enemies
function Combat:GetEnemiesWithinDistance(dist, facing, angle)
  local count = 0

  for _, u in pairs(self.Targets) do
    if Me:GetDistance(u) <= dist or Me:InMeleeRange(u) and (not facing or Me:IsFacing(u, angle)) then
      count = count + 1
    end
  end

  return count
end

---@return boolean, number found returns both a boolean if it found any and how many.
---@param aura any aura id or name
---@param duration number? optional, amount of time left on the buff to consider it applied. (MS)
function Combat:CheckTargetsForAuraByMe(aura, duration)
  local count = 0
  for _, t in pairs(self.Targets) do
    local a = t:GetAuraByMe(aura)
    if a and (not duration or a.Remaining > duration) then
      count = count + 1
    end
  end

  return count > 0, count
end

---@return number targetsaround number of targets around our unit
---@param unit WoWUnit Unit to check for targets
---@param distance integer Distance from unit to check for targets
function Combat:GetTargetsAround(unit, distance)
  local count = 0

  for _, target in pairs(self.Targets) do
    if unit:GetDistance(target) <= distance then
      count = count + 1
    end
  end

  return count
end

---@return boolean True if all targets are gathered near each other, false otherwise.
---@param distance integer The distance in yards from each other that the targets have to be.
function Combat:AllTargetsGathered(distance)
  if table.length(self.Targets) <= 1 then
    return true -- If there's only one or zero targets, consider them gathered.
  end

  for _, target in pairs(self.Targets) do
    if not target.IsCastingOrChanneling then
      for _, otarget in pairs(self.Targets) do
        if target ~= otarget and (otarget:GetDistance(target) > distance and not Me:InMeleeRange(target)) then
          return false -- If any pair of targets is not gathered, return false.
        end
      end
    end
  end

  return true -- If all pairs of targets are gathered, return true.
end

return Combat
