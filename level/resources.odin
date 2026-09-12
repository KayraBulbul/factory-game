package level

import "core:math"
import "core:math/noise"
import "core:math/rand"
import rl "vendor:raylib"

ResourceType :: enum {
	IronOre,
	CopperOre,
	Tree,
}

ResourceTile :: struct {
	texture: rl.Texture2D,
	type:    ResourceType,
	mask:    Bearing_Mask,
}

ResourceMap :: struct {
	width:  int,
	height: int,
	tiles:  [dynamic]ResourceTile,
}

create_resource_map :: proc(width, height: int, seed: ^i64) -> ResourceMap {
	resources := ResourceMap {
		width  = width,
		height = height,
		tiles  = make([dynamic]ResourceTile, width * height),
	}

	noise_scale: f64 = 0.02
	tree := rl.LoadTexture("../assets/tree.png")
	ironOre := rl.LoadTexture("../assets/iron_ore.png")
	copperOre := rl.LoadTexture("../assets/copper_ore.png")
	pass: bool


	for y in 0 ..< height {
		for x in 0 ..< width {
			value := noise.noise_2d(seed^, [2]f64{f64(x) * noise_scale, f64(y) * noise_scale})
			randVal := rand.int_range(0, 10)

			tile: ResourceTile
			if value < 0.8 {
				if randVal > 8 {
					tile.type = .Tree
					tile.texture = tree
				}
			} else if value < 0.85 {
				if randVal >= 7 {
					tile.type = .CopperOre
					tile.texture = copperOre
				}
			} else {
				if randVal >= 7 {
					tile.type = .IronOre
					tile.texture = ironOre
				}
			}

			// Converts 2D position to 1D array
			resources.tiles[y * width + x] = tile
		}
	}

	return resources
}

draw_resources :: proc(resourceGrid: ^ResourceMap, level: ^Level, curr_camera: rl.Camera2D) {
	TILE_SIZE :: 16

	assert(resourceGrid.height == level.height)
	assert(resourceGrid.width == level.width)

	worldWidth := resourceGrid.width * TILE_SIZE
	worldHeight := resourceGrid.height * TILE_SIZE

	visableWidth := f32(rl.GetScreenWidth()) / curr_camera.zoom
	visableHeight := f32(rl.GetScreenHeight()) / curr_camera.zoom

	camera_left := curr_camera.target.x - visableWidth / 2
	camera_top := curr_camera.target.y - visableHeight / 2
	camera_right := curr_camera.target.x + visableWidth / 2
	camera_bot := curr_camera.target.y + visableHeight / 2
	starting_x := math.floor((camera_left + f32(worldWidth) / 2) / TILE_SIZE)
	starting_y := math.floor((camera_top + f32(worldHeight) / 2) / TILE_SIZE)
	ending_x := math.ceil((camera_right + f32(worldWidth) / 2) / TILE_SIZE)
	ending_y := math.ceil((camera_bot + f32(worldHeight) / 2) / TILE_SIZE)

	if starting_x < 0 do starting_x = 0
	if starting_y < 0 do starting_y = 0
	if ending_x > 256 do ending_x = f32(level.width)
	if ending_y > 256 do ending_y = f32(level.height)

	for y in int(starting_y) ..< int(ending_y) {
		for x in int(starting_x) ..< int(ending_x) {
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
