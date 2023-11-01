local gui = {
  Name = "Paladin (Holy)",
  Widgets = {
    {
      type = "text",
      uid = "PaladinHolySingle",
      text = "----------------SINGLE-TARGET-------------",
    },
    {
      type = "slider",
      uid = "PaladinHolyLayOnhands",
      text = "Lay On Hands (%)",
      default = 15,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyBlessingOfSacrifice",
      text = "Blessing of Sacrifice (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyWordOfGlory",
      text = "Word of Glory (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyFlashOfLight",
      text = "Flash Of Light (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHolyLight",
      text = "Holy Light (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHolyShock",
      text = "Holy Shock (%)",
      default = 85,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHOPPct",
      text = "Hand Of Protection (%)",
      default = 25,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHolyPrismPct",
      text = "Holy Prism (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHandOfDivinity",
      text = "Hand of Divinity (%)",
      default = 60,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "PaladinHolyAoE",
      text = "----------------AOE-------------------",
    },
    {
      type = "slider",
      uid = "PaladinHolyCritical",
      text = "Do Not Aoe Below (%)",
      default = 30,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHolyDawnPct",
      text = "Light of Dawn (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyHolyDawnCount",
      text = "Light of Dawn (#)",
      default = 2,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "PaladinHolyDivineTollPct",
      text = "Divine Toll (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyDivineTollCount",
      text = "Divine Toll (#)",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "text",
      uid = "PaladinHolyDefensives",
      text = "----------------DEFENSIVES-------------------",
    },
    {
      type = "slider",
      uid = "PaladinHolyDivineProtection",
      text = "Divine Protection (%)",
      default = 83,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinHolyDivineShield",
      text = "Divine Shield (%)",
      default = 25,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "PaladinHolyGeneral",
      text = "----------------GENERAL-------------------",
    },
    {
      type = "slider",
      uid = "PaladinHolyOverheal",
      text = "Overheal Cancel (%)",
      default = 90,
      min = 0,
      max = 100
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
      uid = "CommonDispels",
      text = "Dispel",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    },
    {
      type = "combobox",
      uid = "CommonInterrupts",
      text = "Interrupt",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    },
    {
      type = "checkbox",
      uid = "PaladinHolyResurrect",
      text = "Resurrect Friends",
      default = false
    },
    {
      type = "checkbox",
      uid = "PaladinHolyGlimmer",
      text = "Glimmer Everyone",
      default = false
    },
  }
}

return gui
