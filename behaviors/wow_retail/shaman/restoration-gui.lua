local gui = {
  Name = "Shaman (Resto)",
  Widgets = {
    {
      type = "text",
      uid = "ShamanRestoSingle",
      text = "----------------SINGLE-TARGET-------------",
    },
    {
      type = "slider",
      uid = "ShamanRestoHealingSurge",
      text = "Healing Surge (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoHealingWave",
      text = "Healing Wave (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoRiptide",
      text = "Riptide (%)",
      default = 95,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoUnleashLife",
      text = "Unleash Life (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoHealingStreamTotem",
      text = "Healing Stream Totem (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoSpiritLinkTotem",
      text = "Spirit Link Totem (%)",
      default = 30,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "ShamanRestoAoE",
      text = "----------------A--O--E-------------------",
    },
    {
      type = "slider",
      uid = "ShamanRestoCritical",
      text = "Do Not Aoe Below (%)",
      default = 30,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoPrimordialWave",
      text = "Primordial Wave (%)",
      default = 83,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoPrimordialWaveCount",
      text = "Primordial Wave Count (#)",
      default = 3,
      min = 1,
      max = 5
    },
    {
      type = "slider",
      uid = "ShamanRestoChainHeal",
      text = "Chain Heal (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoChainHealCount",
      text = "Chain Heal Count (#)",
      default = 3,
      min = 1,
      max = 6
    },
    {
      type = "slider",
      uid = "ShamanRestoAscendance",
      text = "Ascendance (%)",
      default = 60,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoAscendanceCount",
      text = "Ascendance Count (#)",
      default = 4,
      min = 1,
      max = 10
    },
    {
      type = "slider",
      uid = "ShamanRestoHealingTideTotem",
      text = "Healing Tide Totem (%)",
      default = 70,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoHealingTideTotemCount",
      text = "Healing Tide Count (#)",
      default = 5,
      min = 1,
      max = 10
    },
    {
      type = "text",
      uid = "ShamanRestoGeneral",
      text = "----------------GENERAL-------------------",
    },
    {
      type = "slider",
      uid = "ShamanRestoOverheal",
      text = "Overheal Cancel (%)",
      default = 90,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoCancelCast",
      text = "Cancel DPS Below (%)",
      default = 60,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanRestoAstralShift",
      text = "Astral Shift (%)",
      default = 50,
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
      uid = "ShamanRestoPurge",
      text = "Purge Enemies",
      default = false
    },
    {
      type = "checkbox",
      uid = "ShamanRestoResurrect",
      text = "Resurrect Target",
      default = false
    },
    {
      type = "checkbox",
      uid = "ShamanRestoStormkeeper",
      text = "Stormkeeper on AoE",
      default = false
    },
    {
      type = "text",
      uid = "ShamanRestoMythicPlus",
      text = "----------------MYTHIC+-------------------",
    },
    {
      type = "checkbox",
      uid = "ShamanRestoIncorporeal",
      text = "Hex Incorporeal",
      default = false
    },
    {
      type = "checkbox",
      uid = "ShamanRestoAfflicted",
      text = "Dispel Afflicted",
      default = false
    },
  }
}

return gui
