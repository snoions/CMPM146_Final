function dig_to_bedrock()
    success, blockUnder = turtle.inspectDown()
    while blockUnder.name ~= "minecraf:bedrock" do
        if success then
            turtle.digDown()
        end
        turtle.down()
        success, blockUnder = turtle.inspectDown()
    end
    return true
end
 
function go_to_level(current, goal)
    if turtle.getFuelLevel() < math.abs(current-goal) then
        print("not enough fuel, fuelLevel="..turtle.getFuelLevel())
        return false
    end
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
 
function mine_hallway(length, width)
    mine_strip(length)
    for i = 2, width do
        if i%2 ==0 then turtle.turnRight() else turtle.turnLeft() end
        turtle.dig()
        turtle.forward()
        if i%2 ==0 then turtle.turnRight() else turtle.turnLeft() end
        mine_strip(length)
    end
    return true
end
 
function mine_strip(length)
    turtle.digDown()
    turtle.digUp()
    for i = 1, length do
        turtle.dig()
        turtle.forward()
        turtle.digDown()
        turtle.digUp()
    end
    return true
end

-- the end result is a n(2)-1 x n(2)-1 square mined
function mine_spiral_out(n)
    width = n
    length = 0
    for j=0,width do
        for i=0,1 do
            for i=0,length do
                turtle.dig()
                turtle.forward()
            end
            turtle.turnRight()
        end
        length = length + 1
    end
    for i=0,length-1 do
        turtle.dig()
        turtle.forward()
    end
end

-- the end result is a n(2)-1 x n(2)-1 square mined
function mine_spiral_in(n)
    length = n
    for i=0,length do
        turtle.dig()
        turtle.forward()
    end
    turtle.turnRight()
    for j=0,width do
        for i=0,1 do
            for i=0,length do
                turtle.dig()
                turtle.forward()
            end
            turtle.turnRight()
        end
        length = length - 1
    end
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

-- dig down 3 layers then mine in 5x x 4y x 5z
-- spiral out, spiral in, dig down repeat
function look_for_iron()
    finished = false
    amt = 3
    while not finished do
        for i=0,1 do
            mine_spiral_out(3)
            -- reposition
            turtle.digDown()
            turtle.down()
            turtle.turnRight()
            mine_spiral_in(3)
            -- reposition
            turtle.digDown()
            turtle.down()
        end
        for i=0,1 do
            turtle.digDown()
            turtle.down()
        end
        ironOreIndex = find_index("minecraft:iron_ore")
        if ironOreIndex ~= nil then
            ironOreCount = turtle.getItemCount(ironOreIndex)
            if ironOreCount >= amt then
                finished = true
            end
        end
        list = {ironOreIndex}
        empty_inv(list)
    end
    return true
end

-- first descend to layers 5-12
-- hit bedrock then go up 5 layers then strip mine FOR DAYS!!!!!!
function look_for_diamonds()
    finished = false
    -- turtle.dig_to_bedrock()
    -- for i=0,4 do
    --  turtle.up()
    -- end
    while not finished do
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
        mine_hallway(5,6)
        turtle.turnLeft()
        diamondIndex = find_index("minecraft:diamond")
        if diamondIndex ~= nil then
            finished = true
        end
    end
end
