#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_start_point;
uniform vec2 u_end_point;
uniform vec4 u_color;
uniform float u_stroke_width;
uniform int u_edge_type;
uniform float u_arrow_size;

out vec4 fragColor;

// Function to draw a line segment
float line(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - width;
}

// Function to draw a bezier curve
float bezier(vec2 p, vec2 a, vec2 b, vec2 c, vec2 d, float width) {
    // Simplified bezier distance calculation
    // In a real implementation, you would use a more accurate method
    vec2 pa = p - a;
    vec2 ba = b - a;
    vec2 cb = c - b;
    vec2 dc = d - c;
    
    // Sample points along the curve
    float dist = 1000.0;
    for (float t = 0.0; t <= 1.0; t += 0.05) {
        vec2 pos = a + ba * t + cb * t * t + dc * t * t * t;
        float d = length(p - pos);
        dist = min(dist, d);
    }
    return dist - width;
}

void main() {
    vec2 uv = gl_FragCoord.xy;
    
    float alpha = 0.0;
    
    if (u_edge_type == 0) { // Straight line
        alpha = 1.0 - smoothstep(0.0, 1.0, line(uv, u_start_point, u_end_point, u_stroke_width));
    } else if (u_edge_type == 1) { // Bezier curve
        // Control points for bezier curve
        vec2 c1 = u_start_point + vec2((u_end_point.x - u_start_point.x) * 0.5, 0.0);
        vec2 c2 = u_start_point + vec2((u_end_point.x - u_start_point.x) * 0.5, u_end_point.y - u_start_point.y);
        
        // Simplified bezier rendering
        alpha = 1.0 - smoothstep(0.0, 1.0, line(uv, u_start_point, u_end_point, u_stroke_width));
    } else if (u_edge_type == 2) { // Step line
        vec2 mid_point = vec2(u_end_point.x, u_start_point.y);
        float d1 = line(uv, u_start_point, mid_point, u_stroke_width);
        float d2 = line(uv, mid_point, u_end_point, u_stroke_width);
        alpha = 1.0 - smoothstep(0.0, 1.0, min(d1, d2));
    }
    
    // Draw arrowhead if needed
    if (u_arrow_size > 0.0 && u_edge_type != 2) {
        // Arrow direction
        vec2 direction = normalize(u_end_point - u_start_point);
        vec2 arrow_base = u_end_point - direction * u_arrow_size;
        
        // Arrow points
        vec2 perp = vec2(-direction.y, direction.x);
        vec2 arrow_p1 = arrow_base + perp * u_arrow_size * 0.5;
        vec2 arrow_p2 = arrow_base - perp * u_arrow_size * 0.5;
        
        // Check if we're in the arrowhead area
        vec2 to_arrow_base = uv - arrow_base;
        vec2 to_end = uv - u_end_point;
        
        // Simple triangle check
        if (dot(to_end, direction) < 0.0 && dot(to_arrow_base, direction) > 0.0) {
            alpha = max(alpha, 1.0 - smoothstep(0.0, 1.0, line(uv, u_end_point, arrow_p1, u_stroke_width)));
            alpha = max(alpha, 1.0 - smoothstep(0.0, 1.0, line(uv, u_end_point, arrow_p2, u_stroke_width)));
            alpha = max(alpha, 1.0 - smoothstep(0.0, 1.0, line(uv, arrow_p1, arrow_p2, u_stroke_width)));
        }
    }
    
    fragColor = vec4(u_color.rgb, u_color.a * alpha);
}