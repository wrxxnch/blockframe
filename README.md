# BlockFrame

📦 **BlockFrame** is a **Minetest / Mineclonia** mod that lets you **preview, transform, and precisely place blocks or items** before confirming their placement in the world.

It is designed for **detailed building**, complex structures, scale testing, and accurate positioning.

---

## Features

- Real-time preview using entities (`wielditem`)
- Custom scaling (`size`)
- Rotation in degrees on X, Y, and Z axes (`rotate`)
- Axis-based mirroring (`mirror`)
- Adjustable aim snapping (grid) (`step`)
- Absolute or relative positioning (`pos`)
- Optional collision for previews and placed blocks
- Support for **composite structures** (save & load)
- Undo and delete with restoration
- Works with **any item**, not only blocks
- Remembers the last used item

---

## Commands

### `/blockframe <args>`
Creates or updates a **single preview** of the wielded item.

**Available args:**

- `size=x,y,z` — Item scale  
  - 1 value → x=y=z  
  - 2 values → x, y=z  
- `rotate=x,y,z` — Rotation in degrees
- `mirror=x|y|z` — Axis mirroring
- `pos=x,y,z` — Position offset
- `step=value` — Aim snap (grid)
- `collision=true|false` — Enable collision

**Examples:**
/blockframe size=0.5
/blockframe size=1,0.5 rotate=0,90,0
/blockframe mirror=x rotate=45
/blockframe pos=0,1,0 step=0.25


---

### `/blockframe_set`
Confirms the active preview and **places the block(s)** in the world.

---

### `/blockframe_cancel`
Cancels the active preview without placing anything.

---

### `/blockframe_undo`
Removes the **last block placed** using BlockFrame.

---

### `/blockframe_del [radius=N]`
Deletes placed BlockFrame blocks within a radius.

/blockframe_del radius=3


---

### `/blockframe_del_undo`
Restores blocks removed by the last `/blockframe_del`.

---

### `/blockframe_save <name> [radius=N]`
Saves a **composite structure** (BlockFrame-placed blocks) to a `.bf` file.

/blockframe_save my_house radius=10


---

### `/blockframe_load <name> [args]`
Loads a saved structure as a **composite preview**, allowing global transformations.

**Accepted global args:**
- `size`
- `rotate`
- `mirror`
- `pos`
- `step`
- `collision`

**Example:**
/blockframe_load my_house size=2 rotate=0,90,0


---

### `/blockframe_help`
Shows the in-game help text.

---

## Example Usage

1. Hold a block or item.
2. Create a preview:
/blockframe size=1,0.5 rotate=0,90,0

3. Adjust the position using `pos` or `step`.
4. Confirm:
/blockframe_set

5. Undo if needed:
/blockframe_undo


---

## Mod Files

blockframe/
├── init.lua # Complete mod code (preview, entities, commands, save/load)
├── README.md # This file
└── LICENSE.txt # CC BY 3.0 License


---

## Installation

1. Copy the `blockframe` folder into your Minetest `mods/` directory.
2. Enable the mod in your world settings.
3. Start the world.
4. Use `/blockframe_help` to get started.

---

## License

This mod is distributed under the  
**Creative Commons Attribution 3.0 (CC BY 3.0)** license.

You are free to:
- Use
- Modify
- Redistribute
- Use commercially  

As long as proper credit is given to the original author.

https://creativecommons.org/licenses/by/3.0/
