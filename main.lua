DEBUG = true
if DEBUG then
    lick = require "lick"
    lick.reset = true
end

function love.load( arg ) 
    local opts = {
        fsaa = 16,
        resizable = true,
        highdpi = true
    }
    local w = 1680
    if DEBUG then
        opts.display = 2
        w = 1050 
    end
    local h = w / 1.69999
    love.window.setMode( w, h, opts)
    DEAD_ZONE = 0.15

    setupShip( love.graphics.getDimensions() )
end

function setupShip( W, H )
    if DEBUG then
        print( "Creating ship for resolution " .. W .. "x" .. H )
    end
    stick = {
        mode = "fill",
        color = { 215, 144, 66 },
        x = W/2,
        y = H/2,
        w = W/50,
        h = H * 2
    }
    stick.x = stick.x - stick.w/2
    ship = { 
        mode = "fill",
        color = { 205, 205, 205 },
        x = stick.x,
        y = stick.y,
        w = W/8,
        h = W/1.6999/16,
        v = {
            x = W / 1.5,
            y = H / 0.66
        },
        multiplier = 3
    }
    shipFin = {
        mode = "fill",
        color = { 255, 30, 30 },
        x = stick.x,
        y = stick.y,
        w = ship.w / 4,
        h = ship.h * 3/4
    }
    shipWing = {
        mode = "fill",
        color = { 255, 30, 30 },
        x = ship.x + ship.w/2,
        y = ship.y + ship.h/2,
        w = ship.w / 2,
        h = ship.h / 8
    }
    shipWing.x = shipWing.x - shipWing.w/2
    shipWing.y = shipWing.y - shipWing.h/2

    wheels = {
        mode = "fill",
        innerColor = { 255, 30, 30 },
        outerColor = { 30, 30, 255 },
        outerRad = ship.h / 2,
        innerRad = ship.h / 4,
        locations = {
            {
                x = ship.x,
                y = ship.y + ship.h
            }, {
                x = ship.x + ship.w,
                y = ship.y + ship.h
            }
        }
    }
    wheels.locations[1].x = wheels.locations[1].x + wheels.outerRad/2 + 10
    wheels.locations[2].x = wheels.locations[2].x - wheels.outerRad/2 - 10
end

function love.update( dt )
    local g = love.joystick.getJoysticks()[1]
    local dx = g:getGamepadAxis("leftx")
    local dy = g:getGamepadAxis("lefty")
    local multiplier = ship.multiplier * g:getGamepadAxis("triggerright") + 1

    if math.abs(dx) < DEAD_ZONE then
        dx = 0
    end
    if math.abs(dy) < DEAD_ZONE then
        dy = 0
    end

    stick.x = stick.x + (dx * dt * ship.v.x * multiplier)
    stick.y = stick.y + (dy * dt * ship.v.y * multiplier)

    ship.x = stick.x - ship.w/2 + stick.w/2
    ship.y = stick.y - ship.h/2

    shipFin.x = ship.x
    shipFin.y = ship.y

    shipWing.x = ship.x + ship.w/2 - shipWing.w/2
    shipWing.y = ship.y + ship.h/2 - shipWing.h/2

    wheels.locations[1].x = ship.x + wheels.outerRad/2 + 10
    wheels.locations[1].y = ship.y + ship.h

    wheels.locations[2].x = ship.x + ship.w - wheels.outerRad/2 - 10
    wheels.locations[2].y = ship.y + ship.h
end

function love.resize( w, h )
    setupShip( w, h )
end

function love.draw()
    love.graphics.setColor( stick.color )
    love.graphics.rectangle( stick.mode, stick.x, stick.y, stick.w, stick.h )

    love.graphics.setColor( ship.color )
    love.graphics.rectangle( ship.mode, ship.x, ship.y, ship.w, ship.h )

    love.graphics.setColor( shipWing.color )
    love.graphics.rectangle( shipWing.mode, shipWing.x, shipWing.y, shipWing.w, shipWing.h )

    love.graphics.setColor( shipFin.color )
    love.graphics.polygon( shipFin.mode,
        shipFin.x, shipFin.y,
        shipFin.x + shipFin.w, shipFin.y,
        shipFin.x, shipFin.y - shipFin.h
    )

    love.graphics.setColor( wheels.outerColor )
    love.graphics.circle( wheels.mode, wheels.locations[1].x, wheels.locations[1].y, wheels.outerRad, 100 )
    love.graphics.circle( wheels.mode, wheels.locations[2].x, wheels.locations[2].y, wheels.outerRad, 100 )

    love.graphics.setColor( wheels.innerColor )
    love.graphics.circle( wheels.mode, wheels.locations[1].x, wheels.locations[1].y, wheels.innerRad, 100 )
    love.graphics.circle( wheels.mode, wheels.locations[2].x, wheels.locations[2].y, wheels.innerRad, 100 )
end

