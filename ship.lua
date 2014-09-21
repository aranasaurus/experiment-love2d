Ship = {}
--lick.file = "main.lua"

function Ship:new( x, y, w, h, v, gamepad )
    s = {}
    setmetatable( s, self )
    self.__index = self

    s.x = x
    s.y = y
    s.w = w
    s.h = h
    s.v = v
    s.multiplier = 3
    s.gamepad = gamepad or 1

    s.body = {
        mode = "fill",
        color = { 205, 205, 205 },
        x = 0, y = 0,
        w = 1, h = 1
    }

    s.stick = {
        mode = "fill",
        color = { 215, 144, 66 },
        x = w/2,
        y = h/2,
        w = 1/12, -- of self.w
        h = 600 -- of self.h
    }
    s.stick.x = s.stick.x - s.stick.w * s.w/2

    s.fin = {
        mode = "fill",
        color = { 255, 30, 30 },
        x = 0, y = 0,
        w = 0.25, h = 0.75
    }

    s.wing = {
        mode = "fill",
        color = { 255, 30, 30 },
        w = 0.5, h = 0.125
    }
    s.wing.x = w/2 - s.wing.w * w/2
    s.wing.y = h/2 - s.wing.h * h/2

    s.wheels = {
        mode = "fill",
        innerColor = { 255, 30, 30 },
        outerColor = { 30, 30, 255 },
        outerRad = h * 0.5,
        innerRad = h * 0.25,
        locations = {
            { x = 0, y = h },
            { x = w, y = h }
        }
    }
    s.wheels.locations[1].x = s.wheels.innerRad
    s.wheels.locations[2].x = w - s.wheels.innerRad
    s.wheels = nil

    return s
end

function Ship:draw()
    love.graphics.push()
    love.graphics.origin()

    love.graphics.translate( self.x, self.y )

    function drawRect( item )
        love.graphics.setColor( item.color )
        love.graphics.rectangle( item.mode, item.x, item.y, item.w * self.w, item.h * self.h )
    end
    drawRect( self.stick )
    drawRect( self.body )
    drawRect( self.wing )

    love.graphics.setColor( self.fin.color )
    love.graphics.polygon( self.fin.mode,
        self.fin.x, self.fin.y,
        self.fin.x + (self.fin.w * self.w), self.fin.y,
        self.fin.x, self.fin.y - (self.fin.h * self.h)
    )

    if self.wheels ~= nil then
        love.graphics.setColor( self.wheels.outerColor )
        love.graphics.circle( self.wheels.mode, self.wheels.locations[1].x, self.wheels.locations[1].y, self.wheels.outerRad, 100 )
        love.graphics.circle( self.wheels.mode, self.wheels.locations[2].x, self.wheels.locations[2].y, self.wheels.outerRad, 100 )

        love.graphics.setColor( self.wheels.innerColor )
        love.graphics.circle( self.wheels.mode, self.wheels.locations[1].x, self.wheels.locations[1].y, self.wheels.innerRad, 100 )
        love.graphics.circle( self.wheels.mode, self.wheels.locations[2].x, self.wheels.locations[2].y, self.wheels.innerRad, 100 )
    end

    if DEBUG and self.debugText ~= nil then
        love.graphics.setColor( 255, 255, 255, 255 * 0.66 )
        love.graphics.printf( self.debugText, 0, self.h + 2, self.w, "left" )
    end
    love.graphics.pop()
end

function Ship:update( dt )
    local g = love.joystick.getJoysticks()[self.gamepad]
    if g ~= nil then
        if g:isGamepadDown( "a", "b", "x", "y", "back", "start" ) then
            self.x = love.window.getWidth()/2 - self.w/2
            self.y = love.window.getHeight()/2 - self.h/2
        end

        local dx = g:getGamepadAxis("leftx")
        local dy = g:getGamepadAxis("lefty")
        local rmulti = g:getGamepadAxis("triggerright")
        local lmulti = g:getGamepadAxis("triggerleft")
        local multiplier = self.multiplier * math.max(rmulti, lmulti) + 1

        --self.debugText = "LMULTI: " .. lmulti .. "\nRMULTI: " .. rmulti .. "\nMULTI: " .. multiplier
        if math.abs(dx) < DEAD_ZONE then
            dx = 0
        end
        if math.abs(dy) < DEAD_ZONE then
            dy = 0
        end

        self.x = self.x + (dx * dt * self.v.x * multiplier)
        self.y = self.y + (dy * dt * self.v.y * multiplier)
    end
end

