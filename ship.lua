Ship = {}
--lick.file = "main.lua"

Ship.colors = {
        { 205, 205, 205 },
        { 255, 205, 205 },
        { 205, 255, 205 },
        { 205, 205, 255 }
}

Ship.activeColors = {
}

function Ship:new( x, y, w, h, v, gamepad )
    s = {}
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

    s.body = {
        mode = "fill",
        x = 0, y = 0,
        w = 1, h = 1
    }
    s.colorIndex = 0
    s:setColor( gamepad:getID() % (#Ship.colors + 1) )

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

    return s
end

function Ship:draw()
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
    local g = self.gamepad
    if g ~= nil then
        if g:isGamepadDown( "back", "start" ) then
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
        self.tilt = math.pi/12 * dx

        self.flames.on = math.abs( dx ) > 0 or math.abs( dy ) > 0
        if self.flames.on then
            self.flames.d = math.min(multiplier, 1.66)
        end
        self.dir = dx
    end
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

