Laser = {}

function Laser:new( x, y, dir, v, color )
    local l = {}
    setmetatable( l, self )
    self.__index = self

    l.x = x
    l.y = y
    l.w = 66
    l.h = 10
    if dir < 0 then
        l.dir = -1
    else
        l.dir = 1
    end
    l.v = v
    l.color = color

    return l
end

function Laser:update( dt )
    self.x = self.x + (self.v * self.dir * dt)

    -- TODO: Collision detection
end

function Laser:draw()
    love.graphics.push()

    love.graphics.translate( self.x, self.y )

    love.graphics.setColor( self.color )
    love.graphics.rectangle( 'fill', 0, 0, self.w, self.h )

    love.graphics.pop()
end

