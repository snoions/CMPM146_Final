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

function look_for_tree()

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
