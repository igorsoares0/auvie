#version 300 es
// Composites one element layer (premultiplied PNG) over a video frame with
// a W3C blend mode, like android.graphics.BlendMode does for photos
// (LayerCompositor.kt) and Flutter does in the preview. Textures and
// framebuffers here are in GL convention (first row = bottom).
precision highp float;

in vec2 vTexCoord;
out vec4 fragColor;

uniform sampler2D uBase;
uniform sampler2D uLayer;
uniform vec4 uRect;      // the layer in base uv: x0, y0 (bottom), x1, y1 (top)
uniform int uBlend;      // 0 normal, 1 screen, 2 multiply, 3 overlay, 4 soft light
uniform float uOpacity;

float softLight(float b, float s) {
    if (s <= 0.5) return b - (1.0 - 2.0 * s) * b * (1.0 - b);
    float d = b <= 0.25 ? ((16.0 * b - 12.0) * b + 4.0) * b : sqrt(b);
    return b + (2.0 * s - 1.0) * (d - b);
}

vec3 blend(vec3 b, vec3 s) {
    if (uBlend == 1) return b + s - b * s;
    if (uBlend == 2) return b * s;
    if (uBlend == 3) {
        return vec3(
            b.r <= 0.5 ? 2.0 * b.r * s.r : 1.0 - 2.0 * (1.0 - b.r) * (1.0 - s.r),
            b.g <= 0.5 ? 2.0 * b.g * s.g : 1.0 - 2.0 * (1.0 - b.g) * (1.0 - s.g),
            b.b <= 0.5 ? 2.0 * b.b * s.b : 1.0 - 2.0 * (1.0 - b.b) * (1.0 - s.b));
    }
    if (uBlend == 4) return vec3(softLight(b.r, s.r), softLight(b.g, s.g), softLight(b.b, s.b));
    return s;
}

void main() {
    vec4 base = texture(uBase, vTexCoord);
    vec2 local = (vTexCoord - uRect.xy) / (uRect.zw - uRect.xy);
    if (uOpacity <= 0.0 || any(lessThan(local, vec2(0.0))) || any(greaterThan(local, vec2(1.0)))) {
        fragColor = base;
        return;
    }
    // The PNG was uploaded from a bitmap: its first row (the top) is at t = 0.
    vec4 layer = texture(uLayer, vec2(local.x, 1.0 - local.y)) * uOpacity;
    vec3 color = layer.a > 0.0 ? layer.rgb / layer.a : vec3(0.0);
    fragColor = vec4(mix(base.rgb, clamp(blend(base.rgb, color), 0.0, 1.0), layer.a), base.a);
}
