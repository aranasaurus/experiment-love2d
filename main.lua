DEBUG = true
if DEBUG then
    lick = require "lick"
    lick.reset = true
end

require "ship"
lick.file = "ship.lua"

function setupShip( W, H )
    local x = W/2
    local y = H/2
    local w = W/10
    local h = w/2.8
    local v = {
        x = W / 1.5,
        y = H / 0.66
    }
    ship = Ship:new( x - w/2, y - h/2, w, h, v, 1 )
    ship2 = Ship:new( w + 10, h + 10, w, h, v, 2 )
    ship2.body.color = { 255, 200, 200 }
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

    setupShip( love.graphics.getDimensions() )
end

function love.update( dt )
    ship:update( dt )
    ship2:update( dt )
end

function love.resize( w, h )
    setupShip( w, h )
end

function love.draw()
    ship2:draw()
    ship:draw()
end

