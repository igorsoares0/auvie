#version 300 es
// Full-screen quad. uFlipY maps the bitmap's top row to the top of a window
// surface; offscreen renders keep row order for glReadPixels.
in vec2 aPosition;
uniform bool uFlipY;
out vec2 vTexCoord;

void main() {
    vTexCoord = vec2(aPosition.x * 0.5 + 0.5,
                     uFlipY ? 0.5 - aPosition.y * 0.5 : 0.5 + aPosition.y * 0.5);
    gl_Position = vec4(aPosition, 0.0, 1.0);
}
