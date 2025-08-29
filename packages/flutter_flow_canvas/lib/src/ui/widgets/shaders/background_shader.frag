#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_offset;
uniform float u_scale;
uniform vec4 u_color;
uniform float u_gap;
uniform int u_pattern_type;
uniform float u_dot_radius;
uniform float u_cross_size;

out vec4 fragColor;

void main() {
    // Calculate normalized coordinates
    vec2 uv = gl_FragCoord.xy / u_resolution;
    vec2 pos = uv * u_resolution;
    
    // Apply offset and scale
    pos = (pos - u_offset) / u_scale;
    
    // Calculate grid coordinates
    vec2 grid_coord = mod(pos, u_gap);
    vec2 grid_index = floor(pos / u_gap);
    
    float alpha = 1.0;
    
    if (u_pattern_type == 0) { // Dots pattern
        vec2 center = vec2(u_gap * 0.5);
        float dist = distance(grid_coord, center);
        alpha = smoothstep(u_dot_radius, u_dot_radius - 1.0, dist);
    } else if (u_pattern_type == 1) { // Grid pattern
        float lineWidth = 1.0;
        float halfLineWidth = lineWidth * 0.5;
        alpha = (grid_coord.x < lineWidth || grid_coord.y < lineWidth) ? 1.0 : 0.0;
    } else if (u_pattern_type == 2) { // Cross pattern
        vec2 center = vec2(u_gap * 0.5);
        float half_cross = u_cross_size * 0.5;
        bool is_horizontal = abs(grid_coord.y - center.y) < 1.0 && 
                            abs(grid_coord.x - center.x) <= half_cross;
        bool is_vertical = abs(grid_coord.x - center.x) < 1.0 && 
                          abs(grid_coord.y - center.y) <= half_cross;
        alpha = (is_horizontal || is_vertical) ? 1.0 : 0.0;
    } else { // No pattern
        alpha = 0.0;
    }
    
    fragColor = vec4(u_color.rgb, u_color.a * alpha);
}