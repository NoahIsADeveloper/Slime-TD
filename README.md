<p align="center">
  <img src="assets/sprites/logo.png" alt="Slime TD Logo" width="700"><br>
  <h2>A tower defense game created in LOVE2D, <br> 
  where you defend your base against waves of slimes.</h2>
</p>

<br><br>

## Official Links
https://shibathedeveloper.itch.io/slime-td

## Development Setup (Windows Only)
**Note:** If you just want to play the game, use the official links above.  
1. Install [Visual Studio Code](https://code.visualstudio.com/download)  
2. Install [LOVE2D](https://www.love2d.org/)  
3. Install these VS Code extensions:  
   - [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)  
   - [LOVE2D Support](https://marketplace.visualstudio.com/items?itemName=pixelbyte-studios.pixelbyte-love2d)  

## How to Playtest
- Press `ALT + L` while in any `.lua` file; LOVE2D Support will run the game.  
- If that doesn't work, go to the extension settings and set the path to the LOVE2D executable.  
- Still not working? Drag the project folder onto the LOVE2D executable directly.  

## How to Build
1. Create a folder on your desktop.  
2. Create a `.zip` file in that folder.  
3. Copy all game files into the `.zip` file.  
4. Rename the `.zip` file to `.love`.  
5. Name the `.love` file whatever you want (e.g., `SlimeTD.love`).  
6. Copy `love.exe` into the same folder.  
7. Open Command Prompt with administrator permissions.  
8. Run the following command (replace `SlimeTD` with your `.love` file name):
   copy /b love.exe+SlimeTD.love SlimeTD.exe
9. Copy all DLLs that came with `love.exe` into the same folder.  

## Troubleshooting Build
- **Windows Defender Warning:** The `.exe` might be quarantined. Restore it from quarantine.  
- **Missing DLLs:** Make sure the `.exe` and all DLLs are in the same folder.  
