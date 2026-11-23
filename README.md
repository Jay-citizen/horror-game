# Untitled Horror Sandbox (Godot 4.3+)

## Run
1. Install Godot 4.3 or newer (standard build).
2. Project Manager -> Import -> select `project.godot` -> Run (F5).

## Day 1 status (NOT yet run in Godot: written without engine access)
Implemented: chunked voxel terrain (16x16, height 48, hidden-face culling, one trimesh collider per chunk),
trees, caves, coal/iron/copper ore, first-person controller, DDA block targeting, timed mining,
block placement with overlap check, 9-slot hotbar HUD, flashlight, fog + sun, chunk streaming,
chunk-based edit saving to user://world_edits.dat (persists across restarts).

Controls: WASD, Shift, Ctrl, Space, LMB mine (hold), RMB place, 1-9/wheel, F, Esc.

## Next
Day 2: inventory UI, crafting, day/night, survival stats, cabin. Day 3: ENet authoritative server.
