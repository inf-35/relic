shader_type canvas_item;

uniform float hframes = 20;
uniform float vframes = 20;
uniform float shadow_scale = 2.5;
const float buffer = 3.0;

uniform vec4 shadow_color = vec4(0.0824,0.0784,0.1019,0.3);

void vertex() {
	VERTEX *= buffer;
}

void fragment() {
	vec2 grid = vec2(TEXTURE_PIXEL_SIZE.x / hframes, TEXTURE_PIXEL_SIZE.y / vframes);

	vec4 texture_color = texture(TEXTURE,UV);
	vec2 current_pt = TEXTURE_PIXEL_SIZE * UV; //current pt in pixels
	
	float row = floor(current_pt.y / grid.y);
	float col = floor(current_pt.x / grid.x);
	
	vec2 min_pt = vec2(col,row) * grid;
	vec2 max_pt = vec2(col+1.0,row+1.0) * grid;
	
	vec2 local_pt = current_pt - min_pt; //pt in pixels relative to local grid
	vec2 local_uv = 1.0 - (local_pt) / grid;
	
	vec2 buffer_scaled_pt = (min_pt + (local_pt) * buffer) - grid * (buffer - 1.0) * 0.5;
	vec2 shadow_pt = (min_pt + vec2(0,grid.y*(1.0 + shadow_scale * 2.0)) + vec2(local_pt.x,grid.y - local_pt.y * (1.0 + shadow_scale)) * buffer) - grid * (buffer - 1.0) * 0.5;
	
	if (buffer_scaled_pt.x > min_pt.x && buffer_scaled_pt.y > min_pt.y && buffer_scaled_pt.x < max_pt.x && buffer_scaled_pt.y < max_pt.y) {
		COLOR = texture(TEXTURE,buffer_scaled_pt / TEXTURE_PIXEL_SIZE);
	}
	else if (shadow_pt.x > min_pt.x && shadow_pt.y > min_pt.y && shadow_pt.x < max_pt.x && shadow_pt.y < max_pt.y) {
		COLOR = shadow_color;
		COLOR.a *= texture(TEXTURE,shadow_pt / TEXTURE_PIXEL_SIZE).a;
	}
	else {
		COLOR = vec4(0,0,0,0);
	}
}
