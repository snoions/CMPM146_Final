require "bt_nodes"

tools = {'wooden pickaxe', 'stone pickaxe', 'iron pickaxe', 'bench', 'furnace'}
way_points = {}
--a function that returns the location of an item in the turtle's find_in_inventory
--returns 0 if not found
function find_in_inventory(item)
	for i = 1, 16 do
		turtle.select(i)
		found = turtle.getItemDetail()
		if found and found.name == item then
			return i
	end
	return 0
end

-- goes in a spiral pattern looking for a tree, when found it farms it then stops at the bottom
-- n = width of the search spiral
function find_wood(n)
	-- end result is a width+1 x width+2 rectangle
	length = 0
	width = n
	downCount = 0
	treeDone = false
	for j=0,width do
		for i=0,1 do
			for i=0,length do
				-- if its possible to go down do it
				if not turtle.down() then
					-- if under me is a leaf then break it and go down
					success, data = turtle.inspectDown()
					if data.name == "minecraft:leaves" or data.name == "minecraft:leaves2" then
						turtle.digDown()
						turtle.down()
					end
				end
				-- if you can't go forward do this
				if not turtle.forward() then
					success, data = turtle.inspect()
					-- breaks thru leaves
					if data.name == "minecraft:leaves" or data.name == "minecraft:leaves2" then
						turtle.dig()
						turtle.forward()
					-- if we find a log harvest it
					elseif data.name == "minecraft:log" or data.name == "minecraft:log2" then
						turtle.dig()
						turtle.forward()
						-- since we found wood at the root then mine the rest of the tree on top
						suc, dataUp = turtle.inspectUp()
						while dataUp.name == "minecraft:log" or dataUp.name == "minecraft:log2" do
							suc, dataUp = turtle.inspectUp()
							turtle.digUp()
							turtle.up()
							downCount = downCount + 1
						end
						-- after you finish mining the tree at the top descend to the bottom where you started
						for i=0,downCount do
							turtle.down()
						end
						-- inspect under if there is leftover wood
						success, data = turtle.inspectDown()
						while data.name == "minecraft:log" or data.name == "minecraft:log2" do
							turtle.digDown()
							turtle.down()
							success, data = turtle.inspectDown()
						end
						treeDone = true
						break
					-- if we can't go up try to go back until you can
					elseif not turtle.up() then
						success, data = turtle.inspectUp()
						if data.name == "minecraft:leaves" or data.name == "minecraft:leaves2" then
							turtle.digUp()
						end
						while not turtle.up() do
							turtle.back()
						end
					end
					turtle.forward()
				end
			end
			turtle.turnRight()
			-- if we finish descending tree then stop
			if treeDone then
				break
			end
		end
		
		length = length + 1
	end
end

-- this function should ALWAYS be called before crafting something
-- this is necessary because the bot has to clear unecessary items and sort them around to match the specific pattern
-- sets up a crafting space and prepares you to dump things not needed in your inventory
function setup_craft_area()
	-- check if there is a block under you, if not place one
	if not turtle.detectDown() then
		turtle.placeDown()
	end
	-- place barricade around if empty, then set up to dump items
	turtle.place()
	turtle.turnLeft()
	turtle.place()
	turtle.turnLeft()
	turtle.place()
	turtle.turnLeft()
	turtle.dig()
	turtle.forward()
	turtle.turnLeft()
	turtle.dig()
	turtle.forward()
	turtle.placeDown()
	turtle.place()
	turtle.turnRight()
	turtle.place()
	turtle.turnLeft()
	turtle.back()
	turtle.placeDown()
	-- dump items here then when you are done dumping, turtle.turnLeft() to start crafting
end

-- call this function after you finish crafting to pickup all your extra items you dropped
function pickup_leftover()
	turtle.turnRight()
	for i=1,16 do
		turtle.suck()
	end
end


-- empties everything in your inventory except the specified indexes in n
-- n is a list of indicies
function empty_inv(n)
	-- empty out random stuff in inventory that isn't needed to craft
	for i=1,16 do
		turtle.select(i)
		-- gets the size of n
		nSize = table.getn(n)
		-- iter thru n and drop anything that isn't in n
		for j=1,nSize do
			if i ~= n[j] then
				turtle.drop()
			end
		end
	end
end

-- n = a string of what you want
-- returns the index of the item
-- it also selects the slot that your item is in
-- if not in inventory return nil
function find_index(n)
	index = nil
	for i=1,16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item ~= nil then
			if item.name == n then
				index = i
				break
			end
		end
	end
	return index
end

-- craft planks - requires logs
-- you MUST call setup_craft_area() before crafting
function craft_planks()
	-- find what slot your log is in
	woodIndex = find_index("minecraft:log")
	if woodIndex == nil then
		woodIndex = find_index("minecraft:log2")
	end
	if woodIndex == nil then
		print("ERROR: You have no logs!")
		return
	end
	list = {woodIndex}
	-- get rid of unecessary items
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- craft planks
	turtle.craft()
end

-- crafts sticks - requires planks
-- you MUST call setup_craft_area() before crafting
function craft_sticks()
	woodIndex = find_index("minecraft:planks")
	if woodIndex == nil then
		print("ERROR: You have no planks!")
		return
	end
	list = {woodIndex}
	-- get rid of unecessary items
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- put planks in first slot
	turtle.select(woodIndex)
	turtle.transferTo(1)

	-- reposition wood into slot under to match recipe
	-- craft sticks
	turtle.transferTo(5, 1)
	turtle.craft(1)
end

-- craft wood pick - requires planks and sticks
-- you MUST call setup_craft_area() before crafting
function craft_wood_pick()	
	woodIndex = nil
	stickIndex = nil
	-- find what slot your items are in
	woodIndex = find_index("minecraft:planks")
	if woodIndex == nil then
		print("ERROR: You have no planks")
	end
	-- check to make sure you have enough
	plankCount = turtle.getItemCount(woodIndex)
	if plankCount < 3 then
		print("ERROR: You don't have enough planks")
		return
	end

	stickIndex = find_index("minecraft:stick")
	if stickIndex == nil then
		print("ERROR: You have no sticks")
	end
	-- check to make sure you have enough
	stickCount = turtle.getItemCount(stickIndex)
	if stickCount < 2 then
		print("ERROR: You don't have enough sticks")
		return
	end

	-- empty out random stuff in inventory that isn't needed to craft
	list = {woodIndex, stickIndex}
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- at this point you FOR SURE only have two items in your inventory
	-- move sticks to open spot
	turtle.select(stickIndex)
	if turtle.transferTo(16) then
		stickIndex = 16
	else 
		turtle.transferTo(15)
		stickIndex = 15
	end

	-- put planks in slot 1, 2, 3
	turtle.select(woodIndex)
	turtle.transferTo(1)
	turtle.transferTo(2, 1)
	turtle.transferTo(3, 1)

	turtle.select(stickIndex)

	-- pickup sticks, in slot 5 then transfer 1 to slot 9

	-- we have sticks now we need to move stuff around and craft a pickaxe
	-- move sticks
	turtle.select(stickIndex)
	turtle.drop()
	turtle.select(6)
	turtle.suck()
	turtle.drop(1)
	turtle.select(10)
	turtle.suck()
	-- move wood
	turtle.select(1)
	turtle.drop(2)
	turtle.select(2)
	turtle.suck()
	turtle.drop(1)
	turtle.select(3)
	turtle.suck()
	-- craft
	turtle.craft()
end

-- digs down and every 5 blocks pauses to check if we have enough stone to craft
-- n = amount of stone you want
-- need 11 stone to craft pick and furnace
function find_stone(n)
	haveStone = false
	while not haveStone do
		for i=0,4 do
			turtle.digDown()
			turtle.down()
		end
		for i=1,16 do
			turtle.select(i)
			item = turtle.getItemDetail()
			if item ~= nil then
				if item.name == "minecraft:cobblestone" then
					stoneIndex = i
					break
				end
			end
		end

		if turtle.getItemCount() >= n then
			haveStone = true
		end
	end
end

-- you MUST call setup_craft_area() before calling this
-- crafts a stone pickaxe
function craft_stone_pick()
	stoneIndex = nil
	print(stoneIndex)
end

function craft_tool(tool)

end


function mine_iron()

end

--a temporary implementation , could have been done better with GOAP or HTN
function smelt_iron()
	ore_location = find_in_inventory("minecraf:iron_ore")
	if ore_location == 0 then
		return false
	coal_location = find_in_inventory("minecraf:coal")
	if coal_location == 0 then
		return false

	--assume we are facing a furnace

	--drop coal
	turtle.select(coal_location)
	turtle.drop()
	--move to the top of the furnace
	turtle.up()
	turtle.forward()
	--drop iron ore
	turtle.select(ore_location)
	turtle.dropDown()

end

function look_for_diamonds()

end
