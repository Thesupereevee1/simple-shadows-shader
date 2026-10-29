#define SHADOW_DISTORT_ENABLED //Toggles shadow map distortion
#define SHADOW_DISTORT_FACTOR 0.10 //Distortion factor for the shadow map
float SHADOW_BIAS = 3.50; //Base shadow bias
#define NORMAL_BIAS off
#define EXCLUDE_FOLIAGE //If defined, foliage will not cast shadows
#define SHADOW_BRIGHTNESS 0.25 //Terrain shadow brightness

const int shadowMapResolution = 4096;

#ifdef SHADOW_DISTORT_ENABLED
	vec3 distort(vec3 pos) {
		float factor = length(pos.xy) + SHADOW_DISTORT_FACTOR;
		return vec3(pos.xy / factor, pos.z * 0.5);
	}

	float computeBias(vec3 pos) {
		float numerator = length(pos.xy) + SHADOW_DISTORT_FACTOR;
		numerator *= numerator;
		return SHADOW_BIAS / shadowMapResolution * numerator / SHADOW_DISTORT_FACTOR;
	}
#else
	vec3 distort(vec3 pos) {
		return vec3(pos.xy, pos.z * 0.5);
	}

	float computeBias(vec3 pos) {
		return SHADOW_BIAS / shadowMapResolution;
	}
#endif

// Fast 4-tap PCF filter
float sampleShadowSoft(sampler2D shadowMap, vec3 shadowPos) {
	float texelSize = 1.0 / float(shadowMapResolution);
	float shadow = 0.0;
	
	shadow += step(shadowPos.z, texture2D(shadowMap, shadowPos.xy + vec2(-0.5, -0.5) * texelSize).r);
	shadow += step(shadowPos.z, texture2D(shadowMap, shadowPos.xy + vec2( 0.5, -0.5) * texelSize).r);
	shadow += step(shadowPos.z, texture2D(shadowMap, shadowPos.xy + vec2(-0.5,  0.5) * texelSize).r);
	shadow += step(shadowPos.z, texture2D(shadowMap, shadowPos.xy + vec2( 0.5,  0.5) * texelSize).r);

	return shadow * 0.25;
}