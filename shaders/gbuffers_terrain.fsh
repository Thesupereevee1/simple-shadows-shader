#version 120

#define COLORED_SHADOWS 1
#define SHADOW_BRIGHTNESS 0.25

uniform sampler2D lightmap;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;

const bool shadowcolor0Nearest = false;
const bool shadowtex0Nearest = false;
const bool shadowtex1Nearest = false;

#include "/distort.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec2 lm = lmcoord;

	if (shadowPos.w > 0.0) {
		#if COLORED_SHADOWS == 0
			float shadowFactor = sampleShadowSoft(shadowtex0, shadowPos.xyz);
		#else
			float shadowFactor = sampleShadowSoft(shadowtex1, shadowPos.xyz);
		#endif

		if (shadowFactor < 0.99) {
			float currentBrightness = mix(SHADOW_BRIGHTNESS, 1.0, shadowFactor);
			lm.y *= currentBrightness;
		}
		else {
			lm.y = mix(31.0 / 32.0 * SHADOW_BRIGHTNESS, 31.0 / 32.0, sqrt(shadowPos.w));
			#if COLORED_SHADOWS == 1
				// Fix green outline artifacts: verify translucency alpha exists before blending
				if (texture2D(shadowtex0, shadowPos.xy).r < shadowPos.z - 0.0005) {
					vec4 shadowLightColor = texture2D(shadowcolor0, shadowPos.xy);
					if (shadowLightColor.a > 0.001) {
						shadowLightColor.rgb = mix(vec3(1.0), shadowLightColor.rgb, shadowLightColor.a);
						shadowLightColor.rgb = mix(shadowLightColor.rgb, vec3(1.0), lm.x);
						color.rgb *= shadowLightColor.rgb;
					}
				}
			#endif
		}
	}
	color *= texture2D(lightmap, lm);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}