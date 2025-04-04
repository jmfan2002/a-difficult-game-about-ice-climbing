shader_type canvas_item;

uniform sampler2D ground_texture;
uniform vec2 tile_count = vec2(4.0, 4.0); // How many tiles to show in the TextureRect

void fragment() {
    vec2 uv = UV * tile_count;
    COLOR = texture(ground_texture, uv);
}
