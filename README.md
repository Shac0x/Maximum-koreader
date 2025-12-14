# Maximun Plugin for KOReader

## Overview
Maximun is a plugin designed to enhance the manga reading experience on KOReader. It introduces a grid-based zoom functionality and automatic page rotation for landscape pages. Compatible with CBZ, CBR and PDF formats.

---

## Screenshots

Below are examples of the plugin in action:

- **Without Zoom:**

![Manga without zoom](img/Img1.png)

- **With Zoom:**

![Manga with zoom](img/Img2.png)

- **Plugin Menu:**

![Plugin Menu](img/Menu1.png)

- **Plugin Settings:**

![Plugin Settings](img/Menu2.png)

---

## Features
- **Grid View**: Divides the screen into four quadrants (2x2) for easy navigation.
- **Zoom Functionality**: Two-finger tap on any quadrant to zoom it to fullscreen.
- **Auto-rotate**: Automatically rotates landscape pages to landscape orientation.
- **Rotation Direction**: Choose between clockwise (90°) or counter-clockwise (270°) rotation.
- **Persistent Settings**: Hold any option to save it as default.
- **Toggle Modes**: Enable or disable grid mode and auto-rotate independently.
- **Supported Formats**: Works with CBZ, CBR and PDF files.

---

## How to Use

### Grid Mode
1. Open a CBZ, CBR or PDF file.
2. Enable grid mode from the menu (Maximum > Enable Grid Mode).
3. Two-finger tap on any quadrant to zoom in.
4. Single tap or two-finger tap again to return to normal view.

### Auto-rotate
1. Enable auto-rotate from the menu (Maximum > Auto-rotate landscape pages).
2. Choose rotation direction (Maximum > Rotation direction).
3. Landscape pages will automatically rotate when navigating.

### Save Defaults
- Hold any option to save it as the default setting.

---

## Installation
1. Copy the `maximun.koplugin` folder to the KOReader plugins directory.
2. Restart KOReader to load the plugin.

---

## Menu Options
- **Enable Grid Mode**: Activates the grid view for supported files.
- **Auto-rotate landscape pages**: Automatically rotates landscape pages.
- **Rotation direction**: Choose clockwise or counter-clockwise rotation.
- **About**: Displays information about the plugin.

---

## File Structure
```
maximun.koplugin/
├── _meta.lua       # Plugin metadata
├── main.lua        # Main plugin coordinator
├── autorotate.lua  # Auto-rotation module
├── grid.lua        # Grid zoom module
├── menu.lua        # Menu module
└── settings.lua    # Persistent settings module
```

---

## Limitations
- Only supports CBZ, CBR and PDF files.
- Requires a touch-enabled device.

---

## Credits
- Grid functionality by @shac0x
- Auto-rotate based on [koreader-autorotate](https://github.com/Extraltodeus/koreader-autorotate) by @Extraltodeus
