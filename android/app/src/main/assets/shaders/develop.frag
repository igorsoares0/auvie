#version 300 es
// The "develop" shader: every adjustment and preset, shared by photo and
// (from M6) video. Parameters are normalized as in lib/core/models/adjustment.dart.
// DevelopReference.kt (src/sharedTest) mirrors steps 2-5 (with 3b) on the CPU for tests:
// keep both in sync.
// EXTERNAL_SOURCE (defined by DevelopRenderer) samples a video frame from a
// SurfaceTexture instead of a 2D texture.
#ifdef EXTERNAL_SOURCE
#extension GL_OES_EGL_image_external_essl3 : require
#endif
precision highp float;

in vec2 vTexCoord;
out vec4 fragColor;

#ifdef EXTERNAL_SOURCE
uniform samplerExternalOES uSource;
#else
uniform sampler2D uSource;
#endif
uniform mat4 uSourceTransform; // source uv (top-left origin) -> texture coordinates
uniform sampler2D uCurveLut;   // 256x1 RGBA: preset + user curves (Dart)
uniform sampler2D uColorLut;   // 256x1 RGBA by hue: hue shift, saturation, luminance; 128 = 0 (Dart)
uniform bool uColorMix;        // false when the color mix is neutral: step 3b is skipped
uniform mat3 uGeometry;        // output uv -> source uv: crop, turns, flips, straighten
uniform vec4 uTile;            // this draw's part of the output: offset.xy, scale.zw
uniform vec2 uTexel;           // 1 / source image size
uniform vec2 uSharpenStep;     // sharpen neighbour offset in source uv (DevelopTuning)
uniform float uSharpenAmount;  // sharpen strength at sharpen = 1 (DevelopTuning)
uniform float uGrainAmount;    // grain strength at grain = 1 (DevelopTuning)
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
// Color mix (HSL) at ±1: hue turns by MIX_HUE of the wheel (30 degrees),
// saturation scales like uSaturation, luminance darkens by MIX_DARKEN or
// lightens toward white by MIX_LIGHTEN. Pixels below MIX_CHROMA chroma
// fade out of it, so grays and near-grays (no reliable hue) stay as they are.
const float MIX_HUE = 30.0 / 360.0;
const float MIX_DARKEN = 0.5;
const float MIX_LIGHTEN = 0.35;
const float MIX_CHROMA = 0.08;
// Grain and sharpen strengths are uniforms (DevelopTuning.kt), tunable live
// in the engine lab.
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

vec3 toLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

vec3 toSrgb(vec3 c) {
    return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c));
}

vec3 source(vec2 uv) {
    return texture(uSource, (uSourceTransform * vec4(uv, 0.0, 1.0)).xy).rgb;
}

float curve(float v, int channel) {
    return texture(uCurveLut, vec2((v * 255.0 + 0.5) / 256.0, 0.5))[channel];
}

// Color mix of a hue (0..1): entry i of the LUT is at hue (i + 0.5) / 256.
// Interpolated here rather than by the sampler, so it wraps round the wheel.
vec3 colorMixAt(float hue) {
    float x = hue * 256.0 - 0.5;
    float i0 = floor(x);
    int a = int(mod(i0, 256.0));
    int b = int(mod(i0 + 1.0, 256.0));
    vec3 lo = texelFetch(uColorLut, ivec2(a, 0), 0).rgb;
    vec3 hi = texelFetch(uColorLut, ivec2(b, 0), 0).rgb;
    return (mix(lo, hi, x - i0) * 255.0 - 128.0) / 127.0;
}

// HSV hue (0..1) of a color with the given max channel and chroma (> 0).
float hueOf(vec3 c, float maxc, float chroma) {
    float h;
    if (maxc == c.r) {
        h = mod((c.g - c.b) / chroma, 6.0);
    } else if (maxc == c.g) {
        h = (c.b - c.r) / chroma + 2.0;
    } else {
        h = (c.r - c.g) / chroma + 4.0;
    }
    return h / 6.0;
}

vec3 hsvToRgb(float h, float s, float v) {
    vec3 k = mod(vec3(5.0, 3.0, 1.0) + h * 6.0, 6.0);
    return v - v * s * clamp(min(k, 4.0 - k), 0.0, 1.0);
}

// Dave Hoskins' hash: stable for large coordinates, unlike sin().
float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Film grain: smooth value noise over the grain cells, so it clumps like
// grain instead of showing square pixels when a cell spans several pixels.
float grainNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash12(i + uGrainSeed);
    float b = hash12(i + vec2(1.0, 0.0) + uGrainSeed);
    float c = hash12(i + vec2(0.0, 1.0) + uGrainSeed);
    float d = hash12(i + vec2(1.0, 1.0) + uGrainSeed);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
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

    vec3 c = source(src);
    if (uShowOriginal) {
        fragColor = vec4(c, 1.0);
        return;
    }

    // 1. Sharpen: 4-neighbour unsharp mask.
    if (uSharpen > 0.0) {
        // The radius follows the photo's size, so a preview and a full-size
        // export look equally sharp.
        vec3 blur = (source(src + vec2(uSharpenStep.x, 0.0)) +
                     source(src - vec2(uSharpenStep.x, 0.0)) +
                     source(src + vec2(0.0, uSharpenStep.y)) +
                     source(src - vec2(0.0, uSharpenStep.y))) * 0.25;
        c = clamp(c + (c - blur) * uSharpen * uSharpenAmount, 0.0, 1.0);
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

    // 3b. Color mix (HSL): hue, saturation and luminance by color range.
    if (uColorMix) {
        float maxc = max(c.r, max(c.g, c.b));
        float chroma = maxc - min(c.r, min(c.g, c.b));
        if (chroma > 0.0) {
            float hue = hueOf(c, maxc, chroma);
            vec3 m = colorMixAt(hue) * smoothstep(0.0, MIX_CHROMA, chroma);
            c = hsvToRgb(fract(hue + m.x * MIX_HUE), chroma / maxc, maxc);
            c = mix(vec3(dot(c, LUMA)), c, 1.0 + m.y);
            c = m.z >= 0.0 ? mix(c, vec3(1.0), m.z * MIX_LIGHTEN)
                           : c * (1.0 + m.z * MIX_DARKEN);
            c = clamp(c, 0.0, 1.0);
        }
    }

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
        float n = grainNoise(outUv * uGrainGrid) - 0.5;
        float midtones = 1.0 - 0.6 * abs(2.0 * dot(c, LUMA) - 1.0);
        c += n * uGrain * uGrainAmount * midtones;
    }

    fragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
