#version 300 es
// The "develop" shader: every adjustment and preset, shared by photo and
// (from M6) video. Parameters are normalized as in lib/core/models/adjustment.dart.
// DevelopReference.kt (src/sharedTest) mirrors steps 2-5 on the CPU for tests:
// keep both in sync.
precision highp float;

in vec2 vTexCoord;
out vec4 fragColor;

uniform sampler2D uSource;
uniform sampler2D uCurveLut;   // 256x1 RGBA: preset + user curves (Dart)
uniform mat3 uGeometry;        // output uv -> source uv: crop, turns, flips, straighten
uniform vec4 uTile;            // this draw's part of the output: offset.xy, scale.zw
uniform vec2 uTexel;           // 1 / source texture size
uniform float uAspect;         // full output width / height
uniform vec2 uGrainGrid;       // grain cells across the full output
uniform float uGrainSeed;
uniform bool uShowOriginal;

uniform float uExposure;
uniform float uBrightness;
uniform float uContrast;
uniform float uHighlights;
uniform float uShadows;
uniform float uSaturation;
uniform float uTemperature;
uniform float uTint;
uniform float uSharpen;
uniform float uGrain;
uniform float uFade;
uniform float uVignette;

// Strength of each parameter at ±1. Tune with the engine lab (/dev/engine).
const float EXPOSURE_STOPS = 2.0;
const float WHITE_BALANCE = 0.15;
const float BRIGHTNESS_POWER = 0.8;
const float TONE_AMOUNT = 0.25;
const float FADE_LIFT = 0.15;
const float VIGNETTE_AMOUNT = 0.6;
const float VIGNETTE_START = 0.35;
const float GRAIN_AMOUNT = 0.12;
const float SHARPEN_AMOUNT = 1.5;
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

vec3 toLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

vec3 toSrgb(vec3 c) {
    return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c));
}

float curve(float v, int channel) {
    return texture(uCurveLut, vec2((v * 255.0 + 0.5) / 256.0, 0.5))[channel];
}

// Dave Hoskins' hash: stable for large coordinates, unlike sin().
float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    // Position in the whole output (exports render it in tiles), then where
    // that is in the original.
    vec2 outUv = uTile.xy + vTexCoord * uTile.zw;
    vec2 src = (uGeometry * vec3(outUv, 1.0)).xy;
    if (any(lessThan(src, vec2(-0.002))) || any(greaterThan(src, vec2(1.002)))) {
        // Off the image: only visible around a straightened photo while cropping.
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 c = texture(uSource, src).rgb;
    if (uShowOriginal) {
        fragColor = vec4(c, 1.0);
        return;
    }

    // 1. Sharpen: 4-neighbour unsharp mask.
    if (uSharpen > 0.0) {
        vec3 blur = (texture(uSource, src + vec2(uTexel.x, 0.0)).rgb +
                     texture(uSource, src - vec2(uTexel.x, 0.0)).rgb +
                     texture(uSource, src + vec2(0.0, uTexel.y)).rgb +
                     texture(uSource, src - vec2(0.0, uTexel.y)).rgb) * 0.25;
        c = clamp(c + (c - blur) * uSharpen * SHARPEN_AMOUNT, 0.0, 1.0);
    }

    // 2. Light, in linear: exposure and white balance.
    vec3 lin = toLinear(c) * exp2(uExposure * EXPOSURE_STOPS);
    lin *= vec3(1.0 + uTemperature * WHITE_BALANCE,
                1.0 - uTint * WHITE_BALANCE,
                1.0 - uTemperature * WHITE_BALANCE);
    c = toSrgb(clamp(lin, 0.0, 1.0));

    // 3. Tone and color, in sRGB.
    c = pow(c, vec3(exp2(-uBrightness * BRIGHTNESS_POWER)));
    float l = dot(c, LUMA);
    c += (uShadows * (1.0 - smoothstep(0.0, 0.5, l)) +
          uHighlights * smoothstep(0.5, 1.0, l)) * TONE_AMOUNT;
    c = (c - 0.5) * (1.0 + uContrast) + 0.5;
    c = mix(vec3(dot(c, LUMA)), c, 1.0 + uSaturation);
    c = clamp(c, 0.0, 1.0);

    // 4. Curves.
    c = vec3(curve(c.r, 0), curve(c.g, 1), curve(c.b, 2));

    // 5. Film: fade, vignette, grain.
    c += uFade * FADE_LIFT * (1.0 - c);

    vec2 centered = (outUv - 0.5) * vec2(uAspect, 1.0);
    float d = length(centered) / length(vec2(uAspect, 1.0) * 0.5);
    float v = smoothstep(VIGNETTE_START, 1.0, d) * VIGNETTE_AMOUNT;
    c = uVignette >= 0.0 ? c * (1.0 - uVignette * v)
                         : c + (-uVignette) * v * (1.0 - c);

    if (uGrain > 0.0) {
        float n = hash12(floor(outUv * uGrainGrid) + uGrainSeed) - 0.5;
        float midtones = 1.0 - 0.6 * abs(2.0 * dot(c, LUMA) - 1.0);
        c += n * uGrain * GRAIN_AMOUNT * midtones;
    }

    fragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
