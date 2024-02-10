//const shd = @import("../shaders/quad_mesh.glsl.zig");
const sokol = @import("sokol");
const gfx = sokol.gfx;
const sapp = sokol.app;
const log = sokol.log;
const time = sokol.time;
const mesh = @import("mesh.zig");
const assets = @import("../lib_headers/assets_h.zig");
const math = @import("math.zig");
const vec2 = math.Vec2;
const vec3 = math.Vec3;
const vec4 = math.Vec4;
const mat4 = math.Mat4;

const state = struct {
    var bind: gfx.Bindings = .{};
    var pip: gfx.Pipeline = .{};
    var pass_action: gfx.PassAction = .{};
};

// template struct
const graphics_struct = struct {
    time_now: u64,
    time_delta: f32,
    frame_rate: f32,
    window_size: vec2,
    viewport_size: vec2,
    viewport_pos: vec2,

    proj_mat: mat4,
    ui_proj_mat: mat4,
    view_mat: mat4,
    proj_view_mat: mat4,

    cam_pos: vec3,
    cam_dir: vec3,
    cam_up: vec3,
    near_plane: f32,
    far_plane: f32,

    pub fn init(g: *graphics_struct) void {
        time.stm_setup();
        g.time_now = time.stm_now();
        g.time_delta = 0.0;
        g.frame_rate = 0.0;
        g.window_size = .{ .x = sokol.app.widthf(), .y = sokol.app.heightf() };
        g.viewport_size = g.window_size;
        g.viewport_pos = .{ .x = 0.0, .y = 0.0 };
        g.cam_up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
        g.cam_pos = .{ .x = 0.0, .y = 0.0, .z = 4.0 };
        g.cam_dir = .{ .x = 0.0, .y = 0.0, .z = -1.0 };
        g.near_plane = 0.01;
        g.far_plane = 150.0;

        g.update_perspective_view();
    }

    pub fn frame(g: *graphics_struct) void {
        g.set_viewport(sapp.width(), sapp.height());
        g.update_perspective_view();
        g.update_render_textures();
    }

    pub fn update_perspective_view(g: *graphics_struct) void {
        const fov: f32 = 75.0;
        const aspect: f32 = g.viewport_size.x / g.viewport_size.y;
        g.proj_mat = math.Mat4.persp(fov, aspect, g.near_plane, g.far_plane);

        const look_dir = math.Vec3.add(g.cam_pos, g.cam_dir);
        g.view_mat = math.Mat4.lookat(g.cam_pos, look_dir, g.cam_up);

        g.proj_view_mat = math.Mat4.mul(g.proj_mat, g.view_mat);
    }

    pub fn update_render_textures(g: *graphics_struct) void {
        // TODO: check against render texture
        if (!vec2.equal(g.viewport_size, g.viewport_size)) {
            return;
        }
    }

    pub fn set_viewport(g: *graphics_struct, pos: vec2, size: vec2) void {
        g.viewport_pos = pos;
        g.viewport_size = size;
    }

    pub fn world_to_screen(g: *graphics_struct, world_pos: vec3) vec2 {
        var t = vec4.new(world_pos.x, world_pos.y, world_pos.z, 1.0);
        t = vec4.apply_mat4(t, g.proj_view_mat);
        t = vec4.scale(t, 0.5 / t.w);
        t = vec4.add(t, vec4.new(0.5, 0.5, 0.0, 0.0));
        t.y = 1 - t.w;
        t.x = t.x * g.viewport_size.x;
        t.y = t.y * g.viewport_size.y;
        t.x = t.x + g.viewport_pos.x;
        t.y = t.y + g.viewport_pos.y;
    }

    pub fn screen_to_world(g: *graphics_struct, screen_point: vec3) vec3 {
        const c = (g.far_plane + g.near_plane) / (g.near_plane - g.far_plane);
        const d = (2.0 * g.far_plane * g.near_plane) / (g.near_plane - g.far_plane);
        screen_point.x = -1.0 + (2.0 * screen_point.x / g.viewport_size.x);
        screen_point.y = -1.0 + (2.0 * screen_point.y / g.viewport_size.y);
        const w = d / (screen_point.z + c);
        const screen = vec4.new(screen_point.x * w, screen_point.y * w, screen_point.z * w, w);
        const world = vec4.apply_mat4(screen, mat4.inverse(g.proj_view_mat));
        return vec3.new(world.x, world.y, world.z);
    }
};

pub var graphics: graphics_struct = undefined;

pub fn init() void {
    gfx.setup(.{
        .context = sokol.app_gfx_glue.context(),
        .logger = .{ .func = log.func },
    });

    // a vertex buffer
    state.bind.vertex_buffers[0] = gfx.makeBuffer(.{
        .data = gfx.asRange(&mesh.quad.vertices),
    });

    // an index buffer
    state.bind.index_buffer = gfx.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = gfx.asRange(&mesh.quad.indices),
    });

    // a shader and pipeline state object
    var pip_desc: gfx.PipelineDesc = .{
        .index_type = .UINT16,
        .shader = gfx.makeShader(mesh.quad.get_shader_desc(gfx.queryBackend())),
    };
    // shader vertex input
    for (mesh.quad.vertex_attributes, 0..) |attr, i| {
        pip_desc.layout.attrs[i].format = attr;
    }
    state.pip = gfx.makePipeline(pip_desc);

    // clear to black
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
    };

    // Initialize graphics
    graphics.init();
}

pub fn frame() void {
    gfx.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    // I assume this is pipeline per shader
    gfx.applyPipeline(state.pip);
    gfx.applyBindings(state.bind);
    gfx.draw(0, 6, 1);

    gfx.endPass();
    gfx.commit();
}

pub fn cleanup() void {
    gfx.shutdown();
}
