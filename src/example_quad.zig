const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const gfx = sokol.gfx;
const log = sokol.log;
const renderer = @import("utility/renderer.zig");
const shd = @import("shaders/quad_mesh.glsl.zig");
const assets = @import("lib_headers/assets_h.zig");
const mesh = @import("utility/mesh.zig");

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
    pip_desc.layout.attrs[shd.ATTR_vs_position].format = .FLOAT3;
    pip_desc.layout.attrs[shd.ATTR_vs_uv].format = .FLOAT2;
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
