-- region Turtle Modes
function AttackMode()
    local pos = InventoryLookup("minecraft:diamond_sword")
    if (#pos ~= 0) then
        assert(turtle.select(pos[1]))
        assert(turtle.equipRight())
    end
end

function DigMode()
    local pos = InventoryLookup("minecraft:diamond_shovel")
    if (#pos ~= 0) then
        assert(turtle.select(pos[1]))
        assert(turtle.equipRight())
    end
end

function MineMode()
    local pos = InventoryLookup("minecraft:diamond_pickaxe")
    if (#pos ~= 0) then
        assert(turtle.select(pos[1]))
        assert(turtle.equipRight())
    end
end

function FellMode()
    local pos = InventoryLookup("minecraft:diamond_axe")
    if (#pos ~= 0) then
        assert(turtle.select(pos[1]))
        assert(turtle.equipRight())
    end
end

function HostileMode()
    AttackMode()
    while (true)
    do
        turtle.attack()
        turtle.attackDown()
        turtle.attackUp()
        turtle.turnLeft()
    end
end

-- endregion

-- region Turtle methods
function HeadToCoord(coord)
    -- Index of packed table starts from 0
    local currentPos = table.pack(gps.locate)
    -- Equip Modem on Left side if not already equiped
    local modemPos = InventoryLookup("computercraft:ender_modem")
    if (#modemPos ~= 0) then
        assert(turtle.select(pos[1]), "HeadToCoord : Could not select pos[1]")
        assert(turtle.equipLeft(), "HeadToCoord : Could not equipLeft")
    end

    -- Orientation to north
    local orientation = GetOrientation()
    if (orientation == "east") then turtle.turnLeft() end
    if (orientation == "south") then
        turtle.turnLeft()
        turtle.turnLeft()
    end
    if (orientation == "west") then turtle.turnRight() end

    -- Take off to avoid trees and obstacles
    for i = 1, 50, 1
    do
        ClearUpTurtle()
        turtle.up()
    end

    local curTableCoord = table.pack(gps.locate())
    local currentDistance = ProceedDistance2D(curTableCoord, coord)


    while (currentDistance > 1)
    do
        ProceedNextMove(curTableCoord, coord)
        curTableCoord = table.pack(gps.locate())
        currentDistance = ProceedDistance2D(curTableCoord, coord)
    end

    while (not turtle.detectDown())
    do
        turtle.down()
    end

    local modem = peripheral.find("modem") or error("No modem attached!", 0)
    modem.transmit(0, 43, ("Turtle arrived at %s"):format(textutils.serialize(curTableCoord)))
end

function ProceedDistance2D(a, b)
    return math.sqrt(math.pow((b[1] - a[1]), 2) + math.pow((b[3] - a[3]), 2))
end

function ClearUpTurtle()
    if (turtle.detectUp()) then
        MineMode()
        turtle.digUp()
    end
end

function GetOrientation()
    local stonePos = InventoryLookup("minecraft:cobblestone")
    local torchPos = InventoryLookup("minecraft:torch")

    turtle.back()
    if (#stonePos ~= 0) then
        turtle.select(stonePos[1])
        assert(turtle.place())
    end
    turtle.back()
    if (#torchPos ~= 0) then
        turtle.select(torchPos[1])
        assert(turtle.place())
    end

    local properties = table.pack(turtle.inspect())[2]

    MineMode()
    turtle.dig()
    turtle.forward()
    turtle.suck()
    turtle.dig()
    turtle.forward()
    turtle.suck()
    return properties["state"]["facing"]
end

function ProceedNextMove(curCoords, destCoords)
    if (curCoords[1] < destCoords[1]) then
        turtle.turnLeft()
        turtle.forward()
        turtle.turnRight()
    end

    if (curCoords[1] > destCoords[1]) then
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
    end

    if (curCoords[3] < destCoords[3]) then
        turtle.forward()
    end

    if (curCoords[3] > destCoords[3]) then
        turtle.back()
    end
end

-- endregion

-- region Sys Turtle functions
function InventoryLookup(item)
    local invPlaces = {}
    local tableCpt = 1

    -- 16 is max inv index
    for i = 1, 16, 1
    do
        if (turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i)["name"] == item) then
            invPlaces[tableCpt] = i
            tableCpt = tableCpt + 1
        end
    end

    return invPlaces
end

-- endregion
