shader_type canvas_item;

// True Nation - 2D Pixel Tactical Ocean
// Warna laut mengikuti palet samudra tropis: biru tua di palung, biru laut dalam,
// lalu toska jernih di paparan dangkal (dibentuk oleh Coastal Shelf tiap pulau).
// Seluruh gelombang dan warna di-snap ke grid piksel agar tetap terasa 2D pixel.

uniform vec4 deep_trench_color : source_color = vec4(0.008, 0.055, 0.145, 1.0);
uniform vec4 shelf_color : source_color = vec4(0.020, 0.145, 0.290, 1.0);
uniform vec4 shallow_azure : source_color = vec4(0.035, 0.290, 0.430, 1.0);
uniform vec4 crest_foam_color : source_color = vec4(0.36, 0.76, 0.82, 0.16);
uniform vec4 wave_shimmer_color : source_color = vec4(0.52, 0.86, 0.94, 0.18);
uniform vec4 grid_line_color : source_color = vec4(0.32, 0.64, 0.82, 0.075);
uniform vec4 equator_line_color : source_color = vec4(0.88, 0.74, 0.32, 0.13);

uniform float wave_speed : hint_range(0.01, 0.5) = 0.07;
uniform float grid_step : hint_range(100.0, 800.0) = 280.0;
uniform float pixel_size : hint_range(1.0, 12.0) = 6.0;
uniform float color_steps : hint_range(4.0, 64.0) = 22.0;
uniform float equator_y = -92.0;
uniform vec2 depth_center = vec2(0.0, 0.0);

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// Harmoni gelombang laut bertingkat (multi-harmonic directional swell)
float ocean_swell(vec2 p, float t) {
	float w1 = sin(p.x * 0.012 + p.y * 0.007 + t * 0.85);
	float w2 = cos(-p.x * 0.009 + p.y * 0.015 - t * 0.65);
	float w3 = sin(p.x * 0.022 + p.y * 0.018 + t * 1.15);
	float w4 = cos(p.x * 0.038 - p.y * 0.032 - t * 0.95);
	float micro = sin(p.x * 0.075 + p.y * 0.065 + t * 1.7) * 0.5 + 0.5;

	float combined = (w1 * 0.42 + w2 * 0.32 + w3 * 0.18 + w4 * 0.08);
	return combined + (micro * 0.12 - 0.06);
}

void fragment() {
	// Posisi dunia, lalu snap ke grid piksel.
	vec2 world = world_pos;
	vec2 pos = floor(world / pixel_size) * pixel_size + pixel_size * 0.5;
	float t = TIME * wave_speed;

	// 1. Batimetri: palung dalam -> paparan benua.
	float theater_dist = length((pos - depth_center) * vec2(0.85, 1.35)) / 2900.0;
	float seabed = sin(pos.x * 0.0017 + 1.3) * cos(pos.y * 0.0021 - 0.7) * 0.5 + 0.5;
	float depth = smoothstep(0.10, 0.95, clamp(theater_dist + seabed * 0.08, 0.0, 1.0));

	vec4 base_water = mix(shallow_azure, shelf_color, smoothstep(0.0, 0.42, depth));
	base_water = mix(base_water, deep_trench_color, smoothstep(0.38, 0.96, depth));

	// 2. Aliran gelombang dan kilau permukaan.
	float wave_val = ocean_swell(pos, t);
	float crest = smoothstep(0.30, 0.78, wave_val);
	float shimmer = pow(clamp(wave_val * 0.5 + 0.5, 0.0, 1.0), 3.6);

	vec4 water = mix(base_water, crest_foam_color, crest * 0.55);
	water = mix(water, wave_shimmer_color, shimmer * 0.70);

	// 3. Grid navigasi peta laut taktis.
	vec2 grid_pos = abs(fract(pos / grid_step + 0.5) - 0.5) * grid_step;
	float grid_line = 1.0 - smoothstep(0.0, 1.2, min(grid_pos.x, grid_pos.y));
	float cross_mask = step(grid_pos.x, 5.0) * step(grid_pos.y, 5.0);
	vec4 final_map = mix(water, vec4(grid_line_color.rgb, 1.0),
						 (grid_line * 0.70 + cross_mask * 0.95) * grid_line_color.a);

	// 4. Garis khatulistiwa.
	if (abs(pos.y - equator_y) < pixel_size) {
		float dash = step(0.40, fract(pos.x / 24.0));
		final_map = mix(final_map, vec4(equator_line_color.rgb, 1.0), dash * equator_line_color.a);
	}

	// 5. Vignette tepi teater.
	float vignette = smoothstep(5400.0, 2200.0, length(world));
	final_map.rgb *= mix(0.86, 1.0, vignette);

	// 6. Posterize warna untuk nuansa piksel.
	final_map.rgb = floor(final_map.rgb * color_steps + 0.5) / color_steps;
	COLOR = final_map;
}
