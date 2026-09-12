package main

import "core:math"
import rl "vendor:raylib"

import animations "../animations"
import level "../level"

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

touches_water :: proc(grid: ^level.Level, collider: rl.Rectangle) -> bool {
	half_width := f32(grid.width * 16) / 2
	half_height := f32(grid.height * 16) / 2

	left := int(math.floor((collider.x + half_width) / 16))
	right := int(math.floor((collider.x + collider.width + half_width) / 16))
	top := int(math.floor((collider.y + half_height) / 16))
	bottom := int(math.floor((collider.y + collider.height + half_height) / 16))

	for y in top ..< bottom + 1 {
		for x in left ..< right + 1 {
			if x < 0 || x >= grid.width || y < 0 || y >= grid.height {
				continue
			}

			tile := grid.tiles[y * grid.width + x]
			if tile.type == .Water && rl.CheckCollisionRecs(collider, tile.collider) {
				return true
			}
		}
	}

	return false
}

main :: proc() {
	rl.InitWindow(1920, 1080, "Factory Game")
	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(240)
	player_pos: rl.Vector2
	camera_pos: rl.Vector2
	player_vel: rl.Vector2
	player_flip: bool
	player_direction: Direction
	player_is_moving: bool
	camera_attached := true
	curr_camera: rl.Camera2D

	animations.init()
	current_anim := animations.player_idle
	seed: i64 = 12345
	level_height := 256
	level_width := 256
	level_grid := level.create_level_grid(level_width, level_height, &seed)
	resource_grid := level.create_resource_map(level_width, level_height, &seed)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({110, 184, 168, 255})

		player_collider := rl.Rectangle {
			player_pos.x - f32(current_anim.texture.height / 2),
			player_pos.y - f32(current_anim.texture.height / 4),
			f32(int(current_anim.texture.width) / current_anim.num_frames),
			f32(current_anim.texture.height / 4),
		}

		// Player Movement
		if rl.IsKeyDown(.LEFT) {
			player_vel.x = -100
			player_direction = .Left
		} else if rl.IsKeyDown(.RIGHT) {
			player_vel.x = 100
			player_direction = .Right
		} else {
			player_vel.x = 0
		}
		if rl.IsKeyDown(.UP) {
			player_vel.y = -100
			player_direction = .Up
		} else if rl.IsKeyDown(.DOWN) {
			player_vel.y = 100
			player_direction = .Down
		} else {
			player_vel.y = 0
		}

		// Camera Movement
		if rl.IsKeyDown(.A) {
			camera_pos.x += -100 * rl.GetFrameTime()
		} else if rl.IsKeyDown(.D) {
			camera_pos.x += 100 * rl.GetFrameTime()
		}
		if rl.IsKeyDown(.W) {
			camera_pos.y += -100 * rl.GetFrameTime()
		} else if rl.IsKeyDown(.S) {
			camera_pos.y += 100 * rl.GetFrameTime()
		}

		// Camera attached toggle
		if rl.IsKeyPressed(.F) {
			if camera_attached {
				camera_attached = false
			} else {
				camera_attached = true
			}
			camera_pos = player_pos
		}

		player_is_moving = player_vel.x != 0 || player_vel.y != 0

		if player_is_moving {
			switch player_direction {
			case .Up:
				if current_anim.name != .Run_up {
					current_anim = animations.player_run_up
				}
			case .Down:
				if current_anim.name != .Run_down {
					current_anim = animations.player_run_down
				}
			case .Right:
				player_flip = true
				if current_anim.name != .Run_LR {
					current_anim = animations.player_run_LR
				}
			case .Left:
				player_flip = false
				if current_anim.name != .Run_LR {
					current_anim = animations.player_run_LR
				}
			}
		} else {
			if current_anim.name != .Idle {
				current_anim = animations.player_idle
			}
			player_flip = false
		}

		if player_vel.x != 0 && player_vel.y != 0 {
			player_vel *= 0.70710678
		}

		old_x := player_collider.x
		player_collider.x += player_vel.x * rl.GetFrameTime()

		if touches_water(&level_grid, player_collider) {
			player_collider.x = old_x
			player_vel.x = 0
		} else {
			player_pos.x += player_vel.x * rl.GetFrameTime()
		}

		old_y := player_collider.y
		player_collider.y += player_vel.y * rl.GetFrameTime()

		if touches_water(&level_grid, player_collider) {
			player_collider.y = old_y
			player_vel.y = 0
		} else {
			player_pos.y += player_vel.y * rl.GetFrameTime()
		}

		detachedCamera := rl.Camera2D {
			offset = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
			target = camera_pos,
			zoom   = 4,
		}
		attachedCamera := rl.Camera2D {
			offset = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
			target = player_pos,
			zoom   = 4,
		}

		if camera_attached {
			rl.BeginMode2D(attachedCamera)
			curr_camera = attachedCamera
		} else {
			rl.BeginMode2D(detachedCamera)
			curr_camera = detachedCamera
		}

		level.draw_level(&level_grid, curr_camera)
		level.draw_resources(&resource_grid, &level_grid, curr_camera)
		animations.update_animation(&current_anim)
		animations.draw_animation(current_anim, player_pos, player_flip)
		rl.DrawRectangleRec(player_collider, {0, 255, 0, 100})
		rl.EndMode2D()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
