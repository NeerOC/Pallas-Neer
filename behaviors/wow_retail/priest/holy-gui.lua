local gui = {
  Name = "Priest (Holy)",
  Widgets = {
    {
      type = "text",
      uid = "PriestHolySingle",
      text = "----------------SINGLE-TARGET-------------",
    },
    {
      type = "slider",
      uid = "PriestHolyTrinket1Pct",
      text = "Trinket 1 (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyTrinket2Pct",
      text = "Trinket 2 (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyStopDPS",
      text = "Cancel DPS (%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyInstantFlashHeal",
      text = "Instant Flash Heal (%)",
      default = 85,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyFlashHeal",
      text = "Flash Heal (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyLightweaveHeal",
      text = "Lightweave Heal (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyHeal",
      text = "Heal (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyWordSerenity",
      text = "HW: Serenity (%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyGuardianSpirit",
      text = "Guardian Spirit (%)",
      default = 40,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestPowerWordLife",
      text = "PW: Life (%)",
      default = 34,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyRenew",
      text = "Renew (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyPrayerOfMending",
      text = "Prayer of Mending (%)",
      default = 98,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyWordShield",
      text = "PW: Shield (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "PriestHolySingle",
      text = "----------------AOE----------------------",
    },
    {
      type = "slider",
      uid = "PriestHolyDoNotAoe",
      text = "Do Not AOE Below (%)",
      default = 30,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyCircleOfHealingCount",
      text = "Circle Of Healing (#)",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "PriestHolyCircleOfHealingPct",
      text = "Circle Of Healing (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyWordSanctifyCount",
      text = "HW: Sanctify (#)",
      default = 2,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "PriestHolyWordSanctifyPct",
      text = "HW: Sanctify (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyPrayerOfHealingCount",
      text = "Prayer Of Healing (#)",
      default = 5,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "PriestHolyPrayerOfHealingPct",
      text = "Prayer Of Healing (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PriestHolyDivineHymnCount",
      text = "Divine Hymn (#)",
      default = 4,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "PriestHolyDivineHymnPct",
      text = "Divine Hymn (%)",
      default = 60,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "PriestHolyGeneral",
      text = "----------------GENERAL-------------------",
    },
    {
      type = "slider",
      uid = "PriestDesperatePrayer",
      text = "Desperate Prayer (%)",
      default = 90,
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
      type = "checkbox",
      uid = "PriestHolyPurge",
      text = "Purge Enemies",
      default = false
    },
    {
      type = "checkbox",
      uid = "PriestHolySpreadMending",
      text = "Spread Mending on CD",
      default = false
    },
  }
}

return gui
