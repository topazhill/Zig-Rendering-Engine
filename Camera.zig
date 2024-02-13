// Camera
const std = @import("std");
const glfw = @import("mach-glfw");
const pi = 3.14159265359;

pub fn init_camera() Camera {
    const cam = Camera{
        .FOV = 90,
        .aspect = 1.78,
        .nearbuffer = 0.5,
        .farbuffer = 50,
    };
    return cam;
}

const Camera = struct {
    FOV: c_int,
    aspect: f32,
    nearbuffer: f32,
    farbuffer: f32,

    var pos = [3]f32{ 0.0, 0.0, 0.0 };
    var angles = [3]f32{ 0.0, 0.0, 0.0 };

    pub fn keyHandler(self: Camera, window: glfw.Window) void {
        _ = self;
        if (glfw.Window.getKey(window, glfw.Key.escape) == glfw.Action.press) {
            _ = glfw.Window.setShouldClose(window, true);
            std.debug.print("cya", .{});
        } else {
            if (glfw.Window.getKey(window, glfw.Key.w) == glfw.Action.press) {
                move(0.0);
            }
            if (glfw.Window.getKey(window, glfw.Key.s) == glfw.Action.press) {
                move(pi);
            }
            if (glfw.Window.getKey(window, glfw.Key.a) == glfw.Action.press) {
                move(-pi / 2.0);
            }
            if (glfw.Window.getKey(window, glfw.Key.d) == glfw.Action.press) {
                move(pi / 2.0);
            }

            // Print position - for debug
            std.debug.print("{},{}\n", .{ pos[0], pos[2] });
        }
    }
    fn move(m: f32) void {
        pos[0] += 0.1 * @sin(angles[0] + m);
        pos[2] += 0.1 * @cos(angles[0] + m);
    }
};
