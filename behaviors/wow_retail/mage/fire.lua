local gui = require("behaviors.wow_Retail.mage.fire-gui")

local function MageFireCombat()
end

local behaviors = {
  [BehaviorType.Combat] = MageFireCombat,
}

return { Options = gui, Behaviors = behaviors }
