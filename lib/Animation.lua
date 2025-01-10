local Animation = {}
Animation.__index = Animation

-- Constructor for Animation
function Animation.new(image, frameWidth, frameHeight, frameCount, frameDuration)
    local self = setmetatable({}, Animation)
    self.image = image
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
    self.frameCount = frameCount
    self.frameDuration = frameDuration
    self.currentFrame = 1
    self.timeElapsed = 0
    return self
end

-- Update the animation frame based on elapsed time
function Animation:update(dt)
    self.timeElapsed = self.timeElapsed + dt
    if self.timeElapsed >= self.frameDuration then
        self.timeElapsed = self.timeElapsed - self.frameDuration
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > self.frameCount then
            self.currentFrame = 1 -- Loop back to the first frame
        end
    end
end

-- Draw the current frame of the animation at a specific position
function Animation:draw(x, y)
    local frameX = (self.currentFrame - 1) * self.frameWidth
    local frameY = 0
    love.graphics.draw(self.image, frameX, frameY, 0, 1, 1, self.frameWidth / 2, self.frameHeight / 2)
end

return Animation
