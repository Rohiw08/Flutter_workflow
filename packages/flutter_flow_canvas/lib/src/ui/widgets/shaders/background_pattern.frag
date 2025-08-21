#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution; // Canvas size
uniform float u_scale; // Matrix scale
uniform float u_gap; // Pattern spacing
uniform vec4 u_pattern_color; // RGBA
uniform float u_opacity; // Pattern opacity
uniform float u_dot_radius; // Dot size
uniform vec2 u_offset; // Pattern offset
uniform int u_variant; // 0: dots, 1: lines, 2: grid, 3: cross

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution;
    vec2 scaled_pos = uv * u_resolution / (u_gap * u_scale);
    vec2 grid_pos = fract(scaled_pos) - 0.5; // Center on grid
    vec2 grid_index = floor(scaled_pos);

    // Apply offset
    scaled_pos -= u_offset / (u_gap * u_scale);

    float alpha = 0.0;
    if (u_variant == 0) { // Dots
        float dist = length(grid_pos);
        alpha = step(dist, u_dot_radius / u_gap);
    }

    fragColor = vec4(u_pattern_color.rgb, u_pattern_color.a * alpha * u_opacity);
}