const quad_shd = @import("../shaders/quad_mesh.glsl.zig");
const sokol = @import("sokol");
const gfx = sokol.gfx;
const math = @import("math.zig");
const vec2 = math.Vec2;
const vec3 = math.Vec3;
const uv = math.Vec2;
const vertex_format = gfx.VertexFormat;

pub const color_3b = struct {
    r: f32,
    g: f32,
    b: f32,
};
pub const color_4b = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const vertex = struct {
    position: vec3,
    uv: vec2,
    color: color_4b,
};

pub const quad = struct {
    pub const vertices = [4]vertex{
        .{
            .position = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
            .uv = .{ .x = 0.0, .y = 1.0 },
            .color = .{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 },
        },
        .{
            .position = .{ .x = 1.0, .y = 1.0, .z = 0.0 },
            .uv = .{ .x = 1.0, .y = 1.0 },
            .color = .{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 },
        },
        .{
            .position = .{ .x = 1.0, .y = 0.0, .z = 0.0 },
            .uv = .{ .x = 1.0, .y = 0.0 },
            .color = .{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 },
        },
        .{
            .position = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
            .uv = .{ .x = 0.0, .y = 0.0 },
            .color = .{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 },
        },
    };
    pub const indices = [_]u16{ 0, 1, 2, 0, 2, 3 };
    pub const get_shader_desc = quad_shd.quadShaderDesc;
    pub const vertex_attributes = [3]vertex_format{ .FLOAT3, .FLOAT2, .FLOAT4 };
};
