package level

import "core:math/noise"
import "core:math/rand"
import rl "vendor:raylib"


create_resource_map :: proc(width, height: int, seed: ^i64) -> Level {
	resources := Level {
		width  = width,
		height = height,
		tiles  = make([dynamic]Tile, width * height),
	}

	noise_scale: f64 = 0.02
	tree := rl.LoadTexture("../assets/tree.png")
	ironOre := rl.LoadTexture("../assets/iron_ore.png")
	copperOre := rl.LoadTexture("../assets/copper_ore.png")
	air := rl.LoadTexture("../assets/air.png")
	pass: bool


	for i in 0 ..< 3 {
		for y in 0 ..< height {
			for x in 0 ..< width {
				value := noise.noise_2d(seed^, [2]f64{f64(x) * noise_scale, f64(y) * noise_scale})
	      randVal := rand.int_range(0, 10)

				tile: Tile
				if value < 0.8 {
					if randVal > 8 {
						tile.type = .Tree
						tile.texture = tree
					} else {
						tile.type = .Air
						tile.texture = air
					}
				} else if value < 0.85 {
					if randVal >= 7 {
						tile.type = .CopperOre
						tile.texture = copperOre
					} else {
						tile.type = .Air
						tile.texture = air
					}
				} else {
					if randVal >= 7 {
						tile.type = .IronOre
						tile.texture = ironOre
					} else {
						tile.type = .Air
						tile.texture = air
					}
				}

				// Converts 2D position to 1D array
				resources.tiles[y * width + x] = tile
			}
		}
	}

	return resources
}

draw_resources :: proc(resourceGrid, level: ^Level) {
	TILE_SIZE :: 16

	worldWidth := resourceGrid.width * TILE_SIZE
	worldHeight := resourceGrid.height * TILE_SIZE

	for y in 0 ..< resourceGrid.height {
		for x in 0 ..< resourceGrid.width {
			resourceTile := resourceGrid.tiles[y * level.width + x]
			levelTile := level.tiles[y * level.width + x]

			world_x := x * TILE_SIZE - worldWidth / 2
			world_y := y * TILE_SIZE - worldHeight / 2

			if levelTile.type == .Grass {
				rl.DrawTextureEx(
					resourceTile.texture,
					{f32(world_x), f32(world_y)},
					0,
					1.0,
					rl.WHITE,
				)
			}
		}
	}
}
