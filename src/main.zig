const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const gfx = sokol.gfx;
const log = sokol.log;
const shd = @import("shaders/quad.glsl.zig");

const state = struct {
    var bind: gfx.Bindings = .{};
    var pip: gfx.Pipeline = .{};
    var pass_action: gfx.PassAction = .{};
};

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .event_cb = input,
        .cleanup_cb = cleanup,
        .window_title = "My Template",
        .width = 1280,
        .height = 720,
        .icon = .{ .sokol_default = true },
        .logger = .{ .func = log.func },
    });
}

export fn init() void {
    gfx.setup(.{
        .context = sokol.app_gfx_glue.context(),
        .logger = .{ .func = log.func },
    });

    // a vertex buffer
    state.bind.vertex_buffers[0] = gfx.makeBuffer(.{
        .data = gfx.asRange(&[_]f32{
            // positions      colors
            -0.5, 0.5,  0.5, 1.0, 0.0, 0.0, 1.0,
            0.5,  0.5,  0.5, 0.0, 1.0, 0.0, 1.0,
            0.5,  -0.5, 0.5, 0.0, 0.0, 1.0, 1.0,
            -0.5, -0.5, 0.5, 1.0, 1.0, 0.0, 1.0,
        }),
    });

    // an index buffer
    state.bind.index_buffer = gfx.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = gfx.asRange(&[_]u16{ 0, 1, 2, 0, 2, 3 }),
    });

    // a shader and pipeline state object
    var pip_desc: gfx.PipelineDesc = .{
        .index_type = .UINT16,
        .shader = gfx.makeShader(shd.quadShaderDesc(gfx.queryBackend())),
    };
    pip_desc.layout.attrs[shd.ATTR_vs_position].format = .FLOAT3;
    pip_desc.layout.attrs[shd.ATTR_vs_color0].format = .FLOAT4;
    state.pip = gfx.makePipeline(pip_desc);

    // clear to black
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
    };
}

export fn frame() void {
    gfx.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    gfx.applyPipeline(state.pip);
    gfx.applyBindings(state.bind);
    gfx.draw(0, 6, 1);
    gfx.endPass();
    gfx.commit();
}

export fn input(event: ?*const sapp.Event) void {
    const ev = event.?;

    if (ev.type == .KEY_DOWN) {
        switch (ev.key_code) {
            .Q, .ESCAPE => sapp.requestQuit(),
            .F => sapp.toggleFullscreen(),
            else => {},
        }
    }
}

export fn cleanup() void {
    gfx.shutdown();
}
