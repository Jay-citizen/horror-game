extends Node
# Block definitions (data-driven). "time" = seconds to mine, "drop" = item id received.
const AIR = 0
const GRASS = 1
const DIRT = 2
const STONE = 3
const SAND = 4
const WOOD = 5
const LEAVES = 6
const COAL = 7
const IRON = 8
const COPPER = 9
const PLANKS = 10

var DATA := {
	1: {"name": "Grass", "color": Color(0.28, 0.5, 0.2), "time": 0.6, "drop": 2},
	2: {"name": "Dirt", "color": Color(0.42, 0.3, 0.2), "time": 0.5, "drop": 2},
	3: {"name": "Stone", "color": Color(0.5, 0.5, 0.52), "time": 1.6, "drop": 3},
	4: {"name": "Sand", "color": Color(0.8, 0.74, 0.5), "time": 0.4, "drop": 4},
	5: {"name": "Wood", "color": Color(0.38, 0.26, 0.15), "time": 1.0, "drop": 5},
	6: {"name": "Leaves", "color": Color(0.15, 0.35, 0.15), "time": 0.2, "drop": 6},
	7: {"name": "Coal", "color": Color(0.2, 0.2, 0.22), "time": 2.2, "drop": 7},
	8: {"name": "Iron", "color": Color(0.7, 0.55, 0.45), "time": 2.8, "drop": 8},
	9: {"name": "Copper", "color": Color(0.75, 0.45, 0.25), "time": 2.8, "drop": 9},
	10: {"name": "Planks", "color": Color(0.65, 0.5, 0.3), "time": 0.8, "drop": 10},
}
