package level

import "core:math/noise"
import rl "vendor:raylib"

TileType :: enum {
	Water,
	Grass,
	Mountain,
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

create_level_grid :: proc(width, height: int, seed: i64) -> Level {
	level := Level {
		width  = width,
		height = height,
		tiles  = make([dynamic]Tile, width * height),
	}

	noise_scale: f64 = 0.05
	water := rl.LoadTexture("../assets/water.png")
	grass := rl.LoadTexture("../assets/grass.png")
	mountain := rl.LoadTexture("../assets/mountain.png")

	for y in 0 ..< height {
		for x in 0 ..< width {
			value := noise.noise_2d(seed, [2]f64{f64(x) * noise_scale, f64(y) * noise_scale})

			tile: Tile
			if value < -0.15 {
				tile.type = .Water
				tile.texture = water
			} else if value < 0.40 {
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

	return level
}

draw_level :: proc(level: ^Level) {
	TILE_SIZE :: 16

	for y in 0 ..< level.height {
		for x in 0 ..< level.width {
			tile := level.tiles[y * level.width + x]

			world_x := x * TILE_SIZE
			world_y := y * TILE_SIZE

			rl.DrawTextureEx(tile.texture, {f32(world_x), f32(world_y)}, 0, 4.0, rl.WHITE)
		}
	}
}
