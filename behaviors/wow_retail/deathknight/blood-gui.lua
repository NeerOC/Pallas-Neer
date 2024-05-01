local gui = {
  Name = "Death Knight (Blood)",
  Widgets = {
    {
      type = "text",
      uid = "DKBloodGeneral",
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
