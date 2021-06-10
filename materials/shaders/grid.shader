shader_type spatial;

render_mode unshaded;

uniform float len1=0.015;
uniform float thickness=0.0001;
uniform vec4 color1: hint_color = vec4(1.0,0.0,0.0,1); 
uniform vec4 color2: hint_color = vec4(1.0,1.0,1.0,1); 

varying vec3 loc_vertex;

void vertex() {
    loc_vertex = VERTEX;
}

void fragment() {
    if (mod(loc_vertex.z, len1+2.0*thickness)<=len1 && mod(loc_vertex.x, len1+2.0*thickness)<=len1) {
            ALBEDO = color1.rgb;
            ALPHA = color1.a;
    } else {
            ALBEDO = color2.rgb;
            ALPHA = color2.a;
        }
}