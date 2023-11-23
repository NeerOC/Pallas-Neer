local gui = {
  -- The sub menu name
  Name = "Monk (Mistweaver)",
  -- widgets
  Widgets = {
    {
      type = "text",
      uid = "MonkMistweaverSingleText",
      text = ">> Single Target <<",
    },
    {
      type = "slider",
      uid = "MistweaverTrinket1Pct",
      text = "Trinket 1 (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverTrinket2Pct",
      text = "Trinket 2 (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverVivifyPct",
      text = "Vivify (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverEnvelopingMistPct",
      text = "Enveloping Mist (%)",
      default = 60,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverZenPulsePct",
      text = "Zen Pulse (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverSoothingMistPct",
      text = "Soothing Mist (%)",
      default = 60,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverLifeCocoonPct",
      text = "Life Cocoon (%)",
      default = 25,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "MonkMistweaverAoEText",
      text = ">> A o E <<",
    },
    {
      type = "slider",
      uid = "MistweaverDoNotAoePct",
      text = "Do Not AOE Below (%)",
      default = 30,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverSheilunPct",
      text = "Sheilun (%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverSheilunCount",
      text = "Sheilun (#)",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "MistweaverRevivalPct",
      text = "Revival (%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverRevivalCount",
      text = "Revival (#)",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "MistweaverEssenceFontPct",
      text = "Essence Font (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MistweaverEssenceFontCount",
      text = "Essence Font (#)",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "text",
      uid = "MonkMistweaverDefensivesText",
      text = ">> Defensives <<",
    },
    {
      type = "slider",
      uid = "MistweaverExpelharmPct",
      text = "Expel Harm (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "MistweaverGeneralText",
      text = ">> General <<",
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
  }
}

return gui
