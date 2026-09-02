package animations

import rl "vendor:raylib"

Animation_Name :: enum {
	Run_up,
	Run_down,
	Run_LR,
	Idle,
}

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
	name:          Animation_Name,
}

update_animation :: proc(a: ^Animation) {
	a.frame_timer += rl.GetFrameTime()

	if a.frame_timer > a.frame_length {
		a.current_frame += 1
		a.frame_timer = 0

		if a.current_frame == a.num_frames {
			a.current_frame = 0
		}
	}
}

draw_animation :: proc(a: Animation, pos: rl.Vector2, flip: bool) {
	a_width := f32(a.texture.width)
	a_height := f32(a.texture.height)

	source_width := a_width / f32(a.num_frames)

	source := rl.Rectangle {
		x      = f32(a.current_frame) * source_width,
		y      = 0,
		width  = source_width,
		height = a_height,
	}

	if flip {
		source.width = -source.width
	}

	dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = a_width / f32(a.num_frames),
		height = a_height,
	}

	rl.DrawTexturePro(a.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}

player_run_down: Animation
player_run_up: Animation
player_run_LR: Animation
player_idle: Animation

init :: proc() {
	player_run_down = Animation {
		texture      = rl.LoadTexture("../assets/lilbro_down.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run_down,
	}

	player_run_up = Animation {
		texture      = rl.LoadTexture("../assets/lilbro_up.png"),
		num_frames   = 4,
		frame_length = 0.075,
		name         = .Run_up,
	}

	player_run_LR = Animation {
		texture      = rl.LoadTexture("../assets/lilbro_LR.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run_LR,
	}

	player_idle = Animation {
		texture      = rl.LoadTexture("../assets/lilbro_idle.png"),
		num_frames   = 3,
		frame_length = 0.2,
		name         = .Idle,
	}
}
