const sokol = @import("sokol");
const sapp = sokol.app;
const log = sokol.log;
const renderer = @import("utility/renderer.zig");

//var update_callback = init_frame;

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
    renderer.init();
}

export fn frame() void {
    renderer.frame();
}

export fn cleanup() void {
    renderer.cleanup();
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
