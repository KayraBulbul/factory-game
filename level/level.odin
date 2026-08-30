package level

import rl "vendor:raylib"
import "core:math/noise"

create_level_grid :: proc() -> [dynamic]f32 {
	levelWidth :: 8
	levelHeight :: 8

	seed := i64(12345)
	scale := 0.2

	grid: [dynamic]f32

	for i := 0; i < levelHeight * levelWidth; i += 1 {
		x := i % levelWidth
		y := i / levelWidth

		value := noise.noise_2d(seed, noise.Vec2{f64(x) * scale, f64(y) * scale})

		append(&grid, value)
	}

	return grid
}

draw_level :: proc(level_grid: [dynamic]f32) {
	for value in level_grid {
		if value < -0.2 {
			// water
		} else if value < 0.4 {
			// grass
		} else {
			// mountain
		}
	}

}
