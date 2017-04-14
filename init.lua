tanks = {}

minetest.register_tool("tanks:wrench", {
	description = "Wrench",
	inventory_image = "wrench.png",
	wield_image = "wrench.png^[transformR90",
	on_use = function(itemstack, player, pointed_thing)
		if pointed_thing.type == "node" and player:get_player_control().sneak then
			local node_under = minetest.get_node(pointed_thing.under).name
			local dropstack = ItemStack({name = node_under, count = 1})
			local meta = dropstack:get_meta()
			local def = minetest.registered_nodes[node_under] or {groups = {tank = false}}
			if def.groups.tank then
				local param2 = minetest.get_node(pointed_thing.under).param2
				meta:set_int("fill", param2)
				meta:set_string("description", def.description .. " (" .. tostring(param2) .. " / 63)")
				minetest.dig_node(pointed_thing.under)
				local obj = minetest.add_item(pointed_thing.under, dropstack)
				if obj then
					obj:set_velocity({
						x = math.random(-1, 1),
						y = math.random(3, 5),
						z = math.random(-1, 1)})
				end
				itemstack:add_wear(1000)
				return itemstack
			end
		else
			return itemstack
		end
	end
})

function tanks.register_tank(name, bucket, description, liquid_description, special_tiles, tex)
	minetest.register_node("tanks:" .. name, {
		description = description,
		drawtype = "glasslike_framed",
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		tiles = {tex},
		sunlight_propogates = true,
		on_place = function(itemstack, placer, pointed_thing)
			local meta = itemstack:get_meta()
			local param2 = meta:get_int("fill")
			minetest.set_node(pointed_thing.above, {name = "tanks:" .. name, param2 = param2})
			minetest.get_meta(pointed_thing.above):set_string("infotext", tostring(param2) .. " / 63 buckets of " .. liquid_description .. ".")
			return ItemStack("")
		end,
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			if itemstack:get_name() == bucket then
				if node.param2 > 62 then
					return itemstack
				end
				minetest.set_node(pos, {name = node.name, param2 = node.param2 + 1})
				minetest.get_meta(pos):set_string("infotext", tostring(node.param2 + 1) .. " / 63 buckets of " .. liquid_description .. ".")
				return ItemStack("bucket:bucket_empty")
			else
				return itemstack
			end
		end,
		on_punch = function(pos, node, player, pointed_thing)
			local itemstack = player:get_wielded_item()
			if itemstack:get_name() == "bucket:bucket_empty" then
				if node.param2 < 1 then
					return itemstack
				end
				
				minetest.set_node(pos, {name = node.name, param2 = node.param2 - 1})
				minetest.get_meta(pointed_thing.under):set_string("infotext", tostring(node.param2 - 1) .. " / 63 buckets of " .. liquid_description .. ".")
				player:set_wielded_item(ItemStack(bucket))
				return
			end
		end,
		stack_max = 1,
		sounds = default.node_sound_glass_defaults(),
		groups = {cracky = 3, oddly_breakable_by_hand = 3, tank = 1},
		special_tiles = special_tiles
	})
end

tanks.register_tank("tank_water",
	"bucket:bucket_water",
	"Water Tank",
	"Water",
	minetest.registered_nodes["default:water_source"].special_tiles,
	"default_glass.png")

tanks.register_tank("tank_lava",
	"bucket:bucket_lava",
	"Lava Tank",
	"Lava",
	minetest.registered_nodes["default:lava_source"].special_tiles,
	"default_obsidian_glass.png")

minetest.register_craft({
	output = "tanks:tank_water",
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "", "default:glass"},
		{"default:glass", "default:glass", "default:glass"}
	},
})

minetest.register_craft({
	output = "tanks:tank_lava",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"}
	}
})

minetest.register_craft({
	output = "tanks:wrench",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:stick", ""},
		{"", "default:stick", ""}
	}
})
