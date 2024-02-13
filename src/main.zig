const std = @import("std");
const glfw = @import("mach-glfw"); // Imports mach-glfw
const gl = @import("gl"); // Imports gl bindings
const shaders = @import("Shaders.zig");
const camera = @import("Camera.zig");

// void GLAPIENTRY
//MessageCallback( GLenum source,
//                 GLenum type,
//                 GLuint id,
//                 GLenum severity,
//                 GLsizei length,
//                 const GLchar* message,
//                 const void* userParam )
//   fprintf( stderr, "GL CALLBACK: %s type = 0x%x, severity = 0x%x, message = %s\n",
//    ( type == GL_DEBUG_TYPE_ERROR ? "** GL ERROR **" : "" ),
//     type, severity, message );
fn glErrorCallback(source: gl.GLenum, typ: gl.GLenum, id: gl.GLuint, severity: gl.GLenum, length: gl.GLsizei, message: [*:0]const u8, userparam: ?*anyopaque) callconv(.C) void {
    std.log.warn("GLError type = {}, severity {}, message {s}", .{ typ, severity, message });
    _ = source;
    _ = id;
    _ = length;
    _ = userparam;
}

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    //_ = p;
    std.log.warn("GOT {}", .{p});
    return glfw.getProcAddress(proc);
}

pub fn main() !void {

    // Set error callback

    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create a window

    const window = glfw.Window.create(600, 400, "Window!", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 1,
    }) orelse {
        std.process.exit(1);
    }; // width, height, title, monitor, share, hints
    defer window.destroy();

    glfw.makeContextCurrent(window); // Sets the focus on the created window

    // Loads OpenGL pointers
    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    // Loading Shaders
    var shader = shaders.LoadShaders();

    // Creates VAO (Vertex Array Object) and sets as current one
    var VertexArrayID: gl.GLuint = undefined;
    gl.genVertexArrays(1, &VertexArrayID);
    gl.bindVertexArray(VertexArrayID);

    const vertex_buffer_data = [12]gl.GLfloat{
        -0.75, -0.75, 0.0, // bottom left
        -0.75, 0.75, 0.0, // top left
        0.75, -0.75, 0.0, // bottom right
        0.75, 0.75, 0.0, // top right
    }; // stores all of the vertices in the environment to be drawn

    const indeces = [6]gl.GLint{
        0, 1, 2,
        1, 2, 3,
    };

    // Draw all the triangles

    var vertexbuffer: gl.GLuint = undefined;
    var EBO: gl.GLuint = undefined;

    gl.genBuffers(1, &vertexbuffer); // generates an OpenGL buffer and sets vertexbuffer to it
    gl.genBuffers(1, &EBO);

    gl.bindBuffer(gl.ARRAY_BUFFER, vertexbuffer);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO);

    gl.bufferData(gl.ARRAY_BUFFER, vertex_buffer_data.len * @sizeOf(f32), &vertex_buffer_data, gl.STATIC_DRAW); // sends vertices to openGL
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indeces.len * @sizeOf(gl.GLuint), &indeces, gl.STATIC_DRAW);

    gl.vertexAttribPointer(
        0,
        3, // size
        gl.FLOAT, // type
        gl.FALSE, // normalised
        3 * @sizeOf(f32), // stride
        null, // array buffer offset
    );

    gl.enableVertexAttribArray(0);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {

        // Run main loop in here

        // Process Input Here
        camera.keyHandler(window);

        // Then transforms + clipping

        gl.clearColor(0.0, 0.0, 0.4, 0.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        // Use shaders

        shader.use();

        // Then draw everything
        gl.bindVertexArray(VertexArrayID);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO);
        gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, null);
        gl.bindVertexArray(0);

        window.swapBuffers();
        glfw.pollEvents();

        while (gl.getError() != gl.NO_ERROR) {
            std.log.err("ERROR GL", .{});
        }
    }
}
