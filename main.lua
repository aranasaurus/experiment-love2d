DEBUG = true
if DEBUG then
    lick = require "lick"
    lick.reset = true
end

require "ship"
lick.file = "ship.lua"

ships = { }

function addShip( id, gamepad )
    W, H = love.graphics.getDimensions()
    local x = W/2
    local y = H/2
    local w = W/8
    local h = w/2.8
    local v = {
        x = W / 1.5,
        y = H / 0.66
    }

    ships[id] = Ship:new( x - w/2, y - h/2, w, h, v, gamepad )
end

function resetShips()
    ships = { }

    local joysticks = love.joystick.getJoysticks()
    
    if #joysticks == 0 then
        addShip( "keyboard" )
    end

    for _, gamepad in ipairs( joysticks ) do
        addShip( gamepad:getID(), gamepad )
    end
end

function love.load( arg ) 
    local opts = {
        fsaa = 8,
        resizable = true,
        highdpi = true,
    }
    local w = 1680
    love.window.setTitle( "Experiment - Love2d" )
    if DEBUG then
        opts.display = 2
        w = 1050 
        love.window.setTitle( love.window.getTitle() .. " - DEBUG" )
    end
    local h = w / 1.69999
    love.window.setMode( w, h, opts)
    DEAD_ZONE = 0.15

    resetShips()
end

function love.update( dt )
    for _, s in pairs( ships ) do
        s:update( dt )
    end
end

function love.resize( w, h )
    resetShips()
end

function love.draw()
    for _, s in pairs( ships ) do
        s:draw()
    end
end

function love.joystickadded( joystick )
    addShip( joystick )
end

function love.joystickremoved( joystick )
    ships[joystick:getID()] = nil
end

function love.gamepadreleased( gamepad, button )
    if button == "leftshoulder" then
        ships[gamepad:getID()]:changeColor( -1 )
    elseif button == "rightshoulder" then
        ships[gamepad:getID()]:changeColor( 1 )
    elseif button == "y" then
        ships[gamepad:getID()]:setRandomColor()
    elseif button == "x" or button == "a" then
        ships[gamepad:getID()]:fire()
    end
end

function love.keypressed( button )
    if button == "z" or button == "[" then
        ships["keyboard"]:changeColor( -1 )
    elseif button == "x" or button == "]" then
        ships["keyboard"]:changeColor( 1 )
    elseif button == "c" or button == "/" then
        ships["keyboard"]:setRandomColor()
    end
end

