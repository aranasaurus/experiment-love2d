lick = require "lick"
lick.reset = true

function love.load( arg ) 
    SW, SH = love.graphics.getDimensions()
    DEAD_ZONE = 0.15
    stick = {
        mode = "fill",
        color = { 215, 144, 66 },
        x = SW/2,
        y = SH/2,
        w = 25,
        h = SH * 2
    }
    stick.x = stick.x - stick.w/2
    ship = { 
        mode = "fill",
        color = { 205, 205, 205 },
        x = stick.x,
        y = stick.y,
        w = 220,
        h = 60,
        v = 350
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
end

function love.update( dt )
    local g = love.joystick.getJoysticks()[1]
    local dx = g:getGamepadAxis("leftx")
    local dy = g:getGamepadAxis("lefty")

    if math.abs(dx) < DEAD_ZONE then
        dx = 0
    end
    if math.abs(dy) < DEAD_ZONE then
        dy = 0
    end

    stick.x = stick.x + (dx * ship.v * dt)
    stick.y = stick.y + (dy * ship.v * dt)

    ship.x = stick.x - ship.w/2 + stick.w/2
    ship.y = stick.y - ship.h/2
    shipFin.x = ship.x
    shipFin.y = ship.y
    shipWing.x = ship.x + ship.w/2 - shipWing.w/2
    shipWing.y = ship.y + ship.h/2 - shipWing.h/2
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
end

