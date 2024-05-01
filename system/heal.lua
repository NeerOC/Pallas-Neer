---@diagnostic disable: param-type-mismatch
Heal = Heal or Targeting:New()

---@type table<WoWUnit[], number>
Heal.PriorityList = {}

---@type table<string, WoWUnit[]>
Heal.Friends = {
  Tanks = {},
  DPS = {},
  Healers = {},
  All = {}
}

---@type table<WoWUnit[]>
Heal.Afflicted = {}

function Heal:Update()
  Targeting.Update(self)
end

function Heal:Reset()
  self.PriorityList = {}
  self.Friends = {
    Tanks = {},
    DPS = {},
    Healers = {},
    All = {}
  }
  self.HealTargets = {}
  self.Afflicted = {}
end

function Heal:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Heal) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end
  if Me:HasAura("Preparation") then return false end
  return true
end

function Heal:CollectTargets()
  local flags = ObjectTypeFlag.Unit | ObjectTypeFlag.Player | ObjectTypeFlag.ActivePlayer
  local units = wector.Game:GetObjectsByFlag(flags)

  -- copy unit list
  for k, u in pairs(units) do
    self.HealTargets[k] = u.ToUnit
  end
end

local specialUnits = {
  afflicted = 204773 -- Afflicted Soul, M+ Affix, heal to full or dispel.
}

function Heal:ExclusionFilter()
  for k, u in pairs(self.HealTargets) do

    if u.EntryId == specialUnits.afflicted then
      table.insert(self.Afflicted, u)
      self.HealTargets[k] = nil
    end

    if Me:CanAttack(u) then
      self.HealTargets[k] = nil
    elseif u.DeadOrGhost or u.Health <= 1 then
      self.HealTargets[k] = nil
    elseif Me:GetDistance(u) > 40 then
      self.HealTargets[k] = nil
    elseif u:IsHealImmune() then
      self.HealTargets[k] = nil
    end
  end
end

function Heal:InclusionFilter()
end

local healUnits = {
  [208459] = true, -- Treants amird
  [204449] = true, -- chromie
}

function Heal:WeighFilter()
  local manaMulti = 30
  local group = WoWGroup(GroupType.Auto)
  local target = Me.Target

  for _, u in pairs(self.HealTargets) do
    local priority = 0
    local istank = false
    local isdps = false
    local isheal = false

    local healUnit = healUnits[u.EntryId]
    local member = group:GetMemberByGuid(u.Guid)
    if not member and Me.Guid ~= u.Guid and target ~= u and not healUnit then goto continue end

    if target and target == u then
      priority = priority + 20
    end

    if healUnit then
      priority = priority + 30
    end

    if member then
      if member.Role & GroupRole.Tank == GroupRole.Tank then
        if u.Class ~= ClassType.DeathKnight then
          priority = priority + 20
        end
        istank = true
      end

      if member.Role & GroupRole.Healer == GroupRole.Healer then
        priority = priority + 15
        isheal = true
      end

      if member.Role & GroupRole.Damage == GroupRole.Damage then
        priority = priority + 5
        isdps = true
      end
    end

    priority = priority + (100 - u.HealthPct)
    priority = priority - ((100 - Me.PowerPct) * (manaMulti / 100))

    if priority > 0 or u.InCombat then
      table.insert(self.PriorityList, { Unit = u, Priority = priority })
    end

    if istank then
      table.insert(self.Friends.Tanks, u)
    elseif isdps then
      table.insert(self.Friends.DPS, u)
    elseif isheal then
      table.insert(self.Friends.Healers, u)
    end

    table.insert(self.Friends.All, u)

    ::continue::
  end

  table.sort(self.PriorityList, function(a, b)
    return a.Priority > b.Priority
  end)
end

---@return WoWUnit
function Heal:GetLowestMember()
  return Heal.PriorityList[1] and Heal.PriorityList[1].Unit
end

---@return WoWUnit[], integer Members below health percentage
---@param pct integer Health percentage to check
function Heal:GetMembersBelow(pct)
  local count = 0
  local members = {}

  for _, v in pairs(Heal.PriorityList) do
    local u = v.Unit
    if u.HealthPct < pct then
      table.insert(members, u)
      count = count + 1
    end
  end

  return members, count
end

---@param threshold? integer check if unit is below health (Optional)
---@param friend WoWUnit Unit to check around
---@param dist integer Distance from unit to check
function Heal:GetMembersAround(friend, dist, threshold)
  local count = 0
  local members = {}

  threshold = threshold or 100

  for _, v in pairs(self.PriorityList) do
    local f = v.Unit
    if friend ~= f and friend:GetDistance(f) <= dist and f.HealthPct < threshold then
      count = count + 1
      table.insert(members, f)
    end
  end

  return count, members
end

return Heal
