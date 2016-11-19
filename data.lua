-- Add a new entity, item, and recipe into the game,
-- such that we set a recipe from the circuit network.

local assembler_commandor_e = {
  type = "inserter", -- We use an inserter such that we can find the position of the assembling machine.
  name = "assembler-commandor",
  icon = "__base__/graphics/icons/stack-filter-inserter.png",
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "assembler-commandor"},
  max_health = 40,
  corpse = "small-remnants",
  resistances =
  {
    {
      type = "fire",
      percent = 90
    }
  },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  working_sound =
  {
    match_progress_to_activity = true,
    sound =
    {
      {
        filename = "__base__/sound/inserter-fast-1.ogg",
        volume = 0.75
      },
      {
        filename = "__base__/sound/inserter-fast-2.ogg",
        volume = 0.75
      },
      {
        filename = "__base__/sound/inserter-fast-3.ogg",
        volume = 0.75
      },
      {
        filename = "__base__/sound/inserter-fast-4.ogg",
        volume = 0.75
      },
      {
        filename = "__base__/sound/inserter-fast-5.ogg",
        volume = 0.75
      }
    }
  },
  collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
  selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
  pickup_position = {-1, -1},
  insert_position = {-1.2, -1.2}, -- pick-up at the same location
  energy_per_movement = 8000,
  energy_per_rotation = 8000,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    drain = "1kW"
  },
  extension_speed = 0.07,
  rotation_speed = 0.04,
  filter_count = 1,
  hand_base_picture =
  {
    filename = "__base__/graphics/entity/stack-filter-inserter/stack-filter-inserter-hand-base.png",
    priority = "extra-high",
    width = 8,
    height = 34
  },
  hand_closed_picture =
  {
    filename = "__base__/graphics/entity/stack-filter-inserter/stack-filter-inserter-hand-closed.png",
    priority = "extra-high",
    width = 24,
    height = 41
  },
  hand_open_picture =
  {
    filename = "__base__/graphics/entity/stack-filter-inserter/stack-filter-inserter-hand-open.png",
    priority = "extra-high",
    width = 32,
    height = 41
  },
  hand_base_shadow =
  {
    filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
    priority = "extra-high",
    width = 8,
    height = 34
  },
  hand_closed_shadow =
  {
    filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
    priority = "extra-high",
    width = 18,
    height = 41
  },
  hand_open_shadow =
  {
    filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
    priority = "extra-high",
    width = 18,
    height = 41
  },
  platform_picture =
  {
    sheet =
    {
      filename = "__base__/graphics/entity/stack-filter-inserter/stack-filter-inserter-platform.png",
      priority = "extra-high",
      width = 46,
      height = 46,
      shift = {0.09375, 0}
    }
  },
  circuit_wire_connection_point = inserter_circuit_wire_connection_point,
  circuit_connector_sprites = inserter_circuit_connector_sprites,
  circuit_wire_max_distance = inserter_circuit_wire_max_distance
}

local assembler_commandor_r = {
  type = "recipe",
  name = "assembler-commandor",
  enabled = true,
  ingredients =
  {
      {"copper-cable", 5},
      {"electronic-circuit", 2},
  },
  result = "assembler-commandor"
}
local assembler_commandor_i = {
  type = "item",
  name = "assembler-commandor",
  icon = "__base__/graphics/icons/stack-filter-inserter.png",
  flags = { "goes-to-quickbar" },
  subgroup = "circuit-network",
  place_result = "assembler-commandor",
  order = "b[combinators]-a[assembler-commandor]",
  stack_size= 50,
}

data:extend({ assembler_commandor_e, assembler_commandor_r, assembler_commandor_i })
table.insert( data.raw["technology"]["circuit-network"].effects, { type = "unlock-recipe", recipe = "assembler-commandor" } )
