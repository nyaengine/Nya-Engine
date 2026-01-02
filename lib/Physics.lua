local Physics = {}

-- physics library cuz GameObject physics is ass

local world
local bodies = {}
local fixtures = {}
local collisionCallbacks = {}

function Physics.init(dx, dy)
    if not love or not love.physics then
        error("love.physics is required for Physics module")
    end
    world = love.physics.newWorld(dx or 0, dy or 9.81 * 64, true)

    world:setCallbacks(function(a, b, contact)
        local fa, fb = a:getUserData(), b:getUserData()
        if fa and fb then
            local ida, idb = fa._id, fb._id
            if ida and idb and collisionCallbacks[ida] then
                for _, cb in ipairs(collisionCallbacks[ida]) do
                    pcall(cb, fa, fb, contact)
                end
            end
            if idb and ida and collisionCallbacks[idb] then
                for _, cb in ipairs(collisionCallbacks[idb]) do
                    pcall(cb, fb, fa, contact)
                end
            end
        end
    end)
end

local function ensureWorld()
    if not world then
        Physics.init()
    end
end

function Physics.update(dt)
    ensureWorld()
    world:update(dt)
end

function Physics.addRectangle(id, x, y, w, h, opts)
    ensureWorld()
    opts = opts or {}
    local bodyType = opts.static and "static" or "dynamic"
    local body = love.physics.newBody(world, x + w/2, y + h/2, bodyType)
    local shape = love.physics.newRectangleShape(w, h)
    local fixture = love.physics.newFixture(body, shape, opts.density or 1)

    if opts.friction then fixture:setFriction(opts.friction) end
    if opts.restitution then fixture:setRestitution(opts.restitution) end

    -- collision categories and masks (16-bit)
    if opts.category then fixture:setCategory(opts.category) end
    if opts.mask then fixture:setMask(opts.mask) end

    local userdata = { _id = id, type = "rectangle", width = w, height = h }
    fixture:setUserData(userdata)
    body:setUserData(userdata)

    bodies[id] = body
    fixtures[id] = fixture
    return body, fixture
end

function Physics.addCircle(id, x, y, radius, opts)
    ensureWorld()
    opts = opts or {}
    local bodyType = opts.static and "static" or "dynamic"
    local body = love.physics.newBody(world, x, y, bodyType)
    local shape = love.physics.newCircleShape(radius)
    local fixture = love.physics.newFixture(body, shape, opts.density or 1)

    if opts.friction then fixture:setFriction(opts.friction) end
    if opts.restitution then fixture:setRestitution(opts.restitution) end

    if opts.category then fixture:setCategory(opts.category) end
    if opts.mask then fixture:setMask(opts.mask) end

    local userdata = { _id = id, type = "circle", radius = radius }
    fixture:setUserData(userdata)
    body:setUserData(userdata)

    bodies[id] = body
    fixtures[id] = fixture
    return body, fixture
end

function Physics.remove(id)
    if fixtures[id] then
        fixtures[id]:destroy()
        fixtures[id] = nil
    end
    if bodies[id] then
        bodies[id]:destroy()
        bodies[id] = nil
    end
    collisionCallbacks[id] = nil
end

function Physics.getBody(id)
    return bodies[id]
end

function Physics.onCollision(id, callback)
    collisionCallbacks[id] = collisionCallbacks[id] or {}
    table.insert(collisionCallbacks[id], callback)
end

function Physics.clear()
    for k,_ in pairs(bodies) do
        Physics.remove(k)
    end
    if world then
        world:destroy()
        world = nil
    end
end

function Physics.debugDraw()
    if not world then return end
    for id, body in pairs(bodies) do
        local ux = body:getX()
        local uy = body:getY()
        for _, f in ipairs(body:getFixtures()) do
            local s = f:getShape()
            local t = s:getType()
            love.graphics.setColor(0,1,0,0.8)
            if t == "polygon" then
                local points = { body:getWorldPoints(s:getPoints()) }
                love.graphics.polygon("line", points)
            elseif t == "circle" then
                love.graphics.circle("line", ux, uy, s:getRadius())
            end
        end
    end
    love.graphics.setColor(1,1,1,1)
end

return Physics
