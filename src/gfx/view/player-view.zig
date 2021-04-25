const c = @import("../../c.zig");
const math = @import("../../math/math.zig");
const Shader = @import("../shader.zig").Shader;

const noPointerOffset: ?*const c_void = @intToPtr(?*c_void, 0);

pub const PlayerView = struct {
  position: math.Mat4x4,
  vertexArrayId: c.GLuint,

  pub fn init() PlayerView {
    var vertexArrayId: c.GLuint = 0;
    var vertexBufferId: c.GLuint = 0;
    c.glGenBuffers(1, &vertexBufferId);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vertexBufferId);
    var array: [9]f32 = .{
      -0.5, -0.5, 0.0,
      0.0,  0.5, 0.0,
      0.5, -0.5, 0.0,
    };
    c.glBufferData(c.GL_ARRAY_BUFFER, array.len * @sizeOf(f32), &array[0], c.GL_STATIC_DRAW);

    c.glGenVertexArrays(1, &vertexArrayId);
    c.glBindVertexArray(vertexArrayId);
    c.glEnableVertexAttribArray(0);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vertexBufferId);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 0, noPointerOffset);

    return .{
      .position = math.Mat4x4.identity,
      .vertexArrayId = vertexArrayId,
    };
  }

  pub fn draw(self: *PlayerView, shader: *Shader) void {
    shader.setUniformMat4("modelPosition", &self.position);

    c.glBindVertexArray(self.vertexArrayId);
    c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
  }

  pub fn updatePosition(self: *PlayerView, position: math.Vec3) void {
    const translate = math.Mat4x4.createTranslation(position);
    const newPosition = self.position.mul(translate);

    self.position = newPosition;
  }
};
