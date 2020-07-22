

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
    if turtle.getFuelLevel()<length*width +width then
        print("not enough fuel, fuelLevel="..turtle.getFuelLevel())
        return false
    end
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
    if turtle.getFuelLevel() < length then
        print("not enough fuel, fuelLevel="..turtle.getFuelLevel())
        return false
    end
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

function look_for_diamonds()

end