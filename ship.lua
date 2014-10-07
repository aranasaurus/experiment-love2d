require( "laser" )

Ship = {}
--lick.file = "main.lua"

Ship.colors = {
        { 185, 185, 185 },
        { 255, 185, 185 },
        { 185, 255, 185 },
        { 185, 185, 255 }
}

Ship.activeColors = {
}

Ship.turboSound = love.audio.newSource( "res/audio/ship_engine_turbo01.mp3", "static" )
Ship.turboSound:setVolume( 0.9 )

Ship.engineSounds = {
    love.audio.newSource( "res/audio/ship_engine01.mp3", "static" ),
    love.audio.newSource( "res/audio/ship_engine02.mp3", "static" )
}

function Ship:new( x, y, w, h, v, gamepad )
    local s = {}
    setmetatable( s, self )
    self.__index = self

    s.x = x
    s.y = y
    s.tilt = 0
    s.w = w
    s.h = h
    s.v = v
    s.dir = 1
    s.multiplier = 3
    s.gamepad = gamepad
    s.lasers = { }

    s.body = {
        mode = "fill",
        x = 0, y = 0,
        w = 1, h = 1
    }
    s.colorIndex = 0
    if gamepad then
        s:setColor( gamepad:getID() % (#Ship.colors + 1) )
    else
        s:setColor( math.random( #Ship.colors ) )
    end

    s.stick = {
        mode = "fill",
        color = { 215, 144, 66 },
        x = w/2,
        y = h * 0.75,
        w = 1/6, -- of self.w
        h = 600 -- of self.h
    }
    s.stick.x = s.stick.x - s.stick.w * s.w/2

    s.fin = {
        mode = "fill",
        color = { 205, 30, 30 },
        x = 0, y = 0,
        w = 0.25, h = 0.75
    }

    s.wing = {
        mode = "fill",
        color = { 205, 30, 30 },
        w = 0.5, h = 0.125
    }
    s.wing.x = w/2 - s.wing.w * w/2
    s.wing.y = h/2 - s.wing.h * h/2

    s.tape = {
        mode = "fill",
        color = { 255, 255, 255, 255 * 0.5 },
        w = s.stick.w * 2,
        h = 0.33
    }
    s.tape.x = s.w/2 - s.w * s.tape.w/2
    s.tape.y = s.wing.y + s.h * s.wing.h + s.h * s.tape.h/6

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

    s.flames = {
        on = false,
        mode = "fill",
        innerColor = { 255, 200, 55, 255 },
        innerScale = 0.66,
        outerColor = { 255, 0, 0, 255 },
        outerScale = 1.0,
        d = 0.25,
        x = 0,
        y = s.h/2,
        w = 1.0,
        h = 1.25
    }

    s.turboSound = Ship.turboSound:clone()
    for i, s in pairs( Ship.engineSounds ) do
        self.engineSounds[i] = s:clone()
        self.engineSounds[i]:setVolume(0.6)
    end

    return s
end

function Ship:draw()
    for _, l in ipairs( self.lasers ) do
        l:draw()
    end

    love.graphics.push()
    love.graphics.origin()

    love.graphics.translate( self.x, self.y )
    love.graphics.rotate( self.tilt )
    if self.dir < 0 then
        love.graphics.scale( -1, 1 )
    end

    function drawRect( item )
        love.graphics.setColor( item.color )
        love.graphics.rectangle( item.mode, item.x, item.y, item.w * self.w, item.h * self.h )
    end

    if self.dir < 0 then
        drawRect( self.body )
        drawRect( self.wing )
        drawRect( self.stick )
        drawRect( self.tape )
    else
        drawRect( self.stick )
        drawRect( self.body )
        drawRect( self.wing )
    end

    if self.flames.on then
        local flameHeight = self.flames.h * self.h
        local flameWidth = self.flames.w * self.w
        function drawFlame( scale, color )
            love.graphics.push()
            love.graphics.setColor( color )
            love.graphics.translate( self.flames.x - (self.flames.x * scale),
                self.flames.y - (self.flames.y * scale) )
            love.graphics.scale( scale )
            love.graphics.polygon( self.flames.mode,
                self.flames.x, self.flames.y,
                self.flames.x, self.flames.y - flameHeight/4,
                self.flames.x - flameWidth/4, self.flames.y - flameHeight/2,
                self.flames.x - flameWidth/4.7, self.flames.y - flameHeight/3.4,
                self.flames.x - flameWidth/2.15, self.flames.y - flameHeight/2.6,
                self.flames.x - flameWidth/2.7, self.flames.y - flameHeight/5.6,
                self.flames.x - flameWidth, self.flames.y,
                self.flames.x - flameWidth/2.7, self.flames.y + flameHeight/5.6,
                self.flames.x - flameWidth/2.15, self.flames.y + flameHeight/2.6,
                self.flames.x - flameWidth/4.7, self.flames.y + flameHeight/3.4,
                self.flames.x - flameWidth/4, self.flames.y + flameHeight/2,
                self.flames.x, self.flames.y + flameHeight/4
            )
            love.graphics.pop()
        end

        drawFlame( self.flames.outerScale * self.flames.d, self.flames.outerColor )
        drawFlame( self.flames.innerScale * self.flames.d, self.flames.innerColor )
    end

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
    for i, l in ipairs( self.lasers ) do
        l:update( dt )
        if l.x < 0 or l.x > W then
            table.remove( self.lasers, i )
        end
    end

    local g = self.gamepad
    local dx = 0.0
    local dy = 0.0
    local dm = 0.0
    local reset = false

    if g ~= nil then
        reset = g:isGamepadDown( "back", "start" )

        dx = g:getGamepadAxis("leftx")
        dy = g:getGamepadAxis("lefty")
        local rmulti = g:getGamepadAxis("triggerright")
        local lmulti = g:getGamepadAxis("triggerleft")
        dm = math.max(rmulti, lmulti)

        if math.abs(dx) < DEAD_ZONE then
            dx = 0
        end
        if math.abs(dy) < DEAD_ZONE then
            dy = 0
        end
    else
        reset = love.keyboard.isDown( "r", "return" )

        if love.keyboard.isDown( "right" ) then
            dx = 1.0
        elseif love.keyboard.isDown( "left" ) then
            dx = -1.0
        else
            dx = 0.0
        end

        if love.keyboard.isDown( "up" ) then
            dy = -1.0
        elseif love.keyboard.isDown( "down" ) then
            dy = 1.0
        else
            dy = 0.0
        end

        if love.keyboard.isDown( " ", "lshift", "rshift" ) then
            dm = 1.0
        else
            dm = 0.0
        end
    end

    if reset then
        self.x = love.window.getWidth()/2 - self.w/2
        self.y = love.window.getHeight()/2 - self.h/2
    end

    local multiplier = self.multiplier * dm + 1.0
    local vx = dx * dt * self.v.x * multiplier
    local vy = dy * dt * self.v.y * multiplier
    self.x = self.x + vx
    self.y = self.y + vy
    self.tilt = math.pi/12 * dx

    local flamesOnLastFrame = self.flames.on
    self.flames.on = math.abs( dx ) > 0 or math.abs( dy ) > 0
    if self.flames.on then
        self.flames.d = math.min(multiplier, 1.66)

        -- Play a random engine sound when changing direction
        if (self.dir <= 0 and dx > 0) or (self.dir >= 0 and dx < 0) then
            self.engineSounds[ math.random(#self.engineSounds) ]:play()
        end
    end

    if dm > 0.5 then
        self.turboSound:play()
    end
    self.dir = dx
end

function Ship:changeColor( dir )
    local curIndex = self.colorIndex

    local startIndex = curIndex + dir
    if startIndex > #Ship.colors then
        startIndex = 1
    elseif startIndex < 1 then
        startIndex = #Ship.colors
    end

    local endIndex = #Ship.colors
    if dir < 0 then
        endIndex = 1
    end

    for i = startIndex, endIndex, dir do
        if not Ship.activeColors[i] then
            self:setColor( i )
            break
        end
    end

    if self.colorIndex == curIndex then
        self:setRandomColor()
    end
end

function Ship:setColor( color )
    if type(color) == "number" then
        if self.colorIndex > 0 then
            Ship.activeColors[self.colorIndex] = false
        end
        Ship.activeColors[color] = true
        self.colorIndex = color
        self.body.color = Ship.colors[color]
    elseif type(color) == "table" then
        if self.colorIndex > 0 then
            Ship.activeColors[self.colorIndex] = false
        end
        self.colorIndex = 0
        self.body.color = color
    else
        print( "Tried to set color of player '" .. self.gamepad:getID() .. "' to '" .. type(color) .. "'" )
    end
end

function Ship:setRandomColor()
    self:setColor( { math.random(255), math.random(255), math.random(255) } )
end

function Ship:fire()
    table.insert( self.lasers, Laser:new( self.x + self.w/2, self.y + self.h/2, self.dir, self.v.x * 2.5, self.body.color ) )
end
