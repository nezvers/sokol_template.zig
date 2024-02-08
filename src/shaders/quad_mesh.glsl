// sokol-shdc -i quad_mesh.glsl -o quad_mesh.glsl.zig -l glsl330:metal_macos:hlsl4:glsl300es:wgsl -f sokol_zig
/* quad vertex shader */
@vs vs
in vec3 position;
in vec2 uv;
in vec4 color0;
out vec4 color;

void main() {
    gl_Position = vec4(position, 1.0);
    color = color0;
}
@end

/* quad fragment shader */
@fs fs
in vec4 color;
out vec4 frag_color;

void main() {
    frag_color = color;
}
@end

/* quad shader program */
@program quad vs fs

