package level

import "core:math/noise"

Tile :: enum {
	Water,
	Grass,
	Mountain,
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

	for y in 0 ..< height {
		for x in 0 ..< width {
			value := noise.noise_2d(seed, [2]f64{f64(x) * noise_scale, f64(y) * noise_scale})

			tile: Tile
			if value < -0.15 {
				tile = .Water
			} else if value < 0.40 {
				tile = .Grass
			} else {
				tile = .Mountain
			}

      // Converts 2D position to 1D array
			level.tiles[y * width + x] = tile
		}
	}

	return level
}

draw_level :: proc(level: ^Level) {
  TILE_SIZE :: 32

  for y in 0..<level.height {
    for x in 0..<level.width {
      tile := level.tiles[y * level.width + x]

      screen_x := x * TILE_SIZE
      screen_y := y * TILE_SIZE

      switch tile {
      case .Water:
        // Water drawTexture
      case .Grass:
        // Grass drawTexture
      case .Mountain:
        // Mountain drawTexture
      }
    }
  }
}
