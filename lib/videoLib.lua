local videoLib = {}

-- Function to load and play a video
function videoLib.loadVideo(videoPath)
    -- Ensure the video file exists
    if not love.filesystem.getInfo(videoPath) then
        error("Video file not found: " .. videoPath)
    end

    -- Load the video
    local video = love.graphics.newVideo(videoPath)

    -- Start playing the video
    video:play()

    return video
end

-- Function to draw the video on the screen
function videoLib.drawVideo(video, x, y, width, height)
    if video:isPlaying() then
        love.graphics.draw(video, x or 0, y or 0, 0, width and (width / video:getWidth()) or 1, height and (height / video:getHeight()) or 1)
    end
end

-- Function to stop and release the video
function videoLib.stopVideo(video)
    if video then
        video:stop()
    end
end

return videoLib