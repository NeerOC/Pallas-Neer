local gui = {
  Name = "Druid (Resto)",
  Widgets = {
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
