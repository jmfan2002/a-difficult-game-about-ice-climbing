shader_type canvas_item;

uniform sampler2D base_texture;
uniform sampler2D overlay_texture;
uniform vec4 tint_color : source_color;

void fragment() {
    vec4 base = texture(base_texture, UV);
    vec4 overlay = texture(overlay_texture, UV);

    // Mask the overlay with the base's alpha
    overlay *= base.a;

    // Blend base and masked overlay
    COLOR = mix(base, overlay, 1) * tint_color;
}
