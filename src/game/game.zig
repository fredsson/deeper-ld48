const std = @import("std");
const math = @import("../math/math.zig");

const Player = @import("player.zig").Player;

const maxUpdates: u16 = 10;
const tickRate: f32 = comptime 1.0 / 60.0;

const startPosition = math.Vec3.new(0.2, 0.2, 0);

pub const Game = struct {
  allocator: *std.mem.Allocator,
  unHandledElapsedFrameTime: f32,
  player: Player,

  pub fn init(allocator: *std.mem.Allocator) *Game {
    var game = allocator.create(Game) catch unreachable;
    game.allocator = allocator;
    game.unHandledElapsedFrameTime = 0;
    game.player = Player.init(startPosition);

    return game;
  }

  pub fn deinit(self: *Game) void {
    self.allocator.destroy(self);
  }

  pub fn update(self: *Game, dt: f32) void {
    self.fixedUpdate(dt);

    self.player.update(dt);
    // update all systems with dt
  }

  pub fn onPlayerPositionChanged(self: *Game, position: math.Vec3) void {
    std.debug.print("changed position: {}", .{position});
  }

  fn fixedUpdate(self: *Game, dt: f32) void {
    self.unHandledElapsedFrameTime += dt;

    var updates: u16 = 0;
    while (self.unHandledElapsedFrameTime >= tickRate and updates < maxUpdates) {
      defer updates += 1;
      defer self.unHandledElapsedFrameTime -= tickRate;

      self.player.fixedUpdate();
    }
  }
};


