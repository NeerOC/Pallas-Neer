local gui = {
  Name = "Druid (Guardian)",
  Widgets = {
    {
      type = "text",
      uid = "DruidGuardianGeneral",
      text = "General",
    },
    {
      type = "slider",
      uid = "CommonInterruptPct",
      text = "Kick Cast Left (%)",
      default = 40,
      min = 0,
      max = 100
    },
    {
      type = "combobox",
      uid = "CommonInterrupts",
      text = "Interrupt",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
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
      uid = "DruidMotw",
      text = "Mark of The Wild",
      default = false
    },
    {
      type = "checkbox",
      uid = "DruidAutoTaunt",
      text = "Auto Taunt",
      default = false
    },
    {
      type = "checkbox",
      uid = "DruidGuardianSpamFrenized",
      text = "Spam Frenzied Regeneration",
      default = false
    },
    {
      type = "text",
      uid = "DruidGuardianDefensives",
      text = "Defensives",
    },
    {
      type = "slider",
      uid = "GuardianBarkskinPct",
      text = "Barkskin (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "GuardianFR2Pct",
      text = "Frenzied Regeneration 2 Charge (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "GuardianFR1Pct",
      text = "Frenzied Regeneration 1 Charge (%)",
      default = 50,
      min = 0,
      max = 100
    },
  }
}

return gui
