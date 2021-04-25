const std = @import("std");
const c = @import("../c.zig");
const math = @import("../math/math.zig");

var allocator = std.heap.page_allocator;

pub const Shader = struct {
  programId: c.GLuint,

  pub fn init(name: []const u8) Shader {
    return Shader {
      .programId = loadShaderFromRelativePath(name)
    };
  }

  pub fn deinit(self: Shader) void {
    c.glDeleteProgram(self.programId);
  }

  pub fn enable(self: Shader) void {
    c.glUseProgram(self.programId);
  }

  pub fn setUniformMat4(self: Shader, location: [*c]const u8, value: *math.Mat4x4) void {
    const uniformLocation = c.glGetUniformLocation(self.programId, location);

    c.glUniformMatrix4fv(uniformLocation, 1, c.GL_FALSE, &value.fields[0][0]);
  }

  pub fn disable(self: Shader) void {
  }
};

fn loadShaderFromRelativePath(name: []const u8) c.GLuint {
  const vertexShaderPath = std.fmt.allocPrint(allocator, "assets/gfx/{}.vert", .{name}) catch unreachable;
  defer allocator.free(vertexShaderPath);

  const fragmentShaderPath = std.fmt.allocPrint(allocator, "assets/gfx/{}.frag", .{name}) catch unreachable;
  defer allocator.free(fragmentShaderPath);

  const cwd = std.fs.cwd();

  const vertexId = compileShader(cwd, vertexShaderPath, c.GL_VERTEX_SHADER) catch unreachable;
  defer c.glDeleteShader(vertexId);
  const fragmentId = compileShader(cwd, fragmentShaderPath, c.GL_FRAGMENT_SHADER) catch unreachable;
  defer c.glDeleteShader(fragmentId);

  const programId = c.glCreateProgram();
  c.glAttachShader(programId, vertexId);
  c.glAttachShader(programId, fragmentId);

  c.glLinkProgram(programId);

  return programId;
}

fn compileShader(cwd: std.fs.Dir, relativePath: []const u8, comptime shaderType: c.GLenum) !c.GLuint {
  var compileResult: c.GLint = c.GL_FALSE;

  const shaderFile = try cwd.openFile(relativePath, .{});
  defer shaderFile.close();

  var shaderCode = try allocator.alloc(u8, try shaderFile.getEndPos());
  defer allocator.free(shaderCode);

  const shaderObject: c.GLuint = c.glCreateShader(shaderType);
  _ = try shaderFile.read(shaderCode);
  const shaderSrcPtr: ?[*]const u8 = shaderCode.ptr;
  c.glShaderSource(shaderObject, 1, &shaderSrcPtr, 0);
  c.glCompileShader(shaderObject);

  return shaderObject;
}
