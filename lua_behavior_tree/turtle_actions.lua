require "bt_nodes"


tools = {'wooden pickaxe', 'stone pickaxe', 'iron pickaxe', 'bench', 'furnace'}
--a function that returns the location of an item in the turtle's find_in_inventory
--returns 0 if not found
function find_in_inventory(item)
	for i = 1, 16 do
		turtle.select(i)
		found = turtle.getItemDetail()
		if found and found.name == item then
			return i
		end
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

-- this function should always be called before crafting something
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
	turtle.dig()
	-- dump items here then when you are done dumping, do turtle.back() and turtle.turnLeft() to start inventory sorting and crafting!
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
function craft_planks()
	-- find where your logs are stored
end
-- crafts sticks - requires planks
function craft_sticks()

end

-- craft wood pick - requires 2 logs
-- check if there is a block under you, if not place one
-- get rid of the block in front of you so that you can drop and suck without interference
-- move forward and turn twice
-- you MUST call setup_craft_area() before calling this
function craft_wooden_pick()	
	woodIndex = nil
	-- find what slot your wood is in
	woodIndex = find_index("minecraft:log")
	if woodIndex == nil then
		woodIndex = find_index("minecraft:log2")
	end
	if woodIndex == nil then
		print("ERROR: You have no logs!")
		return
	end

	-- empty out random stuff in inventory that isn't needed to craft
	list = {woodIndex}
	empty_inv(list)

	-- get rid of extra blocks so that there is no inventory overflow
	turtle.select(woodIndex)
	amt = turtle.getItemCount()
		if amt > 16 then
			turtle.drop(amt-16)
		end

	-- go back to crafting area
	turtle.back()
	turtle.turnLeft()

	-- get wood in first slot
	turtle.select(woodIndex)
	turtle.drop()
	turtle.select(1)
	turtle.suck()

	-- craft wood
	-- turtle.back()
	turtle.craft(16)

	-- reposition wood into diff slot to
	-- craft sticks
	turtle.drop(1)
	turtle.select(5)
	turtle.suck()
	turtle.craft(1)

	-- we have sticks now we need to move stuff around and craft a pickaxe
	-- move sticks
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

--precondition: turtle has an iron ore, a coal, and a furnace in its inventory
function smelt_iron()
	ore_location = find_in_inventory("minecraft:iron_ore")
	if ore_location == 0 then return false end 
	coal_location = find_in_inventory("minecraft:coal")
	if coal_location == 0 then return false end
	furnace_location = find_in_inventory("minecraft:furnace")
	if furnace_location == 0 then return false end

	--clear space for furnace
	if turtle.detect() then turtle.dig() end
	--assume we are facing a furnace
	turtle.select(furnace_location)
	turtle.place()
	--drop coal
	turtle.select(coal_location)
	turtle.drop()
	--move to the top of the furnace
	turtle.up()
	turtle.forward()
	--drop iron ore
	turtle.select(ore_location)
	turtle.dropDown()
	sleep(10)
	--collect iron_ingot
	turtle.digDown()
	turtle.suckDown()
	turtle.down()
	return true

end


function sleep(n)  -- seconds
  local clock = os.clock
  local t0 = clock()
  while clock() - t0 <= n do end
end

function look_for_diamonds()

end

function dig_to_bedrock()
    success, blockUnder = turtle.inspectDown()
    while not success or blockUnder.name ~= "minecraf:bedrock" do
        if success then
            turtle.digDown()
        end
        turtle.down()
        success, blockUnder = turtle.inspectDown()
    end
    return true
end
 
function go_to_level(current, goal)
    if current == goal then return true end
    while current~=goal do
        if current > goal then
            if turtle.detectDown() then
                turtle.digDown()
            end
            current = current -1
            print(current)
            turtle.down()
        else
            if turtle.detectUp() then
                turtle.digUp()
            end
            current = current +1
            turtle.up()
        end
        print(current)
    end
 return true
end
 
 
