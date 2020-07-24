

tools = {'wooden pickaxe', 'stone pickaxe', 'iron pickaxe', 'bench', 'furnace'}
--a function that returns the location of an item in the turtle's find_in_inventory
--returns 0 if not found

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
	if not turtle.detectDown() then
		turtle.placeDown()
	end
	turtle.place()
	turtle.turnRight()
	turtle.place()
	turtle.turnLeft()
	turtle.back()
	if not turtle.detectDown() then
		turtle.placeDown()
	end
	return true
	-- dump items here then when you are done dumping, turtle.turnLeft() to start crafting
end

-- call this function after you finish crafting to pickup all your extra items you dropped
function pickup_leftover()
	turtle.turnRight()
	for i=1,16 do
		turtle.suck()
	end
	return true
end


-- empties everything in your inventory except the specified indexes in n
-- n is a list of indicies
function empty_inv(n)
	-- empty out random stuff in inventory that isn't needed to craft
	-- gets the size of n
	nSize = table.getn(n)
	for i=1,16 do
		-- iter thru n and drop anything that isn't in n
		turtle.select(i)
		inside_n = false
		for j=1,nSize do
			if i == n[j] then
				inside_n = true
			end
		end
		if not inside_n then
			turtle.drop()
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
		return false
	end
	list = {woodIndex}
	-- get rid of unecessary items
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- craft planks
	return turtle.craft(1)
end

-- crafts sticks - requires planks
-- you MUST call setup_craft_area() before crafting
function craft_sticks()
	woodIndex = find_index("minecraft:planks")
	if woodIndex == nil then
		print("ERROR: You have no planks!")
		return false
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
	return turtle.craft(1)
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
		return false
	end
	-- check to make sure you have enough
	plankCount = turtle.getItemCount(woodIndex)
	if plankCount < 3 then
		print("ERROR: You don't have enough planks")
		return false
	end

	stickIndex = find_index("minecraft:stick")
	if stickIndex == nil then
		print("ERROR: You have no sticks")
		return false
	end
	-- check to make sure you have enough
	stickCount = turtle.getItemCount(stickIndex)
	if stickCount < 2 then
		print("ERROR: You don't have enough sticks")
		return false
	end

	-- empty out random stuff in inventory that isn't needed to craft
	list = {woodIndex, stickIndex}
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- at this point you FOR SURE only have two items in your inventory
	-- move sticks to open spot (try last 2 slots at least one will be avail 100% of time)
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
	turtle.select(1)
	turtle.transferTo(2, 1)
	turtle.transferTo(3, 1)

	-- move sticks to slot 5 then transfer 1 stick to slot 9
	turtle.select(stickIndex)
	turtle.transferTo(6)
	turtle.select(6)
	turtle.transferTo(10, 1)
	-- craft
	return turtle.craft(1)

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
			return true
		end
	end
end

-- you MUST call setup_craft_area() before calling this
-- crafts a stone pickaxe
function craft_stone_pick()
	stoneIndex = nil
	stickIndex = nil
	-- find what slot your items are in
	stoneIndex = find_index("minecraft:cobblestone")
	if stoneIndex == nil then
		print("ERROR: You have no cobblestone")
		return false
	end
	-- check to make sure you have enough
	stoneCount = turtle.getItemCount(stoneIndex)
	if stoneCount < 3 then
		print("ERROR: You don't have enough cobblestone")
		return false
	end

	stickIndex = find_index("minecraft:stick")
	if stickIndex == nil then
		print("ERROR: You have no sticks")
		return false
	end
	-- check to make sure you have enough
	stickCount = turtle.getItemCount(stickIndex)
	if stickCount < 2 then
		print("ERROR: You don't have enough sticks")
		return false
	end

	-- empty out random stuff in inventory that isn't needed to craft
	list = {stoneIndex, stickIndex}
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- at this point you FOR SURE only have two items in your inventory
	-- move sticks to open spot (try last 2 slots at least one will be avail 100% of time)
	turtle.select(stickIndex)
	if turtle.transferTo(16) then
		stickIndex = 16
	else 
		turtle.transferTo(15)
		stickIndex = 15
	end

	-- put stone in slot 1, 2, 3
	turtle.select(stoneIndex)
	turtle.transferTo(1)
	turtle.select(1)
	turtle.transferTo(2, 1)
	turtle.transferTo(3, 1)

	-- move sticks to slot 5 then transfer 1 stick to slot 9
	turtle.select(stickIndex)
	turtle.transferTo(6)
	turtle.select(6)
	turtle.transferTo(10, 1)
	-- craft
	return turtle.craft(1)
	
end

-- you MUST call setup_craft_area() before calling this
-- crafts a iron pickaxe
function craft_iron_pick()
	ironIndex = nil
	stickIndex = nil
	-- find what slot your items are in
	ironIndex = find_index("minecraft:iron_ingot")
	if ironIndex == nil then
		print("ERROR: You have no iron ingots")
		return false
	end
	-- check to make sure you have enough
	stoneCount = turtle.getItemCount(ironIndex)
	if stoneCount < 3 then
		print("ERROR: You don't have enough iron ingots")
		return false
	end

	stickIndex = find_index("minecraft:stick")
	if stickIndex == nil then
		print("ERROR: You have no sticks")
		return false
	end
	-- check to make sure you have enough
	stickCount = turtle.getItemCount(stickIndex)
	if stickCount < 2 then
		print("ERROR: You don't have enough sticks")
		return false
	end

	-- empty out random stuff in inventory that isn't needed to craft
	list = {ironIndex, stickIndex}
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- at this point you FOR SURE only have two items in your inventory
	-- move sticks to open spot (try last 2 slots at least one will be avail 100% of time)
	turtle.select(stickIndex)
	if turtle.transferTo(16) then
		stickIndex = 16
	else 
		turtle.transferTo(15)
		stickIndex = 15
	end

	-- put stone in slot 1, 2, 3
	turtle.select(ironIndex)
	turtle.transferTo(1)
	turtle.select(1)
	turtle.transferTo(2, 1)
	turtle.transferTo(3, 1)

	-- move sticks to slot 5 then transfer 1 stick to slot 9
	turtle.select(stickIndex)
	turtle.transferTo(6)
	turtle.select(6)
	turtle.transferTo(10, 1)
	-- craft
	return turtle.craft(1)
	
end

-- you MUST call setup_craft_area() before calling this
-- crafts a furnace
function craft_furnace()
	stoneIndex = nil
	-- find what slot your items are in
	stoneIndex = find_index("minecraft:cobblestone")
	if stoneIndex == nil then
		print("ERROR: You have no cobblestone")
		return false
	end
	-- check to make sure you have enough
	stoneCount = turtle.getItemCount(stoneIndex)
	if stoneCount < 8 then
		print("ERROR: You don't have enough cobblestone")
		return false
	end

	-- empty out random stuff in inventory that isn't needed to craft
	list = {stoneIndex}
	empty_inv(list)

	-- go back to crafting area
	turtle.turnLeft()

	-- put stone in slot 1-3, 5, 7, 9-11
	turtle.select(stoneIndex)
	turtle.transferTo(1)
	turtle.select(1)
	turtle.transferTo(2, 1)
	turtle.transferTo(3, 1)
	turtle.transferTo(5, 1)
	turtle.transferTo(7, 1)
	turtle.transferTo(9, 1)
	turtle.transferTo(10, 1)
	turtle.transferTo(11, 1)

	-- craft
	return turtle.craft(1)
	
end


function mine_iron()

end

--a temporary implementation , could have been done better with GOAP or HTN
-- smelts 3 iron ore
function smelt_iron()
	-- n is sleep time
	n = 10
	ore_location = find_index("minecraft:iron_ore")
	if ore_location == nil then 
		print("You have no iron ore")
		return false 
	end 
	coal_location = find_index("minecraft:coal")
	if coal_location == nil then 
		print("You have no coal")
		return false 
	end
	furnace_location = find_index("minecraft:furnace")
	if furnace_location == nil then 
		print("You have no furnace")
		return false 
	end

	-- for some reason suck doesn't suck out of the finished slot in furances T_T

	--clear space for furnace
	if turtle.detect() then turtle.dig() end
	--assume we are facing a furnace
	turtle.select(furnace_location)
	turtle.place()
	--drop coal
	turtle.select(coal_location)
	turtle.drop()
	--move to the top of the furnace
	if turtle.detectUp() then turtle.digUp() end
	turtle.up()
	if turtle.detect() then turtle.dig() end
	turtle.forward()
	--drop iron ore
	turtle.select(ore_location)
	turtle.dropDown()
	--wait 10 sec for iron ingot to smelt
  	sleep(n)
	--go in a 3x3 area and dig and suck to collect iron_ingot
	-- start in center
	-- breaks furnace
	turtle.digDown()
	turtle.suckDown()
	turtle.forward()
	turtle.suckDown()
	turtle.turnRight()
	turtle.forward()
	turtle.suckDown()
	turtle.turnRight()
	turtle.forward()
	turtle.suckDown()
	turtle.forward()
	turtle.suckDown()
	turtle.turnRight()
	turtle.forward()
	turtle.suckDown()
	turtle.forward()
	turtle.suckDown()
	turtle.turnRight()
	turtle.forward()
	turtle.suckDown()
	turtle.forward()
	turtle.suckDown()
	return true
end
