local gui = {
  -- The sub menu name
  Name = "Monk (Brewmaster)",
  -- widgets
  Widgets = {
    {
      type = "text",
      uid = "MonkBrewmasterDefensivesText",
      text = ">> Defensives <<",
    },
    {
      type = "slider",
      uid = "BrewmasterExpelharmPct",
      text = "Expel Harm (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "MonkBrewmasterGeneralText",
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
  }
}

return gui
