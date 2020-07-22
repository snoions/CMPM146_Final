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
-- change 'width' to change the width of the search spiral
function look_for_tree()
	-- end result is a width+1 x width+2 rectangle
	length = 0
	width = 5
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

-- this funciton should always be called before crafting something
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

-- craft wood pick
-- check if there is a block under you, if not place one
-- get rid of the block in front of you so that you can drop and suck without interference
-- move forward and turn twice
function craft_wooden_pickaxe()	

	-- find what slot your wood is in
	for i=1,16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item ~= nil then
			if item.name == "minecraft:log" or item.name == "minecraft:log2" then
				woodIndex = i
				break
			end
		end
	end
	-- empty out random stuff in inventory that isn't needed to craft
	for i=1,16 do
		turtle.select(i)
		if i ~= woodIndex then
			turtle.drop()
		end
	end

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

function find_stone()
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

		if turtle.getItemCount() >= 11 then
			haveStone = true
		end
	end
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
