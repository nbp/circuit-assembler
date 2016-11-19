local function print(event, msg)
  if game ~= nil then
    for _,player in pairs(game.players) do
      player.print(msg)
    end
  end
end

--swap comment to toggle debug prints
local function debug() end
--local debug = print

-- When some research is completed, build the reverse index of the crafting table
-- to find the best recipes.  This assumes that the best recipe is registered the last.
function initRecipeForForce(force)
  local recipes = reverse_recipes[force.name]
  if recipes == nil then
    reverse_recipes[force.name] = {}
    recipes = reverse_recipes[force.name]
  end
  for name,recipe in pairs(force.recipes) do
    if recipe.valid and recipe.enabled then
      for _,product in pairs(recipe.products) do
         recipes[product.name] = recipe
      end
    end
  end
end

function initRecipeLookupTable()
  if not global.reverseRecipes then
    global.reverseRecipes = {}
  end
  reverse_recipes = global.reverseRecipes
end

script.on_event(defines.events.on_research_finished, function(event)
  initRecipeForForce(event.research.force)
end)
script.on_event(defines.events.on_force_created,function(event)
  initRecipeForForce(event.force)
end)
script.on_event(defines.events.on_forces_merging,function(event)
  -- TODO: remove event.source from the list.
  initRecipeForForce(event.destination)
end)

-- When loaded, initialize the global index variable.
-- The circuit_assemblers variables serves as a cache for the indexes of entites to look after.
function onLoad()
  if not global.assemblerCommandors then
    global.assemblerCommandors = {}
  end
  assembler_commandors = global.assemblerCommandors

  initRecipeLookupTable()
end

script.on_init(onLoad)
script.on_load(onLoad)

---- When entities are created or removed, update the global index.
function onCreatedEntity(event)
  local entity = event.created_entity
  if entity.name == "assembler-commandor" then
    table.insert(assembler_commandors, entity)
    entity.get_or_create_control_behavior()
  end
end

function onRemovedEntity(event)
  local entity = event.entity
  if entity.name == "assembler-commandor" then
    for i,v in ipairs(assembler_commandors) do
      if v == entity then
        table.remove(assembler_commandors, i)
        break
      end
    end
  end
end

script.on_event(defines.events.on_built_entity, onCreatedEntity)
script.on_event(defines.events.on_robot_built_entity, onCreatedEntity)

script.on_event(defines.events.on_preplayer_mined_item, onRemovedEntity)
script.on_event(defines.events.on_robot_pre_mined, onRemovedEntity)
script.on_event(defines.events.on_entity_died, onRemovedEntity)

---- On each tick, check the wire inputs and update the assembling machine if needed.
--[[
-- Compute the input of a combinator.
function getNetworkInputs(cb)
  local red = cb.get_circuit_network(defines.wire_type.red)
  local green = cb.get_circuit_network(defines.wire_type.green)
  local slot_index = 0
  local inputs = { item = {}, virtual = {}, fluid = {} }
  -- sum both red & green wires, and filter items.
  if red ~= nil and red.valid then
    for _,s in pairs(red.signals) do
      inputs[s.signal.type][s.signal.name] = s.count
    end
  end
  if green ~= nil and green.valid then
    for _,s in pairs(green.signals) do
      local inputs_t = inputs[s.signal.type]
      inputs_t[s.signal.name] = (inputs_t[s.signal.name] or 0) + s.count
    end
  end
  return inputs
end

-- Evaluate the condition of the combinator.
function evaluationCondition(cb, cond)
  local inputs = getNetworkItemInputs(cb)
  return inputs["rail-chain-signal"] > 0 -- For testing
end
--]]

function onTick(event)
  -- Update the assemblers based on the inputs of the assembler commandors.
  for _,entity in ipairs(assembler_commandors) do
    local cb = entity.get_or_create_control_behavior()
    local assembler = entity.pickup_target
    if cb == nil or not cb.valid or assembler == nil or not assembler.valid or assembler.type ~= "assembling-machine" then
      -- do nothing
    elseif cb.circuit_mode_of_operation == defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable then
      -- Disabled for the moment.
      --[[
      -- enable / disable the assembler based on circuit / logistic network conditions.
      local active = not evaluationCondition(cb, nil)
      if assembler.active ~= active then
        assembler.active = active
      end
      --]]
    elseif cb.circuit_mode_of_operation == defines.control_behavior.inserter.circuit_mode_of_operation.set_filters then
      -- Set the recipe based on the current signal sent to the network.
      local item = entity.get_filter(1)
      local recipe = reverse_recipes[assembler.force.name]
      if assembler.recipe ~= recipe[item] then
        assembler.recipe = recipe[item]
      end
    end
  end
end

script.on_event(defines.events.on_tick, onTick)
