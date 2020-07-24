-- require('bt_nodes') 
os.loadAPI("bt_nodes")
os.loadAPI("turtle_actions")
os.loadAPI("turtle_mining")

file = io.open("actions", "r")
io.input(file)

-- set the tasks here
line = io.read()
list = {}
while line ~= nil do
	if line == "punch for wood" then
		step1 = bt_nodes.Leaf( "ch_wood", turtle_actions.check_wood )
		step2 = bt_nodes.Leaf( "f_wood", turtle_actions.find_wood )

		task = bt_nodes.Selector( "Sel_wood", {step1, step2} )
	elseif line == "craft plank" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "cr_planks", turtle_actions.craft_planks )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )

		task = bt_nodes.Sequence( "Seq_plank", {step1, step2, step3} )
	elseif line == "craft bench" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "cr_bench", turtle_actions.craft_bench )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )

		task = bt_nodes.Sequence( "Seq_bench", {step1, step2, step3} )
	elseif line == "craft stick" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "cr_sticks", turtle_actions.craft_sticks )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )

		task = bt_nodes.Sequence( "Seq_stick", {step1, step2, step3} )
	elseif line == "craft wooden_pickaxe at bench" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "cr_w_pick", turtle_actions.craft_wood_pick )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )

		task = bt_nodes.Sequence( "Seq_w_pick", {step1, step2, step3} )
	elseif line == "wooden_pickaxe for cobble" then
		step1 = bt_nodes.Leaf( "ch_stone", turtle_actions.check_stone )
		step2 = bt_nodes.Leaf( "f_stone", turtle_actions.find_stone )

		task = bt_nodes.Selector( "Sel_stone", {step1, step2} )
	elseif line == "craft stone_pickaxe at bench" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "cr_s_pick", turtle_actions.craft_stone_pick )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )

		task = bt_nodes.Sequence( "Seq_s_pick", {step1, step2, step3} )
	elseif line == "stone_pickaxe for coal" then
		step1 = bt_nodes.Leaf( "ch_coal", turtle_actions.check_coal )
		step2 = bt_nodes.Leaf( "f_coal", turtle_mining.look_for_coal )

		task = bt_nodes.Selector( "Sel_coal", {step1, step2} )
	elseif line == "stone_pickaxe for ore" then
		step1 = bt_nodes.Leaf( "ch_iron", turtle_actions.check_iron )
		step2 = bt_nodes.Leaf( "f_iron", turtle_actions.look_for_iron )

		task = bt_nodes.Selector( "Sel_", {step1, step2} )
	elseif line == "craft furnace at bench" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "cr_furnace", turtle_actions.craft_furnace )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )

		task = bt_nodes.Sequence( "Seq_furnace", {step1, step2, step3} )
	elseif line == "smelt ore in furnace" then
		task = bt_nodes.Leaf( "sm_iron", turtle_actions.smelt_iron )
	elseif line == "craft iron_pickaxe at bench" then
		step1 = bt_nodes.Leaf( "setup", turtle_actions.setup_craft_area )
		step2 = bt_nodes.Leaf( "c_i_pick", turtle_actions.craft_iron_pick )
		step3 = bt_nodes.Leaf( "pickup", turtle_actions.pickup_leftover )
		
		task = bt_nodes.Sequence( "Seq_i_pick", {step1, step2, step3} )
	elseif line == "iron_pickaxe for diamond" then
		task = bt_nodes.Leaf( "f_diamonds", turtle_mining.look_for_diamonds )
	end

	table.insert(list, task)
	line = io.read()
end

sequence = bt_nodes.Sequence("S", list)
sequence:execute()
-- test = sequence:tree_to_string(1)
-- io.close(file)
-- file = io.open("output", "a")
-- io.output(file)
-- io.write(test)
-- io.close(file)
