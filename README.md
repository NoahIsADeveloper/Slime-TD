<p align="center">
  <img src="assets/sprites/logo.png" alt="Slime TD Logo" width="700"><br>
  A tower defense game created in LOVE2D where you defend your base against waves of slimes.
</p>

## Special Credits
Font: [Pixel Operator](https://www.dafont.com/pixel-operator.font) (Bold) - Jayvee Enaguas <br>

Sound Effects: <br>
 - [click.wav](https://freesound.org/people/BiORNADE/sounds/735803/) <br>
 - [hit.wav](https://freesound.org/people/DmitryKutin0/sounds/806263/) <br>
 - [turretshoot.wav](https://freesound.org/people/eardeer/sounds/402009/) <br>
 - [hyperturretshoot.wav](https://freesound.org/people/hotpin7/sounds/819269/) <br>
 - [moneygain.wav](https://freesound.org/people/LittleRobotSoundFactory/sounds/276106/) <br>
 - [tick.wav](https://freesound.org/people/KorgMS2000B/sounds/54406/) <br>
 - [splashintro.wav](https://freesound.org/people/nikerk/sounds/764513/) <br>

<br>

Music: <br>
 - [mainmenu.ogg](https://freesound.org/people/Xythe/sounds/516912/) <br>

## Official Links
https://github.com/ShibaTheDeveloper/Slime-TD/releases <br>
https://shibathedeveloper.itch.io/slime-td

## Development Setup (Windows Only)
**Note:** If you just want to play the game, use the official links above.
1. Install [Visual Studio Code](https://code.visualstudio.com/download)
2. Install [LOVE2D](https://www.love2d.org/)
3. Install these VSC extensions:
   - [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
   - [LOVE2D Support](https://marketplace.visualstudio.com/items?itemName=pixelbyte-studios.pixelbyte-love2d)

## How to Playtest
- Press `ALT + L` while in any `.lua` file; LOVE2D Support will run the game.
- If that doesn't work, go to the extension settings and set the path to the LOVE2D executable.
- Still not working? Drag the project folder onto the LOVE2D executable directly.

## How to Build
1. Create a folder on your desktop.
2. Create a `.zip` file in that folder.
3. Copy all game files into the `.zip` file. (Excluding .github .git .vscode)
4. Rename the `.zip` file to `.love`.
5. Name the `.love` file whatever you want (e.g., `SlimeTD.love`).
6. Copy `love.exe` into the same folder.
7. Open Command Prompt with administrator permissions.
8. Run the following command (replace `SlimeTD` with your `.love` file name):
   `copy /b love.exe+SlimeTD.love SlimeTD.exe`
9. Copy all DLLs that came with `love.exe` into the same folder.

## Troubleshooting Build
- **Windows Defender Warning / Cannot find the .exe:** The `.exe` might be quarantined. Restore it from quarantine.
- **Missing DLLs:** Make sure the `.exe` and all DLLs are in the same folder.
