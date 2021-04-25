const c = @import("../../c.zig");
const std = @import("std");
const math = @import("../../math/math.zig");
const Shader = @import("../shader.zig").Shader;
const PlayerListener = @import("../../game/player.zig").PlayerListener;


const noPointerOffset: ?*const c_void = @intToPtr(?*c_void, 0);

pub const PlayerView = struct {
  const Self = @This();
  position: math.Mat4x4,
  vertexArrayId: c.GLuint,
  playerListener: PlayerListener,

  pub fn init(allocator: *std.mem.Allocator) *PlayerView {
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

    var playerView = allocator.create(PlayerView) catch unreachable;
    playerView.position = math.Mat4x4.identity;
    playerView.vertexArrayId = vertexArrayId;
    playerView.playerListener = PlayerListener{ .onPositionChanged =  updatePosition };
    return playerView;
  }

  pub fn draw(self: *PlayerView, shader: *Shader) void {
    shader.setUniformMat4("modelPosition", &self.position);

    c.glBindVertexArray(self.vertexArrayId);
    c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
  }

  fn updatePosition(listener: *PlayerListener, position: math.Vec3)void {
    const self = @fieldParentPtr(Self, "playerListener", listener);

    const translate = math.Mat4x4.createTranslation(position);
    self.position = math.Mat4x4.identity.mul(translate);
  }
};
