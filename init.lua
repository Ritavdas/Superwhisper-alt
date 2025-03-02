-- Configuration (user can adjust these)
local config = {
    -- Coordinates for the voice button (already determined)
    voiceButtonX = 1411.5546875,
    voiceButtonY = 2354.99609375,
    
    -- Coordinates for the tick button (already determined)
    tickButtonX = 1451.74609375,
    tickButtonY = 2358.09375,
    
    -- Polling settings
    initialWaitTime = 2.0,    -- Initial wait after clicking tick (seconds)
    checkInterval = 1.0,      -- How often to check for text (seconds)
    maxTotalWaitTime = 60,    -- Maximum time to wait (seconds)
    
    -- Adjustable commands
    launcherHotkey = {{"alt"}, "space"},  -- Hotkey to open launcher (Option+Space)
    dismissKey = "escape"                 -- Key to dismiss launcher
}

-- Flag to track recording state
local isRecording = false
local activeTimer = nil

-- Helper to set voice button position
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "V", function()
    local mousePoint = hs.mouse.getAbsolutePosition()
    config.voiceButtonX = mousePoint.x
    config.voiceButtonY = mousePoint.y
    hs.alert.show("Voice button position set!")
    print("Voice button position set to: " .. mousePoint.x .. ", " .. mousePoint.y)
end)

-- Helper to set tick button position
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", function()
    local mousePoint = hs.mouse.getAbsolutePosition()
    config.tickButtonX = mousePoint.x
    config.tickButtonY = mousePoint.y
    hs.alert.show("Tick button position set!")
    print("Tick button position set to: " .. mousePoint.x .. ", " .. mousePoint.y)
end)

-- Function to check for text using the self-cleaning marker method
function checkForTextWithMarker(startTime, tryCount)
    -- Check if we've exceeded our maximum wait time
    if os.time() - startTime > config.maxTotalWaitTime then
        if activeTimer then 
            activeTimer:stop()
            activeTimer = nil
        end
        hs.alert.show("Processing timed out!")
        return
    end
    
    -- Generate a unique marker for this check
    local marker = "@@MARKER_" .. os.time() .. "_" .. math.random(10000, 99999) .. "@@"
    
    -- Store the marker in clipboard
    hs.pasteboard.setContents(marker)
    
    -- Try to select all and copy text from textbox
    hs.eventtap.keyStroke({"cmd"}, "a")
    hs.eventtap.keyStroke({"cmd"}, "c")
    
    -- Check if clipboard changed from our marker
    local newContent = hs.pasteboard.getContents() or ""
    
    -- If clipboard still contains just our marker, there was no text
    if newContent ~= marker and string.len(newContent) > 10 then
        -- We found text!
        if activeTimer then
            activeTimer:stop()
            activeTimer = nil
        end
        
        -- Select all and cut the text
        hs.eventtap.keyStroke({"cmd"}, "a")
        hs.eventtap.keyStroke({"cmd"}, "x")
        
        -- Dismiss the launcher/dialog
        hs.eventtap.keyStroke({}, config.dismissKey)
        
        -- Paste the text into the active application
        hs.timer.doAfter(0.5, function()
            hs.eventtap.keyStroke({"cmd"}, "v")
            hs.alert.show("Text processed and pasted")
        end)
    else
        -- No text found yet
        if tryCount % 5 == 0 then
            hs.alert.show("Still waiting for text... (" .. tryCount .. ")")
        end
        
        -- Schedule next check
        activeTimer = hs.timer.doAfter(config.checkInterval, function()
            checkForTextWithMarker(startTime, tryCount + 1)
        end)
    end
end

-- Main workflow function
hs.hotkey.bind({"ctrl"}, "space", function()
    -- Toggle recording state
    isRecording = not isRecording
    
    if isRecording then
        -- START RECORDING
        -- Press Option+Space to open the launcher
        hs.eventtap.keyStroke(config.launcherHotkey[1], config.launcherHotkey[2])
        
        -- Wait for launcher to appear
        hs.timer.doAfter(0.5, function()
            -- Check if we have configured voice button coordinates
            if config.voiceButtonX and config.voiceButtonY then
                -- Click the voice button
                hs.eventtap.leftClick({x = config.voiceButtonX, y = config.voiceButtonY})
                hs.alert.show("Started recording")
            else
                -- Alert user that setup is needed
                hs.alert.show("Voice button position not set! Use Cmd+Alt+Ctrl+V to set it")
                isRecording = false  -- Reset state
            end
        end)
    else
        -- STOP RECORDING
        -- First, click the tick button if coordinates are set
        if config.tickButtonX and config.tickButtonY then
            hs.eventtap.leftClick({x = config.tickButtonX, y = config.tickButtonY})
            hs.alert.show("Clicked tick button, waiting for processing...")
            
            -- Wait for the initial processing time
            hs.timer.doAfter(config.initialWaitTime, function()
                -- Start trying to detect transcribed text
                checkForTextWithMarker(os.time(), 1)
            end)
        else
            hs.alert.show("Tick button position not set! Use Cmd+Alt+Ctrl+T to set it")
            isRecording = true  -- Reset state
        end
    end
end)

-- Print setup instructions
print("Voice dictation workflow loaded!")
print("Setup instructions:")
print("1. Press Option+Space to open your launcher")
print("2. Position your mouse over the voice button and press Cmd+Alt+Ctrl+V")
print("3. Position your mouse over the tick button and press Cmd+Alt+Ctrl+T")
print("4. After setup, use Ctrl+Space to toggle recording")
