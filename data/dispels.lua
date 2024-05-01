---@enum DispelPriority
DispelPriority = {
  None = 0,
  Low = 1,
  Medium = 2,
  High = 3,
  Critical = 4,
}

local dispels = {
  -- Ahn'kahet: The Old Kingdom
  [56728] = DispelPriority.Low, -- Eye in the Dark (OK)
  [59108] = DispelPriority.Low, -- Glutinous Poison (OK)
  [56708] = DispelPriority.Low, -- Contagion of Rot (OK)
  [59467] = DispelPriority.Low, -- Disease shit
  [57061] = DispelPriority.Low, -- Poison Shit
  -- Azjol-Nerub
  -- The Culling of Stratholme
  -- Drak'Tharon Keep
  -- Gundrak
  -- Halls of Stone
  [50761] = DispelPriority.Low, -- Pillar of Woe (HOS)
  -- Halls of Lightning
  -- The Nexus
  [56860] = DispelPriority.Low, -- Magic burn
  [47731] = DispelPriority.Low, -- Polymorph
  [57063] = DispelPriority.Low, -- Arcane atraction
  [57050] = DispelPriority.Low, -- Crystal Chains
  [48179] = DispelPriority.Low, -- Crystalize
  [57091] = DispelPriority.Low, -- Crystalfire Breath
  -- The Oculus
  [59261] = DispelPriority.Low, -- Water Tomb
  [59371] = DispelPriority.Low, -- Amp Magic
  -- The Violet Hold
  -- Utgarde Keep
  -- Utgarde Pinnacle
  -- Pit Of Saron
  [69603] = DispelPriority.Low, -- Blight
  [34779] = DispelPriority.Low, -- Freezing Circle
  -- Forge of souls
  [69131] = DispelPriority.Low, -- Lethargy
  -- Halls of reflection
  [72333] = DispelPriority.Low, -- Envenom
  [72426] = DispelPriority.Low, -- Lethargy
  [72329] = DispelPriority.Low, -- Poison shit
  [72321] = DispelPriority.Low, -- Cower

  -- Unsorted
  [59168] = DispelPriority.Low,  -- Light shock
  [59178] = DispelPriority.Low,  -- Poison Spear in HOL
  [58967] = DispelPriority.Low,  -- Poison Spear
  [13323] = DispelPriority.Low,  -- Polymorph
  [59237] = DispelPriority.Low,  -- Hunters mark
  [59271] = DispelPriority.Low,  -- Poison breath
  [59334] = DispelPriority.Low,  -- Poison Spear
  [49106] = DispelPriority.Low,  -- Fear
  [59300] = DispelPriority.Low,  -- Fetid Rot
  [67710] = DispelPriority.Low,  -- -- Poison
  [34942] = DispelPriority.Low,  -- Swp
  [66619] = DispelPriority.Low,  -- Shadows of past
  [66538] = DispelPriority.Low,  -- Holy fire
  [59348] = DispelPriority.Low,  -- Phys 50%
  [59417] = DispelPriority.Low,  -- Leech
  [59352] = DispelPriority.Low,  -- Giga magic amp
  [59397] = DispelPriority.Low,  -- Ex
  [42702] = DispelPriority.Low,  -- Ex
  [72171] = DispelPriority.Low,  -- Trap
  [70176] = DispelPriority.Low,  -- Damage +20%
  [54462] = DispelPriority.Low,  -- Screech
  [59374] = DispelPriority.Low,  -- Ex
  [59281] = DispelPriority.Low,  -- Ex
  [56777] = DispelPriority.Low,  -- Silence
  [47779] = DispelPriority.Low,  -- Silence
  [30849] = DispelPriority.Low,  -- ex
  [30633] = DispelPriority.Low,  -- Thunderclap
  [56776] = DispelPriority.Low,  -- ex
  [69527] = DispelPriority.Low,  -- Breath
  [69581] = DispelPriority.Low,  -- Poison shit
  [69583] = DispelPriority.Low,  -- Fireball
  [72318] = DispelPriority.Low,  -- Swp
  [72422] = DispelPriority.Low,  -- Dodge chance shit
  [59727] = DispelPriority.Low,  -- Sorrow
  [59868] = DispelPriority.Low,  -- Ex
  [59845] = DispelPriority.Low,  -- Elec
  [59846] = DispelPriority.Low,  -- Elec
  [59849] = DispelPriority.Low,  -- Debuff
  [59470] = DispelPriority.Low,  -- Fire shit
  [32330] = DispelPriority.Low,  -- Ex
  [51240] = DispelPriority.Low,  -- Ex
  [38047] = DispelPriority.Low,  -- Ex
  [59364] = DispelPriority.Low,  -- Bite 30%
  [394608] = DispelPriority.Low, -- Infect
  [58782] = DispelPriority.Low,  -- Hp drain
  [58810] = DispelPriority.Low,
  [59019] = DispelPriority.Low,  -- Poison
  [66863] = DispelPriority.Low,  -- Hammer
  [66940] = DispelPriority.Low,  -- Another hammer
  [59746] = DispelPriority.Low,  -- Heal debuff
  [59359] = DispelPriority.Low,  -- Poison sit
  [56785] = DispelPriority.Low,  -- Disease
  [70426] = DispelPriority.Low, -- Disease ICC
  [70409] = DispelPriority.Low, -- Fireball ICC
  [70408] = DispelPriority.Low, -- Amplify ICC

  -- Dragonflight --

  -- Atal'Dazar
  [255814] = DispelPriority.Low, -- Rending Maul
  [250096] = DispelPriority.Low, -- Wracking Pain
  [250372] = DispelPriority.Low, -- Lingering Nausea
  [253562] = DispelPriority.Low, -- Wildfire
  [255371] = DispelPriority.Low, -- Terrifying Visage
  [255041] = DispelPriority.Low, -- Terrifying Screech
  [255582] = DispelPriority.Low, -- Molten Gold
  [252687] = DispelPriority.Low, -- Venomfang Strike
  [257483] = DispelPriority.Low, -- Pile Of Bones

  -- Black Rook Hold
  [225963] = DispelPriority.Low, -- Bloodthirsty Leap
  [197546] = DispelPriority.Low, -- Brutal Glaive
  [200084] = DispelPriority.Low, -- Soul Blade
  [194960] = DispelPriority.Low, -- Soul Echoes

  -- Darkheart Thicket
  [196376] = DispelPriority.Low, -- Grievous Tear
  [225484] = DispelPriority.Low, -- Grievous Rip
  [201839] = DispelPriority.Low, -- Curse Of Isolation
  [201365] = DispelPriority.Low, -- Darksoul Drain
  [200642] = DispelPriority.Low, -- Despair
  [204246] = DispelPriority.Low, -- Tormenting Fear
  [200182] = DispelPriority.Low, -- Festering Rip
  [201902] = DispelPriority.Low, -- Scorching Shot
  [200684] = DispelPriority.Low, -- Nightmare Toxin

  -- DOTI: Lower
  [412285] = DispelPriority.Low, -- Stonebolt
  [412044] = DispelPriority.Low, -- Temposlice
  [413547] = DispelPriority.Low, -- Bloom
  [416716] = DispelPriority.Low, -- Sheared Lifespan
  [411994] = DispelPriority.Low, -- Chronomelt

  -- DOTI: Upper
  [418009] = DispelPriority.Low, -- Serrated Arrows
  [407120] = DispelPriority.Low, -- Serrated Axe
  [416258] = DispelPriority.Low, -- Stonebolt
  [407313] = DispelPriority.Low, -- Shrapnel
  [412505] = DispelPriority.Low, -- Rending Cleave
  [411700] = DispelPriority.Low, -- Slobbering Bite
  [413618] = DispelPriority.Low, -- Timeless Curse
  [411644] = DispelPriority.Low, -- Soggy Bonk
  [412131] = DispelPriority.Low, -- Orb Of Contemplation
  [413606] = DispelPriority.Low, -- Corroding Volley
  [400681] = DispelPriority.Low, -- Spark Of Tyr
  [418200] = DispelPriority.Low, -- Infinite Burn
  [401667] = DispelPriority.Low, -- Time Stasis
  [417030] = DispelPriority.Low, -- Fireball
  [412027] = DispelPriority.Low, -- Chronal Burn
  [412378] = DispelPriority.Low, -- Dizzying Sands
  [407121] = DispelPriority.Low, -- Immolate

  -- Everbloom
  [428084] = DispelPriority.Low, -- Glacial Fusion
  [164965] = DispelPriority.Low, -- Choking Vines
  [169839] = DispelPriority.Low, -- Pyroblast
  [426849] = DispelPriority.Low, -- Cold Fusion
  [165123] = DispelPriority.Low, -- Venom Burst
  [169658] = DispelPriority.Low, -- Poisonous Claws
  [427460] = DispelPriority.Low, -- Toxic Bloom
  [164886] = DispelPriority.Low, -- Dreadpetal Pollen
  [426500] = DispelPriority.Low, -- Gnarled Roots

  -- Throne of the Tides
  [76820] = DispelPriority.Low, -- Hex
  [76363] = DispelPriority.Low, -- Wave Of Corruption
  [75992] = DispelPriority.Low, -- Lightning Surge
  [429048] = DispelPriority.Low, -- Flame Shock
  [428103] = DispelPriority.Low, -- Frostbolt
  [76516] = DispelPriority.Low, -- Poisoned Spear

  -- Waycrest Manor
  [271178] = DispelPriority.Low, -- Ravaging Leap
  [260741] = DispelPriority.Low, -- Jagged Nettles
  [264556] = DispelPriority.Low, -- Tearing Strike
  [260703] = DispelPriority.Low, -- Unstable Runic Mark
  [264105] = DispelPriority.Low, -- Runic Mark
  [265880] = DispelPriority.Low, -- Dread Mark
  [264050] = DispelPriority.Low, -- Infected Thorn
  [265881] = DispelPriority.Low, -- Decaying Touch
  [264378] = DispelPriority.Low, -- Fragment Soul
  [264390] = DispelPriority.Low, -- Spellbind
  [264407] = DispelPriority.Low, -- Horrific Visage
  [264520] = DispelPriority.Low, -- Severing Serpent

  -- Vortex pinnacle
  [410997] = DispelPriority.Low, -- Rushing Wind

  -- The Azure Vault
  [384978] = DispelPriority.Low,  -- Dragon Strike
  [389443] = DispelPriority.Low,  -- Purifying Blast
  [385963] = DispelPriority.Low,  -- Frost Shock
  [269301] = DispelPriority.Low,  -- Putrid Blood
  -- ***** MYTHIC+ Affix Stuff *****
  [409465] = DispelPriority.High, -- Cursed Spirit
  [409470] = DispelPriority.High, -- Poisoned Spirit
  [409472] = DispelPriority.High, -- Diseased Spirit
  -- ***** PVP *****
  -- PURGE
  [1022] = DispelPriority.High,     -- Paladin - Blessing of Protection
  [1044] = DispelPriority.Medium,   -- Paladin - Blessing of Freedom
  [383648] = DispelPriority.High,   -- Shaman - Earth Shield
  [21562] = DispelPriority.Low,     -- Priest - Powerword Fortitude
  [17] = DispelPriority.Medium,     -- Priest - Powerword Shield
  [11426] = DispelPriority.High,    -- Mage - Ice Barrier
  -- FRIEND DISPEL
  [358385] = DispelPriority.Medium, -- Evoker - Land Slide
  [217832] = DispelPriority.High,   -- Demon Hunter - Imprison
  [339] = DispelPriority.Medium,    -- Druid - Entangling Roots
  [2637] = DispelPriority.High,     -- Druid - Hibernate
  [102359] = DispelPriority.High,   -- Druid - Mass Entanglement
  [467] = DispelPriority.High,      -- Druid - Thorns
  [209790] = DispelPriority.High,   -- Hunter - Freezing Arrow
  [3355] = DispelPriority.High,     -- Hunter - Freezing Trap
  [19386] = DispelPriority.High,    -- Hunter - Wyvern Sting
  [31661] = DispelPriority.Medium,  -- Mage - Dragon's Breath
  [122] = DispelPriority.Medium,    -- Mage - Frost Nova
  [61305] = DispelPriority.High,    -- Mage - Polymorph (Cat)
  [161354] = DispelPriority.High,   -- Mage - Polymorph (Monkey)
  [161355] = DispelPriority.High,   -- Mage - Polymorph (Penguin)
  [28272] = DispelPriority.High,    -- Mage - Polymorph (Pig)
  [161353] = DispelPriority.High,   -- Mage - Polymorph (Polar Bear)
  [126819] = DispelPriority.High,   -- Mage - Polymorph (Porcupine)
  [61721] = DispelPriority.High,    -- Mage - Polymorph (Rabbit)
  [118] = DispelPriority.High,      -- Mage - Polymorph (Sheep)
  [61780] = DispelPriority.High,    -- Mage - Polymorph (Turkey)
  [28271] = DispelPriority.High,    -- Mage - Polymorph (Turtle)
  [20066] = DispelPriority.High,    -- Paladin - Repentance
  [853] = DispelPriority.High,      -- Paladin - Hammer of Justice
  [8122] = DispelPriority.High,     -- Priest - Psychic Scream
  [9484] = DispelPriority.Medium,   -- Priest - Shackle Undead
  [375901] = DispelPriority.High,   -- Priest - Mindgames
  [64695] = DispelPriority.Medium,  -- Shaman - Earthgrab Totem
  [211015] = DispelPriority.High,   -- Shaman - Hex (Cockroach)
  [210873] = DispelPriority.High,   -- Shaman - Hex (Compy)
  [51514] = DispelPriority.High,    -- Shaman - Hex (Frog)
  [211010] = DispelPriority.High,   -- Shaman - Hex (Snake)
  [211004] = DispelPriority.High,   -- Shaman - Hex (Spider)
  [196942] = DispelPriority.High,   -- Shaman - Voodoo Totem: Hex
  [118699] = DispelPriority.High,   -- Warlock - Fear
  [5484] = DispelPriority.Medium,   -- Warlock - Howl of Terror
  [710] = DispelPriority.Medium,    -- Warlock - Banish
}

return dispels
