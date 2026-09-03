package level

import "core:fmt"
import "core:math/noise"
import rl "vendor:raylib"

TileType :: enum {
	Water,
	Grass,
	Mountain,
	IronOre,
	CopperOre,
	Tree,
	Air,
}

Tile :: struct {
	texture: rl.Texture2D,
	type:    TileType,
}

Level :: struct {
	width:  int,
	height: int,
	tiles:  [dynamic]Tile,
}

create_level_grid :: proc(width, height: int, seed: ^i64) -> Level {
	level := Level {
		width  = width,
		height = height,
		tiles  = make([dynamic]Tile, width * height),
	}

	noise_scale: f64 = 0.02
	water := rl.LoadTexture("../assets/water.png")
	grass := rl.LoadTexture("../assets/grass.png")
	mountain := rl.LoadTexture("../assets/mountain.png")
	sandR := rl.LoadTexture("../assets/grassSandBlendR.png")
	sandL := rl.LoadTexture("../assets/grassSandBlendL.png")
	sandB := rl.LoadTexture("../assets/grassSandBlendB.png")
	sandT := rl.LoadTexture("../assets/grassSandBlendT.png")
	sandTR := rl.LoadTexture("../assets/GrassSandBlendTR.png")
	sandBR := rl.LoadTexture("../assets/grassSandBlendBR.png")
  sandBL := rl.LoadTexture("../assets/grassSandBlendBL.png")
  sandTL := rl.LoadTexture("../assets/grassSandBlendTL.png")
	pass: bool

	for i in 0 ..< 3 {
		for y in 0 ..< height {
			for x in 0 ..< width {
				value := noise.noise_2d(seed^, [2]f64{f64(x) * noise_scale, f64(y) * noise_scale})

				tile: Tile
				if value < -0.02 {
					tile.type = .Water
					tile.texture = water
				} else if value < 0.90 {
					tile.type = .Grass
					tile.texture = grass
				} else {
					tile.type = .Mountain
					tile.texture = mountain
				}

				// Converts 2D position to 1D array
				level.tiles[y * width + x] = tile
			}
		}

		mid_x := width / 2
		mid_y := height / 2
		grass_count: int
		for y in mid_y - 3 ..< mid_y + 4 {
			for x in mid_x - 3 ..< mid_x + 4 {
				if level.tiles[y * width + x].type == .Grass {
					grass_count += 1
				}
			}
		}

		if grass_count >= 35 {
			pass = true
			fmt.printfln("Using seed: %d", seed^)
			break
		} else {
			fmt.printfln("Seed: %d didn't work, incrementing seed...", seed^)
			seed^ += 1
		}
	}

	// Forces 7x7 grass land on spawn after 3 seed retries
	if !pass {
		mid_x := width / 2
		mid_y := height / 2
		for y in mid_y - 3 ..< mid_y + 4 {
			for x in mid_x - 3 ..< mid_x + 4 {
				level.tiles[y * width + x].type = .Grass
				level.tiles[y * width + x].texture = grass
			}
		}
	}

	for y in 0 ..< level.height {
		for x in 0 ..< level.width {
			right := level.tiles[y * level.width + (x + 1 if x + 1 < level.width else x)]
			left := level.tiles[y * level.width + (x - 1 if x - 1 > 0 else x)]
			bottom := level.tiles[(y + 1 if y + 1 < level.height else y) * level.width + x]
			top := level.tiles[(y - 1 if y - 1 > 0 else y) * level.width + x]

			if right.type == .Water && level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandR
			}
			if left.type == .Water && level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandL
			}
			if bottom.type == .Water && level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandB
			}
			if top.type == .Water && level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandT
			}
			if top.type == .Water &&
			   right.type == .Water &&
			   level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandTR
			}
			if bottom.type == .Water &&
			   right.type == .Water &&
			   level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandBR
			}
			if bottom.type == .Water &&
			   left.type == .Water &&
			   level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandBL
			}
			if top.type == .Water &&
			   left.type == .Water &&
			   level.tiles[y * level.width + x].type == .Grass {
				level.tiles[y * level.width + x].texture = sandTL
			}
		}
	}

	return level
}

draw_level :: proc(level: ^Level) {
	TILE_SIZE :: 16

	worldWidth := level.width * TILE_SIZE
	worldHeight := level.height * TILE_SIZE

	for y in 0 ..< level.height {
		for x in 0 ..< level.width {
			tile := level.tiles[y * level.width + x]

			world_x := x * TILE_SIZE - worldWidth / 2
			world_y := y * TILE_SIZE - worldHeight / 2

			rl.DrawTextureEx(tile.texture, {f32(world_x), f32(world_y)}, 0, 1.0, rl.WHITE)
		}
	}
}
