# Superwhisper-alt

A Hammerspoon script for macOS to automate voice dictation workflow.

## Features

- Uses keyboard shortcuts to automate voice dictation
- Automatically starts recording when triggered
- Automatically stops recording, waits for transcription, and pastes the result
- Customizable button positions and timing parameters

## Requirements

- macOS
- [Hammerspoon](https://www.hammerspoon.org/)
- Any app with voice dictation capability (configured for ChatGPT in the default setup)

## Installation

1. Install Hammerspoon if you haven't already:
   ```
   brew install hammerspoon
   ```
   Or download from [hammerspoon.org](https://www.hammerspoon.org/)

2. Clone this repository:
   ```
   git clone https://github.com/yourusername/voice-dictation-automator.git
   ```

3. Copy or symlink the `init.lua` file to your Hammerspoon configuration directory:
   ```
   ln -s /path/to/voice-dictation-automator/init.lua ~/.hammerspoon/init.lua
   ```
   
   Or if you already have an init.lua file, copy the contents into your existing file.

4. Reload your Hammerspoon configuration.

## Setup

1. Open your dictation app (e.g., ChatGPT)
2. Press Option+Space to open the launcher
3. Position your mouse over the voice button (without clicking) and press `Cmd+Alt+Ctrl+V` to set its position
4. Position your mouse over the tick/confirmation button and press `Cmd+Alt+Ctrl+T` to set its position
5. Now you're ready to use the script!

## Usage

1. Press `Ctrl+Space` to toggle recording:
   - First press: Opens the launcher, clicks the voice button, and starts recording
   - Second press: Clicks the tick button, waits for processing, then cuts and pastes the text

## Configuration

You can adjust these parameters in the `config` table at the top of the script:

- `initialWaitTime`: Initial wait time after clicking the tick button (seconds)
- `checkInterval`: How often to check for text (seconds)
- `maxTotalWaitTime`: Maximum time to wait for text processing (seconds)
- `launcherHotkey`: Hotkey to open the launcher (default: Option+Space)
- `dismissKey`: Key to dismiss the launcher (default: Escape)

## Troubleshooting

- If the script isn't finding the buttons, try setting the positions again with `Cmd+Alt+Ctrl+V` and `Cmd+Alt+Ctrl+T`
- If the script isn't detecting text correctly, try increasing the `initialWaitTime`
- Check the Hammerspoon console for error messages

## How It Works

This script uses a unique approach to detect when text has been transcribed:

1. When you press Ctrl+Space to start recording:
   - It triggers Option+Space to open your launcher
   - It clicks the voice button at the coordinates you set

2. When you press Ctrl+Space again to stop recording:
   - It clicks the tick button at the coordinates you set
   - It waits for the initial processing time
   - It uses a clever marker technique to detect when text appears:
     - It places a unique marker in your clipboard
     - It tries to select and copy text from the textbox
     - If the clipboard changes from our marker, text has appeared
   - Once text is detected, it cuts the text and pastes it to your active application

This approach ensures reliable text detection without relying on fixed delays or complicated visual detection methods.
