local gui = {
  Name = "Priest (Disc)",
  Widgets = {
    {
      type = "text",
      uid = "PriestDiscGeneral",
      text = ">> General <<",
    },
    {
      type = "slider",
      uid = "PriestDiscTrinket1Pct",
      text = "Trinket 1 (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestDiscTrinket2Pct",
      text = "Trinket 2 (%)",
      default = 70,
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
  }
}

return gui
