local gui = {
  Name = "Paladin (Holy)",
  Widgets = {
    {
      type = "slider",
      uid = "HolyLightAmt",
      text = "Holy Light Amount",
      default = 6000,
      min = 0,
      max = 20000
    },
    {
      type = "slider",
      uid = "FlashOfLightAmt",
      text = "Flash of Light Amount",
      default = 1500,
      min = 0,
      max = 10000
    },
    {
      type = "slider",
      uid = "HolyShockAmt",
      text = "Holy Shock Amount",
      default = 1500,
      min = 0,
      max = 10000
    },
    {
      type = "slider",
      uid = "HandOfProtectionPct",
      text = "Hand of Protection Threshold (%)",
      default = 25,
      min = 0,
      max = 99
    },
    {
      type = "slider",
      uid = "LayOnHandsPct",
      text = "Lay on Hands Threshold (%)",
      default = 10,
      min = 0,
      max = 99
    },
    {
      type = "slider",
      uid = "HandOfSacrificePct",
      text = "Hand of Sacrifice Threshold Focus (%)",
      default = 70,
      min = 0,
      max = 99
    },
    {
      type = "slider",
      uid = "DPSManaPct",
      text = "DPS Above Mana Threshold (%)",
      default = 70,
      min = 0,
      max = 99
    },
    {
      type = "checkbox",
      uid = "HolySalvation",
      text = "Hand of Salvation on Aggro",
      default = true
    },
    {
      type = "checkbox",
      uid = "HolyFreedom",
      text = "Hand of Freedom rooted",
      default = true
    },
    {
      type = "checkbox",
      uid = "AlwaysGrace",
      text = "Always Grace",
      default = true
    },
    {
      type = "checkbox",
      uid = "HolyDPSToggle",
      text = "DPS",
      default = true
    },
    {
      type = "text",
      uid = "PaladinGeneral",
      text = ">> General <<",
    },
    {
      type = "slider",
      uid = "PleaPct",
      text = "Divine Plea Below %",
      default = 85,
      min = 0,
      max = 99
    },
    {
      type = "combobox",
      uid = "PaladinJudge",
      text = "Select Judgement",
      default = 0,
      options = { "Judgement of Wisdom", "Judgement of Light", "Judgement of Justice" }
    },
    {
      type = "combobox",
      uid = "PaladinSeal",
      text = "Select Seal",
      default = 0,
      options = { "Seal of Wisdom", "Seal of Light", "Seal of Righteousness", "Seal of Corruption",
        "Seal of Justice", "Seal of Command" }
    },
    {
      type = "combobox",
      uid = "PaladinBuff",
      text = "Select Self Buff",
      default = 0,
      options = { "Blessing of Wisdom", "Blessing of Kings", "Blessing of Might", "Blessing of Sanctuary" }
    },
    {
      type = "combobox",
      uid = "PaladinAura",
      text = "Select Aura",
      default = 2,
      options = { "Devotion Aura", "Retribution Aura", "Concentration Aura", "Shadow Res Aura", "Frost Res Aura",
        "Fire Res Aura" }
    },
    {
      type = "combobox",
      uid = "CommonDispels",
      text = "Dispel",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    },
    {
      type = "checkbox",
      uid = "Blessings",
      text = "Auto Bless Companions",
      default = true
    },
    {
      type = "checkbox",
      uid = "Crusader",
      text = "Auto Crusader Aura",
      default = true
    },
  }
}

return gui
