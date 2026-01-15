# Genshin Impact Cutscene File Cleaner
A lightweight PowerShell utility designed to free up disk space by selectively removing pre-rendered video cutscenes from Genshin Impact. This tool allows you to safely remove files related to specific regions or the unused Twin (Aether/Lumine) while keeping the game playable.
* 🤖 Note: This project is entirely "vibe" coded.
* Current Support: Verified for Genshin Impact 6.3 (Luna 4 Update).

## ⚠️ Compatibility Warning
This script is configured ONLY for the Epic Games Store version.
* Default Path: C:\Program Files\Epic Games\GenshinImpact\games\Genshin Impact game\GenshinImpact_Data\StreamingAssets\VideoAssets\StandaloneWindows64
* Native Launcher Users: This script will not work out of the box. You must manually right-click the script, select "Edit in Notepad", and change the $TargetDir to your specific installation path.
  * If you can not find the folder try searching "ChangeWeather.usm" in file explorer and opening its folder.

## 🚀 Features
- Choose specific categories to delete:
  - Twin-specific files (Aether/Lumine)
  - Region-specific files (Mondstadt, Liyue, Inazuma, Sumeru, Fontaine, Natlan, Nod-Krai)
  - Miscellaneous cutscenes
- Files are moved to the Recycle Bin rather than permanently deleted, allowing for easy restoration.

## 📋 Requirements
* Windows 10 or Windows 11
* PowerShell
* Genshin Impact (Epic Games Version)

## ⚠️ Disclaimers & Important Notes
* USE AT YOUR OWN RISK. 
* Game Updates: When Genshin Impact updates or if you use the "Verify File Integrity" feature, all deleted video files will be re-downloaded. You will need to run this tool again after an update.
* Game Issues: Deleting a video file may break things when playing if you have not seen them before.

## ⚙️ How to Use
1. Download the [latest release](https://github.com/Gottaloveeggs/GenshinImpactCutsceneFileCleaner/releases/tag/Release).
2. Right-click the file and select "Run with PowerShell".
3. Follow the on-screen menu to select which videos you wish to remove.
4. Confirm the selection to move files to the recycle bin.
5. Check and clear recycle bin
