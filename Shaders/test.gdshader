shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//chromatic aberration
uniform vec2 r_displacement = vec2(0.0,0.0);
uniform vec2 g_displacement = vec2(0.0,0.0);
uniform vec2 b_displacement = vec2(0.0,0.0);
//interlacing


void fragment() {
	float r = texture(SCREEN_TEXTURE,SCREEN_UV+SCREEN_PIXEL_SIZE*r_displacement).r;
	float g = texture(SCREEN_TEXTURE,SCREEN_UV+SCREEN_PIXEL_SIZE*g_displacement).g;
	float b = texture(SCREEN_TEXTURE,SCREEN_UV+SCREEN_PIXEL_SIZE*b_displacement).b;
	COLOR = vec4(r,g,b,texture(SCREEN_TEXTURE,SCREEN_UV).a);
}
