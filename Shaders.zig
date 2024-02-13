const std = @import("std");
const gl = @import("gl"); // Imports gl bindings
const Shader = @This();

ID: gl.GLuint,

pub fn use(self: Shader) void {
    gl.useProgram(self.ID);
}

pub fn LoadShaders() Shader {

    // Shader Code

    const vertex_shader =
        \\ # version 410 core
        \\layout(location = 0) in vec3 aPos;
        \\void main()
        \\{
        \\gl_Position = vec4(aPos.x,aPos.y,aPos.z,1.0);
        \\}
    ;

    const fragment_shader =
        \\# version 410 core
        \\out vec4 color;
        \\void main() {
        \\color = vec4(1.0,0.0,0.0,1.0);
        \\}
    ;

    var Result: c_int = undefined;
    var InfoLog: [512]u8 = [_]u8{0} ** 512;

    // Vertex Shader
    const vertex_shader_id: gl.GLuint = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertex_shader_id);

    gl.shaderSource(vertex_shader_id, 1, @as([*c]const [*c]const u8, @ptrCast(&vertex_shader)), 0);
    gl.compileShader(vertex_shader_id);

    // Check vertex shader
    gl.getShaderiv(vertex_shader_id, gl.COMPILE_STATUS, &Result);

    if (Result == 0) {
        gl.getShaderInfoLog(vertex_shader_id, 512, 0, &InfoLog);
        std.log.err("{s}", .{InfoLog});
    }

    // Fragment Shader
    const fragment_shader_id: gl.GLuint = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragment_shader_id);

    gl.shaderSource(fragment_shader_id, 1, @as([*c]const [*c]const u8, @ptrCast(&fragment_shader)), 0);
    gl.compileShader(fragment_shader_id);

    // Check fragment shader
    gl.getShaderiv(fragment_shader_id, gl.COMPILE_STATUS, &Result);

    if (Result == 0) {
        gl.getShaderInfoLog(fragment_shader_id, 512, 0, &InfoLog);
        std.log.err("{s}", .{InfoLog});
    }

    // Link program
    const ProgramID: gl.GLuint = gl.createProgram();
    std.debug.print("{any}", .{ProgramID});
    defer gl.deleteProgram(ProgramID);

    gl.attachShader(ProgramID, vertex_shader_id);
    gl.attachShader(ProgramID, fragment_shader_id);
    gl.linkProgram(ProgramID);

    // Check program
    gl.getProgramiv(ProgramID, gl.LINK_STATUS, &Result);
    if (Result == 0) {
        gl.getProgramInfoLog(ProgramID, 512, 0, &InfoLog);
        std.log.err("{s}", .{InfoLog});
    }

    return Shader{
        .ID = ProgramID,
    };
}
