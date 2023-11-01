local commonPaladin = {}

commonPaladin.widgets = {

}

function commonPaladin:Blessings()
  if not Settings.Blessings then return end

  local classBlessings = {
    [ClassType.Rogue] = { Spell.BlessingOfKings, Spell.BlessingOfMight },
    [ClassType.Warrior] = { Spell.BlessingOfKings },
    [ClassType.DeathKnight] = { Spell.BlessingOfKings, Spell.BlessingOfMight },
    [ClassType.Druid] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
    [ClassType.Hunter] = { Spell.BlessingOfKings, Spell.BlessingOfMight },
    [ClassType.Mage] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
    [ClassType.Shaman] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
    [ClassType.Warlock] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
    [ClassType.Priest] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
    [ClassType.Paladin] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom }
  }

  for _, member in ipairs(Heal.Friends.All) do
    local isBuffedByMe = member:HasBuffByMe(Spell.BlessingOfKings.Name) or
        member:HasBuffByMe(Spell.BlessingOfWisdom.Name) or member:HasBuffByMe(Spell.BlessingOfMight.Name)
    local class = member.Class
    local blessings = classBlessings[class]

    for _, blessing in ipairs(blessings) do
      if not isBuffedByMe and not member:HasAura(blessing.Name) and blessing:CastEx(member) then
        return
      end
    end
  end
end

function commonPaladin:DivinePlea()
  return Me.PowerPct <= Settings.PleaPct and Spell.DivinePlea:CastEx(Me)
end

function commonPaladin:HolyWrath()
  for _, u in pairs(Combat.Targets) do
    local correctType = u.CreatureType == CreatureType.Undead and not u.Dead and u.isAttackable
    if correctType and Me:GetDistance(u) < 8 and Spell.HolyWrath:CastEx(u) then return end
  end
end

function commonPaladin:HammerOfWrath()
  for _, u in pairs(Combat.Targets) do
    if Me:IsFacing(u) and u.HealthPct < 20 and Spell.HammerOfWrath:CastEx(u, SpellCastExFlags.NoUsable) then return end
  end
end

function commonPaladin:Judgement(target)
  local spells = { Spell.JudgementOfWisdom, Spell.JudgementOfLight, Spell.JudgementOfJustice }
  local option = Settings.PaladinJudge
  return spells[option + 1]:CastEx(target)
end

function commonPaladin:DoAura()
  if Settings.Crusader and Me.IsMounted then
    return Spell.CrusaderAura:Apply(Me)
  end


  local options = { Spell.DevotionAura, Spell.RetributionAura, Spell.ConcentrationAura, Spell.ShadowResistanceAura,
    Spell.FrostResistanceAura, Spell.FireResistanceAura }
  local option = Settings.PaladinAura
  local aura = options[math.min(option + 1, #options)] or options[1]

  return not Me:HasAura(aura.Name) and aura:Apply(Me)
end

function commonPaladin:DoSeal()
  local seals = { Spell.SealOfWisdom, Spell.SealOfLight, Spell.SealOfRighteousness, Spell.SealOfCorruption,
    Spell.SealOfJustice, Spell.SealOfCommand }
  local option = Settings.PaladinSeal
  local seal = seals[math.min(option + 1, #seals)] or Spell.SealOfWisdom

  return seal:Apply(Me)
end

function commonPaladin:DoBuff()
  local spells = { Spell.BlessingOfWisdom, Spell.BlessingOfKings, Spell.BlessingOfMight, Spell.BlessingOfSanctuary }
  local option = Settings.PaladinBuff
  local buff = spells[math.min(option + 1, #spells)]

  return buff:Apply(Me)
end

function commonPaladin:DoRF()
  return Spell.RighteousFury:Apply(Me)
end

return commonPaladin
