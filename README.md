# 🎨 Simple Point-and-Click Template

Welcome! This is the **easiest possible way** to make a point-and-click adventure game in Godot 4.

We've handled all the boring code so you can focus on your art and story.

---

## ✨ Features

- **Zero Coding Required**: Just drag, drop, and type.
- **Auto-Discovery**: Just drop your room files in a folder, and they work!
- **Auto-Scaling**: Your game looks great on any screen (mobile, laptop, 4K).
- **Smart Navigation**: Automatic "Back" buttons for sub-rooms.
- **Custom Cursors**: Easily add your own mouse pointers.
- **Debug Mode**: Press F12 to see all hotspots and connections.
- **Auto-Save**: The game remembers where you left off.

---

## 🚀 Quick Start

1. Open the project in Godot.
2. Open `demo/main.tscn`.
3. Press **F5** (or click the "Play" button at the top right).
4. Press **F12** to see the debug overlay!

---

## 🛠️ How to Make Your Game

**Two Ways to Get Started:**
- **🚀 Quick Path**: Use templates (copy & configure) - recommended for beginners

Want to jump right in? Just copy, paste, and configure!

### Starting a New Project

1. **Copy the Main Template**:
   - Duplicate `templates/main_template.tscn`
   - Rename it to `my_game.tscn`
   - In the Inspector, set **Rooms Directory** to where your rooms will live (e.g., `res://rooms`)

2. **Make Your First Room**:
   - Duplicate `templates/room_template.tscn`
   - Move it to your rooms folder (e.g., `rooms/kitchen.tscn`)
   - **Note**: The filename becomes the Room ID! (`kitchen.tscn` → `kitchen`)

3. **Configure Your Room** (all in the Inspector!):
   - Open your new room scene
   - Click the **Background** node and set your image
   - Done!

4. **Add Hotspots**:
   - Duplicate the example hotspot
   - Set **Target Room Id** to where it should go
   - Resize the collision shape to fit your object

5. **Play!**: Press **F5** and explore your game!

---

## 📚 Advanced Features

### 🔙 Automatic Back Buttons
Making a close-up view (like a bookshelf)?
1. Create your sub-room (e.g., `bookshelf.tscn`)
2. In the Inspector, set **Parent Room Id** to the main room (e.g., `bedroom`)
3. That's it! An invisible "Back" button is automatically created at the bottom of the screen.
   - You can adjust its height with **Back Bar Height Percent**.

### 🐞 Debug Mode
Press **F12** while playing to:
- See all invisible hotspots (colored green/red)
- See their IDs and targets
- Check which room you are in

### 🔍 Auto-Discovery
You don't need to register rooms manually!
- The game automatically finds all `.tscn` files in your **Rooms Directory**.
- The **Room ID** is the filename (e.g., `forest_clearing.tscn` → `forest_clearing`).
- Want a different ID? Set **Room Id Override** in the Inspector.

---

## ❓ FAQ

**Q: My room isn't showing up!**
A: Check the **Rooms Directory** setting in your Main scene. Make sure your room is in that folder and ends with `.tscn`.

**Q: How do I change the starting room?**
A: Open your Main scene and change **Starting Room Id**.

**Q: How do I add custom cursors?**
A: In your Main scene Inspector (under **Cursors**):
1. Drag small PNGs (max 128x128) into **Cursor Default** and **Cursor Hover**.
2. Set the **Hotspot** for each (e.g., `0,0` for top-left, `16,16` for center).
*Note: Press F12 to see a red crosshair and verify your cursor alignment!*

**Q: Where is the save file?**
A: It's hidden in your user data folder. To reset, just delete it or change the `Starting Room Id`.

---

## 📜 License
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
