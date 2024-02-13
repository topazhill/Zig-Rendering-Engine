const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "test",
        .root_source_file = .{ .path = "src/main_test.zig" },
        .target = b.host,
    });

    // Use mach-glfw
    const glfw_dep = b.dependency("mach_glfw", .{
        //.target = target,
        //.optimize = optimize,
    });
    exe.root_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));

    // Setup OpenGL Bindings as a module
    exe.root_module.addImport("gl", b.createModule(.{
        .root_source_file = .{ .path = "gl.zig" },
    }));

    b.installArtifact(exe);
}
