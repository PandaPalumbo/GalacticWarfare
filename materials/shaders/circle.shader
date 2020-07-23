shader_type spatial;

uniform float alpha;
uniform vec3 unitPos;
uniform float R = 6.0;

varying mat4 CAMERA;

void vertex() {
	CAMERA = CAMERA_MATRIX;
	VERTEX.y = sin(1.0) + cos(1.0);
}


void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	// make circle
	vec3 color = vec3(0., 1., 1.); // RED
	if(distance(world_position, unitPos) < R){
        ALBEDO = color + texture(SCREEN_TEXTURE, SCREEN_UV).xyz;
        ALPHA = alpha;
    }
    else
        ALPHA = 0.;
	
}