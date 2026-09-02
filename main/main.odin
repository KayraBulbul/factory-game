package main

import rl "vendor:raylib"

import animations "../animations"
import level "../level"

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

main :: proc() {
	rl.InitWindow(1920, 1080, "Factory Game")
	// rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(240)
	player_pos := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	camera_pos := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	player_vel: rl.Vector2
	player_flip: bool
	player_direction: Direction
	player_is_moving: bool
	current_anim: animations.Animation

	animations.init()
	level_grid := level.create_level_grid(5, 5, 12345)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({110, 184, 168, 255})


		if rl.IsKeyDown(.LEFT) {
			player_vel.x = -200
			player_direction = .Left
		} else if rl.IsKeyDown(.RIGHT) {
			player_vel.x = 200
			player_direction = .Right
		} else {
			player_vel.x = 0
		}

		if rl.IsKeyDown(.UP) {
			player_vel.y = -200
			player_direction = .Up
		} else if rl.IsKeyDown(.DOWN) {
			player_vel.y = 200
			player_direction = .Down
		} else {
			player_vel.y = 0
		}

		if rl.IsKeyDown(.A) {
			camera_pos.x += -200 * rl.GetFrameTime()
		} else if rl.IsKeyDown(.D) {
			camera_pos.x += 200 * rl.GetFrameTime()
		}

		if rl.IsKeyDown(.W) {
			camera_pos.y += -200 * rl.GetFrameTime()
		} else if rl.IsKeyDown(.S) {
			camera_pos.y += 200 * rl.GetFrameTime()
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

		// diagonal speed normalisation probably done really shittly and not even accurate tbh
		if player_vel.x != 0 && player_vel.y != 0 {
			if player_vel.x < 0 {
				player_vel.x = -150
			} else {
				player_vel.x = 150
			}

			if player_vel.y < 0 {
				player_vel.y = -150
			} else {
				player_vel.y = 150
			}
		}

		player_pos += player_vel * rl.GetFrameTime()

		camera := rl.Camera2D {
			offset = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
			target = camera_pos,
			zoom   = 4,
		}

		rl.BeginMode2D(camera)
		level.draw_level(&level_grid)
		animations.update_animation(&current_anim)
		animations.draw_animation(current_anim, player_pos, player_flip)
		rl.EndMode2D()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
