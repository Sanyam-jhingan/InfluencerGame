shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 1.0;
uniform float edge_fade : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    float intensity = smoothstep(1.0, 1.0 - edge_fade, UV.x);
    COLOR = glow_color * intensity;
    COLOR.a *= glow_strength;
}
