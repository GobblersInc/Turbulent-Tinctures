shader_type spatial;

render_mode cull_disabled;

uniform float outline_size : hint_range(0.0, 0.1) = 0.02;
uniform vec4 outline_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
    VERTEX += NORMAL * outline_size;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}
