shader_type canvas_item;

// True Nation - Professional 2D Tactical Ocean Shader
// 1. Harmoni multi-gelombang samudra 2D realistis (Gelombang Arus, Alun Laut, & Riak Mikro)
// 2. Kilau pantulan cahaya di puncak gelombang (Crest Shimmer & Wave Foam)
// 3. Gradasi batimetri kedalaman samudra (Palung Samudra Hindia/Pasifik vs Paparan Dangkal)
// 4. Garis navigasi peta laut taktis (Nautical Chart Lat/Long Grid & Garis Khatulistiwa)

uniform vec4 deep_trench_color : source_color = vec4(0.020, 0.048, 0.105, 1.0);
uniform vec4 shelf_color : source_color = vec4(0.045, 0.105, 0.195, 1.0);
uniform vec4 shallow_azure : source_color = vec4(0.075, 0.170, 0.285, 1.0);
uniform vec4 crest_foam_color : source_color = vec4(0.28, 0.58, 0.82, 0.22);
uniform vec4 wave_shimmer_color : source_color = vec4(0.55, 0.82, 1.0, 0.18);
uniform vec4 grid_line_color : source_color = vec4(0.22, 0.50, 0.78, 0.09);
uniform vec4 equator_line_color : source_color = vec4(0.85, 0.72, 0.30, 0.16);

uniform float wave_speed : hint_range(0.01, 0.5) = 0.08;
uniform float grid_step : hint_range(100.0, 800.0) = 280.0;

// Harmoni gelombang laut bertingkat (Multi-harmonic directional ocean swell)
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
	vec2 pos = VERTEX;
	float t = TIME * wave_speed;
	
	// 1. Gradasi Kedalaman Batimetri Nusantara
	float theater_dist = length(pos * vec2(0.85, 1.35)) / 2900.0;
	float depth = smoothstep(0.12, 0.92, clamp(theater_dist, 0.0, 1.0));
	
	vec4 base_water = mix(shallow_azure, shelf_color, smoothstep(0.0, 0.45, depth));
	base_water = mix(base_water, deep_trench_color, smoothstep(0.40, 1.0, depth));
	
	// 2. Aliran Gelombang & Riak Air Laut Alami
	float wave_val = ocean_swell(pos, t);
	
	// Puncak gelombang (crest)
	float crest = smoothstep(0.28, 0.75, wave_val);
	// Kilau halus spekular matahari di air
	float shimmer = pow(clamp(wave_val * 0.5 + 0.5, 0.0, 1.0), 3.2);
	
	vec4 water = mix(base_water, crest_foam_color, crest * crest_foam_color.a);
	water = mix(water, wave_shimmer_color, shimmer * wave_shimmer_color.a);
	
	// 3. Grid Garis Navigasi Peta Laut Taktis (Nautical Chart Lat/Long Grid)
	vec2 grid_pos = abs(fract(pos / grid_step + 0.5) - 0.5) * grid_step;
	float grid_line = 1.0 - smoothstep(0.0, 1.2, min(grid_pos.x, grid_pos.y));
	
	// Titik koordinat navigasi di persimpangan grid (+)
	float cross_mask = step(grid_pos.x, 5.0) * step(grid_pos.y, 5.0);
	
	vec4 final_map = mix(water, vec4(grid_line_color.rgb, 1.0), 
						 (grid_line * 0.70 + cross_mask * 0.95) * grid_line_color.a);
	
	// 4. Garis Khatulistiwa / Equator (Y = -20)
	float equator_dist = abs(pos.y - (-20.0));
	if (equator_dist < 1.4) {
		float dash = step(0.40, fract(pos.x / 24.0));
		final_map = mix(final_map, vec4(equator_line_color.rgb, 1.0), dash * equator_line_color.a);
	}
	
	// 5. Vignette tepi teater
	float vignette = smoothstep(5400.0, 2200.0, length(pos));
	final_map.rgb *= mix(0.85, 1.0, vignette);
	
	COLOR = final_map;
}
