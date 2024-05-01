local gui = {
  Name = "Rogue (Outlaw)",
  Widgets = {
    {
      type = "text",
      uid = "RogueOutlawGeneral",
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
      type = "checkbox",
      uid = "RogueOutlawCheapInterrupt",
      text = "Interrupt with Cheap Shot",
      default = false
    },
    {
      type = "checkbox",
      uid = "RogueOutlawKidneyInterrupt",
      text = "Interrupt with Kidney Shot",
      default = false
    },
    {
      type = "checkbox",
      uid = "RogueOutlawVanish",
      text = "Vanish",
      default = false
    },
    {
      type = "checkbox",
      uid = "RogueOutlawStunlock",
      text = "Stunlock M+",
      default = false
    },
  }
}

return gui
