
const std = @import("std");
const math = @import("../../math/math.zig");

const PlayerView = @import("player-view.zig").PlayerView;
const Shader = @import("../shader.zig").Shader;


pub const Scene = struct {
  playerView: PlayerView,
  defaultShader: Shader,

  pub fn init(allocator: *std.mem.Allocator) *Scene {
    var result = allocator.create(Scene) catch unreachable;
    result.playerView = PlayerView.init();
    result.defaultShader = Shader.init("default");

    return result;
  }

  pub fn deinit(self: *Scene) void {
    self.defaultShader.deinit();
  }

  pub fn draw(self: *Scene) void {
    self.defaultShader.enable();
    self.playerView.draw(&self.defaultShader);
  }
};


