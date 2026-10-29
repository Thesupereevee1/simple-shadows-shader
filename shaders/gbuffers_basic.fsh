#version 120

uniform sampler2D lightmap;

varying vec2 lmcoord;
varying vec4 glcolor;

void main() {
	vec4 color = glcolor;
	// Boost minimum light level for text/nametags so they don't get dark
	vec2 lm = max(lmcoord, vec2(0.0, 0.75));
	color *= texture2D(lightmap, lm);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}